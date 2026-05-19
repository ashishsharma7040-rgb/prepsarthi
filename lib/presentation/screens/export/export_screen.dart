// lib/presentation/screens/export/export_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/local/isar/schemas/study_log_schema.dart';
import '../../../data/repositories/export_repository.dart';
import '../../providers/all_providers.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _isGenerating = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? DarkColors.primary : LightColors.primary;
    final summary = ref.watch(dashboardSummaryProvider);
    final auth = ref.watch(authProvider);
    final planState = ref.watch(planProvider);
    final logs = ref.watch(studyLogProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverAppBar(
              title: Text('Export Progress'),
              pinned: true,
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── Preview Card ──────────────────────────────────────────
                  _PDFPreviewCard(
                    name: auth.user?.displayName ?? 'Aspirant',
                    targetExam: auth.user?.targetExam ?? 'JEE',
                    overallProgress: summary.overallProgress,
                    daysToExam: summary.daysToExam,
                    streak: summary.streak,
                    totalHours: summary.totalHoursLogged,
                    isDark: isDark,
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

                  const SizedBox(height: 28),

                  // ── What's included ───────────────────────────────────────
                  Text('What\'s included', style: theme.textTheme.headlineSmall)
                      .animate(delay: 100.ms).fadeIn(),
                  const SizedBox(height: 12),

                  ..._included.asMap().entries.map((e) =>
                    _IncludedRow(emoji: e.value.$1, text: e.value.$2, isDark: isDark)
                        .animate(delay: (120 + e.key * 60).ms).fadeIn().slideX(begin: -0.1),
                  ),

                  const SizedBox(height: 28),

                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: LightColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: LightColors.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: LightColors.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_error!,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: LightColors.error)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── Export Buttons ────────────────────────────────────────
                  FilledButton.icon(
                    onPressed: _isGenerating ? null : () => _export(
                      context, auth, planState, logs, summary,
                    ),
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.picture_as_pdf_rounded),
                    label: Text(_isGenerating
                        ? 'Generating PDF...'
                        : 'Generate & Share PDF'),
                  ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _isGenerating ? null : () => _preview(
                      context, auth, planState, logs, summary,
                    ),
                    icon: const Icon(Icons.preview_rounded),
                    label: const Text('Preview PDF'),
                  ).animate(delay: 460.ms).fadeIn(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context, AuthState auth,
      PlanState planState, List<StudyLogSchema> logs, DashboardSummary summary) async {
    setState(() { _isGenerating = true; _error = null; });
    try {
      final pdf = await ExportRepository.generateProgressReport(
        name: auth.user?.displayName ?? 'Aspirant',
        targetExam: auth.user?.targetExam ?? 'jee_main',
        examDate: auth.user?.examDate ?? DateTime.now().add(const Duration(days: 365)),
        chapters: planState.chapters,
        logs: logs,
        summary: summary,
      );
      await Printing.sharePdf(
        bytes: pdf,
        filename: 'PrepSarthi_Progress_${DateTime.now().day}_${DateTime.now().month}.pdf',
      );
    } catch (e) {
      setState(() => _error = 'Failed to generate PDF: $e');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _preview(BuildContext context, AuthState auth,
      PlanState planState, List<StudyLogSchema> logs, DashboardSummary summary) async {
    setState(() { _isGenerating = true; _error = null; });
    try {
      final pdf = await ExportRepository.generateProgressReport(
        name: auth.user?.displayName ?? 'Aspirant',
        targetExam: auth.user?.targetExam ?? 'jee_main',
        examDate: auth.user?.examDate ?? DateTime.now().add(const Duration(days: 365)),
        chapters: planState.chapters,
        logs: logs,
        summary: summary,
      );
      if (context.mounted) {
        await Navigator.push(context, MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('PDF Preview')),
            body: PdfPreview(build: (_) async => pdf),
          ),
        ));
      }
    } catch (e) {
      setState(() => _error = 'Preview failed: $e');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  static const _included = [
    ('👤', 'Student name, target exam & exam date'),
    ('📊', 'Overall weighted completion percentage'),
    ('📚', 'Subject-wise breakdown with chapter status'),
    ('⏱️', 'Total hours studied per subject'),
    ('🔄', 'Revision completion rate'),
    ('🔥', 'Current streak and total study days'),
    ('🏆', 'Unlocked achievements'),
    ('💬', 'Motivational message from your coach'),
  ];
}

class _PDFPreviewCard extends StatelessWidget {
  final String name, targetExam;
  final double overallProgress;
  final int daysToExam, streak;
  final double totalHours;
  final bool isDark;

  const _PDFPreviewCard({
    required this.name,
    required this.targetExam,
    required this.overallProgress,
    required this.daysToExam,
    required this.streak,
    required this.totalHours,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C4B4), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C4B4).withOpacity(0.3),
            blurRadius: 20, offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌟', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PrepSarthi',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800,
                      )),
                  Text('Progress Report',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.white70)),
                ],
              ),
              const Spacer(),
              Text(
                '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.3), thickness: 0.5),
          const SizedBox(height: 16),

          Text(name,
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white, fontWeight: FontWeight.w800,
              )),
          Text(
            targetExam.replaceAll('_', ' ').toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(color: Colors.white70),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              _PreviewStat('${(overallProgress * 100).round()}%',
                  'Complete', Colors.white),
              const SizedBox(width: 24),
              _PreviewStat('$daysToExam', 'Days Left', Colors.white),
              const SizedBox(width: 24),
              _PreviewStat('$streak', 'Day Streak', Colors.white),
              const SizedBox(width: 24),
              _PreviewStat('${totalHours.round()}h', 'Studied', Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _PreviewStat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w800, color: color,
        )),
        Text(label, style: TextStyle(
          fontSize: 11, color: color.withOpacity(0.7),
        )),
      ],
    );
  }
}

class _IncludedRow extends StatelessWidget {
  final String emoji, text;
  final bool isDark;
  const _IncludedRow({required this.emoji, required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
