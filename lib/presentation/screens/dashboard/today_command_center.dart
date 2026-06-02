// lib/presentation/screens/dashboard/today_command_center.dart
//
// Premium "Today Command Center" widget — the most powerful screen
// students see daily. Shows mission, readiness, exam mode, and backlog.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../router/app_router.dart';
import '../../providers/all_providers.dart';
import '../../providers/analytics_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point: full Today Command Center page
// ─────────────────────────────────────────────────────────────────────────────

class TodayCommandCenterPage extends ConsumerWidget {
  const TodayCommandCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final summary = ref.watch(dashboardSummaryProvider);
    final readiness = ref.watch(readinessScoreProvider);
    final weakness = ref.watch(weaknessRadarProvider);
    final backlog = ref.watch(backlogRecoveryProvider);
    final examMode = ref.watch(examModeProvider);
    final auth = ref.watch(authProvider);
    final logs = ref.watch(studyLogProvider);

    // Compute today's logged hours
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayHours = logs
        .where((l) => l.timestamp.isAfter(todayStart))
        .fold<double>(0, (s, l) => s + l.hoursStudied);

    final targetHours = auth.user?.dailyStudyHours ?? 5.0;
    final remainingHours = (targetHours - todayHours).clamp(0.0, 24.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Today\'s Mission',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
        centerTitle: false,
        actions: [
          if (examMode.isActive && examMode.daysLeft <= 90)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _ExamModeBadge(mode: examMode),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── Mission card ────────────────────────────────────────────────
          _MissionCard(
            targetHours: targetHours,
            completedHours: todayHours,
            remainingHours: remainingHours,
            isDark: isDark,
          ).animate().fadeIn().slideY(begin: 0.05),

          const SizedBox(height: 16),

          // ── Exam readiness ───────────────────────────────────────────────
          _ReadinessCard(
            readiness: readiness.valueOrNull ?? ReadinessScore.empty,
            isDark: isDark,
          )
              .animate().fadeIn(delay: 60.ms).slideY(begin: 0.05),

          const SizedBox(height: 16),

          // ── Exam mode phase ──────────────────────────────────────────────
          if (examMode.isActive)
            _ExamModeCard(mode: examMode, isDark: isDark)
                .animate().fadeIn(delay: 120.ms).slideY(begin: 0.05),

          if (examMode.isActive) const SizedBox(height: 16),

          // ── Today's chapters ─────────────────────────────────────────────
          if (summary.todayEntries.isNotEmpty)
            _TodayChaptersCard(entries: summary.todayEntries, isDark: isDark)
                .animate().fadeIn(delay: 180.ms),

          if (summary.todayEntries.isNotEmpty) const SizedBox(height: 16),

          // ── Weakness alert ────────────────────────────────────────────────
          if (weakness.totalWeakAreas > 0)
            _WeaknessAlert(radar: weakness, isDark: isDark)
                .animate().fadeIn(delay: 240.ms),

          if (weakness.totalWeakAreas > 0) const SizedBox(height: 16),

          // ── Backlog recovery ──────────────────────────────────────────────
          if (backlog.hasBacklog)
            _BacklogCard(plan: backlog, isDark: isDark)
                .animate().fadeIn(delay: 300.ms),

          if (backlog.hasBacklog) const SizedBox(height: 16),

          // ── Quick actions ─────────────────────────────────────────────────
          _CommandActions(isDark: isDark)
              .animate().fadeIn(delay: 360.ms),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mission Card
// ─────────────────────────────────────────────────────────────────────────────

class _MissionCard extends StatelessWidget {
  final double targetHours, completedHours, remainingHours;
  final bool isDark;

  const _MissionCard({
    required this.targetHours,
    required this.completedHours,
    required this.remainingHours,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = targetHours > 0
        ? (completedHours / targetHours).clamp(0.0, 1.0)
        : 0.0;
    final percent = (progress * 100).round();
    final accent = isDark ? DarkColors.primary : LightColors.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [DarkColors.surface, DarkColors.surfaceVariant]
              : [LightColors.primary.withOpacity(0.08), LightColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: accent.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text("Today's Study Mission",
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$percent%',
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: accent, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: isDark ? DarkColors.outline : LightColors.outline,
              valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? LightColors.learned : accent),
            ),
          ),

          const SizedBox(height: 14),

          // Stats row
          Row(
            children: [
              _StatPill(
                  emoji: '✅',
                  label: 'Done',
                  value: '${completedHours.toStringAsFixed(1)}h',
                  color: LightColors.learned),
              const SizedBox(width: 10),
              _StatPill(
                  emoji: '🎯',
                  label: 'Target',
                  value: '${targetHours.toStringAsFixed(0)}h',
                  color: accent),
              const SizedBox(width: 10),
              _StatPill(
                  emoji: '⏳',
                  label: 'Left',
                  value: '${remainingHours.toStringAsFixed(1)}h',
                  color: remainingHours <= 0
                      ? LightColors.learned
                      : LightColors.tested),
            ],
          ),

          if (completedHours >= targetHours) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: LightColors.learned.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('🎉 ', style: TextStyle(fontSize: 16)),
                  Text("Today's target achieved! Great work!",
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: LightColors.learned,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String emoji, label, value;
  final Color color;

  const _StatPill(
      {required this.emoji,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style:
                    const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Readiness Card
// ─────────────────────────────────────────────────────────────────────────────

class _ReadinessCard extends StatelessWidget {
  final ReadinessScore readiness;
  final bool isDark;

  const _ReadinessCard(
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

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Score ring
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: readiness.score / 100,
                  strokeWidth: 7,
                  backgroundColor:
                      isDark ? DarkColors.outline : LightColors.outline,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${readiness.score}',
                        style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: color,
                            fontSize: 22)),
                    Text('/100',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exam Readiness',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(readiness.status,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color)),
                ),
                const SizedBox(height: 6),
                Text(readiness.advice,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Exam Mode Card
// ─────────────────────────────────────────────────────────────────────────────

class _ExamModeCard extends StatelessWidget {
  final ExamMode mode;
  final bool isDark;

  const _ExamModeCard({required this.mode, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color phaseColor;
    if (mode.daysLeft <= 7) {
      phaseColor = LightColors.error;
    } else if (mode.daysLeft <= 30) {
      phaseColor = const Color(0xFFFF9800);
    } else if (mode.daysLeft <= 90) {
      phaseColor = LightColors.primary;
    } else {
      phaseColor = LightColors.learned;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [phaseColor.withOpacity(0.12), phaseColor.withOpacity(0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: phaseColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(mode.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mode.phase,
                        style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800, color: phaseColor)),
                    Text('${mode.daysLeft} days remaining',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...mode.recommendations.take(3).map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('→ ',
                        style: TextStyle(
                            color: phaseColor, fontWeight: FontWeight.w700)),
                    Expanded(
                        child: Text(r,
                            style: theme.textTheme.bodySmall)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Today's Chapters
// ─────────────────────────────────────────────────────────────────────────────

class _TodayChaptersCard extends ConsumerWidget {
  final List<dynamic> entries;
  final bool isDark;

  const _TodayChaptersCard(
      {required this.entries, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final shown = entries.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📚', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text("Today's Chapters",
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ...shown.asMap().entries.map((e) {
            final entry = e.value;
            final isDone = entry.status == 'completed';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: isDone
                        ? null
                        : () => ref
                            .read(planProvider.notifier)
                            .markPlanEntryStatus(
                              entry.id as int,
                              'completed',
                              entry.plannedHours as double,
                            ),
                    child: Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isDone
                          ? LightColors.learned
                          : Colors.grey.shade400,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.chapterName as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              decoration:
                                  isDone ? TextDecoration.lineThrough : null,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(
                            '${entry.subjectName}  •  ${entry.plannedHours}h',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: () => context.go(AppRoutes.log),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Log a session'),
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weakness Alert
// ─────────────────────────────────────────────────────────────────────────────

class _WeaknessAlert extends StatelessWidget {
  final WeaknessRadar radar;
  final bool isDark;

  const _WeaknessAlert({required this.radar, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topWeak = radar.weakChapters.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LightColors.error.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LightColors.error.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                    '${radar.totalWeakAreas} Weak Areas Need Attention',
                    style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LightColors.error)),
              ),
              GestureDetector(
                onTap: () => context.push('/analytics/weakness'),
                child: Text('View All',
                    style: TextStyle(
                        fontSize: 12,
                        color: LightColors.error,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...topWeak.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Text('• ',
                        style: TextStyle(color: LightColors.error)),
                    Expanded(
                        child: Text(
                            '${c.subjectName}: ${c.name}',
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis)),
                    Text('W${c.weightage.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: LightColors.error)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Backlog Card
// ─────────────────────────────────────────────────────────────────────────────

class _BacklogCard extends StatelessWidget {
  final BacklogRecoveryPlan plan;
  final bool isDark;

  const _BacklogCard({required this.plan, required this.isDark});

  Color get _urgencyColor {
    switch (plan.urgencyLevel) {
      case 'critical': return LightColors.error;
      case 'high': return const Color(0xFFFF9800);
      case 'medium': return LightColors.tested;
      default: return LightColors.learned;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _urgencyColor;
    final shown = plan.items.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📋', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Backlog Recovery Plan',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                    plan.urgencyLevel[0].toUpperCase() +
                        plan.urgencyLevel.substring(1),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
              '${plan.totalBacklogChapters} chapters · ~${plan.estimatedDaysToRecover.toStringAsFixed(0)} days to recover',
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 10),
          ...shown.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${item.priority}',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: color)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.chapter.name,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis),
                          Text(item.action,
                              style: theme.textTheme.labelSmall,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Command Actions
// ─────────────────────────────────────────────────────────────────────────────

class _CommandActions extends StatelessWidget {
  final bool isDark;
  const _CommandActions({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              _ActionButton(
                emoji: '🍅',
                label: 'Start Pomodoro',
                color: const Color(0xFFFF6B6B),
                onTap: () => context.push(AppRoutes.pomodoro),
              ),
              const SizedBox(width: 10),
              _ActionButton(
                emoji: '📝',
                label: 'Log Session',
                color: LightColors.primary,
                onTap: () => context.go(AppRoutes.log),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ActionButton(
                emoji: '🔄',
                label: 'Revisions',
                color: LightColors.revised,
                onTap: () => context.go(AppRoutes.revision),
              ),
              const SizedBox(width: 10),
              _ActionButton(
                emoji: '📊',
                label: 'Mock Test',
                color: LightColors.tested,
                onTap: () => context.push(AppRoutes.testScore),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Exam mode badge (shown in AppBar)
// ─────────────────────────────────────────────────────────────────────────────

class _ExamModeBadge extends StatelessWidget {
  final ExamMode mode;
  const _ExamModeBadge({required this.mode});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (mode.daysLeft <= 7) {
      color = LightColors.error;
    } else if (mode.daysLeft <= 30) {
      color = const Color(0xFFFF9800);
    } else {
      color = LightColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text('${mode.emoji} ${mode.daysLeft}d',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}
