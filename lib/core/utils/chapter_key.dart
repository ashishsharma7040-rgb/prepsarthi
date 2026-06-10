// lib/core/utils/chapter_key.dart
//
// DATA-1 (Master Spec): stable chapter identity.
//
// chapterKey = '<syllabusSource>|<slug(chapterName)>'
//   e.g.  'neet_ug|kinematics'
//         'ca_final|ind-as-116-leases'
//
// WHY: 37 chapter names exist in 2–4 syllabi simultaneously ("Kinematics",
// "Current Electricity", ...). Every name-string lookup was a coin flip for
// 'both'-stream students and exam-switchers. chapterKey is the ONE identity
// used by PlanEntry, StudyLog, RevisionSchedule, MistakeEntry (and future
// ReviewCard). chapterName remains a display field only.
//
// RULES:
//  • The slug is deterministic and stable across app versions — never change
//    this algorithm without writing a re-keying migration.
//  • Uniqueness is enforced in application logic (upserts), NOT by an Isar
//    unique index: adding a unique index to existing rows that all default to
//    '' would collapse/replace rows on first open after upgrade. (See
//    ChapterKeyMigration for the safe backfill.)

class ChapterKey {
  ChapterKey._();

  static const String separator = '|';

  /// Deterministic slug: lowercase, alphanumerics kept, runs of anything
  /// else collapse to single '-', trimmed. 'Ind AS 116 (Leases)' →
  /// 'ind-as-116-leases'.
  static String slug(String name) {
    final lower = name.toLowerCase().trim();
    final cleaned = lower
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return cleaned.isEmpty ? 'untitled' : cleaned;
  }

  /// Build the canonical key for a chapter.
  static String build(String syllabusSource, String chapterName) =>
      '$syllabusSource$separator${slug(chapterName)}';

  /// Extract the syllabusSource from a key ('' if malformed/legacy-empty).
  static String sourceOf(String chapterKey) {
    final i = chapterKey.indexOf(separator);
    return i <= 0 ? '' : chapterKey.substring(0, i);
  }

  static bool isValid(String chapterKey) =>
      chapterKey.contains(separator) && sourceOf(chapterKey).isNotEmpty;
}
