// lib/domain/usecases/streak_usecase.dart
//
// DATA-5 (Master Spec): THE single streak authority.
//
// Previously two competing implementations existed:
//   • an inline block inside StudyLogNotifier.logSession()
//   • AuthNotifier.updateStreak(), called additionally from two screens
// Both wrote UserSchema.currentStreak → race / double-count corruption.
//
// NOW:
//   • StudyLogNotifier.logSession() calls StreakUseCase.touchToday() — the
//     ONLY production write path.
//   • AuthNotifier.updateStreak() delegates here (kept for API compatibility;
//     idempotent same-day so accidental extra calls are harmless).
//   • Screens must NEVER call streak updates directly.
//
// computeNext() is pure so it is unit-testable without Isar.

import 'package:isar/isar.dart';
import '../../data/local/isar/isar_service.dart';
import '../../core/utils/notification_helper.dart';

class StreakResult {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastStudyDate;
  final bool changed; // false when already touched today (idempotent no-op)
  const StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastStudyDate,
    required this.changed,
  });
}

class StreakUseCase {
  StreakUseCase._();

  static const milestones = [3, 7, 14, 30, 60, 100];

  /// PURE streak transition. Given the stored values and 'today', returns the
  /// next state. Same-day repeat calls return changed=false (idempotent).
  static StreakResult computeNext({
    required int currentStreak,
    required int longestStreak,
    required DateTime? lastStudyDate,
    required DateTime today,
  }) {
    final day = DateTime(today.year, today.month, today.day);
    if (lastStudyDate != null) {
      final last = DateTime(
          lastStudyDate.year, lastStudyDate.month, lastStudyDate.day);
      if (last == day) {
        return StreakResult(
          currentStreak: currentStreak,
          longestStreak: longestStreak,
          lastStudyDate: day,
          changed: false,
        );
      }
      final diff = day.difference(last).inDays;
      final next = diff == 1 ? currentStreak + 1 : 1;
      return StreakResult(
        currentStreak: next,
        longestStreak: next > longestStreak ? next : longestStreak,
        lastStudyDate: day,
        changed: true,
      );
    }
    return StreakResult(
      currentStreak: 1,
      longestStreak: longestStreak < 1 ? 1 : longestStreak,
      lastStudyDate: day,
      changed: true,
    );
  }

  /// Records that the user studied today. Idempotent — safe to call from any
  /// number of code paths in the same day; only the first call mutates state.
  /// Returns the resulting streak, or null if no user exists / DB unavailable.
  static Future<StreakResult?> touchToday() async {
    try {
      final db = IsarService.db;
      final user = await db.userSchemas.where().findFirst();
      if (user == null) return null;

      final result = computeNext(
        currentStreak: user.currentStreak,
        longestStreak: user.longestStreak,
        lastStudyDate: user.lastStudyDate,
        today: DateTime.now(),
      );

      if (result.changed) {
        user.currentStreak = result.currentStreak;
        user.longestStreak = result.longestStreak;
        user.lastStudyDate = result.lastStudyDate;
        await db.writeTxn(() async => db.userSchemas.put(user));

        if (milestones.contains(result.currentStreak)) {
          await NotificationHelper.showStreakNotification(
              result.currentStreak);
        }
      }
      return result;
    } catch (_) {
      // Streak must never break a study-log save.
      return null;
    }
  }
}
