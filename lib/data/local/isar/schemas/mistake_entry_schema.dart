// lib/data/local/isar/schemas/mistake_entry_schema.dart
//
// Replaces SharedPreferences storage for mistake notebook entries.
// After adding this file:
//   1. Add export to schemas.dart barrel
//   2. Add MistakeEntrySchemaSchema to IsarService.open() list
//   3. Increment isar_service.dart schema version (same version bump as MockTestSchema)
//   4. Run: dart run build_runner build --delete-conflicting-outputs

import 'package:isar/isar.dart';
part 'mistake_entry_schema.g.dart';

/// Maps to the MistakeType enum in mistake_notebook_screen.dart.
/// Index 0-based matches MistakeType.values order:
///   0=conceptual, 1=calculation, 2=silly, 3=timePressure,
///   4=forgotFormula, 5=guesswork
@collection
class MistakeEntrySchema {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;

  /// Index into MistakeType.values — avoids storing enum strings,
  /// keeping schema forward-compatible if new types are added.
  int mistakeTypeIndex = 0;

  @Index()
  late String chapterName;

  @Index()
  late String subjectName;

  late String questionSummary;
  late String correctApproach;

  @Index()
  bool isResolved = false;

  DateTime? resolvedAt;

  /// Name of the mock test this mistake came from (optional).
  String? testName;

  late DateTime createdAt;

  // ── Computed helpers ────────────────────────────────────────────────────────

  /// Human-readable label for the mistake type.
  /// Mirrors MistakeType.label from mistake_notebook_screen.dart.
  String get mistakeTypeLabel {
    const labels = [
      'Conceptual',
      'Calculation',
      'Silly Mistake',
      'Time Pressure',
      'Forgot Formula',
      'Guesswork',
    ];
    return mistakeTypeIndex < labels.length
        ? labels[mistakeTypeIndex]
        : 'Other';
  }

  /// Emoji for the mistake type. Mirrors MistakeType.emoji.
  String get mistakeTypeEmoji {
    const emojis = ['🧠', '🔢', '🤦', '⏱️', '📐', '🎲'];
    return mistakeTypeIndex < emojis.length
        ? emojis[mistakeTypeIndex]
        : '❓';
  }

  /// Factory: build from the legacy MistakeEntry.toJson() map stored in SharedPrefs.
  /// Used during one-time migration on first launch.
  static MistakeEntrySchema fromLegacyJson(Map<String, dynamic> j) {
    const typeNames = [
      'conceptual',
      'calculation',
      'silly',
      'timePressure',
      'forgotFormula',
      'guesswork',
    ];
    final typeName = j['type'] as String? ?? 'silly';
    final typeIdx  = typeNames.indexOf(typeName).clamp(0, typeNames.length - 1);

    return MistakeEntrySchema()
      ..date             = j['date'] != null
          ? DateTime.tryParse(j['date'] as String) ?? DateTime.now()
          : DateTime.now()
      ..mistakeTypeIndex = typeIdx
      ..chapterName      = j['chapterName'] as String? ?? ''
      ..subjectName      = j['subjectName'] as String? ?? ''
      ..questionSummary  = j['questionSummary'] as String? ?? ''
      ..correctApproach  = j['correctApproach'] as String? ?? ''
      ..isResolved       = j['isResolved'] as bool? ?? false
      ..resolvedAt       = null
      ..testName         = j['testName'] as String?
      ..createdAt        = DateTime.now();
  }
}
