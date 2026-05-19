// lib/presentation/widgets/dashboard/deficit_card.dart
//
// ✅ NEW: Daily Deficit Tracker card for dashboard.
// Shows "Planned X hours — Studied Y hours — Deficit/Surplus Z hours".
// Calculated from real study logs vs user's daily target.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../presentation/providers/all_providers.dart';

class DeficitCard extends ConsumerWidget {
  const DeficitCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final logs = ref.watch(studyLogProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final plannedHours = auth.user?.dailyStudyHours ?? 6.0;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    final todayHours = logs
        .where((l) => l.timestamp.isAfter(todayStart) && l.timestamp.isBefore(todayEnd))
        .fold(0.0, (sum, l) => sum + l.hoursStudied);

    final deficit = plannedHours - todayHours;
    final isAhead = deficit <= 0;
    final absDeficit = deficit.abs();

    final color = isAhead
        ? const Color(0xFF4CAF50)
        : (deficit > 2 ? LightColors.error : LightColors.tested);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Today\'s Progress',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isAhead
                      ? '+${absDeficit.toStringAsFixed(1)}h ahead'
                      : '${absDeficit.toStringAsFixed(1)}h remaining',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatItem(label: 'Planned', value: '${plannedHours.toStringAsFixed(1)}h', color: Colors.grey),
              const SizedBox(width: 20),
              _StatItem(label: 'Studied', value: '${todayHours.toStringAsFixed(1)}h', color: LightColors.primary),
              const SizedBox(width: 20),
              _StatItem(
                label: isAhead ? 'Surplus' : 'Deficit',
                value: '${absDeficit.toStringAsFixed(1)}h',
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (todayHours / plannedHours).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          if (!isAhead && deficit > 0.5) ...[
            const SizedBox(height: 8),
            Text(
              'Add ${deficit.toStringAsFixed(1)}h more today to stay on track.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}
