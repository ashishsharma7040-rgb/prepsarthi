// lib/domain/usecases/review_card_usecase.dart
//
// Full SM-2 Spaced Repetition System for PrepSarthi
//
// SM-2 Algorithm Reference:
//   - If performance >= 3 (Good/Easy): interval grows by easeFactor
//   - If performance < 3 (Hard/Again): reset to 1 day
//   - EF_new = EF + (0.1 - (5-q) * (0.08 + (5-q)*0.02))   q = quality 0-5
//   - Minimum ease factor: 1.3
//
// ⚠️  This file is INACTIVE until you complete [REVIEW_CARD_STEP]:
//     1. Run: dart run build_runner build --delete-conflicting-outputs
//     2. Uncomment lines in isar_service.dart and schemas.dart marked [REVIEW_CARD_STEP]
//     3. This file will then compile and work automatically.
//
// Until then, all methods are stubbed with safe no-ops so the rest of the
// app compiles without errors.

// ignore_for_file: unused_import

import '../../data/local/isar/isar_service.dart';
import '../../core/utils/notification_helper.dart';

// ── STUB SECTION ─────────────────────────────────────────────────────────────
// After completing [REVIEW_CARD_STEP], delete the stub section and uncomment
// the full implementation section below.

class ReviewCardUsecase {
  /// Get cards due for review today (sorted by nextReviewDate ascending)
  Future<List<dynamic>> getTodaysReviewCards() async {
    // [REVIEW_CARD_STEP] Replace with real implementation below
    return [];
  }

  /// Create initial SM-2 cards when a chapter is first learned
  Future<void> createCardsForChapter({
    required String chapterName,
    required String subjectName,
    required String syllabusSource,
  }) async {
    // [REVIEW_CARD_STEP] Replace with real implementation below
  }

  /// Apply SM-2 review result and reschedule the card
  Future<void> markCardReviewed({
    required int cardId,
    required int performance, // 1 = Hard, 3 = Good, 5 = Easy
  }) async {
    // [REVIEW_CARD_STEP] Replace with real implementation below
  }

  /// Count of cards due today (for badge/notification)
  Future<int> getPendingReviewCount() async {
    // [REVIEW_CARD_STEP] Replace with real implementation below
    return 0;
  }

  /// Deactivate all cards for a chapter (when student resets progress)
  Future<void> deactivateCardsForChapter(String chapterName) async {
    // [REVIEW_CARD_STEP] Replace with real implementation below
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FULL IMPLEMENTATION — uncomment this entire section after [REVIEW_CARD_STEP]
// ═══════════════════════════════════════════════════════════════════════════════

/*

import 'package:isar/isar.dart';
import '../../data/local/isar/schemas/review_card_schema.dart';

class ReviewCardUsecase {
  final Isar _db = IsarService.db;

  // ── SM-2 constants ────────────────────────────────────────────────────────
  static const double _minEaseFactor = 1.3;
  static const double _maxEaseFactor = 2.8;
  static const int    _initialInterval = 1; // days

  // ── Get today's pending review cards ─────────────────────────────────────
  Future<List<ReviewCardSchema>> getTodaysReviewCards() async {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return await _db.reviewCardSchemas
        .filter()
        .isActiveEqualTo(true)
        .nextReviewDateLessThan(endOfDay.add(const Duration(seconds: 1)))
        .sortByNextReviewDate()
        .findAll();
  }

  // ── Create initial cards when chapter is first learned ───────────────────
  Future<void> createCardsForChapter({
    required String chapterName,
    required String subjectName,
    required String syllabusSource,
  }) async {
    // Idempotent: don't duplicate cards
    final existing = await _db.reviewCardSchemas
        .filter()
        .chapterNameEqualTo(chapterName)
        .isActiveEqualTo(true)
        .count();
    if (existing > 0) return;

    final now = DateTime.now();
    final cards = <ReviewCardSchema>[
      ReviewCardSchema.create(
        chapterName:    chapterName,
        subjectName:    subjectName,
        syllabusSource: syllabusSource,
        cardType:       'concept',
        front:          'Explain the core concept of "$chapterName"',
        back:           'Key ideas:\n• [Fill in the main theory]\n• [Fill in a key application]',
        nextReviewDate: now.add(const Duration(days: 1)),
      ),
      ReviewCardSchema.create(
        chapterName:    chapterName,
        subjectName:    subjectName,
        syllabusSource: syllabusSource,
        cardType:       'formula',
        front:          'What is the most important formula/technique in "$chapterName"?',
        back:           'Main formula:\n[Write the formula or key method here]',
        nextReviewDate: now.add(const Duration(days: 3)),
      ),
    ];

    await _db.writeTxn(() async {
      await _db.reviewCardSchemas.putAll(cards);
    });

    // Schedule review notification if there are pending cards
    final pending = await getPendingReviewCount();
    if (pending > 0) {
      await NotificationHelper.scheduleReviewReminder(pendingCards: pending);
    }
  }

  // ── SM-2 Review: update card and reschedule ───────────────────────────────
  // performance: 1 = Hard/Again, 3 = Good, 5 = Easy
  Future<void> markCardReviewed({
    required int cardId,
    required int performance,
  }) async {
    final card = await _db.reviewCardSchemas.get(cardId);
    if (card == null) return;

    final now = DateTime.now();
    final q = performance.clamp(0, 5); // quality in SM-2 range

    // SM-2 ease factor update: EF = EF + 0.1 - (5-q)*(0.08 + (5-q)*0.02)
    final double newEase = (card.easeFactor + 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
        .clamp(_minEaseFactor, _maxEaseFactor);

    int newInterval;
    int newRepetitions;

    if (q < 3) {
      // Failed review — reset to beginning
      newInterval    = _initialInterval;
      newRepetitions = 0;
    } else if (card.repetitions == 0) {
      // First successful review
      newInterval    = 1;
      newRepetitions = 1;
    } else if (card.repetitions == 1) {
      // Second successful review
      newInterval    = 6;
      newRepetitions = 2;
    } else {
      // Nth successful review: interval = previous_interval * EF
      newInterval    = (card.interval * newEase).round().clamp(1, 365);
      newRepetitions = card.repetitions + 1;
    }

    final nextDate = DateTime(
      now.year, now.month, now.day
    ).add(Duration(days: newInterval));

    await _db.writeTxn(() async {
      card
        ..repetitions    = newRepetitions
        ..interval       = newInterval
        ..easeFactor     = newEase
        ..lastReviewed   = now
        ..nextReviewDate = nextDate
        ..lastPerformance = performance;
      await _db.reviewCardSchemas.put(card);
    });

    // Reschedule notification for remaining cards
    final remaining = await getPendingReviewCount();
    if (remaining > 0) {
      await NotificationHelper.scheduleReviewReminder(pendingCards: remaining);
    }
  }

  // ── Count cards due today ─────────────────────────────────────────────────
  Future<int> getPendingReviewCount() async {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return await _db.reviewCardSchemas
        .filter()
        .isActiveEqualTo(true)
        .nextReviewDateLessThan(endOfDay.add(const Duration(seconds: 1)))
        .count();
  }

  // ── Deactivate cards for a chapter (progress reset) ──────────────────────
  Future<void> deactivateCardsForChapter(String chapterName) async {
    await _db.writeTxn(() async {
      final cards = await _db.reviewCardSchemas
          .filter()
          .chapterNameEqualTo(chapterName)
          .findAll();
      for (final card in cards) {
        card.isActive = false;
      }
      await _db.reviewCardSchemas.putAll(cards);
    });
  }

  // ── Get all cards for a chapter (for the chapter detail screen) ───────────
  Future<List<ReviewCardSchema>> getCardsForChapter(String chapterName) async {
    return await _db.reviewCardSchemas
        .filter()
        .chapterNameEqualTo(chapterName)
        .isActiveEqualTo(true)
        .findAll();
  }
}

*/
