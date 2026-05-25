// lib/data/local/isar/schemas/mistake_entry_schema.dart

import 'package:isar/isar.dart';
part 'mistake_entry_schema.g.dart';

@collection
class MistakeEntrySchema {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;

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

  String? testName;

  late DateTime createdAt;

  // ── Computed helpers — @ignore tells Isar to skip these ─────────────────────

  @ignore
  String get mistakeTypeLabel {
    const labels = [
      'Conceptual', 'Calculation', 'Silly Mistake',
      'Time Pressure', 'Forgot Formula', 'Guesswork',
    ];
    return mistakeTypeIndex < labels.length
        ? labels[mistakeTypeIndex]
        : 'Other';
  }

  @ignore
  String get mistakeTypeEmoji {
    const emojis = ['🧠', '🔢', '🤦', '⏱️', '📐', '🎲'];
    return mistakeTypeIndex < emojis.length
        ? emojis[mistakeTypeIndex]
        : '❓';
  }

  /// Migrate from legacy SharedPreferences JSON format.
  static MistakeEntrySchema fromLegacyJson(Map<String, dynamic> j) {
    const typeNames = [
      'conceptual', 'calculation', 'silly',
      'timePressure', 'forgotFormula', 'guesswork',
    ];
    final typeName = j['type'] as String? ?? 'silly';
    final typeIdx  = typeNames.indexOf(typeName).clamp(0, typeNames.length - 1);

    return MistakeEntrySchema()
      ..date             = j['date'] != null
          ? DateTime.tryParse(j['date'] as String) ?? DateTime.now()
          : DateTime.now()
      ..mistakeTypeIndex = typeIdx
      ..chapterName      = j['chapterName']     as String? ?? ''
      ..subjectName      = j['subjectName']     as String? ?? ''
      ..questionSummary  = j['questionSummary'] as String? ?? ''
      ..correctApproach  = j['correctApproach'] as String? ?? ''
      ..isResolved       = j['isResolved']      as bool?   ?? false
      ..resolvedAt       = null
      ..testName         = j['testName']        as String?
      ..createdAt        = DateTime.now();
  }
}
