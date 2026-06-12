// lib/domain/usecases/achievement_usecase.dart
//
// PART 3 — WIRE-7 (+ R2 NEW-9, DATA-8).
//
// THE single achievement authority. Before this, badge unlocking lived inline
// in StudyLogNotifier._checkAchievements() and ran ONLY on the log path, so:
//   • mastery_10 ("Chapter Champion") and ai_report had ZERO unlock sites —
//     they were permanently dead badges (R2 NEW-9).
//   • completing a plan entry, marking a chapter learned, or generating an AI
//     report never re-checked achievements.
//   • totals were computed from the 30-day in-memory log window, so hours_100
//     could unlock late or never and total hours were wrong (DATA-8).
//
// This use-case is called from EVERY path that can move a badge:
//   • StudyLogNotifier.logSession()          (log path)
//   • PlanNotifier.markPlanEntryStatus()     (plan-completion path)
//   • PlanNotifier.markChapterStatus()       (mastery path)
//   • AI report providers                    (markAiReportGenerated → ai_report)
//
// It reads from the FULL study-log history via StudyLogRepository (DATA-8 fix),
// not the trimmed 30-day notifier state. Every unlock is idempotent.

import 'package:isar/isar.dart';

import '../../data/local/isar/isar_service.dart'; // re-exports schemas
import '../../data/repositories/chapter_repository.dart';
import '../../data/repositories/study_log_repository.dart';
import '../../core/utils/notification_helper.dart';

class AchievementUseCase {
  AchievementUseCase._();

  /// Evaluate every threshold badge against the current DB state and unlock any
  /// that now qualify. Safe to call from any path, any number of times.
  static Future<void> evaluate() async {
    final db = IsarService.db;

    // ── DATA-8: totals from FULL history, not the 30-day window ────────────
    final totalLogs = await StudyLogRepository.totalCount();
    final totalHours = await StudyLogRepository.totalHours();
    final pyqCount = await StudyLogRepository.countByTag('pyq');

    // mastery_10 — chapters at Test Ready (masteryLevel ≥ 7). Previously had no
    // unlock site at all.
    final allChapters = await db.chapterSchemas.where().findAll();
    final testReadyCount =
        allChapters.where((c) => c.masteryLevel >= 7).length;

    if (totalLogs >= 1) await _unlock('first_log');
    if (totalHours >= 10) await _unlock('hours_10');
    if (totalHours >= 50) await _unlock('hours_50');
    if (totalHours >= 100) await _unlock('hours_100');
    if (totalHours >= 250) await _unlock('hours_250');
    if (totalHours >= 500) await _unlock('hours_500');
    if (pyqCount >= 10) await _unlock('pyq_10');
    if (pyqCount >= 50) await _unlock('pyq_50');
    if (pyqCount >= 100) await _unlock('pyq_100');
    if (testReadyCount >= 10) await _unlock('mastery_10');

    // ── CA Final group badges ─────────────────────────────────────────────
    final user = await db.userSchemas.where().findFirst();
    if (user?.targetExam == 'ca_final') {
      final (g1Total, g1Done) =
          await ChapterRepository.statusProgressByClassLevels(
              'ca_final', const [1, 2, 3]);
      if (g1Total > 0 && g1Done >= g1Total) await _unlock('ca_group1');

      final (g2Total, g2Done) =
          await ChapterRepository.statusProgressByClassLevels(
              'ca_final', const [4, 5, 6]);
      if (g2Total > 0 && g2Done >= g2Total) await _unlock('ca_group2');
    }
  }

  /// Unlock the 'ai_report' badge the first time the student generates any AI
  /// analysis (SWOT / Pattern / CA Insights). Previously this badge could never
  /// unlock — there was no call site.
  static Future<void> markAiReportGenerated() async {
    await _unlock('ai_report');
  }

  // ── Internal: idempotent unlock + notification ──────────────────────────
  static Future<void> _unlock(String badgeId) async {
    final db = IsarService.db;
    final badge =
        await db.achievementSchemas.filter().badgeIdEqualTo(badgeId).findFirst();
    if (badge == null || badge.unlocked) return;

    badge.unlocked = true;
    badge.unlockedAt = DateTime.now();
    await db.writeTxn(() async => db.achievementSchemas.put(badge));

    // Non-fatal: never let a notification failure break the study flow.
    try {
      await NotificationHelper.showAchievementNotification(
        badgeTitle: badge.title,
        badgeEmoji: badge.emoji,
        description: badge.description,
      );
    } catch (_) {}
  }
}
