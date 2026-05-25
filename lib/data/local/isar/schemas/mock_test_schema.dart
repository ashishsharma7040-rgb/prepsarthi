// lib/data/local/isar/schemas/mock_test_schema.dart

import 'dart:convert';
import 'package:isar/isar.dart';
part 'mock_test_schema.g.dart';

@collection
class MockTestSchema {
  Id id = Isar.autoIncrement;

  @Index()
  late String examType;

  late String testName;

  @Index()
  late DateTime date;

  late int totalMarks;
  late int obtainedMarks;

  // Maps stored as JSON strings — Isar 3 does not support Map fields natively
  String subjectMarksJson = '{}';
  String subjectMaxJson   = '{}';

  String? notes;

  late DateTime createdAt;

  // ── Computed helpers — @ignore tells Isar to skip these ─────────────────────

  @ignore
  double get percentage =>
      totalMarks > 0 ? obtainedMarks / totalMarks * 100 : 0.0;

  @ignore
  Map<String, int> get subjectMarks {
    try {
      final raw = jsonDecode(subjectMarksJson) as Map<String, dynamic>;
      return raw.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  @ignore
  set subjectMarks(Map<String, int> value) {
    subjectMarksJson = jsonEncode(value);
  }

  @ignore
  Map<String, int> get subjectMax {
    try {
      final raw = jsonDecode(subjectMaxJson) as Map<String, dynamic>;
      return raw.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  @ignore
  set subjectMax(Map<String, int> value) {
    subjectMaxJson = jsonEncode(value);
  }

  /// Migrate from legacy SharedPreferences JSON format.
  static MockTestSchema fromLegacyJson(Map<String, dynamic> j) {
    final schema = MockTestSchema()
      ..examType      = j['examType']  as String? ?? 'Mock'
      ..testName      = j['testName']  as String? ?? 'Unknown Test'
      ..date          = j['date'] != null
          ? DateTime.tryParse(j['date'] as String) ?? DateTime.now()
          : DateTime.now()
      ..totalMarks    = (j['totalMarks'] as num?)?.toInt() ?? 0
      ..obtainedMarks = (j['obtained']   as num?)?.toInt() ?? 0
      ..notes         = j['notes'] as String?
      ..createdAt     = DateTime.now();

    if (j['subjectMarks'] is Map) {
      schema.subjectMarksJson =
          jsonEncode(Map<String, dynamic>.from(j['subjectMarks'] as Map));
    }
    if (j['subjectMax'] is Map) {
      schema.subjectMaxJson =
          jsonEncode(Map<String, dynamic>.from(j['subjectMax'] as Map));
    }
    return schema;
  }
}
