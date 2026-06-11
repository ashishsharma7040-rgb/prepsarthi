// lib/data/repositories/plan_repository.dart
//
// PART 2B (STRUCT-2 / C-3): the access point for plan-entry queries.
//
// planEntrySchemas was the most-queried collection (30+ raw sites). This
// repository centralises the READ patterns and simple CRUD that recur across
// the dashboard, calendar and readiness. The planner's bulk-insert internals
// (generate_plan_usecase, backlog_adjuster) keep their own transactions for
// now — Planner v5 (Part 4) rewrites those modules anyway.

import 'package:isar/isar.dart';

import '../local/isar/isar_service.dart'; // re-exports schemas/schemas.dart

class PlanRepository {
  PlanRepository._();

  // ── Reads ─────────────────────────────────────────────────────────────────

  /// Entries planned for a single day, ordered by orderIndex.
  static Future<List<PlanEntrySchema>> forDay(DateTime day) async {
    final db = IsarService.db;
    final d = DateTime(day.year, day.month, day.day);
    return db.planEntrySchemas
        .filter()
        .plannedDateEqualTo(d)
        .sortByOrderIndex()
        .findAll();
  }

  /// Entries in the inclusive date range [start]..[end], ordered by date.
  static Future<List<PlanEntrySchema>> inRange(
      DateTime start, DateTime end) async {
    final db = IsarService.db;
    return db.planEntrySchemas
        .filter()
        .plannedDateGreaterThan(start.subtract(const Duration(days: 1)))
        .and()
        .plannedDateLessThan(end.add(const Duration(days: 1)))
        .sortByPlannedDate()
        .findAll();
  }

  /// Entries grouped by calendar day for [start]..[end] (calendar view).
  static Future<Map<DateTime, List<PlanEntrySchema>>> groupedByDay(
      DateTime start, DateTime end) async {
    final entries = await inRange(start, end);
    final map = <DateTime, List<PlanEntrySchema>>{};
    for (final e in entries) {
      final key =
          DateTime(e.plannedDate.year, e.plannedDate.month, e.plannedDate.day);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  static Future<PlanEntrySchema?> byId(int id) async {
    final db = IsarService.db;
    return db.planEntrySchemas.get(id);
  }

  static Future<int> totalCount() async {
    final db = IsarService.db;
    return db.planEntrySchemas.count();
  }

  /// Count of pending entries, optionally only those overdue before [before].
  static Future<int> pendingCount({DateTime? overdueBefore}) async {
    final db = IsarService.db;
    if (overdueBefore == null) {
      return db.planEntrySchemas.filter().statusEqualTo('pending').count();
    }
    return db.planEntrySchemas
        .filter()
        .statusEqualTo('pending')
        .plannedDateLessThan(overdueBefore)
        .count();
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  static Future<void> put(PlanEntrySchema entry) async {
    final db = IsarService.db;
    await db.writeTxn(() async => db.planEntrySchemas.put(entry));
  }

  static Future<void> putAll(List<PlanEntrySchema> entries) async {
    final db = IsarService.db;
    await db.writeTxn(() async => db.planEntrySchemas.putAll(entries));
  }

  static Future<void> delete(int id) async {
    final db = IsarService.db;
    await db.writeTxn(() async => db.planEntrySchemas.delete(id));
  }
}
