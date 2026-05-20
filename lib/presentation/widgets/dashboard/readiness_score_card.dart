// lib/presentation/widgets/dashboard/readiness_score_card.dart
//
// ✅ FIXED: Removed local readinessScoreProvider declaration.
//           Now imports readinessScoreProvider from analytics_providers.dart
//           (which delegates to ReadinessCalculator — single source of truth).
//           Widget refreshes automatically when plan/study logs change.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
// ✅ Import canonical provider — do NOT redeclare it here
import '../../providers/analytics_providers.dart';

class ReadinessScoreCard extends ConsumerWidget {
  final bool isPremium;
  const ReadinessScoreCard({super.key, required this.isPremium});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isPremium) return _LockedScoreCard(isDark: isDark);

    // Uses the canonical FutureProvider from analytics_providers.dart
    final scoreAsync = ref.watch(readinessScoreProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [LightColors.primary.withOpacity(0.9), const Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: LightColors.primary.withOpacity(0.3),
          blurRadius: 16, offset: const Offset(0, 6),
        )],
      ),
      child: scoreAsync.when(
        loading: () => const SizedBox(
          height: 160,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
        error: (err, _) => SizedBox(
          height: 80,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not load score',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => ref.invalidate(readinessScoreProvider),
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        data: (score) => _ScoreContent(score: score),
      ),
    );
  }
}

class _ScoreContent extends StatelessWidget {
  final ReadinessScore score;
  const _ScoreContent({required this.score});

  Color get _gradeColor {
    switch (score.color) {
      case 'green':  return Colors.greenAccent;
      case 'yellow': return Colors.yellowAccent;
      case 'orange': return Colors.orangeAccent;
      default:       return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Exam Readiness',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${score.score}', style: const TextStyle(
                        color: Colors.white, fontSize: 52,
                        fontWeight: FontWeight.w900,
                      )),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text('/100',
                            style: TextStyle(color: Colors.white60, fontSize: 18)),
                      ),
                    ],
                  ),
                  Text(score.status,
                      style: TextStyle(
                          color: _gradeColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ],
              ),
            ),
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(score.grade, style: const TextStyle(
                  color: Colors.white, fontSize: 28,
                  fontWeight: FontWeight.w900,
                )),
              ),
            ),
          ]),

          const SizedBox(height: 16),

          // Breakdown bars
          ...score.breakdown.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(
                        color: Colors.white70, fontSize: 11)),
                    Text('${(e.value * 100).round()}%',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: e.value.clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      e.value >= 0.7
                          ? Colors.greenAccent
                          : (e.value >= 0.4
                              ? Colors.yellowAccent
                              : Colors.redAccent),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          )),

          if (score.tips.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡 Focus Areas',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                  const SizedBox(height: 6),
                  ...score.tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text('• $tip',
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            height: 1.4)),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LockedScoreCard extends StatelessWidget {
  final bool isDark;
  const _LockedScoreCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: LightColors.primary.withOpacity(0.3), width: 1.5),
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: LightColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_outline,
              color: LightColors.primary, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Exam Readiness Score',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text(
                  'Unlock your personalized score with PrepSarthi Pro',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: LightColors.primary),
      ]),
    );
  }
}
