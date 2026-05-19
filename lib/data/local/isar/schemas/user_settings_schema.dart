import 'package:isar/isar.dart';
part 'user_settings_schema.g.dart';

@collection
class UserSettingsSchema {
  Id id = Isar.autoIncrement;

  String themeMode = 'system';
  bool notificationsEnabled = true;
  String notificationTime = '09:00';

  int pomodoroWorkMinutes = 25;
  int pomodoroBreakMinutes = 5;
  int pomodoroCycles = 4;

  bool soundEnabled = true;
  bool vibrationEnabled = true;

  List<DateTime> blackoutDates = [];

  String? appVersion;
  DateTime? lastPlanGeneratedAt;
}
