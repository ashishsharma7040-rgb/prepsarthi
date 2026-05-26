// lib/presentation/screens/plan/chapter_mastery_screen.dart
//
// Premium: Chapter Mastery Level + PYQ Progress tracker.
// Students can set 0–7 mastery level and PYQ completion per chapter.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/local/isar/isar_service.dart';
import '../../../data/local/isar/schemas/chapter_schema.dart';
import '../../providers/all_providers.dart';

const _masteryLabels = [
  'Not Started',
  'Theory Started',
  'Theory Done',
  'Questions Done',
  'PYQs Done',
  'Revision 1 Done',
  'Revision 2 Done',
  'Test Ready',
];

const _masteryEmojis = ['📖', '📖', '✅', '✏️', '📝', '🔄', '🔄', '🎯'];
const _masteryColors = [
  Color(0xFFCBD5E0),
  Color(0xFF90CDF4),
  Color(0xFF63B3ED),
  Color(0xFF4299E1),
  Color(0xFF9C27B0),
  Color(0xFF4CAF50),
  Color(0xFF2E7D32),
  Color(0xFFFFD700),
];

const _pyqLabels = [
  'Not Started',
  '25% Done',
  '50% Done',
  '75% Done',
  '100% Done',
  'Mistakes Revised',
];

const _pyqEmojis = ['📝', '📝', '📝', '📝', '✅', '🏆'];

class ChapterMasteryScreen extends ConsumerStatefulWidget {
  const ChapterMasteryScreen({super.key});

  @override
  ConsumerState<ChapterMasteryScreen> createState() =>
      _ChapterMasteryScreenState();
}

class _ChapterMasteryScreenState
    extends ConsumerState<ChapterMasteryScreen> {
  String? _subjectFilter;
  String _searchQuery = '';
  bool _showWeakOnly = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final planState = ref.watch(planProvider);
    final chapters = planState.chapters;

    final subjects = chapters.map((c) => c.subjectName).toSet().toList()
      ..sort();

    var filtered = chapters.where((c) {
      if (_subjectFilter != null && c.subjectName != _subjectFilter)
        return false;
      if (_showWeakOnly && !c.isWeakChapter) return false;
      if (_searchQuery.isNotEmpty &&
          !c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        return false;
      return true;
    }).toList();

    // Stats
    final avgMastery = chapters.isNotEmpty
        ? chapters.fold<double>(0, (s, c) => s + c.masteryLevel) /
            chapters.length
        : 0.0;
    final testReady =
        chapters.where((c) => c.masteryLevel >= 7).length;
    final weakCount =
        chapters.where((c) => c.isWeakChapter).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter Mastery',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(_showWeakOnly
                ? Icons.warning_rounded
                : Icons.warning_outlined),
            color: _showWeakOnly ? LightColors.error : null,
            tooltip: 'Show weak chapters only',
            onPressed: () =>
                setState(() => _showWeakOnly = !_showWeakOnly),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                _StatChip(
                    label: 'Avg Mastery',
                    value: '${avgMastery.toStringAsFixed(1)}/7',
                    color: LightColors.primary),
                const SizedBox(width: 10),
                _StatChip(
                    label: 'Test Ready',
                    value: '$testReady',
                    color: const Color(0xFFFFD700)),
                const SizedBox(width: 10),
                _StatChip(
                    label: 'Weak',
                    value: '$weakCount',
                    color: LightColors.error),
              ],
            ),
          ),

          // Search
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search chapters...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // Subject filter
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                _SubjectChip(
                  label: 'All',
                  selected: _subjectFilter == null,
                  onTap: () =>
                      setState(() => _subjectFilter = null),
                ),
                ...subjects.map((s) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _SubjectChip(
                        label: s,
                        selected: _subjectFilter == s,
                        onTap: () => setState(() =>
                            _subjectFilter = _subjectFilter == s ? null : s),
                      ),
                    )),
              ],
            ),
          ),

          // Chapter list
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (ctx, i) => _ChapterMasteryCard(
                      chapter: filtered[i],
                      isDark: isDark,
                      onMasteryChange: (level) =>
                          _updateMastery(filtered[i], level),
                      onPyqChange: (progress) =>
                          _updatePyq(filtered[i], progress),
                      onWeakToggle: () =>
                          _toggleWeak(filtered[i]),
                    ).animate().fadeIn(delay: (i * 20).ms),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateMastery(ChapterSchema c, int level) async {
    final db = IsarService.db;
    c.masteryLevel = level;
    // Sync legacy status
    if (level >= 5) { c.status = 'revised'; }
    else if (level >= 3) { c.status = 'learned'; }
    if (level == 7) { c.status = 'tested'; }
    await db.writeTxn(() async => db.chapterSchemas.put(c));
    ref.read(planProvider.notifier).refresh();
  }

  Future<void> _updatePyq(ChapterSchema c, int progress) async {
    final db = IsarService.db;
    c.pyqProgress = progress;
    await db.writeTxn(() async => db.chapterSchemas.put(c));
    ref.read(planProvider.notifier).refresh();
  }

  Future<void> _toggleWeak(ChapterSchema c) async {
    final db = IsarService.db;
    c.isWeakChapter = !c.isWeakChapter;
    await db.writeTxn(() async => db.chapterSchemas.put(c));
    ref.read(planProvider.notifier).refresh();
  }
}

// ─── Chapter card ──────────────────────────────────────────────────────────────

class _ChapterMasteryCard extends StatelessWidget {
  final ChapterSchema chapter;
  final bool isDark;
  final ValueChanged<int> onMasteryChange;
  final ValueChanged<int> onPyqChange;
  final VoidCallback onWeakToggle;

  const _ChapterMasteryCard({
    required this.chapter,
    required this.isDark,
    required this.onMasteryChange,
    required this.onPyqChange,
    required this.onWeakToggle,
  });

  Color get _masteryColor => _masteryColors[chapter.masteryLevel];

  Color _subjectColor(String s) {
    switch (s) {
      case 'Physics': return LightColors.physics;
      case 'Chemistry': return LightColors.chemistry;
      case 'Mathematics': return LightColors.mathematics;
      default: return LightColors.biology;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjColor = _subjectColor(chapter.subjectName);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: chapter.isWeakChapter
              ? LightColors.error.withOpacity(0.4)
              : _masteryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                    color: subjColor,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chapter.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: subjColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(chapter.subjectName,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: subjColor,
                                  fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 6),
                        Text('W${chapter.weightage.toStringAsFixed(0)}',
                            style: theme.textTheme.labelSmall),
                        if (chapter.pyqCount > 0) ...[
                          const SizedBox(width: 6),
                          Text('${chapter.pyqCount} PYQs',
                              style: theme.textTheme.labelSmall),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Weak toggle
              GestureDetector(
                onTap: onWeakToggle,
                child: Icon(
                  chapter.isWeakChapter
                      ? Icons.warning_rounded
                      : Icons.warning_outlined,
                  color: chapter.isWeakChapter
                      ? LightColors.error
                      : Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Mastery bar
          Text('Mastery Level',
              style: theme.textTheme.labelSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Row(
            children: List.generate(8, (i) {
              final active = i <= chapter.masteryLevel;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onMasteryChange(i),
                  child: Container(
                    height: 28,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: active
                          ? _masteryColors[i]
                          : (isDark
                              ? DarkColors.outline
                              : LightColors.outline),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: i == chapter.masteryLevel
                        ? Center(
                            child: Text(
                              _masteryEmojis[i],
                              style: const TextStyle(fontSize: 10),
                            ),
                          )
                        : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_masteryLabels[chapter.masteryLevel],
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _masteryColor)),
              Text('Level ${chapter.masteryLevel}/7',
                  style: theme.textTheme.labelSmall),
            ],
          ),

          // PYQ tracker (only for chapters with PYQs)
          if (chapter.pyqCount > 0) ...[
            const SizedBox(height: 10),
            Text('PYQ Progress',
                style: theme.textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Row(
              children: List.generate(6, (i) {
                final active = i <= chapter.pyqProgress;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onPyqChange(i),
                    child: Container(
                      height: 22,
                      margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF9C27B0)
                            : (isDark
                                ? DarkColors.outline
                                : LightColors.outline),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: i == chapter.pyqProgress
                          ? Center(
                              child: Text(
                                _pyqEmojis[i],
                                style: const TextStyle(fontSize: 9),
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 2),
            Text(chapter.pyqProgressLabel,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9C27B0))),
          ],
        ],
      ),
    );
  }
}

// ─── Helper widgets ────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;

  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SubjectChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? LightColors.primary
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : null)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('📖', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('No chapters match your filters',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }
}
