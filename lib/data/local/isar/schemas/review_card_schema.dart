// lib/data/local/isar/schemas/review_card_schema.dart
//
// Spaced Repetition Card Schema for PrepSarthi
// Implements the SM-2 algorithm fields.
//
// ⚠️  After adding this file, run:
//     dart run build_runner build --delete-conflicting-outputs
// Then uncomment the lines in isar_service.dart marked [REVIEW_CARD_STEP].

import 'package:isar/isar.dart';

part 'review_card_schema.g.dart';

@collection
class ReviewCardSchema {
  Id id = Isar.autoIncrement;

  @Index()
  late String chapterName;

  @Index()
  late String subjectName;

  @Index()
  late String syllabusSource; // 'jee_main', 'ca_final', etc.

  /// Type: 'concept' | 'formula' | 'definition' | 'mistake' | 'pyq'
  late String cardType;

  /// Question / front of card shown to student
  late String front;

  /// Answer / back of card
  late String back;

  // ── SM-2 Spaced Repetition Fields ────────────────────────────────────────

  /// Ease factor — how well the student remembers this card (min 1.3)
  double easeFactor = 2.5;

  /// Current interval in days until next review
  int interval = 1;

  /// How many times this card has been successfully reviewed
  int repetitions = 0;

  /// Date when next review is due
  @Index()
  late DateTime nextReviewDate;

  /// Date of the last review (null if never reviewed)
  DateTime? lastReviewed;

  /// Is this card active (not deleted/deactivated)?
  bool isActive = true;

  /// When this card was created
  DateTime createdAt = DateTime.now();

  /// Last performance rating given by student (1=Hard, 3=Good, 5=Easy)
  int? lastPerformance;

  ReviewCardSchema();

  /// Factory constructor for clean creation
  factory ReviewCardSchema.create({
    required String chapterName,
    required String subjectName,
    required String syllabusSource,
    required String cardType,
    required String front,
    required String back,
    DateTime? nextReviewDate,
  }) {
    return ReviewCardSchema()
      ..chapterName   = chapterName
      ..subjectName   = subjectName
      ..syllabusSource = syllabusSource
      ..cardType      = cardType
      ..front         = front
      ..back          = back
      ..nextReviewDate = nextReviewDate ?? DateTime.now().add(const Duration(days: 1))
      ..createdAt     = DateTime.now();
  }

  /// Human-readable card type label
  String get cardTypeLabel {
    switch (cardType) {
      case 'formula':    return '📐 Formula';
      case 'concept':    return '💡 Concept';
      case 'definition': return '📖 Definition';
      case 'mistake':    return '⚠️ Mistake';
      case 'pyq':        return '📝 PYQ';
      default:           return '🃏 Card';
    }
  }

  /// Whether this card is due for review today or overdue
  bool get isDueToday {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return isActive && nextReviewDate.isBefore(todayEnd);
  }
}
