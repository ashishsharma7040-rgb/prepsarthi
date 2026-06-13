// lib/presentation/screens/dashboard/decision_support_cards.dart
//
// FLAGSHIP dashboard surfaces — the decision-support layer.
//   • PassProbabilityCard  — "Group I 82% · Group II 69% · Both 58%", with the
//                            weakest-paper limiter explained underneath.
//   • DecisionImpactCard   — ranked "do this next", each line showing the
//                            actual Δ pass-probability and Δ/hour, plus WHY.
// Both read providers backed by the shared PassProbabilityEngine, so every
// number agrees with every other surface in the app.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/analytics_providers.dart';

Color _probColor(double p) {
  if (p >= 0.75) return Colors.green;
  if (p >= 0.55) return Colors.lightGreen.shade700;
  if (p >= 0.40) return Colors.amber.shade800;
  return Colors.red.shade400;
}

// ───────────────────────── Pass Probability ─────────────────────────────────
class PassProbabilityCard extends ConsumerWidget {
  final bool isDark;
  const PassProbabilityCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(passProbabilityProvider);
    if (!r.hasData) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1B2236), const Color(0xFF161B2B)]
              : [const Color(0xFFF3F6FF), const Color(0xFFFFFFFF)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: _probColor(r.bothGroupsProbability).withOpacity(0.35),
            width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_rounded,
                  color: _probColor(r.bothGroupsProbability), size: 20),
              const SizedBox(width: 8),
              Text('Pass Probability',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('estimate',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.hintColor)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final g in r.groups) ...[
                Expanded(child: _probPill(theme, g.label, g.passProbability)),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: _probPill(theme, 'Both', r.bothGroupsProbability,
                    emphasise: true),
              ),
            ],
          ),
          if (r.reasons.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(isDark ? 0.4 : 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Why',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  ...r.reasons.take(2).map((reason) => Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text('• ${reason.detail}',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(height: 1.35)),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 60.ms).slideY(begin: 0.05);
  }

  Widget _probPill(ThemeData theme, String label, double p,
      {bool emphasise = false}) {
    final c = _probColor(p);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(emphasise ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(14),
        border: emphasise ? Border.all(color: c.withOpacity(0.5)) : null,
      ),
      child: Column(
        children: [
          Text('${(p * 100).round()}%',
              style: theme.textTheme.titleLarge?.copyWith(
                  color: c,
                  fontWeight: FontWeight.w800,
                  fontSize: emphasise ? 26 : 22)),
          const SizedBox(height: 2),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ───────────────────────── Decision Impact ──────────────────────────────────
class DecisionImpactCard extends ConsumerWidget {
  final bool isDark;
  const DecisionImpactCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.watch(decisionImpactProvider);
    if (actions.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B2B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.4), width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Do this next — highest impact',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Ranked by how much each hour moves your pass probability.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 12),
          ...actions.asMap().entries.map((e) =>
              _actionRow(theme, e.key + 1, e.value)
                  .animate(delay: (e.key * 70).ms)
                  .fadeIn()
                  .slideX(begin: -0.06)),
        ],
      ),
    );
  }

  Widget _actionRow(ThemeData theme, int rank, ImpactAction a) {
    final accent = theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('$rank',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: accent, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('${a.verb}: ${a.chapterName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text('+${a.deltaPassPercent.toStringAsFixed(1)}%',
                          style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'P${a.paper} · ~${a.hours.toStringAsFixed(a.hours % 1 == 0 ? 0 : 1)}h · '
                  '${a.impactPerHour.toStringAsFixed(1)}%/h',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.hintColor),
                ),
                const SizedBox(height: 3),
                Text(a.reason,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
