// lib/data/repositories/mock_test_repository.dart
//
// PART 2B (STRUCT-2 / DATA-4): the single access point for mock test records.
//
// The exam-matching filter (a JEE mock must not count toward CA readiness)
// previously lived inside ReadinessCalculator. Centralising it here means
// every consumer gets the same correct, exam-aware view — and the filter is
// defined once.

import 'package:isar/isar.dart';

import '../local/isar/isar_service.dart'; // re-exports schemas/schemas.dart

class MockTestRepository {
  MockTestRepository._();

  /// All mocks, newest-first (raw — callers that need exam filtering should
  /// use [forExam]).
  static Future<List<MockTestSchema>> all() async {
    final db = IsarService.db;
    final list = await db.mockTestSchemas.where().findAll();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Mocks belonging to [targetExam], oldest-first (for recency slicing in
  /// readiness). Legacy-label tolerant: examType strings written by the old
  /// test-score screen ('JEE Main', 'NEET', 'Mock') are matched loosely.
  /// DATA-4: a student who switched exams no longer carries the old exam's
  /// mock percentages into the new exam's readiness.
  static Future<List<MockTestSchema>> forExam(String? targetExam) async {
    final db = IsarService.db;
    final all = await db.mockTestSchemas.where().sortByDate().findAll();
    if (targetExam == null) return all;
    return all.where((t) => _matchesExam(t.examType, targetExam)).toList();
  }

  static bool _matchesExam(String examType, String targetExam) {
    final e = examType.toLowerCase();
    switch (targetExam) {
      case 'neet':
        return e.contains('neet') || e == 'mock';
      case 'both':
        return e.contains('neet') || e.contains('jee') || e == 'mock';
      case 'ca_final':
        return e.contains('ca') || e == 'mock';
      case 'class12_boards':
        return e.contains('board') || e == 'mock';
      case 'jee_advanced':
      case 'jee_main':
      default:
        return e.contains('jee') || e == 'mock';
    }
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  static Future<void> put(MockTestSchema schema) async {
    final db = IsarService.db;
    await db.writeTxn(() => db.mockTestSchemas.put(schema));
  }

  static Future<void> putAll(List<MockTestSchema> schemas) async {
    final db = IsarService.db;
    await db.writeTxn(() => db.mockTestSchemas.putAll(schemas));
  }

  static Future<void> delete(int id) async {
    final db = IsarService.db;
    await db.writeTxn(() => db.mockTestSchemas.delete(id));
  }
}
