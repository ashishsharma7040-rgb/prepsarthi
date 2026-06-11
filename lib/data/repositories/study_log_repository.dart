// lib/data/repositories/study_log_repository.dart
//
// PART 2B (STRUCT-2 / C-3): the access point for study-log queries.

import 'package:isar/isar.dart';

import '../local/isar/isar_service.dart'; // re-exports schemas/schemas.dart

class StudyLogRepository {
  StudyLogRepository._();

  // ── Reads ─────────────────────────────────────────────────────────────────

  /// Logs from the last [days], newest-first (dashboard recent window).
  static Future<List<StudyLogSchema>> recent({int days = 30}) async {
    final db = IsarService.db;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return db.studyLogSchemas
        .filter()
        .timestampGreaterThan(cutoff)
        .sortByTimestampDesc()
        .findAll();
  }

  /// Logs since [from] (no upper bound).
  static Future<List<StudyLogSchema>> since(DateTime from) async {
    final db = IsarService.db;
    return db.studyLogSchemas
        .filter()
        .timestampGreaterThan(from)
        .findAll();
  }

  /// Logs whose timestamp falls within [start]..[end].
  static Future<List<StudyLogSchema>> inRange(
      DateTime start, DateTime end) async {
    final db = IsarService.db;
    return db.studyLogSchemas
        .filter()
        .timestampGreaterThan(start)
        .and()
        .timestampLessThan(end)
        .findAll();
  }

  /// Logs for a single calendar day.
  static Future<List<StudyLogSchema>> forDay(DateTime date) async {
    final db = IsarService.db;
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return db.studyLogSchemas
        .filter()
        .timestampGreaterThan(start.subtract(const Duration(seconds: 1)))
        .and()
        .timestampLessThan(end)
        .findAll();
  }

  static Future<int> totalCount() async {
    final db = IsarService.db;
    return db.studyLogSchemas.count();
  }

  /// Count of logs with a given activity tag (e.g. 'pyq').
  static Future<int> countByTag(String tag) async {
    final db = IsarService.db;
    return db.studyLogSchemas.filter().activityTagEqualTo(tag).count();
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  static Future<void> put(StudyLogSchema log) async {
    final db = IsarService.db;
    await db.writeTxn(() async => db.studyLogSchemas.put(log));
  }
}
