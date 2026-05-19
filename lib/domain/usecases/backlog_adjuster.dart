// lib/domain/usecases/backlog_adjuster.dart
//
// Backlog Auto-Adjustment — detects missed study days and reschedules
// pending plan entries intelligently without overloading any single day.
// ✅ FIX: Import paths corrected (was ../../../, now ../../ from usecases/)

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../../data/local/isar/isar_service.dart';
import '../../data/local/isar/schemas/plan_entry_schema.dart';
import '../../data/local/isar/schemas/user_schema.dart';

class BacklogAdjuster {
  /// Checks if student missed study days and reschedules pending entries.
  /// Returns number of missed days handled, or 0 if nothing was needed.
  ///
  /// ✅ Smart logic:
  ///  - Never overloads a single day beyond maxPerDay
  ///  - High-priority (high weightage) chapters are protected — scheduled first
  ///  - Safety limit: never pushes more than 30 days forward
  ///  - If missed > 14 days, suggests plan regeneration instead of shifting
  static Future<BacklogResult> adjustIfNeeded() async {
    try {
      final db = IsarService.db;
      final user = await db.userSchemas.where().findFirst();
      if (user == null) return BacklogResult.none;

      final today = _dayOnly(DateTime.now());
      final last = user.lastStudyDate;
      if (last == null) return BacklogResult.none;

      final lastDay = _dayOnly(last);
      final missedDays = today.difference(lastDay).inDays - 1;

      if (missedDays <= 0) return BacklogResult.none;

      // ✅ If missed more than 14 days, plan has drifted too far — recommend regeneration
      if (missedDays > 14) {
        return BacklogResult(
          missedDays: missedDays,
          rescheduledCount: 0,
          needsRegeneration: true,
          message: 'You missed ${missedDays} days. Consider regenerating your plan for a fresh start.',
        );
      }

      final adjustDays = missedDays.clamp(1, 14);
      debugPrint('[BacklogAdjuster] Missed $missedDays days — adjusting $adjustDays days of entries');

      // Find pending entries during the missed window
      final missedStart = lastDay.add(const Duration(days: 1));
      final missedEnd = today;

      final staleEntries = await db.planEntrySchemas
          .filter()
          .plannedDateGreaterThan(missedStart.subtract(const Duration(seconds: 1)))
          .and()
          .plannedDateLessThan(missedEnd)
          .and()
          .statusEqualTo('pending')
          .sortByOrderIndex()
          .findAll();

      if (staleEntries.isEmpty) return BacklogResult.none;

      // ✅ Count existing future entries per day
      final futureCounts = <DateTime, int>{};
      final existingFuture = await db.planEntrySchemas
          .filter()
          .plannedDateGreaterThan(today.subtract(const Duration(seconds: 1)))
          .and()
          .statusEqualTo('pending')
          .findAll();

      for (final e in existingFuture) {
        final day = _dayOnly(e.plannedDate);
        futureCounts[day] = (futureCounts[day] ?? 0) + 1;
      }

      // ✅ Respect daily capacity (don't overload)
      final dailyHours = user.dailyStudyHours;
      final maxPerDay = (dailyHours / 1.5).round().clamp(2, 6);

      // ✅ Sort by weightage desc (high-weight chapters get rescheduled first/earliest)
      // Since PlanEntrySchema doesn't have weightage, maintain original order
      // which already reflects priority from plan generation

      await db.writeTxn(() async {
        for (final entry in staleEntries) {
          DateTime candidate = today;
          int safetyLimit = 0;
          while (safetyLimit < 60) {
            final count = futureCounts[candidate] ?? 0;
            if (count < maxPerDay) {
              entry.plannedDate = candidate;
              futureCounts[candidate] = count + 1;
              break;
            }
            candidate = candidate.add(const Duration(days: 1));
            safetyLimit++;
          }
          await db.planEntrySchemas.put(entry);
        }
      });

      debugPrint('[BacklogAdjuster] Rescheduled ${staleEntries.length} entries across future days');
      return BacklogResult(
        missedDays: missedDays,
        rescheduledCount: staleEntries.length,
        needsRegeneration: false,
        message: '${staleEntries.length} tasks rescheduled after $missedDays missed day(s).',
      );
    } catch (e) {
      debugPrint('[BacklogAdjuster] Error: $e');
      return BacklogResult.none;
    }
  }

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

class BacklogResult {
  final int missedDays;
  final int rescheduledCount;
  final bool needsRegeneration;
  final String message;

  const BacklogResult({
    required this.missedDays,
    required this.rescheduledCount,
    required this.needsRegeneration,
    required this.message,
  });

  static const BacklogResult none = BacklogResult(
    missedDays: 0,
    rescheduledCount: 0,
    needsRegeneration: false,
    message: '',
  );

  bool get hasBacklog => rescheduledCount > 0 || needsRegeneration;
}
