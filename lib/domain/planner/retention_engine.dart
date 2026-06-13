// lib/domain/planner/retention_engine.dart
//
// FOUNDATION 1 — Memory retention / forgetting curve.
//
// The old planner assumed mastery, once reached, is permanent. Reality: a
// chapter revised four months ago has decayed. Every higher-order feature
// (pass probability, decision impact, revision urgency) needs to know how much
// of a chapter the student would ACTUALLY retain if examined today — not what
// they once knew.
//
// Model: Ebbinghaus exponential decay  R(t) = floor + (peak − floor)·e^(−t/S)
//   • peak   — knowledge level right after the last study/revision, derived
//              from evidence-honest mastery (NOT the raw declared ladder).
//   • floor  — the residual that essentially never decays (recognition,
//              gist). Higher for easier chapters, lower for hard/numerical.
//   • S      — memory strength (days). Grows with each revision (spacing
//              effect: every successful revision flattens the curve) and with
//              demonstrated test accuracy; shrinks for difficult chapters and
//              chapters with a history of mistakes.
//
// All pure functions. Deterministic. Unit-testable. No I/O.

import 'dart:math' as math;

import '../../data/local/isar/isar_service.dart'; // re-exports ChapterSchema
import 'feasibility_engine.dart'; // shared evidence-honest mastery

class RetentionResult {
  final double retention; // 0..1 — fraction recalled if tested today
  final double peak; // 0..1 — level right after last study
  final double strengthDays; // memory half-life proxy (S)
  final int daysSinceStudy;
  final double decayPerWeek; // points/week being lost right now (for ranking)
  const RetentionResult({
    required this.retention,
    required this.peak,
    required this.strengthDays,
    required this.daysSinceStudy,
    required this.decayPerWeek,
  });

  static const cold = RetentionResult(
    retention: 0,
    peak: 0,
    strengthDays: 1,
    daysSinceStudy: 0,
    decayPerWeek: 0,
  );

  /// Human-readable urgency band for the UI.
  String get band {
    if (peak <= 0.05) return 'not-learned';
    if (retention >= 0.80) return 'fresh';
    if (retention >= 0.60) return 'fading';
    if (retention >= 0.40) return 'weak';
    return 'critical';
  }
}

class RetentionEngine {
  RetentionEngine._();

  // Strength model tunables (days).
  static const double _baseStrength = 9.0; // first-pass half-life-ish
  static const double _perRevisionGain = 7.0; // spacing effect per revision
  static const double _maxStrength = 120.0;
  static const double _accuracyStrengthBoost = 14.0; // at 100% test accuracy

  /// Retention for a single chapter as of [asOf] (defaults to now).
  static RetentionResult forChapter(ChapterSchema c, {DateTime? asOf}) {
    final now = asOf ?? DateTime.now();

    // Peak = evidence-honest mastery at last study (caps wishful self-rating).
    final peak = FeasibilityEngine.effectiveMastery(c);
    if (peak <= 0.05) return RetentionResult.cold;

    // Anchor date = most recent of last-studied / first-learned.
    final anchor = c.lastStudiedDate ?? c.firstLearnedDate;
    if (anchor == null) {
      // Learned but no date — treat as just studied (no decay yet).
      return RetentionResult(
        retention: peak,
        peak: peak,
        strengthDays: _strength(c),
        daysSinceStudy: 0,
        decayPerWeek: 0,
      );
    }
    final days = math.max(0, now.difference(anchor).inDays);

    // Floor: durable residual. Easy chapters keep more; hard/numerical less.
    // difficulty is 1 (easy) .. 5 (hard).
    final floor = (0.34 - (c.difficulty - 1) * 0.05).clamp(0.12, 0.34);

    final strength = _strength(c);
    final decayed = floor + (peak - floor) * math.exp(-days / strength);
    final retention = decayed.clamp(0.0, peak);

    // Instantaneous loss rate (points/week) — used by decision-impact ranking
    // to prioritise chapters bleeding the most marks right now.
    final dPerDay = (peak - floor) * (1 / strength) * math.exp(-days / strength);
    final decayPerWeek = (dPerDay * 7).clamp(0.0, 1.0);

    return RetentionResult(
      retention: retention,
      peak: peak,
      strengthDays: strength,
      daysSinceStudy: days,
      decayPerWeek: decayPerWeek,
    );
  }

  /// Memory strength S (days) — bigger = flatter forgetting curve.
  static double _strength(ChapterSchema c) {
    var s = _baseStrength + c.revisionCount * _perRevisionGain;
    if (c.testAttempts >= 3) {
      s += (c.testAccuracy / 100.0) * _accuracyStrengthBoost;
    }
    // Difficulty drag: hard chapters decay faster (shorter strength).
    s *= (1.0 - (c.difficulty - 1) * 0.07).clamp(0.7, 1.0);
    // Mistake history shortens retention (shaky encoding).
    final mistakes =
        c.conceptualMistakes + c.calculationMistakes + c.sillyMistakes;
    if (mistakes > 0) s *= (1.0 - math.min(mistakes, 6) * 0.03);
    return s.clamp(3.0, _maxStrength);
  }

  /// Days from last study until retention is predicted to fall to [target]
  /// (e.g. 0.6). Negative/zero means already below target → revise now.
  static int daysUntilRetention(ChapterSchema c, double target) {
    final r = forChapter(c);
    if (r.peak <= 0.05) return 0;
    final floor = (0.34 - (c.difficulty - 1) * 0.05).clamp(0.12, 0.34);
    if (target <= floor) return 9999; // never decays below floor
    if (target >= r.peak) return 0;
    final s = r.strengthDays;
    // Solve floor + (peak−floor)e^(−t/S) = target  →  t = −S·ln((target−floor)/(peak−floor))
    final t = -s * math.log((target - floor) / (r.peak - floor));
    return (t - r.daysSinceStudy).round();
  }
}
