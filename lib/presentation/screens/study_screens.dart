// lib/presentation/screens/study_screens.dart
// Contains: DailyLogScreen + RevisionScheduleScreen

import 'package:confetti/confetti.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../data/local/isar/isar_service.dart';
import '../providers/all_providers.dart';
import '../../domain/usecases/generate_plan_usecase.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// DAILY LOG SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class DailyLogScreen extends ConsumerStatefulWidget {
  const DailyLogScreen({super.key});
  @override
  ConsumerState<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends ConsumerState<DailyLogScreen> {
  late ConfettiController _confetti;
  String? _selectedSubject;
  String? _selectedChapter;
  double _hours = 1.0;
  String _activityTag = 'learned';
  final _notesCtrl = TextEditingController();
  bool _isSaving = false;
  String? _saveError;

  final _tags = [
    ('learned', '✅', 'Learned', LightColors.learned),
    ('revised', '🔄', 'Revised', LightColors.revised),
    ('tested', '🧪', 'Tested', LightColors.tested),
    ('pyq', '📝', 'PYQ Done', LightColors.pyqDone),
    ('notes', '📒', 'Notes Made', LightColors.notesMade),
  ];

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confetti.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  List<String> _subjects(List<ChapterSchema> chapters) =>
      chapters.map((c) => c.subjectName).toSet().toList()..sort();

  List<String> _chaptersFor(List<ChapterSchema> chapters, String? subject) {
    if (subject == null) return [];
    return chapters.where((c) => c.subjectName == subject).map((c) => c.name).toList()..sort();
  }

  Future<void> _save() async {
    if (_selectedChapter == null || _selectedSubject == null) return;
    setState(() { _isSaving = true; _saveError = null; });

    try {
      // ── FIX: Data Safety — clamp hours to sane range ──────────────────
      final safeHours = _hours.clamp(0.25, 10.0);
      final dailyTarget = ref.read(authProvider).user?.dailyStudyHours ?? 6.0;
      final todayAlready = ref.read(studyLogProvider.notifier).hoursForDate(DateTime.now());

      // Warn if this single session exceeds 2× daily target — likely a mistake
      if (safeHours > dailyTarget * 2 && mounted) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('⚠️ Unusually Long Session'),
            content: Text(
              "You're logging ${safeHours.toStringAsFixed(1)}h, which is more than "
              '2× your daily target (${dailyTarget.toStringAsFixed(1)}h). '
              'Are you sure this is correct?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Fix It'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Yes, Log It'),
              ),
            ],
          ),
        );
        if (confirm != true) {
          setState(() => _isSaving = false);
          return;
        }
      }
      // ── END FIX ──────────────────────────────────────────────────────

      await ref.read(studyLogProvider.notifier).logSession(
        chapterName: _selectedChapter!,
        subjectName: _selectedSubject!,
        hours: safeHours,
        activityTag: _activityTag,
        notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
      );

      // Schedule revisions if chapter marked learned
      if (_activityTag == 'learned') {
        final planState = ref.read(planProvider);
        final chapter = planState.chapters
            .where((c) => c.name == _selectedChapter)
            .firstOrNull;
        if (chapter != null && chapter.firstLearnedDate == null) {
          await GeneratePlanUseCase.scheduleRevisions(
            chapterName: _selectedChapter!,
            subjectName: _selectedSubject!,
            learnedDate: DateTime.now(),
            estimatedHours: chapter.estimatedHours,
          );
          // Also mark chapter status
          await ref.read(planProvider.notifier).markChapterStatus(
            _selectedChapter!, 'learned',
          );
        }
      }

      // Update streak
      await ref.read(authProvider.notifier).updateStreak();
      await ref.read(planProvider.notifier).refresh();

      _confetti.play();

      // Check daily goal met
      final logNotifier = ref.read(studyLogProvider.notifier);
      final todayHours = logNotifier.hoursForDate(DateTime.now());
      final dailyGoal = ref.read(authProvider).user?.dailyStudyHours ?? 6.0;
      final goalMet = todayHours >= dailyGoal * 0.9;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(goalMet
                ? '🎉 Daily goal reached! Amazing work!'
                : '✅ Session logged! ${todayHours.toStringAsFixed(1)}h today.'),
            backgroundColor: LightColors.learned,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        // Reset form
        setState(() {
          _isSaving = false;
          _selectedChapter = null;
          _hours = 1.0;
          _activityTag = 'learned';
        });
        _notesCtrl.clear();
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _saveError = 'Failed to save: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? DarkColors.primary : LightColors.primary;
    final planState = ref.watch(planProvider);
    final subjects = _subjects(planState.chapters);
    final chapters = _chaptersFor(planState.chapters, _selectedSubject);

    // Today's logged hours
    final todayHours = ref.read(studyLogProvider.notifier).hoursForDate(DateTime.now());
    final dailyGoal = ref.read(authProvider).user?.dailyStudyHours ?? 6.0;
    final goalProgress = (todayHours / dailyGoal).clamp(0.0, 1.0);

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [LightColors.primary, LightColors.secondary, LightColors.tertiary],
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  title: const Text('Log Study Session'),
                  pinned: true,
                  actions: [
                    TextButton(
                      onPressed: (_selectedChapter == null || _isSaving) ? null : _save,
                      child: _isSaving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text('Save', style: TextStyle(
                              color: _selectedChapter == null ? null : accent,
                              fontWeight: FontWeight.w700,
                            )),
                    ),
                  ],
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([

                      // ── Daily Goal Progress ────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: accent.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Today\'s Progress', style: theme.textTheme.labelLarge),
                                Text(
                                  '${todayHours.toStringAsFixed(1)} / ${dailyGoal.toStringAsFixed(0)}h',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: accent, fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: goalProgress,
                                minHeight: 8,
                                backgroundColor: isDark ? DarkColors.outline : LightColors.outline,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  goalProgress >= 1.0 ? LightColors.learned : accent,
                                ),
                              ),
                            ),
                            if (goalProgress >= 1.0) ...[
                              const SizedBox(height: 6),
                              Text('🎉 Daily goal reached!',
                                  style: theme.textTheme.labelSmall?.copyWith(color: LightColors.learned)),
                            ],
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms),

                      // ── Today's Planned Chapters (quick select) ────────────
                      if (planState.todayEntries.isNotEmpty) ...[
                        Text('Today\'s Plan', style: theme.textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 64,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: planState.todayEntries.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final e = planState.todayEntries[i];
                              final sel = _selectedChapter == e.chapterName;
                              return GestureDetector(
                                onTap: () => setState(() {
                                  _selectedSubject = e.subjectName;
                                  _selectedChapter = e.chapterName;
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: sel ? accent : (isDark ? DarkColors.surfaceVariant : LightColors.surfaceVariant),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: sel ? accent : Colors.transparent, width: 1.5),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(e.chapterName,
                                          style: theme.textTheme.labelMedium?.copyWith(
                                            color: sel ? Colors.white : null, fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1, overflow: TextOverflow.ellipsis),
                                      Text('${e.subjectName} • ${e.plannedHours}h',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: sel ? Colors.white70 : null,
                                          )),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Subject ────────────────────────────────────────────
                      _Label('Subject'),
                      const SizedBox(height: 8),
                      _PickerField(
                        value: _selectedSubject,
                        hint: planState.hasChapters ? 'Tap to select subject' : 'No syllabus loaded — complete onboarding first',
                        items: subjects,
                        isDark: isDark,
                        enabled: planState.hasChapters,
                        onChanged: (v) => setState(() { _selectedSubject = v; _selectedChapter = null; }),
                      ),
                      const SizedBox(height: 16),

                      // ── Chapter ────────────────────────────────────────────
                      _Label('Chapter'),
                      const SizedBox(height: 8),
                      _PickerField(
                        value: _selectedChapter,
                        hint: _selectedSubject == null ? 'Select subject first' : 'Tap to select chapter',
                        items: chapters,
                        isDark: isDark,
                        enabled: _selectedSubject != null && chapters.isNotEmpty,
                        onChanged: (v) => setState(() => _selectedChapter = v),
                      ),
                      const SizedBox(height: 20),

                      // ── Hours Slider ────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _Label('Hours Studied'),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.12), borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('${_hours.toStringAsFixed(1)}h',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: accent, fontWeight: FontWeight.w700,
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                          activeTrackColor: accent,
                          inactiveTrackColor: isDark ? DarkColors.outline : LightColors.outline,
                          thumbColor: accent,
                          overlayColor: accent.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _hours, min: 0.25, max: 10.0, divisions: 39,
                          onChanged: (v) => setState(() => _hours = v),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('15 min', style: theme.textTheme.labelSmall),
                          Text('8 hrs', style: theme.textTheme.labelSmall),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Activity Tag ────────────────────────────────────────
                      _Label('Activity Type'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: _tags.map((t) {
                          final (id, emoji, label, color) = t;
                          final sel = _activityTag == id;
                          return GestureDetector(
                            onTap: () => setState(() => _activityTag = id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: sel ? color.withOpacity(0.12) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: sel ? color : (isDark ? DarkColors.outline : LightColors.outline),
                                  width: sel ? 1.5 : 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(emoji, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(label,
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: sel ? color : null,
                                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                                      )),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // ── Notes ───────────────────────────────────────────────
                      _Label('Notes (optional)'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Doubts, key formulas, important points...',
                          hintStyle: theme.textTheme.bodySmall,
                        ),
                      ),

                      // ── Error ───────────────────────────────────────────────
                      if (_saveError != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: LightColors.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: LightColors.error.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: LightColors.error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_saveError!,
                                  style: theme.textTheme.bodySmall?.copyWith(color: LightColors.error))),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── Save Button ─────────────────────────────────────────
                      FilledButton(
                        onPressed: (_selectedChapter == null || _isSaving) ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                            : const Text('Save Session ✅'),
                      ),

                      const SizedBox(height: 20),

                      // ── Recent logs today ────────────────────────────────────
                      _TodayLogsSummary(isDark: isDark),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Today's sessions at bottom of log screen
class _TodayLogsSummary extends ConsumerWidget {
  final bool isDark;
  const _TodayLogsSummary({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logs = ref.watch(studyLogProvider);
    final today = DateTime.now();
    final todayLogs = logs.where((l) {
      final d = l.timestamp;
      return d.year == today.year && d.month == today.month && d.day == today.day;
    }).toList();

    if (todayLogs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today\'s Sessions',
            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...todayLogs.map((log) {
          final (emoji, color) = _tagInfo(log.activityTag);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? DarkColors.surfaceCard : LightColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isDark ? DarkColors.outline : LightColors.outline, width: 0.5),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.chapterName,
                          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${log.subjectName} • ${log.hoursStudied.toStringAsFixed(1)}h',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Text(DateFormat('h:mm a').format(log.timestamp),
                    style: theme.textTheme.labelSmall),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.05);
        }),
      ],
    );
  }

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
}

// ═══════════════════════════════════════════════════════════════════════════════
// REVISION SCHEDULE SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class RevisionScheduleScreen extends ConsumerWidget {
  const RevisionScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final upcomingAsync = ref.watch(upcomingRevisionsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              title: const Text('Revision Schedule'),
              pinned: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add manual revision',
                  onPressed: () => _showAddRevisionSheet(context, ref, isDark),
                ),
              ],
            ),

            upcomingAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: _ErrorState(message: e.toString(), isDark: isDark),
              ),
              data: (grouped) {
                final allEmpty = grouped.values.every((l) => l.isEmpty);
                if (allEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyRevision(isDark: isDark),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Stats row
                      _RevisionStats(grouped: grouped, isDark: isDark),
                      const SizedBox(height: 16),

                      for (final group in grouped.entries)
                        if (group.value.isNotEmpty) ...[
                          _GroupHeader(label: group.key, count: group.value.length, isDark: isDark),
                          ...group.value.asMap().entries.map((e) =>
                              _RevisionTile(
                                revision: e.value,
                                isDark: isDark,
                                groupLabel: group.key,
                                onComplete: () => _completeRevision(context, ref, e.value),
                                onPostpone: () => _postponeRevision(context, ref, e.value),
                              ).animate(delay: (e.key * 50).ms).fadeIn().slideY(begin: 0.08),
                          ),
                          const SizedBox(height: 8),
                        ],
                    ]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Mark revision complete ───────────────────────────────────────────────
  Future<void> _completeRevision(
      BuildContext context, WidgetRef ref, RevisionScheduleSchema revision) async {
    final db = IsarService.db;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Find the next pending date
    final pending = revision.scheduledDates.where((d) =>
        !revision.completedDates.any((c) => c.year == d.year && c.month == d.month && c.day == d.day) &&
        !d.isBefore(today)).toList()..sort();

    if (pending.isEmpty) return;

    revision.completedDates.add(pending.first);
    revision.completedCount++;
    if (revision.completedCount >= revision.scheduledDates.length) {
      revision.isFullyRevised = true;
    }

    await db.writeTxn(() async => db.revisionScheduleSchemas.put(revision));

    // Auto-log as revised
    await ref.read(studyLogProvider.notifier).logSession(
      chapterName: revision.chapterName,
      subjectName: revision.subjectName,
      hours: 0.5,
      activityTag: 'revised',
    );

    ref.invalidate(upcomingRevisionsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔄 ${revision.chapterName} marked revised!'),
          backgroundColor: LightColors.revised,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ── Postpone revision by 2 days ─────────────────────────────────────────
  Future<void> _postponeRevision(
      BuildContext context, WidgetRef ref, RevisionScheduleSchema revision) async {
    final db = IsarService.db;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final updated = revision.scheduledDates.map((d) {
      if (!d.isBefore(today) && !revision.completedDates.any(
          (c) => c.year == d.year && c.month == d.month && c.day == d.day)) {
        return d.add(const Duration(days: 2));
      }
      return d;
    }).toList();

    revision.scheduledDates.clear();
    revision.scheduledDates.addAll(updated);

    await db.writeTxn(() async => db.revisionScheduleSchemas.put(revision));
    ref.invalidate(upcomingRevisionsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📅 Revision postponed by 2 days'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Add manual revision sheet ────────────────────────────────────────────
  void _showAddRevisionSheet(BuildContext context, WidgetRef ref, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddRevisionSheet(isDark: isDark, ref: ref),
    );
  }
}

// ─── Revision Tile with Slidable (complete / postpone) ────────────────────────
class _RevisionTile extends StatelessWidget {
  final RevisionScheduleSchema revision;
  final bool isDark;
  final String groupLabel;
  final VoidCallback onComplete;
  final VoidCallback onPostpone;

  const _RevisionTile({
    required this.revision,
    required this.isDark,
    required this.groupLabel,
    required this.onComplete,
    required this.onPostpone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final revNo = revision.completedCount + 1;
    final totalRevs = revision.scheduledDates.length;

    final urgentColor = groupLabel == 'Today'
        ? LightColors.error
        : groupLabel == 'Tomorrow'
            ? LightColors.tested
            : LightColors.revised;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Slidable(
        key: ValueKey(revision.id),
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.3,
          children: [
            SlidableAction(
              onPressed: (_) => onPostpone(),
              backgroundColor: LightColors.tested,
              foregroundColor: Colors.white,
              icon: Icons.schedule_rounded,
              label: '+2 days',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.3,
          children: [
            SlidableAction(
              onPressed: (_) => onComplete(),
              backgroundColor: LightColors.revised,
              foregroundColor: Colors.white,
              icon: Icons.check_circle_outline,
              label: 'Done',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? DarkColors.surfaceCard : LightColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: groupLabel == 'Today'
                  ? urgentColor.withOpacity(0.4)
                  : (isDark ? DarkColors.outline : LightColors.outline),
              width: groupLabel == 'Today' ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: urgentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text('🔄', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(revision.chapterName,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(revision.subjectName, style: theme.textTheme.bodySmall),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: urgentColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Rev $revNo/$totalRevs',
                            style: theme.textTheme.labelSmall?.copyWith(color: urgentColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(groupLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: urgentColor, fontWeight: FontWeight.w700,
                      )),
                  Text('~30 min', style: theme.textTheme.labelSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Add Manual Revision Sheet ─────────────────────────────────────────────────
class _AddRevisionSheet extends ConsumerStatefulWidget {
  final bool isDark;
  final WidgetRef ref;
  const _AddRevisionSheet({required this.isDark, required this.ref});

  @override
  ConsumerState<_AddRevisionSheet> createState() => _AddRevisionSheetState();
}

class _AddRevisionSheetState extends ConsumerState<_AddRevisionSheet> {
  String? _selectedSubject;
  String? _selectedChapter;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planState = ref.read(planProvider);
    final subjects = planState.chapters.map((c) => c.subjectName).toSet().toList()..sort();
    final chapters = _selectedSubject == null
        ? <String>[]
        : planState.chapters.where((c) => c.subjectName == _selectedSubject).map((c) => c.name).toList()..sort();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🔄', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text('Add Manual Revision', style: theme.textTheme.headlineSmall),
          ]),
          const SizedBox(height: 16),
          _PickerField(
            value: _selectedSubject,
            hint: 'Select subject',
            items: subjects,
            isDark: widget.isDark,
            enabled: true,
            onChanged: (v) => setState(() { _selectedSubject = v; _selectedChapter = null; }),
          ),
          const SizedBox(height: 12),
          _PickerField(
            value: _selectedChapter,
            hint: _selectedSubject == null ? 'Select subject first' : 'Select chapter',
            items: chapters,
            isDark: widget.isDark,
            enabled: _selectedSubject != null && chapters.isNotEmpty,
            onChanged: (v) => setState(() => _selectedChapter = v),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: (_selectedChapter == null || _saving) ? null : () async {
              setState(() => _saving = true);
              final chapter = ref.read(planProvider).chapters
                  .firstWhere((c) => c.name == _selectedChapter!);
              await GeneratePlanUseCase.scheduleRevisions(
                chapterName: chapter.name,
                subjectName: chapter.subjectName,
                learnedDate: DateTime.now().subtract(const Duration(days: 1)),
                estimatedHours: chapter.estimatedHours,
              );
              ref.invalidate(upcomingRevisionsProvider);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Revision scheduled for ${chapter.name}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: _saving
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : const Text('Schedule Revision'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// ─── Supporting Widgets ────────────────────────────────────────────────────────
class _RevisionStats extends StatelessWidget {
  final Map<String, List<RevisionScheduleSchema>> grouped;
  final bool isDark;
  const _RevisionStats({required this.grouped, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todayCount = grouped['Today']?.length ?? 0;
    final totalPending = grouped.values.fold(0, (s, l) => s + l.length);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surfaceCard : LightColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _RevStat('📋', '$totalPending', 'Pending', theme),
          const SizedBox(width: 20),
          _RevStat('🔴', '$todayCount', 'Due Today', theme),
          const SizedBox(width: 20),
          _RevStat('📅', '${grouped['This Week']?.length ?? 0}', 'This Week', theme),
        ],
      ),
    );
  }
}

class _RevStat extends StatelessWidget {
  final String emoji, value, label;
  final ThemeData theme;
  const _RevStat(this.emoji, this.value, this.label, this.theme);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      ]),
      Text(label, style: theme.textTheme.labelSmall),
    ],
  );
}

class _GroupHeader extends StatelessWidget {
  final String label;
  final int count;
  final bool isDark;
  const _GroupHeader({required this.label, required this.count, required this.isDark});

  Color _color() {
    switch (label) {
      case 'Today': return LightColors.error;
      case 'Tomorrow': return LightColors.tested;
      case 'This Week': return LightColors.primary;
      default: return LightColors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 8),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _color().withOpacity(0.12), borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: _color(), fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        Text('$count chapter${count == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.labelSmall),
      ],
    ),
  );
}

class _EmptyRevision extends StatelessWidget {
  final bool isDark;
  const _EmptyRevision({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('All clear!', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'No revisions due right now. Mark chapters as "Learned" to auto-schedule spaced revisions.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final bool isDark;
  const _ErrorState({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('Could not load revisions', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Form Widgets ────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600));
}

// ─────────────────────────────────────────────────────────────────────────────
// _PickerField — replaces DropdownButton (which has known scroll+overlay issues
// on Android/iOS inside CustomScrollView). Uses a reliable ModalBottomSheet.
// ─────────────────────────────────────────────────────────────────────────────
class _PickerField extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool isDark;
  final bool enabled;

  const _PickerField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    required this.isDark,
    required this.enabled,
  });

  Future<void> _openPicker(BuildContext context) async {
    if (!enabled || items.isEmpty) return;
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        items: items,
        selected: value,
        isDark: isDark,
      ),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = enabled && items.isNotEmpty
        ? (isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant)
        : (isDark ? DarkColors.outline : LightColors.outline);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surfaceVariant : LightColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value != null
                ? (isDark ? DarkColors.primary : LightColors.primary).withOpacity(0.5)
                : (isDark ? DarkColors.outline : LightColors.outline),
            width: value != null ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: value != null
                      ? (isDark ? DarkColors.onSurfaceVariant : LightColors.onSurface)
                      : textColor,
                  fontWeight: value != null ? FontWeight.w500 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              enabled && items.isNotEmpty
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.lock_outline_rounded,
              size: 20,
              color: textColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PickerSheet — searchable scrollable list shown as bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _PickerSheet extends StatefulWidget {
  final List<String> items;
  final String? selected;
  final bool isDark;
  const _PickerSheet({required this.items, required this.selected, required this.isDark});

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDark;
    final accent = isDark ? DarkColors.primary : LightColors.primary;

    final filtered = widget.items
        .where((s) => s.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    final maxH = MediaQuery.of(context).size.height * 0.75;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? DarkColors.outline : LightColors.outline,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: TextField(
              controller: _searchCtrl,
              autofocus: widget.items.length > 8,
              decoration: InputDecoration(
                hintText: 'Search…',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('No results for "$_query"',
                        style: theme.textTheme.bodySmall),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final item = filtered[i];
                      final selected = item == widget.selected;
                      return ListTile(
                        dense: true,
                        title: Text(
                          item,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                            color: selected ? accent : null,
                          ),
                        ),
                        trailing: selected
                            ? Icon(Icons.check_circle_rounded, color: accent, size: 20)
                            : null,
                        onTap: () => Navigator.pop(context, item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
