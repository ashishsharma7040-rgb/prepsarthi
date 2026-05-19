// lib/presentation/screens/analytics/weakness_radar_screen.dart
//
// Premium: Weakness Radar — shows weak chapters, subject vulnerability,
// low PYQ progress, low accuracy chapters, and never-revised chapters.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/local/isar/isar_service.dart';
import '../../../data/local/isar/schemas/chapter_schema.dart';
import '../../providers/all_providers.dart';
import '../../providers/analytics_providers.dart';

class WeaknessRadarScreen extends ConsumerWidget {
  const WeaknessRadarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radar = ref.watch(weaknessRadarProvider);
    final readiness = ref.watch(readinessScoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Weakness Radar',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
      ),
      body: radar.hasWeaknesses == false && radar.totalWeakAreas == 0
          ? _EmptyRadar(isDark: isDark)
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              physics: const BouncingScrollPhysics(),
              children: [
                // Subject vulnerability bars
                _SubjectVulnerabilityCard(
                        radar: radar, isDark: isDark)
                    .animate()
                    .fadeIn(),

                const SizedBox(height: 16),

                // Weak chapters
                if (radar.weakChapters.isNotEmpty) ...[
                  _SectionTitle(
                    emoji: '⚠️',
                    title: 'Weak Chapters',
                    subtitle:
                        '${radar.weakChapters.length} chapters flagged',
                    color: LightColors.error,
                  ),
                  const SizedBox(height: 10),
                  ...radar.weakChapters.asMap().entries.map((e) =>
                      _ChapterRow(
                        chapter: e.value,
                        badge: 'Weak',
                        badgeColor: LightColors.error,
                        isDark: isDark,
                        onToggleWeak: () =>
                            _toggleWeak(ref, e.value),
                      ).animate().fadeIn(delay: (e.key * 40).ms)),
                  const SizedBox(height: 16),
                ],

                // High backlog
                if (radar.highBacklogChapters.isNotEmpty) ...[
                  _SectionTitle(
                    emoji: '📋',
                    title: 'High-Priority Backlog',
                    subtitle:
                        '${radar.highBacklogChapters.length} not started, high weightage',
                    color: const Color(0xFFFF9800),
                  ),
                  const SizedBox(height: 10),
                  ...radar.highBacklogChapters.asMap().entries.map((e) =>
                      _ChapterRow(
                        chapter: e.value,
                        badge: 'Backlog',
                        badgeColor: const Color(0xFFFF9800),
                        isDark: isDark,
                      ).animate().fadeIn(delay: (e.key * 40).ms)),
                  const SizedBox(height: 16),
                ],

                // Low PYQ progress
                if (radar.lowPyqChapters.isNotEmpty) ...[
                  _SectionTitle(
                    emoji: '📝',
                    title: 'PYQ Gap',
                    subtitle:
                        '${radar.lowPyqChapters.length} chapters with pending PYQs',
                    color: const Color(0xFF9C27B0),
                  ),
                  const SizedBox(height: 10),
                  ...radar.lowPyqChapters.asMap().entries.map((e) =>
                      _ChapterRow(
                        chapter: e.value,
                        badge: '${e.value.pyqCount} PYQs',
                        badgeColor: const Color(0xFF9C27B0),
                        isDark: isDark,
                      ).animate().fadeIn(delay: (e.key * 40).ms)),
                  const SizedBox(height: 16),
                ],

                // Low accuracy
                if (radar.lowAccuracyChapters.isNotEmpty) ...[
                  _SectionTitle(
                    emoji: '🎯',
                    title: 'Low Test Accuracy',
                    subtitle:
                        '${radar.lowAccuracyChapters.length} chapters below 50% accuracy',
                    color: LightColors.revised,
                  ),
                  const SizedBox(height: 10),
                  ...radar.lowAccuracyChapters.asMap().entries.map((e) =>
                      _ChapterRow(
                        chapter: e.value,
                        badge:
                            '${e.value.testAccuracy.toStringAsFixed(0)}%',
                        badgeColor: LightColors.revised,
                        isDark: isDark,
                      ).animate().fadeIn(delay: (e.key * 40).ms)),
                  const SizedBox(height: 16),
                ],

                // Never revised
                if (radar.neverRevisedChapters.isNotEmpty) ...[
                  _SectionTitle(
                    emoji: '🔄',
                    title: 'Never Revised',
                    subtitle:
                        '${radar.neverRevisedChapters.length} chapters learned but never revised',
                    color: LightColors.primary,
                  ),
                  const SizedBox(height: 10),
                  ...radar.neverRevisedChapters.asMap().entries.map(
                      (e) => _ChapterRow(
                            chapter: e.value,
                            badge: 'No Revision',
                            badgeColor: LightColors.primary,
                            isDark: isDark,
                          ).animate().fadeIn(delay: (e.key * 40).ms)),
                  const SizedBox(height: 16),
                ],

                // Action tip
                _ActionTip(radar: radar, isDark: isDark)
                    .animate()
                    .fadeIn(delay: 300.ms),
              ],
            ),
    );
  }

  Future<void> _toggleWeak(WidgetRef ref, ChapterSchema c) async {
    final db = IsarService.db;
    c.isWeakChapter = !c.isWeakChapter;
    await db.writeTxn(() async => db.chapterSchemas.put(c));
    ref.read(planProvider.notifier).refresh();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subject vulnerability card
// ─────────────────────────────────────────────────────────────────────────────

class _SubjectVulnerabilityCard extends StatelessWidget {
  final WeaknessRadar radar;
  final bool isDark;

  const _SubjectVulnerabilityCard(
      {required this.radar, required this.isDark});

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
    if (radar.subjectWeakness.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('Subject Vulnerability',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Higher bar = more attention needed',
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          ...radar.subjectWeakness.entries.map((e) {
            final color = _subjectColor(e.key);
            final pct = (e.value * 100).round();
            String label;
            if (e.value >= 0.7) label = 'Critical';
            else if (e.value >= 0.5) label = 'High Risk';
            else if (e.value >= 0.3) label = 'Moderate';
            else label = 'Good';

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(label,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: color,
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 6),
                          Text('$pct%',
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: e.value,
                      minHeight: 10,
                      backgroundColor:
                          isDark ? DarkColors.outline : LightColors.outline,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chapter row
// ─────────────────────────────────────────────────────────────────────────────

class _ChapterRow extends StatelessWidget {
  final ChapterSchema chapter;
  final String badge;
  final Color badgeColor;
  final bool isDark;
  final VoidCallback? onToggleWeak;

  const _ChapterRow({
    required this.chapter,
    required this.badge,
    required this.badgeColor,
    required this.isDark,
    this.onToggleWeak,
  });

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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 42,
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(chapter.subjectName,
                        style: TextStyle(
                            fontSize: 11, color: subjColor)),
                    Text(' · W${chapter.weightage.toStringAsFixed(1)}',
                        style: theme.textTheme.labelSmall),
                    Text(' · Level ${chapter.masteryLevel}/7',
                        style: theme.textTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(badge,
                style: TextStyle(
                    fontSize: 11,
                    color: badgeColor,
                    fontWeight: FontWeight.w700)),
          ),
          if (onToggleWeak != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onToggleWeak,
              child: Icon(
                chapter.isWeakChapter
                    ? Icons.flag_rounded
                    : Icons.flag_outlined,
                color: chapter.isWeakChapter
                    ? LightColors.error
                    : Colors.grey.shade400,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section title
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String emoji, title, subtitle;
  final Color color;

  const _SectionTitle({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800, color: color)),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action tip
// ─────────────────────────────────────────────────────────────────────────────

class _ActionTip extends StatelessWidget {
  final WeaknessRadar radar;
  final bool isDark;

  const _ActionTip({required this.radar, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String tip;
    String emoji;

    if (radar.highBacklogChapters.isNotEmpty) {
      final top = radar.highBacklogChapters.first;
      tip =
          'Priority: Start "${top.name}" in ${top.subjectName}. It has high weightage (${top.weightage.toStringAsFixed(0)}) and hasn\'t been touched yet.';
      emoji = '🚨';
    } else if (radar.weakChapters.isNotEmpty) {
      tip =
          'Focus on weak chapters before attempting new ones. Revise theory and practise at least 20 questions per weak chapter.';
      emoji = '🎯';
    } else if (radar.lowPyqChapters.isNotEmpty) {
      tip =
          'Your syllabus coverage is good. Now focus on PYQ practice to understand exam patterns and improve accuracy.';
      emoji = '📝';
    } else {
      tip =
          'Looking good! Keep revising completed chapters and attempt regular mock tests to maintain performance.';
      emoji = '✅';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LightColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: LightColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recommended Action',
                    style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: LightColors.primary)),
                const SizedBox(height: 4),
                Text(tip,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyRadar extends StatelessWidget {
  final bool isDark;
  const _EmptyRadar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('No Weaknesses Detected!',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'Log more study sessions and mark chapters\nto build your weakness radar.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
