// lib/presentation/screens/past_papers/past_papers_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/all_providers.dart';

// ─── Data model for a PYQ paper entry ─────────────────────────────────────────
class PYQPaper {
  final String id;
  final String exam;       // 'JEE Main' | 'JEE Advanced' | 'NEET UG'
  final int year;
  final String session;    // 'Jan' | 'Apr' | 'Paper 1' | ''
  final String subject;    // 'All' | 'Physics' | 'Chemistry' | 'Maths' | 'Biology'
  final int questionCount;
  final bool isPracticed;

  const PYQPaper({
    required this.id,
    required this.exam,
    required this.year,
    required this.session,
    required this.subject,
    required this.questionCount,
    this.isPracticed = false,
  });

  PYQPaper copyWith({bool? isPracticed}) =>
      PYQPaper(
        id: id, exam: exam, year: year, session: session,
        subject: subject, questionCount: questionCount,
        isPracticed: isPracticed ?? this.isPracticed,
      );
}

// ─── Provider ─────────────────────────────────────────────────────────────────
class PYQNotifier extends Notifier<List<PYQPaper>> {
  @override
  List<PYQPaper> build() => _generatePapers();

  void markPracticed(String paperId) {
    state = state
        .map((p) => p.id == paperId ? p.copyWith(isPracticed: true) : p)
        .toList();
    final paper = state.firstWhere((p) => p.id == paperId);
    double hours;
    switch (paper.exam) {
      case 'NEET UG':
        hours = 3.5;
        break;
      case 'JEE Advanced':
        hours = 3.0;
        break;
      case 'JEE Main':
      default:
        hours = 3.0;
    }
    // Also log as a PYQ session
    ref.read(studyLogProvider.notifier).logSession(
      chapterName: 'PYQ Session',
      subjectName: paper.subject,
      hours: hours,
      activityTag: 'pyq',
    );
  }

  List<PYQPaper> _generatePapers() {
    final papers = <PYQPaper>[];
    int id = 0;

    // JEE Main 2016–2025 (2 sessions per year from 2019)
    for (int yr = 2016; yr <= 2025; yr++) {
      final sessions = yr >= 2019
          ? ['Jan', 'Apr']
          : [''];
      for (final sess in sessions) {
        papers.add(PYQPaper(
          id: 'jee_main_${yr}_$sess',
          exam: 'JEE Main',
          year: yr,
          session: sess,
          subject: 'All',
          questionCount: 90,
        ));
      }
      id++;
    }

    // JEE Advanced 2016–2025
    for (int yr = 2016; yr <= 2025; yr++) {
      for (final paper in ['Paper 1', 'Paper 2']) {
        papers.add(PYQPaper(
          id: 'jee_adv_${yr}_$paper',
          exam: 'JEE Advanced',
          year: yr,
          session: paper,
          subject: 'All',
          questionCount: 54,
        ));
      }
    }

    // NEET UG 2016–2025
    for (int yr = 2016; yr <= 2025; yr++) {
      papers.add(PYQPaper(
        id: 'neet_${yr}',
        exam: 'NEET UG',
        year: yr,
        session: '',
        subject: 'All',
        questionCount: 180,
      ));
    }

    return papers;
  }
}

final pyqProvider = NotifierProvider<PYQNotifier, List<PYQPaper>>(PYQNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class PastPapersScreen extends ConsumerStatefulWidget {
  const PastPapersScreen({super.key});

  @override
  ConsumerState<PastPapersScreen> createState() => _PastPapersScreenState();
}

class _PastPapersScreenState extends ConsumerState<PastPapersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<String> _tabLabels = const [];
  String _selectedFilter = 'All';

  List<String> _examsForTarget(String? targetExam) {
    switch (targetExam) {
      case 'neet':
        return ['All', 'NEET UG'];
      case 'jee_advanced':
        return ['All', 'JEE Main', 'JEE Advanced'];
      case 'both':
        return ['All', 'JEE Main', 'NEET UG'];
      case 'class12_boards':
        return ['All', 'JEE Main'];
      case 'jee_main':
      default:
        return ['All', 'JEE Main'];
    }
  }

  bool _sameTabs(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _handleTabChange() {
    if (_tabController.index >= _tabLabels.length) return;
    final nextFilter = _tabLabels[_tabController.index];
    if (_selectedFilter != nextFilter) {
      setState(() => _selectedFilter = nextFilter);
    }
  }

  void _configureTabs(List<String> exams) {
    final previousFilter = _selectedFilter;
    final initialIndex = exams.indexOf(previousFilter) >= 0
        ? exams.indexOf(previousFilter)
        : 0;

    if (_tabLabels.isNotEmpty) {
      _tabController.removeListener(_handleTabChange);
      _tabController.dispose();
    }

    _tabLabels = List<String>.from(exams);
    _selectedFilter = _tabLabels[initialIndex];
    _tabController = TabController(
      length: _tabLabels.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void initState() {
    super.initState();
    _configureTabs(_examsForTarget(ref.read(authProvider).user?.targetExam));
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? DarkColors.primary : LightColors.primary;
    final papers = ref.watch(pyqProvider);
    final auth = ref.watch(authProvider);
    final exams = _examsForTarget(auth.user?.targetExam);

    if (!_sameTabs(_tabLabels, exams)) {
      _configureTabs(exams);
    }

    final relevantPapers =
        papers.where((p) => exams.contains(p.exam)).toList();

    final filtered = _selectedFilter == 'All'
        ? relevantPapers
        : relevantPapers.where((p) => p.exam == _selectedFilter).toList();

    // Group by year descending
    final grouped = <int, List<PYQPaper>>{};
    for (final p in filtered) {
      grouped.putIfAbsent(p.year, () => []).add(p);
    }
    final years = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final practicedCount = relevantPapers.where((p) => p.isPracticed).length;
    final totalCount = relevantPapers.length;
    final completionPct =
        totalCount == 0 ? 0 : (practicedCount / totalCount * 100).round();
    final practicedHours = relevantPapers
        .where((p) => p.isPracticed)
        .fold<double>(0, (sum, paper) {
      switch (paper.exam) {
        case 'NEET UG':
          return sum + 3.5;
        case 'JEE Advanced':
          return sum + 3.0;
        case 'JEE Main':
        default:
          return sum + 3.0;
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Past Papers', style: theme.textTheme.headlineLarge),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Stats bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _StatChip('📝', '$practicedCount/$totalCount', 'Papers Done', accent),
                        const SizedBox(width: 16),
                        _StatChip('🎯', '$completionPct%', 'Completion', accent),
                        const Spacer(),
                        if (practicedCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: LightColors.learned.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('${practicedHours.toStringAsFixed(0)}h practiced',
                                style: theme.textTheme.labelSmall
                                    ?.copyWith(color: LightColors.learned)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Tab bar ───────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              decoration: BoxDecoration(
                color: isDark ? DarkColors.surfaceVariant : LightColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                padding: const EdgeInsets.all(4),
                indicator: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: isDark
                    ? DarkColors.onSurfaceVariant
                    : LightColors.onSurfaceVariant,
                labelStyle: theme.textTheme.labelMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
                unselectedLabelStyle: theme.textTheme.labelMedium,
                dividerColor: Colors.transparent,
                tabs: _tabLabels.map((e) => Tab(text: e)).toList(),
              ),
            ),

            const SizedBox(height: 8),

            // ── Papers list ───────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('📭', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text('No papers found',
                              style: theme.textTheme.titleMedium),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: years.length,
                      itemBuilder: (context, yi) {
                        final year = years[yi];
                        final yearPapers = grouped[year]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Year header
                            Padding(
                              padding: const EdgeInsets.only(top: 20, bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: accent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$year',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: accent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${yearPapers.where((p) => p.isPracticed).length}'
                                    '/${yearPapers.length} done',
                                    style: theme.textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                            // Papers for this year
                            ...yearPapers.asMap().entries.map((e) =>
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _PaperCard(
                                  paper: e.value,
                                  isDark: isDark,
                                  onMarkPracticed: () =>
                                      ref.read(pyqProvider.notifier)
                                          .markPracticed(e.value.id),
                                ).animate(
                                  delay: (yi * 40 + e.key * 30).ms,
                                ).fadeIn().slideX(begin: 0.05),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Paper Card
// ─────────────────────────────────────────────────────────────────────────────
class _PaperCard extends StatelessWidget {
  final PYQPaper paper;
  final bool isDark;
  final VoidCallback onMarkPracticed;

  const _PaperCard({
    required this.paper,
    required this.isDark,
    required this.onMarkPracticed,
  });

  (String, Color) _examInfo() {
    switch (paper.exam) {
      case 'JEE Main':
        return ('📐', isDark ? DarkColors.mathematics : LightColors.mathematics);
      case 'JEE Advanced':
        return ('🏆', isDark ? DarkColors.physics : LightColors.physics);
      case 'NEET UG':
        return ('🩺', isDark ? DarkColors.biology : LightColors.biology);
      default:
        return ('📝', isDark ? DarkColors.primary : LightColors.primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (examEmoji, examColor) = _examInfo();

    return Container(
      decoration: BoxDecoration(
        color: paper.isPracticed
            ? LightColors.learned.withOpacity(isDark ? 0.06 : 0.04)
            : (isDark ? DarkColors.surfaceCard : LightColors.surface),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: paper.isPracticed
              ? LightColors.learned.withOpacity(0.3)
              : (isDark ? DarkColors.outline : LightColors.outline),
          width: paper.isPracticed ? 1.5 : 0.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: examColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(examEmoji, style: const TextStyle(fontSize: 22)),
          ),
        ),
        title: Text(
          '${paper.exam}${paper.session.isEmpty ? '' : ' – ${paper.session}'} ${paper.year}',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: paper.isPracticed ? TextDecoration.none : null,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: examColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${paper.questionCount} Qs',
                style: theme.textTheme.labelSmall?.copyWith(color: examColor),
              ),
            ),
            if (paper.isPracticed) ...[
              const SizedBox(width: 8),
              Text(
                '✅ Practiced',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: LightColors.learned),
              ),
            ],
          ],
        ),
        trailing: paper.isPracticed
            ? const Icon(Icons.check_circle_rounded,
                color: LightColors.learned, size: 26)
            : FilledButton(
                onPressed: onMarkPracticed,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(80, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  backgroundColor: examColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Mark Done',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String emoji, value, label;
  final Color color;

  const _StatChip(this.emoji, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: color,
                )),
            Text(label,
                style: TextStyle(
                  fontSize: 10, color: color.withOpacity(0.7),
                )),
          ],
        ),
      ],
    );
  }
}
