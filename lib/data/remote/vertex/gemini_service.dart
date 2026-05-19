// lib/data/remote/vertex/gemini_service.dart
//
// All Gemini 2.5 Flash AI features via Firebase Vertex AI.
// FIXED: Added retry logic, JSON validation, timeout, safe fallback,
//        and proper error messages for commercial release.

import 'dart:async';
import 'dart:convert';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/foundation.dart';
import '../../local/isar/schemas/schemas.dart';

class GeminiService {
  static late GenerativeModel _model;
  static const _modelName = 'gemini-2.5-flash';
  static const _timeout = Duration(seconds: 45);
  static const _maxRetries = 2;

  static void initialize() {
    _model = FirebaseVertexAI.instance.generativeModel(
      model: _modelName,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.4,
        maxOutputTokens: 2048,
      ),
      systemInstruction: Content.system(
        'You are PrepSarthi AI, an expert academic coach specialising in JEE and NEET exam preparation. '
        'You understand Indian competitive exam patterns, NCERT syllabus, NTA weightage, and student psychology. '
        'Always be encouraging yet honest. All responses must be valid JSON only — no preamble, no markdown fences.',
      ),
    );
  }

  // ── Core: safe API call with retry + timeout ──────────────────────────────
  static Future<Map<String, dynamic>> _callWithRetry(
    String prompt, {
    Map<String, dynamic> fallback = const {},
  }) async {
    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final response = await _model
            .generateContent([Content.text(prompt)])
            .timeout(_timeout);

        final rawText = response.text ?? '';
        if (rawText.isEmpty) throw const FormatException('Empty AI response');

        // Strip any accidental markdown fences
        final clean = rawText
            .replaceAll(RegExp(r'```json\s*'), '')
            .replaceAll(RegExp(r'```\s*'), '')
            .trim();

        final parsed = jsonDecode(clean);
        if (parsed is Map<String, dynamic>) return parsed;
        if (parsed is List) return {'_list': parsed};
        throw const FormatException('Unexpected JSON root type');
      } on TimeoutException {
        debugPrint('[GeminiService] Attempt $attempt timed out');
        if (attempt == _maxRetries) {
          return Map<String, dynamic>.from(fallback)..['_error'] = 'timeout';
        }
        await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
      } on FormatException catch (e) {
        debugPrint('[GeminiService] JSON parse error: $e');
        if (attempt == _maxRetries) {
          return Map<String, dynamic>.from(fallback)..['_error'] = 'parse_error';
        }
      } catch (e) {
        debugPrint('[GeminiService] Error on attempt $attempt: $e');
        if (attempt == _maxRetries) {
          return Map<String, dynamic>.from(fallback)..['_error'] = e.toString();
        }
        await Future.delayed(Duration(seconds: attempt + 1));
      }
    }
    return Map<String, dynamic>.from(fallback)..['_error'] = 'unknown';
  }

  // ── 1. SWOT Analysis ──────────────────────────────────────────────────────
  static Future<SWOTReport> generateSWOT({
    required List<ChapterSchema> allChapters,
    required List<StudyLogSchema> last30DaysLogs,
    required int streakDays,
    required double avgDailyHours,
    required double overallProgress,
    required Map<String, double> subjectProgress,
  }) async {
    final strongChapters = allChapters
        .where((c) => c.weightage > 50 &&
            c.estimatedHours > 0 &&
            c.hoursSpent / c.estimatedHours > 0.8)
        .map((c) => '${c.name} (${c.subjectName}, ${c.weightage}% weightage)')
        .take(8)
        .toList();

    final weakChapters = allChapters
        .where((c) => c.weightage > 40 &&
            c.estimatedHours > 0 &&
            c.hoursSpent / c.estimatedHours < 0.4)
        .map((c) => '${c.name} (${c.subjectName}, ${c.weightage}% weightage)')
        .take(8)
        .toList();

    final revisionRate = last30DaysLogs.isEmpty
        ? 0
        : (last30DaysLogs.where((l) => l.activityTag == 'revised').length /
                last30DaysLogs.length *
                100)
            .round();

    final subjectHours = <String, double>{};
    for (final log in last30DaysLogs) {
      subjectHours[log.subjectName] =
          (subjectHours[log.subjectName] ?? 0) + log.hoursStudied;
    }

    final prompt = '''
Perform a detailed SWOT analysis for this JEE/NEET student. Return ONLY valid JSON.

STUDENT DATA (last 30 days):
- Overall syllabus completion: ${overallProgress.toStringAsFixed(1)}%
- Current streak: $streakDays days
- Average daily study hours: ${avgDailyHours.toStringAsFixed(1)}h
- Revision rate: $revisionRate%
- Subject progress: ${jsonEncode(subjectProgress.map((k, v) => MapEntry(k, '${v.toStringAsFixed(1)}%')))}
- Subject hours this month: ${jsonEncode(subjectHours)}
- Strong chapters (high weightage, good progress): ${jsonEncode(strongChapters)}
- Weak chapters (high weightage, low progress): ${jsonEncode(weakChapters)}
- Total study logs this month: ${last30DaysLogs.length}

Return this EXACT JSON structure (no other text):
{
  "strengths": [{"title": "string", "detail": "string (2 sentences, specific)"}],
  "weaknesses": [{"title": "string", "detail": "string (2 sentences, specific)"}],
  "opportunities": [{"title": "string", "detail": "string (2 sentences, actionable)"}],
  "threats": [{"title": "string", "detail": "string (2 sentences, honest)"}],
  "recommendations": [
    {"day_range": "Next 7 days", "action": "string (specific, numbered steps)"},
    {"day_range": "Next 14 days", "action": "string"},
    {"day_range": "Next 30 days", "action": "string"}
  ],
  "overall_assessment": "string (3-4 sentences, encouraging but honest)",
  "predicted_score_range": "string (e.g., '140-160 out of 300 if current pace maintained')",
  "key_message": "string (1 powerful motivational sentence)"
}

Provide 3 items per SWOT category, all specific to this student's data.
''';

    final json = await _callWithRetry(prompt, fallback: _swotFallback);
    return SWOTReport.fromJson(json);
  }

  // ── 2. Pattern Analysis ───────────────────────────────────────────────────
  static Future<PatternReport> generatePatternAnalysis({
    required List<StudyLogSchema> logs,
    required List<ChapterSchema> chapters,
    required int streakDays,
  }) async {
    final hoursByHour = <int, double>{};
    final hoursByDay = <int, double>{};
    double totalHours = 0;

    for (final log in logs) {
      final h = log.timestamp.hour;
      final d = log.timestamp.weekday;
      hoursByHour[h] = (hoursByHour[h] ?? 0) + log.hoursStudied;
      hoursByDay[d] = (hoursByDay[d] ?? 0) + log.hoursStudied;
      totalHours += log.hoursStudied;
    }

    final mostProductiveHour = hoursByHour.isEmpty
        ? 'Unknown'
        : '${hoursByHour.entries.reduce((a, b) => a.value > b.value ? a : b).key}:00';

    final mostProductiveDay = hoursByDay.isEmpty
        ? 'Unknown'
        : _dayName(
            hoursByDay.entries.reduce((a, b) => a.value > b.value ? a : b).key);

    final avgDailyHours = logs.isEmpty ? 0.0 : totalHours / 30;

    final prompt = '''
Analyse this JEE/NEET student's study patterns. Return ONLY valid JSON.

PATTERN DATA:
- Total logs analysed: ${logs.length}
- Total hours studied (period): ${totalHours.toStringAsFixed(1)}h
- Average daily hours: ${avgDailyHours.toStringAsFixed(1)}h
- Current streak: $streakDays days
- Most productive hour of day: $mostProductiveHour
- Most productive day of week: $mostProductiveDay
- Activity breakdown: ${jsonEncode(_activityBreakdown(logs))}
- Consistency (days studied / 30): ${logs.isEmpty ? 0 : (logs.map((l) => '${l.timestamp.day}-${l.timestamp.month}').toSet().length / 30 * 100).round()}%

Return this EXACT JSON (no other text):
{
  "most_productive_time": "string (e.g., '9-11 AM')",
  "study_rhythm": "string (2 sentences about their consistency pattern)",
  "burnout_risk": "low|medium|high",
  "burnout_risk_reason": "string",
  "strengths_pattern": ["string", "string", "string"],
  "watch_out": ["string", "string"],
  "this_week_focus": ["string", "string", "string"],
  "pace_assessment": "string (are they on track to finish syllabus? Be specific)",
  "best_session_length": "string (e.g., '45 minutes with 10-minute break')",
  "motivational_insight": "string (1 powerful observation about their data)"
}
''';

    final json = await _callWithRetry(prompt, fallback: _patternFallback);
    return PatternReport.fromJson(json);
  }

  // ── 3. Plan Regeneration ──────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> regeneratePlan({
    required DateTime examDate,
    required double dailyHours,
    required List<ChapterSchema> completedChapters,
    required List<ChapterSchema> pendingHighWeightChapters,
    required List<double> recentDailyHours,
    required List<ChapterSchema> weakChapters,
  }) async {
    final daysLeft = examDate.difference(DateTime.now()).inDays;
    final avgRecentHours = recentDailyHours.isEmpty
        ? dailyHours
        : recentDailyHours.reduce((a, b) => a + b) / recentDailyHours.length;

    final prompt = '''
You are a JEE/NEET academic planner. Create an optimised 7-day study plan. Return ONLY valid JSON array.

CONTEXT:
- Days until exam: $daysLeft
- Declared daily study hours: ${dailyHours}h
- Actual average recent hours: ${avgRecentHours.toStringAsFixed(1)}h (use this for realistic planning)
- Completed chapters: ${completedChapters.map((c) => c.name).take(20).join(', ')}
- Pending HIGH-WEIGHTAGE chapters: ${pendingHighWeightChapters.map((c) => '${c.name} (${c.weightage}%, ${c.estimatedHours}h est.)').take(15).join('; ')}
- Weak areas (needs extra attention): ${weakChapters.map((c) => c.name).take(10).join(', ')}

RULES:
1. Daily total ≤ ${avgRecentHours.toStringAsFixed(1)}h (use actual pace, not declared)
2. Prioritise pending high-weightage chapters
3. Include 1 revision session per day from completed chapters
4. Day 7 (Sunday) = mock test day (3h block)
5. Balance subjects — no two consecutive days of same subject

Return EXACTLY this JSON array (7 elements):
[
  {
    "day": 1,
    "date_offset": 0,
    "entries": [
      {
        "chapter": "string",
        "subject": "string",
        "hours": 1.5,
        "is_revision": false,
        "priority": "high|medium|low",
        "note": "string (brief tip)"
      }
    ],
    "total_hours": 4.5,
    "day_theme": "string (e.g., 'Electrostatics Deep Dive')"
  }
]
''';

    final json = await _callWithRetry(prompt, fallback: {'_list': []});
    final list = json['_list'] as List? ?? (json.isEmpty ? [] : [json]);
    return list.cast<Map<String, dynamic>>();
  }

  // ── 4. Concept Connector ──────────────────────────────────────────────────
  static Future<ConceptConnectorResult> getConceptConnections({
    required ChapterSchema chapter,
    required List<ChapterSchema> allChapters,
  }) async {
    final relatedNames = allChapters
        .where((c) => c.subjectName == chapter.subjectName && c.name != chapter.name)
        .map((c) => c.name)
        .take(15)
        .toList();

    final prompt = '''
For a JEE/NEET student starting "${chapter.name}" (${chapter.subjectName}, Class ${chapter.classLevel}),
identify prerequisites and related chapters.

Available chapters in ${chapter.subjectName}: ${relatedNames.join(', ')}

Return ONLY valid JSON:
{
  "prerequisites": ["chapter name 1", "chapter name 2"],
  "builds_into": ["chapter name 1"],
  "key_concepts_to_recall": ["concept 1", "concept 2", "concept 3"],
  "common_mistakes": ["mistake 1", "mistake 2"],
  "pro_tip": "string (1 expert study tip specific to this chapter)"
}
''';

    final json = await _callWithRetry(prompt, fallback: {
      'prerequisites': [],
      'builds_into': [],
      'key_concepts_to_recall': [],
      'common_mistakes': [],
      'pro_tip': 'Focus on understanding concepts before solving problems.',
    });
    return ConceptConnectorResult.fromJson(json);
  }

  // ── 5. Backlog Auto-Adjustment ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> generateBacklogPlan({
    required int missedDays,
    required double dailyHours,
    required List<ChapterSchema> pendingChapters,
    required DateTime examDate,
  }) async {
    final daysLeft = examDate.difference(DateTime.now()).inDays;

    final prompt = '''
A JEE/NEET student missed $missedDays consecutive study days and has a backlog.
Help them recover. Return ONLY valid JSON.

CONTEXT:
- Days left until exam: $daysLeft
- Daily study capacity: ${dailyHours}h
- Pending chapters (by priority): ${pendingChapters.map((c) => '${c.name} (${c.weightage}% wt, ${c.estimatedHours}h est)').take(20).join('; ')}

Return:
{
  "recovery_message": "string (empathetic, 2 sentences)",
  "missed_hours": ${missedDays * dailyHours},
  "recovery_plan_days": 3,
  "daily_extra_hours": 1.0,
  "chapters_to_drop_temporarily": ["string"],
  "chapters_to_prioritise": ["string"],
  "motivational_tip": "string"
}
''';

    return _callWithRetry(prompt, fallback: {
      'recovery_message': 'Missing a few days is normal. Let\'s get back on track systematically.',
      'missed_hours': missedDays * dailyHours,
      'recovery_plan_days': missedDays,
      'daily_extra_hours': 0.5,
      'chapters_to_drop_temporarily': [],
      'chapters_to_prioritise': pendingChapters.take(3).map((c) => c.name).toList(),
      'motivational_tip': 'Consistency beats intensity. Start with one focused session today.',
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  static String _dayName(dynamic day) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final d = day is int ? day : 1;
    return d >= 1 && d <= 7 ? days[d] : 'Unknown';
  }

  static Map<String, int> _activityBreakdown(List<StudyLogSchema> logs) {
    final breakdown = <String, int>{};
    for (final log in logs) {
      breakdown[log.activityTag] = (breakdown[log.activityTag] ?? 0) + 1;
    }
    return breakdown;
  }

  // ── Safe fallbacks for offline / API failure ───────────────────────────────
  static const _swotFallback = {
    'strengths': [
      {'title': 'Consistent Effort', 'detail': 'You are building a solid study habit. Keep going.'}
    ],
    'weaknesses': [
      {'title': 'Data Unavailable', 'detail': 'AI analysis could not be generated. Please try again.'}
    ],
    'opportunities': [
      {'title': 'Retry Analysis', 'detail': 'Check your internet connection and try regenerating.'}
    ],
    'threats': [],
    'recommendations': [
      {'day_range': 'Next 7 days', 'action': 'Continue your current study plan.'}
    ],
    'overall_assessment': 'AI analysis is temporarily unavailable. Your study data is being tracked locally.',
    'predicted_score_range': 'Please retry for score prediction.',
    'key_message': 'Every session counts. Keep studying!',
  };

  static const _patternFallback = {
    'most_productive_time': 'Morning (9-11 AM)',
    'study_rhythm': 'Keep your study logs updated for a detailed pattern analysis.',
    'burnout_risk': 'low',
    'burnout_risk_reason': 'Insufficient data. Log more sessions.',
    'strengths_pattern': ['Regular logging habit', 'Consistent effort', 'Good subject variety'],
    'watch_out': ['Log sessions daily for better analysis', 'Retry when connected'],
    'this_week_focus': ['Complete pending chapters', 'Review revision schedule', 'Log all sessions'],
    'pace_assessment': 'Log more sessions to get pace assessment.',
    'best_session_length': '45 minutes with 10-minute break',
    'motivational_insight': 'Students who log consistently outperform those who don\'t.',
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Response Data Models
// ─────────────────────────────────────────────────────────────────────────────

class SWOTItem {
  final String title;
  final String detail;
  SWOTItem({required this.title, required this.detail});
  factory SWOTItem.fromJson(Map<String, dynamic> j) =>
      SWOTItem(title: j['title'] as String? ?? '', detail: j['detail'] as String? ?? '');
}

class SWOTRecommendation {
  final String dayRange;
  final String action;
  SWOTRecommendation({required this.dayRange, required this.action});
  factory SWOTRecommendation.fromJson(Map<String, dynamic> j) =>
      SWOTRecommendation(dayRange: j['day_range'] as String? ?? '', action: j['action'] as String? ?? '');
}

class SWOTReport {
  final List<SWOTItem> strengths;
  final List<SWOTItem> weaknesses;
  final List<SWOTItem> opportunities;
  final List<SWOTItem> threats;
  final List<SWOTRecommendation> recommendations;
  final String overallAssessment;
  final String predictedScoreRange;
  final String keyMessage;
  final bool hasError;

  SWOTReport({
    required this.strengths,
    required this.weaknesses,
    required this.opportunities,
    required this.threats,
    required this.recommendations,
    required this.overallAssessment,
    required this.predictedScoreRange,
    required this.keyMessage,
    this.hasError = false,
  });

  factory SWOTReport.fromJson(Map<String, dynamic> j) => SWOTReport(
    strengths: (j['strengths'] as List? ?? [])
        .map((e) => SWOTItem.fromJson(e as Map<String, dynamic>)).toList(),
    weaknesses: (j['weaknesses'] as List? ?? [])
        .map((e) => SWOTItem.fromJson(e as Map<String, dynamic>)).toList(),
    opportunities: (j['opportunities'] as List? ?? [])
        .map((e) => SWOTItem.fromJson(e as Map<String, dynamic>)).toList(),
    threats: (j['threats'] as List? ?? [])
        .map((e) => SWOTItem.fromJson(e as Map<String, dynamic>)).toList(),
    recommendations: (j['recommendations'] as List? ?? [])
        .map((e) => SWOTRecommendation.fromJson(e as Map<String, dynamic>)).toList(),
    overallAssessment: j['overall_assessment'] as String? ?? '',
    predictedScoreRange: j['predicted_score_range'] as String? ?? '',
    keyMessage: j['key_message'] as String? ?? '',
    hasError: j.containsKey('_error'),
  );
}

class PatternReport {
  final String mostProductiveTime;
  final String studyRhythm;
  final String burnoutRisk;
  final String burnoutRiskReason;
  final List<String> strengthsPattern;
  final List<String> watchOut;
  final List<String> thisWeekFocus;
  final String paceAssessment;
  final String bestSessionLength;
  final String motivationalInsight;
  final bool hasError;

  PatternReport({
    required this.mostProductiveTime,
    required this.studyRhythm,
    required this.burnoutRisk,
    required this.burnoutRiskReason,
    required this.strengthsPattern,
    required this.watchOut,
    required this.thisWeekFocus,
    required this.paceAssessment,
    required this.bestSessionLength,
    required this.motivationalInsight,
    this.hasError = false,
  });

  factory PatternReport.fromJson(Map<String, dynamic> j) => PatternReport(
    mostProductiveTime: j['most_productive_time'] as String? ?? '',
    studyRhythm: j['study_rhythm'] as String? ?? '',
    burnoutRisk: j['burnout_risk'] as String? ?? 'low',
    burnoutRiskReason: j['burnout_risk_reason'] as String? ?? '',
    strengthsPattern: List<String>.from(j['strengths_pattern'] as List? ?? []),
    watchOut: List<String>.from(j['watch_out'] as List? ?? []),
    thisWeekFocus: List<String>.from(j['this_week_focus'] as List? ?? []),
    paceAssessment: j['pace_assessment'] as String? ?? '',
    bestSessionLength: j['best_session_length'] as String? ?? '',
    motivationalInsight: j['motivational_insight'] as String? ?? '',
    hasError: j.containsKey('_error'),
  );
}

class ConceptConnectorResult {
  final List<String> prerequisites;
  final List<String> buildsInto;
  final List<String> keyConceptsToRecall;
  final List<String> commonMistakes;
  final String proTip;

  ConceptConnectorResult({
    required this.prerequisites,
    required this.buildsInto,
    required this.keyConceptsToRecall,
    required this.commonMistakes,
    required this.proTip,
  });

  factory ConceptConnectorResult.fromJson(Map<String, dynamic> j) =>
      ConceptConnectorResult(
        prerequisites: List<String>.from(j['prerequisites'] as List? ?? []),
        buildsInto: List<String>.from(j['builds_into'] as List? ?? []),
        keyConceptsToRecall: List<String>.from(j['key_concepts_to_recall'] as List? ?? []),
        commonMistakes: List<String>.from(j['common_mistakes'] as List? ?? []),
        proTip: j['pro_tip'] as String? ?? '',
      );
}
