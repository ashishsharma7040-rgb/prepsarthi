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

final _swotReportProvider = FutureProvider<SWOTReport?>((ref) async {
  final planState = ref.read(planProvider);
  final logs = ref.read(studyLogProvider);
  final authState = ref.read(authProvider);
  final sub = ref.read(subscriptionProvider);

  if (!sub.isPremium) return null;

  final summary = ref.read(dashboardSummaryProvider);

  return GeminiService.generateSWOT(
    allChapters: planState.chapters,
    last30DaysLogs: logs,
    streakDays: authState.user?.currentStreak ?? 0,
    avgDailyHours: summary.avgDailyHours,
    overallProgress: summary.overallProgress * 100,
    subjectProgress: summary.subjectProgress
        .map((k, v) => MapEntry(k, v * 100)),
  );
});

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
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => ref.invalidate(_swotReportProvider),
                ),
              ],
            ),

            if (!isPremium)
              SliverFillRemaining(child: _PremiumGate(isDark: isDark))
            else
              swotAsync.when(
                loading: () => SliverFillRemaining(child: _LoadingAI(isDark: isDark)),
                error: (e, _) => SliverFillRemaining(child: _AIError(error: e.toString(), isDark: isDark)),
                data: (report) {
                  if (report == null) {
                    return SliverFillRemaining(child: _PremiumGate(isDark: isDark));
                  }
                  return _SWOTContent(report: report, isDark: isDark);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SWOTContent extends StatelessWidget {
  final SWOTReport report;
  final bool isDark;
  const _SWOTContent({required this.report, required this.isDark});

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

final _patternReportProvider = FutureProvider<PatternReport?>((ref) async {
  final sub = ref.read(subscriptionProvider);
  if (!sub.isPremium) return null;

  final planState = ref.read(planProvider);
  final logs = ref.read(studyLogProvider);
  final authState = ref.read(authProvider);

  return GeminiService.generatePatternAnalysis(
    logs: logs,
    chapters: planState.chapters,
    streakDays: authState.user?.currentStreak ?? 0,
  );
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
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => ref.invalidate(_patternReportProvider),
                ),
              ],
            ),

            if (!isPremium)
              SliverFillRemaining(child: _PremiumGate(isDark: isDark))
            else
              reportAsync.when(
                loading: () => SliverFillRemaining(child: _LoadingAI(isDark: isDark)),
                error: (e, _) => SliverFillRemaining(child: _AIError(error: e.toString(), isDark: isDark)),
                data: (report) {
                  if (report == null) {
                    return SliverFillRemaining(child: _PremiumGate(isDark: isDark));
                  }
                  return _PatternContent(report: report, isDark: isDark);
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
