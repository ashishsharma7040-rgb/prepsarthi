// lib/domain/planner/forecast_confidence_engine.dart
//
// PART 5 — Forecast Confidence & Readiness Staging.
//
// The intelligence engine became accurate, but a brand-new student opening the
// app saw "Pass Probability 0% / 0% / 0%". That is not just demotivating — it
// is statistically WRONG. With near-zero evidence the honest forecast is
// "unknown", not "you will score zero". A point estimate is only trustworthy
// once enough evidence backs it.
//
// This engine answers ONE question the whole dashboard now defers to:
//   "Do we have enough evidence to show a pass-probability forecast yet, and
//    how much should the student trust it?"
//
// Three stages, gated by an explainable confidence score (0..1):
//   • baseline    — too little data. Hide the % entirely; show a positive
//                   "Preparation Baseline" with an unlock checklist.
//   • emerging    — some data. Show the forecast, clearly labelled "Early
//                   estimate · building confidence" and visually softened.
//   • established — enough breadth + validation. Show the full forecast with
//                   High confidence.
//
// Evidence is multi-signal on purpose: a student who self-rates 10 chapters
// "mastered" but has never taken a mock has BREADTH without VALIDATION, so
// confidence stays medium until a mock confirms it. This is the same
// evidence-honest philosophy as the retention/feasibility engines, applied to
// the forecast's own trustworthiness.
//
// Pure. Deterministic. No I/O.

import 'dart:math' as math;

import '../../data/local/isar/isar_service.dart'; // ChapterSchema
import 'feasibility_engine.dart';

enum ForecastStage { baseline, emerging, established }

/// One unlock requirement shown on the baseline card ("✓ 3 / 10 sessions").
class UnlockCriterion {
  final String label;
  final int current;
  final int target;
  const UnlockCriterion(this.label, this.current, this.target);
  bool get met => current >= target;
  double get progress => target <= 0 ? 1 : (current / target).clamp(0.0, 1.0);
}

class ForecastReadiness {
  final ForecastStage stage;
  final double confidence; // 0..1
  final String confidenceLabel; // Low / Medium / High
  final List<String> reasons; // why confidence is where it is
  final List<UnlockCriterion> criteria; // for the baseline checklist
  const ForecastReadiness({
    required this.stage,
    required this.confidence,
    required this.confidenceLabel,
    required this.reasons,
    required this.criteria,
  });

  bool get showForecast => stage != ForecastStage.baseline;
  bool get isEarly => stage == ForecastStage.emerging;
}

class ForecastConfidenceEngine {
  ForecastConfidenceEngine._();

  // Unlock targets — calibrated for CA Final (6 papers, ~50+ chapters).
  static const int _targetCoveredChapters = 8; // chapters with real coverage
  static const int _targetCompletions = 3; // chapters at/near mastery
  static const int _targetSessions = 10; // logged study sessions
  static const int _targetMocks = 1; // at least one validated attempt

  // Signal weights (sum = 1.0). Validation (mocks) and breadth matter most:
  // a forecast you can't defend with breadth + a real test isn't trustworthy.
  static const double _wBreadth = 0.34;
  static const double _wDepth = 0.22;
  static const double _wSessions = 0.16;
  static const double _wValidation = 0.28;

  // Stage thresholds on the blended confidence.
  static const double _emergingAt = 0.18;
  static const double _establishedAt = 0.55;

  /// [studySessionCount] = total logged study sessions (full history).
  static ForecastReadiness assess(
    List<ChapterSchema> chapters, {
    required int studySessionCount,
  }) {
    if (chapters.isEmpty) {
      return const ForecastReadiness(
        stage: ForecastStage.baseline,
        confidence: 0,
        confidenceLabel: 'Low',
        reasons: ['No syllabus loaded yet'],
        criteria: [],
      );
    }

    // Count evidence.
    var covered = 0; // chapters with meaningful real coverage
    var completions = 0; // chapters at/near mastery
    var totalMockAttempts = 0;
    for (final c in chapters) {
      final m = FeasibilityEngine.effectiveMastery(c);
      if (m >= 0.25) covered++;
      if (c.masteryLevel >= 6) completions++;
      totalMockAttempts += c.testAttempts;
    }

    // Normalised signals (0..1).
    final breadth = (covered / _targetCoveredChapters).clamp(0.0, 1.0);
    final depth = (completions / _targetCompletions).clamp(0.0, 1.0);
    final sessions = (studySessionCount / _targetSessions).clamp(0.0, 1.0);
    // Validation saturates faster: even one solid mock is a big trust jump.
    final validation =
        (totalMockAttempts / (_targetMocks * 3)).clamp(0.0, 1.0);

    final confidence = (_wBreadth * breadth +
            _wDepth * depth +
            _wSessions * sessions +
            _wValidation * validation)
        .clamp(0.0, 1.0);

    final stage = confidence >= _establishedAt
        ? ForecastStage.established
        : confidence >= _emergingAt
            ? ForecastStage.emerging
            : ForecastStage.baseline;

    final label = confidence >= _establishedAt
        ? 'High'
        : confidence >= _emergingAt
            ? 'Medium'
            : 'Low';

    final criteria = [
      UnlockCriterion('Study sessions', studySessionCount, _targetSessions),
      UnlockCriterion('Chapters covered', covered, _targetCoveredChapters),
      UnlockCriterion('Chapters completed', completions, _targetCompletions),
      UnlockCriterion('Mock attempt', totalMockAttempts, _targetMocks),
    ];

    return ForecastReadiness(
      stage: stage,
      confidence: confidence,
      confidenceLabel: label,
      reasons: _reasons(
        breadth: breadth,
        depth: depth,
        validation: validation,
        sessions: sessions,
        mocks: totalMockAttempts,
      ),
      criteria: criteria,
    );
  }

  static List<String> _reasons({
    required double breadth,
    required double depth,
    required double validation,
    required double sessions,
    required int mocks,
  }) {
    final out = <String>[];
    // Surface the WEAKEST evidence first — that's what's holding trust down.
    final ranked = <(String, double)>[
      ('limited mock validation', validation),
      ('narrow syllabus coverage so far', breadth),
      ('few completed chapters', depth),
      ('limited study history', sessions),
    ]..sort((a, b) => a.$2.compareTo(b.$2));

    for (final r in ranked.take(2)) {
      if (r.$2 < 0.6) out.add(r.$1);
    }
    if (mocks == 0) {
      out.insert(0, 'no mock attempted yet — a mock sharpens the forecast most');
    }
    if (out.isEmpty) out.add('broad coverage and validated by tests');
    return out.take(3).toList();
  }
}
