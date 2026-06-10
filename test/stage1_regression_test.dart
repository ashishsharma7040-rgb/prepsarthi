// test/stage1_regression_test.dart
//
// Stage 1 (Master Spec) regression gate. PURE-DART — no Isar/Flutter binding,
// so it runs in milliseconds in CI (matches the existing test suite style).
//
// These tests lock in the four foundation invariants. If any breaks, the
// data-corruption class it guards has returned.
//
//   DATA-1  chapterKey identity is stable and stream-distinct
//   DATA-5  streak transition is correct AND idempotent same-day
//   DATA-2  onboarding snapshot may only UPGRADE mastery, never downgrade
//   EXAM-2  CA Final January attempt resolves to January (not May)
//
// Run: flutter test test/stage1_regression_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:prepsarthi/core/constants/exam_dates.dart';
import 'package:prepsarthi/core/utils/chapter_key.dart';
import 'package:prepsarthi/data/local/isar/schemas/chapter_schema.dart';
import 'package:prepsarthi/domain/usecases/generate_plan_usecase.dart';
import 'package:prepsarthi/domain/usecases/streak_usecase.dart';

void main() {
  // ── DATA-1: chapterKey identity ────────────────────────────────────────────
  group('DATA-1 chapterKey identity', () {
    test('same name in different streams produces DIFFERENT keys', () {
      final jee = ChapterKey.build('jee_main', 'Kinematics');
      final neet = ChapterKey.build('neet_ug', 'Kinematics');
      expect(jee, isNot(equals(neet)));
      expect(jee, 'jee_main|kinematics');
      expect(neet, 'neet_ug|kinematics');
    });

    test('slug is deterministic and punctuation-stable', () {
      expect(ChapterKey.slug('Ind AS 116 (Leases)'), 'ind-as-116-leases');
      expect(ChapterKey.slug('  Current  Electricity  '),
          'current-electricity');
      // Same input → same output, every time (stable across versions).
      expect(ChapterKey.slug('Atoms & Nuclei'),
          ChapterKey.slug('Atoms & Nuclei'));
    });

    test('sourceOf and isValid round-trip', () {
      final key = ChapterKey.build('ca_final', 'Financial Reporting');
      expect(ChapterKey.sourceOf(key), 'ca_final');
      expect(ChapterKey.isValid(key), isTrue);
      expect(ChapterKey.isValid(''), isFalse);
      expect(ChapterKey.isValid('no-separator'), isFalse);
    });
  });

  // ── DATA-5: single streak authority ────────────────────────────────────────
  group('DATA-5 streak transition', () {
    final today = DateTime(2026, 6, 10);

    test('consecutive day increments by exactly one', () {
      final r = StreakUseCase.computeNext(
        currentStreak: 5,
        longestStreak: 5,
        lastStudyDate: DateTime(2026, 6, 9),
        today: today,
      );
      expect(r.currentStreak, 6); // NOT 7 — this is the double-count guard
      expect(r.longestStreak, 6);
      expect(r.changed, isTrue);
    });

    test('same-day repeat is an idempotent no-op', () {
      final r = StreakUseCase.computeNext(
        currentStreak: 6,
        longestStreak: 6,
        lastStudyDate: today,
        today: today,
      );
      expect(r.currentStreak, 6);
      expect(r.changed, isFalse); // second writer must not bump again
    });

    test('gap of 2+ days resets to one', () {
      final r = StreakUseCase.computeNext(
        currentStreak: 9,
        longestStreak: 12,
        lastStudyDate: DateTime(2026, 6, 7),
        today: today,
      );
      expect(r.currentStreak, 1);
      expect(r.longestStreak, 12); // longest preserved
    });

    test('first ever study session starts at one', () {
      final r = StreakUseCase.computeNext(
        currentStreak: 0,
        longestStreak: 0,
        lastStudyDate: null,
        today: today,
      );
      expect(r.currentStreak, 1);
      expect(r.longestStreak, 1);
    });
  });

  // ── DATA-2: upgrade-only mastery ───────────────────────────────────────────
  // NOTE: applyStatusUpgradeOnly lives in WeaknessDetectorUseCase (same file as
  // GeneratePlanUseCase), since it is part of progress/weakness application.
  group('DATA-2 onboarding snapshot is upgrade-only', () {
    ChapterSchema chapterAt(int mastery, String status) => ChapterSchema()
      ..name = 'Ind AS 116'
      ..subjectName = 'FR'
      ..syllabusSource = 'ca_final'
      ..classLevel = 1
      ..estimatedHours = 8
      ..weightage = 10
      ..difficulty = 3
      ..pyqCount = 5
      ..tags = <String>[]
      ..masteryLevel = mastery
      ..status = status;

    test('does NOT downgrade a chapter the student advanced in-app', () {
      // Student took it to Test Ready (7); onboarding said 'in_progress' (2).
      final ch = chapterAt(7, 'completed');
      WeaknessDetectorUseCase.applyStatusUpgradeOnly(ch, 'in_progress');
      expect(ch.masteryLevel, 7); // stays — the regression that was reported
      expect(ch.status, 'completed');
    });

    test('DOES upgrade when the snapshot is ahead', () {
      final ch = chapterAt(0, 'not_started');
      WeaknessDetectorUseCase.applyStatusUpgradeOnly(ch, 'completed');
      expect(ch.masteryLevel, 7);
      expect(ch.status, 'completed');
    });

    test('not_started is a no-op', () {
      final ch = chapterAt(3, 'learned');
      WeaknessDetectorUseCase.applyStatusUpgradeOnly(ch, 'not_started');
      expect(ch.masteryLevel, 3);
      expect(ch.status, 'learned');
    });
  });

  // ── EXAM-2: CA Final Jan/May/Sep cycle ─────────────────────────────────────
  group('EXAM-2 CA Final attempt dates', () {
    test('January attempt resolves to January, not May', () {
      final d = ExamDates.examDate('ca_final', 2028, caAttempt: 'january');
      expect(d.month, 1); // the 4-month bug: previously returned May (5)
      expect(d.year, 2028);
    });

    test('September attempt resolves to September', () {
      final d = ExamDates.examDate('ca_final', 2027, caAttempt: 'september');
      expect(d.month, 9);
    });

    test('legacy november maps to next January (no phantom date)', () {
      final d = ExamDates.examDate('ca_final', 2027, caAttempt: 'november');
      expect(d.month, 1);
      expect(d.year, 2028);
    });

    test('boards is early March, consistent everywhere', () {
      final d = ExamDates.examDate('class12_boards', 2027);
      expect(d.month, 3);
      expect(d.day, 5);
    });
  });
}
