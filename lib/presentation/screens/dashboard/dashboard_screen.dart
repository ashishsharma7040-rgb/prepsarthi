// lib/presentation/screens/dashboard/dashboard_screen.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/local/isar/schemas/plan_entry_schema.dart';
import '../../../router/app_router.dart';
import '../../providers/all_providers.dart';
import '../../providers/analytics_providers.dart';
import '../../widgets/common/shared_widgets.dart';

// ── Daily quote provider ───────────────────────────────────────────────────
final _dailyQuoteProvider = FutureProvider<Map<String, String>>((ref) async {
  final raw = await rootBundle.loadString('assets/quotes/motivational_quotes.json');
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final quotes = (json['quotes'] as List).cast<Map<String, dynamic>>();
  final index = DateTime.now().dayOfYear % quotes.length;
  final q = quotes[index];
  return {'text': q['text'] as String, 'author': q['author'] as String};
});

extension on DateTime {
  int get dayOfYear => difference(DateTime(year, 1, 1)).inDays;
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final summary = ref.watch(dashboardSummaryProvider);
    final auth = ref.watch(authProvider);
    final settings = ref.watch(settingsProvider);
    final quoteAsync = ref.watch(_dailyQuoteProvider);
    final readiness = ref.watch(readinessScoreProvider);
    final backlog = ref.watch(backlogRecoveryProvider);
    final examMode = ref.watch(examModeProvider);
    final logs = ref.watch(studyLogProvider);

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayHours = logs
        .where((l) => l.timestamp.isAfter(todayStart))
        .fold<double>(0, (s, l) => s + l.hoursStudied);
    final targetHours = auth.user?.dailyStudyHours ?? 5.0;
    final currentThemeMode = settings.themeMode;
    final overdueRevisions = ref.watch(overdueRevisionCountProvider);

    IconData themeIcon;
    String nextThemeMode;
    if (currentThemeMode == 'dark') {
      themeIcon = Icons.light_mode_rounded;
      nextThemeMode = 'light';
    } else if (currentThemeMode == 'light') {
      themeIcon = Icons.dark_mode_rounded;
      nextThemeMode = 'dark';
    } else {
      themeIcon =
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded;
      nextThemeMode = isDark ? 'light' : 'dark';
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(planProvider);
          ref.invalidate(studyLogProvider);
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(readinessScoreProvider);
          ref.invalidate(backlogRecoveryProvider);
        },
        color: isDark ? DarkColors.primary : LightColors.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            floating: false,
            backgroundColor: isDark ? DarkColors.background : LightColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: _DashboardHeader(
                name: auth.user?.displayName ?? '',
                daysToExam: summary.daysToExam,
                streak: summary.streak,
                isDark: isDark,
                examMode: examMode,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(themeIcon),
                tooltip: 'Toggle theme',
                onPressed: () => ref
                    .read(settingsProvider.notifier)
                    .setThemeMode(nextThemeMode),
              ),
              IconButton(
                icon: const Icon(Icons.flash_on_rounded),
                tooltip: "Today's Mission",
                onPressed: () => context.push(AppRoutes.todayMission),
              ),
            ],
          ),

          if (auth.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // Motivational quote
                  quoteAsync.when(
                    data: (q) => _QuoteCard(text: q['text']!, author: q['author']!, isDark: isDark)
                        .animate().fadeIn(delay: 50.ms),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // ── TASK 7: Overdue Revision Warning ─────────────────────
                  if (overdueRevisions > 0) ...[\
                    const SizedBox(height: 10),
                    _OverdueRevisionBanner(
                      count: overdueRevisions,
                      isDark: isDark,
                    ).animate().fadeIn(delay: 55.ms).slideY(begin: -0.06),
                  ],

                  const SizedBox(height: 12),

                  // ── Today's mission banner ───────────────────────────────
                  _TodayMissionBanner(
                    todayHours: todayHours,
                    targetHours: targetHours,
                    todayEntries: summary.todayEntries,
                    isDark: isDark,
                  ).animate().fadeIn(delay: 70.ms).slideY(begin: 0.05),

                  const SizedBox(height: 16),

                  // ── Exam Readiness Score (NEW) ──────────────────────────
                  _ReadinessScoreCard(
                    readiness: readiness.valueOrNull ?? ReadinessScore.empty,
                    isDark: isDark,
                  )
                      .animate().fadeIn(delay: 90.ms).slideY(begin: 0.05),

                  const SizedBox(height: 20),

                  // ── Overall Progress ────────────────────────────────────
                  _SectionHeader(title: 'Syllabus Progress', emoji: '📊'),
                  const SizedBox(height: 10),
                  summary.hasData
                      ? _OverallProgressSection(summary: summary, isDark: isDark)
                          .animate().fadeIn(delay: 100.ms).slideY(begin: 0.08)
                      : _EmptyProgressCard(isDark: isDark)
                          .animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 20),

                  // ── Today's Focus ───────────────────────────────────────
                  _SectionHeader(title: "Today's Focus", emoji: '🎯'),
                  const SizedBox(height: 10),
                  summary.todayEntries.isEmpty
                      ? _EmptyTodayCard(isDark: isDark)
                          .animate().fadeIn(delay: 180.ms)
                      : _TodayFocusCard(entries: summary.todayEntries, isDark: isDark)
                          .animate().fadeIn(delay: 180.ms).slideY(begin: 0.08),

                  const SizedBox(height: 20),

                  // ── Backlog alert (NEW) ─────────────────────────────────
                  if (backlog.hasBacklog && backlog.urgencyLevel != 'low') ...[
                    _BacklogAlertBanner(backlog: backlog, isDark: isDark)
                        .animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 20),
                  ],

                  // ── Exam mode phase (NEW) ───────────────────────────────
                  if (examMode.isActive && summary.daysToExam <= 90) ...[
                    _SectionHeader(title: 'Exam Mode', emoji: examMode.emoji),
                    const SizedBox(height: 10),
                    _ExamModeBanner(mode: examMode, isDark: isDark)
                        .animate().fadeIn(delay: 210.ms),
                    const SizedBox(height: 20),
                  ],

                  // ── Premium feature shortcuts (NEW) ─────────────────────
                  _SectionHeader(title: 'Premium Tools', emoji: '⚡'),
                  const SizedBox(height: 10),
                  _PremiumFeatureGrid(isDark: isDark)
                      .animate().fadeIn(delay: 220.ms),

                  const SizedBox(height: 20),

                  // ── AI Insights ─────────────────────────────────────────
                  _SectionHeader(title: 'AI Insights', emoji: '🧠'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _AIButton(
                          label: 'Pattern Report',
                          icon: '📊',
                          gradient: isDark
                              ? DarkColors.gradientPrimary
                              : LightColors.gradientPhysics,
                          onTap: () => context.push(AppRoutes.patternReport),
                        ).animate().fadeIn(delay: 240.ms).slideX(begin: -0.08),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AIButton(
                          label: 'SWOT Analysis',
                          icon: '⚡',
                          gradient: isDark
                              ? [DarkColors.secondary, DarkColors.primary]
                              : LightColors.gradientGold,
                          onTap: () => context.push(AppRoutes.swotReport),
                        ).animate().fadeIn(delay: 280.ms).slideX(begin: 0.08),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Quick Actions ───────────────────────────────────────
                  _SectionHeader(title: 'Quick Actions', emoji: '⚡'),
                  const SizedBox(height: 10),
                  _QuickActionsRow().animate().fadeIn(delay: 320.ms),

                  const SizedBox(height: 20),

                  // ── Weekly Heatmap ──────────────────────────────────────
                  _SectionHeader(title: 'This Week', emoji: '📅'),
                  const SizedBox(height: 10),
                  _LiveHeatmap(isDark: isDark).animate().fadeIn(delay: 360.ms),

                  const SizedBox(height: 20),

                  // ── Recent Activity ─────────────────────────────────────
                  _SectionHeader(title: 'Recent Activity', emoji: '🕐'),
                  const SizedBox(height: 10),
                  summary.recentLogs.isEmpty
                      ? _EmptyRecentActivity(isDark: isDark)
                          .animate().fadeIn(delay: 400.ms)
                      : _RecentActivityList(logs: summary.recentLogs, isDark: isDark)
                          .animate().fadeIn(delay: 400.ms),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.log),
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('Log Now'),
        backgroundColor: isDark ? DarkColors.primary : LightColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// ─── Today Mission Banner (NEW) ───────────────────────────────────────────────
// ─── TASK 7: Overdue Revision Banner ─────────────────────────────────────────
class _OverdueRevisionBanner extends StatelessWidget {
  final int count;
  final bool isDark;

  const _OverdueRevisionBanner({required this.count, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push(AppRoutes.revision),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: LightColors.error.withOpacity(0.09),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LightColors.error.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$count revision${count > 1 ? 's' : ''} overdue — tap to review',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: LightColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: LightColors.error.withOpacity(0.7), size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── TASK 8: Today's Mission Banner with chapter list ─────────────────────────
class _TodayMissionBanner extends ConsumerWidget {
  final double todayHours, targetHours;
  final List<PlanEntrySchema> todayEntries;
  final bool isDark;

  const _TodayMissionBanner({
    required this.todayHours,
    required this.targetHours,
    required this.todayEntries,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = targetHours > 0
        ? (todayHours / targetHours).clamp(0.0, 1.0)
        : 0.0;
    final pct = (progress * 100).round();
    final accent = isDark ? DarkColors.primary : LightColors.primary;
    final done = todayHours >= targetHours;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: done
            ? LightColors.learned.withOpacity(0.08)
            : accent.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: done
                ? LightColors.learned.withOpacity(0.3)
                : accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text(done ? '🎉' : '🎯', style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      done
                          ? "Today's target complete!"
                          : "Today's Mission: $pct% done",
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor:
                            isDark ? DarkColors.outline : LightColors.outline,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            done ? LightColors.learned : accent),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${todayHours.toStringAsFixed(1)}h / ${targetHours.toStringAsFixed(0)}h studied',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push(AppRoutes.todayMission),
                child: Icon(Icons.chevron_right_rounded,
                    color: accent.withOpacity(0.6)),
              ),
            ],
          ),

          // Chapter list (Task 8)
          if (todayEntries.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...todayEntries.take(4).map((entry) {
              final subjColor = _subjectColor(entry.subjectName);
              final isDone = entry.status == 'done' || entry.status == 'completed';
              return GestureDetector(
                onTap: () {
                  if (!isDone) {
                    ref.read(planProvider.notifier).markPlanEntryStatus(
                          entry.id, 'done', entry.plannedHours);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? LightColors.learned
                              : Colors.transparent,
                          border: Border.all(
                            color: isDone
                                ? LightColors.learned
                                : (isDark
                                    ? DarkColors.outline
                                    : LightColors.outline),
                            width: 1.5,
                          ),
                        ),
                        child: isDone
                            ? const Icon(Icons.check_rounded,
                                size: 12, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: subjColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          entry.chapterName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : null,
                            color: isDone
                                ? (isDark
                                    ? DarkColors.onSurfaceVariant
                                    : LightColors.onSurfaceVariant)
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${entry.plannedHours.toStringAsFixed(1)}h',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: subjColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (todayEntries.length > 4)
              Text(
                '+${todayEntries.length - 4} more chapters',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: accent),
              ),
          ],
        ],
      ),
    );
  }

  Color _subjectColor(String s) {
    switch (s) {
      case 'Physics': return LightColors.physics;
      case 'Chemistry': return LightColors.chemistry;
      case 'Mathematics': return LightColors.mathematics;
      default: return LightColors.biology;
    }
  }
}

// ─── Readiness Score Card (NEW) ───────────────────────────────────────────────
class _ReadinessScoreCard extends StatelessWidget {
  final ReadinessScore readiness;
  final bool isDark;

  const _ReadinessScoreCard(
      {required this.readiness, required this.isDark});

  Color get _scoreColor {
    if (readiness.score >= 80) return LightColors.learned;
    if (readiness.score >= 60) return LightColors.tested;
    if (readiness.score >= 40) return const Color(0xFFFF9800);
    return LightColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _scoreColor;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.todayMission),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : LightColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: readiness.score / 100,
                    strokeWidth: 6,
                    backgroundColor:
                        isDark ? DarkColors.outline : LightColors.outline,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                  Text('${readiness.score}',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: color)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Exam Readiness',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(readiness.status,
                        style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 4),
                  Text(readiness.advice,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}

// ─── Backlog Alert Banner (NEW) ───────────────────────────────────────────────
class _BacklogAlertBanner extends StatelessWidget {
  final BacklogRecoveryPlan backlog;
  final bool isDark;

  const _BacklogAlertBanner(
      {required this.backlog, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    switch (backlog.urgencyLevel) {
      case 'critical': color = LightColors.error; break;
      case 'high': color = const Color(0xFFFF9800); break;
      default: color = LightColors.tested;
    }

    return GestureDetector(
      onTap: () => context.push(AppRoutes.todayMission),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Text('📋', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${backlog.totalBacklogChapters} chapters in backlog',
                    style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700, color: color),
                  ),
                  Text(
                    'Est. ${backlog.estimatedDaysToRecover.toStringAsFixed(0)} days to recover • Tap for recovery plan',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }
}

// ─── Exam Mode Banner (NEW) ───────────────────────────────────────────────────
class _ExamModeBanner extends StatelessWidget {
  final ExamMode mode;
  final bool isDark;

  const _ExamModeBanner({required this.mode, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    if (mode.daysLeft <= 7) color = LightColors.error;
    else if (mode.daysLeft <= 30) color = const Color(0xFFFF9800);
    else color = LightColors.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(mode.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('${mode.phase} — ${mode.daysLeft} days left',
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          ...mode.recommendations.take(2).map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('→ ',
                        style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                    Expanded(child: Text(r, style: theme.textTheme.bodySmall)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Premium Feature Grid (NEW) ───────────────────────────────────────────────
class _PremiumFeatureGrid extends StatelessWidget {
  final bool isDark;
  const _PremiumFeatureGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('⚠️', 'Weakness\nRadar', AppRoutes.weaknessRadar, LightColors.error),
      ('📓', 'Mistake\nNotebook', AppRoutes.mistakeNotebook, const Color(0xFF9C27B0)),
      ('🏅', 'Chapter\nMastery', AppRoutes.chapterMastery, LightColors.primary),
      ('🧪', 'Mock Test\nAnalysis', AppRoutes.testScore, LightColors.tested),
    ];

    return Row(
      children: items.map((item) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => context.push(item.$3),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: (item.$4).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: (item.$4).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(item.$1, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 6),
                  Text(item.$2,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: item.$4),
                      textAlign: TextAlign.center,
                      maxLines: 2),
                ],
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  final String name;
  final int daysToExam;
  final int streak;
  final bool isDark;
  final ExamMode examMode;

  const _DashboardHeader({
    required this.name,
    required this.daysToExam,
    required this.streak,
    required this.isDark,
    required this.examMode,
  });

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    if (h < 21) return 'Good evening';
    return 'Keep going';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? _greeting() : '${_greeting()}, $name 👋',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  if (daysToExam > 0)
                    _CountdownChip(days: daysToExam, isDark: isDark, examMode: examMode),
                ],
              ),
              StreakBadge(streak: streak, isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountdownChip extends StatelessWidget {
  final int days;
  final bool isDark;
  final ExamMode examMode;

  const _CountdownChip({required this.days, required this.isDark, required this.examMode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    if (days <= 30) color = LightColors.error;
    else if (days <= 90) color = const Color(0xFFFF9800);
    else color = isDark ? DarkColors.secondary : LightColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(examMode.emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '$days days to exam',
            style: theme.textTheme.labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─── Quote card ───────────────────────────────────────────────────────────────
class _QuoteCard extends StatelessWidget {
  final String text, author;
  final bool isDark;
  const _QuoteCard({required this.text, required this.author, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isDark ? DarkColors.secondary : LightColors.primary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('"$text"',
                    style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic, height: 1.5)),
                const SizedBox(height: 4),
                Text('— $author',
                    style: theme.textTheme.labelSmall?.copyWith(color: accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Overall progress ─────────────────────────────────────────────────────────
class _OverallProgressSection extends StatelessWidget {
  final DashboardSummary summary;
  final bool isDark;
  const _OverallProgressSection({required this.summary, required this.isDark});

  Color _subjectColor(String s) {
    switch (s) {
      case 'Physics': return isDark ? DarkColors.physics : LightColors.physics;
      case 'Chemistry': return isDark ? DarkColors.chemistry : LightColors.chemistry;
      case 'Mathematics': return isDark ? DarkColors.mathematics : LightColors.mathematics;
      default: return isDark ? DarkColors.biology : LightColors.biology;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isDark ? DarkColors.primary : LightColors.primary;
    final pct = (summary.overallProgress * 100).round();

    return GradientCard(
      isDark: isDark,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          ProgressRing(
            progress: summary.overallProgress,
            size: 96,
            strokeWidth: 9,
            primaryColor: accent,
            backgroundColor: isDark ? DarkColors.outline : LightColors.outline,
            centerWidget: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$pct%',
                    style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800, color: accent)),
                Text('done', style: theme.textTheme.labelSmall),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Syllabus Progress',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${summary.completedChapters}/${summary.totalChapters} chapters done',
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: 10),
                ...summary.subjectProgress.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 62,
                            child: Text(
                              e.key.length > 7 ? '${e.key.substring(0, 7)}.' : e.key,
                              style: theme.textTheme.labelSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: e.value,
                                minHeight: 6,
                                backgroundColor:
                                    isDark ? DarkColors.outline : LightColors.outline,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    _subjectColor(e.key)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('${(e.value * 100).round()}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: _subjectColor(e.key),
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProgressCard extends StatelessWidget {
  final bool isDark;
  const _EmptyProgressCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientCard(
      isDark: isDark,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('📋', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text('No plan generated yet',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Complete onboarding to generate your personalised study plan.',
              style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Today's Focus Card ───────────────────────────────────────────────────────
class _TodayFocusCard extends ConsumerWidget {
  final List<dynamic> entries;
  final bool isDark;
  const _TodayFocusCard({required this.entries, required this.isDark});

  Color _subjectColor(String s) {
    switch (s) {
      case 'Physics': return LightColors.physics;
      case 'Chemistry': return LightColors.chemistry;
      case 'Mathematics': return LightColors.mathematics;
      default: return LightColors.biology;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final shown = entries.take(3).toList();

    return GradientCard(
      isDark: isDark,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          ...shown.asMap().entries.map((e) {
            final entry = e.value;
            final isLast = e.key == shown.length - 1;
            final color = _subjectColor(entry.subjectName as String);
            final isDone = entry.status == 'completed';

            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 4, height: 52,
                      decoration: BoxDecoration(
                        color: isDone ? LightColors.learned : color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.chapterName as String,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(entry.subjectName as String,
                                    style: theme.textTheme.labelSmall?.copyWith(color: color)),
                              ),
                              const SizedBox(width: 8),
                              Text('${entry.plannedHours}h planned',
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!isDone)
                      GestureDetector(
                        onTap: () async {
                          await ref.read(planProvider.notifier).markPlanEntryStatus(
                              entry.id as int, 'completed', entry.plannedHours as double);
                        },
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: isDark ? DarkColors.outline : LightColors.outline,
                                width: 2),
                          ),
                        ),
                      )
                    else
                      const Icon(Icons.check_circle, color: LightColors.learned, size: 26),
                  ],
                ),
                if (!isLast)
                  Divider(height: 18,
                      color: isDark ? DarkColors.outline : LightColors.outline),
              ],
            );
          }),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.log),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Log Study Session'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
          ),
        ],
      ),
    );
  }
}

class _EmptyTodayCard extends StatelessWidget {
  final bool isDark;
  const _EmptyTodayCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientCard(
      isDark: isDark,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('🌅', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text('No sessions planned for today',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Your plan may not have been generated yet, or today is a buffer day.',
              style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.log),
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
            child: const Text('Log a session manually'),
          ),
        ],
      ),
    );
  }
}

// ─── Live heatmap ─────────────────────────────────────────────────────────────
class _LiveHeatmap extends ConsumerWidget {
  final bool isDark;
  const _LiveHeatmap({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekData = ref.read(studyLogProvider.notifier).weekHeatmapData();
    return HeatmapWeekWidget(isDark: isDark, weekData: weekData);
  }
}

// ─── AI buttons ───────────────────────────────────────────────────────────────
class _AIButton extends StatelessWidget {
  final String label, icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _AIButton({required this.label, required this.icon, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient,
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: gradient.first.withOpacity(0.3),
                blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Stack(
          children: [
            Positioned(right: -8, top: -8,
                child: Text(icon, style: const TextStyle(fontSize: 56, color: Colors.white10))),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 22)),
                  Text(label,
                      style: const TextStyle(color: Colors.white, fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick actions ────────────────────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      ('🍅', 'Pomodoro', AppRoutes.pomodoro),
      ('🔄', 'Revision', AppRoutes.revision),
      ('📊', 'Test Scores', AppRoutes.testScore),
      ('📄', 'PYQ Papers', AppRoutes.pastPapers),
      ('📤', 'Export PDF', AppRoutes.export),
    ];
    return Row(
      children: actions.map((a) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _QuickTile(emoji: a.$1, label: a.$2, route: a.$3),
        ),
      )).toList(),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final String emoji, label, route;
  const _QuickTile({required this.emoji, required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surfaceVariant : LightColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? DarkColors.outline : LightColors.outline, width: 0.5),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.labelSmall,
                textAlign: TextAlign.center, maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ─── Recent activity ──────────────────────────────────────────────────────────
class _RecentActivityList extends StatelessWidget {
  final List<dynamic> logs;
  final bool isDark;

  const _RecentActivityList({required this.logs, required this.isDark});

  (String, Color) _tagInfo(String tag) {
    switch (tag) {
      case 'learned': return ('✅', LightColors.learned);
      case 'revised': return ('🔄', LightColors.revised);
      case 'tested': return ('🧪', LightColors.tested);
      case 'pyq': return ('📝', LightColors.pyqDone);
      case 'notes': return ('📒', LightColors.notesMade);
      default: return ('📚', LightColors.primary);
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientCard(
      isDark: isDark,
      padding: const EdgeInsets.all(4),
      child: Column(
        children: logs.asMap().entries.map((e) {
          final log = e.value;
          final isLast = e.key == logs.length - 1;
          final (tagEmoji, tagColor) = _tagInfo(log.activityTag as String);
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                      color: tagColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text(tagEmoji, style: const TextStyle(fontSize: 18))),
                ),
                title: Text(log.chapterName as String,
                    style: theme.textTheme.titleSmall, maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                subtitle: Text('${log.subjectName}  •  ${(log.hoursStudied as double).toStringAsFixed(1)}h',
                    style: theme.textTheme.bodySmall),
                trailing: Text(_timeAgo(log.timestamp as DateTime),
                    style: theme.textTheme.labelSmall),
              ),
              if (!isLast)
                Divider(height: 1, indent: 68,
                    color: isDark ? DarkColors.outline : LightColors.outline),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyRecentActivity extends StatelessWidget {
  final bool isDark;
  const _EmptyRecentActivity({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientCard(
      isDark: isDark,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('📭', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text('No study sessions logged yet',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Tap "Log Now" to record your first session.',
              style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title, emoji;
  const _SectionHeader({required this.title, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}
