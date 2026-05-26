import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui' as ui;
// ═══════════════════════════════════════════════════════════════════════════════
// lib/presentation/screens/ai/swot_report_screen.dart
// ═══════════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/remote/vertex/gemini_service.dart';
import '../../providers/all_providers.dart';
import '../../../router/app_router.dart';

const _kSwotCacheKey = 'prepsarthi_swot_cache_v1';
const _kSwotCacheTimeKey = 'prepsarthi_swot_cache_time_v1';
const _kPatternCacheKey = 'prepsarthi_pattern_cache_v1';
const _kPatternCacheTimeKey = 'prepsarthi_pattern_cache_time_v1';

// Cached SWOT provider — returns cached report on network failure
final _swotReportProvider = FutureProvider<_CachedReport<SWOTReport?>>((ref) async {
  final planState = ref.read(planProvider);
  final logs = ref.read(studyLogProvider);
  final authState = ref.read(authProvider);
  final sub = ref.read(subscriptionProvider);

  if (!sub.isPremium) return _CachedReport(data: null, cachedAt: null);

  final summary = ref.read(dashboardSummaryProvider);
  final prefs = await SharedPreferences.getInstance();

  try {
    final report = await GeminiService.generateSWOT(
      allChapters: planState.chapters,
      last30DaysLogs: logs,
      streakDays: authState.user?.currentStreak ?? 0,
      avgDailyHours: summary.avgDailyHours,
      overallProgress: summary.overallProgress * 100,
      subjectProgress: summary.subjectProgress.map((k, v) => MapEntry(k, v * 100)),
    );
    // Cache on success
    if (report != null) {
      await prefs.setString(_kSwotCacheKey, jsonEncode(report.toJson()));
      await prefs.setInt(_kSwotCacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    }
    return _CachedReport(data: report, cachedAt: null);
  } catch (_) {
    // Offline — try cache
    final cached = prefs.getString(_kSwotCacheKey);
    final cachedTime = prefs.getInt(_kSwotCacheTimeKey);
    if (cached != null) {
      final report = SWOTReport.fromJson(jsonDecode(cached) as Map<String, dynamic>);
      return _CachedReport(
        data: report,
        cachedAt: cachedTime != null
            ? DateTime.fromMillisecondsSinceEpoch(cachedTime)
            : null,
      );
    }
    rethrow;
  }
});

/// Wrapper that carries a freshness timestamp for offline-served cache results.
class _CachedReport<T> {
  final T data;
  final DateTime? cachedAt; // null = freshly fetched; non-null = served from cache

  const _CachedReport({required this.data, required this.cachedAt});

  bool get isFromCache => cachedAt != null;

  String get cacheAge {
    if (cachedAt == null) return '';
    final diff = DateTime.now().difference(cachedAt!);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class SWOTReportScreen extends ConsumerWidget {
  const SWOTReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPremium = ref.watch(subscriptionProvider).isPremium;
    final swotAsync = ref.watch(_swotReportProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              title: const Text('SWOT Analysis'),
              pinned: true,
              actions: [
                if (isPremium)
                  _CooldownRefreshButton(
                    cooldownKey: GeminiService.swotCooldownKey,
                    onRefresh: () => ref.invalidate(_swotReportProvider),
                  ),
              ],
            ),

            // ── FREE TIER: show partial SWOT with blur paywall ──────────
            if (!isPremium)
              swotAsync.when(
                loading: () => SliverFillRemaining(child: _LoadingAI(isDark: isDark)),
                error: (_, __) => SliverFillRemaining(child: _PremiumGate(isDark: isDark)),
                data: (cached) {
                  if (cached.data == null) {
                    return SliverFillRemaining(child: _PremiumGate(isDark: isDark));
                  }
                  // Show strengths section free + blur the rest
                  return SliverFillRemaining(
                    child: _FreeTierSWOTPreview(
                      report: cached.data!,
                      isDark: isDark,
                    ),
                  );
                },
              )
            // ── PREMIUM: full report ──────────────────────────────────────
            else
              swotAsync.when(
                loading: () => SliverFillRemaining(child: _LoadingAI(isDark: isDark)),
                error: (e, _) => SliverFillRemaining(child: _AIError(error: e.toString(), isDark: isDark)),
                data: (cached) {
                  if (cached.data == null) {
                    return SliverFillRemaining(child: _PremiumGate(isDark: isDark));
                  }
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      if (cached.isFromCache)
                        _CacheBanner(cacheAge: cached.cacheAge),
                      _SWOTContentWidget(report: cached.data!, isDark: isDark),
                    ]),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Free-tier SWOT Preview — shows Strengths + blurs the rest ───────────────
//
// HIGH #6 fix: "taste-then-pay" model.
// Free users see the Key Insight banner + their Strengths (first 2 items).
// Everything below (Weaknesses, Opportunities, Threats, Recommendations) is
// rendered but blurred with a paywall CTA overlay — giving them proof of value
// before asking them to pay.

class _FreeTierSWOTPreview extends StatelessWidget {
  final SWOTReport report;
  final bool isDark;

  const _FreeTierSWOTPreview({required this.report, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isDark ? DarkColors.primary : LightColors.primary;

    return Stack(
      children: [
        // ── Scrollable content (full report, some parts will be blurred) ──
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            // Free: Key message banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? DarkColors.gradientPrimary
                      : LightColors.gradientPrimary,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text('AI Key Insight',
                          style: theme.textTheme.labelLarge
                              ?.copyWith(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.keyMessage,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Free: Strengths section (first 2 items only)
            _SWOTQuadrant(
              emoji: '💪',
              title: 'Your Strengths',
              items: report.strengths.take(2).toList(),
              color: LightColors.learned,
              isDark: isDark,
            ).animate(delay: 150.ms).fadeIn(),

            const SizedBox(height: 12),

            // Locked: Weaknesses, Opportunities, Threats, Recommendations
            // Rendered blurred so users see content exists.
            _BlurredSection(isDark: isDark),
          ],
        ),

        // ── Paywall overlay pinned at bottom ──────────────────────────────
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (isDark ? DarkColors.background : LightColors.background)
                      .withOpacity(0),
                  (isDark ? DarkColors.background : LightColors.background)
                      .withOpacity(0.97),
                ],
                stops: const [0.0, 0.4],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🔒 Unlock Full SWOT Analysis',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Weaknesses, Opportunities, Threats + personalised Action Plan',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.push(AppRoutes.subscription),
                  child: const Text('Upgrade to Premium — ₹99/month'),
                ),
                const SizedBox(height: 6),
                Text(
                  '7-day free trial • Cancel anytime',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: accent),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A blurred, greyed representation of the locked content sections.
/// Renders enough visual content to prove the data is real —
/// but blurred so the student is motivated to unlock it.
class _BlurredSection extends StatelessWidget {
  final bool isDark;
  const _BlurredSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholders = [
      ('⚠️', 'Weaknesses', LightColors.error, [
        'Limited revision consistency\nLong gaps between review sessions',
        'Subject imbalance detected\nOne subject receiving 3× more hours'
      ]),
      ('🌟', 'Opportunities', LightColors.secondary, [
        'High-weightage chapters untapped\nOptimising could add 20+ marks',
        'Revision efficiency window\nSpaced repetition not yet leveraged'
      ]),
      ('🔴', 'Threats', LightColors.tested, [
        'Backlog accumulation risk\nSlowing pace vs. exam timeline',
        'Test practice deficit\nMock test frequency below target'
      ]),
    ];

    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: IgnorePointer(
        child: Column(
          children: [
            ...placeholders.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.$3.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.$3.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(p.$1, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(p.$2,
                            style: theme.textTheme.labelLarge?.copyWith(
                                color: p.$3, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...p.$4.map((item) {
                      final parts = item.split('\n');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ${parts[0]}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600)),
                            if (parts.length > 1) ...[
                              const SizedBox(height: 3),
                              Text(parts[1],
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(height: 1.4)),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            )),
            // Action plan placeholder
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? DarkColors.surfaceCard : LightColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? DarkColors.outline : LightColors.outline,
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🎯 Action Plan', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  ...[
                    'Next 7 days: Complete all high-weightage pending chapters',
                    'Next 14 days: Schedule 2 full mock tests this fortnight',
                    'Next 30 days: Revision of entire completed syllabus',
                  ].asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                            color: LightColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text('${e.key + 1}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                    color: LightColors.primary)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(e.value,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(height: 1.4)),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Cache banner — shows when report is served offline ─────────────────────
class _CacheBanner extends StatelessWidget {
  final String cacheAge;
  const _CacheBanner({required this.cacheAge});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: LightColors.tested.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LightColors.tested.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 16, color: LightColors.tested),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline — showing cached report from $cacheAge. Tap ↻ to refresh when online.',
              style: const TextStyle(fontSize: 12, color: LightColors.tested),
            ),
          ),
        ],
      ),
    );
  }
}

class _SWOTContentWidget extends StatelessWidget {
  final SWOTReport report;
  final bool isDark;
  const _SWOTContentWidget({required this.report, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isDark ? DarkColors.primary : LightColors.primary;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      sliver: SliverList(
        delegate: SliverChildListDelegate([

          // ── Key Message Banner ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark ? DarkColors.gradientPrimary : LightColors.gradientPrimary,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text('AI Key Insight',
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  report.keyMessage,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

          const SizedBox(height: 16),

          // ── Overall Assessment ──────────────────────────────────────────
          _InfoCard(
            emoji: '📊',
            title: 'Overall Assessment',
            content: report.overallAssessment,
            color: accent,
            isDark: isDark,
          ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),

          const SizedBox(height: 16),

          // ── Score Prediction ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: LightColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: LightColors.secondary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Predicted Score Range',
                          style: theme.textTheme.labelLarge),
                      Text(report.predictedScoreRange,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: LightColors.secondary,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(delay: 150.ms).fadeIn(),

          const SizedBox(height: 24),

          // ── SWOT Grid ───────────────────────────────────────────────────
          Text('SWOT Breakdown', style: theme.textTheme.headlineSmall)
              .animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _SWOTQuadrant(
                  emoji: '💪',
                  title: 'Strengths',
                  items: report.strengths,
                  color: LightColors.learned,
                  isDark: isDark,
                ).animate(delay: 250.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SWOTQuadrant(
                  emoji: '⚠️',
                  title: 'Weaknesses',
                  items: report.weaknesses,
                  color: LightColors.error,
                  isDark: isDark,
                ).animate(delay: 300.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _SWOTQuadrant(
                  emoji: '🌟',
                  title: 'Opportunities',
                  items: report.opportunities,
                  color: LightColors.secondary,
                  isDark: isDark,
                ).animate(delay: 350.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SWOTQuadrant(
                  emoji: '🔴',
                  title: 'Threats',
                  items: report.threats,
                  color: LightColors.tested,
                  isDark: isDark,
                ).animate(delay: 400.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Recommendations ─────────────────────────────────────────────
          Text('Action Plan', style: theme.textTheme.headlineSmall)
              .animate(delay: 450.ms).fadeIn(),
          const SizedBox(height: 14),

          ...report.recommendations.asMap().entries.map((e) {
            final i = e.key;
            final rec = e.value;
            return _RecommendationTile(
              index: i + 1,
              dayRange: rec.dayRange,
              action: rec.action,
              isDark: isDark,
            ).animate(delay: (480 + i * 80).ms).fadeIn().slideX(begin: -0.1);
          }),

          const SizedBox(height: 20),

          // Footer
          Center(
            child: Text(
              '🤖 Generated by Gemini 2.5 Flash • ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ]),
      ),
    );
  }
}

class _SWOTQuadrant extends StatelessWidget {
  final String emoji, title;
  final List<SWOTItem> items;
  final Color color;
  final bool isDark;

  const _SWOTQuadrant({
    required this.emoji,
    required this.title,
    required this.items,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(title,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: color, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ${item.title}',
                        style: theme.textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(item.detail,
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.4)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  final int index;
  final String dayRange, action;
  final bool isDark;

  const _RecommendationTile({
    required this.index,
    required this.dayRange,
    required this.action,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isDark ? DarkColors.primary : LightColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surfaceCard : LightColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? DarkColors.outline : LightColors.outline,
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('$index',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: accent, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dayRange,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: accent, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(action,
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String emoji, title, content;
  final Color color;
  final bool isDark;

  const _InfoCard({
    required this.emoji,
    required this.title,
    required this.content,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surfaceCard : LightColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? DarkColors.outline : LightColors.outline,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 10),
          Text(content,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}

// ─── Pattern Report Screen ────────────────────────────────────────────────────

final _patternReportProvider = FutureProvider<_CachedReport<PatternReport?>>((ref) async {
  final sub = ref.read(subscriptionProvider);
  if (!sub.isPremium) return _CachedReport(data: null, cachedAt: null);

  final planState = ref.read(planProvider);
  final logs = ref.read(studyLogProvider);
  final authState = ref.read(authProvider);
  final prefs = await SharedPreferences.getInstance();

  try {
    final report = await GeminiService.generatePatternAnalysis(
      logs: logs,
      chapters: planState.chapters,
      streakDays: authState.user?.currentStreak ?? 0,
    );
    // Cache on success
    await prefs.setString(_kPatternCacheKey, jsonEncode({
      'most_productive_time': report.mostProductiveTime,
      'study_rhythm': report.studyRhythm,
      'burnout_risk': report.burnoutRisk,
      'burnout_risk_reason': report.burnoutRiskReason,
      'strengths_pattern': report.strengthsPattern,
      'watch_out': report.watchOut,
      'this_week_focus': report.thisWeekFocus,
      'pace_assessment': report.paceAssessment,
      'best_session_length': report.bestSessionLength,
      'motivational_insight': report.motivationalInsight,
    }));
    await prefs.setInt(_kPatternCacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    return _CachedReport(data: report, cachedAt: null);
  } catch (_) {
    // Offline — serve cached report
    final cached = prefs.getString(_kPatternCacheKey);
    final cachedTime = prefs.getInt(_kPatternCacheTimeKey);
    if (cached != null) {
      final report = PatternReport.fromJson(
          jsonDecode(cached) as Map<String, dynamic>);
      return _CachedReport(
        data: report,
        cachedAt: cachedTime != null
            ? DateTime.fromMillisecondsSinceEpoch(cachedTime)
            : null,
      );
    }
    rethrow;
  }
});

class PatternReportScreen extends ConsumerWidget {
  const PatternReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPremium = ref.watch(subscriptionProvider).isPremium;
    final reportAsync = ref.watch(_patternReportProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              title: const Text('Study Pattern Analysis'),
              pinned: true,
              actions: [
                _CooldownRefreshButton(
                  cooldownKey: GeminiService.patternCooldownKey,
                  onRefresh: () => ref.invalidate(_patternReportProvider),
                ),
              ],
            ),

            if (!isPremium)
              SliverFillRemaining(child: _PremiumGate(isDark: isDark))
            else
              reportAsync.when(
                loading: () => SliverFillRemaining(child: _LoadingAI(isDark: isDark)),
                error: (e, _) => SliverFillRemaining(child: _AIError(error: e.toString(), isDark: isDark)),
                data: (cached) {
                  if (cached.data == null) {
                    return SliverFillRemaining(child: _PremiumGate(isDark: isDark));
                  }
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      if (cached.isFromCache)
                        _CacheBanner(cacheAge: cached.cacheAge),
                      _PatternContent(report: cached.data!, isDark: isDark),
                    ]),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PatternContent extends StatelessWidget {
  final PatternReport report;
  final bool isDark;
  const _PatternContent({required this.report, required this.isDark});

  Color get _burnoutColor {
    switch (report.burnoutRisk) {
      case 'high': return LightColors.error;
      case 'medium': return LightColors.tested;
      default: return LightColors.learned;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isDark ? DarkColors.primary : LightColors.primary;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      sliver: SliverList(
        delegate: SliverChildListDelegate([

          // ── Motivational Insight ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [DarkColors.primary, DarkColors.secondary]
                    : [LightColors.primary, LightColors.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✨', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(
                  report.motivationalInsight,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w600, height: 1.4,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

          const SizedBox(height: 20),

          // ── Stats Row ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  emoji: '⏰',
                  label: 'Peak Time',
                  value: report.mostProductiveTime,
                  color: accent,
                  isDark: isDark,
                ).animate(delay: 100.ms).fadeIn(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  emoji: '🧠',
                  label: 'Best Session',
                  value: report.bestSessionLength,
                  color: LightColors.physics,
                  isDark: isDark,
                ).animate(delay: 150.ms).fadeIn(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  emoji: '🔥',
                  label: 'Burnout Risk',
                  value: report.burnoutRisk.toUpperCase(),
                  color: _burnoutColor,
                  isDark: isDark,
                ).animate(delay: 200.ms).fadeIn(),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Rhythm ─────────────────────────────────────────────────────
          _InfoCard(
            emoji: '🎵',
            title: 'Your Study Rhythm',
            content: report.studyRhythm,
            color: accent,
            isDark: isDark,
          ).animate(delay: 250.ms).fadeIn(),

          const SizedBox(height: 16),

          if (report.burnoutRisk != 'low') ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _burnoutColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _burnoutColor.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Burnout Risk: ${report.burnoutRisk.toUpperCase()}',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: _burnoutColor, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(report.burnoutRiskReason,
                            style: theme.textTheme.bodySmall?.copyWith(height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate(delay: 300.ms).fadeIn(),
            const SizedBox(height: 16),
          ],

          // ── Strengths ──────────────────────────────────────────────────
          _BulletSection(
            emoji: '💪', title: 'Your Strengths',
            items: report.strengthsPattern,
            color: LightColors.learned, isDark: isDark,
          ).animate(delay: 350.ms).fadeIn(),
          const SizedBox(height: 16),

          // ── Watch Out ──────────────────────────────────────────────────
          _BulletSection(
            emoji: '⚠️', title: 'Watch Out',
            items: report.watchOut,
            color: LightColors.tested, isDark: isDark,
          ).animate(delay: 400.ms).fadeIn(),
          const SizedBox(height: 16),

          // ── This Week Focus ────────────────────────────────────────────
          _BulletSection(
            emoji: '🎯', title: 'This Week\'s Focus',
            items: report.thisWeekFocus,
            color: accent, isDark: isDark,
          ).animate(delay: 450.ms).fadeIn(),
          const SizedBox(height: 16),

          // ── Pace Assessment ────────────────────────────────────────────
          _InfoCard(
            emoji: '📈',
            title: 'Pace Assessment',
            content: report.paceAssessment,
            color: accent,
            isDark: isDark,
          ).animate(delay: 500.ms).fadeIn(),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji, label, value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(value,
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: color, fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _BulletSection extends StatelessWidget {
  final String emoji, title;
  final List<String> items;
  final Color color;
  final bool isDark;

  const _BulletSection({
    required this.emoji,
    required this.title,
    required this.items,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surfaceCard : LightColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? DarkColors.outline : LightColors.outline,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(title,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6, height: 6,
                      margin: const EdgeInsets.only(top: 6, right: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    ),
                    Expanded(
                      child: Text(item,
                          style: theme.textTheme.bodySmall?.copyWith(height: 1.5)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Shared AI state widgets ──────────────────────────────────────────────────

class _LoadingAI extends StatelessWidget {
  final bool isDark;
  const _LoadingAI({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isDark ? DarkColors.primary : LightColors.primary;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 72, height: 72,
            child: CircularProgressIndicator(
              strokeWidth: 5,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
              strokeCap: StrokeCap.round,
            ),
          ),
          const SizedBox(height: 24),
          const Text('🧠', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text('Gemini AI is analysing your data...',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('This may take 10–15 seconds',
              style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _AIError extends StatelessWidget {
  final String error;
  final bool isDark;
  const _AIError({required this.error, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😵', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('AI analysis failed', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(error, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumGate extends StatelessWidget {
  final bool isDark;
  const _PremiumGate({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isDark ? DarkColors.primary : LightColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark ? DarkColors.gradientPrimary : LightColors.gradientGold,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(child: Text('🔒', style: TextStyle(fontSize: 48))),
            ).animate().scale(
              begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut,
            ),
            const SizedBox(height: 24),
            Text('Premium Feature', style: theme.textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(
              'AI-powered analysis is available on the Premium plan. Upgrade to unlock SWOT Analysis, Pattern Reports, and unlimited revisions.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => context.push(AppRoutes.subscription),
              child: const Text('Upgrade to Premium'),
            ),
            const SizedBox(height: 12),
            Text(
              '7-day free trial • ₹99/month',
              style: theme.textTheme.labelSmall?.copyWith(color: accent),
            ),
          ],
        ),
      ),
    );
  }
}


// ── Cooldown Refresh Button ────────────────────────────────────────────────
// Shows a greyed-out button with remaining cooldown time if < 6h have passed.
// Shows a normal refresh icon when cooldown has expired.
class _CooldownRefreshButton extends ConsumerStatefulWidget {
  final String cooldownKey;
  final VoidCallback onRefresh;

  const _CooldownRefreshButton({
    required this.cooldownKey,
    required this.onRefresh,
  });

  @override
  ConsumerState<_CooldownRefreshButton> createState() =>
      _CooldownRefreshButtonState();
}

class _CooldownRefreshButtonState
    extends ConsumerState<_CooldownRefreshButton> {
  Duration _remaining = Duration.zero;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _checkCooldown();
  }

  Future<void> _checkCooldown() async {
    final rem = await GeminiService.remainingCooldown(widget.cooldownKey);
    if (mounted) setState(() { _remaining = rem; _checked = true; });
  }

  String _fmt(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    return '${d.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) return const SizedBox.shrink();
    final ready = _remaining == Duration.zero;
    return Tooltip(
      message: ready ? 'Refresh AI report' : 'Next refresh in ${_fmt(_remaining)}',
      child: IconButton(
        icon: Icon(
          ready ? Icons.refresh_rounded : Icons.timer_outlined,
          color: ready ? null : Colors.grey,
        ),
        onPressed: ready
            ? () {
                widget.onRefresh();
                _checkCooldown();
              }
            : null,
      ),
    );
  }
}
