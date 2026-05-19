// lib/domain/usecases/readiness_score.dart
//
// ✅ FIXED: Correct relative imports (was ../data/... → ../../data/...)
// ✅ FIXED: Uses barrel schemas.dart (covers planEntrySchema — no missing import)
// ✅ FIXED: testPerf from real TestEntry SharedPrefs data (no more hardcoded 0.6)
// ✅ FIXED: mistakeScore from real MistakeEntry SharedPrefs data (no more hardcoded 0.7)
// ✅ This is the SINGLE readiness engine. analytics_providers.dart wraps it via FutureProvider.
//
// Formula:
//   30% syllabus completion  (chapters learned+revised+tested / total)
//   20% revision completion  (revision sessions done / due)
//   20% mock test performance (avg score % from real TestEntry records)
//   15% consistency          (study days in last 14 / 14)
//   10% backlog control      (1 - backlog ratio via planEntrySchemas)
//    5% mistake correction   (mistakes resolved / total from MistakeEntry records)
//
// ── PRODUCTION ROADMAP TODO ──────────────────────────────────────────────────
//
// SharedPreferences is acceptable for beta but NOT for a serious paid app.
// Before Play Store full release, migrate test and mistake data to Isar:
//
//   TODO(production): Create MockTestSchema in isar/schemas/
//     Fields: id, examName, totalMarks, obtainedMarks, date, subject, notes
//     Replace _loadTestEntries() SharedPrefs read with:
//       db.mockTestSchemas.where().sortByDateDesc().limit(5).findAll()
//
//   TODO(production): Create MistakeEntrySchema in isar/schemas/
//     Fields: id, subject, topic, description, isResolved, resolvedAt, createdAt
//     Replace _loadMistakeEntries() SharedPrefs read with:
//       db.mistakeEntrySchemas.where().findAll()
//
//   TODO(production): Create PYQProgressSchema in isar/schemas/
//     Fields: id, year, subject, paperId, correctCount, totalCount, attemptedAt
//     Use for PYQ completion tracking instead of SharedPreferences.
//
//   TODO(production): Create ReadinessSnapshotSchema in isar/schemas/
//     Fields: id, score, grade, breakdown (as JSON), computedAt
//     Cache last computed ReadinessScore to avoid re-computing on every build.
//     Invalidate when study logs, test entries, or mistake entries change.
//
// See: docs/PRODUCTION_ROADMAP.md for migration order and schema definitions.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ✅ FIXED: correct path — file lives in lib/domain/usecases/, data is at lib/data/
import '../../data/local/isar/isar_service.dart';
// ✅ FIXED: barrel covers chapter, study_log, revision_schedule, user, plan_entry
import '../../data/local/isar/schemas/schemas.dart';

// Shared-prefs keys — must match the screens that write them
const _kTestScoresKey = 'prepsarthi_test_scores_v1'; // test_score_screen.dart
const _kMistakesKey   = 'prepsarthi_mistakes_v1';    // mistake_notebook_screen.dart

// ── ReadinessScore value object ───────────────────────────────────────────────
class ReadinessScore {
  final int score;                      // 0–100
  final String grade;                   // S / A / B / C / D
  final String status;                  // human-readable label
  final String color;                   // 'green' | 'yellow' | 'orange' | 'red'
  final Map<String, double> breakdown;  // component name → 0.0–1.0
  final List<String> tips;              // up to 3 actionable tips

  const ReadinessScore({
    required this.score,
    required this.grade,
    required this.status,
    required this.color,
    required this.breakdown,
    required this.tips,
  });

  String get advice => tips.isNotEmpty ? tips.first : status;

  static const empty = ReadinessScore(
    score: 0,
    grade: 'D',
    status: 'No Data Yet',
    color: 'red',
    breakdown: {},
    tips: ['Complete onboarding and log your first study session to see your score.'],
  );
}

// ── ReadinessCalculator — single source of calculation logic ─────────────────
// analytics_providers.dart should expose this via a Riverpod FutureProvider
// rather than duplicating formulas.
class ReadinessCalculator {
  static Future<ReadinessScore> calculate() async {
    final db = IsarService.db;

    // Raw data
    final chapters  = await db.chapterSchemas.where().findAll();
    final revisions = await db.revisionScheduleSchemas
        .filter().activeEqualTo(true).findAll();

    final now             = DateTime.now();
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));
    final recentLogs      = await db.studyLogSchemas
        .filter()
        .timestampGreaterThan(fourteenDaysAgo)
        .findAll();

    // ✅ REAL data from SharedPreferences
    final testEntries    = await _loadTestEntries();
    final mistakeEntries = await _loadMistakeEntries();

    // ── 1. Syllabus Completion (30%) ─────────────────────────────────────────
    final totalChapters = chapters.length;
    int completedChapters = 0;
    for (final c in chapters) {
      if (c.status == 'learned' ||
          c.status == 'revised'  ||
          c.status == 'tested'   ||
          c.masteryLevel >= 3) {
        completedChapters++;
      }
    }
    final syllabusRatio = totalChapters > 0
        ? (completedChapters / totalChapters).clamp(0.0, 1.0)
        : 0.0;

    // ── 2. Revision Completion (20%) ─────────────────────────────────────────
    int revisionsDue       = 0;
    int revisionsCompleted = 0;
    for (final r in revisions) {
      for (final d in r.scheduledDates) {
        if (d.isBefore(now)) {
          revisionsDue++;
          final done = r.completedDates.any((c) =>
              c.year == d.year && c.month == d.month && c.day == d.day);
          if (done) revisionsCompleted++;
        }
      }
    }
    final revisionRatio = revisionsDue > 0
        ? (revisionsCompleted / revisionsDue).clamp(0.0, 1.0)
        : 1.0;

    // ── 3. Mock Test Performance (20%) ✅ REAL DATA ──────────────────────────
    double testPerf;
    if (testEntries.isNotEmpty) {
      // Use most recent 5 tests for recency-weighted accuracy
      final recent = testEntries.length > 5
          ? testEntries.sublist(testEntries.length - 5)
          : testEntries;
      final avgPct = recent.fold<double>(
            0.0,
            (s, e) {
              final total    = (e['totalMarks'] as num?)?.toInt() ?? 0;
              final obtained = (e['obtained']   as num?)?.toInt() ?? 0;
              return s + (total > 0 ? obtained / total : 0.0);
            }) /
          recent.length;
      testPerf = avgPct.clamp(0.0, 1.0);
    } else {
      // Fallback: chapter-level test accuracy from Isar
      final testedChapters = chapters.where((c) => c.testAttempts > 0).toList();
      if (testedChapters.isNotEmpty) {
        final avgAccuracy = testedChapters.fold<double>(
                0.0, (s, c) => s + c.testAccuracy) /
            testedChapters.length;
        testPerf = (avgAccuracy / 100.0).clamp(0.0, 1.0);
      } else {
        testPerf = 0.0; // genuinely no test data — no fake constant
      }
    }

    // ── 4. Consistency (15%) ─────────────────────────────────────────────────
    final studyDays = <String>{};
    for (final log in recentLogs) {
      final d = log.timestamp;
      studyDays.add('${d.year}-${d.month}-${d.day}');
    }
    final consistencyRatio = (studyDays.length / 14.0).clamp(0.0, 1.0);

    // ── 5. Backlog Control (10%) ─────────────────────────────────────────────
    // planEntrySchemas available via schemas.dart barrel ✅
    final allPending = await db.planEntrySchemas
        .filter().statusEqualTo('pending').count();
    final overduePending = await db.planEntrySchemas
        .filter()
        .statusEqualTo('pending')
        .plannedDateLessThan(now)
        .count();
    final backlogRatio = allPending > 0 ? overduePending / allPending : 0.0;
    final backlogScore = (1.0 - backlogRatio).clamp(0.0, 1.0);

    // ── 6. Mistake Correction (5%) ✅ REAL DATA ──────────────────────────────
    double mistakeScore;
    if (mistakeEntries.isNotEmpty) {
      final resolved = mistakeEntries
          .where((e) => e['isResolved'] == true)
          .length;
      mistakeScore = (resolved / mistakeEntries.length).clamp(0.0, 1.0);
    } else {
      mistakeScore = 0.5; // neutral — no mistakes logged yet, not a penalty
    }

    // ── Weighted Total ────────────────────────────────────────────────────────
    final raw = syllabusRatio  * 0.30
        + revisionRatio        * 0.20
        + testPerf             * 0.20
        + consistencyRatio     * 0.15
        + backlogScore         * 0.10
        + mistakeScore         * 0.05;

    final score = (raw * 100).round().clamp(0, 100);

    // ── Grade & Status ────────────────────────────────────────────────────────
    String grade, status, color;
    if (score >= 85) {
      grade = 'S'; status = 'Excellent Preparation'; color = 'green';
    } else if (score >= 70) {
      grade = 'A'; status = 'Strong Preparation';    color = 'green';
    } else if (score >= 55) {
      grade = 'B'; status = 'Good Progress';          color = 'yellow';
    } else if (score >= 40) {
      grade = 'C'; status = 'Needs Focus';            color = 'orange';
    } else {
      grade = 'D'; status = 'Critical — Act Now';     color = 'red';
    }

    // ── Actionable Tips ───────────────────────────────────────────────────────
    final tips = <String>[];
    if (syllabusRatio < 0.5) {
      tips.add('Complete more chapters — only ${(syllabusRatio * 100).round()}% done');
    }
    if (revisionRatio < 0.7 && revisionsDue > 0) {
      tips.add('${revisionsDue - revisionsCompleted} revision(s) overdue — clear them today');
    }
    if (testPerf < 0.6) {
      if (testEntries.isEmpty) {
        tips.add('Log your first mock test result to get a real accuracy score');
      } else {
        tips.add('Mock test avg ${(testPerf * 100).round()}% — target 70%+ with more PYQ practice');
      }
    }
    if (studyDays.length < 10) {
      tips.add('Study more consistently — only ${studyDays.length}/14 days active');
    }
    if (backlogRatio > 0.3) {
      tips.add('Clear your backlog — $overduePending overdue tasks pending');
    }
    if (mistakeEntries.isNotEmpty && mistakeScore < 0.6) {
      final unresolved = mistakeEntries.where((e) => e['isResolved'] != true).length;
      tips.add('$unresolved unresolved mistakes in notebook — review and mark done');
    }
    if (tips.isEmpty) tips.add("Keep it up! You're on a great track.");

    return ReadinessScore(
      score: score,
      grade: grade,
      status: status,
      color: color,
      breakdown: {
        'Syllabus':    syllabusRatio,
        'Revision':    revisionRatio,
        'Tests':       testPerf,
        'Consistency': consistencyRatio,
        'Backlog':     backlogScore,
        'Mistakes':    mistakeScore,
      },
      tips: tips.take(3).toList(),
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> _loadTestEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_kTestScoresKey) ?? [];
      return raw.map((s) {
        try { return jsonDecode(s) as Map<String, dynamic>; }
        catch (_) { return <String, dynamic>{}; }
      }).where((e) => e.isNotEmpty && e.containsKey('totalMarks')).toList();
    } catch (_) { return []; }
  }

  static Future<List<Map<String, dynamic>>> _loadMistakeEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_kMistakesKey) ?? [];
      return raw.map((s) {
        try { return jsonDecode(s) as Map<String, dynamic>; }
        catch (_) { return <String, dynamic>{}; }
      }).where((e) => e.isNotEmpty).toList();
    } catch (_) { return []; }
  }
}
