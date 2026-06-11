// lib/domain/usecases/weakness_detector_usecase.dart
//
// PART 2B (STRUCT-1): extracted from generate_plan_usecase.dart so each
// use case lives in its own file. WeaknessDetectorUseCase uses none of
// GeneratePlanUseCase's private members; the one cross-call
// (_applyCaFinalProgress) was made public (applyCaFinalProgress) for the split.

import 'dart:convert';
import 'package:isar/isar.dart'; // for .filter()/.writeTxn query extensions
import '../../data/local/isar/isar_service.dart'; // re-exports schemas
import 'package:shared_preferences/shared_preferences.dart';


// ═══════════════════════════════════════════════════════════════════════════════
// WEAKNESS DETECTOR USE CASE
// ═══════════════════════════════════════════════════════════════════════════════
class WeaknessDetectorUseCase {
  /// Top-N weak chapters (high weightage + low progress OR stale)
  static List<ChapterSchema> detectWeakChapters(
    List<ChapterSchema> chapters, {
    int topN = 5,
    double progressThreshold = 0.4,
  }) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final weak = chapters.where((c) {
      if (c.estimatedHours == 0) return false;
      final progress = (c.hoursSpent / c.estimatedHours).clamp(0.0, 1.0);
      final weightageNorm = c.weightage / 100.0;
      final isLowProgress =
          progress < progressThreshold && weightageNorm > 0.04;
      // High-weightage chapters that haven't been touched in 30 days
      final isStale = c.weightage >= 60 &&
          c.lastStudiedDate != null &&
          c.lastStudiedDate!.isBefore(thirtyDaysAgo) &&
          progress < 0.8;
      return isLowProgress || isStale;
    }).toList();

    weak.sort((a, b) {
      final aP = a.estimatedHours > 0
          ? (a.hoursSpent / a.estimatedHours).clamp(0.0, 1.0)
          : 0.0;
      final bP = b.estimatedHours > 0
          ? (b.hoursSpent / b.estimatedHours).clamp(0.0, 1.0)
          : 0.0;
      // Sort by weakness score = weightage × (1 - progress)
      return (b.weightage * (1 - bP)).compareTo(a.weightage * (1 - aP));
    });

    return weak.take(topN).toList();
  }

  /// Weighted overall completion percentage
  static double computeWeightedProgress(List<ChapterSchema> chapters) {
    if (chapters.isEmpty) return 0;
    double wProgress = 0, wTotal = 0;
    for (final c in chapters) {
      final p = c.estimatedHours > 0
          ? (c.hoursSpent / c.estimatedHours).clamp(0.0, 1.0)
          : 0.0;
      wProgress += p * c.weightage;
      wTotal += c.weightage;
    }
    return wTotal > 0 ? (wProgress / wTotal) * 100 : 0;
  }

  /// Per-subject weighted progress map (0.0–1.0)
  static Map<String, double> computeSubjectProgress(List<ChapterSchema> all) {
    final subjects = all.map((c) => c.subjectName).toSet();
    return {
      for (final s in subjects)
        s: computeWeightedProgress(
              all.where((c) => c.subjectName == s).toList(),
            ) /
            100,
    };
  }

  /// Streak from sorted study logs (pass all logs, most-recent first)
  static int calculateStreak(List<StudyLogSchema> logs) {
    if (logs.isEmpty) return 0;
    final uniqueDays = logs
        .map((l) =>
            DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    DateTime expected = DateTime(now.year, now.month, now.day);
    int streak = 0;

    for (final day in uniqueDays) {
      if (day == expected) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  // ── CA Final: pre-apply chapter progress from SharedPreferences ───────────
  // Reads granular chapter-level map first; falls back to paper-level.
  static Future<void> applyCaFinalProgress(
      List<ChapterSchema> chapters) async {
    if (chapters.isEmpty) return;
    final isCa = chapters.any((c) => c.syllabusSource == 'ca_final');
    if (!isCa) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // DATA-2 FIX (part 1): apply the onboarding snapshot EXACTLY ONCE.
      // It used to re-apply on every plan regeneration, overwriting months
      // of in-app progress with the stale onboarding state ("regenerate
      // plan → my finished chapter shows in_progress again").
      const appliedFlag = 'ca_onboarding_progress_applied_v1';
      if (prefs.getBool(appliedFlag) == true) return;

      final db = IsarService.db;

      // ── Chapter-level granularity (preferred) ──────────────────────────
      final chapterRaw = prefs.getString('ca_final_chapter_progress');
      if (chapterRaw != null) {
        final Map<String, dynamic> chapterMap =
            jsonDecode(chapterRaw) as Map<String, dynamic>;
        await db.writeTxn(() async {
          for (final ch in chapters) {
            // DATA-3 FIX: prefer stable chapterKey keys (new writer format).
            // Legacy positional '<classLevel>:<alphaIndex>' keys remain
            // readable for pre-fix installs — but since this whole method
            // now runs exactly once (DATA-2), a syllabus update can no
            // longer shift indices and corrupt the mapping afterwards.
            String? status = chapterMap[ch.chapterKey] as String?;
            if (status == null) {
              final sameSubject = chapters
                  .where((c) => c.classLevel == ch.classLevel)
                  .toList()
                ..sort((a, b) => a.name.compareTo(b.name));
              final idxInSubject = sameSubject.indexOf(ch);
              status = chapterMap['${ch.classLevel}:$idxInSubject'] as String?;
            }
            if (status == null) continue;
            _applyStatusToChapter(ch, status);
            await db.chapterSchemas.put(ch);
          }
        });
        await prefs.setBool(appliedFlag, true); // DATA-2 (part 1)
        return;
      }

      // ── Fallback: paper-level map ──────────────────────────────────────
      final paperRaw = prefs.getString('ca_final_paper_progress');
      if (paperRaw == null) return;
      final Map<String, dynamic> progressMap =
          jsonDecode(paperRaw) as Map<String, dynamic>;
      await db.writeTxn(() async {
        for (final ch in chapters) {
          final paperStatus =
              progressMap[ch.classLevel.toString()] as String?;
          if (paperStatus == null) continue;
          _applyStatusToChapter(ch, paperStatus);
          await db.chapterSchemas.put(ch);
        }
      });
      await prefs.setBool(appliedFlag, true); // DATA-2 (part 1)
    } catch (_) {
      // Non-fatal — planner continues normally without progress data
    }
  }

  /// DATA-2 FIX (part 2): UPGRADE-ONLY. The onboarding snapshot may raise a
  /// chapter's mastery, never lower it — previously 'in_progress' forced
  /// masteryLevel back to 2 even on a chapter the student had taken to 7.
  /// Pure & static so it is unit-testable (see stage1_regression_test.dart).
  static void _applyStatusToChapter(ChapterSchema ch, String status) {
    applyStatusUpgradeOnly(ch, status);
  }

  static void applyStatusUpgradeOnly(ChapterSchema ch, String status) {
    int targetLevel;
    switch (status) {
      case 'completed':
        targetLevel = 7;
        break;
      case 'revision_pending':
        targetLevel = 4;
        break;
      case 'in_progress':
        targetLevel = 2;
        break;
      case 'not_started':
      default:
        return;
    }
    if (targetLevel > ch.masteryLevel) {
      ch.masteryLevel = targetLevel;
      ch.status = status;
    }
    // else: in-app progress is ahead of the onboarding snapshot — keep it.
  }
}
