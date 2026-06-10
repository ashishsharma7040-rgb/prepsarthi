// lib/core/constants/exam_dates.dart
//
// PART 2A: now a thin delegate to ExamRegistry (the single source of truth).
// Kept so existing call sites need no changes. New code should call
// ExamRegistry.examDate(...) directly.

import '../../data/content/exam_registry.dart';

class ExamDates {
  ExamDates._();

  /// Canonical exam date for [targetExam] in year [y].
  /// [caAttempt] selects the CA Final sitting ('january'|'may'|'september';
  /// legacy 'november' maps to next January inside the registry).
  static DateTime examDate(String? targetExam, int y, {String? caAttempt}) =>
      ExamRegistry.examDate(targetExam, y, sessionId: caAttempt);
}
