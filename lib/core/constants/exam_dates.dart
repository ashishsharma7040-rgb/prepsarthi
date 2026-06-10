// lib/core/constants/exam_dates.dart
//
// SINGLE SOURCE OF TRUTH for exam session dates (Master Spec EXAM-2 + EXAM-5).
// Interim solution until the Stage-2 ExamRegistry replaces this with
// assets/exams/<id>.json → ExamSpec.sessions.
//
// ⚠️ Dates are typical session anchors. NTA/ICAI/CBSE shift exact dates by a
//    few days each cycle — re-verify against official notifications before
//    each release. The student can also fine-tune the date later in Settings.

class ExamDates {
  ExamDates._();

  /// Canonical exam date for [targetExam] in year [y].
  /// [caAttempt] applies only to 'ca_final': 'january' | 'may' | 'september'.
  /// ICAI holds CA Final THRICE yearly since 2025 (Jan/May/Sep) — the legacy
  /// 'november' value is mapped to January of the following year as the
  /// nearest valid session, so old saved users never get a phantom date.
  static DateTime examDate(String? targetExam, int y, {String? caAttempt}) {
    switch (targetExam) {
      case 'ca_final':
        switch (caAttempt) {
          case 'january':
            return DateTime(y, 1, 10);
          case 'september':
            return DateTime(y, 9, 10);
          case 'november': // legacy value from pre-fix installs
            return DateTime(y + 1, 1, 10);
          case 'may':
          default:
            return DateTime(y, 5, 6);
        }
      case 'neet':
        return DateTime(y, 5, 4);
      case 'jee_advanced':
        return DateTime(y, 5, 25);
      case 'class12_boards':
        // EXAM-5 FIX: CBSE practical/theory mains begin early March,
        // not Feb 28. One constant — previously two files disagreed.
        return DateTime(y, 3, 5);
      case 'both':
      case 'jee_main':
      default:
        return DateTime(y, 4, 13);
    }
  }
}
