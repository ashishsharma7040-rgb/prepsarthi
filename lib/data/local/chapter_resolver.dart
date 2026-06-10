// lib/data/local/chapter_resolver.dart
//
// DATA-1 (Master Spec): stream-aware chapter resolution.
//
// Replaces every raw `chapterSchemas.filter().nameEqualTo(x).findFirst()` —
// the lookup pattern that hit a RANDOM copy when a chapter name exists in
// multiple syllabi (37 such collisions across the 5 syllabus JSONs).
//
// Resolution order:
//   1. chapterKey (exact identity) — preferred, always correct
//   2. name WITHIN the user's current exam sources — correct for all
//      single-stream users and deterministic for 'both'
//   3. plain name — last-resort legacy fallback (same as old behaviour,
//      only reachable for pre-migration data referencing removed chapters)
//
// NOTE: interim location. Stage 2 of the Master Spec moves this into
// lib/data/repositories/chapter_repository.dart — keep the logic identical.

import 'package:isar/isar.dart';

import '../../core/utils/chapter_key.dart';
import '../content/exam_registry.dart';
import 'isar/schemas/chapter_schema.dart';
import 'isar/schemas/user_schema.dart';

class ChapterResolver {
  ChapterResolver._();

  /// PART 2A: delegates to ExamRegistry — the single source of truth.
  static List<String> sourcesForExam(String? targetExam) =>
      ExamRegistry.sourcesOf(targetExam);

  /// Stream-aware chapter lookup. Pass [chapterKey] whenever the caller has
  /// it (plan entries, logs post-migration); [targetExam] disambiguates
  /// name-only lookups from legacy data and name-driven UI selectors.
  static Future<ChapterSchema?> find(
    Isar db, {
    String? chapterKey,
    required String chapterName,
    String? targetExam,
  }) async {
    // 1. Identity match
    if (chapterKey != null && ChapterKey.isValid(chapterKey)) {
      final byKey = await db.chapterSchemas
          .filter()
          .chapterKeyEqualTo(chapterKey)
          .findFirst();
      if (byKey != null) return byKey;
    }

    // 2. Name within the user's stream(s)
    final exam = targetExam ??
        (await db.userSchemas.where().findFirst())?.targetExam;
    for (final src in sourcesForExam(exam)) {
      final inStream = await db.chapterSchemas
          .filter()
          .nameEqualTo(chapterName)
          .and()
          .syllabusSourceEqualTo(src)
          .findFirst();
      if (inStream != null) return inStream;
    }

    // 3. Legacy fallback — old behaviour, now last resort only
    return db.chapterSchemas.filter().nameEqualTo(chapterName).findFirst();
  }
}
