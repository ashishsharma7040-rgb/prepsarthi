// test/part2_exam_registry_test.dart
//
// PART 2B gate: the ExamRegistry contract that the repository layer and all
// migrated call sites now depend on. Pure — no Isar runtime needed.

import 'package:flutter_test/flutter_test.dart';
import 'package:prepsarthi/data/content/exam_registry.dart';

void main() {
  group('ExamRegistry source resolution', () {
    test("'both' merges jee_main + neet_ug", () {
      final s = ExamRegistry.sourcesOf('both');
      expect(s, containsAll(['jee_main', 'neet_ug']));
      expect(s.length, 2);
    });

    test('single-stream exams resolve to exactly one source', () {
      expect(ExamRegistry.sourcesOf('neet'), ['neet_ug']);
      expect(ExamRegistry.sourcesOf('ca_final'), ['ca_final']);
      expect(ExamRegistry.sourcesOf('jee_advanced'), ['jee_advanced']);
      expect(ExamRegistry.sourcesOf('class12_boards'), ['class12_boards']);
    });

    test('unknown / null exam falls back to jee_main (never throws)', () {
      expect(ExamRegistry.sourcesOf(null), ['jee_main']);
      expect(ExamRegistry.sourcesOf('totally_unknown'), ['jee_main']);
      expect(ExamRegistry.isKnown('totally_unknown'), isFalse);
    });

    test('primary source is the first/anchor source', () {
      expect(ExamRegistry.primarySourceOf('both'), 'jee_main');
      expect(ExamRegistry.primarySourceOf('neet'), 'neet_ug');
    });
  });

  group('ExamRegistry exam metadata', () {
    test('display names are human-readable', () {
      expect(ExamRegistry.displayNameOf('ca_final'), 'CA Final');
      expect(ExamRegistry.displayNameOf('both'), 'JEE + NEET');
      expect(ExamRegistry.displayNameOf('unknown'), 'Exam');
    });

    test('mock labels match the exam (EXAM-4)', () {
      expect(ExamRegistry.of('ca_final').mockTestLabel, 'CA Final');
      expect(ExamRegistry.of('neet').mockTestLabel, 'NEET');
    });

    test('percentile applies only to entrance exams, not CA/Boards', () {
      expect(ExamRegistry.of('jee_main').usesPercentile, isTrue);
      expect(ExamRegistry.of('ca_final').usesPercentile, isFalse);
      expect(ExamRegistry.of('class12_boards').usesPercentile, isFalse);
    });

    test('every exam has a syllabus asset for each of its sources', () {
      for (final id in ExamRegistry.allIds) {
        final spec = ExamRegistry.of(id);
        for (final src in spec.syllabusSources) {
          expect(spec.syllabusAssets[src], isNotNull,
              reason: 'missing asset for $src in $id');
        }
      }
    });
  });

  group('ExamRegistry.examDate', () {
    test('CA Final January resolves to January', () {
      final d = ExamRegistry.examDate('ca_final', 2028, sessionId: 'january');
      expect(d.month, 1);
      expect(d.year, 2028);
    });

    test('legacy november maps to next January', () {
      final d = ExamRegistry.examDate('ca_final', 2027, sessionId: 'november');
      expect(d.month, 1);
      expect(d.year, 2028);
    });

    test('boards is early March', () {
      final d = ExamRegistry.examDate('class12_boards', 2027);
      expect(d.month, 3);
    });
  });
}
