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

  // ── WIRE-10: keep the planner's revision PLAN ENTRIES in lock-step with the
  // revision schedule. Previously postpone/complete updated the schedule only,
  // leaving the matching plan entry stranded on its old date ("ghost entries
  // in planner"). Both helpers resolve entries chapterKey-first (stream-safe)
  // with a chapterName fallback for legacy rows.

  /// Shift the pending revision plan entries on each of [oldDates] forward by
  /// [days], so the planner mirrors a postponed revision schedule.
  static Future<void> postponePlanEntries({
    required String chapterKey,
    required String chapterName,
    required List<DateTime> oldDates,
    required int days,
  }) async {
    if (oldDates.isEmpty) return;
    final db = IsarService.db;
    await db.writeTxn(() async {
      for (final raw in oldDates) {
        final day = DateTime(raw.year, raw.month, raw.day);
        final entries = await db.planEntrySchemas
            .filter()
            .isRevisionEqualTo(true)
            .and()
            .plannedDateEqualTo(day)
            .and()
            .statusEqualTo('pending')
            .findAll();
        for (final e in entries) {
          final matches = chapterKey.isNotEmpty
              ? e.chapterKey == chapterKey
              : e.chapterName == chapterName;
          if (!matches) continue;
          e.plannedDate = day.add(Duration(days: days));
          await db.planEntrySchemas.put(e);
        }
      }
    });
  }

  /// Mark the pending revision plan entry on [date] as done, so completing a
  /// revision from the revision screen also clears its planner tile.
  static Future<void> completePlanEntry({
    required String chapterKey,
    required String chapterName,
    required DateTime date,
  }) async {
    final db = IsarService.db;
    final day = DateTime(date.year, date.month, date.day);
    await db.writeTxn(() async {
      final entries = await db.planEntrySchemas
          .filter()
          .isRevisionEqualTo(true)
          .and()
          .plannedDateEqualTo(day)
          .and()
          .statusEqualTo('pending')
          .findAll();
      for (final e in entries) {
        final matches = chapterKey.isNotEmpty
            ? e.chapterKey == chapterKey
            : e.chapterName == chapterName;
        if (!matches) continue;
        e.status = 'done';
        e.actualHours = e.plannedHours;
        await db.planEntrySchemas.put(e);
      }
    });
  }
}
