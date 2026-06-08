// lib/domain/usecases/generate_plan_usecase.dart
//
// PREPSARTHI INTELLIGENT PLANNER ENGINE — v4 "Exam-Specific Best Plan"
//
// ✅ Per-exam logic: JEE Main/Advanced, NEET UG, Class 12 Boards, CA Final
// ✅ Phase 1 (syllabus coverage) + Phase 2 (revision/mocks) fully separated
// ✅ Applies existing CA Final progress before generating new slots
// ✅ Filters already-mastered chapters — no redundant allocation
// ✅ Weakness detection + boost, pace mode (relaxed/balanced/aggressive)
// ✅ Subject interleaving, buffer days, mock test injection
// ✅ Spaced revision scheduling (7, 21, 45 days)
// ✅ scheduleRevisions: idempotent, never creates duplicates

import 'dart:convert';
import 'dart:math' as math;
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/local/isar/isar_service.dart';

// ── Exam-specific planner configuration ──────────────────────────────────────
class _PlanConfig {
  final double effectiveHourRatio;
  final double maxChapterHoursPerDay;
  final int bufferDayInterval;
  final int mockTestStartWeek; // weeks from today before first mock
  final double mockTestHours;
  final int phase2BufferDays; // how many days before exam Phase 2 starts
  final int phase2MockIntervalDays;

  const _PlanConfig({
    required this.effectiveHourRatio,
    required this.maxChapterHoursPerDay,
    required this.bufferDayInterval,
    required this.mockTestStartWeek,
    required this.mockTestHours,
    required this.phase2BufferDays,
    required this.phase2MockIntervalDays,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// GENERATE PLAN USE CASE
// ═══════════════════════════════════════════════════════════════════════════════
class GeneratePlanUseCase {
  static const List<int> _revisionIntervals = [7, 21, 45];
  static const List<double> _revisionDurationRatios = [0.30, 0.20, 0.15];

  // ── Per-exam configuration ─────────────────────────────────────────────────
  static _PlanConfig _configFor(String examType) {
    switch (examType) {
      case 'ca_final':
        // CA Final: 6 papers, 2 groups, intensive case-study paper (IBS)
        // Needs more weeks before first mock (foundation required)
        return const _PlanConfig(
          effectiveHourRatio: 0.82,
          maxChapterHoursPerDay: 2.5,
          bufferDayInterval: 7,
          mockTestStartWeek: 6,
          mockTestHours: 3.0,
          phase2BufferDays: 28,
          phase2MockIntervalDays: 5,
        );
      case 'neet':
        // NEET: Biology = 2x marks. 3h 20min exam. NCERT-heavy.
        return const _PlanConfig(
          effectiveHourRatio: 0.87,
          maxChapterHoursPerDay: 2.0,
          bufferDayInterval: 7,
          mockTestStartWeek: 4,
          mockTestHours: 3.5,
          phase2BufferDays: 21,
          phase2MockIntervalDays: 5,
        );
      case 'jee_advanced':
        // JEE Advanced: harder, needs deep problem solving
        return const _PlanConfig(
          effectiveHourRatio: 0.88,
          maxChapterHoursPerDay: 3.0,
          bufferDayInterval: 7,
          mockTestStartWeek: 4,
          mockTestHours: 3.0,
          phase2BufferDays: 21,
          phase2MockIntervalDays: 5,
        );
      case 'class12_boards':
        // Boards: 5-6 subjects, needs consistent revision
        return const _PlanConfig(
          effectiveHourRatio: 0.80,
          maxChapterHoursPerDay: 2.5,
          bufferDayInterval: 7,
          mockTestStartWeek: 6,
          mockTestHours: 3.0,
          phase2BufferDays: 35,
          phase2MockIntervalDays: 7,
        );
      case 'jee_main':
      default:
        return const _PlanConfig(
          effectiveHourRatio: 0.85,
          maxChapterHoursPerDay: 2.5,
          bufferDayInterval: 7,
          mockTestStartWeek: 3,
          mockTestHours: 3.0,
          phase2BufferDays: 21,
          phase2MockIntervalDays: 5,
        );
    }
  }

  // ── Main execute ───────────────────────────────────────────────────────────
  Future<void> execute({
    required DateTime examDate,
    required double dailyStudyHours,
    required List<ChapterSchema> chapters,
    required List<DateTime> blackoutDates,
    DateTime? syllabusCompletionTargetDate,
    String paceMode = 'balanced',
    Map<String, double> weakSubjectBoost = const {},
  }) async {
    final db = IsarService.db;
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final totalDays = examDate.difference(today).inDays;
    if (totalDays <= 0) throw Exception('Exam date must be in the future.');
    if (chapters.isEmpty)
      throw Exception('No chapters loaded. Run Syllabus Loader first.');

    // 1. Detect exam type from chapters' syllabusSource
    final examType = _examTypeFromChapters(chapters);
    final config = _configFor(examType);
    final isCaFinal = examType == 'ca_final';

    // 2. Apply existing CA Final progress from onboarding SharedPreferences
    if (isCaFinal) {
      await WeaknessDetectorUseCase._applyCaFinalProgress(chapters);
    }

    // 3. Separate IBS (CA Final Paper 6 case-study) — handled as special mocks
    final ibsChapters = isCaFinal
        ? chapters
            .where((c) =>
                c.tags.contains('case-study') &&
                c.syllabusSource == 'ca_final' &&
                c.classLevel == 6)
            .toList()
        : <ChapterSchema>[];

    final allStudyChapters = chapters
        .where((c) =>
            !(isCaFinal &&
                c.tags.contains('case-study') &&
                c.syllabusSource == 'ca_final' &&
                c.classLevel == 6))
        .toList();

    // 4. Filter out already mastered/completed chapters (respects existing work)
    final activeChapters = allStudyChapters.where((c) {
      final progress = c.estimatedHours > 0
          ? (c.hoursSpent / c.estimatedHours).clamp(0.0, 1.0)
          : 0.0;
      // Exclude chapters that are truly done
      return !(c.masteryLevel >= 7 ||
          c.status == 'completed' ||
          progress >= 0.90);
    }).toList();

    final studyChapters =
        activeChapters.isNotEmpty ? activeChapters : allStudyChapters;

    // 5. Pace mode → effective hour ratio
    final double effectiveRatio;
    switch (paceMode.toLowerCase()) {
      case 'aggressive':
        effectiveRatio = 0.93;
        break;
      case 'relaxed':
        effectiveRatio = 0.75;
        break;
      default:
        effectiveRatio = config.effectiveHourRatio;
    }

    // 6. Phase boundary (Phase 1 = learn, Phase 2 = revise + mock)
    final syllabusPhaseEnd = syllabusCompletionTargetDate ??
        examDate.subtract(Duration(days: config.phase2BufferDays));

    // 7. Priority scoring (exam-type aware)
    final scores = studyChapters
        .map((c) => _scoreChapter(c, examType, weakSubjectBoost))
        .toList();

    final totalScore = scores.fold<double>(0, (a, b) => a + b);
    if (totalScore == 0)
      throw Exception('All chapters have zero priority score.');

    // 8. Hour allocation proportional to priority score
    final planDays = math.min(totalDays, 180);
    final totalEffectiveHours = planDays * dailyStudyHours * effectiveRatio;

    final allocatedHours = List<double>.generate(
      studyChapters.length,
      (i) => (scores[i] / totalScore) * totalEffectiveHours,
    );

    // 9. Sort by priority descending + interleave subjects
    final sortedIndices =
        List<int>.generate(studyChapters.length, (i) => i)
          ..sort((a, b) => scores[b].compareTo(scores[a]));
    final interleaved = _interleaveBySubject(sortedIndices, studyChapters);

    // 10. Build blackout set
    final blackoutSet =
        blackoutDates.map((d) => DateTime(d.year, d.month, d.day)).toSet();

    // 11. Distribute chapters into calendar slots
    final dailyBudget = <DateTime, double>{};
    final entries = <PlanEntrySchema>[];
    int studyDayCount = 0;
    DateTime cursor = today;

    bool isBlackout(DateTime d) => blackoutSet.contains(d);
    bool isBufferDay(int count) =>
        count > 0 && count % config.bufferDayInterval == 0;
    bool isPhase1(DateTime d) =>
        !d.isAfter(syllabusPhaseEnd);

    bool isMockDay(DateTime d, int count) {
      if (d.weekday != DateTime.sunday) return false;
      final weekThreshold = isPhase1(d)
          ? config.mockTestStartWeek * 7
          : 0; // Phase 2: every Sunday is mock
      return count >= weekThreshold;
    }

    DateTime nextValidDay(DateTime from) {
      var d = from.add(const Duration(days: 1));
      while (isBlackout(d)) d = d.add(const Duration(days: 1));
      return d;
    }

    for (final idx in interleaved) {
      final chapter = studyChapters[idx];
      double remaining = allocatedHours[idx];
      int orderIndex = 0;

      while (remaining > 0.05) {
        if (cursor.isAfter(examDate.subtract(const Duration(days: 1)))) break;

        final inPhase1 = isPhase1(cursor);

        final shouldSkip = isBlackout(cursor) ||
            (inPhase1 &&
                (isBufferDay(studyDayCount) ||
                    isMockDay(cursor, studyDayCount)));

        if (shouldSkip) {
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

        final maxPerDay = inPhase1
            ? math.min(config.maxChapterHoursPerDay, dailyStudyHours * 0.60)
            : math.min(
                config.maxChapterHoursPerDay + 0.5, dailyStudyHours * 0.75);

        final chunk =
            _round(math.min(math.min(maxPerDay, remaining), available));

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

    // 12. Phase 1 mock tests (weekly, rotating subjects)
    _injectPhase1Mocks(entries, studyChapters, today, syllabusPhaseEnd,
        blackoutSet, config, examType);

    // 13. Phase 2 sessions (intensive revision + full mock tests)
    _injectPhase2Sessions(entries, studyChapters, syllabusPhaseEnd, examDate,
        blackoutSet, dailyStudyHours, config, examType);

    // 14. CA Final IBS integrated mocks
    if (isCaFinal && ibsChapters.isNotEmpty) {
      _injectIbsMocks(entries, syllabusPhaseEnd, examDate, blackoutSet);
    }

    // 15. Persist — clears old plan and writes new one
    await db.writeTxn(() async {
      await db.planEntrySchemas.clear();
      await db.planEntrySchemas.putAll(entries);
    });
  }

  // ── Exam-specific priority scoring ────────────────────────────────────────
  static double _scoreChapter(
    ChapterSchema c,
    String examType,
    Map<String, double> weakSubjectBoost,
  ) {
    double base =
        c.weightage * math.log(c.estimatedHours + 1) / math.log(10);

    // NEET: Biology is 360 marks (2× Physics/Chemistry) — boost it
    if (examType == 'neet' &&
        (c.subjectName.toLowerCase().contains('biology') ||
            c.subjectName.toLowerCase().contains('botany') ||
            c.subjectName.toLowerCase().contains('zoology'))) {
      base *= 1.80;
    }

    // JEE Advanced: Mathematics & Physics get slight boost (multi-concept Qs)
    if (examType == 'jee_advanced') {
      if (c.subjectName == 'Mathematics') base *= 1.10;
      if (c.subjectName == 'Physics') base *= 1.05;
    }

    // CA Final: Group I papers need stronger foundation (Group II builds on them)
    if (examType == 'ca_final' && c.classLevel <= 3) {
      base *= 1.08;
    }

    // Difficulty boost (harder chapters need more time)
    final diffBoost = ((c.difficulty) / 5.0) * 0.15;
    base += diffBoost * c.weightage * 0.20;

    // PYQ boost (chapters with more past questions are more exam-relevant)
    final pyqBoost = (c.pyqCount / 65.0).clamp(0.0, 0.25);
    base += pyqBoost * c.weightage * 0.20;

    // In-progress chapters: momentum bonus (don't abandon mid-chapter)
    final progress = c.estimatedHours > 0
        ? (c.hoursSpent / c.estimatedHours).clamp(0.0, 1.0)
        : 0.0;
    if (progress > 0.15 && progress < 0.85) base *= 1.12;

    // Weak subject boost (user-selected)
    final boost = weakSubjectBoost[c.subjectName] ?? 1.0;
    base *= boost;

    return base;
  }

  // ── Determine exam type from chapter syllabusSource ───────────────────────
  static String _examTypeFromChapters(List<ChapterSchema> chapters) {
    if (chapters.isEmpty) return 'jee_main';
    final sources = chapters.map((c) => c.syllabusSource).toSet();
    if (sources.contains('ca_final')) return 'ca_final';
    if (sources.contains('neet_ug')) return 'neet';
    if (sources.contains('jee_advanced')) return 'jee_advanced';
    if (sources.contains('class12_boards')) return 'class12_boards';
    return 'jee_main';
  }

  // ── Phase 1 mock test injection ────────────────────────────────────────────
  // Rotating subject-specific tests on Sundays from week N
  void _injectPhase1Mocks(
    List<PlanEntrySchema> entries,
    List<ChapterSchema> studyChapters,
    DateTime today,
    DateTime syllabusPhaseEnd,
    Set<DateTime> blackoutSet,
    _PlanConfig config,
    String examType,
  ) {
    if (studyChapters.isEmpty) return;
    final subjects = studyChapters.map((c) => c.subjectName).toSet().toList();

    // Start at first Sunday after (mockTestStartWeek) weeks from today
    var cursor = today.add(Duration(days: config.mockTestStartWeek * 7));
    while (cursor.weekday != DateTime.sunday) {
      cursor = cursor.add(const Duration(days: 1));
    }

    int rotation = 0;
    while (cursor.isBefore(syllabusPhaseEnd)) {
      final dateKey = DateTime(cursor.year, cursor.month, cursor.day);
      if (!blackoutSet.contains(dateKey)) {
        final subject = subjects[rotation % subjects.length];
        final label = _mockLabel(examType, subject);
        entries.add(PlanEntrySchema()
          ..chapterName = label
          ..subjectName = subject
          ..plannedDate = dateKey
          ..plannedHours = config.mockTestHours
          ..orderIndex = 99
          ..isRevision = false
          ..isMockTest = true
          ..mockTestSubject = subject
          ..status = 'pending');
        rotation++;
      }
      cursor = cursor.add(const Duration(days: 7));
    }
  }

  // ── Phase 2 sessions ───────────────────────────────────────────────────────
  // Full mock tests every N days + high-impact revision days + PYQ marathons
  void _injectPhase2Sessions(
    List<PlanEntrySchema> entries,
    List<ChapterSchema> studyChapters,
    DateTime syllabusPhaseEnd,
    DateTime examDate,
    Set<DateTime> blackoutSet,
    double dailyStudyHours,
    _PlanConfig config,
    String examType,
  ) {
    if (studyChapters.isEmpty) return;
    final subjects = studyChapters.map((c) => c.subjectName).toSet().toList();
    int rotation = 0;

    // Full mock tests every N days in Phase 2
    var cursor = syllabusPhaseEnd.add(const Duration(days: 2));
    while (cursor.weekday != DateTime.sunday) {
      cursor = cursor.add(const Duration(days: 1));
    }

    while (cursor.isBefore(examDate)) {
      final dateKey = DateTime(cursor.year, cursor.month, cursor.day);
      if (!blackoutSet.contains(dateKey)) {
        final subject = subjects[rotation % subjects.length];
        final isFullTest = rotation % subjects.length == 0;
        entries.add(PlanEntrySchema()
          ..chapterName = isFullTest
              ? _fullMockLabel(examType)
              : _mockLabel(examType, subject)
          ..subjectName = isFullTest ? 'Mixed / All Subjects' : subject
          ..plannedDate = dateKey
          ..plannedHours = isFullTest
              ? (config.mockTestHours + 0.5).clamp(3.0, 4.5)
              : config.mockTestHours
          ..orderIndex = 99
          ..isRevision = false
          ..isMockTest = true
          ..mockTestSubject = isFullTest ? 'Full' : subject
          ..status = 'pending');
        rotation++;
      }
      cursor = cursor
          .add(Duration(days: config.phase2MockIntervalDays));
    }

    // High-impact days in last 4 weeks before exam
    _injectPhase2HighImpactDays(
        entries, syllabusPhaseEnd, examDate, blackoutSet, dailyStudyHours);
  }

  // Saturdays in last 4 weeks: alternating PYQ Marathon + Full Syllabus Revision
  void _injectPhase2HighImpactDays(
    List<PlanEntrySchema> entries,
    DateTime syllabusPhaseEnd,
    DateTime examDate,
    Set<DateTime> blackoutSet,
    double dailyStudyHours,
  ) {
    final start = examDate.subtract(const Duration(days: 28));
    if (start.isBefore(syllabusPhaseEnd)) return;
    var cursor = start;
    int added = 0;
    while (cursor.isBefore(examDate) && added < 4) {
      final dateKey = DateTime(cursor.year, cursor.month, cursor.day);
      if (cursor.weekday == DateTime.saturday &&
          !blackoutSet.contains(dateKey)) {
        entries.add(PlanEntrySchema()
          ..chapterName = added.isEven
              ? 'PYQ Marathon – Mixed Subjects'
              : 'Full Syllabus Rapid Revision'
          ..subjectName = 'Mixed / Revision'
          ..plannedDate = dateKey
          ..plannedHours = (dailyStudyHours * 0.9).clamp(4.0, 7.0)
          ..orderIndex = 90 + added
          ..isRevision = true
          ..status = 'pending');
        added++;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
  }

  // CA Final IBS Integrated Mock Sessions (fortnightly Saturdays)
  void _injectIbsMocks(
    List<PlanEntrySchema> entries,
    DateTime syllabusPhaseEnd,
    DateTime examDate,
    Set<DateTime> blackoutSet,
  ) {
    var cursor = syllabusPhaseEnd.add(const Duration(days: 7));
    while (cursor.weekday != DateTime.saturday) {
      cursor = cursor.add(const Duration(days: 1));
    }
    int session = 1;
    while (cursor.isBefore(examDate.subtract(const Duration(days: 7)))) {
      final dateKey = DateTime(cursor.year, cursor.month, cursor.day);
      if (!blackoutSet.contains(dateKey)) {
        entries.add(PlanEntrySchema()
          ..chapterName = 'IBS Integrated Case Study Mock – Session $session'
          ..subjectName = 'Paper 6: Integrated Business Solutions (IBS)'
          ..plannedDate = dateKey
          ..plannedHours = 3.0
          ..orderIndex = 95
          ..isRevision = false
          ..isMockTest = true
          ..mockTestSubject = 'IBS'
          ..status = 'pending');
        session++;
      }
      cursor = cursor.add(const Duration(days: 14)); // fortnightly
    }
  }

  // ── Mock test labels by exam type ─────────────────────────────────────────
  static String _mockLabel(String examType, String subject) {
    switch (examType) {
      case 'neet':
        return 'NEET Mock – $subject';
      case 'ca_final':
        return 'CA Final Mock – $subject';
      case 'class12_boards':
        return 'Board Pre-Test – $subject';
      default:
        return 'Mock Test – $subject';
    }
  }

  static String _fullMockLabel(String examType) {
    switch (examType) {
      case 'neet':
        return 'Full NEET Mock Test';
      case 'ca_final':
        return 'CA Final Full Paper Mock';
      case 'class12_boards':
        return 'Full Board Mock Examination';
      case 'jee_advanced':
        return 'JEE Advanced Full Mock (Paper 1+2)';
      default:
        return 'JEE Main Full Mock Test';
    }
  }

  // ── Subject interleaving ──────────────────────────────────────────────────
  // Round-robin across subjects to prevent burnout from same-subject streaks
  static List<int> _interleaveBySubject(
      List<int> sortedIndices, List<ChapterSchema> chapters) {
    final groups = <String, List<int>>{};
    for (final i in sortedIndices) {
      groups.putIfAbsent(chapters[i].subjectName, () => []).add(i);
    }
    final result = <int>[];
    bool added = true;
    while (added) {
      added = false;
      for (final key in groups.keys) {
        if (groups[key]!.isNotEmpty) {
          result.add(groups[key]!.removeAt(0));
          added = true;
        }
      }
    }
    return result;
  }

  // ── Spaced Revision Scheduling ────────────────────────────────────────────
  // Creates RevisionScheduleSchema + injects plan entries at 7, 21, 45 days
  // Idempotent — will not create duplicate entries
  static Future<void> scheduleRevisions({
    required String chapterName,
    required String subjectName,
    required DateTime learnedDate,
    required double estimatedHours,
  }) async {
    final db = IsarService.db;

    // Upsert: update existing schedule if present, else create new
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

    final schedule = existing ?? RevisionScheduleSchema();
    schedule.chapterName = chapterName;
    schedule.subjectName = subjectName;
    schedule.firstLearnedDate = learnedDate;
    schedule.scheduledDates = revisionDates;
    if (existing == null) {
      schedule.completedDates = [];
      schedule.completedCount = 0;
      schedule.isFullyRevised = false;
    }
    schedule.active = true;

    await db.writeTxn(() async {
      await db.revisionScheduleSchemas.put(schedule);
    });

    // Insert plan entries for each future revision date
    final today = DateTime.now();
    final revEntries = <PlanEntrySchema>[];
    for (int i = 0; i < _revisionIntervals.length; i++) {
      final revDate = revisionDates[i];
      if (revDate.isBefore(today)) continue;
      final dayKey =
          DateTime(revDate.year, revDate.month, revDate.day);

      // Idempotent check: don't add duplicate revision entry
      final exists = await db.planEntrySchemas
          .filter()
          .chapterNameEqualTo(chapterName)
          .and()
          .plannedDateEqualTo(dayKey)
          .and()
          .isRevisionEqualTo(true)
          .count();
      if (exists > 0) continue;

      revEntries.add(PlanEntrySchema()
        ..chapterName = chapterName
        ..subjectName = subjectName
        ..plannedDate = dayKey
        ..plannedHours = _round(durations[i])
        ..orderIndex = 50 + i
        ..isRevision = true
        ..revisionOf = chapterName
        ..status = 'pending');
    }

    if (revEntries.isNotEmpty) {
      await db.writeTxn(() async {
        await db.planEntrySchemas.putAll(revEntries);
      });
    }

    // ── Also queue SM-2 review cards for this chapter ─────────────────────
    await createInitialReviewCards(
      chapterName: chapterName,
      subjectName: subjectName,
      syllabusSource: '',
    );
  }

  // ── Initial SM-2 review cards ─────────────────────────────────────────────
  // Called automatically from scheduleRevisions() when a chapter is learned.
  // Also callable directly from ChapterDetailScreen / any "Mark as Learned" flow.
  // ⚠️  Full DB persistence needs [REVIEW_CARD_STEP] — see isar_service.dart.
  //     Until then, the method is a safe no-op so nothing else breaks.
  static Future<void> createInitialReviewCards({
    required String chapterName,
    required String subjectName,
    required String syllabusSource,
  }) async {
    // [REVIEW_CARD_STEP] Uncomment this block after running build_runner
    // and enabling ReviewCardSchema in isar_service.dart + schemas.dart:
    //
    // try {
    //   final db = IsarService.db;
    //   String src = syllabusSource;
    //   if (src.isEmpty) {
    //     final ch = await db.chapterSchemas
    //         .filter().nameEqualTo(chapterName).findFirst();
    //     src = ch?.syllabusSource ?? 'jee_main';
    //   }
    //   final already = await db.reviewCardSchemas
    //       .filter().chapterNameEqualTo(chapterName)
    //       .isActiveEqualTo(true).count();
    //   if (already > 0) return;
    //   final now = DateTime.now();
    //   await db.writeTxn(() async {
    //     await db.reviewCardSchemas.putAll([
    //       ReviewCardSchema.create(
    //         chapterName: chapterName, subjectName: subjectName,
    //         syllabusSource: src, cardType: 'concept',
    //         front: 'Explain the core concept of "$chapterName"',
    //         back: 'Key ideas:\n• [Main theory]\n• [Key application]',
    //         nextReviewDate: now.add(const Duration(days: 1)),
    //       ),
    //       ReviewCardSchema.create(
    //         chapterName: chapterName, subjectName: subjectName,
    //         syllabusSource: src, cardType: 'formula',
    //         front: 'Most important formula/technique in "$chapterName"?',
    //         back: 'Main formula:\n[Write the formula or key method]',
    //         nextReviewDate: now.add(const Duration(days: 3)),
    //       ),
    //     ]);
    //   });
    // } catch (_) {} // Non-fatal — never block the study flow
  }

  static double _round(double v) => (v * 10).round() / 10;
}

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
  static Future<void> _applyCaFinalProgress(
      List<ChapterSchema> chapters) async {
    if (chapters.isEmpty) return;
    final isCa = chapters.any((c) => c.syllabusSource == 'ca_final');
    if (!isCa) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final db = IsarService.db;

      // ── Chapter-level granularity (preferred) ──────────────────────────
      final chapterRaw = prefs.getString('ca_final_chapter_progress');
      if (chapterRaw != null) {
        final Map<String, dynamic> chapterMap =
            jsonDecode(chapterRaw) as Map<String, dynamic>;
        await db.writeTxn(() async {
          for (final ch in chapters) {
            final sameSubject = chapters
                .where((c) => c.classLevel == ch.classLevel)
                .toList()
              ..sort((a, b) => a.name.compareTo(b.name));
            final idxInSubject = sameSubject.indexOf(ch);
            final key = '${ch.classLevel}:$idxInSubject';
            final status = chapterMap[key] as String?;
            if (status == null) continue;
            _applyStatusToChapter(ch, status);
            await db.chapterSchemas.put(ch);
          }
        });
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
    } catch (_) {
      // Non-fatal — planner continues normally without progress data
    }
  }

  static void _applyStatusToChapter(ChapterSchema ch, String status) {
    switch (status) {
      case 'completed':
        ch.masteryLevel = 7;
        ch.status = 'completed';
        break;
      case 'revision_pending':
        ch.masteryLevel = 4;
        ch.status = 'revision_pending';
        break;
      case 'in_progress':
        ch.masteryLevel = 2;
        ch.status = 'in_progress';
        break;
      case 'not_started':
      default:
        break;
    }
  }
}
