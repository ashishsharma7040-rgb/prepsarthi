import 'package:isar/isar.dart';
part 'revision_schedule_schema.g.dart';

@collection
class RevisionScheduleSchema {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String chapterName;

  late String subjectName;
  late DateTime firstLearnedDate;

  late List<DateTime> scheduledDates;
  List<DateTime> completedDates = [];

  int completedCount = 0;
  bool isFullyRevised = false;
  bool active = true;
}
