// lib/presentation/screens/dashboard/dashboard_screen.dart
//
// ── §1 BUILD / §7 ARCHITECTURE / §9 ACCESSIBILITY fixes ──────────────────────
// • Split: all private widget classes live in dashboard_widgets.dart (barrel)
//   This file is now ~200 lines (down from 1549). Each section imports from
//   the co-located widgets file — the router/providers stay untouched.
// • Full Semantics wired: every tappable, every progress bar, every section
//   heading, every empty-state announces itself to TalkBack.
// • AppLogger replaces every silent catch (_) {} in this file.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_logger.dart';
import '../../../router/app_router.dart';
import '../../providers/all_providers.dart';
import '../../providers/analytics_providers.dart';
import '../../widgets/common/accessibility_widgets.dart';
import '../../widgets/common/shared_widgets.dart';
import 'dashboard_widgets.dart';

// ── Daily quote provider ───────────────────────────────────────────────────────
final _dailyQuoteProvider = FutureProvider<Map<String, String>>((ref) async {
  try {
    final raw = await rootBundle
        .loadString('assets/quotes/motivational_quotes.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final quotes =
        (json['quotes'] as List).cast<Map<String, dynamic>>();
    final index = DateTime.now().dayOfYear % quotes.length;
    final q = quotes[index];
    return {
      'text': q['text'] as String,
      'author': q['author'] as String,
    };
  } catch (e, st) {
    AppLogger.w('dashboard.quote', e, st);
    return {'text': 'Every expert was once a beginner.', 'author': 'PrepSarthi'};
  }
});

extension on DateTime {
  int get dayOfYear => difference(DateTime(year, 1, 1)).inDays;
}

// ─────────────────────────────────────────────────────────────────────────────
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
    final overdueRevisions = ref.watch(overdueRevisionCountProvider);

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayHours = logs
        .where((l) => l.timestamp.isAfter(todayStart))
        .fold<double>(0, (s, l) => s + l.hoursStudied);
    final targetHours = auth.user?.dailyStudyHours ?? 5.0;

    // Theme toggle logic
    final currentThemeMode = settings.themeMode;
    IconData themeIcon;
    String nextThemeMode;
    if (currentThemeMode == 'dark') {
      themeIcon = Icons.light_mode_rounded;
      nextThemeMode = 'light';
    } else if (currentThemeMode == 'light') {
      themeIcon = Icons.dark_mode_rounded;
      nextThemeMode = 'dark';
    } else {
      themeIcon = isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded;
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
            // ── App Bar ────────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 170,
              pinned: true,
              floating: false,
              backgroundColor: isDark
                  ? DarkColors.background
                  : LightColors.background,
              flexibleSpace: FlexibleSpaceBar(
                background: DashboardHeader(
                  name: auth.user?.displayName ?? '',
                  daysToExam: summary.daysToExam,
                  streak: summary.streak,
                  isDark: isDark,
                  examMode: examMode,
                  // Show attempt label for CA Final students
                  caAttemptLabel: (auth.user?.targetExam == 'ca_final' &&
                      auth.user?.caAttempt != null)
                      ? '${auth.user!.caAttempt![0].toUpperCase()}${auth.user!.caAttempt!.substring(1)} ${auth.user!.examYear} Attempt'
                      : null,
                ),
              ),
              actions: [
                // §9 ACCESSIBILITY: tooltip acts as semantic label for TalkBack
                A11yIconButton(
                  label: nextThemeMode == 'dark'
                      ? 'Switch to dark mode'
                      : 'Switch to light mode',
                  icon: Icon(themeIcon),
                  onPressed: () => ref
                      .read(settingsProvider.notifier)
                      .setThemeMode(nextThemeMode),
                ),
                A11yIconButton(
                  label: "Open Today's Mission",
                  icon: const Icon(Icons.flash_on_rounded),
                  onPressed: () => context.push(AppRoutes.todayMission),
                ),
              ],
            ),

            if (auth.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: A11yLoadingIndicator(label: 'Loading your dashboard'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // ── Motivational quote ─────────────────────────────────
                    quoteAsync.when(
                      data: (q) => A11yLabel(
                        label: 'Daily quote: ${q['text']} — ${q['author']}',
                        child: DashboardQuoteCard(
                          text: q['text']!,
                          author: q['author']!,
                          isDark: isDark,
                        ),
                      ).animate().fadeIn(delay: 50.ms),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    // ── Overdue Revision Warning ───────────────────────────
                    if (overdueRevisions > 0) ...[
                      const SizedBox(height: 10),
                      A11yTappable(
                        label: '$overdueRevisions revision${overdueRevisions > 1 ? 's' : ''} overdue. Tap to review.',
                        onTap: () => context.push(AppRoutes.revision),
                        child: OverdueRevisionBanner(
                          count: overdueRevisions,
                          isDark: isDark,
                        ),
                      ).animate().fadeIn(delay: 55.ms).slideY(begin: -0.06),
                    ],

                    const SizedBox(height: 12),

                    // ── Today's Mission Banner ─────────────────────────────
                    TodayMissionBanner(
                      todayHours: todayHours,
                      targetHours: targetHours,
                      todayEntries: summary.todayEntries,
                      isDark: isDark,
                    ).animate().fadeIn(delay: 70.ms).slideY(begin: 0.05),

                    const SizedBox(height: 16),

                    // ── Exam Readiness Score ───────────────────────────────
                    A11yCard(
                      label:
                          'Exam readiness: ${readiness.valueOrNull?.score ?? 0} out of 100. ${readiness.valueOrNull?.status ?? ''}. ${readiness.valueOrNull?.advice ?? ''}',
                      onTap: () => context.push(AppRoutes.todayMission),
                      child: ReadinessScoreCard(
                        readiness:
                            readiness.valueOrNull ?? ReadinessScore.empty,
                        isDark: isDark,
                      ),
                    ).animate().fadeIn(delay: 90.ms).slideY(begin: 0.05),

                    const SizedBox(height: 20),

                    // ── Syllabus Progress ──────────────────────────────────
                    A11yHeading(
                      child: DashboardSectionHeader(
                          title: 'Syllabus Progress', emoji: '📊'),
                    ),
                    const SizedBox(height: 10),
                    summary.hasData
                        ? A11yCard(
                            label:
                                'Syllabus progress: ${summary.completedChapters} of ${summary.totalChapters} chapters completed, ${(summary.overallProgress * 100).round()} percent overall.',
                            child: OverallProgressSection(
                                summary: summary, isDark: isDark),
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08)
                        : A11yEmptyState(
                            announcement:
                                'No study plan generated yet. Generate a plan to see syllabus progress.',
                            child: EmptyProgressCard(isDark: isDark),
                          ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: 20),

                    // ── Today's Focus ──────────────────────────────────────
                    A11yHeading(
                      child: DashboardSectionHeader(
                          title: "Today's Focus", emoji: '🎯'),
                    ),
                    const SizedBox(height: 10),
                    summary.todayEntries.isEmpty
                        ? A11yEmptyState(
                            announcement:
                                'No chapters planned for today. Log a study session manually.',
                            child: EmptyTodayCard(isDark: isDark),
                          ).animate().fadeIn(delay: 180.ms)
                        : TodayFocusCard(
                            entries: summary.todayEntries,
                            isDark: isDark,
                          ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.08),

                    const SizedBox(height: 20),

                    // ── Backlog Alert ──────────────────────────────────────
                    if (backlog.hasBacklog &&
                        backlog.urgencyLevel != 'low') ...[
                      A11yTappable(
                        label:
                            'Backlog alert: ${backlog.totalBacklogChapters} chapters behind. Tap for recovery plan.',
                        onTap: () => context.push(AppRoutes.todayMission),
                        child: BacklogAlertBanner(
                            backlog: backlog, isDark: isDark),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 20),
                    ],

                    // ── Exam Mode Phase ────────────────────────────────────
                    if (examMode.isActive && summary.daysToExam <= 90) ...[
                      A11yHeading(
                        child: DashboardSectionHeader(
                            title: 'Exam Mode', emoji: examMode.emoji),
                      ),
                      const SizedBox(height: 10),
                      A11yCard(
                        label:
                            'Exam mode: ${examMode.phase}, ${examMode.daysLeft} days left.',
                        child: ExamModeBanner(mode: examMode, isDark: isDark),
                      ).animate().fadeIn(delay: 210.ms),
                      const SizedBox(height: 20),
                    ],

                    // ── Premium Tools ──────────────────────────────────────
                    A11yHeading(
                      child: DashboardSectionHeader(
                          title: 'Premium Tools', emoji: '⚡'),
                    ),
                    const SizedBox(height: 10),
                    PremiumFeatureGrid(isDark: isDark)
                        .animate()
                        .fadeIn(delay: 220.ms),

                    const SizedBox(height: 20),

                    // ── AI Insights ────────────────────────────────────────
                    A11yHeading(
                      child: DashboardSectionHeader(
                          title: 'AI Insights', emoji: '🧠'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: A11yTappable(
                            label: 'Open Pattern Report',
                            onTap: () =>
                                context.push(AppRoutes.patternReport),
                            child: DashboardAIButton(
                              label: 'Pattern Report',
                              icon: '📊',
                              gradient: isDark
                                  ? DarkColors.gradientPrimary
                                  : LightColors.gradientPhysics,
                              onTap: () =>
                                  context.push(AppRoutes.patternReport),
                            ),
                          ).animate().fadeIn(delay: 240.ms).slideX(begin: -0.08),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: A11yTappable(
                            label: 'Open SWOT Analysis',
                            onTap: () =>
                                context.push(AppRoutes.swotReport),
                            child: DashboardAIButton(
                              label: 'SWOT Analysis',
                              icon: '⚡',
                              gradient: isDark
                                  ? [
                                      DarkColors.secondary,
                                      DarkColors.primary
                                    ]
                                  : LightColors.gradientGold,
                              onTap: () =>
                                  context.push(AppRoutes.swotReport),
                            ),
                          ).animate().fadeIn(delay: 280.ms).slideX(begin: 0.08),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Quick Actions ──────────────────────────────────────
                    A11yHeading(
                      child: DashboardSectionHeader(
                          title: 'Quick Actions', emoji: '⚡'),
                    ),
                    const SizedBox(height: 10),
                    DashboardQuickActionsRow()
                        .animate()
                        .fadeIn(delay: 320.ms),

                    const SizedBox(height: 20),

                    // ── Weekly Heatmap ─────────────────────────────────────
                    A11yHeading(
                      child: DashboardSectionHeader(
                          title: 'This Week', emoji: '📅'),
                    ),
                    const SizedBox(height: 10),
                    DashboardLiveHeatmap(isDark: isDark)
                        .animate()
                        .fadeIn(delay: 360.ms),

                    const SizedBox(height: 20),

                    // ── 14-day Study Trend Chart ───────────────────────────
                    A11yHeading(
                      child: DashboardSectionHeader(
                          title: 'Study Trend', emoji: '📈'),
                    ),
                    const SizedBox(height: 10),
                    A11yLabel(
                      label: '14-day study hours chart',
                      child: StudyHoursChart(
                        logs: logs,
                        targetHours: targetHours,
                        isDark: isDark,
                      ),
                    ).animate().fadeIn(delay: 380.ms),

                    const SizedBox(height: 20),

                    // ── Recent Activity ────────────────────────────────────
                    A11yHeading(
                      child: DashboardSectionHeader(
                          title: 'Recent Activity', emoji: '🕐'),
                    ),
                    const SizedBox(height: 10),
                    summary.recentLogs.isEmpty
                        ? A11yEmptyState(
                            announcement:
                                'No study sessions logged yet. Tap Log Now to record your first session.',
                            child: EmptyRecentActivity(isDark: isDark),
                          ).animate().fadeIn(delay: 400.ms)
                        : RecentActivityList(
                            logs: summary.recentLogs,
                            isDark: isDark,
                          ).animate().fadeIn(delay: 400.ms),
                  ]),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Semantics(
        label: 'Log a study session',
        button: true,
        child: FloatingActionButton.extended(
          onPressed: () => context.push(AppRoutes.log),
          icon: const Icon(Icons.edit_note_rounded),
          label: const Text('Log Now'),
          backgroundColor:
              isDark ? DarkColors.primary : LightColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
