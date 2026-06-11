// lib/data/repositories/revision_repository.dart
//
// PART 2B (STRUCT-2 / C-3): the access point for revision-schedule queries.

import 'package:isar/isar.dart';

import '../local/isar/isar_service.dart'; // re-exports schemas/schemas.dart

class RevisionRepository {
  RevisionRepository._();

  // ── Reads ─────────────────────────────────────────────────────────────────

  /// All active revision schedules.
  static Future<List<RevisionScheduleSchema>> active() async {
    final db = IsarService.db;
    return db.revisionScheduleSchemas.filter().activeEqualTo(true).findAll();
  }

  /// Existing schedule for a chapter, preferring the stable chapterKey and
  /// falling back to chapterName for legacy rows (matches the planner's
  /// upsert resolution in scheduleRevisions).
  static Future<RevisionScheduleSchema?> forChapter({
    String chapterKey = '',
    required String chapterName,
  }) async {
    final db = IsarService.db;
    if (chapterKey.isNotEmpty) {
      return db.revisionScheduleSchemas
          .filter()
          .chapterKeyEqualTo(chapterKey)
          .findFirst();
    }
    return db.revisionScheduleSchemas
        .filter()
        .chapterNameEqualTo(chapterName)
        .findFirst();
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  static Future<void> put(RevisionScheduleSchema schedule) async {
    final db = IsarService.db;
    await db.writeTxn(() async => db.revisionScheduleSchemas.put(schedule));
  }
}
