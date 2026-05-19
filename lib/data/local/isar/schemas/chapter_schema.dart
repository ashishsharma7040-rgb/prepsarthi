import 'package:isar/isar.dart';
part 'chapter_schema.g.dart';

/// Mastery levels 0–7 for serious JEE/NEET tracking
/// 0=Not Started, 1=Theory Started, 2=Theory Completed,
/// 3=Questions Practiced, 4=PYQs Done, 5=Revision 1 Done,
/// 6=Revision 2 Done, 7=Test Ready
@collection
class ChapterSchema {
  Id id = Isar.autoIncrement;

  @Index()
  late String subjectName;

  @Index()
  late String syllabusSource;

  late String name;
  late int classLevel;
  late double estimatedHours;
  late double weightage;
  late int difficulty;
  late int pyqCount;

  // ── Legacy status (backward compatible) ─────────────────────────────────
  String status = 'not_started';

  // ── 8-level mastery system ───────────────────────────────────────────────
  int masteryLevel = 0; // 0–7

  // ── PYQ Tracker ──────────────────────────────────────────────────────────
  int pyqProgress = 0; // 0=not started, 1=25%, 2=50%, 3=75%, 4=100%, 5=mistakes revised

  // ── Mistake tracking ─────────────────────────────────────────────────────
  int conceptualMistakes = 0;
  int calculationMistakes = 0;
  int sillyMistakes = 0;

  // ── Study tracking ────────────────────────────────────────────────────────
  double hoursSpent = 0.0;
  int revisionCount = 0;
  DateTime? firstLearnedDate;
  DateTime? lastStudiedDate;

  // ── Test accuracy ─────────────────────────────────────────────────────────
  int testAttempts = 0;
  int testCorrect = 0;

  // ── Flags ─────────────────────────────────────────────────────────────────
  bool isWeakChapter = false;
  bool isPriorityRevision = false;

  late List<String> tags;

  String get masteryLabel {
    const labels = [
      'Not Started', 'Theory Started', 'Theory Done',
      'Questions Done', 'PYQs Done', 'Revision 1 Done',
      'Revision 2 Done', 'Test Ready',
    ];
    return masteryLevel < labels.length ? labels[masteryLevel] : 'Not Started';
  }

  String get pyqProgressLabel {
    const labels = [
      'Not Started', '25% Done', '50% Done', '75% Done',
      '100% Done', 'Mistakes Revised',
    ];
    return pyqProgress < labels.length ? labels[pyqProgress] : 'Not Started';
  }

  double get progressFraction => (masteryLevel / 7.0).clamp(0.0, 1.0);
  double get testAccuracy =>
      testAttempts > 0 ? testCorrect / testAttempts * 100 : 0;
}
