// lib/domain/planner/feasibility_engine.dart
//
// PART 4 — Planner v5, Stage 1: Feasibility Engine (v2).
//
// v1 closed PLAN-1 (exact calendar capacity, no 180-day cap) and PLAN-2
// (need-based demand + Smart-Trim). v2 hardens the three inputs the whole
// model stands on — the review's exact worries:
//
//   1. MASTERY NOISE → evidence-blended mastery. A chapter's declared mastery
//      ladder (0–7) is only believed up to a bounded head-start beyond what
//      the EVIDENCE supports (hours actually spent + test accuracy). A chapter
//      tapped to "Revised" with 0.5h logged and no tests no longer deletes
//      90% of its need from the plan. Planning errs conservative by design:
//      over-estimating remaining work costs a few spare hours; under-estimating
//      it costs the exam.
//
//   2. ESTIMATE QUALITY → per-subject self-calibration. The syllabus JSON's
//      estimatedHours are editorial guesses. Once the student has genuinely
//      worked chapters to (near-)completion, their OWN cost data is better:
//      we extrapolate true full cost per worked chapter
//      (hoursSpent / masteryFraction), take the median ratio vs the estimate
//      per subject (median = robust to one outlier chapter), clamp to
//      0.70–1.60, and scale that subject's remaining needs by it. A student
//      who consistently needs 1.3× the book time on Audit gets an Audit plan
//      that says so. Falls back to a global median, then 1.0, when samples
//      are scarce (≥2 per subject / ≥3 global required).
//
//   3. NO VELOCITY LOOP → 14-day pace signal (Stage-4 seed). The caller
//      passes the student's actual average study hours/day over the last 14
//      days; the engine reports a second, parallel verdict at REAL pace
//      (velocity = actual ÷ planned, clamped 0.25–1.15). "Plan says 6h/day,
//      you're doing 3.1 → at your real pace coverage is 54%." The full
//      auto-rebalancing loop (rewriting future entries weekly) remains a
//      dedicated Stage-4 build per the Master Spec — this ships the honest
//      measurement it will be built on, surfaced to the student today.
//
// Pure functions over data the app already has. Deterministic, unit-testable,
// no I/O.

import 'dart:math' as math;

import '../../data/local/isar/isar_service.dart'; // re-exports ChapterSchema

/// One chapter the student could drop to make an infeasible plan fit, with the
/// marks it would cost — lowest ROI first.
class TrimCandidate {
  final String chapterName;
  final String subjectName;
  final double remainingHours;
  final double weightage; // marks-weight proxy
  const TrimCandidate({
    required this.chapterName,
    required this.subjectName,
    required this.remainingHours,
    required this.weightage,
  });
}

enum FeasibilityStatus { comfortable, tight, atRisk, noData }

class FeasibilityResult {
  final FeasibilityStatus status;
  final double requiredHours; // calibrated hours still needed to finish
  final double availableHours; // real capacity over the remaining calendar
  final double coverageRatio; // available / required  (>=1 means it fits)
  final int daysLeft;
  final List<TrimCandidate> trimSuggestions; // only when at risk
  final double trimmableMarksCost; // marks at stake in the trim list

  // ── Velocity layer (Stage-4 seed). Null/absent when too little log data. ──
  /// actual ÷ planned daily hours over the last 14 days, clamped 0.25–1.15.
  final double? velocity;

  /// Raw average actual study hours/day over the last 14 days (unclamped),
  /// for honest display ("you averaged 3.1h/day").
  final double? actualDailyHours;

  /// Coverage if the student keeps their REAL recent pace instead of the
  /// promised daily hours.
  final double? paceCoverageRatio;
  final FeasibilityStatus? paceStatus;

  const FeasibilityResult({
    required this.status,
    required this.requiredHours,
    required this.availableHours,
    required this.coverageRatio,
    required this.daysLeft,
    this.trimSuggestions = const [],
    this.trimmableMarksCost = 0,
    this.velocity,
    this.actualDailyHours,
    this.paceCoverageRatio,
    this.paceStatus,
  });

  static const noData = FeasibilityResult(
    status: FeasibilityStatus.noData,
    requiredHours: 0,
    availableHours: 0,
    coverageRatio: 0,
    daysLeft: 0,
  );

  /// Hours-per-day the student would need to *just* finish on time.
  double get requiredHoursPerDay =>
      daysLeft > 0 ? requiredHours / daysLeft : requiredHours;

  /// True when the student's real pace gives a materially worse verdict than
  /// the promised pace — the signal worth interrupting them for.
  bool get paceIsTheProblem =>
      velocity != null &&
      velocity! < 0.92 &&
      paceStatus != null &&
      paceStatus!.index > status.index;

  String get headline {
    switch (status) {
      case FeasibilityStatus.comfortable:
        return 'On track to finish in time';
      case FeasibilityStatus.tight:
        return 'Finishable, but tight';
      case FeasibilityStatus.atRisk:
        return "Won't finish at this pace";
      case FeasibilityStatus.noData:
        return 'Not enough data yet';
    }
  }
}

class FeasibilityEngine {
  FeasibilityEngine._();

  // Tunables (mirror Planner v5 Part 3 reserves).
  static const double _slack = 0.12; // 12% buffer for slippage
  static const double _reservedForMocksAndRevision = 0.18; // 18% off the top
  static const double _comfortableAt = 1.15;
  static const double _atRiskBelow = 0.85;

  // Evidence model tunables.
  static const double _declaredHeadStart = 0.30; // belief beyond evidence
  static const int _minTestAttemptsToTrust = 3;
  static const double _testEvidenceWeight = 0.55;

  // Calibration tunables.
  static const double _minGlobalSamples = 3;
  static const double _calibrationFloor = 0.70;
  static const double _calibrationCeil = 1.60;

  // Velocity tunables.
  static const double _velocityFloor = 0.25;
  static const double _velocityCeil = 1.15;

  // ── 1. Evidence-blended mastery ──────────────────────────────────────────
  /// What fraction of this chapter can the plan SAFELY consider done?
  /// Declared mastery (the 0–7 ladder) is capped at a bounded head-start
  /// above measurable evidence: hours actually invested and (when there are
  /// enough attempts to mean anything) test accuracy.
  static double effectiveMastery(ChapterSchema c) {
    final declared = (c.masteryLevel / 7.0).clamp(0.0, 1.0);
    final est = c.estimatedHours <= 0 ? 2.0 : c.estimatedHours;
    final hoursEvidence = (c.hoursSpent / est).clamp(0.0, 1.0);
    final double evidence;
    if (c.testAttempts >= _minTestAttemptsToTrust) {
      final testEvidence = (c.testAccuracy / 100.0).clamp(0.0, 1.0);
      evidence = _testEvidenceWeight * testEvidence +
          (1 - _testEvidenceWeight) * hoursEvidence;
    } else {
      evidence = hoursEvidence;
    }
    final believable =
        _declaredHeadStart + (1 - _declaredHeadStart) * evidence;
    return math.min(declared, believable);
  }

  // ── 2. Per-subject estimate calibration ──────────────────────────────────
  /// Learns the student's true cost multiplier per subject from chapters
  /// they've genuinely worked (mastery ≥ 5 with real hours logged). For each
  /// such chapter the full cost is extrapolated as hoursSpent ÷ masteryFraction
  /// and compared to the editorial estimate; the per-subject MEDIAN ratio
  /// (robust to a single weird chapter) becomes that subject's multiplier,
  /// clamped to 0.70–1.60. Subjects without enough samples inherit the global
  /// median; with no usable history at all, everything stays at 1.0.
  static Map<String, double> subjectCalibration(List<ChapterSchema> chapters) {
    final bySubject = <String, List<double>>{};
    final global = <double>[];

    for (final c in chapters) {
      if (c.masteryLevel < 5 || c.hoursSpent < 0.5 || c.estimatedHours <= 0) {
        continue;
      }
      final masteryFrac = (c.masteryLevel / 7.0).clamp(0.5, 1.0);
      final impliedFullCost = c.hoursSpent / masteryFrac;
      final ratio = (impliedFullCost / c.estimatedHours)
          .clamp(_calibrationFloor / 2, _calibrationCeil * 2);
      bySubject.putIfAbsent(c.subjectName, () => []).add(ratio);
      global.add(ratio);
    }

    double clampCal(double v) =>
        v.clamp(_calibrationFloor, _calibrationCeil).toDouble();

    final globalCal = global.length >= _minGlobalSamples
        ? clampCal(_median(global))
        : 1.0;

    final result = <String, double>{};
    for (final c in chapters) {
      final samples = bySubject[c.subjectName];
      final n = samples?.length ?? 0;
      if (n == 0) {
        result[c.subjectName] = globalCal;
        continue;
      }
      // Fix A — SMOOTHED calibration. Instead of flipping from global to
      // subject-only at a hard threshold (a jarring 1.0 → 1.6 overnight as the
      // 2nd sample lands), confidence grows with sample count and the subject
      // multiplier is blended toward from the global one:
      //   1 sample  → ~25% subject   3 samples → ~60%   5 samples → ~80%
      //   8+ samples→ ~92% subject.  w = n / (n + k), k = 3.
      final subjectCal = clampCal(_median(samples!));
      final w = n / (n + 3.0);
      result[c.subjectName] = globalCal + (subjectCal - globalCal) * w;
    }
    return result;
  }

  /// Calibrated remaining hours for one chapter — the single formula both this
  /// engine and GeneratePlanUseCase allocate from, so the plan and the verdict
  /// can never disagree about what "need" means.
  static double remainingNeed(ChapterSchema c, Map<String, double> calibration) {
    final est = c.estimatedHours <= 0 ? 2.0 : c.estimatedHours;
    final cal = calibration[c.subjectName] ?? 1.0;
    return math.max(0.0, est * cal * (1.0 - effectiveMastery(c)));
  }

  // ── 3. Assessment ────────────────────────────────────────────────────────
  /// [hoursByWeekday] is Sun..Sat (index 0 = Sunday) target study hours.
  /// [recentDailyActualHours]: the student's average ACTUAL study hours/day
  /// over the last ~14 days (caller computes from study logs; pass null when
  /// there's too little data to mean anything).
  static FeasibilityResult assess({
    required List<ChapterSchema> chapters,
    required List<double> hoursByWeekday, // length 7, Sun..Sat
    required DateTime? examDate,
    List<DateTime> blackoutDates = const [],
    double? recentDailyActualHours,
  }) {
    if (chapters.isEmpty || examDate == null) return FeasibilityResult.noData;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exam = DateTime(examDate.year, examDate.month, examDate.day);
    final daysLeft = exam.difference(today).inDays;
    if (daysLeft <= 0) return FeasibilityResult.noData;

    // ── Required: calibrated, evidence-honest remaining hours.
    final calibration = subjectCalibration(chapters);
    double required = 0;
    for (final c in chapters) {
      required += remainingNeed(c, calibration);
    }

    // ── Available: EXACT capacity over the real calendar (PLAN-1: no cap).
    final blackout =
        blackoutDates.map((d) => DateTime(d.year, d.month, d.day)).toSet();
    double available = 0;
    for (int i = 0; i < daysLeft; i++) {
      final day = today.add(Duration(days: i));
      if (blackout.contains(DateTime(day.year, day.month, day.day))) continue;
      // Dart weekday: Mon=1..Sun=7 → our Sun=0..Sat=6 index.
      final idx = day.weekday % 7;
      available += idx < hoursByWeekday.length ? hoursByWeekday[idx] : 0;
    }
    final effective =
        available * (1 - _reservedForMocksAndRevision) * (1 - _slack);

    final coverage = required <= 0 ? 2.0 : effective / required;
    final status = _statusFor(coverage);

    // ── Velocity layer: same verdict at the student's REAL recent pace.
    double? velocity;
    double? paceCoverage;
    FeasibilityStatus? paceStatus;
    final plannedPerDay = hoursByWeekday.isEmpty
        ? 0.0
        : hoursByWeekday.reduce((a, b) => a + b) / hoursByWeekday.length;
    if (recentDailyActualHours != null && plannedPerDay > 0.1) {
      velocity = (recentDailyActualHours / plannedPerDay)
          .clamp(_velocityFloor, _velocityCeil)
          .toDouble();
      final paceEffective = effective * velocity;
      paceCoverage = required <= 0 ? 2.0 : paceEffective / required;
      paceStatus = _statusFor(paceCoverage);
    }

    // ── Smart-Trim (only when at risk at PROMISED pace): drop lowest-ROI
    // chapters until the plan fits, surfacing the marks cost honestly.
    final trims = <TrimCandidate>[];
    double trimmedMarks = 0;
    if (status == FeasibilityStatus.atRisk) {
      final gap = required - effective; // hours we must shed
      final ranked = <_RoiRow>[];
      for (final c in chapters) {
        final remaining = remainingNeed(c, calibration);
        if (remaining <= 0) continue;
        final w = c.weightage <= 0 ? 1.0 : c.weightage;
        final roi = w / remaining; // marks per hour — lower = better to cut
        ranked.add(_RoiRow(c, remaining, w, roi));
      }
      ranked.sort((a, b) => a.roi.compareTo(b.roi)); // worst ROI first
      double shed = 0;
      for (final r in ranked) {
        if (shed >= gap) break;
        trims.add(TrimCandidate(
          chapterName: r.chapter.name,
          subjectName: r.chapter.subjectName,
          remainingHours: r.remaining,
          weightage: r.weightage,
        ));
        shed += r.remaining;
        trimmedMarks += r.weightage;
      }
    }

    return FeasibilityResult(
      status: status,
      requiredHours: required,
      availableHours: effective,
      coverageRatio: coverage,
      daysLeft: daysLeft,
      trimSuggestions: trims,
      trimmableMarksCost: trimmedMarks,
      velocity: velocity,
      actualDailyHours: recentDailyActualHours,
      paceCoverageRatio: paceCoverage,
      paceStatus: paceStatus,
    );
  }

  static FeasibilityStatus _statusFor(double coverage) {
    if (coverage >= _comfortableAt) return FeasibilityStatus.comfortable;
    if (coverage >= _atRiskBelow) return FeasibilityStatus.tight;
    return FeasibilityStatus.atRisk;
  }

  static double _median(List<double> values) {
    final sorted = List<double>.from(values)..sort();
    final n = sorted.length;
    if (n == 0) return 1.0;
    return n.isOdd
        ? sorted[n ~/ 2]
        : (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2.0;
  }
}

class _RoiRow {
  final ChapterSchema chapter;
  final double remaining;
  final double weightage;
  final double roi;
  const _RoiRow(this.chapter, this.remaining, this.weightage, this.roi);
}
