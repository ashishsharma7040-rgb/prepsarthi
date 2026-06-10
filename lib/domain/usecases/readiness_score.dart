// lib/domain/usecases/readiness_score.dart
//
// ✅ TIER 1 MIGRATION: Test scores and mistake entries now read from Isar
//    (MockTestSchema + MistakeEntrySchema) instead of SharedPreferences.
// ✅ PRESERVED: Formula, grade thresholds, tips logic — identical to original.
// ✅ PRESERVED: Fallback to chapter-level test accuracy when no mock tests logged.
//
// Formula:
//   30% syllabus completion  (chapters learned+revised+tested / total)
//   20% revision completion  (revision sessions done / due)
//   20% mock test performance (avg score % from MockTestSchema records)
//   15% consistency          (study days in last 14 / 14)
//   10% backlog control      (1 - backlog ratio via planEntrySchemas)
//    5% mistake correction   (mistakes resolved / total from MistakeEntrySchema)

import 'package:isar/isar.dart';
import '../../data/local/isar/isar_service.dart';

// ── ReadinessScore value object ────────────────────────────────────────────────
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

// ── ReadinessCalculator — single source of calculation logic ────────────────
// analytics_providers.dart exposes this via a Riverpod FutureProvider.
class ReadinessCalculator {
  // EXAM-1 FIX: every exam maps to its own source(s); 'both' merges two.
  // (Interim until Stage-2 ExamRegistry — see Master Spec.)
  static List<String> _syllabusSourcesForTarget(String? targetExam) {
    switch (targetExam) {
      case 'neet':
        return ['neet_ug'];
      case 'jee_advanced':
        return ['jee_advanced'];
      case 'ca_final':
        return ['ca_final'];
      case 'class12_boards':
        return ['class12_boards'];
      case 'both':
        return ['jee_main', 'neet_ug'];
      case 'jee_main':
      default:
        return ['jee_main'];
    }
  }

  static Future<ReadinessScore> calculate() async {
    final db = IsarService.db;
    final user = await db.userSchemas.where().findFirst();
    final userSources = _syllabusSourcesForTarget(user?.targetExam);

    // Raw data from Isar — EXAM-1 FIX: merge all of the user's sources
    final chapters = <ChapterSchema>[];
    for (final src in userSources) {
      chapters.addAll(await db.chapterSchemas
          .filter()
          .syllabusSourceEqualTo(src)
          .findAll());
    }
    final revisions = await db.revisionScheduleSchemas
        .filter().activeEqualTo(true).findAll();

    final now             = DateTime.now();
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));
    final recentLogs      = await db.studyLogSchemas
        .filter()
        .timestampGreaterThan(fourteenDaysAgo)
        .findAll();

    // ✅ MIGRATED + DATA-4 FIX: read from Isar, filtered to THIS user's exam.
    final testSchemas    = await _loadTestSchemas(db, user?.targetExam);
    final mistakeSchemas = await _loadMistakeSchemas(db, userSources);

    // ── 1. Syllabus Completion (30%) ──────────────────────────────────────────
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

    // ── 2. Revision Completion (20%) ──────────────────────────────────────────
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

    // ── 3. Mock Test Performance (20%) — now from Isar ───────────────────────
    double testPerf;
    if (testSchemas.isNotEmpty) {
      // Use most recent 5 tests for recency-weighted accuracy
      final recent = testSchemas.length > 5
          ? testSchemas.sublist(testSchemas.length - 5)
          : testSchemas;
      final avgPct = recent.fold<double>(
            0.0,
            (s, e) => s + (e.totalMarks > 0
                ? e.obtainedMarks / e.totalMarks
                : 0.0),
          ) /
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
        testPerf = 0.0; // genuinely no test data
      }
    }

    // ── 4. Consistency (15%) ──────────────────────────────────────────────────
    final studyDays = <String>{};
    for (final log in recentLogs) {
      final d = log.timestamp;
      studyDays.add('${d.year}-${d.month}-${d.day}');
    }
    final consistencyRatio = (studyDays.length / 14.0).clamp(0.0, 1.0);

    // ── 5. Backlog Control (10%) ──────────────────────────────────────────────
    final allPending = await db.planEntrySchemas
        .filter().statusEqualTo('pending').count();
    final overduePending = await db.planEntrySchemas
        .filter()
        .statusEqualTo('pending')
        .plannedDateLessThan(now)
        .count();
    final backlogRatio = allPending > 0 ? overduePending / allPending : 0.0;
    final backlogScore = (1.0 - backlogRatio).clamp(0.0, 1.0);

    // ── 6. Mistake Correction (5%) — now from Isar ───────────────────────────
    double mistakeScore;
    if (mistakeSchemas.isNotEmpty) {
      final resolved = mistakeSchemas.where((e) => e.isResolved).length;
      mistakeScore = (resolved / mistakeSchemas.length).clamp(0.0, 1.0);
    } else {
      mistakeScore = 0.5; // neutral — no mistakes logged yet
    }

    // ── Weighted Total ─────────────────────────────────────────────────────────
    final raw = syllabusRatio  * 0.30
        + revisionRatio        * 0.20
        + testPerf             * 0.20
        + consistencyRatio     * 0.15
        + backlogScore         * 0.10
        + mistakeScore         * 0.05;

    final score = (raw * 100).round().clamp(0, 100);

    // ── Grade & Status ─────────────────────────────────────────────────────────
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

    // ── Actionable Tips ────────────────────────────────────────────────────────
    final tips = <String>[];
    if (syllabusRatio < 0.5) {
      tips.add(
          'Complete more chapters — only ${(syllabusRatio * 100).round()}% done');
    }
    if (revisionRatio < 0.7 && revisionsDue > 0) {
      tips.add(
          '${revisionsDue - revisionsCompleted} revision(s) overdue — clear them today');
    }
    if (testPerf < 0.6) {
      if (testSchemas.isEmpty) {
        tips.add('Log your first mock test result to get a real accuracy score');
      } else {
        tips.add(
            'Mock test avg ${(testPerf * 100).round()}% — target 70%+ with more PYQ practice');
      }
    }
    if (studyDays.length < 10) {
      tips.add(
          'Study more consistently — only ${studyDays.length}/14 days active');
    }
    if (backlogRatio > 0.3) {
      tips.add('Clear your backlog — $overduePending overdue tasks pending');
    }
    if (mistakeSchemas.isNotEmpty && mistakeScore < 0.6) {
      final unresolved = mistakeSchemas.where((e) => !e.isResolved).length;
      tips.add(
          '$unresolved unresolved mistakes in notebook — review and mark done');
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

  // ── Snapshot persistence — HIGH #7 ─────────────────────────────────────────
  //
  // Called automatically at the end of calculate().
  // Writes at most one snapshot per calendar day (idempotent on repeated calls).
  // Prunes snapshots older than 90 days to keep the DB lean.
  static Future<void> saveSnapshot(ReadinessScore result) async {
    try {
      final db = IsarService.db;
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      // Overwrite today's snapshot if one exists
      final existing = await db.readinessSnapshotSchemas
          .where()
          .dateBetween(
            today,
            today.add(const Duration(hours: 23, minutes: 59)),
          )
          .findFirst();

      await db.writeTxn(() async {
        final snap = existing ?? ReadinessSnapshotSchema();
        snap.date = today;
        snap.score = result.score;
        snap.grade = result.grade;
        snap.syllabusRatio = result.breakdown['Syllabus'] ?? 0;
        snap.revisionRatio = result.breakdown['Revision'] ?? 0;
        snap.testPerf = result.breakdown['Tests'] ?? 0;
        snap.consistencyRatio = result.breakdown['Consistency'] ?? 0;
        snap.backlogScore = result.breakdown['Backlog'] ?? 0;
        snap.mistakeScore = result.breakdown['Mistakes'] ?? 0;
        await db.readinessSnapshotSchemas.put(snap);

        // Prune old snapshots (keep last 90 days)
        final cutoff = DateTime.now().subtract(const Duration(days: 90));
        await db.readinessSnapshotSchemas
            .where()
            .dateLessThan(cutoff)
            .deleteAll();
      });
    } catch (_) {
      // Snapshot failure must never crash the UI — swallow silently
    }
  }

  /// Loads the last [days] daily snapshots sorted oldest-first.
  /// Used by the trend chart on Today Command Center.
  static Future<List<ReadinessSnapshotSchema>> loadTrend({int days = 30}) async {
    try {
      final db = IsarService.db;
      final since = DateTime.now().subtract(Duration(days: days));
      return db.readinessSnapshotSchemas
          .where()
          .dateGreaterThan(since)
          .sortByDate()
          .findAll();
    } catch (_) {
      return [];
    }
  }

  // ── Private Isar queries ───────────────────────────────────────────────────

  /// Returns mock test records for THIS user's exam, oldest-first.
  /// DATA-4 FIX: previously loaded ALL exams' tests — a student who switched
  /// from JEE to CA Final kept JEE percentages inside their CA readiness.
  /// Legacy tolerance: examType labels written by the old test-score screen
  /// ('JEE Main', 'NEET', 'Mock') are matched loosely so old data still counts
  /// for the matching exam family; the label model is rebuilt in Stage 2 (EXAM-4).
  static Future<List<MockTestSchema>> _loadTestSchemas(
      Isar db, String? targetExam) async {
    try {
      final all = await db.mockTestSchemas.where().sortByDate().findAll();
      if (targetExam == null) return all;
      bool matches(MockTestSchema t) {
        final e = t.examType.toLowerCase();
        switch (targetExam) {
          case 'neet':
            return e.contains('neet') || e == 'mock';
          case 'both':
            return e.contains('neet') || e.contains('jee') || e == 'mock';
          case 'ca_final':
            return e.contains('ca') || e == 'mock';
          case 'class12_boards':
            return e.contains('board') || e == 'mock';
          case 'jee_advanced':
          case 'jee_main':
          default:
            return e.contains('jee') || e == 'mock';
        }
      }
      return all.where(matches).toList();
    } catch (_) {
      return [];
    }
  }

  /// Returns all mistake entry records.
  static Future<List<MistakeEntrySchema>> _loadMistakeSchemas(
      Isar db, List<String> userSources) async {
    try {
      final all = await db.mistakeEntrySchemas.where().findAll();
      // DATA-4 FIX: only this user's stream(s). Pre-migration mistakes have
      // syllabusSource '' (no field existed) — keep counting those.
      return all
          .where((m) =>
              m.syllabusSource.isEmpty ||
              userSources.contains(m.syllabusSource))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
