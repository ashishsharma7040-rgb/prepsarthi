// lib/domain/planner/pass_probability_engine.dart
//
// FOUNDATION 2 — Pass Probability (the shared probability primitive).
//
// Replaces the single opaque "Readiness = 76%" with something a CA student
// reads instantly and trusts:
//
//     Group I   = 82%
//     Group II  = 69%
//     Both      = 58%   (single-attempt, both groups together)
//
// This is the engine EVERY higher-order surface reads — Decision Impact,
// Counterfactual, Exam Simulation, Regret — so the whole app speaks one
// consistent, explainable probability. Build the views on five private copies
// of this math and they drift; build them on this and they agree by
// construction.
//
// HOW IT WORKS (and why each step is defensible)
//
//  1. Per-chapter expected exam score (0..1):
//        score = retention · (0.55 + 0.45 · testReliability)
//     Retention (forgetting curve) is what they'd actually recall today, not
//     what they once knew. The test term nudges up chapters with proven
//     accuracy and down chapters never tested — exam performance needs recall
//     AND application, and an untested chapter is a known unknown.
//
//  2. Per-paper expected mark % = weightage-weighted mean of chapter scores
//     (falls back to simple mean when weightage data is absent), scaled by an
//     exam-realism factor (knowing the syllabus ≠ scoring it under 3h pressure).
//
//  3. Per-paper PASS probability: real exams are noisy. We model the paper
//     mark as Normal(mean, σ) where σ widens with how little EVIDENCE backs the
//     estimate (few tests, low coverage → more uncertainty → probability is
//     pulled toward 50%, never falsely confident). P(pass) = P(mark ≥ 40).
//
//  4. Group pass = ALL papers ≥ 40 AND group aggregate ≥ 50% (real ICAI rule).
//     Computed by light Monte-Carlo over correlated paper outcomes so the
//     aggregate rule and the per-paper rule interact correctly.
//
//  5. "Both groups, single attempt" = P(GroupI) · P(GroupII) with a mild
//     positive-correlation adjustment (a strong student tends to be strong in
//     both) — not naive independence.
//
// Deterministic given a fixed seed. Pure (reads ChapterSchema only). No I/O.

import 'dart:math' as math;

import '../../data/local/isar/isar_service.dart'; // ChapterSchema
import 'feasibility_engine.dart';
import 'retention_engine.dart';

/// One driver of a probability, for the "why" panel.
class ProbabilityReason {
  final String label;
  final String detail;
  final double impact; // signed contribution hint (−1..1), for sorting/arrows
  const ProbabilityReason(this.label, this.detail, this.impact);
}

class PaperEstimate {
  final int paper; // classLevel 1..6
  final String name; // subject name
  final double expectedPercent; // 0..100 predicted mark
  final double passProbability; // 0..1  P(mark ≥ 40)
  final double sigma; // uncertainty (std-dev, percent points)
  final double weightInGroup;
  const PaperEstimate({
    required this.paper,
    required this.name,
    required this.expectedPercent,
    required this.passProbability,
    required this.sigma,
    required this.weightInGroup,
  });
}

class GroupProbability {
  final int group; // 1 or 2
  final String label; // 'Group I'
  final List<PaperEstimate> papers;
  final double aggregatePercent; // expected aggregate mark %
  final double passProbability; // 0..1, full ICAI rule
  const GroupProbability({
    required this.group,
    required this.label,
    required this.papers,
    required this.aggregatePercent,
    required this.passProbability,
  });
}

class PassProbabilityResult {
  final List<GroupProbability> groups;
  final double bothGroupsProbability; // single attempt, both groups
  final List<ProbabilityReason> reasons; // top explainers, app-wide
  final bool hasData;
  const PassProbabilityResult({
    required this.groups,
    required this.bothGroupsProbability,
    required this.reasons,
    required this.hasData,
  });

  static const empty = PassProbabilityResult(
    groups: [],
    bothGroupsProbability: 0,
    reasons: [],
    hasData: false,
  );

  GroupProbability? group(int g) {
    for (final gp in groups) {
      if (gp.group == g) return gp;
    }
    return null;
  }
}

class PassProbabilityEngine {
  PassProbabilityEngine._();

  static const double _passMarkPaper = 40.0; // % per paper
  static const double _passMarkAggregate = 50.0; // % group aggregate
  static const double _examRealism = 0.92; // syllabus-knowing → exam-scoring
  static const double _untestedPenaltyFloor = 0.55; // recall-only weight
  static const int _mcRuns = 400; // Monte-Carlo iterations (deterministic seed)

  /// Group I = papers 1–3, Group II = papers 4–6.
  static PassProbabilityResult assessCaFinal(List<ChapterSchema> chapters) {
    final ca = chapters.where((c) => c.syllabusSource == 'ca_final').toList();
    if (ca.isEmpty) return PassProbabilityResult.empty;

    final g1 = _group(ca, group: 1, papers: const [1, 2, 3]);
    final g2 = _group(ca, group: 2, papers: const [4, 5, 6]);
    final groups = [g1, g2].whereType<GroupProbability>().toList();
    if (groups.isEmpty) return PassProbabilityResult.empty;

    // Both groups, single attempt. Mild positive correlation (ρ≈0.25): a
    // student strong enough to clear one group is likelier to clear the other,
    // so naive p1·p2 understates. Blend independent product with the min.
    double both;
    if (g1 != null && g2 != null) {
      // Both groups, single attempt. Mild positive correlation: a student
      // strong enough to clear one group is likelier to clear the other, so
      // naive p1·p2 understates. Blend the independent product with the
      // weaker group's probability.
      final indep = g1.passProbability * g2.passProbability;
      final lower = math.min(g1.passProbability, g2.passProbability);
      both = (0.78 * indep + 0.22 * lower).clamp(0.0, 1.0);
    } else {
      both = groups.first.passProbability;
    }

    return PassProbabilityResult(
      groups: groups,
      bothGroupsProbability: both,
      reasons: _explain(groups),
      hasData: true,
    );
  }

  static GroupProbability? _group(List<ChapterSchema> ca,
      {required int group, required List<int> papers}) {
    final inGroup = ca.where((c) => papers.contains(c.classLevel)).toList();
    if (inGroup.isEmpty) return null;

    // Build per-paper estimates.
    final estimates = <PaperEstimate>[];
    final byPaper = <int, List<ChapterSchema>>{};
    for (final c in inGroup) {
      byPaper.putIfAbsent(c.classLevel, () => []).add(c);
    }

    for (final entry in byPaper.entries) {
      final chs = entry.value;
      double wSum = 0, scoreW = 0, evidenceW = 0;
      for (final c in chs) {
        final r = RetentionEngine.forChapter(c);
        final testReliability = c.testAttempts >= 3
            ? (c.testAccuracy / 100.0).clamp(0.0, 1.0)
            : 0.0;
        final chapterScore = (r.retention *
                (_untestedPenaltyFloor +
                    (1 - _untestedPenaltyFloor) * testReliability))
            .clamp(0.0, 1.0);
        final w = c.weightage > 0 ? c.weightage : 1.0;
        wSum += w;
        scoreW += chapterScore * w;
        // Evidence strength per chapter: coverage + whether it's been tested.
        final cov = FeasibilityEngine.effectiveMastery(c);
        final ev = 0.6 * cov + 0.4 * (c.testAttempts >= 3 ? 1.0 : 0.0);
        evidenceW += ev * w;
      }
      final meanScore = wSum > 0 ? scoreW / wSum : 0.0;
      final evidence = wSum > 0 ? (evidenceW / wSum).clamp(0.0, 1.0) : 0.0;
      final expectedPercent = (meanScore * 100 * _examRealism).clamp(0.0, 100.0);

      // Uncertainty: low evidence → wide σ → probability pulled toward 50%.
      final sigma = (7.0 + (1 - evidence) * 17.0); // 7..24 percent points
      final passProb =
          _normalTailGe(expectedPercent, sigma, _passMarkPaper);

      estimates.add(PaperEstimate(
        paper: entry.key,
        name: chs.first.subjectName,
        expectedPercent: expectedPercent,
        passProbability: passProb,
        sigma: sigma,
        weightInGroup: wSum,
      ));
    }

    estimates.sort((a, b) => a.paper.compareTo(b.paper));

    // Expected aggregate = mean of paper expected percents (papers equal-weight
    // in ICAI aggregate; each paper is 100 marks).
    final aggregate = estimates.isEmpty
        ? 0.0
        : estimates.map((e) => e.expectedPercent).reduce((a, b) => a + b) /
            estimates.length;

    final passProb = _groupPassMonteCarlo(estimates);

    return GroupProbability(
      group: group,
      label: group == 1 ? 'Group I' : 'Group II',
      papers: estimates,
      aggregatePercent: aggregate,
      passProbability: passProb,
    );
  }

  /// Full ICAI rule via Monte-Carlo: a group passes iff EVERY paper ≥ 40 AND
  /// the aggregate ≥ 50%. Papers are sampled with a shared "exam-day" factor
  /// (correlation: a good/bad day lifts/sinks all papers together), so the
  /// per-paper and aggregate rules interact realistically.
  static double _groupPassMonteCarlo(List<PaperEstimate> papers) {
    if (papers.isEmpty) return 0;
    final rng = math.Random(20260613); // fixed seed → deterministic UI
    var passes = 0;
    for (var i = 0; i < _mcRuns; i++) {
      final dayFactor = _gauss(rng) * 6.0; // shared ±day effect (pts)
      var allPapersPass = true;
      var sum = 0.0;
      for (final p in papers) {
        final mark =
            (p.expectedPercent + _gauss(rng) * p.sigma + dayFactor)
                .clamp(0.0, 100.0);
        if (mark < _passMarkPaper) allPapersPass = false;
        sum += mark;
      }
      final aggregate = sum / papers.length;
      if (allPapersPass && aggregate >= _passMarkAggregate) passes++;
    }
    return passes / _mcRuns;
  }

  // P(X ≥ k) for X ~ Normal(mean, sigma), via erf-based CDF.
  static double _normalTailGe(double mean, double sigma, double k) {
    if (sigma <= 0.0001) return mean >= k ? 1.0 : 0.0;
    final z = (k - mean) / sigma;
    return (1.0 - _phi(z)).clamp(0.0, 1.0);
  }

  // Standard normal CDF Φ(z) using Abramowitz-Stegun erf approximation.
  static double _phi(double z) {
    final t = 1.0 / (1.0 + 0.2316419 * z.abs());
    final d = 0.3989422804014327 * math.exp(-z * z / 2.0);
    var p = d *
        t *
        (0.319381530 +
            t *
                (-0.356563782 +
                    t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))));
    p = z >= 0 ? 1.0 - p : p;
    return p;
  }

  // Box–Muller standard normal sample.
  static double _gauss(math.Random rng) {
    final u1 = math.max(rng.nextDouble(), 1e-9);
    final u2 = rng.nextDouble();
    return math.sqrt(-2.0 * math.log(u1)) * math.cos(2 * math.pi * u2);
  }

  static List<ProbabilityReason> _explain(List<GroupProbability> groups) {
    final reasons = <ProbabilityReason>[];
    for (final g in groups) {
      // Weakest paper in each group is the headline limiter.
      final weakest = [...g.papers]
        ..sort((a, b) => a.passProbability.compareTo(b.passProbability));
      if (weakest.isNotEmpty) {
        final w = weakest.first;
        reasons.add(ProbabilityReason(
          '${g.label}: ${w.name} is the limiter',
          'Predicted ~${w.expectedPercent.round()}% (pass-line 40%). '
              'It caps ${g.label} because a group needs EVERY paper ≥40.',
          -(1 - w.passProbability),
        ));
      }
    }
    reasons.sort((a, b) => a.impact.compareTo(b.impact));
    return reasons.take(4).toList();
  }
}
