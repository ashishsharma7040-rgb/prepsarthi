import 'package:isar/isar.dart';
part 'study_log_schema.g.dart';

@collection
class StudyLogSchema {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime timestamp;

  late String chapterName;
  late String subjectName;
  late double hoursStudied;
  late String activityTag;

  String? notes;
  bool isPomodoro = false;
  int pomodoroSessions = 0;
}
