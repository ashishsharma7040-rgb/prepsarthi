// lib/domain/models/exam_spec.dart
//
// PART 2A (Master Spec C-1): the ExamSpec model.
//
// Every piece of exam-specific knowledge — syllabus sources, session dates,
// planner tuning, AI persona, display labels — lives in ONE typed structure.
// Specs are defined in lib/data/content/exam_registry.dart.
//
// WHY: exam knowledge was scattered across 7+ switch statements (syllabus
// loader, planner config, readiness, providers, Gemini prompts, exam dates,
// mock labels). That is exactly how the BUG-1 class of bugs happened: add an
// exam, miss one switch, silently corrupt one subsystem. With the registry,
// adding CA Inter / CA Foundation / UPSC is ONE spec entry + one syllabus
// JSON — zero scattered edits.

/// One exam sitting in the year (e.g. CA Final January session).
class ExamSession {
  final String id; // 'january' | 'may' | 'september' | 'default'
  final String label; // 'January'
  final int month;
  final int day;
  const ExamSession(this.id, this.label, this.month, this.day);
}

/// Planner tuning knobs (mirrors the planner's internal config 1:1).
class PlannerKnobs {
  final double effectiveHourRatio;
  final double maxChapterHoursPerDay;
  final int bufferDayInterval;
  final int mockTestStartWeek;
  final double mockTestHours;
  final int phase2BufferDays;
  final int phase2MockIntervalDays;

  const PlannerKnobs({
    required this.effectiveHourRatio,
    required this.maxChapterHoursPerDay,
    required this.bufferDayInterval,
    required this.mockTestStartWeek,
    required this.mockTestHours,
    required this.phase2BufferDays,
    required this.phase2MockIntervalDays,
  });
}

class ExamSpec {
  /// Canonical exam id stored in UserSchema.targetExam.
  final String id;

  /// Human-readable name ('CA Final', 'JEE + NEET').
  final String displayName;

  /// All syllabus sources this exam draws from. 'both' has two.
  final List<String> syllabusSources;

  /// The source used for synthetic (non-chapter) plan entries like mocks.
  final String primarySource;

  /// syllabusSource → asset path for every source of this exam.
  final Map<String, String> syllabusAssets;

  /// Exam sittings. Single-session exams have one 'default' session.
  final List<ExamSession> sessions;

  /// Which session applies when none is specified.
  final String defaultSessionId;

  /// Planner tuning for this exam.
  final PlannerKnobs planner;

  /// One-sentence persona fragment injected into AI prompts so Gemini
  /// advises a CA student like a CA mentor, not a JEE coach (EXAM-3).
  final String aiPersona;

  /// Label written to MockTestSchema.examType for this exam's mocks.
  final String mockTestLabel;

  /// Whether the NTA-style percentile estimator is meaningful (false for
  /// pass-marks exams like CA Final and for Boards).
  final bool usesPercentile;

  const ExamSpec({
    required this.id,
    required this.displayName,
    required this.syllabusSources,
    required this.primarySource,
    required this.syllabusAssets,
    required this.sessions,
    required this.defaultSessionId,
    required this.planner,
    required this.aiPersona,
    required this.mockTestLabel,
    required this.usesPercentile,
  });

  /// Resolve a session by id with safe fallback to the default session.
  ExamSession sessionOf(String? sessionId) {
    for (final s in sessions) {
      if (s.id == sessionId) return s;
    }
    for (final s in sessions) {
      if (s.id == defaultSessionId) return s;
    }
    return sessions.first;
  }
}
