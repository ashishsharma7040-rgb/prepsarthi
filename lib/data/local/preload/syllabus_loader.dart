// lib/data/local/preload/syllabus_loader.dart
//
// ✅ FIX: forceReload now does a SAFE reload — it updates chapter metadata
// (estimatedHours, weightage, difficulty, pyqCount) WITHOUT wiping mastery,
// hoursSpent, revisionCount, or any student progress.
// Only the new "Clear All Study Data" button in Settings does a full wipe.

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import '../isar/isar_service.dart';
import '../isar/schemas/chapter_schema.dart';
import '../isar/schemas/achievement_schema.dart';

const _jeeMainAsset     = 'assets/syllabus/jee_main_2026.json';
const _jeeAdvAsset      = 'assets/syllabus/jee_advanced_2026.json';
const _neetAsset        = 'assets/syllabus/neet_ug_2026.json';

class SyllabusLoader {
  /// Seeds on first launch — no-op if chapters already exist.
  /// Loads only the syllabus relevant to the user's target exam.
  static Future<void> loadIfNeeded({String? targetExam}) async {
    final db = IsarService.db;
    final count = await db.chapterSchemas.count();
    if (count > 0) return;

    // Load syllabus assets based on the user's exam target.
    // Defaults to JEE Main + NEET if target is unknown.
    switch (targetExam) {
      case 'jee_advanced':
        await _loadSource(_jeeAdvAsset, 'jee_advanced');
        break;
      case 'neet':
        await _loadSource(_neetAsset, 'neet_ug');
        break;
      case 'both':
        await _loadSource(_jeeMainAsset, 'jee_main');
        await _loadSource(_neetAsset, 'neet_ug');
        break;
      case 'class12_boards':
        // Class 12 Boards uses JEE Main syllabus as the closest match
        // until a dedicated boards asset is created.
        await _loadSource(_jeeMainAsset, 'jee_main');
        break;
      case 'jee_main':
      default:
        await _loadSource(_jeeMainAsset, 'jee_main');
        break;
    }
    await _seedAchievements();
  }

  /// ✅ SAFE reload — updates metadata only, NEVER wipes student progress.
  /// Called from Settings → "Reload Syllabus" button.
  /// Adds new chapters if curriculum was expanded; existing progress preserved.
  static Future<SafeReloadResult> safeReload({String? targetExam}) async {
    int added = 0;
    int updated = 0;
    final db = IsarService.db;

    final List<(String, String)> sources;
    switch (targetExam) {
      case 'jee_advanced':
        sources = [(_jeeAdvAsset, 'jee_advanced')];
        break;
      case 'neet':
        sources = [(_neetAsset, 'neet_ug')];
        break;
      case 'both':
        sources = [(_jeeMainAsset, 'jee_main'), (_neetAsset, 'neet_ug')];
        break;
      case 'class12_boards':
        sources = [(_jeeMainAsset, 'jee_main')];
        break;
      case 'jee_main':
      default:
        sources = [(_jeeMainAsset, 'jee_main')];
        break;
    }

    for (final entry in sources) {
      final raw  = await rootBundle.loadString(entry.$1);
      final json = jsonDecode(raw) as Map<String, dynamic>;

      for (final subject in (json['subjects'] as List)) {
        final subjectName = subject['name'] as String;
        for (final ch in (subject['chapters'] as List)) {
          final name   = ch['name'] as String;
          final source = entry.$2;

          await db.writeTxn(() async {
            final existing = await db.chapterSchemas
                .filter()
                .nameEqualTo(name)
                .syllabusSourceEqualTo(source)
                .findFirst();

            if (existing == null) {
              // New chapter added to curriculum
              final newChapter = ChapterSchema()
                ..subjectName    = subjectName
                ..syllabusSource = source
                ..name           = name
                ..classLevel     = ch['class'] as int
                ..estimatedHours = (ch['estimatedHours'] as num).toDouble()
                ..weightage      = (ch['weightage'] as num).toDouble()
                ..difficulty     = ch['difficulty'] as int
                ..pyqCount       = ch['pyqCount'] as int
                ..tags           = List<String>.from(ch['tags'] as List)
                ..status         = 'not_started';
              await db.chapterSchemas.put(newChapter);
              added++;
            } else {
              // ✅ Update metadata only — student progress UNTOUCHED
              existing.estimatedHours = (ch['estimatedHours'] as num).toDouble();
              existing.weightage      = (ch['weightage'] as num).toDouble();
              existing.difficulty     = ch['difficulty'] as int;
              existing.pyqCount       = ch['pyqCount'] as int;
              existing.tags           = List<String>.from(ch['tags'] as List);
              // masteryLevel, hoursSpent, revisionCount, testAttempts → unchanged
              await db.chapterSchemas.put(existing);
              updated++;
            }
          });
        }
      }
    }
    return SafeReloadResult(added: added, updated: updated);
  }

  // ── Private: initial full load ────────────────────────────────────────────
  static Future<void> _loadSource(String asset, String source) async {
    final raw      = await rootBundle.loadString(asset);
    final json     = jsonDecode(raw) as Map<String, dynamic>;
    final chapters = <ChapterSchema>[];

    for (final subject in (json['subjects'] as List)) {
      final subjectName = subject['name'] as String;
      for (final ch in (subject['chapters'] as List)) {
        chapters.add(ChapterSchema()
          ..subjectName    = subjectName
          ..syllabusSource = source
          ..name           = ch['name'] as String
          ..classLevel     = ch['class'] as int
          ..estimatedHours = (ch['estimatedHours'] as num).toDouble()
          ..weightage      = (ch['weightage'] as num).toDouble()
          ..difficulty     = ch['difficulty'] as int
          ..pyqCount       = ch['pyqCount'] as int
          ..tags           = List<String>.from(ch['tags'] as List)
          ..status         = 'not_started'
          ..hoursSpent     = 0.0
          ..revisionCount  = 0);
      }
    }

    final db = IsarService.db;
    await db.writeTxn(() async => db.chapterSchemas.putAll(chapters));
  }

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
      _badge('hours_250',   '🎖️', 'Scholar',           'Study 250 total hours'),
      _badge('hours_500',   '👑', 'Legend',             'Study 500 total hours'),
      _badge('pyq_10',      '📝', 'PYQ Starter',        'Solve 10 past year questions'),
      _badge('pyq_50',      '📝', 'PYQ Pro',            'Solve 50 past year questions'),
      _badge('pyq_100',     '🎯', 'PYQ Master',         'Solve 100 past year questions'),
      _badge('mastery_10',  '🌟', 'Chapter Champion',   'Reach Test Ready level in 10 chapters'),
      _badge('ai_report',   '🤖', 'AI Insight',         'Generate your first AI analysis'),
    ];
    await db.writeTxn(() async => db.achievementSchemas.putAll(badges));
  }

  static AchievementSchema _badge(String id, String emoji, String title, String desc) =>
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
  String get message => '$added new chapter(s) added, $updated updated. Your progress is intact.';
}
