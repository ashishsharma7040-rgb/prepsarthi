// lib/presentation/screens/plan/weekly_plan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/local/isar/schemas/plan_entry_schema.dart';
import '../../../data/remote/vertex/gemini_service.dart';
import '../../providers/all_providers.dart';
import '../../../router/app_router.dart';

class WeeklyPlanScreen extends ConsumerStatefulWidget {
  const WeeklyPlanScreen({super.key});
  @override
  ConsumerState<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends ConsumerState<WeeklyPlanScreen> {
  int _weekOffset = 0;

  DateTime get _weekStart {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final base = DateTime(monday.year, monday.month, monday.day);
    return base.add(Duration(days: _weekOffset * 7));
  }

  List<DateTime> get _weekDays =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final planState = ref.watch(planProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Study Plan', style: theme.textTheme.headlineLarge),
                      Row(
                        children: [
                          _IconBtn(icon: Icons.chevron_left, onTap: () => setState(() => _weekOffset--), isDark: isDark),
                          const SizedBox(width: 4),
                          Text(
                            _weekOffset == 0 ? 'This Week' : _weekOffset == 1 ? 'Next Week' : '+$_weekOffset weeks',
                            style: theme.textTheme.labelLarge,
                          ),
                          const SizedBox(width: 4),
                          _IconBtn(icon: Icons.chevron_right, onTap: () => setState(() => _weekOffset++), isDark: isDark),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _DayStrip(days: _weekDays, entries: planState.weekEntries, isDark: isDark),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _WeekBar(entries: planState.weekEntries, isDark: isDark),
            ),
            const SizedBox(height: 8),

            // List
            Expanded(
              child: planState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !planState.hasPlan
                      ? _NoPlanYet(isDark: isDark)
                      : _buildList(planState.weekEntries, isDark),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRegenerateSheet(context, isDark),
        icon: const Text('🧠', style: TextStyle(fontSize: 20)),
        label: const Text('AI Regenerate'),
        backgroundColor: isDark ? DarkColors.primary : LightColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildList(List<PlanEntrySchema> entries, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: _weekDays.length,
      itemBuilder: (_, i) {
        final day = _weekDays[i];
        final dayEntries = entries.where((e) =>
            e.plannedDate.year == day.year &&
            e.plannedDate.month == day.month &&
            e.plannedDate.day == day.day).toList()
          ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        if (dayEntries.isEmpty) return const SizedBox.shrink();
        return _DaySection(day: day, entries: dayEntries, isDark: isDark)
            .animate(delay: (i * 50).ms).fadeIn().slideY(begin: 0.06);
      },
    );
  }

  void _showRegenerateSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RegenerateSheet(isDark: isDark),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Day Section with fully wired slidable actions
// ─────────────────────────────────────────────────────────────────────────────
class _DaySection extends ConsumerWidget {
  final DateTime day;
  final List<PlanEntrySchema> entries;
  final bool isDark;

  const _DaySection({required this.day, required this.entries, required this.isDark});

  bool get _isToday {
    final n = DateTime.now();
    return day.year == n.year && day.month == n.month && day.day == n.day;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accent = isDark ? DarkColors.primary : LightColors.primary;
    final total = entries.fold(0.0, (s, e) => s + e.plannedHours);
    final done = entries.where((e) => e.status == 'completed').fold(0.0, (s, e) => s + e.plannedHours);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _isToday ? accent : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _isToday ? accent : (isDark ? DarkColors.outline : LightColors.outline)),
              ),
              child: Text(
                _isToday ? '🔥 Today' : DateFormat('EEE, d MMM').format(day),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: _isToday ? Colors.white : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('${total.toStringAsFixed(1)}h',
                style: theme.textTheme.labelMedium?.copyWith(color: accent)),
            if (done > 0) ...[
              const SizedBox(width: 6),
              Text('• ${done.toStringAsFixed(1)}h done',
                  style: theme.textTheme.labelSmall?.copyWith(color: LightColors.learned)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        ...entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Slidable(
            key: ValueKey(entry.id),
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              extentRatio: 0.42,
              children: [
                SlidableAction(
                  onPressed: (_) async {
                    // WIRED: mark completed
                    await ref.read(planProvider.notifier).markPlanEntryStatus(
                      entry.id, 'completed', entry.plannedHours,
                    );
                    // Also mark chapter as learned if not already
                    if (entry.status != 'completed' && !entry.isRevision) {
                      await ref.read(planProvider.notifier).markChapterStatus(
                        entry.chapterName, 'learned',
                      );
                      await ref.read(authProvider.notifier).updateStreak();
                    }
                    // Log automatically
                    await ref.read(studyLogProvider.notifier).logSession(
                      chapterName: entry.chapterName,
                      subjectName: entry.subjectName,
                      hours: entry.plannedHours,
                      activityTag: entry.isRevision ? 'revised' : 'learned',
                    );
                  },
                  backgroundColor: LightColors.learned,
                  foregroundColor: Colors.white,
                  icon: Icons.check_circle_outline,
                  label: 'Done',
                ),
                SlidableAction(
                  onPressed: (_) async {
                    // WIRED: mark skipped
                    await ref.read(planProvider.notifier).markPlanEntryStatus(
                      entry.id, 'skipped', 0,
                    );
                  },
                  backgroundColor: LightColors.tested,
                  foregroundColor: Colors.white,
                  icon: Icons.skip_next_rounded,
                  label: 'Skip',
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
                ),
              ],
            ),
            child: _EntryTile(entry: entry, isDark: isDark),
          ),
        )),
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  final PlanEntrySchema entry;
  final bool isDark;
  const _EntryTile({required this.entry, required this.isDark});

  Color _subjectColor() {
    switch (entry.subjectName) {
      case 'Physics': return isDark ? DarkColors.physics : LightColors.physics;
      case 'Chemistry': return isDark ? DarkColors.chemistry : LightColors.chemistry;
      case 'Mathematics': return isDark ? DarkColors.mathematics : LightColors.mathematics;
      default: return isDark ? DarkColors.biology : LightColors.biology;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _subjectColor();
    final isCompleted = entry.status == 'completed';
    final isSkipped = entry.status == 'skipped';

    return Container(
      decoration: BoxDecoration(
        color: isSkipped
            ? (isDark ? DarkColors.surfaceVariant : LightColors.surfaceVariant)
            : (isDark ? DarkColors.surfaceCard : LightColors.surface),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted
              ? LightColors.learned.withOpacity(0.4)
              : (isDark ? DarkColors.outline : LightColors.outline),
          width: isCompleted ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 5, height: 70,
            decoration: BoxDecoration(
              color: entry.isMockTest ? LightColors.tested : color,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (entry.isRevision)
                        _Badge('🔄 Revision', LightColors.revised),
                      if (entry.isMockTest)
                        _Badge('🧪 Mock Test', LightColors.tested),
                    ],
                  ),
                  if (entry.isRevision || entry.isMockTest) const SizedBox(height: 3),
                  Text(
                    entry.chapterName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted || isSkipped ? TextDecoration.lineThrough : null,
                      color: isSkipped
                          ? (isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant)
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      _SubjectBadge(name: entry.subjectName, color: color),
                      const SizedBox(width: 8),
                      Text('${entry.plannedHours}h', style: theme.textTheme.bodySmall),
                      if (isCompleted) ...[
                        const SizedBox(width: 6),
                        Text('✓ ${entry.actualHours}h actual',
                            style: theme.textTheme.labelSmall?.copyWith(color: LightColors.learned)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: isCompleted
                ? const Icon(Icons.check_circle, color: LightColors.learned, size: 22)
                : isSkipped
                    ? const Icon(Icons.skip_next_rounded, color: LightColors.tested, size: 22)
                    : Icon(Icons.radio_button_unchecked,
                        color: isDark ? DarkColors.outline : LightColors.outline, size: 22),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    margin: const EdgeInsets.only(right: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
  );
}

class _SubjectBadge extends StatelessWidget {
  final String name;
  final Color color;
  const _SubjectBadge({required this.name, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(4),
    ),
    child: Text(name, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Regenerate Sheet — fully wired to GeminiService
// ─────────────────────────────────────────────────────────────────────────────
class _RegenerateSheet extends ConsumerStatefulWidget {
  final bool isDark;
  const _RegenerateSheet({required this.isDark});
  @override
  ConsumerState<_RegenerateSheet> createState() => _RegenerateSheetState();
}

class _RegenerateSheetState extends ConsumerState<_RegenerateSheet> {
  bool _loading = false;
  String? _error;

  Future<void> _regenerate() async {
    setState(() { _loading = true; _error = null; });
    try {
      final planState = ref.read(planProvider);
      final auth = ref.read(authProvider);
      final logs = ref.read(studyLogProvider);

      final completed = planState.chapters
          .where((c) => c.status == 'learned' || c.status == 'revised' || c.status == 'tested')
          .toList();

      final pendingHigh = planState.chapters
          .where((c) => c.status == 'not_started' || c.status == 'in_progress')
          .where((c) => c.weightage >= 60)
          .toList()
        ..sort((a, b) => b.weightage.compareTo(a.weightage));

      final weakChapters = planState.chapters
          .where((c) => c.estimatedHours > 0 && (c.hoursSpent / c.estimatedHours) < 0.3 && c.weightage >= 50)
          .toList();

      // Get recent daily hours
      final now = DateTime.now();
      final recentHours = List.generate(7, (i) {
        final d = now.subtract(Duration(days: i));
        final start = DateTime(d.year, d.month, d.day);
        final end = start.add(const Duration(days: 1));
        return logs.where((l) => l.timestamp.isAfter(start) && l.timestamp.isBefore(end))
            .fold(0.0, (s, l) => s + l.hoursStudied);
      });

      final aiPlan = await GeminiService.regeneratePlan(
        examDate: auth.user?.examDate ?? DateTime.now().add(const Duration(days: 300)),
        dailyHours: auth.user?.dailyStudyHours ?? 6.0,
        completedChapters: completed,
        pendingHighWeightChapters: pendingHigh.take(10).toList(),
        recentDailyHours: recentHours,
        weakChapters: weakChapters.take(5).toList(),
      );

      // Apply AI plan — update plan entries for next 7 days
      await ref.read(planProvider.notifier).applyAIPlan(aiPlan);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🧠 Plan regenerated with AI!'),
            backgroundColor: LightColors.learned,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = widget.isDark ? DarkColors.primary : LightColors.primary;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🧠', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Text('Regenerate with AI', style: theme.textTheme.headlineSmall),
          ]),
          const SizedBox(height: 12),
          Text(
            'AI will analyse your progress, actual study pace, and weak areas to create an improved 7-day schedule.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: widget.isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI considers:', style: theme.textTheme.labelLarge?.copyWith(color: accent)),
                const SizedBox(height: 8),
                for (final s in [
                  '✓  Chapters you\'ve completed',
                  '✓  Your actual daily study pace (last 7 days)',
                  '✓  High-weightage pending chapters',
                  '✓  Weak areas needing revision',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(s, style: theme.textTheme.bodySmall),
                  ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: LightColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: LightColors.error)),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : _regenerate,
            child: _loading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : const Text('Regenerate Now'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _loading ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// ─── Supporting widgets ────────────────────────────────────────────────────

class _DayStrip extends StatelessWidget {
  final List<DateTime> days;
  final List<PlanEntrySchema> entries;
  final bool isDark;
  const _DayStrip({required this.days, required this.entries, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isDark ? DarkColors.primary : LightColors.primary;
    final now = DateTime.now();
    return Row(
      children: days.map((d) {
        final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
        final has = entries.any((e) => e.plannedDate.year == d.year && e.plannedDate.month == d.month && e.plannedDate.day == d.day);
        return Expanded(
          child: Column(
            children: [
              Text(DateFormat('EEE').format(d),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: isToday ? FontWeight.w700 : null,
                    color: isToday ? accent : null,
                  )),
              const SizedBox(height: 4),
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: isToday ? accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text('${d.day}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isToday ? Colors.white : null,
                      fontWeight: isToday ? FontWeight.w700 : null,
                    ))),
              ),
              const SizedBox(height: 4),
              Container(
                width: 5, height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: has ? accent : Colors.transparent,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _WeekBar extends StatelessWidget {
  final List<PlanEntrySchema> entries;
  final bool isDark;
  const _WeekBar({required this.entries, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isDark ? DarkColors.primary : LightColors.primary;
    final total = entries.fold(0.0, (s, e) => s + e.plannedHours);
    final done = entries.where((e) => e.status == 'completed').fold(0.0, (s, e) => s + e.plannedHours);
    final ratio = total > 0 ? (done / total).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surfaceCard : LightColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Week: ${(ratio * 100).round()}%', style: theme.textTheme.labelLarge),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio, minHeight: 8,
                    backgroundColor: isDark ? DarkColors.outline : LightColors.outline,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${done.toStringAsFixed(1)} / ${total.toStringAsFixed(1)}h',
                  style: theme.textTheme.titleSmall?.copyWith(color: accent, fontWeight: FontWeight.w700)),
              Text('${entries.length} sessions', style: theme.textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoPlanYet extends StatelessWidget {
  final bool isDark;
  const _NoPlanYet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📋', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('No plan generated yet', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Complete onboarding to auto-generate your study plan, or use the AI Regenerate button.',
              style: theme.textTheme.bodySmall, textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  const _IconBtn({required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surfaceVariant : LightColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18),
    ),
  );
}
