import 'package:isar/isar.dart';
part 'achievement_schema.g.dart';

@collection
class AchievementSchema {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String badgeId;

  late String title;
  late String description;
  late String emoji;

  bool unlocked = false;
  DateTime? unlockedAt;
  int currentProgress = 0;
  int targetProgress = 1;
}
