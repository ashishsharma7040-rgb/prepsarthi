// lib/presentation/providers/analytics_providers.dart
//
// ✅ FIXED: Removed duplicate ReadinessScore class and duplicate formula.
//           readinessScoreProvider now delegates to ReadinessCalculator (domain engine).
//           Single source of truth: domain/usecases/readiness_score.dart
// ✅ FIXED: readinessScoreProvider is now an AsyncNotifierProvider (FutureProvider)
//           so callers can handle loading/error states properly.
// Remaining providers: WeaknessRadar, BacklogRecoveryPlan, ExamMode (unchanged).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../data/local/isar/isar_service.dart';
import '../../data/repositories/study_log_repository.dart';
// ✅ Delegate to single engine — no formula duplication
import '../../domain/usecases/readiness_score.dart';
import '../../domain/planner/feasibility_engine.dart';
import '../../domain/planner/pass_probability_engine.dart';
import '../../domain/planner/decision_impact_engine.dart';
import '../../domain/planner/forecast_confidence_engine.dart';
import 'all_providers.dart';

// Re-export so existing widgets that import ReadinessScore from analytics_providers
// continue to work without any change.
export '../../domain/usecases/readiness_score.dart' show ReadinessScore;
export '../../domain/planner/feasibility_engine.dart'
    show FeasibilityResult, FeasibilityStatus, TrimCandidate;
export '../../domain/planner/pass_probability_engine.dart'
    show PassProbabilityResult, GroupProbability, PaperEstimate, ProbabilityReason;
export '../../domain/planner/decision_impact_engine.dart'
    show ImpactAction, ActionType;
export '../../domain/planner/forecast_confidence_engine.dart'
    show ForecastReadiness, ForecastStage, UnlockCriterion;

// ═══════════════════════════════════════════════════════════════════════════
// PART 4 — SYLLABUS FEASIBILITY (Planner v5 Stage 1; PLAN-1/PLAN-2 signal)
// ═══════════════════════════════════════════════════════════════════════════
// "Can I realistically finish in time?" — the one question the old planner
// never answered. Recomputes whenever the plan/chapters change; invalidate
// after study events the same way as readinessScoreProvider.
final feasibilityProvider = FutureProvider<FeasibilityResult>((ref) async {
  final user = ref.watch(authProvider).user;
  final chapters = ref.watch(planProvider).chapters;
  if (user == null || chapters.isEmpty) return FeasibilityResult.noData;

  List<DateTime> blackouts = const [];
  try {
    final settings =
        await IsarService.db.userSettingsSchemas.where().findFirst();
    blackouts = settings?.blackoutDates ?? const [];
  } catch (_) {}

  // ── Stage-4 seed: REAL pace, with a DYNAMIC window (Fix B). Far from the
  // exam, a 14-day average is stable; near it, responsiveness matters more
  // than smoothness — a bad final week must show immediately. Window shrinks
  // as the exam approaches: >90d → 14d, 30–90d → 10d, 14–30d → 7d, <14d → 3d.
  double? recentDailyActualHours;
  try {
    final user = ref.watch(authProvider).user;
    final daysLeft = user?.examDate != null
        ? user!.examDate!.difference(DateTime.now()).inDays
        : 999;
    final window = daysLeft <= 14
        ? 3
        : daysLeft <= 30
            ? 7
            : daysLeft <= 90
                ? 10
                : 14;
    final minActiveDays = window <= 3 ? 2 : 4;
    final cutoff = DateTime.now().subtract(Duration(days: window));
    final logs = await IsarService.db.studyLogSchemas
        .filter()
        .timestampGreaterThan(cutoff)
        .findAll();
    final activeDays = logs
        .map((l) =>
            DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day))
        .toSet()
        .length;
    if (activeDays >= minActiveDays) {
      final totalHours = logs.fold<double>(0, (s, l) => s + l.hoursStudied);
      recentDailyActualHours = totalHours / window;
    }
  } catch (_) {}

  return FeasibilityEngine.assess(
    chapters: chapters,
    hoursByWeekday: List<double>.filled(7, user.dailyStudyHours),
    examDate: user.examDate,
    blackoutDates: blackouts,
    recentDailyActualHours: recentDailyActualHours,
  );
});

// ═══════════════════════════════════════════════════════════════════════════
// EXAM READINESS SCORE  — delegates to ReadinessCalculator (domain engine)
// ═══════════════════════════════════════════════════════════════════════════

/// Async provider so UI can show a loading indicator and handle errors.
/// Invalidate with ref.invalidate(readinessScoreProvider) after any study event.
final readinessScoreProvider =
    FutureProvider.autoDispose<ReadinessScore>((ref) async {
  // Re-compute whenever plan or study logs change
  ref.watch(planProvider);
  ref.watch(studyLogProvider);
  final result = await ReadinessCalculator.calculate();
  // HIGH #7 — persist snapshot for 30-day trend chart (fire-and-forget)
  ReadinessCalculator.saveSnapshot(result);
  return result;
});

// ── HIGH #7: 30-day readiness trend ─────────────────────────────────────────
/// Loads the last 30 daily snapshots for the trend sparkline.
/// Sorted oldest-first so chart renders left→right.
final readinessTrendProvider =
    FutureProvider.autoDispose<List<ReadinessSnapshotSchema>>((ref) async {
  ref.watch(readinessScoreProvider); // re-fetch when score updates
  return ReadinessCalculator.loadTrend(days: 30);
});

// ═══════════════════════════════════════════════════════════════════════════
// WEAKNESS RADAR
// ═══════════════════════════════════════════════════════════════════════════

class WeaknessRadar {
  final List<ChapterSchema> weakChapters;
  final List<ChapterSchema> highBacklogChapters;
  final List<ChapterSchema> lowPyqChapters;
  final List<ChapterSchema> lowAccuracyChapters;
  final List<ChapterSchema> neverRevisedChapters;
  final Map<String, double> subjectWeakness; // subject → weakness score 0–1

  const WeaknessRadar({
    required this.weakChapters,
    required this.highBacklogChapters,
    required this.lowPyqChapters,
    required this.lowAccuracyChapters,
    required this.neverRevisedChapters,
    required this.subjectWeakness,
  });

  bool get hasWeaknesses =>
      weakChapters.isNotEmpty ||
      highBacklogChapters.isNotEmpty ||
      lowPyqChapters.isNotEmpty;

  int get totalWeakAreas =>
      weakChapters.length +
      highBacklogChapters.length +
      lowPyqChapters.length +
      lowAccuracyChapters.length;
}

final weaknessRadarProvider = Provider<WeaknessRadar>((ref) {
  final planState = ref.watch(planProvider);
  final chapters  = planState.chapters;

  if (chapters.isEmpty) {
    return const WeaknessRadar(
      weakChapters: [],
      highBacklogChapters: [],
      lowPyqChapters: [],
      lowAccuracyChapters: [],
      neverRevisedChapters: [],
      subjectWeakness: {},
    );
  }

  final weakChapters = chapters
      .where((c) => c.isWeakChapter || (c.masteryLevel <= 2 && c.weightage >= 3.0))
      .toList()
    ..sort((a, b) => b.weightage.compareTo(a.weightage));

  final highBacklog = chapters
      .where((c) => c.masteryLevel == 0 && c.weightage >= 2.5)
      .toList()
    ..sort((a, b) => b.weightage.compareTo(a.weightage));

  final lowPyq = chapters
      .where((c) => c.pyqProgress <= 1 && c.pyqCount >= 5 && c.masteryLevel >= 3)
      .toList()
    ..sort((a, b) => b.pyqCount.compareTo(a.pyqCount));

  final lowAccuracy = chapters
      .where((c) => c.testAttempts >= 5 && c.testAccuracy < 50)
      .toList()
    ..sort((a, b) => a.testAccuracy.compareTo(b.testAccuracy));

  final neverRevised = chapters
      .where((c) =>
          c.masteryLevel >= 3 &&
          c.revisionCount == 0 &&
          c.firstLearnedDate != null &&
          DateTime.now().difference(c.firstLearnedDate!).inDays > 7)
      .toList()
    ..sort((a, b) => b.weightage.compareTo(a.weightage));

  final subjects       = chapters.map((c) => c.subjectName).toSet();
  final subjectWeakness = <String, double>{};
  for (final s in subjects) {
    final sc = chapters.where((c) => c.subjectName == s).toList();
    if (sc.isEmpty) continue;
    final avgMastery    = sc.fold<double>(0, (sum, c) => sum + c.masteryLevel) / sc.length;
    final weakFraction  = sc.where((c) => c.isWeakChapter).length / sc.length;
    final score         = (1 - avgMastery / 7) * 0.6 + weakFraction * 0.4;
    subjectWeakness[s]  = score.clamp(0.0, 1.0);
  }

  return WeaknessRadar(
    weakChapters:         weakChapters.take(10).toList(),
    highBacklogChapters:  highBacklog.take(8).toList(),
    lowPyqChapters:       lowPyq.take(8).toList(),
    lowAccuracyChapters:  lowAccuracy.take(8).toList(),
    neverRevisedChapters: neverRevised.take(8).toList(),
    subjectWeakness:      subjectWeakness,
  );
});

// ═══════════════════════════════════════════════════════════════════════════
// BACKLOG RECOVERY ENGINE
// ═══════════════════════════════════════════════════════════════════════════

class BacklogRecoveryPlan {
  final List<RecoveryItem> items;
  final int totalBacklogChapters;
  final double estimatedDaysToRecover;
  final String urgencyLevel; // 'low'|'medium'|'high'|'critical'

  const BacklogRecoveryPlan({
    required this.items,
    required this.totalBacklogChapters,
    required this.estimatedDaysToRecover,
    required this.urgencyLevel,
  });

  bool get hasBacklog => totalBacklogChapters > 0;
}

class RecoveryItem {
  final ChapterSchema chapter;
  final String reason;
  final String action;
  final int priority; // 1=highest

  const RecoveryItem({
    required this.chapter,
    required this.reason,
    required this.action,
    required this.priority,
  });
}

final backlogRecoveryProvider = Provider<BacklogRecoveryPlan>((ref) {
  final planState = ref.watch(planProvider);
  final auth      = ref.watch(authProvider);
  final chapters  = planState.chapters;

  if (chapters.isEmpty) {
    return const BacklogRecoveryPlan(
      items: [],
      totalBacklogChapters: 0,
      estimatedDaysToRecover: 0,
      urgencyLevel: 'low',
    );
  }

  final examDate = auth.user?.examDate;
  final daysLeft = examDate != null
      ? examDate.difference(DateTime.now()).inDays.clamp(0, 9999)
      : 180;

  final backloggedChapters = chapters
      .where((c) => c.masteryLevel == 0 || (c.masteryLevel <= 1 && c.weightage >= 3.0))
      .toList()
    ..sort((a, b) {
      final w = b.weightage.compareTo(a.weightage);
      return w != 0 ? w : b.pyqCount.compareTo(a.pyqCount);
    });

  final totalHoursNeeded = backloggedChapters.fold<double>(
      0, (s, c) => s + c.estimatedHours * (1 - c.progressFraction));

  final dailyHours          = auth.user?.dailyStudyHours ?? 5.0;
  final recoveryHoursPerDay = dailyHours * 0.4;
  final daysToRecover       = recoveryHoursPerDay > 0
      ? totalHoursNeeded / recoveryHoursPerDay
      : double.infinity;

  String urgency;
  if (backloggedChapters.isEmpty) {
    urgency = 'low';
  } else if (daysToRecover <= daysLeft * 0.3) {
    urgency = 'medium';
  } else if (daysToRecover <= daysLeft * 0.6) {
    urgency = 'high';
  } else {
    urgency = 'critical';
  }

  final items = backloggedChapters.take(12).toList().asMap().entries.map((e) {
    final c    = e.value;
    final rank = e.key + 1;
    final reason = c.masteryLevel == 0
        ? 'Not started • ${c.weightage.toStringAsFixed(1)} weightage'
        : 'Incomplete theory • ${c.weightage.toStringAsFixed(1)} weightage';
    final action = c.masteryLevel == 0
        ? 'Start theory + ${(c.estimatedHours * 0.5).toStringAsFixed(1)}h questions'
        : 'Complete theory in ${c.estimatedHours.toStringAsFixed(1)}h';
    return RecoveryItem(chapter: c, reason: reason, action: action, priority: rank);
  }).toList();

  return BacklogRecoveryPlan(
    items:                   items,
    totalBacklogChapters:    backloggedChapters.length,
    estimatedDaysToRecover:  daysToRecover.isFinite ? daysToRecover : 999,
    urgencyLevel:            urgency,
  );
});

// ═══════════════════════════════════════════════════════════════════════════
// EXAM MODE  (Last 180 / 90 / 60 / 30 / 15 / 7 days)
// ═══════════════════════════════════════════════════════════════════════════

class ExamMode {
  final String phase;
  final String focusArea;
  final String emoji;
  final List<String> recommendations;
  final int daysLeft;
  final bool isActive;

  const ExamMode({
    required this.phase,
    required this.focusArea,
    required this.emoji,
    required this.recommendations,
    required this.daysLeft,
    this.isActive = false,
  });

  static const inactive = ExamMode(
    phase: 'Foundation Phase',
    focusArea: 'Syllabus Coverage',
    emoji: '📚',
    recommendations: [
      'Focus on covering all chapters systematically',
      'Build strong theory foundations',
      'Practice basic questions chapter by chapter',
      'Maintain 6+ hours daily study habit',
    ],
    daysLeft: 999,
    isActive: true,
  );
}

final examModeProvider = Provider<ExamMode>((ref) {
  final auth     = ref.watch(authProvider);
  final examDate = auth.user?.examDate;
  if (examDate == null) return ExamMode.inactive;

  final daysLeft = examDate.difference(DateTime.now()).inDays;

  if (daysLeft <= 7) {
    return ExamMode(
      phase: 'Final Revision', focusArea: 'Last 7 Days', emoji: '🔥',
      daysLeft: daysLeft, isActive: true,
      recommendations: [
        'No new topics — revision only',
        'Revise formula sheets daily',
        'Attempt 1 mock test per day',
        'Get 8 hours of sleep',
        'Light nutrition, stay hydrated',
      ],
    );
  } else if (daysLeft <= 15) {
    return ExamMode(
      phase: 'Formula Sprint', focusArea: 'Last 15 Days', emoji: '⚡',
      daysLeft: daysLeft, isActive: true,
      recommendations: [
        'Revise all formula sheets twice daily',
        'Focus on common mistake patterns',
        'Attempt 2 mock tests per week',
        'Target weak chapters from mock tests',
        'Avoid starting any new chapter',
      ],
    );
  } else if (daysLeft <= 30) {
    return ExamMode(
      phase: 'PYQ Intensive', focusArea: 'Last 30 Days', emoji: '📝',
      daysLeft: daysLeft, isActive: true,
      recommendations: [
        'Complete all pending PYQs chapter-wise',
        'Attempt 3+ mock tests per week',
        'Analyse every wrong answer in tests',
        'Revise weak chapters first every day',
        'No backlog — complete pending chapters',
      ],
    );
  } else if (daysLeft <= 60) {
    return ExamMode(
      phase: 'Weakness Fixing', focusArea: 'Last 60 Days', emoji: '🎯',
      daysLeft: daysLeft, isActive: true,
      recommendations: [
        'Target all weak chapters from tests',
        'Complete remaining syllabus',
        'Attempt weekly full mock tests',
        'Strengthen low-accuracy subjects',
        'Build revision frequency for learned chapters',
      ],
    );
  } else if (daysLeft <= 90) {
    return ExamMode(
      phase: 'Mock Test Mode', focusArea: 'Last 90 Days', emoji: '🧪',
      daysLeft: daysLeft, isActive: true,
      recommendations: [
        'Attempt mock tests every week',
        'Start chapter-wise PYQ practice',
        'Complete revision of all studied chapters',
        'Identify weak subjects from test analysis',
        'Maintain daily study consistency',
      ],
    );
  } else if (daysLeft <= 180) {
    return ExamMode(
      phase: 'Revision & Coverage', focusArea: 'Last 180 Days', emoji: '🔄',
      daysLeft: daysLeft, isActive: true,
      recommendations: [
        'Cover remaining syllabus chapters',
        'Begin first revision of completed topics',
        'Start PYQ practice for strong chapters',
        'Attempt chapter-wise tests',
        'Build study consistency above 5h/day',
      ],
    );
  }

  return ExamMode.inactive;
});

// ═══════════════════════════════════════════════════════════════════════════
// FLAGSHIP — Pass Probability (CA Final) + Decision Impact Ranking
// ═══════════════════════════════════════════════════════════════════════════
// One shared probability primitive read by every higher-order surface, and the
// next-best-action ranking computed as a true counterfactual over it. Both
// recompute whenever chapters change; invalidate alongside readiness/feasibility.

final passProbabilityProvider = Provider<PassProbabilityResult>((ref) {
  final user = ref.watch(authProvider).user;
  final chapters = ref.watch(planProvider).chapters;
  if (user?.targetExam != 'ca_final' || chapters.isEmpty) {
    return PassProbabilityResult.empty;
  }
  return PassProbabilityEngine.assessCaFinal(chapters);
});

final decisionImpactProvider = Provider<List<ImpactAction>>((ref) {
  final user = ref.watch(authProvider).user;
  final chapters = ref.watch(planProvider).chapters;
  if (user?.targetExam != 'ca_final' || chapters.isEmpty) return const [];
  return DecisionImpactEngine.rank(chapters, limit: 5);
});

// ═══════════════════════════════════════════════════════════════════════════
// PART 5 — Forecast readiness (staging + confidence) & Momentum
// ═══════════════════════════════════════════════════════════════════════════

/// Gates the pass-probability forecast behind real evidence and reports how
/// much the student should trust it. The dashboard uses this to decide whether
/// to show the "Preparation Baseline" checklist, an "early estimate", or the
/// full forecast.
final forecastReadinessProvider =
    FutureProvider<ForecastReadiness>((ref) async {
  final user = ref.watch(authProvider).user;
  final chapters = ref.watch(planProvider).chapters;
  if (user?.targetExam != 'ca_final' || chapters.isEmpty) {
    return const ForecastReadiness(
      stage: ForecastStage.baseline,
      confidence: 0,
      confidenceLabel: 'Low',
      reasons: [],
      criteria: [],
    );
  }
  int sessions = 0;
  try {
    sessions = await StudyLogRepository.totalCount();
  } catch (_) {}
  return ForecastConfidenceEngine.assess(chapters, studySessionCount: sessions);
});

/// Last-14-day momentum: hours done vs target pace + chapters touched, for a
/// motivating "you're moving" card. Honest — zero days count against pace.
class MomentumSummary {
  final double hours14d;
  final double targetHours14d;
  final int chaptersTouched;
  final double pacePercent; // 100 = on pace, >100 ahead
  final bool hasData;
  const MomentumSummary({
    required this.hours14d,
    required this.targetHours14d,
    required this.chaptersTouched,
    required this.pacePercent,
    required this.hasData,
  });
  static const empty = MomentumSummary(
      hours14d: 0,
      targetHours14d: 0,
      chaptersTouched: 0,
      pacePercent: 0,
      hasData: false);
}

final momentumProvider = FutureProvider<MomentumSummary>((ref) async {
  final user = ref.watch(authProvider).user;
  ref.watch(planProvider); // refresh after study events
  if (user == null) return MomentumSummary.empty;

  try {
    final cutoff = DateTime.now().subtract(const Duration(days: 14));
    final logs = await StudyLogRepository.since(cutoff);
    if (logs.isEmpty) return MomentumSummary.empty;
    final hours = logs.fold<double>(0, (s, l) => s + l.hoursStudied);
    final touched = logs
        .map((l) => l.chapterKey.isNotEmpty ? l.chapterKey : l.chapterName)
        .toSet()
        .length;
    final target = (user.dailyStudyHours) * 14.0;
    final pace = target > 0 ? (hours / target * 100) : 0.0;
    return MomentumSummary(
      hours14d: hours,
      targetHours14d: target,
      chaptersTouched: touched,
      pacePercent: pace,
      hasData: true,
    );
  } catch (_) {
    return MomentumSummary.empty;
  }
});
