// lib/data/repositories/mistake_repository.dart
//
// PART 2B (STRUCT-2 / DATA-4): the single access point for mistake records.
//
// The stream filter (only count THIS exam's mistakes, with legacy '' rows
// still counted) lived inside ReadinessCalculator. It is centralised here so
// the Mistake Notebook UI and readiness share one definition.

import 'package:isar/isar.dart';

import '../local/isar/isar_service.dart'; // re-exports schemas/schemas.dart

class MistakeRepository {
  MistakeRepository._();

  /// All mistakes, newest-first.
  static Future<List<MistakeEntrySchema>> all() async {
    final db = IsarService.db;
    final list = await db.mistakeEntrySchemas.where().findAll();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Mistakes for the given [sources] (legacy rows with empty source are kept
  /// — they predate the source field). DATA-4: keeps weakness analysis from
  /// mixing exams.
  static Future<List<MistakeEntrySchema>> forSources(
      List<String> sources) async {
    final db = IsarService.db;
    final all = await db.mistakeEntrySchemas.where().findAll();
    return all
        .where((m) =>
            m.syllabusSource.isEmpty || sources.contains(m.syllabusSource))
        .toList();
  }

  static Future<MistakeEntrySchema?> byId(int id) async {
    final db = IsarService.db;
    return db.mistakeEntrySchemas.get(id);
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  static Future<void> put(MistakeEntrySchema schema) async {
    final db = IsarService.db;
    await db.writeTxn(() => db.mistakeEntrySchemas.put(schema));
  }

  static Future<void> putAll(List<MistakeEntrySchema> schemas) async {
    final db = IsarService.db;
    await db.writeTxn(() => db.mistakeEntrySchemas.putAll(schemas));
  }

  static Future<void> delete(int id) async {
    final db = IsarService.db;
    await db.writeTxn(() => db.mistakeEntrySchemas.delete(id));
  }
}
