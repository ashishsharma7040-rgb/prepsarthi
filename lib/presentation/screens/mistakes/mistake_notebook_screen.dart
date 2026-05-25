// lib/presentation/screens/mistakes/mistake_notebook_screen.dart
//
// ✅ TIER 1 MIGRATION: Reads/writes MistakeEntrySchema via Isar.
//    On first load, migrates existing SharedPreferences data to Isar, then clears it.
// ✅ UI: Identical to original — only the data layer changed.
// ✅ MistakeType enum and MistakeEntry Dart class are KEPT as local types
//    so the rest of the UI (type selector, filter chips, analytics tab) compiles
//    without changes. Isar schema uses mistakeTypeIndex (int) to map to/from enum.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/local/isar/isar_service.dart';
import '../../../data/local/isar/schemas/mistake_entry_schema.dart';
import '../../providers/all_providers.dart';

// ─── Legacy SharedPrefs migration key ────────────────────────────────────────

const _kLegacyMistakesKey    = 'prepsarthi_mistakes_v1';
const _kMigrationDoneKey     = 'prepsarthi_mistakes_migrated_v2';

// ─── Mistake types ────────────────────────────────────────────────────────────

enum MistakeType {
  conceptual('Conceptual', '🧠', 'Misunderstood the theory or concept'),
  calculation('Calculation', '🔢', 'Error in computation or arithmetic'),
  silly('Silly Mistake', '🤦', 'Careless error despite knowing the answer'),
  timePressure('Time Pressure', '⏱️', 'Rushed and made avoidable error'),
  forgotFormula('Forgot Formula', '📐', 'Could not recall required formula'),
  guesswork('Guesswork', '🎲', 'Answered without proper reasoning');

  const MistakeType(this.label, this.emoji, this.description);
  final String label;
  final String emoji;
  final String description;
}

// ── Helper: map MistakeType ↔ mistakeTypeIndex ────────────────────────────────
MistakeType _typeFromIndex(int i) {
  if (i < 0 || i >= MistakeType.values.length) return MistakeType.silly;
  return MistakeType.values[i];
}

int _indexFromType(MistakeType t) => MistakeType.values.indexOf(t);

// ─── Provider ─────────────────────────────────────────────────────────────────

class MistakeNotifier extends AsyncNotifier<List<MistakeEntrySchema>> {
  @override
  Future<List<MistakeEntrySchema>> build() async {
    await _migrateFromSharedPrefsIfNeeded();
    return _fetchAll();
  }

  // ── One-time migration from SharedPreferences → Isar ──────────────────────

  Future<void> _migrateFromSharedPrefsIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyMigrated = prefs.getBool(_kMigrationDoneKey) ?? false;
      if (alreadyMigrated) return;

      final raw = prefs.getStringList(_kLegacyMistakesKey) ?? [];
      if (raw.isNotEmpty) {
        final db = IsarService.db;
        final schemas = raw.map((s) {
          try {
            final j = jsonDecode(s) as Map<String, dynamic>;
            return MistakeEntrySchema.fromLegacyJson(j);
          } catch (_) {
            return null;
          }
        }).whereType<MistakeEntrySchema>().toList();

        if (schemas.isNotEmpty) {
          await db.writeTxn(() async {
            await db.mistakeEntrySchemas.putAll(schemas);
          });
        }
        await prefs.remove(_kLegacyMistakesKey);
      }

      await prefs.setBool(_kMigrationDoneKey, true);
    } catch (_) {
      // Non-fatal — user keeps old data or starts fresh
    }
  }

  // ── Isar CRUD ──────────────────────────────────────────────────────────────

  Future<List<MistakeEntrySchema>> _fetchAll() async {
    final db = IsarService.db;
    final all = await db.mistakeEntrySchemas.where().findAll();
    all.sort((a, b) => b.date.compareTo(a.date));
    return all;
  }

  Future<void> addEntry({
    required MistakeType type,
    required String chapterName,
    required String subjectName,
    required String questionSummary,
    required String correctApproach,
    String? testName,
  }) async {
    final schema = MistakeEntrySchema()
      ..date             = DateTime.now()
      ..mistakeTypeIndex = _indexFromType(type)
      ..chapterName      = chapterName
      ..subjectName      = subjectName
      ..questionSummary  = questionSummary
      ..correctApproach  = correctApproach
      ..isResolved       = false
      ..testName         = testName
      ..createdAt        = DateTime.now();

    final db = IsarService.db;
    await db.writeTxn(() => db.mistakeEntrySchemas.put(schema));
    state = AsyncData(await _fetchAll());
  }

  Future<void> toggleResolved(int id) async {
    final db      = IsarService.db;
    final current = await db.mistakeEntrySchemas.get(id);
    if (current == null) return;
    current.isResolved = !current.isResolved;
    current.resolvedAt = current.isResolved ? DateTime.now() : null;
    await db.writeTxn(() => db.mistakeEntrySchemas.put(current));
    state = AsyncData(await _fetchAll());
  }

  Future<void> deleteEntry(int id) async {
    final db = IsarService.db;
    await db.writeTxn(() => db.mistakeEntrySchemas.delete(id));
    state = AsyncData(await _fetchAll());
  }

  Map<MistakeType, int> byType(List<MistakeEntrySchema> entries) {
    final map = <MistakeType, int>{};
    for (final e in entries) {
      final t = _typeFromIndex(e.mistakeTypeIndex);
      map[t] = (map[t] ?? 0) + 1;
    }
    return map;
  }

  int unresolvedCount(List<MistakeEntrySchema> entries) =>
      entries.where((e) => !e.isResolved).length;
}

final mistakeProvider =
    AsyncNotifierProvider<MistakeNotifier, List<MistakeEntrySchema>>(
  MistakeNotifier.new,
);

// ─── Screen ───────────────────────────────────────────────────────────────────

class MistakeNotebookScreen extends ConsumerStatefulWidget {
  const MistakeNotebookScreen({super.key});

  @override
  ConsumerState<MistakeNotebookScreen> createState() =>
      _MistakeNotebookScreenState();
}

class _MistakeNotebookScreenState extends ConsumerState<MistakeNotebookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  MistakeType? _filterType;
  bool _showResolved = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final isDark  = theme.brightness == Brightness.dark;
    final mistakesAsync = ref.watch(mistakeProvider);
    final notifier      = ref.read(mistakeProvider.notifier);

    return mistakesAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Error: $e'))),
      data: (mistakes) {
        final filtered = mistakes.where((e) {
          if (!_showResolved && e.isResolved) return false;
          if (_filterType != null &&
              _typeFromIndex(e.mistakeTypeIndex) != _filterType) return false;
          return true;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Row(children: [
              const Text('📓 '),
              Text('Mistake Notebook',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ]),
            actions: [
              if (notifier.unresolvedCount(mistakes) > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text(
                        '${notifier.unresolvedCount(mistakes)} pending',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600)),
                    backgroundColor: LightColors.error.withOpacity(0.12),
                    labelStyle: const TextStyle(color: LightColors.error),
                    padding: EdgeInsets.zero,
                  ),
                ),
            ],
            bottom: TabBar(
              controller: _tab,
              tabs: const [
                Tab(text: 'All Mistakes'),
                Tab(text: 'Analytics'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tab,
            children: [
              _MistakeListTab(
                mistakes: filtered,
                isDark: isDark,
                filterType: _filterType,
                showResolved: _showResolved,
                onFilterType: (t) => setState(() => _filterType = t),
                onToggleResolved: () =>
                    setState(() => _showResolved = !_showResolved),
              ),
              _MistakeAnalyticsTab(
                  byType: notifier.byType(mistakes), isDark: isDark),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addMistake(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Log Mistake'),
            backgroundColor:
                isDark ? DarkColors.primary : LightColors.primary,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  Future<void> _addMistake(BuildContext context, WidgetRef ref) async {
    final planState = ref.read(planProvider);
    final chapters  = planState.chapters;

    MistakeType selectedType = MistakeType.silly;
    String chapterName =
        chapters.isNotEmpty ? chapters.first.name : '';
    String subjectName =
        chapters.isNotEmpty ? chapters.first.subjectName : '';
    final questionCtrl = TextEditingController();
    final approachCtrl = TextEditingController();
    final testCtrl     = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom:
                  MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Log a Mistake',
                    style: Theme.of(ctx)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),

                // Type selector
                Text('Type',
                    style: Theme.of(ctx).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MistakeType.values.map((t) {
                    final sel = selectedType == t;
                    return GestureDetector(
                      onTap: () =>
                          setModal(() => selectedType = t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel
                              ? LightColors.primary
                                  .withOpacity(0.15)
                              : Colors.transparent,
                          border: Border.all(
                            color: sel
                                ? LightColors.primary
                                : Colors.grey.shade300,
                          ),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${t.emoji} ${t.label}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: sel
                                ? FontWeight.w700
                                : FontWeight.normal,
                            color: sel
                                ? LightColors.primary
                                : null,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Chapter selector
                Text('Chapter',
                    style: Theme.of(ctx).textTheme.labelLarge),
                const SizedBox(height: 8),
                if (chapters.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: chapterName,
                    decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder()),
                    items: chapters
                        .map((c) => DropdownMenuItem(
                            value: c.name,
                            child: Text(
                              '${c.subjectName}: ${c.name}',
                              overflow: TextOverflow.ellipsis,
                            )))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      final c = chapters
                          .firstWhere((c) => c.name == v);
                      setModal(() {
                        chapterName = v;
                        subjectName = c.subjectName;
                      });
                    },
                  )
                else
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Chapter Name',
                        isDense: true,
                        border: OutlineInputBorder()),
                    onChanged: (v) => chapterName = v,
                  ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: questionCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'What went wrong? (brief)',
                      isDense: true,
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: approachCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Correct approach / reminder',
                      isDense: true,
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: testCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Test/Source (optional)',
                      isDense: true,
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (questionCtrl.text.trim().isEmpty) return;
                      ref
                          .read(mistakeProvider.notifier)
                          .addEntry(
                            type: selectedType,
                            chapterName: chapterName,
                            subjectName: subjectName,
                            questionSummary:
                                questionCtrl.text.trim(),
                            correctApproach:
                                approachCtrl.text.trim(),
                            testName: testCtrl.text
                                    .trim()
                                    .isEmpty
                                ? null
                                : testCtrl.text.trim(),
                          );
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save Mistake'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── List tab ─────────────────────────────────────────────────────────────────

class _MistakeListTab extends ConsumerWidget {
  final List<MistakeEntrySchema> mistakes;
  final bool isDark;
  final MistakeType? filterType;
  final bool showResolved;
  final ValueChanged<MistakeType?> onFilterType;
  final VoidCallback onToggleResolved;

  const _MistakeListTab({
    required this.mistakes,
    required this.isDark,
    required this.filterType,
    required this.showResolved,
    required this.onFilterType,
    required this.onToggleResolved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Filter row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                emoji: '📓',
                selected: filterType == null,
                onTap: () => onFilterType(null),
              ),
              ...MistakeType.values.map((t) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _FilterChip(
                      label: t.label,
                      emoji: t.emoji,
                      selected: filterType == t,
                      onTap: () => onFilterType(
                          filterType == t ? null : t),
                    ),
                  )),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onToggleResolved,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: showResolved
                        ? LightColors.learned.withOpacity(0.15)
                        : Colors.transparent,
                    border: Border.all(
                        color: showResolved
                            ? LightColors.learned
                            : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('✅ Resolved',
                      style: TextStyle(
                        fontSize: 12,
                        color: showResolved
                            ? LightColors.learned
                            : null,
                        fontWeight: showResolved
                            ? FontWeight.w700
                            : FontWeight.normal,
                      )),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: mistakes.isEmpty
              ? _EmptyState(isDark: isDark)
              : ListView.separated(
                  padding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: mistakes.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _MistakeCard(
                    entry: mistakes[i],
                    isDark: isDark,
                    onToggle: () => ref
                        .read(mistakeProvider.notifier)
                        .toggleResolved(mistakes[i].id),
                    onDelete: () => ref
                        .read(mistakeProvider.notifier)
                        .deleteEntry(mistakes[i].id),
                  )
                      .animate()
                      .fadeIn(delay: (i * 30).ms)
                      .slideY(begin: 0.05),
                ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label, emoji;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? LightColors.primary.withOpacity(0.15)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? LightColors.primary
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('$emoji $label',
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.normal,
              color: selected ? LightColors.primary : null,
            )),
      ),
    );
  }
}

class _MistakeCard extends StatelessWidget {
  final MistakeEntrySchema entry;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _MistakeCard({
    required this.entry,
    required this.isDark,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type  = _typeFromIndex(entry.mistakeTypeIndex);
    final accent = _typeColor(type);

    return Dismissible(
      key: Key(entry.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: LightColors.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline,
            color: LightColors.error),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : LightColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: entry.isResolved
                ? LightColors.learned.withOpacity(0.3)
                : accent.withOpacity(0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(entry.mistakeTypeEmoji,
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.mistakeTypeLabel,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w700)),
                      Text(
                        '${entry.subjectName} · ${entry.chapterName}',
                        style: theme.textTheme.labelSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: entry.isResolved
                          ? LightColors.learned.withOpacity(0.12)
                          : Colors.transparent,
                      border: Border.all(
                          color: entry.isResolved
                              ? LightColors.learned
                              : Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.isResolved ? '✅ Done' : 'Mark Done',
                      style: TextStyle(
                          fontSize: 11,
                          color: entry.isResolved
                              ? LightColors.learned
                              : null,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(entry.questionSummary,
                style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: entry.isResolved
                        ? TextDecoration.lineThrough
                        : null)),
            if (entry.correctApproach.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      LightColors.learned.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 ',
                        style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Text(entry.correctApproach,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(
                                  color: LightColors.learned,
                                  fontStyle: FontStyle.italic)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                    '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                    style: theme.textTheme.labelSmall),
                if (entry.testName != null) ...[
                  const Text(' · ',
                      style: TextStyle(fontSize: 11)),
                  Text(entry.testName!,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(
                              color: LightColors.primary)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(MistakeType t) {
    switch (t) {
      case MistakeType.conceptual:
        return const Color(0xFF6C63FF);
      case MistakeType.calculation:
        return const Color(0xFFFF6B6B);
      case MistakeType.silly:
        return const Color(0xFFFF9800);
      case MistakeType.timePressure:
        return const Color(0xFFE91E63);
      case MistakeType.forgotFormula:
        return const Color(0xFF00BCD4);
      case MistakeType.guesswork:
        return const Color(0xFF9C27B0);
    }
  }
}

// ─── Analytics tab ────────────────────────────────────────────────────────────

class _MistakeAnalyticsTab extends StatelessWidget {
  final Map<MistakeType, int> byType;
  final bool isDark;

  const _MistakeAnalyticsTab(
      {required this.byType, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = byType.values.fold<int>(0, (s, v) => s + v);

    if (total == 0) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📓', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('No mistakes logged yet',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Log your first mistake to see analytics',
                style: theme.textTheme.bodySmall),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _StatCard(
          title: 'Total Mistakes Logged',
          value: '$total',
          emoji: '📓',
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? DarkColors.surface : LightColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Breakdown by Type',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ...MistakeType.values.map((t) {
                final count = byType[t] ?? 0;
                final pct   = total > 0 ? count / total : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('${t.emoji} ',
                              style:
                                  const TextStyle(fontSize: 16)),
                          Expanded(
                              child: Text(t.label,
                                  style: theme
                                      .textTheme.bodyMedium)),
                          Text('$count',
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(
                                      fontWeight:
                                          FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 6,
                          backgroundColor: isDark
                              ? DarkColors.outline
                              : LightColors.outline,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                                  _typeColor(t)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LightColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: LightColors.primary.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('💡 What to focus on',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                _topAdvice(),
                style: theme.textTheme.bodySmall
                    ?.copyWith(height: 1.6),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  String _topAdvice() {
    final sorted = byType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.isEmpty) {
      return 'Keep logging mistakes to get personalised advice.';
    }
    switch (sorted.first.key) {
      case MistakeType.conceptual:
        return 'Your top mistake is conceptual. Re-read theory before solving problems. Create mind maps for complex concepts.';
      case MistakeType.calculation:
        return 'Calculation errors are your weakness. Practice mental maths daily and double-check units in every step.';
      case MistakeType.silly:
        return 'You make silly mistakes often. Slow down in the last 5 minutes of each test and re-read answers carefully.';
      case MistakeType.timePressure:
        return 'Time pressure is your problem. Improve speed by solving timed chapter tests. Attempt easy questions first in exams.';
      case MistakeType.forgotFormula:
        return 'You forget formulas often. Maintain a formula sheet and revise it every morning before studying.';
      case MistakeType.guesswork:
        return 'You guess too much. Skip uncertain questions first, come back later. Negative marking can reduce your score.';
    }
  }

  Color _typeColor(MistakeType t) {
    switch (t) {
      case MistakeType.conceptual:   return const Color(0xFF6C63FF);
      case MistakeType.calculation:  return const Color(0xFFFF6B6B);
      case MistakeType.silly:        return const Color(0xFFFF9800);
      case MistakeType.timePressure: return const Color(0xFFE91E63);
      case MistakeType.forgotFormula:return const Color(0xFF00BCD4);
      case MistakeType.guesswork:    return const Color(0xFF9C27B0);
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title, value, emoji;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.emoji,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              Text(title, style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📭', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('No mistakes here',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Log your first mistake to build a review library.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
