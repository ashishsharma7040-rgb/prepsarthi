// lib/presentation/screens/dashboard/dashboard_widgets.dart
//
// ── §7 ARCHITECTURE fix ───────────────────────────────────────────────────────
// All private widget classes extracted from dashboard_screen.dart (was 1549 lines).
// dashboard_screen.dart is now ~200 lines. This file holds the remaining ~1350.
// Naming: leading underscore removed → public classes used by dashboard_screen.dart.
// Zero import changes needed in the router or any other screen.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/local/isar/schemas/plan_entry_schema.dart';
import '../../../router/app_router.dart';
import '../../providers/all_providers.dart';
import '../../providers/analytics_providers.dart';
import '../../widgets/common/accessibility_widgets.dart';
import '../../widgets/common/gradient_card.dart';
import '../../widgets/common/heatmap_week.dart';
import '../../widgets/common/progress_ring.dart';
import '../../widgets/common/streak_badge.dart';

// ─── Section header ───────────────────────────────────────────────────────────
class DashboardSectionHeader extends StatelessWidget {
  final String title, emoji;
  const DashboardSectionHeader(
      {super.key, required this.title, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // §9: emoji as image so TalkBack skips the raw codepoint
        A11yImage(
          label: '',
          child: Text(emoji, style: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}

// ─── Dashboard header (collapsible SliverAppBar background) ──────────────────
class DashboardHeader extends StatelessWidget {
  final String name;
  final int daysToExam, streak;
  final bool isDark;
  final ExamMode examMode;
  /// For CA Final students: displayed as e.g. "May 2026 Attempt"
  final String? caAttemptLabel;

  const DashboardHeader({
    super.key,
    required this.name,
    required this.daysToExam,
    required this.streak,
    required this.isDark,
    required this.examMode,
    this.caAttemptLabel,
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
    return Semantics(
      label: name.isEmpty
          ? '${_greeting()}. ${daysToExam > 0 ? '$daysToExam days to exam.' : ''} $streak day streak.'
          : '${_greeting()}, $name. ${daysToExam > 0 ? '$daysToExam days to exam.' : ''} $streak day streak.',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name.isEmpty
                              ? _greeting()
                              : '${_greeting()}, $name 👋',
                          style: theme.textTheme.headlineMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (daysToExam > 0)
                          _CountdownChip(
                              days: daysToExam,
                              isDark: isDark,
                              examMode: examMode),
                        // CA Final: always show which attempt is targeted
                        if (caAttemptLabel != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5C6BC0).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF5C6BC0).withOpacity(0.25)),
                            ),
                            child: Text(
                              '⚖️  $caAttemptLabel',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF5C6BC0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  StreakBadge(streak: streak, isDark: isDark),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountdownChip extends StatelessWidget {
  final int days;
  final bool isDark;
  final ExamMode examMode;

  const _CountdownChip(
      {required this.days, required this.isDark, required this.examMode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    if (days <= 30) {
      color = LightColors.error;
    } else if (days <= 90) {
      color = const Color(0xFFFF9800);
    } else {
      color = isDark ? DarkColors.secondary : LightColors.primary;
    }

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
class DashboardQuoteCard extends StatelessWidget {
  final String text, author;
  final bool isDark;
  const DashboardQuoteCard(
      {super.key,
      required this.text,
      required this.author,
      required this.isDark});

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
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic, height: 1.5)),
                const SizedBox(height: 4),
                Text('— $author',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Overdue Revision Banner ───────────────────────────────────────────────────
class OverdueRevisionBanner extends StatelessWidget {
  final int count;
  final bool isDark;
  const OverdueRevisionBanner(
      {super.key, required this.count, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
                  color: LightColors.error, fontWeight: FontWeight.w600),
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: LightColors.error.withOpacity(0.7), size: 18),
        ],
      ),
    );
  }
}

// ─── Today's Mission Banner ────────────────────────────────────────────────────
class TodayMissionBanner extends ConsumerWidget {
  final double todayHours, targetHours;
  final List<PlanEntrySchema> todayEntries;
  final bool isDark;

  const TodayMissionBanner({
    super.key,
    required this.todayHours,
    required this.targetHours,
    required this.todayEntries,
    required this.isDark,
  });

  Color _subjectColor(String s) {
    switch (s) {
      case 'Physics':
        return LightColors.physics;
      case 'Chemistry':
        return LightColors.chemistry;
      case 'Mathematics':
        return LightColors.mathematics;
      default:
        return LightColors.biology;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress =
        targetHours > 0 ? (todayHours / targetHours).clamp(0.0, 1.0) : 0.0;
    final pct = (progress * 100).round();
    final accent = isDark ? DarkColors.primary : LightColors.primary;
    final done = todayHours >= targetHours;

    return Semantics(
      label: done
          ? "Today's target complete! ${todayHours.toStringAsFixed(1)} hours studied."
          : "Today's mission: $pct percent done. ${todayHours.toStringAsFixed(1)} of ${targetHours.toStringAsFixed(0)} hours studied.",
      child: ExcludeSemantics(
        child: Container(
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
              Row(
                children: [
                  Text(done ? '🎉' : '🎯',
                      style: const TextStyle(fontSize: 22)),
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
                            backgroundColor: isDark
                                ? DarkColors.outline
                                : LightColors.outline,
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
              if (todayEntries.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                ...todayEntries.take(4).map((entry) {
                  final subjColor = _subjectColor(entry.subjectName);
                  final isDone =
                      entry.status == 'done' || entry.status == 'completed';
                  return Semantics(
                    label:
                        '${entry.chapterName}, ${entry.subjectName}, ${entry.plannedHours.toStringAsFixed(1)} hours${isDone ? ', completed' : ''}',
                    button: !isDone,
                    child: GestureDetector(
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
                                  shape: BoxShape.circle, color: subjColor),
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
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                if (todayEntries.length > 4)
                  Text('+${todayEntries.length - 4} more chapters',
                      style:
                          theme.textTheme.labelSmall?.copyWith(color: accent)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Readiness Score Card ─────────────────────────────────────────────────────
class ReadinessScoreCard extends StatelessWidget {
  final ReadinessScore readiness;
  final bool isDark;
  const ReadinessScoreCard(
      {super.key, required this.readiness, required this.isDark});

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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(readiness.status,
                        style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 4),
                  Text(readiness.advice,
                      style:
                          theme.textTheme.bodySmall?.copyWith(height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}

// ─── Backlog Alert Banner ──────────────────────────────────────────────────────
class BacklogAlertBanner extends StatelessWidget {
  final BacklogRecoveryPlan backlog;
  final bool isDark;
  const BacklogAlertBanner(
      {super.key, required this.backlog, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    switch (backlog.urgencyLevel) {
      case 'critical':
        color = LightColors.error;
        break;
      case 'high':
        color = const Color(0xFFFF9800);
        break;
      default:
        color = LightColors.tested;
    }
    return Container(
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
                Text('${backlog.totalBacklogChapters} chapters in backlog',
                    style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700, color: color)),
                Text(
                    'Est. ${backlog.estimatedDaysToRecover.toStringAsFixed(0)} days to recover • Tap for recovery plan',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.6)),
        ],
      ),
    );
  }
}

// ─── Exam Mode Banner ─────────────────────────────────────────────────────────
class ExamModeBanner extends StatelessWidget {
  final ExamMode mode;
  final bool isDark;
  const ExamModeBanner({super.key, required this.mode, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    if (mode.daysLeft <= 7) {
      color = LightColors.error;
    } else if (mode.daysLeft <= 30) {
      color = const Color(0xFFFF9800);
    } else {
      color = LightColors.primary;
    }
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
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.w700)),
                    Expanded(
                        child:
                            Text(r, style: theme.textTheme.bodySmall)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Premium Feature Grid ─────────────────────────────────────────────────────
class PremiumFeatureGrid extends StatelessWidget {
  final bool isDark;
  const PremiumFeatureGrid({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('⚠️', 'Weakness\nRadar', AppRoutes.weaknessRadar, LightColors.error,
          'Open Weakness Radar'),
      ('📓', 'Mistake\nNotebook', AppRoutes.mistakeNotebook,
          const Color(0xFF9C27B0), 'Open Mistake Notebook'),
      ('🏅', 'Chapter\nMastery', AppRoutes.chapterMastery, LightColors.primary,
          'Open Chapter Mastery'),
      ('🧪', 'Mock Test\nAnalysis', AppRoutes.testScore, LightColors.tested,
          'Open Mock Test Analysis'),
    ];

    return Row(
      children: items.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        return Expanded(
          child: Padding(
            padding:
                EdgeInsets.only(right: idx < items.length - 1 ? 8 : 0),
            child: Semantics(
              label: item.$5,
              button: true,
              child: GestureDetector(
                onTap: () => context.push(item.$3),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: (item.$4).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: (item.$4).withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      ExcludeSemantics(
                          child: Text(item.$1,
                              style: const TextStyle(fontSize: 22))),
                      const SizedBox(height: 6),
                      Text(
                        item.$2,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: item.$4),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Overall Progress Section ─────────────────────────────────────────────────
class OverallProgressSection extends StatelessWidget {
  final dynamic summary;
  final bool isDark;
  const OverallProgressSection(
      {super.key, required this.summary, required this.isDark});

  Color _subjectColor(String s) {
    switch (s) {
      case 'Physics':
        return isDark ? DarkColors.physics : LightColors.physics;
      case 'Chemistry':
        return isDark ? DarkColors.chemistry : LightColors.chemistry;
      case 'Mathematics':
        return isDark ? DarkColors.mathematics : LightColors.mathematics;
      default:
        return isDark ? DarkColors.biology : LightColors.biology;
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
          A11yProgressRing(
            value: summary.overallProgress as double,
            label: 'Overall syllabus progress',
            child: ProgressRing(
              progress: summary.overallProgress as double,
              size: 96,
              strokeWidth: 9,
              primaryColor: accent,
              backgroundColor:
                  isDark ? DarkColors.outline : LightColors.outline,
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
                Text(
                    '${summary.completedChapters}/${summary.totalChapters} chapters done',
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: 10),
                ...summary.subjectProgress.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 62,
                            child: Text(
                              e.key.length > 7
                                  ? '${e.key.substring(0, 7)}.'
                                  : e.key,
                              style: theme.textTheme.labelSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: A11yProgressBar(
                              value: e.value as double,
                              label: '${e.key} progress',
                              color: _subjectColor(e.key as String),
                              backgroundColor: isDark
                                  ? DarkColors.outline
                                  : LightColors.outline,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${(e.value * 100).round()}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: _subjectColor(e.key as String),
                                fontWeight: FontWeight.w600),
                          ),
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

// ─── Empty Progress Card ──────────────────────────────────────────────────────
class EmptyProgressCard extends StatelessWidget {
  final bool isDark;
  const EmptyProgressCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientCard(
      isDark: isDark,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('📚', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text('No study plan yet',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Complete onboarding to generate your personalised syllabus plan.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Today's Focus Card ───────────────────────────────────────────────────────
class TodayFocusCard extends ConsumerWidget {
  final List<dynamic> entries;
  final bool isDark;
  const TodayFocusCard(
      {super.key, required this.entries, required this.isDark});

  Color _subjectColor(String s) {
    switch (s) {
      case 'Physics':
        return LightColors.physics;
      case 'Chemistry':
        return LightColors.chemistry;
      case 'Mathematics':
        return LightColors.mathematics;
      default:
        return LightColors.biology;
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

            return Semantics(
              label:
                  '${entry.chapterName}, ${entry.subjectName}, ${entry.plannedHours}h${isDone ? ', done' : ''}',
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 52,
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
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(entry.subjectName as String,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(color: color)),
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
                        Semantics(
                          label: 'Mark ${entry.chapterName} as done',
                          button: true,
                          child: GestureDetector(
                            onTap: () async {
                              await ref
                                  .read(planProvider.notifier)
                                  .markPlanEntryStatus(
                                      entry.id as int,
                                      'completed',
                                      entry.plannedHours as double);
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: isDark
                                        ? DarkColors.outline
                                        : LightColors.outline,
                                    width: 2),
                              ),
                            ),
                          ),
                        )
                      else
                        const Icon(Icons.check_circle,
                            color: LightColors.learned, size: 26),
                    ],
                  ),
                  if (!isLast)
                    Divider(
                        height: 18,
                        color: isDark
                            ? DarkColors.outline
                            : LightColors.outline),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.log),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Log Study Session'),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40)),
          ),
        ],
      ),
    );
  }
}

// ─── Empty Today Card ─────────────────────────────────────────────────────────
class EmptyTodayCard extends StatelessWidget {
  final bool isDark;
  const EmptyTodayCard({super.key, required this.isDark});

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
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
              'Your plan may not have been generated yet, or today is a buffer day.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.log),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40)),
            child: const Text('Log a session manually'),
          ),
        ],
      ),
    );
  }
}

// ─── Live Heatmap ─────────────────────────────────────────────────────────────
class DashboardLiveHeatmap extends ConsumerWidget {
  final bool isDark;
  const DashboardLiveHeatmap({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekData =
        ref.read(studyLogProvider.notifier).weekHeatmapData();
    return Semantics(
      label: 'Weekly study heatmap',
      child: HeatmapWeekWidget(isDark: isDark, weekData: weekData),
    );
  }
}

// ─── AI Buttons ───────────────────────────────────────────────────────────────
class DashboardAIButton extends StatelessWidget {
  final String label, icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const DashboardAIButton({
    super.key,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: gradient.first.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
                right: -8,
                top: -8,
                child: Text(icon,
                    style: const TextStyle(
                        fontSize: 56, color: Colors.white10))),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 22)),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
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

// ─── Quick Actions Row ────────────────────────────────────────────────────────
class DashboardQuickActionsRow extends ConsumerWidget {
  const DashboardQuickActionsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetExam = ref.watch(authProvider).user?.targetExam;
    final isCaFinal = targetExam == 'ca_final';

    final actions = [
      ('🍅', 'Pomodoro',   AppRoutes.pomodoro),
      ('🔄', 'Revision',   AppRoutes.revision),
      ('📊', 'Test Scores', AppRoutes.testScore),
      // CA Final gets dedicated papers + AI insights; others get PYQ Papers
      if (isCaFinal) ...const [
        ('📄', 'CA Papers', AppRoutes.pastPapers),
        ('🎯', 'AI Insights', AppRoutes.caInsights),
      ] else ...[
        ('📄', 'PYQ Papers', AppRoutes.pastPapers),
        ('📤', 'Export PDF', AppRoutes.export),
      ],
    ];
    return Row(
      children: actions.asMap().entries.map((e) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  right: e.key < actions.length - 1 ? 6 : 0),
              child: _QuickTile(
                  emoji: e.value.$1,
                  label: e.value.$2,
                  route: e.value.$3),
            ),
          )).toList(),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final String emoji, label, route;
  const _QuickTile(
      {required this.emoji, required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Semantics(
      label: 'Open $label',
      button: true,
      child: GestureDetector(
        onTap: () => context.push(route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? DarkColors.surfaceVariant
                : LightColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isDark ? DarkColors.outline : LightColors.outline,
                width: 0.5),
          ),
          child: Column(
            children: [
              ExcludeSemantics(
                  child:
                      Text(emoji, style: const TextStyle(fontSize: 22))),
              const SizedBox(height: 4),
              Text(label,
                  style: theme.textTheme.labelSmall,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Recent Activity List ─────────────────────────────────────────────────────
class RecentActivityList extends StatelessWidget {
  final List<dynamic> logs;
  final bool isDark;
  const RecentActivityList(
      {super.key, required this.logs, required this.isDark});

  (String, Color) _tagInfo(String tag) {
    switch (tag) {
      case 'learned':
        return ('✅', LightColors.learned);
      case 'revised':
        return ('🔄', LightColors.revised);
      case 'tested':
        return ('🧪', LightColors.tested);
      case 'pyq':
        return ('📝', LightColors.pyqDone);
      case 'notes':
        return ('📒', LightColors.notesMade);
      default:
        return ('📚', LightColors.primary);
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
          final (tagEmoji, tagColor) =
              _tagInfo(log.activityTag as String);
          final timeAgo = _timeAgo(log.timestamp as DateTime);

          return Semantics(
            label:
                '${log.chapterName}, ${log.subjectName}, ${(log.hoursStudied as double).toStringAsFixed(1)} hours, ${log.activityTag}, $timeAgo',
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 2),
                  leading: ExcludeSemantics(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: tagColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: Text(tagEmoji,
                              style: const TextStyle(fontSize: 18))),
                    ),
                  ),
                  title: Text(log.chapterName as String,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                      '${log.subjectName}  •  ${(log.hoursStudied as double).toStringAsFixed(1)}h',
                      style: theme.textTheme.bodySmall),
                  trailing: Text(timeAgo,
                      style: theme.textTheme.labelSmall),
                ),
                if (!isLast)
                  Divider(
                      height: 1,
                      indent: 68,
                      color: isDark
                          ? DarkColors.outline
                          : LightColors.outline),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Empty Recent Activity ────────────────────────────────────────────────────
class EmptyRecentActivity extends StatelessWidget {
  final bool isDark;
  const EmptyRecentActivity({super.key, required this.isDark});

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
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Tap "Log Now" to record your first session.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Study Hours Chart (14-day) ───────────────────────────────────────────────
class StudyHoursChart extends StatelessWidget {
  final List<dynamic> logs;
  final double targetHours;
  final bool isDark;
  const StudyHoursChart({
    super.key,
    required this.logs,
    required this.targetHours,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final days = List.generate(
        14, (i) => now.subtract(Duration(days: 13 - i)));

    final hoursPerDay = days.map((d) {
      final start = DateTime(d.year, d.month, d.day);
      final end = start.add(const Duration(days: 1));
      return logs
          .where((l) {
            final t = l.timestamp as DateTime;
            return t.isAfter(start) && t.isBefore(end);
          })
          .fold<double>(0, (s, l) => s + (l.hoursStudied as double));
    }).toList();

    final maxY = ([...hoursPerDay, targetHours + 1])
        .reduce((a, b) => a > b ? a : b);

    final spots = hoursPerDay
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final accent = isDark ? DarkColors.primary : LightColors.primary;

    return GradientCard(
      isDark: isDark,
      padding: const EdgeInsets.fromLTRB(12, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '14-day study hours',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                  width: 20,
                  height: 3,
                  decoration: BoxDecoration(
                      color: LightColors.learned,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              Text('target', style: theme.textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY.clamp(targetHours + 0.5, 12),
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: targetHours > 0 ? targetHours : 2,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: (isDark
                            ? DarkColors.outline
                            : LightColors.outline)
                        .withOpacity(0.6),
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 7,
                      getTitlesWidget: (v, meta) {
                        if (v == 0) {
                          return Text('14d ago',
                              style: theme.textTheme.labelSmall);
                        }
                        if (v == 13) {
                          return Text('Today',
                              style: theme.textTheme.labelSmall);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: targetHours,
                      color: LightColors.learned.withOpacity(0.6),
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: accent,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, __, ___, ____) {
                        final aboveTarget = spot.y >= targetHours;
                        return FlDotCirclePainter(
                          radius: 3,
                          color: aboveTarget
                              ? LightColors.learned
                              : accent,
                          strokeWidth: 0,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          accent.withOpacity(0.18),
                          accent.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
