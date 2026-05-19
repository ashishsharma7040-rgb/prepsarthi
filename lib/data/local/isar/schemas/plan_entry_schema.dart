import 'package:isar/isar.dart';
part 'plan_entry_schema.g.dart';

@collection
class PlanEntrySchema {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime plannedDate;

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
