// lib/domain/planner/decision_impact_engine.dart
//
// FOUNDATION 3 / FLAGSHIP 2 — Decision Impact Ranking.
//
// Turns the planner from a to-do list into an advisor. Instead of
//     "Today: DT, Audit, AFM"
// it answers the question the whole system exists for:
//     "What is the highest-impact thing to do next, and why?"
//
//     1. DT Revision        +4.8% pass   (2h)   2.4%/h
//     2. AFM Mock           +3.1% pass   (3h)   1.0%/h
//     3. Audit PYQ          +2.4% pass   (2h)   1.2%/h
//
// METHOD — true counterfactual, not a heuristic score:
//   • Take the live pass-probability baseline (both-groups).
//   • For each candidate action, CLONE the affected chapter, apply the action's
//     realistic effect (a revision lifts retention by resetting its clock and
//     adding strength; a mock/PYQ raises test reliability + mastery a notch),
//     recompute pass probability, and measure the actual Δ.
//   • Rank by Δ per hour (impact density) so a 2h action that moves the needle
//     more than a 3h action wins — finite study time is the real constraint.
//
// Because it calls the SAME PassProbabilityEngine the dashboard shows, the
// numbers are consistent end to end: the gain it promises is exactly the gain
// the student will see on the dial after doing it. That is the trust property.
//
// This engine also powers Counterfactual ("+1h/day", "skip Group II") and
// Smart-Trim v2 (target pass-level mastery instead of dropping) — same clone-
// and-recompute machinery, different perturbation.
//
// Pure. Deterministic (engine uses a fixed MC seed). No I/O.

import 'dart:math' as math;

import '../../data/local/isar/isar_service.dart'; // ChapterSchema
import 'feasibility_engine.dart';
import 'retention_engine.dart';
import 'pass_probability_engine.dart';

enum ActionType { revise, practice, mock, learn }

class ImpactAction {
  final ActionType type;
  final String chapterKey;
  final String chapterName;
  final String subjectName;
  final int paper; // classLevel
  final double hours; // estimated cost
  final double deltaPassPercent; // Δ both-groups pass prob, in PERCENT points
  final String reason; // explainability
  const ImpactAction({
    required this.type,
    required this.chapterKey,
    required this.chapterName,
    required this.subjectName,
    required this.paper,
    required this.hours,
    required this.deltaPassPercent,
    required this.reason,
  });

  double get impactPerHour => hours > 0 ? deltaPassPercent / hours : 0;

  String get verb => switch (type) {
        ActionType.revise => 'Revise',
        ActionType.practice => 'PYQ practice',
        ActionType.mock => 'Mock',
        ActionType.learn => 'Study',
      };
}

class DecisionImpactEngine {
  DecisionImpactEngine._();

  /// Top [limit] highest-impact next actions, ranked by Δpass per hour.
  /// [groupFilter] (1 or 2) restricts to a single group when the student is
  /// attempting only one.
  static List<ImpactAction> rank(
    List<ChapterSchema> chapters, {
    int limit = 6,
    int? groupFilter,
  }) {
    final ca = chapters.where((c) => c.syllabusSource == 'ca_final').toList();
    if (ca.isEmpty) return const [];

    final baseline =
        PassProbabilityEngine.assessCaFinal(ca).bothGroupsProbability;

    final actions = <ImpactAction>[];
    for (final c in ca) {
      if (groupFilter != null) {
        final g = c.classLevel <= 3 ? 1 : 2;
        if (g != groupFilter) continue;
      }
      final candidate = _bestActionFor(c);
      if (candidate == null) continue;

      // Counterfactual: clone the full list, mutate the one chapter, recompute.
      final mutated = _cloneWith(ca, c.chapterKey, candidate.$1);
      final after =
          PassProbabilityEngine.assessCaFinal(mutated).bothGroupsProbability;
      final delta = (after - baseline) * 100.0;
      if (delta <= 0.02) continue; // ignore negligible moves

      actions.add(ImpactAction(
        type: _effectToType(candidate.$1),
        chapterKey: c.chapterKey,
        chapterName: c.name,
        subjectName: c.subjectName,
        paper: c.classLevel,
        hours: candidate.$2,
        deltaPassPercent: delta,
        reason: candidate.$3,
      ));
    }

    // Rank by impact DENSITY (Δpass per hour) — time is the binding constraint.
    actions.sort((a, b) => b.impactPerHour.compareTo(a.impactPerHour));
    return actions.take(limit).toList();
  }

  /// Counterfactual: pass probability if the student adds [extraHoursPerDay] of
  /// effective study, spent greedily on the current highest-impact actions.
  /// Returns (currentProb, projectedProb).
  static (double, double) counterfactualExtraHours(
    List<ChapterSchema> chapters,
    double extraHoursPerDay,
    int daysLeft,
  ) {
    final ca = chapters.where((c) => c.syllabusSource == 'ca_final').toList();
    if (ca.isEmpty) return (0, 0);
    final current =
        PassProbabilityEngine.assessCaFinal(ca).bothGroupsProbability;

    var budget = extraHoursPerDay * daysLeft;
    final working = ca.map(_copy).toList();
    // Greedily apply highest-impact actions until the extra budget is spent.
    for (var iter = 0; iter < 200 && budget > 0.5; iter++) {
      final ranked = rank(working, limit: 1);
      if (ranked.isEmpty) break;
      final a = ranked.first;
      if (a.hours > budget) break;
      _applyInPlace(working, a.chapterKey, a.type);
      budget -= a.hours;
    }
    final projected =
        PassProbabilityEngine.assessCaFinal(working).bothGroupsProbability;
    return (current, projected);
  }

  /// Counterfactual: pass probability for ONE group if the student drops the
  /// other. Returns the focused group's probability.
  static double counterfactualSingleGroup(
      List<ChapterSchema> chapters, int keepGroup) {
    final res = PassProbabilityEngine.assessCaFinal(chapters);
    final g = res.group(keepGroup);
    return g?.passProbability ?? 0;
  }

  // ── Action modelling ──────────────────────────────────────────────────────

  /// Picks the single most sensible next action for a chapter and its realistic
  /// effect + cost + reason. Returns (effect, hours, reason).
  static (_Effect, double, String)? _bestActionFor(ChapterSchema c) {
    final mastery = FeasibilityEngine.effectiveMastery(c);
    final r = RetentionEngine.forChapter(c);

    // Learned but decaying → revision is cheapest, highest-yield.
    if (mastery >= 0.55 && r.retention < 0.7) {
      return (
        _Effect.revise,
        _round(0.5 + c.estimatedHours * 0.12),
        'Retention has slipped to ${(r.retention * 100).round()}% — a short '
            'revision restores it and stops the marks bleed (${(r.decayPerWeek * 100).toStringAsFixed(1)}%/wk).'
      );
    }
    // Solid coverage but never tested → a mock converts knowledge into marks.
    if (mastery >= 0.6 && c.testAttempts < 3) {
      return (
        _Effect.mock,
        _round(1.0 + c.estimatedHours * 0.15),
        'Well-covered but untested — a timed attempt turns recall into exam '
            'marks and de-risks the paper.'
      );
    }
    // Weak/under-covered high-weight chapter → study/PYQ has the most headroom.
    if (mastery < 0.6) {
      final isPyq = c.pyqProgress < 3 && mastery >= 0.35;
      return (
        isPyq ? _Effect.practice : _Effect.learn,
        _round(math.max(1.0, c.estimatedHours * (1 - mastery) * 0.5)),
        isPyq
            ? 'PYQ practice on a half-prepared, ${c.weightage > 0 ? "${c.weightage.round()}-mark" : "high"}-weight chapter lifts it fastest.'
            : 'Low coverage on a scoring chapter — the biggest single source of '
                'missing marks in this paper.'
      );
    }
    return null;
  }

  static List<ChapterSchema> _cloneWith(
      List<ChapterSchema> src, String key, _Effect e) {
    final out = src.map(_copy).toList();
    _applyInPlace(out, key, _effectToType(e));
    return out;
  }

  static void _applyInPlace(
      List<ChapterSchema> list, String key, ActionType type) {
    for (final c in list) {
      if (c.chapterKey != key) continue;
      switch (type) {
        case ActionType.revise:
          c.revisionCount += 1;
          c.lastStudiedDate = DateTime.now(); // reset forgetting clock
          if (c.masteryLevel < 7) c.masteryLevel += 1;
          c.hoursSpent += 1.0;
          break;
        case ActionType.mock:
          c.testAttempts += 3;
          c.testCorrect += 2; // ~67% — models a realistic first timed attempt
          c.lastStudiedDate = DateTime.now();
          if (c.masteryLevel < 7) c.masteryLevel += 1;
          break;
        case ActionType.practice:
          if (c.pyqProgress < 4) c.pyqProgress += 1;
          if (c.masteryLevel < 7) c.masteryLevel += 1;
          c.hoursSpent += c.estimatedHours * 0.25;
          c.lastStudiedDate = DateTime.now();
          break;
        case ActionType.learn:
          if (c.masteryLevel < 5) c.masteryLevel += 2;
          c.hoursSpent += c.estimatedHours * 0.4;
          c.firstLearnedDate ??= DateTime.now();
          c.lastStudiedDate = DateTime.now();
          if (c.status == 'not_started') c.status = 'learned';
          break;
      }
      return;
    }
  }

  static ActionType _effectToType(_Effect e) => switch (e) {
        _Effect.revise => ActionType.revise,
        _Effect.mock => ActionType.mock,
        _Effect.practice => ActionType.practice,
        _Effect.learn => ActionType.learn,
      };

  // Shallow domain copy (only fields the engines read).
  static ChapterSchema _copy(ChapterSchema c) {
    return ChapterSchema()
      ..chapterKey = c.chapterKey
      ..subjectName = c.subjectName
      ..syllabusSource = c.syllabusSource
      ..name = c.name
      ..classLevel = c.classLevel
      ..estimatedHours = c.estimatedHours
      ..weightage = c.weightage
      ..difficulty = c.difficulty
      ..pyqCount = c.pyqCount
      ..status = c.status
      ..masteryLevel = c.masteryLevel
      ..pyqProgress = c.pyqProgress
      ..conceptualMistakes = c.conceptualMistakes
      ..calculationMistakes = c.calculationMistakes
      ..sillyMistakes = c.sillyMistakes
      ..hoursSpent = c.hoursSpent
      ..revisionCount = c.revisionCount
      ..testAttempts = c.testAttempts
      ..testCorrect = c.testCorrect
      ..firstLearnedDate = c.firstLearnedDate
      ..lastStudiedDate = c.lastStudiedDate
      ..tags = c.tags;
  }

  static double _round(double h) => (h * 2).round() / 2.0; // nearest 0.5h
}

enum _Effect { revise, mock, practice, learn }
