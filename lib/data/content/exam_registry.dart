// lib/data/content/exam_registry.dart
//
// PART 2A (Master Spec C-1): THE single source of truth for exam knowledge.
//
// Replaces the scattered switch statements in: exam_dates, chapter_resolver,
// readiness_score, chapter_key_migration, all_providers (_syllabusSource),
// generate_plan_usecase (_configFor / _primarySourceFor), syllabus_loader,
// gemini_service (persona) and generating_plan_screen (display name).
// Those sites now DELEGATE here.
//
// ADDING A NEW EXAM (e.g. CA Inter):
//   1. Add its syllabus JSON under assets/syllabus/ (+ pubspec assets entry).
//   2. Add ONE ExamSpec entry to _specs below.
//   That's it. No other Dart file changes.
//
// NOTE: kept as Dart consts (not asset JSON) deliberately — consts are
// available synchronously everywhere with zero load-order risk, which several
// consumers (resolver, migration) require. Externalising to JSON can happen
// later if specs ever need server-side updates.

import '../../domain/models/exam_spec.dart';

class ExamRegistry {
  ExamRegistry._();

  static const String fallbackExamId = 'jee_main';

  static const Map<String, ExamSpec> _specs = {
    'jee_main': ExamSpec(
      id: 'jee_main',
      displayName: 'JEE Main',
      syllabusSources: ['jee_main'],
      primarySource: 'jee_main',
      syllabusAssets: {'jee_main': 'assets/syllabus/jee_main_2026.json'},
      sessions: [ExamSession('default', 'April Session', 4, 13)],
      defaultSessionId: 'default',
      planner: PlannerKnobs(
        effectiveHourRatio: 0.85,
        maxChapterHoursPerDay: 2.5,
        bufferDayInterval: 7,
        mockTestStartWeek: 3,
        mockTestHours: 3.0,
        phase2BufferDays: 21,
        phase2MockIntervalDays: 5,
      ),
      aiPersona:
          'The student is preparing for JEE Main (NTA): NCERT-based Physics, '
          'Chemistry and Mathematics with numerical problem-solving emphasis '
          'and percentile-based scoring.',
      mockTestLabel: 'JEE Main',
      usesPercentile: true,
    ),
    'jee_advanced': ExamSpec(
      id: 'jee_advanced',
      displayName: 'JEE Advanced',
      syllabusSources: ['jee_advanced'],
      primarySource: 'jee_advanced',
      syllabusAssets: {
        'jee_advanced': 'assets/syllabus/jee_advanced_2026.json'
      },
      sessions: [ExamSession('default', 'May Session', 5, 25)],
      defaultSessionId: 'default',
      planner: PlannerKnobs(
        effectiveHourRatio: 0.88,
        maxChapterHoursPerDay: 3.0,
        bufferDayInterval: 7,
        mockTestStartWeek: 4,
        mockTestHours: 3.0,
        phase2BufferDays: 21,
        phase2MockIntervalDays: 5,
      ),
      aiPersona:
          'The student is preparing for JEE Advanced (IIT entrance): deep '
          'multi-concept problem solving in Physics, Chemistry and '
          'Mathematics; conceptual rigour matters more than coverage speed.',
      mockTestLabel: 'JEE Advanced',
      usesPercentile: true,
    ),
    'neet': ExamSpec(
      id: 'neet',
      displayName: 'NEET UG',
      syllabusSources: ['neet_ug'],
      primarySource: 'neet_ug',
      syllabusAssets: {'neet_ug': 'assets/syllabus/neet_ug_2026.json'},
      sessions: [ExamSession('default', 'May Session', 5, 4)],
      defaultSessionId: 'default',
      planner: PlannerKnobs(
        effectiveHourRatio: 0.87,
        maxChapterHoursPerDay: 2.0,
        bufferDayInterval: 7,
        mockTestStartWeek: 4,
        mockTestHours: 3.5,
        phase2BufferDays: 21,
        phase2MockIntervalDays: 5,
      ),
      aiPersona:
          'The student is preparing for NEET UG (medical entrance): Biology '
          'carries half the marks; NCERT-line accuracy and recall speed are '
          'critical, with Physics and Chemistry support.',
      mockTestLabel: 'NEET',
      usesPercentile: true,
    ),
    'both': ExamSpec(
      id: 'both',
      displayName: 'JEE + NEET',
      syllabusSources: ['jee_main', 'neet_ug'],
      primarySource: 'jee_main',
      syllabusAssets: {
        'jee_main': 'assets/syllabus/jee_main_2026.json',
        'neet_ug': 'assets/syllabus/neet_ug_2026.json',
      },
      sessions: [ExamSession('default', 'April Session', 4, 13)],
      defaultSessionId: 'default',
      planner: PlannerKnobs(
        // mirrors jee_main — dual-prep students follow the JEE cadence
        effectiveHourRatio: 0.85,
        maxChapterHoursPerDay: 2.5,
        bufferDayInterval: 7,
        mockTestStartWeek: 3,
        mockTestHours: 3.0,
        phase2BufferDays: 21,
        phase2MockIntervalDays: 5,
      ),
      aiPersona:
          'The student is preparing for BOTH JEE Main and NEET UG '
          'simultaneously: shared Physics/Chemistry core, with Mathematics '
          'for JEE and Biology for NEET; time-split discipline is the key '
          'challenge.',
      mockTestLabel: 'JEE Main',
      usesPercentile: true,
    ),
    'ca_final': ExamSpec(
      id: 'ca_final',
      displayName: 'CA Final',
      syllabusSources: ['ca_final'],
      primarySource: 'ca_final',
      syllabusAssets: {'ca_final': 'assets/syllabus/ca_final_2026.json'},
      // EXAM-2: ICAI holds CA Final thrice yearly since 2025.
      sessions: [
        ExamSession('january', 'January', 1, 10),
        ExamSession('may', 'May', 5, 6),
        ExamSession('september', 'September', 9, 10),
      ],
      defaultSessionId: 'may',
      planner: PlannerKnobs(
        effectiveHourRatio: 0.82,
        maxChapterHoursPerDay: 2.5,
        bufferDayInterval: 7,
        mockTestStartWeek: 6,
        mockTestHours: 3.0,
        phase2BufferDays: 28,
        phase2MockIntervalDays: 5,
      ),
      aiPersona:
          'The student is a CA Final candidate (ICAI): six descriptive '
          'papers across two groups, pass-marks scoring (40 per paper, 50 '
          'aggregate per group), ABC-weightage strategy, RTP/MTP practice '
          'and answer-writing skill — typically balancing articleship hours.',
      mockTestLabel: 'CA Final',
      usesPercentile: false,
    ),
    'class12_boards': ExamSpec(
      id: 'class12_boards',
      displayName: 'Class 12 Boards',
      syllabusSources: ['class12_boards'],
      primarySource: 'class12_boards',
      syllabusAssets: {
        'class12_boards': 'assets/syllabus/class12_boards_2026.json'
      },
      // EXAM-5: CBSE theory mains begin early March.
      sessions: [ExamSession('default', 'March Session', 3, 5)],
      defaultSessionId: 'default',
      planner: PlannerKnobs(
        effectiveHourRatio: 0.80,
        maxChapterHoursPerDay: 2.5,
        bufferDayInterval: 7,
        mockTestStartWeek: 6,
        mockTestHours: 3.0,
        phase2BufferDays: 35,
        phase2MockIntervalDays: 7,
      ),
      aiPersona:
          'The student is preparing for Class 12 Board exams (CBSE pattern): '
          'NCERT mastery, descriptive answer writing, sample papers and '
          'presentation quality drive marks.',
      mockTestLabel: 'Board Exam',
      usesPercentile: false,
    ),
  };

  /// Canonical lookup — never throws; unknown/null ids fall back to JEE Main
  /// (matching the app's long-standing default behaviour).
  static ExamSpec of(String? examId) =>
      _specs[examId] ?? _specs[fallbackExamId]!;

  /// True if [examId] is a recognised exam.
  static bool isKnown(String? examId) => _specs.containsKey(examId);

  /// All registered exam ids (stable order).
  static List<String> get allIds => _specs.keys.toList(growable: false);

  // ── Convenience helpers used by the migrated call sites ──────────────────

  static List<String> sourcesOf(String? examId) => of(examId).syllabusSources;

  static String primarySourceOf(String? examId) => of(examId).primarySource;

  static String displayNameOf(String? examId) =>
      isKnown(examId) ? of(examId).displayName : 'Exam';

  /// Exam date for [examId] in [year]. [sessionId] selects a sitting for
  /// multi-session exams (CA Final). Includes the EXAM-2 legacy mapping:
  /// the retired 'november' attempt resolves to January of the next year.
  static DateTime examDate(String? examId, int year, {String? sessionId}) {
    if (examId == 'ca_final' && sessionId == 'november') {
      final jan = of(examId).sessionOf('january');
      return DateTime(year + 1, jan.month, jan.day);
    }
    final s = of(examId).sessionOf(sessionId);
    return DateTime(year, s.month, s.day);
  }
}
