// lib/presentation/screens/onboarding/generating_plan_screen.dart
//
// FIXED: _generate() now calls SyllabusLoader.ensureLoadedForExam() FIRST,
// then refreshes planProvider chapters BEFORE running the planner.
// This guarantees CA Final / Board / NEET syllabus is in the DB regardless
// of what was loaded at startup (the root cause of the stream mixup bug).

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/local/preload/syllabus_loader.dart';
import '../../../router/app_router.dart';
import '../../providers/all_providers.dart';
import '../../../domain/usecases/generate_plan_usecase.dart';

class GeneratingPlanScreen extends ConsumerStatefulWidget {
  const GeneratingPlanScreen({super.key});
  @override
  ConsumerState<GeneratingPlanScreen> createState() =>
      _GeneratingPlanScreenState();
}

class _GeneratingPlanScreenState extends ConsumerState<GeneratingPlanScreen> {
  DateTime? _syllabusTargetDate;
  String _paceMode = 'balanced';
  Map<String, double> _weakBoosts = {};
  bool _isGenerating = false;
  bool _showAdvanced = false;
  String? _error;
  String _statusMessage = '';

  List<String> _detectWeakSubjects() {
    final chapters = ref.read(planProvider).chapters;
    if (chapters.isEmpty) return [];
    final weak = WeaknessDetectorUseCase.detectWeakChapters(chapters, topN: 8);
    return weak.map((c) => c.subjectName).toSet().toList();
  }

  @override
  void initState() {
    super.initState();
    final ob = ref.read(onboardingProvider);
    final exam = ob.examDate ?? DateTime.now().add(const Duration(days: 180));
    final daysLeft = exam.difference(DateTime.now()).inDays;

    final buffer = daysLeft > 120 ? 28 : daysLeft > 60 ? 21 : 14;
    _syllabusTargetDate = exam.subtract(Duration(days: buffer));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weak = _detectWeakSubjects();
      setState(() {
        for (final s in weak.take(3)) {
          _weakBoosts[s] = 1.40;
        }
      });
    });
  }

  // ── THE CORE FIX ─────────────────────────────────────────────────────────
  // Step 1: Ensure the target exam's syllabus is in Isar (per-source check).
  // Step 2: Refresh planProvider so state.chapters reflects the right exam.
  // Step 3: THEN generate the plan.
  Future<void> _generate() async {
    setState(() {
      _isGenerating = true;
      _error = null;
      _statusMessage = 'Loading syllabus…';
    });

    final ob = ref.read(onboardingProvider);
    final targetExam = ob.targetExam ?? 'jee_main';

    try {
      // ── Step 1: Save user profile ────────────────────────────────────────
      await ref.read(authProvider.notifier).updateOnboarding(
            targetExam: targetExam,
            examYear: ob.examYear ?? '2027',
            dailyHours: ob.dailyHours,
            examDate: ob.examDate!,
            caAttempt: ob.caAttempt,
          );

      // ── Step 2: Guarantee the correct syllabus is in the DB ──────────────
      // This is the fix for the "CA Final shows Class 12 syllabus" bug.
      // loadIfNeeded() used to check total count (not per-source), so the
      // wrong syllabus could persist from a previous session.
      setState(() => _statusMessage = 'Verifying ${_examLabel(targetExam)} syllabus…');
      await SyllabusLoader.ensureLoadedForExam(targetExam);

      // ── Step 3: Refresh planProvider so chapters reflect the right exam ──
      setState(() => _statusMessage = 'Preparing chapter data…');
      await ref.read(planProvider.notifier).refresh();

      // ── Step 4: Generate the plan ────────────────────────────────────────
      setState(() => _statusMessage = 'Building your optimal plan…');
      await ref.read(planProvider.notifier).generatePlan(
            examDate: ob.examDate!,
            dailyHours: ob.dailyHours,
            blackoutDates: ob.blackoutDates,
            syllabusCompletionTargetDate: _syllabusTargetDate,
            paceMode: _paceMode,
            weakSubjectBoost: Map<String, double>.from(_weakBoosts),
          );

      if (mounted) context.go(AppRoutes.dashboard);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _friendlyError(e.toString());
          _isGenerating = false;
          _statusMessage = '';
        });
      }
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('No chapters')) {
      return 'Could not load syllabus chapters. Please check your internet connection and try again.';
    }
    if (raw.contains('Exam date must be')) {
      return 'Exam date appears to be in the past. Please go back and update it.';
    }
    return 'Something went wrong: $raw';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? DarkColors.primary : LightColors.primary;
    final ob = ref.watch(onboardingProvider);
    final planState = ref.watch(planProvider);

    final examDate = ob.examDate;
    if (examDate == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text('Missing exam details.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go(AppRoutes.dailyHours),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final daysToSyllabus = _syllabusTargetDate != null
        ? _syllabusTargetDate!.difference(DateTime.now()).inDays
        : 0;
    final total = planState.chapters.length;
    final completed = planState.chapters
        .where((c) => c.masteryLevel >= 7 || c.status == 'completed')
        .length;
    final inProgress = planState.chapters
        .where((c) =>
            c.hoursSpent > 0 && c.masteryLevel < 7 && c.status != 'completed')
        .length;
    final weakSubjects = _detectWeakSubjects();
    final examTypeLabel = _examLabel(ob.targetExam);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              title: const Text('Build Your Optimal Plan'),
              pinned: true,
              backgroundColor:
                  isDark ? DarkColors.surface : LightColors.background,
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Headline ──────────────────────────────────────────────
                  Text(
                    'Your personalised $examTypeLabel plan is ready to build.',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700, height: 1.3),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15),
                  const SizedBox(height: 6),
                  Text(
                    'Review the analysis below and fine-tune before generating.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? DarkColors.onSurfaceVariant
                          : LightColors.onSurfaceVariant,
                    ),
                  ).animate(delay: 100.ms).fadeIn(),
                  const SizedBox(height: 24),

                  // ── Summary card ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [DarkColors.primaryContainer, DarkColors.surface]
                            : [LightColors.primaryContainer, LightColors.surface],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accent.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Text('📊', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Text(
                            'Your Battle Plan Analysis',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ]),
                        const SizedBox(height: 16),
                        _InfoRow(icon: '🎯', label: 'Target Exam',
                            value: examTypeLabel, accent: accent),
                        _InfoRow(
                          icon: '📅',
                          label: 'Exam Date',
                          value: DateFormat('dd MMM yyyy').format(examDate),
                          accent: accent,
                        ),
                        _InfoRow(
                          icon: '⏱️',
                          label: 'Daily Study',
                          value: '${ob.dailyHours.toStringAsFixed(1)} hrs',
                          accent: accent,
                        ),
                        _InfoRow(
                          icon: '✅',
                          label: 'Already Mastered',
                          value: '$completed / $total chapters',
                          accent: accent,
                          highlight: completed > 0,
                        ),
                        if (inProgress > 0)
                          _InfoRow(
                            icon: '🔄',
                            label: 'In Progress',
                            value: '$inProgress chapters',
                            accent: accent,
                          ),
                        if (_syllabusTargetDate != null)
                          _InfoRow(
                            icon: '🏁',
                            label: 'Phase 1 Ends',
                            value:
                                '${DateFormat('dd MMM').format(_syllabusTargetDate!)} ($daysToSyllabus days)',
                            accent: accent,
                          ),
                        if (_weakBoosts.isNotEmpty)
                          _InfoRow(
                            icon: '🔥',
                            label: 'Auto-Boosted',
                            value: _weakBoosts.keys.take(2).join(', ') +
                                (_weakBoosts.length > 2 ? '…' : ''),
                            accent: accent,
                          ),
                      ],
                    ),
                  ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1),

                  const SizedBox(height: 28),

                  // ── Fine-tune ─────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fine-tune for best results',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () =>
                            setState(() => _showAdvanced = !_showAdvanced),
                        child: Text(_showAdvanced ? 'Less' : 'More options'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Syllabus Target Date ───────────────────────────────────
                  _SectionCard(
                    isDark: isDark,
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month_rounded,
                            color: accent, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Syllabus Completion Target',
                                style: theme.textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                _syllabusTargetDate != null
                                    ? DateFormat('EEEE, dd MMMM yyyy')
                                        .format(_syllabusTargetDate!)
                                    : 'Not set',
                                style:
                                    theme.textTheme.bodySmall?.copyWith(color: accent),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _syllabusTargetDate ??
                                  DateTime.now().add(const Duration(days: 90)),
                              firstDate:
                                  DateTime.now().add(const Duration(days: 7)),
                              lastDate:
                                  examDate.subtract(const Duration(days: 7)),
                            );
                            if (picked != null) {
                              setState(() => _syllabusTargetDate = picked);
                            }
                          },
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn(),

                  const SizedBox(height: 12),

                  // ── Pace Mode ─────────────────────────────────────────────
                  _SectionCard(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Study Pace',
                          style: theme.textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _paceDescription(_paceMode),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? DarkColors.onSurfaceVariant
                                : LightColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'relaxed',
                              label: Text('Relaxed'),
                              icon: Icon(Icons.spa_rounded, size: 16),
                            ),
                            ButtonSegment(
                              value: 'balanced',
                              label: Text('Balanced'),
                              icon: Icon(Icons.balance_rounded, size: 16),
                            ),
                            ButtonSegment(
                              value: 'aggressive',
                              label: Text('Intensive'),
                              icon: Icon(Icons.rocket_launch_rounded, size: 16),
                            ),
                          ],
                          selected: {_paceMode},
                          onSelectionChanged: (s) =>
                              setState(() => _paceMode = s.first),
                        ),
                      ],
                    ),
                  ).animate(delay: 250.ms).fadeIn(),

                  // ── Weak Area Boosts ──────────────────────────────────────
                  if (_showAdvanced || _weakBoosts.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _SectionCard(
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Text('🔥', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              'Boost Weak Subjects',
                              style: theme.textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ]),
                          const SizedBox(height: 4),
                          Text(
                            'Selected subjects get more time allocated in the plan.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? DarkColors.onSurfaceVariant
                                  : LightColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          weakSubjects.isEmpty
                              ? Text(
                                  'No weak subjects detected yet.',
                                  style: theme.textTheme.bodySmall,
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: weakSubjects.map((s) {
                                    final boosted = _weakBoosts.containsKey(s);
                                    return FilterChip(
                                      label: Text(s),
                                      selected: boosted,
                                      selectedColor: accent.withOpacity(0.15),
                                      checkmarkColor: accent,
                                      side: BorderSide(
                                        color: boosted
                                            ? accent
                                            : (isDark
                                                ? DarkColors.outline
                                                : LightColors.outline),
                                      ),
                                      onSelected: (sel) => setState(() {
                                        sel
                                            ? _weakBoosts[s] = 1.40
                                            : _weakBoosts.remove(s);
                                      }),
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),
                    ).animate(delay: 300.ms).fadeIn(),
                  ],

                  // ── What will be generated ────────────────────────────────
                  if (_showAdvanced) ...[
                    const SizedBox(height: 12),
                    _SectionCard(
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📋 Your plan will include:',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          for (final item in _planFeatures(ob.targetExam))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.$1,
                                      style: const TextStyle(fontSize: 15)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(item.$2,
                                        style: theme.textTheme.bodySmall),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ).animate(delay: 350.ms).fadeIn(),
                  ],

                  // ── Error ─────────────────────────────────────────────────
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: LightColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: LightColors.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: LightColors.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: LightColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // ── Generate Button ───────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: _isGenerating ? null : _generate,
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome_rounded),
                      label: Text(
                        _isGenerating
                            ? _statusMessage
                            : '🚀 Build My Best Personalised Plan',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),

                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Typically takes 2–5 seconds',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? DarkColors.onSurfaceVariant
                            : LightColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _examLabel(String? exam) {
    switch (exam) {
      case 'jee_main':       return 'JEE Main';
      case 'jee_advanced':   return 'JEE Advanced';
      case 'neet':           return 'NEET UG';
      case 'ca_final':       return 'CA Final';
      case 'class12_boards': return 'Class 12 Boards';
      case 'both':           return 'JEE + NEET';
      default:               return 'Exam';
    }
  }

  String _paceDescription(String pace) {
    switch (pace) {
      case 'relaxed':    return 'Fewer hours per session, more buffer days. Good for long timelines.';
      case 'aggressive': return 'Maximum utilization. Best for short timelines or high motivation.';
      default:           return 'Balanced effort — sustainable for most students.';
    }
  }

  List<(String, String)> _planFeatures(String? exam) {
    final base = [
      ('📚', 'Chapter sessions with daily hour limits'),
      ('🔄', 'Spaced revision at 7, 21 & 45 days after learning'),
      ('📅', 'Buffer days every week for catch-up'),
      ('✏️', 'Fully editable — change date, hours, order anytime'),
    ];
    if (exam == 'ca_final') {
      return [
        ...base,
        ('🧪', 'Paper-specific mock tests every Sunday'),
        ('📋', 'IBS Integrated Case Study mocks (fortnightly)'),
        ('🏁', 'Phase 2 full paper mocks + rapid revision days'),
      ];
    }
    if (exam == 'neet') {
      return [
        ...base,
        ('🩺', 'NEET-style 3.5h mock tests from week 4'),
        ('🌿', 'Biology gets 2× allocation (360 vs 180 marks)'),
      ];
    }
    if (exam == 'class12_boards') {
      return [
        ...base,
        ('📝', 'Board pre-tests for each subject'),
        ('📖', 'Heavier revision phase (5 weeks) before exam'),
      ];
    }
    return [
      ...base,
      ('🧪', 'Subject mock tests every Sunday from week 3'),
      ('⚡', 'PYQ Marathon days in final 4 weeks'),
    ];
  }
}

// ── Supporting widgets ─────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String icon, label, value;
  final Color accent;
  final bool highlight;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: highlight ? LightColors.learned : null,
                ),
          ),
        ]),
      );
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _SectionCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surfaceCard : LightColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? DarkColors.outline : LightColors.outline,
            width: 0.5,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: child,
      );
}
