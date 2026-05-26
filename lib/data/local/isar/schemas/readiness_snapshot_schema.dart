// lib/data/local/isar/schemas/readiness_snapshot_schema.dart
//
// Stores one readiness score snapshot per calendar day.
// Written on app open; read to render the 30-day trend chart on
// Today Command Center and Dashboard.
//
// No migration needed — this is a brand-new collection.

import 'package:isar/isar.dart';
part 'readiness_snapshot_schema.g.dart';

@collection
class ReadinessSnapshotSchema {
  Id id = Isar.autoIncrement;

  /// Calendar date — midnight UTC, used as the de-dup key.
  /// Only one snapshot per day is kept; a new write overwrites the previous one.
  @Index(unique: false)
  late DateTime date;

  /// 0–100 overall readiness score.
  late int score;

  /// Grade string: 'S' | 'A' | 'B' | 'C' | 'D'
  late String grade;

  // ── Breakdown components (each 0.0–1.0) ──────────────────────────────────
  late double syllabusRatio;
  late double revisionRatio;
  late double testPerf;
  late double consistencyRatio;
  late double backlogScore;
  late double mistakeScore;
}
