// lib/data/local/migrations/chapter_key_migration.dart
//
// DATA-1 (Master Spec) — ONE-TIME backfill migration.
//
// Runs once per install (flag in SharedPreferences), after Isar opens and
// after SyllabusLoader has stamped chapterKey onto ChapterSchema rows.
// Resolves every legacy chapterName reference in PlanEntry, StudyLog,
// RevisionSchedule and MistakeEntry to a stable chapterKey.
//
// DISAMBIGUATION ORDER for a colliding name (e.g. 'Kinematics' exists in
// jee_main, jee_advanced, neet_ug):
//   1. exactly one chapter with that name → its key
//   2. several → prefer the one whose syllabusSource matches the user's
//      current exam sources (best effort; old data was already ambiguous)
//   3. none → leave '' (record keeps working via the name-fallback path,
//      and a later regeneration replaces it)
//
// SAFETY: read-modify-write in small batches inside writeTxn; any failure
// leaves the flag unset so the migration retries on next launch. The
// migration is idempotent — rows with a non-empty chapterKey are skipped.

import 'package:isar/isar.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/app_logger.dart';
import '../../../core/utils/chapter_key.dart';
import '../isar/isar_service.dart';

class ChapterKeyMigration {
  ChapterKeyMigration._();

  static const _flag = 'migration_chapter_key_v1_done';

  /// Same source mapping as the rest of the app (interim until ExamRegistry).
  static List<String> _sourcesForExam(String? targetExam) {
    switch (targetExam) {
      case 'neet':
        return ['neet_ug'];
      case 'jee_advanced':
        return ['jee_advanced'];
      case 'ca_final':
        return ['ca_final'];
      case 'class12_boards':
        return ['class12_boards'];
      case 'both':
        return ['jee_main', 'neet_ug'];
      case 'jee_main':
      default:
        return ['jee_main'];
    }
  }

  static Future<void> runIfNeeded() async {
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_flag) == true) return;
    } catch (e) {
      AppLogger.w('ChapterKeyMigration', 'prefs unavailable, skipping: $e');
      return;
    }

    try {
      final db = IsarService.db;

      // ── 1. Stamp keys on chapters themselves ────────────────────────────
      final chapters = await db.chapterSchemas.where().findAll();
      final toStamp = <ChapterSchema>[];
      for (final c in chapters) {
        final key = ChapterKey.build(c.syllabusSource, c.name);
        if (c.chapterKey != key) {
          c.chapterKey = key;
          toStamp.add(c);
        }
      }
      if (toStamp.isNotEmpty) {
        await db.writeTxn(() async => db.chapterSchemas.putAll(toStamp));
      }

      // ── 2. Build the name → key resolver ────────────────────────────────
      final user = await db.userSchemas.where().findFirst();
      final userSources = _sourcesForExam(user?.targetExam);

      // name → list of (source, key)
      final byName = <String, List<ChapterSchema>>{};
      for (final c in chapters) {
        (byName[c.name] ??= []).add(c);
      }

      String resolve(String chapterName) {
        final candidates = byName[chapterName];
        if (candidates == null || candidates.isEmpty) return '';
        if (candidates.length == 1) return candidates.first.chapterKey;
        // Collision: prefer the user's current stream.
        for (final src in userSources) {
          final match =
              candidates.where((c) => c.syllabusSource == src).firstOrNull;
          if (match != null) return match.chapterKey;
        }
        // Ambiguous and outside user's stream — first candidate is no worse
        // than the old findFirst() behaviour, but now it is at least STABLE.
        return candidates.first.chapterKey;
      }

      // ── 3. Backfill referencing collections ─────────────────────────────
      var planFixed = 0, logFixed = 0, revFixed = 0, misFixed = 0;

      final planEntries = await db.planEntrySchemas
          .filter()
          .chapterKeyEqualTo('')
          .findAll();
      for (final e in planEntries) {
        final key = resolve(e.chapterName);
        if (key.isEmpty) continue;
        e.chapterKey = key;
        e.syllabusSource = ChapterKey.sourceOf(key);
        planFixed++;
      }
      if (planEntries.isNotEmpty) {
        await db.writeTxn(() async => db.planEntrySchemas.putAll(planEntries));
      }

      final logs =
          await db.studyLogSchemas.filter().chapterKeyEqualTo('').findAll();
      for (final l in logs) {
        final key = resolve(l.chapterName);
        if (key.isEmpty) continue;
        l.chapterKey = key;
        l.syllabusSource = ChapterKey.sourceOf(key);
        logFixed++;
      }
      if (logs.isNotEmpty) {
        await db.writeTxn(() async => db.studyLogSchemas.putAll(logs));
      }

      final revs = await db.revisionScheduleSchemas
          .filter()
          .chapterKeyEqualTo('')
          .findAll();
      for (final r in revs) {
        final key = resolve(r.chapterName);
        if (key.isEmpty) continue;
        r.chapterKey = key;
        r.syllabusSource = ChapterKey.sourceOf(key);
        revFixed++;
      }
      if (revs.isNotEmpty) {
        await db.writeTxn(
            () async => db.revisionScheduleSchemas.putAll(revs));
      }

      final mistakes = await db.mistakeEntrySchemas
          .filter()
          .chapterKeyEqualTo('')
          .findAll();
      for (final m in mistakes) {
        final key = resolve(m.chapterName);
        if (key.isEmpty) continue;
        m.chapterKey = key;
        m.syllabusSource = ChapterKey.sourceOf(key);
        misFixed++;
      }
      if (mistakes.isNotEmpty) {
        await db.writeTxn(
            () async => db.mistakeEntrySchemas.putAll(mistakes));
      }

      await prefs.setBool(_flag, true);
      AppLogger.d('ChapterKeyMigration',
          'done — chapters=${toStamp.length}, plan=$planFixed, '
          'logs=$logFixed, revisions=$revFixed, mistakes=$misFixed');
    } catch (e, st) {
      // Flag stays unset → retried next launch. Never block startup.
      AppLogger.e('ChapterKeyMigration', 'failed (will retry): $e', st);
    }
  }
}
