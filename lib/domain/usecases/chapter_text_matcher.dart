// lib/domain/usecases/chapter_text_matcher.dart
//
// PART 3 — WIRE-5 / WIRE-6 support.
//
// AI reports (SWOT recommendations, pattern "This Week's Focus") are free
// text from Gemini. To make them ACTIONABLE ("Add to Plan" in one tap), we
// need to recognise which of the student's own chapters a sentence refers to.
//
// Matching rules (deliberately conservative — a wrong match that schedules
// the wrong chapter is worse than no button):
//   • case-insensitive containment of the FULL chapter name in the text
//   • longest-name-first, so "Vector Algebra" wins over a chapter "Vector"
//     and overlapping names can't shadow each other
//   • chapter names shorter than 4 chars are skipped (too collision-prone)
//
// The caller passes the stream-correct chapter list (planProvider.chapters),
// so matches are automatically stream-safe — a CA Final student can never get
// a JEE chapter suggested (DATA-1 discipline carried into Part 3).

import '../../data/local/isar/isar_service.dart'; // re-exports ChapterSchema

class ChapterTextMatcher {
  ChapterTextMatcher._();

  /// First chapter from [chapters] whose name appears inside [text].
  /// Returns null when nothing matches confidently.
  static ChapterSchema? firstMatch(String text, List<ChapterSchema> chapters) {
    if (text.isEmpty || chapters.isEmpty) return null;
    final haystack = text.toLowerCase();

    // Longest names first → most specific match wins.
    final sorted = List<ChapterSchema>.from(chapters)
      ..sort((a, b) => b.name.length.compareTo(a.name.length));

    for (final c in sorted) {
      final needle = c.name.trim().toLowerCase();
      if (needle.length < 4) continue;
      if (haystack.contains(needle)) return c;
    }
    return null;
  }
}
