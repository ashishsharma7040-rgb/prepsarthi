// lib/domain/usecases/generate_plan_usecase.dart
//
// PEAKPREP INTELLIGENT PLANNER ENGINE
//
// Algorithm:
//  1. Score chapters: weightage × log10(estimatedHours + 1)
//  2. Allocate hours proportionally to priority score
//  3. Interleave subjects to avoid 3+ consecutive same-subject days
//  4. Distribute into calendar slots respecting daily hour cap
//  5. Buffer days every 7th study day (catch-up / rest)
//  6. Mock test Sundays from week 4
//  7. Spaced revision scheduling (7, 21, 45 days)

import 'dart:math' as math;
import 'package:isar/isar.dart';
import '../../data/local/isar/isar_service.dart';

class GeneratePlanUseCase {
  // ── Configurable constants (documented) ────────────────────────────────────
  static const double _effectiveHourRatio = 0.85; // 15% buffer for life events
  static const double _maxChapterHoursPerDay = 2.5; // max hours on one chapter per day
  static const int _bufferDayInterval = 7;          // buffer day every N study days
  static const int _mockTestStartWeek = 3;          // start mock tests after week N
  static const double _mockTestHours = 3.0;
  static const List<int> _revisionIntervals = [7, 21, 45]; // spaced repetition days
  static const List<double> _revisionDurationRatios = [0.30, 0.20, 0.15];

  Future<void> execute({
    required DateTime examDate,
    required double dailyStudyHours,
    required List<ChapterSchema> chapters,
    required List<DateTime> blackoutDates,
  }) async {
    final db = IsarService.db;
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final totalDays = examDate.difference(today).inDays;
    if (totalDays <= 0) throw Exception('Exam date must be in the future.');
    if (chapters.isEmpty) throw Exception('No chapters loaded. Run Syllabus Loader first.');

    // ── 1. Priority Scoring ──────────────────────────────────────────────────
    // priorityScore = weightage × log10(estimatedHours + 1)
    // Rationale: high-weight chapters get more time, log dampens extreme hour counts
    final scores = chapters
        .map((c) => c.weightage * math.log(c.estimatedHours + 1) / math.log(10))
        .toList();
    final totalScore = scores.fold<double>(0, (a, b) => a + b);
    if (totalScore == 0) throw Exception('All chapters have zero priority score.');

    // ── 2. Hour Allocation ────────────────────────────────────────────────────
    // Cap plan horizon to 180 days to avoid over-allocation on long timelines
    final planDays = math.min(totalDays, 180);
    final totalEffectiveHours = planDays * dailyStudyHours * _effectiveHourRatio;

    final allocatedHours = List<double>.generate(
      chapters.length,
      (i) => (scores[i] / totalScore) * totalEffectiveHours,
    );

    // ── 3. Sort by priority descending then interleave subjects ───────────────
    final sortedIndices = List<int>.generate(chapters.length, (i) => i)
      ..sort((a, b) => scores[b].compareTo(scores[a]));

    final interleaved = _interleaveBySubject(sortedIndices, chapters);

    // ── 4. Build blackout set ─────────────────────────────────────────────────
    final blackoutSet = blackoutDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    // ── 5. Distribute chapters into calendar slots ────────────────────────────
    final dailyBudget = <DateTime, double>{};
    final entries = <PlanEntrySchema>[];
    int studyDayCount = 0;

    DateTime cursor = today;

    bool isBlackout(DateTime d) => blackoutSet.contains(d);
    bool isBufferDay(int count) => count > 0 && count % _bufferDayInterval == 0;
    bool isMockDay(DateTime d, int count) =>
        d.weekday == DateTime.sunday && count >= _mockTestStartWeek * 7;

    DateTime nextValidDay(DateTime from) {
      var d = from.add(const Duration(days: 1));
      while (isBlackout(d)) {
        d = d.add(const Duration(days: 1));
      }
      return d;
    }

    for (final idx in interleaved) {
      final chapter = chapters[idx];
      double remaining = allocatedHours[idx];
      int orderIndex = 0;

      while (remaining > 0.05) {
        if (cursor.isAfter(examDate.subtract(const Duration(days: 1)))) break;

        // Skip buffer and mock days for new chapter learning
        if (isBufferDay(studyDayCount) || isMockDay(cursor, studyDayCount) || isBlackout(cursor)) {
          cursor = nextValidDay(cursor);
          studyDayCount++;
          continue;
        }

        final dateKey = DateTime(cursor.year, cursor.month, cursor.day);
        final used = dailyBudget[dateKey] ?? 0.0;
        final available = dailyStudyHours - used;

        if (available <= 0.05) {
          cursor = nextValidDay(cursor);
          studyDayCount++;
          continue;
        }

        final maxPerDay = math.min(_maxChapterHoursPerDay, dailyStudyHours * 0.6);
        final chunk = _round(math.min(math.min(maxPerDay, remaining), available));

        entries.add(PlanEntrySchema()
          ..chapterName = chapter.name
          ..subjectName = chapter.subjectName
          ..plannedDate = dateKey
          ..plannedHours = chunk
          ..orderIndex = orderIndex++
          ..isRevision = false
          ..status = 'pending');

        dailyBudget[dateKey] = used + chunk;
        remaining -= chunk;

        if ((dailyStudyHours - (dailyBudget[dateKey] ?? 0)) < 0.05) {
          cursor = nextValidDay(cursor);
          studyDayCount++;
        }
      }
    }

    // ── 6. Inject Mock Test Sundays ──────────────────────────────────────────
    final subjects = chapters.map((c) => c.subjectName).toSet().toList();
    int subjectRotation = 0;
    var mockCursor = today;
    // Advance to first Sunday
    while (mockCursor.weekday != DateTime.sunday) {
      mockCursor = mockCursor.add(const Duration(days: 1));
    }
    // Skip first 3 weeks
    mockCursor = mockCursor.add(const Duration(days: 21));

    while (mockCursor.isBefore(examDate)) {
      final dateKey = DateTime(mockCursor.year, mockCursor.month, mockCursor.day);
      if (!isBlackout(dateKey)) {
        entries.add(PlanEntrySchema()
          ..chapterName = 'Mock Test – ${subjects[subjectRotation % subjects.length]}'
          ..subjectName = subjects[subjectRotation % subjects.length]
          ..plannedDate = dateKey
          ..plannedHours = _mockTestHours
          ..orderIndex = 99
          ..isRevision = false
          ..isMockTest = true
          ..mockTestSubject = subjects[subjectRotation % subjects.length]
          ..status = 'pending');
        subjectRotation++;
      }
      mockCursor = mockCursor.add(const Duration(days: 7));
    }

    // ── 7. Persist ────────────────────────────────────────────────────────────
    await db.writeTxn(() async {
      await db.planEntrySchemas.clear();
      await db.planEntrySchemas.putAll(entries);
    });
  }

  // ── Subject Interleaving ──────────────────────────────────────────────────
  // Prevents 3+ consecutive days of the same subject
  static List<int> _interleaveBySubject(
      List<int> sortedIndices, List<ChapterSchema> chapters) {
    // Group indices by subject while preserving within-subject priority order
    final subjectGroups = <String, List<int>>{};
    for (final i in sortedIndices) {
      final s = chapters[i].subjectName;
      subjectGroups.putIfAbsent(s, () => []).add(i);
    }

    // Round-robin across subjects
    final result = <int>[];
    bool anyAdded = true;
    while (anyAdded) {
      anyAdded = false;
      for (final key in subjectGroups.keys) {
        if (subjectGroups[key]!.isNotEmpty) {
          result.add(subjectGroups[key]!.removeAt(0));
          anyAdded = true;
        }
      }
    }
    return result;
  }

  // ── Spaced Revision Scheduling ────────────────────────────────────────────
  static Future<void> scheduleRevisions({
    required String chapterName,
    required String subjectName,
    required DateTime learnedDate,
    required double estimatedHours,
  }) async {
    final db = IsarService.db;

    // Check if revision schedule already exists
    final existing = await db.revisionScheduleSchemas
        .filter()
        .chapterNameEqualTo(chapterName)
        .findFirst();

    final revisionDates = _revisionIntervals
        .map((d) => learnedDate.add(Duration(days: d)))
        .toList();

    final durations = _revisionDurationRatios
        .map((r) => (estimatedHours * r).clamp(0.5, 2.5))
        .toList();

    // Upsert revision schedule
    final schedule = existing ?? RevisionScheduleSchema();
    schedule.chapterName = chapterName;
    schedule.subjectName = subjectName;
    schedule.firstLearnedDate = learnedDate;
    schedule.scheduledDates = revisionDates;
    schedule.completedDates = [];
    schedule.completedCount = 0;
    schedule.isFullyRevised = false;
    schedule.active = true;

    await db.writeTxn(() async {
      await db.revisionScheduleSchemas.put(schedule);
    });

    // Insert revision entries in plan (don't duplicate)
    final today = DateTime.now();
    final revEntries = <PlanEntrySchema>[];
    for (int i = 0; i < _revisionIntervals.length; i++) {
      final revDate = revisionDates[i];
      if (revDate.isBefore(today)) continue;

      // Check if already exists
      final exists = await db.planEntrySchemas
          .filter()
          .chapterNameEqualTo(chapterName)
          .and()
          .plannedDateEqualTo(DateTime(revDate.year, revDate.month, revDate.day))
          .and()
          .isRevisionEqualTo(true)
          .count();

      if (exists == 0) {
        revEntries.add(PlanEntrySchema()
          ..chapterName = chapterName
          ..subjectName = subjectName
          ..plannedDate = DateTime(revDate.year, revDate.month, revDate.day)
          ..plannedHours = _round(durations[i])
          ..orderIndex = 50 + i
          ..isRevision = true
          ..revisionOf = chapterName
          ..status = 'pending');
      }
    }

    if (revEntries.isNotEmpty) {
      await db.writeTxn(() async {
        await db.planEntrySchemas.putAll(revEntries);
      });
    }
  }

  static double _round(double v) => (v * 10).round() / 10;
}

// ═══════════════════════════════════════════════════════════════════════════════
// WEAKNESS DETECTOR USECASE
// ═══════════════════════════════════════════════════════════════════════════════
class WeaknessDetectorUseCase {
  /// Returns top-N weak chapters.
  /// Weak = high weightage + low progress OR not touched in 30+ days
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
      final isLowProgress = progress < progressThreshold && weightageNorm > 0.04;
      // Also flag: high-weightage chapters not touched in 30 days
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

  /// Weighted overall completion % across all chapters
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

  /// Per-subject weighted progress map
  static Map<String, double> computeSubjectProgress(
      List<ChapterSchema> all) {
    final subjects = all.map((c) => c.subjectName).toSet();
    return {
      for (final s in subjects)
        s: computeWeightedProgress(
          all.where((c) => c.subjectName == s).toList(),
        ) / 100,
    };
  }

  /// Streak from sorted study logs (pass all logs, most-recent first)
  static int calculateStreak(List<StudyLogSchema> logs) {
    if (logs.isEmpty) return 0;

    // Deduplicate to unique calendar days — fixes over-counting when
    // multiple sessions are logged on the same day.
    final uniqueDays = logs
        .map((l) => DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // newest first

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
}
