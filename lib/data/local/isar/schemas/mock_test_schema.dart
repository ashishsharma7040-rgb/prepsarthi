// lib/data/local/isar/schemas/mock_test_schema.dart
//
// Replaces SharedPreferences storage for mock test scores.
// After adding this file:
//   1. Add export to schemas.dart barrel
//   2. Add MockTestSchemaSchema to IsarService.open() list
//   3. Increment isar_service.dart schema version
//   4. Run: dart run build_runner build --delete-conflicting-outputs

import 'dart:convert';
import 'package:isar/isar.dart';
part 'mock_test_schema.g.dart';

@collection
class MockTestSchema {
  Id id = Isar.autoIncrement;

  @Index()
  late String examType; // 'JEE Main' | 'JEE Advanced' | 'NEET' | 'Mock' | 'Other'

  late String testName;

  @Index()
  late DateTime date;

  late int totalMarks;
  late int obtainedMarks;

  // Maps stored as JSON strings (Isar 3 does not support Map fields natively)
  String subjectMarksJson = '{}';  // e.g. {"Physics":72,"Chemistry":68,"Mathematics":55}
  String subjectMaxJson   = '{}';  // e.g. {"Physics":100,"Chemistry":100,"Mathematics":100}

  String? notes;

  late DateTime createdAt;

  // ── Computed helpers ────────────────────────────────────────────────────────

  double get percentage =>
      totalMarks > 0 ? obtainedMarks / totalMarks * 100 : 0.0;

  Map<String, int> get subjectMarks {
    try {
      final raw = jsonDecode(subjectMarksJson) as Map<String, dynamic>;
      return raw.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  set subjectMarks(Map<String, int> value) {
    subjectMarksJson = jsonEncode(value);
  }

  Map<String, int> get subjectMax {
    try {
      final raw = jsonDecode(subjectMaxJson) as Map<String, dynamic>;
      return raw.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  set subjectMax(Map<String, int> value) {
    subjectMaxJson = jsonEncode(value);
  }

  /// Factory: build from the legacy TestEntry.toJson() map that SharedPrefs stored.
  /// Used during one-time migration on first launch.
  static MockTestSchema fromLegacyJson(Map<String, dynamic> j) {
    final schema = MockTestSchema()
      ..examType        = j['examType'] as String? ?? 'Mock'
      ..testName        = j['testName'] as String? ?? 'Unknown Test'
      ..date            = j['date'] != null
          ? DateTime.tryParse(j['date'] as String) ?? DateTime.now()
          : DateTime.now()
      ..totalMarks      = (j['totalMarks'] as num?)?.toInt() ?? 0
      ..obtainedMarks   = (j['obtained'] as num?)?.toInt() ?? 0
      ..notes           = j['notes'] as String?
      ..createdAt       = DateTime.now();

    // Legacy used 'subjectMarks' and 'subjectMax' as nested Map<String,int>
    if (j['subjectMarks'] is Map) {
      schema.subjectMarksJson = jsonEncode(
        Map<String, dynamic>.from(j['subjectMarks'] as Map),
      );
    }
    if (j['subjectMax'] is Map) {
      schema.subjectMaxJson = jsonEncode(
        Map<String, dynamic>.from(j['subjectMax'] as Map),
      );
    }

    return schema;
  }
}
