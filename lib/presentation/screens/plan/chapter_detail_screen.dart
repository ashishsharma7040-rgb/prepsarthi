// lib/presentation/screens/plan/chapter_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/local/isar/schemas/schemas.dart';
import '../../../data/remote/vertex/gemini_service.dart';
import '../../providers/all_providers.dart';
import '../../../router/app_router.dart';

class ChapterDetailScreen extends ConsumerStatefulWidget {
  final String chapterName;
  const ChapterDetailScreen({super.key, required this.chapterName});

  @override
  ConsumerState<ChapterDetailScreen> createState() =>
      _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends ConsumerState<ChapterDetailScreen> {
  ConceptConnectorResult? _connector;
  bool _loadingConnector = false;

  ChapterSchema? _getChapter(List<ChapterSchema> chapters) {
    try {
      return chapters.firstWhere((c) => c.name == widget.chapterName);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadConceptConnector(
      ChapterSchema chapter, List<ChapterSchema> all) async {
    if (_connector != null || _loadingConnector) return;
    setState(() => _loadingConnector = true);
    try {
      final result = await GeminiService.getConceptConnections(
        chapter: chapter,
        allChapters: all,
      );
      if (mounted) setState(() => _connector = result);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingConnector = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final planState = ref.watch(planProvider);
    final chapter = _getChapter(planState.chapters);

    if (chapter == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Chapter not found')),
      );
    }

    final accent = _subjectColor(chapter.subjectName, isDark);
    final progressRatio = chapter.estimatedHours > 0
        ? (chapter.hoursSpent / chapter.estimatedHours).clamp(0.0, 1.0)
        : 0.0;

    // Load connector once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConceptConnector(chapter, planState.chapters);
    });

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient App Bar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Subject badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${chapter.subjectName} · Class ${chapter.classLevel}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          chapter.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Key Stats Row ────────────────────────────────────────
                Row(
                  children: [
                    _StatBox('⚡', 'Weightage',
                        '${chapter.weightage.round()}%', accent, isDark),
                    const SizedBox(width: 10),
                    _StatBox('⏱️', 'Est. Hours',
                        '${chapter.estimatedHours}h', accent, isDark),
                    const SizedBox(width: 10),
                    _StatBox('📝', 'PYQs',
                        '${chapter.pyqCount}', accent, isDark),
                    const SizedBox(width: 10),
                    _StatBox('🎯', 'Difficulty',
                        '${'★' * chapter.difficulty}', accent, isDark),
                  ],
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 20),

                // ── Progress section ────────────────────────────────────
                _SectionCard(
                  title: 'Your Progress',
                  isDark: isDark,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${chapter.hoursSpent.toStringAsFixed(1)}h / ${chapter.estimatedHours}h studied',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '${(progressRatio * 100).round()}%',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: accent, fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          minHeight: 10,
                          backgroundColor: isDark
                              ? DarkColors.outline
                              : LightColors.outline,
                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Status chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'not_started',
                          'in_progress',
                          'learned',
                          'revised',
                          'tested',
                        ].map((status) {
                          final sel = chapter.status == status;
                          final (label, color) = _statusInfo(status);
                          return GestureDetector(
                            onTap: () async {
                              await ref
                                  .read(planProvider.notifier)
                                  .markChapterStatus(chapter.name, status);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: sel
                                    ? color.withOpacity(0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: sel
                                      ? color
                                      : (isDark
                                          ? DarkColors.outline
                                          : LightColors.outline),
                                  width: sel ? 1.5 : 0.5,
                                ),
                              ),
                              child: Text(
                                label,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: sel ? color : null,
                                  fontWeight:
                                      sel ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ).animate(delay: 80.ms).fadeIn(),

                const SizedBox(height: 16),

                // ── Tags ────────────────────────────────────────────────
                if (chapter.tags.isNotEmpty) ...[
                  _SectionCard(
                    title: 'Tags & Type',
                    isDark: isDark,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: chapter.tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accent.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                        child: Text(tag,
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: accent)),
                      )).toList(),
                    ),
                  ).animate(delay: 120.ms).fadeIn(),
                  const SizedBox(height: 16),
                ],

                // ── Quick Actions ────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          context.push(AppRoutes.log);
                        },
                        icon: const Text('✅', style: TextStyle(fontSize: 16)),
                        label: const Text('Log Session'),
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          minimumSize: const Size(0, 46),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push(AppRoutes.pomodoro);
                        },
                        icon: const Text('🍅', style: TextStyle(fontSize: 16)),
                        label: const Text('Focus Timer'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 46),
                        ),
                      ),
                    ),
                  ],
                ).animate(delay: 160.ms).fadeIn(),

                const SizedBox(height: 20),

                // ── AI Concept Connector ─────────────────────────────────
                _SectionCard(
                  title: '🧠 AI Concept Connector',
                  isDark: isDark,
                  trailing: _loadingConnector
                      ? SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                          ),
                        )
                      : null,
                  child: _connector == null
                      ? Text(
                          _loadingConnector
                              ? 'Analysing chapter connections...'
                              : 'Tap to load AI insights for this chapter',
                          style: theme.textTheme.bodySmall,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_connector!.prerequisites.isNotEmpty) ...[
                              _ConnectorSection(
                                emoji: '📌',
                                title: 'Prerequisites',
                                items: _connector!.prerequisites,
                                color: LightColors.tested,
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (_connector!.keyConceptsToRecall.isNotEmpty) ...[
                              _ConnectorSection(
                                emoji: '💡',
                                title: 'Key Concepts to Recall',
                                items: _connector!.keyConceptsToRecall,
                                color: accent,
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (_connector!.commonMistakes.isNotEmpty) ...[
                              _ConnectorSection(
                                emoji: '⚠️',
                                title: 'Common Mistakes',
                                items: _connector!.commonMistakes,
                                color: LightColors.error,
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (_connector!.proTip.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: accent.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('🚀',
                                        style: TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Pro Tip',
                                              style: theme.textTheme.labelLarge
                                                  ?.copyWith(color: accent)),
                                          const SizedBox(height: 4),
                                          Text(_connector!.proTip,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(height: 1.5)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ).animate(delay: 200.ms).fadeIn(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Color _subjectColor(String s, bool dark) {
    switch (s) {
      case 'Physics': return dark ? DarkColors.physics : LightColors.physics;
      case 'Chemistry': return dark ? DarkColors.chemistry : LightColors.chemistry;
      case 'Mathematics': return dark ? DarkColors.mathematics : LightColors.mathematics;
      default: return dark ? DarkColors.biology : LightColors.biology;
    }
  }

  (String, Color) _statusInfo(String status) {
    switch (status) {
      case 'not_started': return ('Not Started', LightColors.onSurfaceVariant);
      case 'in_progress': return ('In Progress', LightColors.tested);
      case 'learned': return ('✅ Learned', LightColors.learned);
      case 'revised': return ('🔄 Revised', LightColors.revised);
      case 'tested': return ('🧪 Tested', LightColors.pyqDone);
      default: return (status, LightColors.primary);
    }
  }
}

class _StatBox extends StatelessWidget {
  final String emoji, label, value;
  final Color color;
  final bool isDark;

  const _StatBox(this.emoji, this.label, this.value, this.color, this.isDark);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 0.5),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(value,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color, fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(label, style: theme.textTheme.labelSmall, maxLines: 1),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.child,
    required this.isDark,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surfaceCard : LightColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DarkColors.outline : LightColors.outline,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ConnectorSection extends StatelessWidget {
  final String emoji, title;
  final List<String> items;
  final Color color;

  const _ConnectorSection({
    required this.emoji,
    required this.title,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(title,
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4, left: 4),
          child: Row(
            children: [
              Container(
                width: 5, height: 5,
                margin: const EdgeInsets.only(right: 8, top: 1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: color,
                ),
              ),
              Expanded(
                child: Text(item, style: theme.textTheme.bodySmall),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
