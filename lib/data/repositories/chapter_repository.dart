// lib/data/repositories/chapter_repository.dart
//
// PART 2B (Master Spec STRUCT-2 / C-3): the ONLY place chapter queries live.
//
// WHY: raw `db.chapterSchemas.filter()...` calls were scattered across
// providers, screens and use cases. Two of them even reimplemented the same
// "load the user's stream(s)" logic differently (one special-cased 'both',
// the other looped registry sources). Scattering this query is exactly how
// the stream-bleed bug class (DATA-1 / EXAM-1) keeps coming back.
//
// THE RULE: every READ that must respect a student's exam takes the
// `sources` (or `targetExam`) as a REQUIRED argument — so "forgot the source
// filter" is structurally impossible. Callers get a stream-correct list and
// nothing else.
//
// Static methods to match the existing repository convention
// (auth_repository, export_repository, purchase_repository).

import 'package:isar/isar.dart';

import '../content/exam_registry.dart';
import '../local/isar/isar_service.dart'; // re-exports schemas/schemas.dart

class ChapterRepository {
  ChapterRepository._();

  // ── Stream-aware reads ────────────────────────────────────────────────────

  /// All chapters for the given syllabus [sources] (e.g. ['jee_main','neet_ug']
  /// for a 'both' student). This is the canonical loader — replaces the two
  /// duplicated implementations in PlanNotifier and ReadinessCalculator.
  static Future<List<ChapterSchema>> forSources(List<String> sources) async {
    final db = IsarService.db;
    final out = <ChapterSchema>[];
    for (final src in sources) {
      out.addAll(await db.chapterSchemas
          .filter()
          .syllabusSourceEqualTo(src)
          .findAll());
    }
    return out;
  }

  /// Convenience: load by exam id, resolving sources via ExamRegistry.
  /// 'both' correctly merges jee_main + neet_ug.
  static Future<List<ChapterSchema>> forExam(String? targetExam) =>
      forSources(ExamRegistry.sourcesOf(targetExam));

  /// Count chapters for an exam within specific class levels (used by the CA
  /// Group I / Group II progress widgets). [completedOnly] counts mastered.
  static Future<int> countByClassLevels(
    String source,
    List<int> classLevels, {
    bool completedOnly = false,
    int masteredAtLevel = 7,
  }) async {
    final db = IsarService.db;
    final all = await db.chapterSchemas
        .filter()
        .syllabusSourceEqualTo(source)
        .findAll();
    return all
        .where((c) => classLevels.contains(c.classLevel))
        .where((c) => !completedOnly || c.masteryLevel >= masteredAtLevel)
        .length;
  }

  /// Group progress by STATUS (CA Final achievement logic): returns
  /// (total, done) where "done" means status is learned/revised/tested.
  /// Preserves the exact semantics of the previous inline queries.
  static Future<(int total, int done)> statusProgressByClassLevels(
    String source,
    List<int> classLevels,
  ) async {
    const doneStatuses = {'learned', 'revised', 'tested'};
    final db = IsarService.db;
    final all = await db.chapterSchemas
        .filter()
        .syllabusSourceEqualTo(source)
        .findAll();
    final inGroup =
        all.where((c) => classLevels.contains(c.classLevel)).toList();
    final done = inGroup.where((c) => doneStatuses.contains(c.status)).length;
    return (inGroup.length, done);
  }

  // ── Identity reads (stream-aware single chapter) ──────────────────────────

  /// Resolve a single chapter by its stable [chapterKey].
  static Future<ChapterSchema?> byKey(String chapterKey) async {
    final db = IsarService.db;
    return db.chapterSchemas
        .filter()
        .chapterKeyEqualTo(chapterKey)
        .findFirst();
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  /// Persist a (mutated) chapter row.
  static Future<void> put(ChapterSchema chapter) async {
    final db = IsarService.db;
    await db.writeTxn(() async => db.chapterSchemas.put(chapter));
  }
}
