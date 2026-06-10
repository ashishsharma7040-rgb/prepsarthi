import 'package:isar/isar.dart';
part 'plan_entry_schema.g.dart';

@collection
class PlanEntrySchema {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime plannedDate;

  // DATA-1 (Master Spec): identity link to the chapter ('' = legacy row,
  // backfilled by ChapterKeyMigration). chapterName below is display-only.
  @Index()
  String chapterKey = '';

  // Denormalized for cheap stream filtering (supersedes R1 BUG-2).
  @Index()
  String syllabusSource = '';

  late String chapterName;
  late String subjectName;
  late double plannedHours;
  late int orderIndex;

  bool isRevision = false;
  String? revisionOf;

  String status = 'pending';
  double actualHours = 0.0;

  bool isBufferDay = false;
  bool isMockTest = false;
  String? mockTestSubject;
}
