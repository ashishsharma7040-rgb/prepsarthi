import 'package:isar/isar.dart';
part 'revision_schedule_schema.g.dart';

@collection
class RevisionScheduleSchema {
  Id id = Isar.autoIncrement;

  // DATA-1 (Master Spec): identity link. Upserts in scheduleRevisions() key
  // on chapterKey, so 'Kinematics' in jee_main and neet_ug finally get
  // SEPARATE revision schedules.
  @Index()
  String chapterKey = '';
  String syllabusSource = '';

  // ⚠️ unique:true REMOVED. The old unique index on a colliding name meant
  // two streams' schedules silently clobbered each other — and adding a
  // unique index on a new ''-defaulted field would collapse existing rows on
  // first open. Uniqueness is now enforced by the upsert in
  // GeneratePlanUseCase.scheduleRevisions().
  @Index()
  late String chapterName;

  late String subjectName;
  late DateTime firstLearnedDate;

  late List<DateTime> scheduledDates;
  List<DateTime> completedDates = [];

  int completedCount = 0;
  bool isFullyRevised = false;
  bool active = true;
}
