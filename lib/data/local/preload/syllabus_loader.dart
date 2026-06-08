// lib/data/local/preload/syllabus_loader.dart
//
// ✅ Supports: jee_main, jee_advanced, neet, both, class12_boards, ca_final
// ✅ CA Final: ICAI NSET (New Scheme) — 6 papers, 2 groups, May/Nov attempts
//
// FIXED: ensureLoadedForExam() checks by syllabusSource (not total count).
// This is the method called during onboarding plan generation to guarantee
// the correct syllabus is in the DB regardless of prior state.
//
// loadIfNeeded() is now smarter — it delegates to ensureLoadedForExam() so
// a fresh install with no stored targetExam only loads JEE Main by default,
// but switching to any exam later always loads the right data.

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import '../isar/isar_service.dart';

// ── Asset paths ──────────────────────────────────────────────────────────────
const _jeeMainAsset = 'assets/syllabus/jee_main_2026.json';
const _jeeAdvAsset  = 'assets/syllabus/jee_advanced_2026.json';
const _neetAsset    = 'assets/syllabus/neet_ug_2026.json';
const _boardsAsset  = 'assets/syllabus/class12_boards_2026.json';
const _caFinalAsset = 'assets/syllabus/ca_final_2026.json';

// ── Syllabus source identifiers ──────────────────────────────────────────────
const kSourceJeeMain = 'jee_main';
const kSourceJeeAdv  = 'jee_advanced';
const kSourceNeet    = 'neet_ug';
const kSourceBoards  = 'class12_boards';
const kSourceCaFinal = 'ca_final';

class SyllabusLoader {
  // ── Maps exam → list of (asset, sourceId) pairs ──────────────────────────
  static List<(String asset, String source)> _sourcesFor(String? targetExam) {
    switch (targetExam) {
      case 'jee_advanced':
        return [(_jeeAdvAsset, kSourceJeeAdv)];
      case 'neet':
        return [(_neetAsset, kSourceNeet)];
      case 'both':
        // JEE Main + NEET together
        return [
          (_jeeMainAsset, kSourceJeeMain),
          (_neetAsset, kSourceNeet),
        ];
      case 'class12_boards':
        return [(_boardsAsset, kSourceBoards)];
      case 'ca_final':
        return [(_caFinalAsset, kSourceCaFinal)];
      case 'jee_main':
      default:
        return [(_jeeMainAsset, kSourceJeeMain)];
    }
  }

  // ── PUBLIC: Guaranteed load for a specific exam ──────────────────────────
  // Unlike loadIfNeeded, this checks per-syllabusSource, not total count.
  // Call this from the generating-plan screen to ensure the right syllabus
  // is in the DB before plan generation runs.
  static Future<void> ensureLoadedForExam(String? targetExam) async {
    final db = IsarService.db;
    final needed = _sourcesFor(targetExam);

    for (final entry in needed) {
      final count = await db.chapterSchemas
          .filter()
          .syllabusSourceEqualTo(entry.$2)
          .count();

      if (count == 0) {
        // This source has never been loaded — seed it now
        await _loadSource(entry.$1, entry.$2);
      }
    }

    // Ensure achievements are seeded (idempotent)
    final achCount = await db.achievementSchemas.count();
    if (achCount == 0) await _seedAchievements();
  }

  // ── PUBLIC: Initial seed on first launch ─────────────────────────────────
  // No-op if the target exam's chapters already exist.
  static Future<void> loadIfNeeded({String? targetExam}) async {
    await ensureLoadedForExam(targetExam);
  }

  // ── PUBLIC: Safe metadata reload — student progress is NEVER touched ─────
  static Future<SafeReloadResult> safeReload({String? targetExam}) async {
    int added   = 0;
    int updated = 0;
    final db    = IsarService.db;

    for (final entry in _sourcesFor(targetExam)) {
      final raw  = await rootBundle.loadString(entry.$1);
      final json = jsonDecode(raw) as Map<String, dynamic>;

      for (final subject in (json['subjects'] as List)) {
        final subjectName = subject['name'] as String;
        final paperNo = subject['paperNo'] as int? ?? 0;
        for (final ch in (subject['chapters'] as List)) {
          final name   = ch['name']   as String;
          final source = entry.$2;

          await db.writeTxn(() async {
            final existing = await db.chapterSchemas
                .filter()
                .nameEqualTo(name)
                .syllabusSourceEqualTo(source)
                .findFirst();

            if (existing == null) {
              final newCh = ChapterSchema()
                ..subjectName    = subjectName
                ..syllabusSource = source
                ..name           = name
                ..classLevel     = (ch['class'] as int?) ?? paperNo
                ..estimatedHours = (ch['estimatedHours'] as num).toDouble()
                ..weightage      = (ch['weightage'] as num).toDouble()
                ..difficulty     = ch['difficulty'] as int
                ..pyqCount       = ch['pyqCount']   as int
                ..tags           = List<String>.from(ch['tags'] as List)
                ..status         = 'not_started';
              await db.chapterSchemas.put(newCh);
              added++;
            } else {
              existing.estimatedHours = (ch['estimatedHours'] as num).toDouble();
              existing.weightage      = (ch['weightage'] as num).toDouble();
              existing.difficulty     = ch['difficulty'] as int;
              existing.pyqCount       = ch['pyqCount']   as int;
              existing.tags           = List<String>.from(ch['tags'] as List);
              await db.chapterSchemas.put(existing);
              updated++;
            }
          });
        }
      }
    }

    return SafeReloadResult(added: added, updated: updated);
  }

  // ── PRIVATE: Full load for initial seed ──────────────────────────────────
  static Future<void> _loadSource(String asset, String source) async {
    final raw      = await rootBundle.loadString(asset);
    final json     = jsonDecode(raw) as Map<String, dynamic>;
    final chapters = <ChapterSchema>[];

    for (final subject in (json['subjects'] as List)) {
      final subjectName = subject['name'] as String;
      final paperNo = subject['paperNo'] as int? ?? 0;
      for (final ch in (subject['chapters'] as List)) {
        chapters.add(ChapterSchema()
          ..subjectName    = subjectName
          ..syllabusSource = source
          ..name           = ch['name']          as String
          ..classLevel     = (ch['class'] as int?) ?? paperNo
          ..estimatedHours = (ch['estimatedHours'] as num).toDouble()
          ..weightage      = (ch['weightage']      as num).toDouble()
          ..difficulty     = ch['difficulty']      as int
          ..pyqCount       = ch['pyqCount']        as int
          ..tags           = List<String>.from(ch['tags'] as List)
          ..status         = 'not_started'
          ..hoursSpent     = 0.0
          ..revisionCount  = 0);
      }
    }

    final db = IsarService.db;
    await db.writeTxn(() async => db.chapterSchemas.putAll(chapters));
  }

  // ── PRIVATE: Achievement badges seed ─────────────────────────────────────
  static Future<void> _seedAchievements() async {
    final db = IsarService.db;
    final badges = [
      _badge('first_log',   '🌱', 'First Step',        'Log your very first study session'),
      _badge('streak_3',    '🔥', '3-Day Streak',       'Study 3 days in a row'),
      _badge('streak_7',    '⚡', 'Week Warrior',        'Study 7 days in a row'),
      _badge('streak_14',   '💪', 'Fortnight Focus',    'Study 14 days in a row'),
      _badge('streak_30',   '🏆', 'Monthly Master',     'Study 30 days in a row'),
      _badge('hours_10',    '⏱️', '10 Hours',           'Study 10 total hours'),
      _badge('hours_50',    '📚', '50 Hours',           'Study 50 total hours'),
      _badge('hours_100',   '💯', 'Century Club',       'Study 100 total hours'),
      _badge('hours_250',   '🎖️', 'Scholar',            'Study 250 total hours'),
      _badge('hours_500',   '👑', 'Legend',             'Study 500 total hours'),
      _badge('pyq_10',      '📝', 'PYQ Starter',        'Solve 10 past year questions'),
      _badge('pyq_50',      '📝', 'PYQ Pro',            'Solve 50 past year questions'),
      _badge('pyq_100',     '🎯', 'PYQ Master',         'Solve 100 past year questions'),
      _badge('mastery_10',  '🌟', 'Chapter Champion',   'Reach Test Ready level in 10 chapters'),
      _badge('ai_report',   '🤖', 'AI Insight',         'Generate your first AI analysis'),
      _badge('ca_group1',   '📊', 'Group I Cleared',    'Complete all Group I chapters (CA Final)'),
      _badge('ca_group2',   '🏛️', 'Group II Cleared',   'Complete all Group II chapters (CA Final)'),
    ];
    await db.writeTxn(() async => db.achievementSchemas.putAll(badges));
  }

  static AchievementSchema _badge(
    String id, String emoji, String title, String desc,
  ) =>
      AchievementSchema()
        ..badgeId     = id
        ..emoji       = emoji
        ..title       = title
        ..description = desc
        ..unlocked    = false;
}

class SafeReloadResult {
  final int added;
  final int updated;
  const SafeReloadResult({required this.added, required this.updated});
  String get message =>
      '$added new chapter(s) added, $updated updated. Your progress is intact.';
}
