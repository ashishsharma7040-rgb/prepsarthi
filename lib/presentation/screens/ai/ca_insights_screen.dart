// lib/presentation/screens/ai/ca_insights_screen.dart
//
// ✅ CA Final AI Insights — "Most Important Topics" feature
// Analyses past PYQ patterns across all 6 papers and pinpoints topics
// that appear repeatedly. Uses Gemini via the existing Vertex AI service
// to generate a ranked, attempt-specific importance report.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/remote/vertex/gemini_service.dart';
import '../../providers/all_providers.dart';
import '../../../domain/usecases/achievement_usecase.dart'; // WIRE-7

// GeminiService is used as a static class — no provider needed

// ─── Data Models ──────────────────────────────────────────────────────────────
class InsightTopic {
  final String subject;
  final String topic;
  final int timesAsked;
  final String importance; // 'critical' | 'high' | 'medium'
  final String tipForAttempt;
  final List<String> recentAttempts;

  const InsightTopic({
    required this.subject,
    required this.topic,
    required this.timesAsked,
    required this.importance,
    required this.tipForAttempt,
    required this.recentAttempts,
  });

  factory InsightTopic.fromJson(Map<String, dynamic> json) => InsightTopic(
    subject:        json['subject']       as String? ?? '',
    topic:          json['topic']         as String? ?? '',
    timesAsked:     json['timesAsked']    as int?    ?? 0,
    importance:     json['importance']    as String? ?? 'medium',
    tipForAttempt:  json['tip']           as String? ?? '',
    recentAttempts: List<String>.from(json['recentAttempts'] as List? ?? []),
  );
}

class InsightReport {
  final String attempt;
  final List<InsightTopic> topics;
  final String summary;
  final String generatedAt;

  const InsightReport({
    required this.attempt,
    required this.topics,
    required this.summary,
    required this.generatedAt,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class CaInsightsScreen extends ConsumerStatefulWidget {
  const CaInsightsScreen({super.key});

  @override
  ConsumerState<CaInsightsScreen> createState() => _CaInsightsScreenState();
}

class _CaInsightsScreenState extends ConsumerState<CaInsightsScreen> {
  InsightReport? _report;
  bool _loading = false;
  String? _error;
  String _selectedFilter = 'All Papers';
  // Populated in initState from the persisted user caAttempt + examYear.
  String _selectedAttempt = 'May 2026';
  // Attempt list: populated in initState via _buildAttemptList()
  List<String> _attempts = [];

  final List<String> _filters = [
    'All Papers',
    'Paper 1: FR',
    'Paper 2: AFM',
    'Paper 3: Audit',
    'Paper 4: DT',
    'Paper 5: IDT',
    'Paper 6: IBS',
  ];

  // ── Dynamic attempt list: ICAI holds CA Final in May & November every year.
  // We show the upcoming 4 attempts (next 2 years × 2 attempts each).
  List<String> _buildAttemptList() {
    final now = DateTime.now();
    final thisYear = now.year;
    final attempts = <String>[];
    for (int y = thisYear; y <= thisYear + 1; y++) {
      attempts.add('May $y');
      attempts.add('November $y');
    }
    return attempts;
  }

  @override
  void initState() {
    super.initState();
    _attempts = _buildAttemptList();
    // Pre-select the attempt that matches the student's saved onboarding choice.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authProvider);
      final user = auth.user;
      if (user != null && user.targetExam == 'ca_final') {
        final attempt = user.caAttempt ?? 'may';
        final year = user.examYear;
        final label = attempt == 'november'
            ? 'November $year'
            : 'May $year';
        setState(() => _selectedAttempt = label);
      }
      _generate();
    });
  }

  // ── Ask Gemini to analyse PYQ patterns for CA Final ─────────────────────
  Future<void> _generate() async {
    setState(() { _loading = true; _error = null; });

    // WIRE-8: the prompt previously had ZERO personal context — every student
    // got the same generic topic list. Now we inject days-to-exam, per-paper
    // progress and the weakest papers so tips are ranked for THIS student.
    final prompt = _buildPrompt(_selectedAttempt, _personalContext());

    try {
      final raw = await GeminiService.generateRaw(prompt);
      final cleaned = raw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final json = jsonDecode(cleaned) as Map<String, dynamic>;

      final topics = (json['topics'] as List)
          .map((t) => InsightTopic.fromJson(t as Map<String, dynamic>))
          .toList();

      topics.sort((a, b) => b.timesAsked.compareTo(a.timesAsked));

      // WIRE-7: CA Insights counts as an AI analysis → 'ai_report' badge.
      await AchievementUseCase.markAiReportGenerated();

      setState(() {
        _report = InsightReport(
          attempt: _selectedAttempt,
          topics: topics,
          summary: json['summary'] as String? ?? '',
          generatedAt: DateTime.now().toString().substring(0, 16),
        );
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // ── WIRE-8: personal study context block for the prompt ─────────────────
  // Built from the student's real data: exam date, per-paper progress
  // (hours-vs-estimate weighted), and the two weakest papers. Returns '' when
  // there isn't enough data, so the prompt degrades gracefully.
  String _personalContext() {
    final user = ref.read(authProvider).user;
    final chapters = ref.read(planProvider).chapters;
    if (user == null || chapters.isEmpty) return '';

    final daysLeft = user.examDate?.difference(DateTime.now()).inDays;

    // Per-paper (subject) progress 0–100.
    final byPaper = <String, List<double>>{};
    for (final c in chapters) {
      final p = c.estimatedHours > 0
          ? (c.hoursSpent / c.estimatedHours).clamp(0.0, 1.0)
          : (c.masteryLevel / 7.0).clamp(0.0, 1.0);
      byPaper.putIfAbsent(c.subjectName, () => []).add(p);
    }
    final paperPct = <String, int>{
      for (final e in byPaper.entries)
        e.key: ((e.value.reduce((a, b) => a + b) / e.value.length) * 100)
            .round(),
    };
    if (paperPct.isEmpty) return '';

    final sorted = paperPct.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final weakest = sorted.take(2).map((e) => e.key).join(', ');
    final progressLine = sorted.reversed
        .map((e) => '${e.key}: ${e.value}%')
        .join(' · ');

    return '''

STUDENT CONTEXT (personalise the ranking and tips for this student):
- ${daysLeft != null ? 'Days until exam: $daysLeft' : 'Exam date not set'}
- Paper-wise syllabus progress: $progressLine
- Weakest papers right now: $weakest
- For the weakest papers, prefer high-yield topics that can still be covered in the remaining time, and make tips remediation-focused.
- For strong papers, prefer rank-protecting topics (frequently asked, low prep cost).
''';
  }

  String _buildPrompt(String attempt, String personalContext) => '''
You are a CA Final examination expert with deep knowledge of ICAI question papers from 2018 to 2025.

Analyse the PYQ patterns for CA Final (New Scheme - NSET) for the upcoming $attempt attempt.
$personalContext

Return ONLY valid JSON (no markdown, no preamble) in this exact structure:
{
  "summary": "2-3 sentence overall insight about this attempt's focus areas",
  "topics": [
    {
      "subject": "Paper 1: Financial Reporting",
      "topic": "Ind AS 115 – Revenue Recognition (with specific steps)",
      "timesAsked": 8,
      "importance": "critical",
      "tip": "Focus on 5-step model and variable consideration. Always appears in Q1 or Q2.",
      "recentAttempts": ["May 2025", "Nov 2024", "May 2024"]
    }
  ]
}

Requirements:
- List exactly 20 topics spread across all 6 papers (Group I: FR, AFM, Audit; Group II: DT, IDT, IBS)
- importance must be one of: "critical" (asked 6+ times), "high" (3-5 times), "medium" (1-2 times)
- timesAsked = approximate count across last 8 attempts (2021-2025)
- tip must be exam-strategy specific and actionable (max 100 chars)
- recentAttempts = last 2-3 attempts where this topic appeared
- Focus on topics that are consistently tested and likely to recur in $attempt
- Include both conceptual and numerical topics
- For IBS topics: focus on integration of subjects across a case study (SFM application, tax integration, audit context), NOT standalone theory
- IBS is case-study based: tips should focus on approach/structure, not content memorisation

Distribute like: 4 FR topics, 3 AFM, 3 Audit, 4 DT, 3 IDT, 3 IBS
''';

  List<InsightTopic> get _filteredTopics {
    if (_report == null) return [];
    if (_selectedFilter == 'All Papers') return _report!.topics;
    final paperKey = _selectedFilter.split(': ').last;
    return _report!.topics
        .where((t) => t.subject.contains(paperKey))
        .toList();
  }

  Color _importanceColor(String importance) {
    switch (importance) {
      case 'critical': return const Color(0xFFE53935);
      case 'high':     return const Color(0xFFFF6F00);
      default:         return const Color(0xFF388E3C);
    }
  }

  IconData _importanceIcon(String importance) {
    switch (importance) {
      case 'critical': return Icons.local_fire_department_rounded;
      case 'high':     return Icons.trending_up_rounded;
      default:         return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? DarkColors.primary : LightColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Topic Insights'),
        actions: [
          if (!_loading)
            IconButton(
              onPressed: _generate,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh analysis',
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Header banner ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent.withOpacity(0.18), accent.withOpacity(0.06)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('High-Yield Topics',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800)),
                      Text('AI-analysed from CA Final PYQs 2018–2025',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? DarkColors.onSurfaceVariant
                                : LightColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 12),

          // ── Attempt selector ───────────────────────────────────────────
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _attempts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final a = _attempts[i];
                final sel = _selectedAttempt == a;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedAttempt = a);
                    _generate();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? accent : (isDark
                            ? DarkColors.outline
                            : LightColors.outline),
                      ),
                    ),
                    child: Text(a,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: sel
                              ? Colors.white
                              : (isDark
                                  ? DarkColors.onSurface
                                  : LightColors.onSurface),
                          fontWeight:
                              sel ? FontWeight.w700 : FontWeight.w500,
                        )),
                  ),
                );
              },
            ),
          ).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 8),

          // ── Paper filter chips ─────────────────────────────────────────
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final sel = _selectedFilter == f;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel
                          ? accent.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? accent : (isDark
                            ? DarkColors.outline
                            : LightColors.outline),
                        width: sel ? 1.5 : 0.5,
                      ),
                    ),
                    child: Text(f,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: sel ? accent : null,
                          fontWeight: sel ? FontWeight.w700 : null,
                        )),
                  ),
                );
              },
            ),
          ).animate(delay: 150.ms).fadeIn(),

          const SizedBox(height: 8),

          // ── Body ────────────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? _buildLoading(accent)
                : _error != null
                    ? _buildError(theme, isDark, accent)
                    : _report == null
                        ? const SizedBox()
                        : _buildReport(theme, isDark, accent),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(Color accent) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: accent),
        const SizedBox(height: 20),
        const Text('Analysing PYQs from 2018–2025…',
            style: TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        const Text('This takes 10–20 seconds',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    ),
  );

  Widget _buildError(ThemeData theme, bool isDark, Color accent) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('😵', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text('Could not generate insights', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(_error ?? '', style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _generate,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try Again'),
        ),
      ],
    ),
  );

  Widget _buildReport(ThemeData theme, bool isDark, Color accent) {
    final topics = _filteredTopics;
    final report = _report!;

    return CustomScrollView(
      slivers: [
        // Summary card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF1565C0).withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      report.summary,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),
        ),

        // Legend
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                _legendChip('🔴 Critical (6+)', const Color(0xFFE53935)),
                const SizedBox(width: 10),
                _legendChip('🟠 High (3–5)', const Color(0xFFFF6F00)),
                const SizedBox(width: 10),
                _legendChip('🟢 Medium (1–2)', const Color(0xFF388E3C)),
              ],
            ),
          ).animate(delay: 250.ms).fadeIn(),
        ),

        // Topic cards
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList.separated(
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: topics.length,
            itemBuilder: (_, i) {
              final t = topics[i];
              final impColor = _importanceColor(t.importance);
              final impIcon = _importanceIcon(t.importance);

              return _TopicCard(
                topic: t,
                index: i,
                impColor: impColor,
                impIcon: impIcon,
                isDark: isDark,
                theme: theme,
                accent: accent,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _legendChip(String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 10, height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 10)),
    ],
  );
}

// ─── Topic Card Widget ────────────────────────────────────────────────────────
class _TopicCard extends StatelessWidget {
  final InsightTopic topic;
  final int index;
  final Color impColor, accent;
  final IconData impIcon;
  final bool isDark;
  final ThemeData theme;

  const _TopicCard({
    required this.topic,
    required this.index,
    required this.impColor,
    required this.impIcon,
    required this.isDark,
    required this.theme,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surfaceCard : LightColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: impColor.withOpacity(0.25),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Rank badge
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: impColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: impColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  topic.topic,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Importance chip
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: impColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(impIcon, size: 11, color: impColor),
                    const SizedBox(width: 3),
                    Text(
                      '${topic.timesAsked}×',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: impColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Subject label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              topic.subject,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: accent),
            ),
          ),
          const SizedBox(height: 8),

          // Strategy tip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡 ', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Text(
                  topic.tipForAttempt,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ),
            ],
          ),

          // Recent attempts
          if (topic.recentAttempts.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: topic.recentAttempts
                  .map((a) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? Colors.white
                                  : Colors.black)
                              .withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(a,
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    ).animate(delay: (index * 50).ms).fadeIn().slideY(begin: 0.05);
  }
}
