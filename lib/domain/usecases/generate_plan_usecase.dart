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

import 'dart:math' as math;
import 'package:isar/isar.dart';
import '../../data/local/isar/isar_service.dart';
import '../../data/content/exam_registry.dart';
import '../planner/feasibility_engine.dart'; // shared need formula (PLAN-2)
import 'weakness_detector_usecase.dart';

// PART 2B (STRUCT-1): WeaknessDetectorUseCase moved to its own file.
// - import: so THIS file can call it (execute() uses applyCaFinalProgress).
// - export: so downstream files importing generate_plan_usecase.dart keep
//   seeing WeaknessDetectorUseCase unchanged (no import edits needed anywhere).
export 'weakness_detector_usecase.dart';

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
  /// PART 2A: planner tuning now comes from ExamRegistry — the single
  /// source of truth. _PlanConfig is kept as the internal carrier type.
  static _PlanConfig _configFor(String examType) {
    final k = ExamRegistry.of(examType).planner;
    return _PlanConfig(
      effectiveHourRatio: k.effectiveHourRatio,
      maxChapterHoursPerDay: k.maxChapterHoursPerDay,
      bufferDayInterval: k.bufferDayInterval,
      mockTestStartWeek: k.mockTestStartWeek,
      mockTestHours: k.mockTestHours,
      phase2BufferDays: k.phase2BufferDays,
      phase2MockIntervalDays: k.phase2MockIntervalDays,
    );
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
    String? examType, // DATA-6: pass user.targetExam — see PlanNotifier
  }) async {
    final db = IsarService.db;
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final totalDays = examDate.difference(today).inDays;
    if (totalDays <= 0) throw Exception('Exam date must be in the future.');
    if (chapters.isEmpty) {
      throw Exception('No chapters loaded. Run Syllabus Loader first.');
    }

    // 1. DATA-6 FIX: exam type comes from the USER, not inferred from
    // whatever chapters happen to sit in the DB (exam-switch debris made
    // the inference return the OLD exam). Inference kept as fallback only.
    final resolvedExamType = (examType != null && examType.isNotEmpty)
        ? (examType == 'both' ? 'jee_main' : examType)
        : _examTypeFromChapters(chapters);
    final config = _configFor(resolvedExamType);
    final isCaFinal = resolvedExamType == 'ca_final';

    // 2. Apply existing CA Final progress from onboarding SharedPreferences
    if (isCaFinal) {
      await WeaknessDetectorUseCase.applyCaFinalProgress(chapters);
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
        .map((c) => _scoreChapter(c, resolvedExamType, weakSubjectBoost))
        .toList();

    final totalScore = scores.fold<double>(0, (a, b) => a + b);
    if (totalScore == 0) {
      throw Exception('All chapters have zero priority score.');
    }

    // ── 8. PLANNER v5 CORE (PLAN-1..5 fixes) ─────────────────────────────────
    //
    // 8a. CALENDAR PRE-PASS — single source of truth for what each calendar
    //     day IS (study / buffer / mock / phase-2 spill). Fixes PLAN-4: buffer
    //     and mock cadence are derived from the real calendar in ONE place,
    //     instead of a `studyDayCount` that drifted because it incremented on
    //     skips, blackouts and budget-full days alike.
    final blackoutSet =
        blackoutDates.map((d) => DateTime(d.year, d.month, d.day)).toSet();

    final phase1StudyDays = <DateTime>[]; // coverage learning slots
    final phase1MockDays = <DateTime>[]; // reserved Sundays (mocks own them)
    final phase2SpillDays = <DateTime>[]; // phase-2 days open to coverage spill
    final lastDay = examDate.subtract(const Duration(days: 1));
    final highImpactWindowStart = examDate.subtract(const Duration(days: 28));

    int eligibleStudySeen = 0; // counts real study-eligible days, for buffers
    for (var d = today;
        !d.isAfter(lastDay);
        d = d.add(const Duration(days: 1))) {
      final day = DateTime(d.year, d.month, d.day);
      if (blackoutSet.contains(day)) continue;

      if (!day.isAfter(syllabusPhaseEnd)) {
        // Phase 1: Sundays past the mock-start threshold are mock-reserved.
        final isMock = day.weekday == DateTime.sunday &&
            day.difference(today).inDays >= config.mockTestStartWeek * 7;
        if (isMock) {
          phase1MockDays.add(day);
          continue;
        }
        eligibleStudySeen++;
        // Every Nth eligible study day is a buffer (catch-up) day — stable
        // because it's counted over the calendar, never over loop iterations.
        final isBuffer = config.bufferDayInterval > 0 &&
            eligibleStudySeen % config.bufferDayInterval == 0;
        if (isBuffer) continue;
        phase1StudyDays.add(day);
      } else {
        // Phase 2 is revision/mock territory. Coverage may SPILL here at
        // reduced intensity, but never onto mock Sundays or the high-impact
        // Saturdays of the final 4 weeks (those days belong to Phase 2).
        if (day.weekday == DateTime.sunday) continue;
        if (day.weekday == DateTime.saturday &&
            !day.isBefore(highImpactWindowStart)) {
          continue;
        }
        phase2SpillDays.add(day);
      }
    }

    // 8b. EXACT CAPACITY (PLAN-1: the 180-day cap is GONE). Capacity is the
    //     sum over the *actual* remaining calendar — a 16-month CA Final plan
    //     now budgets all 16 months, not a silent half.
    const phase2SpillRatio = 0.5; // spill days keep ≥50% free for revision
    final phase1Capacity =
        phase1StudyDays.length * dailyStudyHours * effectiveRatio;
    final spillCapacity = phase2SpillDays.length *
        dailyStudyHours *
        phase2SpillRatio *
        effectiveRatio;

    // 8c. NEED-BASED WATER-FILL ALLOCATION (PLAN-2). Each chapter's true need
    //     comes from FeasibilityEngine.remainingNeed — the ONE formula shared
    //     with the dashboard verdict, so the plan and the feasibility card can
    //     never disagree. It is evidence-honest (declared mastery is only
    //     believed up to a bounded head-start over logged hours + test
    //     accuracy) and self-calibrated (per-subject cost multiplier learned
    //     from the student's own completed chapters). Priority scores decide
    //     WHO gets capacity first when it's scarce — but no chapter is ever
    //     allocated beyond its need.
    final calibration =
        FeasibilityEngine.subjectCalibration(allStudyChapters);
    final needs = List<double>.generate(
      studyChapters.length,
      (i) => FeasibilityEngine.remainingNeed(studyChapters[i], calibration),
    );
    final totalNeed = needs.fold<double>(0, (a, b) => a + b);
    final coverageCapacity = phase1Capacity + spillCapacity;

    final allocatedHours = List<double>.filled(studyChapters.length, 0.0);
    if (totalNeed <= coverageCapacity) {
      // Feasible: everyone gets full need. Surplus becomes DEPTH hours for
      // high-priority chapters (practice/PYQ depth), capped at +40% of need so
      // surplus deepens preparation instead of padding the calendar.
      for (var i = 0; i < needs.length; i++) {
        allocatedHours[i] = needs[i];
      }
      var surplus = coverageCapacity - totalNeed;
      if (surplus > 0.5 && totalScore > 0) {
        for (var i = 0; i < needs.length; i++) {
          final depth =
              math.min(surplus * (scores[i] / totalScore), needs[i] * 0.40);
          allocatedHours[i] += depth;
        }
      }
    } else {
      // Infeasible horizon: water-fill by priority. High-score chapters are
      // saturated to full need first; capacity is exhausted exactly; nobody
      // exceeds need. (The dashboard Feasibility card carries the explicit
      // "won't finish — trim list" warning to the student.)
      var remainingCap = coverageCapacity;
      final unsat = List<int>.generate(studyChapters.length, (i) => i)
        ..removeWhere((i) => needs[i] <= 0);
      for (var iter = 0; iter < 12 && remainingCap > 0.05 && unsat.isNotEmpty; iter++) {
        final wSum =
            unsat.fold<double>(0, (a, i) => a + math.max(scores[i], 0.001));
        var distributed = 0.0;
        final saturatedNow = <int>[];
        for (final i in unsat) {
          final share =
              remainingCap * (math.max(scores[i], 0.001) / wSum);
          final room = needs[i] - allocatedHours[i];
          final give = math.min(share, room);
          allocatedHours[i] += give;
          distributed += give;
          if (needs[i] - allocatedHours[i] <= 0.05) saturatedNow.add(i);
        }
        remainingCap -= distributed;
        unsat.removeWhere(saturatedNow.contains);
        if (distributed <= 0.05) break;
      }
    }

    // 9. Sort by priority descending + interleave subjects
    final sortedIndices =
        List<int>.generate(studyChapters.length, (i) => i)
          ..sort((a, b) => scores[b].compareTo(scores[a]));
    final interleaved = _interleaveBySubject(sortedIndices, studyChapters);

    // 10/11. DISTRIBUTE over the precomputed day plan.
    //   • PLAN-5: ONE global monotonic orderIndex across the whole plan, so
    //     "today's order" is deterministic instead of resetting per chapter.
    //   • PLAN-3 (generation side): spill days expose only their reduced
    //     budget to coverage, and mock days were never offered to coverage at
    //     all — so the injected mocks/high-impact sessions land on days the
    //     study loop deliberately left room on.
    final dailyBudget = <DateTime, double>{};
    final dailyCap = <DateTime, double>{
      for (final d in phase1StudyDays) d: dailyStudyHours,
      for (final d in phase2SpillDays) d: dailyStudyHours * phase2SpillRatio,
    };
    final coverageDays = <DateTime>[...phase1StudyDays, ...phase2SpillDays];
    final entries = <PlanEntrySchema>[];
    int globalOrder = 0;
    int dayIdx = 0;

    for (final idx in interleaved) {
      final chapter = studyChapters[idx];
      double remaining = allocatedHours[idx];

      while (remaining > 0.05 && dayIdx < coverageDays.length) {
        final dateKey = coverageDays[dayIdx];
        final cap = dailyCap[dateKey] ?? dailyStudyHours;
        final used = dailyBudget[dateKey] ?? 0.0;
        final available = cap - used;

        if (available <= 0.05) {
          dayIdx++;
          continue;
        }

        final inPhase1 = !dateKey.isAfter(syllabusPhaseEnd);
        final maxPerDay = inPhase1
            ? math.min(config.maxChapterHoursPerDay, dailyStudyHours * 0.60)
            : math.min(
                config.maxChapterHoursPerDay + 0.5, dailyStudyHours * 0.75);

        final chunk =
            _round(math.min(math.min(maxPerDay, remaining), available));
        if (chunk <= 0.05) {
          dayIdx++;
          continue;
        }

        entries.add(PlanEntrySchema()
          ..chapterKey = chapter.chapterKey // DATA-1: identity travels with entry
          ..syllabusSource = chapter.syllabusSource
          ..chapterName = chapter.name
          ..subjectName = chapter.subjectName
          ..plannedDate = dateKey
          ..plannedHours = chunk
          ..orderIndex = globalOrder++ // PLAN-5: globally monotonic
          ..isRevision = false
          ..status = 'pending');

        dailyBudget[dateKey] = used + chunk;
        remaining -= chunk;
      }
      if (dayIdx >= coverageDays.length) break; // calendar exhausted
    }

    // 12. Phase 1 mock tests — on the EXACT reserved Sundays from the
    // pre-pass, consuming the day's budget (PLAN-3).
    _injectPhase1Mocks(entries, studyChapters, phase1MockDays, dailyBudget,
        config, resolvedExamType);

    // 13. Phase 2 sessions (intensive revision + full mock tests) — budget-aware
    _injectPhase2Sessions(entries, studyChapters, syllabusPhaseEnd, examDate,
        blackoutSet, dailyStudyHours, dailyBudget, config, resolvedExamType);

    // 14. CA Final IBS integrated mocks (budget-aware: PLAN-3)
    if (isCaFinal && ibsChapters.isNotEmpty) {
      _injectIbsMocks(
          entries, syllabusPhaseEnd, examDate, blackoutSet, dailyStudyHours,
          dailyBudget);
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
  /// DATA-1: primary syllabusSource stamped onto synthetic (mock/marathon)
  /// entries so stream filters include them. Non-chapter entries keep
  /// chapterKey '' by design — they have no chapter identity.
  static String _primarySourceFor(String examType) =>
      ExamRegistry.primarySourceOf(examType);

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
    List<DateTime> reservedMockDays, // exact Sundays from the calendar pre-pass
    Map<DateTime, double> dailyBudget, // PLAN-3: mocks consume the day budget
    _PlanConfig config,
    String examType,
  ) {
    if (studyChapters.isEmpty) return;
    final subjects = studyChapters.map((c) => c.subjectName).toSet().toList();

    int rotation = 0;
    for (final dateKey in reservedMockDays) {
      final subject = subjects[rotation % subjects.length];
      final label = _mockLabel(examType, subject);
      entries.add(PlanEntrySchema()
        ..syllabusSource = _primarySourceFor(examType) // DATA-1
        ..chapterName = label
        ..subjectName = subject
        ..plannedDate = dateKey
        ..plannedHours = config.mockTestHours
        ..orderIndex = 99
        ..isRevision = false
        ..isMockTest = true
        ..mockTestSubject = subject
        ..status = 'pending');
      // PLAN-3: record the mock's hours so NOTHING else (revision backfill,
      // quick-adds) can silently stack a 9–11h day on top of a mock.
      dailyBudget[dateKey] = (dailyBudget[dateKey] ?? 0) + config.mockTestHours;
      rotation++;
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
    Map<DateTime, double> dailyBudget, // PLAN-3: shared budget ledger
    _PlanConfig config,
    String examType,
  ) {
    if (studyChapters.isEmpty) return;
    final subjects = studyChapters.map((c) => c.subjectName).toSet().toList();
    int rotation = 0;

    // PLAN-3: a session is only placed on a day with room; otherwise it walks
    // forward to the next non-blackout day that fits. The student's daily
    // budget is a hard ceiling everywhere now.
    DateTime? placeWithBudget(DateTime from, double hours) {
      var d = DateTime(from.year, from.month, from.day);
      final limit = examDate.subtract(const Duration(days: 1));
      while (!d.isAfter(limit)) {
        if (!blackoutSet.contains(d) &&
            (dailyBudget[d] ?? 0) + hours <= dailyStudyHours + 0.01) {
          return d;
        }
        d = d.add(const Duration(days: 1));
      }
      return null;
    }

    // Full mock tests every N days in Phase 2
    var cursor = syllabusPhaseEnd.add(const Duration(days: 2));
    while (cursor.weekday != DateTime.sunday) {
      cursor = cursor.add(const Duration(days: 1));
    }

    while (cursor.isBefore(examDate)) {
      final subject = subjects[rotation % subjects.length];
      final isFullTest = rotation % subjects.length == 0;
      final double hours = isFullTest
          ? (config.mockTestHours + 0.5).clamp(3.0, 4.5).toDouble()
          : config.mockTestHours;
      final dateKey = placeWithBudget(cursor, hours);
      if (dateKey != null) {
        entries.add(PlanEntrySchema()
          ..syllabusSource = _primarySourceFor(examType) // DATA-1
          ..chapterName = isFullTest
              ? _fullMockLabel(examType)
              : _mockLabel(examType, subject)
          ..subjectName = isFullTest ? 'Mixed / All Subjects' : subject
          ..plannedDate = dateKey
          ..plannedHours = hours.toDouble()
          ..orderIndex = 99
          ..isRevision = false
          ..isMockTest = true
          ..mockTestSubject = isFullTest ? 'Full' : subject
          ..status = 'pending');
        dailyBudget[dateKey] = (dailyBudget[dateKey] ?? 0) + hours;
        rotation++;
      }
      cursor = cursor
          .add(Duration(days: config.phase2MockIntervalDays));
    }

    // High-impact days in last 4 weeks before exam
    _injectPhase2HighImpactDays(entries, syllabusPhaseEnd, examDate,
        blackoutSet, dailyStudyHours, dailyBudget);
  }

  // Saturdays in last 4 weeks: alternating PYQ Marathon + Full Syllabus Revision
  void _injectPhase2HighImpactDays(
    List<PlanEntrySchema> entries,
    DateTime syllabusPhaseEnd,
    DateTime examDate,
    Set<DateTime> blackoutSet,
    double dailyStudyHours,
    Map<DateTime, double> dailyBudget, // PLAN-3
  ) {
    final start = examDate.subtract(const Duration(days: 28));
    if (start.isBefore(syllabusPhaseEnd)) return;
    var cursor = start;
    int added = 0;
    while (cursor.isBefore(examDate) && added < 4) {
      final dateKey = DateTime(cursor.year, cursor.month, cursor.day);
      final double hours = (dailyStudyHours * 0.9).clamp(4.0, 7.0).toDouble();
      if (cursor.weekday == DateTime.saturday &&
          !blackoutSet.contains(dateKey) &&
          (dailyBudget[dateKey] ?? 0) + hours <=
              dailyStudyHours + 0.01) {
        entries.add(PlanEntrySchema()
          ..chapterName = added.isEven
              ? 'PYQ Marathon – Mixed Subjects'
              : 'Full Syllabus Rapid Revision'
          ..subjectName = 'Mixed / Revision'
          ..plannedDate = dateKey
          ..plannedHours = hours
          ..orderIndex = 90 + added
          ..isRevision = true
          ..status = 'pending');
        dailyBudget[dateKey] = (dailyBudget[dateKey] ?? 0) + hours;
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
    double dailyStudyHours,
    Map<DateTime, double> dailyBudget, // PLAN-3
  ) {
    const ibsHours = 3.0;
    var cursor = syllabusPhaseEnd.add(const Duration(days: 7));
    while (cursor.weekday != DateTime.saturday) {
      cursor = cursor.add(const Duration(days: 1));
    }
    int session = 1;
    final limit = examDate.subtract(const Duration(days: 7));
    while (cursor.isBefore(limit)) {
      // PLAN-3: place on the first non-blackout day from the cadence anchor
      // that still has room for a 3h case-study sitting.
      var d = DateTime(cursor.year, cursor.month, cursor.day);
      DateTime? dateKey;
      while (d.isBefore(limit)) {
        if (!blackoutSet.contains(d) &&
            (dailyBudget[d] ?? 0) + ibsHours <= dailyStudyHours + 0.01) {
          dateKey = d;
          break;
        }
        d = d.add(const Duration(days: 1));
      }
      if (dateKey != null) {
        entries.add(PlanEntrySchema()
          ..syllabusSource = 'ca_final' // DATA-1: IBS is CA Final-only
          ..chapterName = 'IBS Integrated Case Study Mock – Session $session'
          ..subjectName = 'Paper 6: Integrated Business Solutions (IBS)'
          ..plannedDate = dateKey
          ..plannedHours = ibsHours
          ..orderIndex = 95
          ..isRevision = false
          ..isMockTest = true
          ..mockTestSubject = 'IBS'
          ..status = 'pending');
        dailyBudget[dateKey] = (dailyBudget[dateKey] ?? 0) + ibsHours;
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
    String chapterKey = '', // DATA-1: pass whenever the caller has the chapter
    String syllabusSource = '',
  }) async {
    final db = IsarService.db;

    // DATA-1 FIX: upsert by chapterKey when available. The old name-keyed
    // upsert + unique index meant 'Kinematics' (jee_main) and 'Kinematics'
    // (neet_ug) could never BOTH have revision schedules — one silently
    // clobbered the other. Name match remains the legacy fallback only.
    final existing = chapterKey.isNotEmpty
        ? await db.revisionScheduleSchemas
            .filter()
            .chapterKeyEqualTo(chapterKey)
            .findFirst()
        : await db.revisionScheduleSchemas
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
    schedule.chapterKey = chapterKey;
    schedule.syllabusSource = syllabusSource;
    schedule.chapterName = chapterName;
    schedule.subjectName = subjectName;
    schedule.firstLearnedDate = learnedDate;
    schedule.scheduledDates = revisionDates;
    schedule.estimatedHours = estimatedHours; // PLAN-6: drives tile duration
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

    // PLAN-3 (runtime side): revisions are scheduled AFTER plan generation,
    // so without a budget check they stacked on top of full study days
    // (the 9–11h-day bug). Read the student's daily ceiling once; if the SM-2
    // target day is already full, the revision slides up to 3 days forward to
    // the first day with room (clinically, a 1–3 day slip barely moves the
    // forgetting curve — far better than an impossible day the student skips).
    final planUser = await db.userSchemas.where().findFirst();
    final double dayCeiling = planUser?.dailyStudyHours ?? 6.0;

    Future<DateTime> bestDayFor(DateTime wanted, double hours) async {
      var d = wanted;
      for (int tries = 0; tries < 4; tries++) {
        final pending = await db.planEntrySchemas
            .filter()
            .plannedDateEqualTo(d)
            .and()
            .statusEqualTo('pending')
            .findAll();
        final used =
            pending.fold<double>(0, (s, e) => s + e.plannedHours);
        if (used + hours <= dayCeiling + 0.01) return d;
        d = d.add(const Duration(days: 1));
      }
      return wanted; // every nearby day full → keep SM-2 date (memory wins)
    }

    for (int i = 0; i < _revisionIntervals.length; i++) {
      final revDate = revisionDates[i];
      if (revDate.isBefore(today)) continue;
      final wantedKey =
          DateTime(revDate.year, revDate.month, revDate.day);
      final hours = _round(durations[i].toDouble());
      final dayKey = await bestDayFor(wantedKey, hours);

      // Idempotent check: don't add duplicate revision entry
      // (chapterKey-aware so cross-stream same-name entries don't block)
      final dupQuery = chapterKey.isNotEmpty
          ? db.planEntrySchemas
              .filter()
              .chapterKeyEqualTo(chapterKey)
              .and()
              .plannedDateEqualTo(dayKey)
              .and()
              .isRevisionEqualTo(true)
          : db.planEntrySchemas
              .filter()
              .chapterNameEqualTo(chapterName)
              .and()
              .plannedDateEqualTo(dayKey)
              .and()
              .isRevisionEqualTo(true);
      final exists = await dupQuery.count();
      if (exists > 0) continue;

      revEntries.add(PlanEntrySchema()
        ..chapterKey = chapterKey
        ..syllabusSource = syllabusSource
        ..chapterName = chapterName
        ..subjectName = subjectName
        ..plannedDate = dayKey
        ..plannedHours = hours
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
      syllabusSource: syllabusSource,
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
