// lib/presentation/screens/achievements/achievements_screen.dart
//
// TASK 10: Achievements screen — earned badges with emoji, title, date,
// and locked state for unearned achievements.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/local/isar/schemas/achievement_schema.dart';
import '../../providers/all_providers.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final achievementsAsync = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Achievements',
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: achievementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😕', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('Could not load achievements',
                  style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        data: (achievements) {
          if (achievements.isEmpty) {
            return _EmptyState(isDark: isDark);
          }

          final earned =
              achievements.where((a) => a.unlocked).toList()
                ..sort((a, b) =>
                    (b.unlockedAt ?? DateTime(0))
                        .compareTo(a.unlockedAt ?? DateTime(0)));
          final locked =
              achievements.where((a) => !a.unlocked).toList();

          return SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Summary banner ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: _SummaryBanner(
                    earned: earned.length,
                    total: achievements.length,
                    isDark: isDark,
                  ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.06),
                ),

                // ── Earned section ──────────────────────────────────────
                if (earned.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Text(
                        '🏆  Earned (${earned.length})',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _AchievementCard(
                          achievement: earned[i],
                          isDark: isDark,
                          earned: true,
                        )
                            .animate()
                            .fadeIn(delay: (i * 45).ms)
                            .slideY(begin: 0.08),
                        childCount: earned.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.88,
                      ),
                    ),
                  ),
                ],

                // ── Locked section ──────────────────────────────────────
                if (locked.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        '🔒  Locked (${locked.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? DarkColors.onSurfaceVariant
                              : LightColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _AchievementCard(
                          achievement: locked[i],
                          isDark: isDark,
                          earned: false,
                        )
                            .animate()
                            .fadeIn(delay: (i * 30).ms),
                        childCount: locked.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.88,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Summary Banner ───────────────────────────────────────────────────────────
class _SummaryBanner extends StatelessWidget {
  final int earned, total;
  final bool isDark;

  const _SummaryBanner(
      {required this.earned, required this.total, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isDark ? DarkColors.primary : LightColors.primary;
    final progress = total > 0 ? earned / total : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.15), accent.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          // Circle progress
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  backgroundColor:
                      isDark ? DarkColors.outline : LightColors.outline,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
                Text(
                  '$earned',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$earned of $total unlocked',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  earned == 0
                      ? 'Start studying to earn your first badge!'
                      : earned < total
                          ? '${total - earned} more to go — keep it up!'
                          : '🎉 All badges unlocked!',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor:
                        isDark ? DarkColors.outline : LightColors.outline,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
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

// ─── Achievement Card ─────────────────────────────────────────────────────────
class _AchievementCard extends StatelessWidget {
  final AchievementSchema achievement;
  final bool isDark;
  final bool earned;

  const _AchievementCard({
    required this.achievement,
    required this.isDark,
    required this.earned,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isDark ? DarkColors.primary : LightColors.primary;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: earned ? 1.0 : 0.45,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: earned
              ? (isDark
                  ? DarkColors.surfaceCard
                  : LightColors.surface)
              : (isDark
                  ? DarkColors.surfaceVariant
                  : LightColors.surfaceVariant),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: earned
                ? accent.withOpacity(0.25)
                : Colors.grey.withOpacity(0.12),
            width: earned ? 1.0 : 0.5,
          ),
          boxShadow: earned
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji + lock
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  earned ? achievement.emoji : '🔒',
                  style: const TextStyle(fontSize: 32),
                ),
                if (earned && achievement.unlockedAt != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: LightColors.learned.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '✓ Done',
                      style: TextStyle(
                        fontSize: 10,
                        color: LightColors.learned,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              achievement.title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: earned ? null : Colors.grey,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 4),

            // Description (blurred/hidden when locked)
            earned
                ? Text(
                    achievement.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.4,
                      color: isDark
                          ? DarkColors.onSurfaceVariant
                          : LightColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    '???  Complete a challenge to reveal',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                  ),

            const Spacer(),

            // Progress bar (for unearned with progress > 0)
            if (!earned && achievement.targetProgress > 1) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: (achievement.currentProgress /
                          achievement.targetProgress)
                      .clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey.shade400),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${achievement.currentProgress} / ${achievement.targetProgress}',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: Colors.grey.shade500),
              ),
            ],

            // Unlock date
            if (earned && achievement.unlockedAt != null) ...[
              const SizedBox(height: 6),
              Text(
                _fmtDate(achievement.unlockedAt!),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏅', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text('No Achievements Yet',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Log your first study session to start\nearning badges!',
                style: theme.textTheme.bodySmall
                    ?.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
