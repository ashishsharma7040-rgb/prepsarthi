// lib/presentation/screens/dashboard/feasibility_card.dart
//
// PART 4 — dashboard surface for the Feasibility Engine (PLAN-1/PLAN-2).
// One compact card answering: "Will I finish the syllabus in time?"
//   • comfortable → quiet green confirmation
//   • tight       → amber, shows the hours/day actually required
//   • at risk     → red, shows the gap and the top Smart-Trim suggestions
//     (lowest-ROI chapters to drop, with the marks-weight cost)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/analytics_providers.dart';

class FeasibilityCard extends ConsumerWidget {
  final bool isDark;
  const FeasibilityCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(feasibilityProvider);
    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (f) {
        if (f.status == FeasibilityStatus.noData) {
          return const SizedBox.shrink();
        }
        final theme = Theme.of(context);

        final (color, icon) = switch (f.status) {
          FeasibilityStatus.comfortable => (Colors.green, Icons.verified_rounded),
          FeasibilityStatus.tight => (Colors.amber.shade700, Icons.timelapse_rounded),
          _ => (Colors.red.shade400, Icons.warning_amber_rounded),
        };

        final pct = (f.coverageRatio * 100).clamp(0, 999).round();

        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.10 : 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.35), width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f.headline,
                      style: theme.textTheme.titleSmall?.copyWith(
                          color: color, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text('$pct%',
                      style: theme.textTheme.titleSmall?.copyWith(
                          color: color, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${f.requiredHours.round()}h of study left · '
                '${f.availableHours.round()}h realistically available '
                'in ${f.daysLeft} days',
                style: theme.textTheme.bodySmall,
              ),
              if (f.status == FeasibilityStatus.tight) ...[
                const SizedBox(height: 4),
                Text(
                  'Doable if you hold ~${f.requiredHoursPerDay.toStringAsFixed(1)}h/day — protect your streak.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
              // ── Velocity layer (Stage-4 seed): the plan may fit on paper,
              // but the last 14 days of REAL behaviour tell the truer story.
              if (f.paceIsTheProblem) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Reality check: last 14 days you averaged '
                    '${(f.actualDailyHours ?? 0).toStringAsFixed(1)}h/day. '
                    'At that real pace, coverage drops to '
                    '${((f.paceCoverageRatio ?? 0) * 100).round()}%.',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              if (f.status == FeasibilityStatus.atRisk &&
                  f.trimSuggestions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'To make it fit, consider dropping these low-yield chapters '
                  '(~${f.trimmableMarksCost.round()} weightage at stake):',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                ...f.trimSuggestions.take(3).map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '• ${t.chapterName} (${t.subjectName}, ~${t.remainingHours.round()}h)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ),
              ],
            ],
          ),
        );
      },
    );
  }
}
