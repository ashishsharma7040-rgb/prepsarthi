// lib/data/local/isar/isar_service.dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'schemas/user_schema.dart';
import 'schemas/chapter_schema.dart';
import 'schemas/plan_entry_schema.dart';
import 'schemas/study_log_schema.dart';
import 'schemas/revision_schedule_schema.dart';
import 'schemas/user_settings_schema.dart';
import 'schemas/achievement_schema.dart';
import 'schemas/mock_test_schema.dart';
import 'schemas/mistake_entry_schema.dart';
import 'schemas/readiness_snapshot_schema.dart';
// [REVIEW_CARD_STEP] After running build_runner, uncomment this import:
// import 'schemas/review_card_schema.dart';

export 'schemas/schemas.dart';

class IsarService {
  static Isar? _instance;

  static bool get isReady => _instance != null && _instance!.isOpen;

  static Future<Isar> getInstance() async {
    if (_instance != null && _instance!.isOpen) return _instance!;
    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [
        UserSchemaSchema,
        ChapterSchemaSchema,
        PlanEntrySchemaSchema,
        StudyLogSchemaSchema,
        RevisionScheduleSchemaSchema,
        UserSettingsSchemaSchema,
        AchievementSchemaSchema,
        MockTestSchemaSchema,
        MistakeEntrySchemaSchema,
        ReadinessSnapshotSchemaSchema,
        // [REVIEW_CARD_STEP] After running build_runner, uncomment this line:
        // ReviewCardSchemaSchema,
      ],
      directory: dir.path,
      name: 'prepsarthi_db',
      // Version history:
      // v1 → v2: added MockTestSchema + MistakeEntrySchema
      // v2 → v3: added ReadinessSnapshotSchema
      // [REVIEW_CARD_STEP] When uncommenting ReviewCardSchema, increment to v4
      //   and add: migration: (db, version) => db.writeTxn(() async {})
    );
    return _instance!;
  }

  static Isar get db {
    assert(
      _instance != null && _instance!.isOpen,
      'IsarService not initialised. Call getInstance() first.',
    );
    return _instance!;
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }

  static Future<void> clearAllStudyData() async {
    final db = IsarService.db;
    await db.writeTxn(() async {
      await db.chapterSchemas.clear();
      await db.planEntrySchemas.clear();
      await db.studyLogSchemas.clear();
      await db.revisionScheduleSchemas.clear();
      await db.achievementSchemas.clear();
      await db.mockTestSchemas.clear();
      await db.mistakeEntrySchemas.clear();
      await db.readinessSnapshotSchemas.clear();
      // [REVIEW_CARD_STEP] After build_runner, add: await db.reviewCardSchemas.clear();
    });
  }
}
