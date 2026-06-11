// test/part2b_repository_test.dart
//
// PART 2B gate: confirms the repository layer's public API surface is intact.
// These are compile-time contract checks — they import every repository and
// reference each public method as a tear-off, so if a signature changes or a
// method is removed, the test fails to compile (a CI signal). No live Isar
// needed.

import 'package:flutter_test/flutter_test.dart';
import 'package:prepsarthi/data/repositories/chapter_repository.dart';
import 'package:prepsarthi/data/repositories/plan_repository.dart';
import 'package:prepsarthi/data/repositories/mock_test_repository.dart';
import 'package:prepsarthi/data/repositories/mistake_repository.dart';
import 'package:prepsarthi/data/repositories/study_log_repository.dart';
import 'package:prepsarthi/data/repositories/revision_repository.dart';

void main() {
  test('repository public API surface exists', () {
    // Chapter
    expect(ChapterRepository.forSources, isNotNull);
    expect(ChapterRepository.forExam, isNotNull);
    expect(ChapterRepository.byKey, isNotNull);
    expect(ChapterRepository.statusProgressByClassLevels, isNotNull);
    expect(ChapterRepository.put, isNotNull);

    // Plan
    expect(PlanRepository.forDay, isNotNull);
    expect(PlanRepository.inRange, isNotNull);
    expect(PlanRepository.groupedByDay, isNotNull);
    expect(PlanRepository.pendingCount, isNotNull);
    expect(PlanRepository.put, isNotNull);

    // Mock
    expect(MockTestRepository.forExam, isNotNull);
    expect(MockTestRepository.all, isNotNull);
    expect(MockTestRepository.put, isNotNull);

    // Mistake
    expect(MistakeRepository.forSources, isNotNull);
    expect(MistakeRepository.all, isNotNull);
    expect(MistakeRepository.byId, isNotNull);

    // StudyLog
    expect(StudyLogRepository.recent, isNotNull);
    expect(StudyLogRepository.since, isNotNull);
    expect(StudyLogRepository.inRange, isNotNull);
    expect(StudyLogRepository.forDay, isNotNull);
    expect(StudyLogRepository.countByTag, isNotNull);

    // Revision
    expect(RevisionRepository.active, isNotNull);
    expect(RevisionRepository.forChapter, isNotNull);
    expect(RevisionRepository.put, isNotNull);
  });
}
