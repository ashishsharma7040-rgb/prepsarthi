// lib/presentation/screens/test_score/test_score_screen.dart
//
// Mock Test Score Tracker — tracks marks, subject breakdown, percentile estimate.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/all_providers.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class TestEntry {
  final String id;
  final DateTime date;
  final String testName;
  final String examType;
  final int totalMarks;
  final int obtained;
  final Map<String, int> subjectMarks;
  final Map<String, int> subjectMax;
  final String? notes;

  const TestEntry({
    required this.id, required this.date, required this.testName,
    required this.examType, required this.totalMarks, required this.obtained,
    required this.subjectMarks, required this.subjectMax, this.notes,
  });

  double get percentage => totalMarks > 0 ? obtained / totalMarks * 100 : 0;

  Map<String, dynamic> toJson() => {
    'id': id, 'date': date.toIso8601String(), 'testName': testName,
    'examType': examType, 'totalMarks': totalMarks, 'obtained': obtained,
    'subjectMarks': subjectMarks, 'subjectMax': subjectMax, 'notes': notes,
  };

  factory TestEntry.fromJson(Map<String, dynamic> j) => TestEntry(
    id: j['id'] as String, date: DateTime.parse(j['date'] as String),
    testName: j['testName'] as String, examType: j['examType'] as String,
    totalMarks: j['totalMarks'] as int, obtained: j['obtained'] as int,
    subjectMarks: Map<String, int>.from(j['subjectMarks'] as Map),
    subjectMax: Map<String, int>.from(j['subjectMax'] as Map),
    notes: j['notes'] as String?,
  );
}

// ─── Provider ─────────────────────────────────────────────────────────────────

class TestScoreNotifier extends Notifier<List<TestEntry>> {
  static const _key = 'prepsarthi_test_scores_v1';

  @override
  List<TestEntry> build() { _load(); return []; }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? [];
      state = raw
          .map((s) => TestEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList()..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) { state = []; }
  }

  Future<void> addEntry(TestEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = [entry, ...state];
    await prefs.setStringList(_key, updated.map((e) => jsonEncode(e.toJson())).toList());
    state = updated;
  }

  Future<void> deleteEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = state.where((e) => e.id != id).toList();
    await prefs.setStringList(_key, updated.map((e) => jsonEncode(e.toJson())).toList());
    state = updated;
  }

  double get averagePercentage {
    if (state.isEmpty) return 0;
    return state.fold(0.0, (s, e) => s + e.percentage) / state.length;
  }

  Map<String, double> get subjectAverages {
    final sums = <String, double>{};
    final counts = <String, int>{};
    for (final e in state) {
      for (final sub in e.subjectMarks.entries) {
        final max = (e.subjectMax[sub.key] ?? 100).toDouble();
        final pct = max > 0 ? sub.value / max * 100 : 0.0;
        sums[sub.key] = (sums[sub.key] ?? 0) + pct;
        counts[sub.key] = (counts[sub.key] ?? 0) + 1;
      }
    }
    return {for (final k in sums.keys) k: sums[k]! / counts[k]!};
  }

  String estimatePercentile(double pct, String examType) {
    if (examType == 'NEET') {
      if (pct >= 95) return '≈ 99+ percentile';
      if (pct >= 85) return '≈ 95-99 percentile';
      if (pct >= 70) return '≈ 85-95 percentile';
      if (pct >= 55) return '≈ 70-85 percentile';
      return '< 70 percentile';
    }
    if (pct >= 95) return '≈ 99.5+ percentile';
    if (pct >= 85) return '≈ 97-99 percentile';
    if (pct >= 70) return '≈ 90-97 percentile';
    if (pct >= 55) return '≈ 75-90 percentile';
    return '< 75 percentile';
  }
}

final testScoreProvider = NotifierProvider<TestScoreNotifier, List<TestEntry>>(TestScoreNotifier.new);

// ─── Screen ───────────────────────────────────────────────────────────────────

class TestScoreScreen extends ConsumerWidget {
  const TestScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scores = ref.watch(testScoreProvider);
    final notifier = ref.read(testScoreProvider.notifier);
    final auth = ref.watch(authProvider);
    final exam = auth.user?.targetExam ?? 'jee_main';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              title: const Text('Mock Test Scores'),
              pinned: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () => _showAddSheet(context, ref, exam),
                ),
              ],
            ),
            if (scores.isEmpty)
              SliverFillRemaining(child: _EmptyState(onAdd: () => _showAddSheet(context, ref, exam)))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _SummaryCard(notifier: notifier, scores: scores, isDark: isDark)
                        .animate().fadeIn(),
                    const SizedBox(height: 16),
                    if (notifier.subjectAverages.isNotEmpty) ...[
                      Text('Subject Averages',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _SubjectBar(averages: notifier.subjectAverages, isDark: isDark)
                          .animate(delay: 80.ms).fadeIn(),
                      const SizedBox(height: 16),
                    ],
                    Text('All Tests', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ...scores.asMap().entries.map((e) => _TestCard(
                      entry: e.value, isDark: isDark,
                      percentile: notifier.estimatePercentile(e.value.percentage, e.value.examType),
                      onDelete: () => notifier.deleteEntry(e.value.id),
                    ).animate(delay: (e.key * 40 + 100).ms).fadeIn()),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext ctx, WidgetRef ref, String exam) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddSheet(ref: ref, exam: exam),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final TestScoreNotifier notifier;
  final List<TestEntry> scores;
  final bool isDark;
  const _SummaryCard({required this.notifier, required this.scores, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avg = notifier.averagePercentage;
    final latest = scores.first;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? DarkColors.gradientPrimary : LightColors.gradientPrimary,
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Performance Overview', style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70)),
        const SizedBox(height: 12),
        Row(children: [
          _Metric('${avg.toStringAsFixed(1)}%', 'Avg Score'),
          _Metric(scores.length.toString(), 'Tests Taken'),
          _Metric('${latest.percentage.toStringAsFixed(1)}%', 'Latest'),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: avg / 100, minHeight: 8,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        Text(notifier.estimatePercentile(avg, latest.examType),
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.white70)),
      ]),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value, label;
  const _Metric(this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
  ]));
}

class _SubjectBar extends StatelessWidget {
  final Map<String, double> averages;
  final bool isDark;
  const _SubjectBar({required this.averages, required this.isDark});

  static const _palette = [Color(0xFF6366F1), Color(0xFF10B981), Color(0xFFF59E0B), Color(0xFFEF4444)];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? DarkColors.outline : LightColors.outline, width: 0.5),
      ),
      child: Column(children: averages.entries.toList().asMap().entries.map((e) {
        final color = _palette[e.key % _palette.length];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(e.value.key, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              Text('${e.value.value.toStringAsFixed(1)}%',
                  style: theme.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 4),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
              value: e.value.value / 100, minHeight: 6,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(color),
            )),
          ]),
        );
      }).toList()),
    );
  }
}

class _TestCard extends StatelessWidget {
  final TestEntry entry;
  final bool isDark;
  final String percentile;
  final VoidCallback onDelete;
  const _TestCard({required this.entry, required this.isDark, required this.percentile, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = entry.percentage;
    final color = pct >= 70 ? const Color(0xFF10B981) : pct >= 50 ? const Color(0xFFF59E0B) : LightColors.error;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? DarkColors.outline : LightColors.outline, width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text('${pct.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(entry.testName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${entry.examType} · ${entry.obtained}/${entry.totalMarks}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant)),
          Text(percentile, style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${entry.date.day}/${entry.date.month}', style: theme.textTheme.labelSmall),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: LightColors.error, onPressed: onDelete, padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ]),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('📊', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text('No Test Scores', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Track mock tests, analyse subject-wise performance and estimate percentile.',
            style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add_rounded), label: const Text('Add First Score')),
      ]),
    ));
  }
}

class _AddSheet extends StatefulWidget {
  final WidgetRef ref;
  final String exam;
  const _AddSheet({required this.ref, required this.exam});
  @override
  State<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<_AddSheet> {
  final _nameCtrl = TextEditingController();
  String _examType = 'Mock';
  late List<({String subject, int max, TextEditingController ctrl})> _subs;

  @override
  void initState() {
    super.initState();
    _examType = widget.exam.contains('neet') ? 'NEET' : 'JEE Main';
    _subs = _buildSubs(_examType);
  }

  List<({String subject, int max, TextEditingController ctrl})> _buildSubs(String t) {
    if (t == 'NEET') {
      return [
        (subject: 'Physics', max: 180, ctrl: TextEditingController()),
        (subject: 'Chemistry', max: 180, ctrl: TextEditingController()),
        (subject: 'Biology', max: 360, ctrl: TextEditingController()),
      ];
    }
    return [
      (subject: 'Physics', max: 100, ctrl: TextEditingController()),
      (subject: 'Chemistry', max: 100, ctrl: TextEditingController()),
      (subject: 'Mathematics', max: 100, ctrl: TextEditingController()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(
            color: isDark ? DarkColors.outline : LightColors.outline,
            borderRadius: BorderRadius.circular(2),
          ))),
          const SizedBox(height: 16),
          Text('Add Test Score', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(
            labelText: 'Test Name', hintText: 'e.g. Allen Phase Test 3', prefixIcon: Icon(Icons.quiz_rounded),
          )),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _examType,
            items: ['JEE Main', 'JEE Advanced', 'NEET', 'Mock', 'Other']
                .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() { _examType = v!; _subs = _buildSubs(_examType); }),
            decoration: const InputDecoration(labelText: 'Exam Type', prefixIcon: Icon(Icons.school_rounded)),
          ),
          const SizedBox(height: 16),
          Text('Subject Marks', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ..._subs.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(flex: 3, child: Text(s.subject, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
              SizedBox(width: 80, child: TextField(
                controller: s.ctrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '0',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              )),
              const SizedBox(width: 6),
              Text('/ ${s.max}', style: theme.textTheme.bodySmall),
            ]),
          )),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
            const SizedBox(width: 12),
            Expanded(child: FilledButton(onPressed: _save, child: const Text('Save'))),
          ]),
        ],
      )),
    );
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) return;
    int total = 0, obtained = 0;
    final marks = <String, int>{};
    final maxes = <String, int>{};
    for (final s in _subs) {
      final m = int.tryParse(s.ctrl.text) ?? 0;
      marks[s.subject] = m;
      maxes[s.subject] = s.max;
      total += s.max;
      obtained += m;
    }
    widget.ref.read(testScoreProvider.notifier).addEntry(TestEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(), testName: _nameCtrl.text.trim(), examType: _examType,
      totalMarks: total, obtained: obtained, subjectMarks: marks, subjectMax: maxes,
    ));
    Navigator.pop(context);
  }
}
