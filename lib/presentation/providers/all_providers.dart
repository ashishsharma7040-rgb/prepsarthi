// lib/presentation/providers/all_providers.dart
//
// ✅ FIX (Improvement #2 / Audit §7):
//   SettingsState + SettingsNotifier have been extracted to settings_provider.dart.
//   This file re-exports that module for 100% backward compatibility — no
//   import changes needed anywhere else in the codebase.
//
//   Next step (future refactor): extract AuthNotifier → auth_provider.dart,
//   PlanNotifier → plan_provider.dart, SubscriptionNotifier → subscription_provider.dart.
//   Each is independent and can be extracted without breaking any screens.
//
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../data/local/isar/isar_service.dart';
import '../../core/utils/notification_helper.dart';
import '../../core/constants/exam_dates.dart';
import '../../data/content/exam_registry.dart';
import '../../data/local/chapter_resolver.dart';
import '../../domain/usecases/generate_plan_usecase.dart';
import '../../domain/usecases/streak_usecase.dart';

// ── Re-export extracted providers ─────────────────────────────────────────
// Settings is now its own file. Export it here so all existing imports
// of all_providers.dart still resolve SettingsState / settingsProvider.
export 'settings_provider.dart';

// ── SettingsState / SettingsNotifier / settingsProvider ─────────────────────
// Moved to settings_provider.dart — re-exported via `export` above.

// ═══════════════════════════════════════════════════════════════════════════
// AUTH PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

class AuthState {
  final UserSchema? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isLoggedIn => user != null;
  bool get onboardingComplete => user?.onboardingComplete ?? false;
  bool get isPremium => user?.isPremium ?? false;
  String get displayName => user?.displayName ?? '';

  AuthState copyWith({UserSchema? user, bool? isLoading, String? error}) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _loadLocalUser();
    return const AuthState(isLoading: true);
  }

  Future<void> _loadLocalUser() async {
    if (!IsarService.isReady) {
      debugPrint('[Auth] Isar not ready, skipping local user load');
      state = const AuthState(isLoading: false);
      return;
    }

    try {
      final db = IsarService.db;
      final user = await db.userSchemas.where().findFirst();
      state = AuthState(user: user, isLoading: false);
    } catch (error) {
      debugPrint('[Auth] local user load failed: $error');
      state = const AuthState(isLoading: false);
    }
  }

  Future<void> saveUser(UserSchema user) async {
    final db = IsarService.db;
    await db.writeTxn(() async => db.userSchemas.put(user));
    state = state.copyWith(user: user, isLoading: false);
  }

  Future<void> updateOnboarding({
    required String targetExam,
    required String examYear,
    required double dailyHours,
    required DateTime examDate,
    String? caAttempt,
  }) async {
    final db = IsarService.db;
    final user = state.user;
    if (user == null) return;
    user.targetExam = targetExam;
    user.examYear = examYear;
    user.dailyStudyHours = dailyHours;
    user.examDate = examDate;
    user.onboardingComplete = true;
    user.planStartDate = DateTime.now();
    // ✅ Persist CA Final attempt so it survives app restarts.
    // ICAI officially holds CA Final twice yearly: May (week 2) & November (week 2).
    if (targetExam == 'ca_final') {
      user.caAttempt = caAttempt ?? 'may';
    } else {
      user.caAttempt = null;
    }
    await db.writeTxn(() async => db.userSchemas.put(user));
    state = state.copyWith(user: user);
  }

  /// DATA-5 FIX: delegates to the single streak authority. The previous body
  /// was a SECOND streak implementation that raced with the one inside
  /// logSession() — the double-update bug. StreakUseCase is idempotent
  /// same-day, so any legacy caller of this method is now harmless.
  /// Screens should NOT call this; logSession() handles streaks itself.
  Future<void> updateStreak() async {
    await StreakUseCase.touchToday();
    await _loadLocalUser(); // refresh state.user with the new streak values
  }

  Future<void> signOut() async {
    state = const AuthState(isLoading: false);
  }

  Future<void> reload() => _loadLocalUser();

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// ═══════════════════════════════════════════════════════════════════════════
// ONBOARDING PROVIDER — holds in-progress onboarding selections
// ═══════════════════════════════════════════════════════════════════════════

class OnboardingState {
  final String? targetExam;
  final String? examYear;
  // ✅ CA Final: attempt = 'may' | 'november' | 'january' | 'september'
  final String? caAttempt;
  final double dailyHours;
  final List<DateTime> blackoutDates;

  const OnboardingState({
    this.targetExam,
    this.examYear,
    this.caAttempt,
    this.dailyHours = 6.0,
    this.blackoutDates = const [],
  });

  DateTime? get examDate {
    if (examYear == null) return null;
    final year = int.tryParse(examYear!);
    if (year == null) return null;
    // EXAM-2/EXAM-5 FIX: routed through ExamDates — previously this getter and
    // the onboarding screen disagreed (Mar 1 vs Feb 28; May/Nov vs Jan/May/Sep).
    return ExamDates.examDate(targetExam, year, caAttempt: caAttempt);
  }

  OnboardingState copyWith({
    String? targetExam,
    String? examYear,
    String? caAttempt,
    double? dailyHours,
    List<DateTime>? blackoutDates,
  }) =>
      OnboardingState(
        targetExam: targetExam ?? this.targetExam,
        examYear: examYear ?? this.examYear,
        caAttempt: caAttempt ?? this.caAttempt,
        dailyHours: dailyHours ?? this.dailyHours,
        blackoutDates: blackoutDates ?? this.blackoutDates,
      );
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setTarget(String exam) => state = state.copyWith(targetExam: exam);
  void setYear(String year) => state = state.copyWith(examYear: year);
  void setCaAttempt(String attempt) =>
      state = state.copyWith(caAttempt: attempt);
  void setHours(double h) => state = state.copyWith(dailyHours: h);

  /// Persists the holiday / blackout dates selected on the onboarding screen.
  void setBlackoutDates(List<DateTime> dates) =>
      state = state.copyWith(blackoutDates: dates);
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
        OnboardingNotifier.new);

// ═══════════════════════════════════════════════════════════════════════════
// PLAN PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

class PlanState {
  final List<ChapterSchema> chapters;
  final List<PlanEntrySchema> todayEntries;
  final List<PlanEntrySchema> weekEntries;
  final bool isLoading;
  final String? error;

  const PlanState({
    this.chapters = const [],
    this.todayEntries = const [],
    this.weekEntries = const [],
    this.isLoading = false,
    this.error,
  });

  bool get hasPlan => weekEntries.isNotEmpty;
  bool get hasChapters => chapters.isNotEmpty;

  PlanState copyWith({
    List<ChapterSchema>? chapters,
    List<PlanEntrySchema>? todayEntries,
    List<PlanEntrySchema>? weekEntries,
    bool? isLoading,
    String? error,
  }) =>
      PlanState(
        chapters: chapters ?? this.chapters,
        todayEntries: todayEntries ?? this.todayEntries,
        weekEntries: weekEntries ?? this.weekEntries,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class PlanNotifier extends Notifier<PlanState> {
  @override
  PlanState build() {
    _load();
    return const PlanState(isLoading: true);
  }

  Future<void> _load() async {
    final db = IsarService.db;
    final user = await db.userSchemas.where().findFirst();
    if (user == null) {
      state = const PlanState();
      return;
    }

    // FIXED: 'both' loads jee_main + neet_ug combined.
    // All other exams load their specific source.
    final List<ChapterSchema> chapters;
    if (user.targetExam == 'both') {
      final jee = await db.chapterSchemas
          .filter()
          .syllabusSourceEqualTo('jee_main')
          .findAll();
      final neet = await db.chapterSchemas
          .filter()
          .syllabusSourceEqualTo('neet_ug')
          .findAll();
      chapters = [...jee, ...neet];
    } else {
      final source = _syllabusSource(user.targetExam);
      chapters = await db.chapterSchemas
          .filter()
          .syllabusSourceEqualTo(source)
          .findAll();
    }

    final today = _dayOnly(DateTime.now());

    // DATA-1/DATA-4 FIX: only show THIS user's stream(s). Entries created
    // before the chapterKey migration have syllabusSource '' — keep showing
    // those (legacy tolerance) so nobody loses their plan during upgrade.
    final userSources = ChapterResolver.sourcesForExam(user.targetExam);
    bool inStream(PlanEntrySchema e) =>
        e.syllabusSource.isEmpty || userSources.contains(e.syllabusSource);

    final todayEntriesRaw = await db.planEntrySchemas
        .filter()
        .plannedDateEqualTo(today)
        .sortByOrderIndex()
        .findAll();
    final todayEntries = todayEntriesRaw.where(inStream).toList();

    final weekEnd = today.add(const Duration(days: 7));
    final weekEntriesRaw = await db.planEntrySchemas
        .filter()
        .plannedDateGreaterThan(today.subtract(const Duration(days: 1)))
        .and()
        .plannedDateLessThan(weekEnd)
        .sortByPlannedDate()
        .findAll();
    final weekEntries = weekEntriesRaw.where(inStream).toList();

    state = PlanState(
      chapters: chapters,
      todayEntries: todayEntries,
      weekEntries: weekEntries,
      isLoading: false,
    );
  }

  // Generate the full plan from scratch
  // ✅ UPDATED: accepts syllabusCompletionTargetDate, paceMode, weakSubjectBoost
  // so the GeneratingPlanScreen can pass fine-tuned options through.
  Future<void> generatePlan({
    required DateTime examDate,
    required double dailyHours,
    required List<DateTime> blackoutDates,
    DateTime? syllabusCompletionTargetDate,
    String paceMode = 'balanced',
    Map<String, double> weakSubjectBoost = const {},
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // DATA-6 FIX: read the user's exam from the user record and pass it
      // explicitly, so the planner never infers the wrong exam from
      // exam-switch debris left in the chapters table.
      final db0 = IsarService.db;
      final user0 = await db0.userSchemas.where().findFirst();
      await GeneratePlanUseCase().execute(
        examDate: examDate,
        dailyStudyHours: dailyHours,
        chapters: state.chapters,
        blackoutDates: blackoutDates,
        syllabusCompletionTargetDate: syllabusCompletionTargetDate,
        paceMode: paceMode,
        weakSubjectBoost: weakSubjectBoost,
        examType: user0?.targetExam,
      );
      // Mark plan generated timestamp
      final db = IsarService.db;
      final settings = await db.userSettingsSchemas.where().findFirst() ??
          UserSettingsSchema();
      settings.lastPlanGeneratedAt = DateTime.now();
      await db.writeTxn(() async => db.userSettingsSchemas.put(settings));
      await _load();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Mark a plan entry done/skipped — and keep chapter progress in sync.
  // This is the SINGLE place where ticking off a plan entry propagates to the
  // chapter's hoursSpent so the Syllabus Progress ring updates immediately.
  Future<void> markPlanEntryStatus(
      Id entryId, String status, double actualHours) async {
    final db = IsarService.db;
    final entry = await db.planEntrySchemas.get(entryId);
    if (entry == null) return;

    final wasAlreadyDone = entry.status == 'done' ||
        entry.status == 'completed' ||
        entry.status == 'skipped';
    entry.status = status;
    entry.actualHours = actualHours;
    await db.writeTxn(() async => db.planEntrySchemas.put(entry));

    // ── Propagate hours to ChapterSchema so progress bars update ────────────
    // Only add hours when newly completing (not if already done or skipping)
    final isCompleting =
        (status == 'done' || status == 'completed') && !wasAlreadyDone;
    if (isCompleting && entry.chapterName.isNotEmpty) {
      // DATA-1 FIX: resolve by the entry's chapterKey (stream-aware), not a
      // raw name lookup that hit a random copy of colliding names.
      final chapter = await ChapterResolver.find(
        db,
        chapterKey: entry.chapterKey,
        chapterName: entry.chapterName,
      );
      if (chapter != null) {
        chapter.hoursSpent += actualHours;
        chapter.lastStudiedDate = DateTime.now();

        // Auto-upgrade mastery: if hours now ≥ estimatedHours and mastery < 3
        // bump to "Questions Practiced" level — the student finished the block
        if (chapter.estimatedHours > 0 &&
            chapter.hoursSpent >= chapter.estimatedHours * 0.85 &&
            chapter.masteryLevel < 3) {
          chapter.masteryLevel = 3; // Questions Practiced
          chapter.status = 'learned';
          chapter.firstLearnedDate ??= DateTime.now();
          {
            // Auto-schedule spaced revisions when chapter completes
            await GeneratePlanUseCase.scheduleRevisions(
              chapterName: chapter.name,
              subjectName: chapter.subjectName,
              learnedDate: DateTime.now(),
              estimatedHours: chapter.estimatedHours,
              chapterKey: chapter.chapterKey,
              syllabusSource: chapter.syllabusSource,
            );
          }
        }

        await db.writeTxn(() async => db.chapterSchemas.put(chapter));
      }
    }

    await _load();
  }

  // Mark a chapter status and trigger revision scheduling if learned.
  // Also syncs masteryLevel so both the legacy status field AND the 8-level
  // mastery system stay consistent — previously they diverged.
  // DATA-1 FIX: stream-aware resolution; pass [chapterKey] when available.
  Future<void> markChapterStatus(String chapterName, String status,
      {String? chapterKey}) async {
    final db = IsarService.db;
    final chapter = await ChapterResolver.find(
      db,
      chapterKey: chapterKey,
      chapterName: chapterName,
    );
    if (chapter == null) return;
    chapter.status = status;
    chapter.lastStudiedDate = DateTime.now();

    // Keep masteryLevel in sync with status
    if (status == 'learned' && chapter.masteryLevel < 3) {
      chapter.masteryLevel = 3; // Questions Practiced
    } else if (status == 'revised' && chapter.masteryLevel < 5) {
      chapter.masteryLevel = 5; // Revision 1 Done
    } else if (status == 'tested' && chapter.masteryLevel < 7) {
      chapter.masteryLevel = 7; // Test Ready
    }

    if (status == 'learned' && chapter.firstLearnedDate == null) {
      chapter.firstLearnedDate = DateTime.now();
      // Auto-schedule spaced revisions
      await GeneratePlanUseCase.scheduleRevisions(
        chapterName: chapter.name,
        subjectName: chapter.subjectName,
        learnedDate: DateTime.now(),
        estimatedHours: chapter.estimatedHours,
        chapterKey: chapter.chapterKey,
        syllabusSource: chapter.syllabusSource,
      );
    }
    await db.writeTxn(() async => db.chapterSchemas.put(chapter));
    await _load();
  }

  Future<void> refresh() => _load();

  /// Fetch plan entries for any arbitrary week (used by weekly plan screen
  /// when the user navigates to past/future weeks with _weekOffset).
  Future<List<PlanEntrySchema>> fetchEntriesForWeek(DateTime weekStart) async {
    final db = IsarService.db;
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 7));
    return db.planEntrySchemas
        .filter()
        .plannedDateGreaterThan(start.subtract(const Duration(days: 1)))
        .and()
        .plannedDateLessThan(end)
        .sortByPlannedDate()
        .findAll();
  }

  /// Check if any plan entries exist at all (not just this week).
  Future<bool> hasPlanEntries() async {
    final db = IsarService.db;
    final count = await db.planEntrySchemas.count();
    return count > 0;
  }

  // ── Manual Plan Editing ──────────────────────────────────────────────────
  // Powers the full manual-edit flow: rearrange sessions within a day,
  // change hours/date of any entry, or remove an entry entirely.
  // All changes persist to Isar and invalidate in-memory state so every
  // listening widget re-renders immediately.

  /// Reorder two entries WITHIN the same day by swapping their orderIndex values.
  /// Called after a ReorderableListView drag-and-drop completes.
  Future<void> reorderDayEntries(
      List<PlanEntrySchema> dayEntries, int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    final db = IsarService.db;

    final reordered = List<PlanEntrySchema>.from(dayEntries);
    final moved = reordered.removeAt(oldIndex);
    final insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex;
    reordered.insert(insertAt, moved);

    await db.writeTxn(() async {
      for (int i = 0; i < reordered.length; i++) {
        reordered[i].orderIndex = i;
        await db.planEntrySchemas.put(reordered[i]);
      }
    });
    await _load();
  }

  /// Edit a plan entry's date and/or planned hours in place.
  /// Moving to a different date fixes its orderIndex on the target day.
  Future<void> editPlanEntry(
      Id entryId, {DateTime? newDate, double? newHours}) async {
    final db = IsarService.db;
    final entry = await db.planEntrySchemas.get(entryId);
    if (entry == null) return;

    if (newDate != null) {
      final day = DateTime(newDate.year, newDate.month, newDate.day);
      final maxOrder = await db.planEntrySchemas
          .filter()
          .plannedDateEqualTo(day)
          .sortByOrderIndexDesc()
          .findFirst();
      entry.plannedDate = day;
      entry.orderIndex = (maxOrder?.orderIndex ?? -1) + 1;
    }
    if (newHours != null) entry.plannedHours = newHours.clamp(0.5, 8.0);

    await db.writeTxn(() async => db.planEntrySchemas.put(entry));
    await _load();
  }

  /// Permanently delete a plan entry.
  Future<void> deletePlanEntry(Id entryId) async {
    final db = IsarService.db;
    await db.writeTxn(() async => db.planEntrySchemas.delete(entryId));
    await _load();
  }

  /// TASK 9: Inserts a quick 1.5-hour plan entry for the next available slot
  /// this week for the given chapter/subject.
  Future<void> addQuickEntry(
      String chapterName, String subjectName, {double hours = 1.5}) async {
    final db = IsarService.db;
    final now = DateTime.now();
    final today = _dayOnly(now);
    final weekEnd = today.add(const Duration(days: 7));

    // Find the first day this week that doesn't already have 3+ entries
    DateTime? targetDate;
    for (int i = 0; i < 7; i++) {
      final candidate = today.add(Duration(days: i));
      if (candidate.isAfter(weekEnd)) break;
      final count = await db.planEntrySchemas
          .filter()
          .plannedDateEqualTo(candidate)
          .count();
      if (count < 3) {
        targetDate = candidate;
        break;
      }
    }
    targetDate ??= today; // fallback: add to today

    final maxOrder = await db.planEntrySchemas
        .filter()
        .plannedDateEqualTo(targetDate)
        .sortByOrderIndexDesc()
        .findFirst();
    final orderIndex = (maxOrder?.orderIndex ?? -1) + 1;

    final entry = PlanEntrySchema()
      ..chapterName = chapterName
      ..subjectName = subjectName
      ..plannedDate = targetDate
      ..plannedHours = hours
      ..orderIndex = orderIndex
      ..isRevision = false
      ..status = 'pending';

    await db.writeTxn(() async => db.planEntrySchemas.put(entry));
    await _load();
  }

  /// Add a study session on a SPECIFIC date (used by Add Session sheet)
  Future<void> addSessionOnDate({
    required String chapterName,
    required String subjectName,
    required double hours,
    required DateTime date,
  }) async {
    final db = IsarService.db;
    final dayKey = _dayOnly(date);

    final maxOrder = await db.planEntrySchemas
        .filter()
        .plannedDateEqualTo(dayKey)
        .sortByOrderIndexDesc()
        .findFirst();
    final orderIndex = (maxOrder?.orderIndex ?? -1) + 1;

    final entry = PlanEntrySchema()
      ..chapterName = chapterName
      ..subjectName = subjectName
      ..plannedDate = dayKey
      ..plannedHours = hours.clamp(0.5, 8.0)
      ..orderIndex = orderIndex
      ..isRevision = false
      ..status = 'pending';

    await db.writeTxn(() async => db.planEntrySchemas.put(entry));
    await _load();
  }

  // FIXED: class12_boards now correctly maps to 'class12_boards' source.
  // 'both' is handled in _load() directly (loads two sources) — this method
  // is only used as a fallback; 'both' shouldn't reach here.
  // PART 2A: delegates to ExamRegistry — the single source of truth.
  String _syllabusSource(String? exam) => ExamRegistry.primarySourceOf(exam);

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

final planProvider =
    NotifierProvider<PlanNotifier, PlanState>(PlanNotifier.new);

// ═══════════════════════════════════════════════════════════════════════════
// STUDY LOG PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

class StudyLogNotifier extends Notifier<List<StudyLogSchema>> {
  @override
  List<StudyLogSchema> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final db = IsarService.db;
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final logs = await db.studyLogSchemas
        .filter()
        .timestampGreaterThan(cutoff)
        .sortByTimestampDesc()
        .findAll();
    state = logs;
  }

  Future<void> logSession({
    required String chapterName,
    required String subjectName,
    required double hours,
    required String activityTag,
    String? notes,
    bool isPomodoro = false,
    int pomodoroSessions = 0,
    String? chapterKey, // DATA-1: pass when the caller has it (plan entries)
  }) async {
    final db = IsarService.db;

    // DATA-1 FIX: resolve the chapter stream-aware BEFORE writing the log,
    // so the log row carries the correct identity. The old code did a raw
    // nameEqualTo lookup — a coin flip for the 37 colliding chapter names.
    final chapter = await ChapterResolver.find(
      db,
      chapterKey: chapterKey,
      chapterName: chapterName,
    );

    final log = StudyLogSchema()
      ..chapterKey = chapter?.chapterKey ?? (chapterKey ?? '')
      ..syllabusSource = chapter?.syllabusSource ?? ''
      ..chapterName = chapterName
      ..subjectName = subjectName
      ..hoursStudied = hours
      ..activityTag = activityTag
      ..timestamp = DateTime.now()
      ..notes = notes
      ..isPomodoro = isPomodoro
      ..pomodoroSessions = pomodoroSessions;

    await db.writeTxn(() async => db.studyLogSchemas.put(log));

    // Update chapter hours AND keep status/mastery in sync
    // (chapter was resolved stream-aware above)
    if (chapter != null) {
      chapter.hoursSpent += hours;
      chapter.lastStudiedDate = DateTime.now();
      if (activityTag == 'revised') {
        chapter.revisionCount++;
        // Sync mastery: revised ≥ level 5
        if (chapter.masteryLevel < 5) chapter.masteryLevel = 5;
        if (chapter.status != 'revised' && chapter.status != 'tested') {
          chapter.status = 'revised';
        }
      }
      if (activityTag == 'tested') {
        // Sync mastery: tested = level 7
        if (chapter.masteryLevel < 7) chapter.masteryLevel = 7;
        chapter.status = 'tested';
        chapter.testAttempts++;
      }
      if (activityTag == 'learned' && chapter.status == 'not_started') {
        // First learn — advance to at least masteryLevel 3
        if (chapter.masteryLevel < 3) chapter.masteryLevel = 3;
        chapter.status = 'learned';
        chapter.firstLearnedDate ??= DateTime.now();
      }
      if (activityTag == 'pyq') {
        // Bump PYQ progress tracker
        if (chapter.pyqProgress < 4) chapter.pyqProgress++;
        if (chapter.masteryLevel < 4) chapter.masteryLevel = 4; // PYQs Done
      }
      await db.writeTxn(() async => db.chapterSchemas.put(chapter));
    }

    await _load();
    // Notify planProvider to reload so Syllabus Progress ring updates immediately
    ref.invalidate(planProvider);
    await _checkAchievements();
    // DATA-5 FIX: ONE streak authority. The previous inline implementation
    // raced with AuthNotifier.updateStreak() (called from screens) — the
    // double-update bug. StreakUseCase.touchToday() is idempotent same-day.
    await StreakUseCase.touchToday();
  }

  Future<List<StudyLogSchema>> getLogsForDate(DateTime date) async {
    final db = IsarService.db;
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return db.studyLogSchemas
        .filter()
        .timestampGreaterThan(start.subtract(const Duration(seconds: 1)))
        .and()
        .timestampLessThan(end)
        .findAll();
  }

  double hoursForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return state
        .where((l) => l.timestamp.isAfter(start) && l.timestamp.isBefore(end))
        .fold(0.0, (s, l) => s + l.hoursStudied);
  }

  /// Returns hours studied per day for the last N days (keyed by day offset 0=today)
  Map<String, double> weekHeatmapData() {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final result = <String, double>{
      for (final d in days) d: 0.0,
    };
    for (int i = 0; i < 7; i++) {
      final d = now.subtract(Duration(days: i));
      final key = days[d.weekday - 1];
      result[key] = (result[key] ?? 0) + hoursForDate(d);
    }
    return result;
  }

  Map<String, double> subjectHoursLast30Days() {
    final result = <String, double>{};
    for (final log in state) {
      result[log.subjectName] =
          (result[log.subjectName] ?? 0) + log.hoursStudied;
    }
    return result;
  }

  Future<void> _checkAchievements() async {
    final db = IsarService.db;
    final totalLogs = await db.studyLogSchemas.count();
    final totalHours = state.fold(0.0, (s, l) => s + l.hoursStudied);
    final pyqCount =
        await db.studyLogSchemas.filter().activityTagEqualTo('pyq').count();

    Future<void> unlock(String badgeId) async {
      final badge = await db.achievementSchemas
          .filter()
          .badgeIdEqualTo(badgeId)
          .findFirst();
      if (badge != null && !badge.unlocked) {
        badge.unlocked = true;
        badge.unlockedAt = DateTime.now();
        await db.writeTxn(() async => db.achievementSchemas.put(badge));
        await NotificationHelper.showAchievementNotification(
          badgeTitle: badge.title,
          badgeEmoji: badge.emoji,
          description: badge.description,
        );
      }
    }

    if (totalLogs == 1) await unlock('first_log');
    if (totalHours >= 10) await unlock('hours_10');
    if (totalHours >= 50) await unlock('hours_50');
    if (totalHours >= 100) await unlock('hours_100');
    if (totalHours >= 250) await unlock('hours_250');
    if (totalHours >= 500) await unlock('hours_500');
    if (pyqCount >= 10) await unlock('pyq_10');
    if (pyqCount >= 50) await unlock('pyq_50');
    if (pyqCount >= 100) await unlock('pyq_100');

    // ── CA Final Group badges ─────────────────────────────────────────────
    // Check if the student is a CA Final user and whether all chapters in
    // Group I (Papers 1–3) or Group II (Papers 4–6) are at 'learned' or better.
    final user = await db.userSchemas.where().findFirst();
    if (user?.targetExam == 'ca_final') {
      // Group I: Papers 1, 2, 3 → classLevel 1, 2, 3
      final g1Total = await db.chapterSchemas
          .filter()
          .syllabusSourceEqualTo('ca_final')
          .and()
          .group((q) => q
              .classLevelEqualTo(1)
              .or()
              .classLevelEqualTo(2)
              .or()
              .classLevelEqualTo(3))
          .count();
      final g1Done = await db.chapterSchemas
          .filter()
          .syllabusSourceEqualTo('ca_final')
          .and()
          .group((q) => q
              .classLevelEqualTo(1)
              .or()
              .classLevelEqualTo(2)
              .or()
              .classLevelEqualTo(3))
          .and()
          .group((q) => q
              .statusEqualTo('learned')
              .or()
              .statusEqualTo('revised')
              .or()
              .statusEqualTo('tested'))
          .count();
      if (g1Total > 0 && g1Done >= g1Total) await unlock('ca_group1');

      // Group II: Papers 4, 5, 6 → classLevel 4, 5, 6
      final g2Total = await db.chapterSchemas
          .filter()
          .syllabusSourceEqualTo('ca_final')
          .and()
          .group((q) => q
              .classLevelEqualTo(4)
              .or()
              .classLevelEqualTo(5)
              .or()
              .classLevelEqualTo(6))
          .count();
      final g2Done = await db.chapterSchemas
          .filter()
          .syllabusSourceEqualTo('ca_final')
          .and()
          .group((q) => q
              .classLevelEqualTo(4)
              .or()
              .classLevelEqualTo(5)
              .or()
              .classLevelEqualTo(6))
          .and()
          .group((q) => q
              .statusEqualTo('learned')
              .or()
              .statusEqualTo('revised')
              .or()
              .statusEqualTo('tested'))
          .count();
      if (g2Total > 0 && g2Done >= g2Total) await unlock('ca_group2');
    }
  }

  Future<void> refresh() => _load();
}

final studyLogProvider =
    NotifierProvider<StudyLogNotifier, List<StudyLogSchema>>(
        StudyLogNotifier.new);

// ═══════════════════════════════════════════════════════════════════════════
// DASHBOARD SUMMARY PROVIDER  (derived — no fake data)
// ═══════════════════════════════════════════════════════════════════════════

class DashboardSummary {
  final double overallProgress; // 0.0–1.0 weighted
  final Map<String, double> subjectProgress; // subject → 0.0–1.0
  final double avgDailyHours;
  final int streak;
  final int daysToExam;
  final double totalHoursLogged;
  final List<StudyLogSchema> recentLogs;
  final List<PlanEntrySchema> todayEntries;
  final int totalChapters;
  final int completedChapters;

  const DashboardSummary({
    required this.overallProgress,
    required this.subjectProgress,
    required this.avgDailyHours,
    required this.streak,
    required this.daysToExam,
    required this.totalHoursLogged,
    required this.recentLogs,
    required this.todayEntries,
    required this.totalChapters,
    required this.completedChapters,
  });

  bool get hasData => totalChapters > 0;
}

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final planState = ref.watch(planProvider);
  final logs = ref.watch(studyLogProvider);
  final authState = ref.watch(authProvider);

  // Weighted overall progress
  double totalWeight = 0;
  double totalWeightedProgress = 0;
  int completedCount = 0;

  for (final c in planState.chapters) {
    final p = c.estimatedHours > 0
        ? (c.hoursSpent / c.estimatedHours).clamp(0.0, 1.0)
        : 0.0;
    totalWeightedProgress += p * c.weightage;
    totalWeight += c.weightage;
    if (c.status == 'learned' ||
        c.status == 'revised' ||
        c.status == 'tested') {
      completedCount++;
    }
  }
  final overall = totalWeight > 0 ? totalWeightedProgress / totalWeight : 0.0;

  // Per-subject progress
  final subjectProgress = <String, double>{};
  final subjects = planState.chapters.map((c) => c.subjectName).toSet();
  for (final s in subjects) {
    final sc = planState.chapters.where((c) => c.subjectName == s).toList();
    double sw = 0, swp = 0;
    for (final c in sc) {
      final p = c.estimatedHours > 0
          ? (c.hoursSpent / c.estimatedHours).clamp(0.0, 1.0)
          : 0.0;
      swp += p * c.weightage;
      sw += c.weightage;
    }
    subjectProgress[s] = sw > 0 ? swp / sw : 0.0;
  }

  // Avg daily hours last 7 days
  final now = DateTime.now();
  double last7h = 0;
  for (int i = 0; i < 7; i++) {
    final d = now.subtract(Duration(days: i));
    final start = DateTime(d.year, d.month, d.day);
    final end = start.add(const Duration(days: 1));
    last7h += logs
        .where((l) => l.timestamp.isAfter(start) && l.timestamp.isBefore(end))
        .fold(0.0, (s, l) => s + l.hoursStudied);
  }

  final examDate = authState.user?.examDate;
  final daysToExam =
      examDate != null ? examDate.difference(now).inDays.clamp(0, 9999) : 0;

  return DashboardSummary(
    overallProgress: overall,
    subjectProgress: subjectProgress,
    avgDailyHours: last7h / 7,
    streak: authState.user?.currentStreak ?? 0,
    daysToExam: daysToExam,
    totalHoursLogged: logs.fold(0.0, (s, l) => s + l.hoursStudied),
    recentLogs: logs.take(5).toList(),
    todayEntries: planState.todayEntries,
    totalChapters: planState.chapters.length,
    completedChapters: completedCount,
  );
});

// ═══════════════════════════════════════════════════════════════════════════
// REVISION PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

final revisionProvider =
    FutureProvider<List<RevisionScheduleSchema>>((ref) async {
  final db = IsarService.db;
  return db.revisionScheduleSchemas.filter().activeEqualTo(true).findAll();
});

/// TASK 7: Count of revisions whose next pending date is today or in the past.
final overdueRevisionCountProvider = Provider<int>((ref) {
  final revisionsAsync = ref.watch(revisionProvider);
  return revisionsAsync.when(
    data: (revisions) {
      final today = DateTime.now();
      final todayDay = DateTime(today.year, today.month, today.day);
      int count = 0;
      for (final r in revisions) {
        if (r.isFullyRevised) continue;
        final pending = r.scheduledDates.where((d) {
          final day = DateTime(d.year, d.month, d.day);
          return !r.completedDates.any(
                (c) =>
                    c.year == d.year && c.month == d.month && c.day == d.day,
              ) &&
              !day.isAfter(todayDay);
        }).toList();
        if (pending.isNotEmpty) count++;
      }
      return count;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final upcomingRevisionsProvider =
    FutureProvider<Map<String, List<RevisionScheduleSchema>>>((ref) async {
  final db = IsarService.db;
  final all =
      await db.revisionScheduleSchemas.filter().activeEqualTo(true).findAll();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final weekEnd = today.add(const Duration(days: 7));

  final grouped = <String, List<RevisionScheduleSchema>>{
    'Today': [],
    'Tomorrow': [],
    'This Week': [],
    'Later': [],
  };

  for (final r in all) {
    if (r.isFullyRevised) continue;
    final pending = r.scheduledDates
        .where((d) =>
            !r.completedDates.any((c) =>
                c.year == d.year && c.month == d.month && c.day == d.day) &&
            !d.isBefore(today))
        .toList()
      ..sort();
    if (pending.isEmpty) continue;

    final next = pending.first;
    final nextDay = DateTime(next.year, next.month, next.day);

    if (nextDay == today) {
      grouped['Today']!.add(r);
    } else if (nextDay == tomorrow) {
      grouped['Tomorrow']!.add(r);
    } else if (nextDay.isBefore(weekEnd)) {
      grouped['This Week']!.add(r);
    } else {
      grouped['Later']!.add(r);
    }
  }
  return grouped;
});

// ═══════════════════════════════════════════════════════════════════════════
// SUBSCRIPTION PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

class SubscriptionState {
  final bool isPremium;
  final String? planType;
  final DateTime? expiryDate;
  final bool isLoading;
  final bool isInTrial;

  const SubscriptionState({
    this.isPremium = false,
    this.planType,
    this.expiryDate,
    this.isLoading = false,
    this.isInTrial = false,
  });
}

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() {
    _load();
    return const SubscriptionState(isLoading: true);
  }

  Future<void> _load() async {
    final db = IsarService.db;
    final user = await db.userSchemas.where().findFirst();
    if (user == null) {
      state = const SubscriptionState();
      return;
    }
    final active = user.isPremium &&
        (user.premiumExpiry == null ||
            user.premiumExpiry!.isAfter(DateTime.now()));
    state = SubscriptionState(
      isPremium: active,
      planType: user.subscriptionPlan,
      expiryDate: user.premiumExpiry,
      isLoading: false,
    );
  }

  /// Called ONLY from server-verified purchase flow in app.dart
  Future<void> activatePremiumFromServer({
    required String planType,
    required DateTime? expiry,
  }) async {
    final db = IsarService.db;
    final user = await db.userSchemas.where().findFirst();
    if (user == null) return;
    user.isPremium = true;
    user.subscriptionPlan = planType;
    user.premiumExpiry = expiry;
    await db.writeTxn(() async => db.userSchemas.put(user));
    state = SubscriptionState(
      isPremium: true,
      planType: planType,
      expiryDate: expiry,
    );
  }

  /// Legacy method kept for compatibility — prefer activatePremiumFromServer
  Future<void> activatePremium({
    required String planType,
    required DateTime expiry,
    bool isInTrial = false,
  }) =>
      activatePremiumFromServer(planType: planType, expiry: expiry);

  Future<void> deactivatePremium() async {
    final db = IsarService.db;
    final user = await db.userSchemas.where().findFirst();
    if (user == null) return;
    user.isPremium = false;
    user.subscriptionPlan = null;
    user.premiumExpiry = null;
    await db.writeTxn(() async => db.userSchemas.put(user));
    state = const SubscriptionState();
  }

  bool get isPremium => state.isPremium;
}

final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
        SubscriptionNotifier.new);

// ═══════════════════════════════════════════════════════════════════════════
// ACHIEVEMENTS PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

final achievementsProvider =
    FutureProvider<List<AchievementSchema>>((ref) async {
  // Re-run when study logs change
  ref.watch(studyLogProvider);
  final db = IsarService.db;
  return db.achievementSchemas.where().findAll();
});

// Extension: applyAIPlan added separately for clarity
extension PlanNotifierAI on PlanNotifier {
  Future<void> applyAIPlan(List<Map<String, dynamic>> aiDays) async {
    final db = IsarService.db;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekEnd = today.add(const Duration(days: 7));

    // Remove only future pending entries (don't touch completed/skipped)
    final futureEntries = await db.planEntrySchemas
        .filter()
        .plannedDateGreaterThan(today.subtract(const Duration(days: 1)))
        .and()
        .plannedDateLessThan(weekEnd)
        .and()
        .statusEqualTo('pending')
        .findAll();

    final newEntries = <PlanEntrySchema>[];
    for (final day in aiDays) {
      final dateOffset = day['date_offset'] as int? ?? 0;
      final date = today.add(Duration(days: dateOffset));
      if (date.isAfter(weekEnd)) continue;
      final dayEntries =
          (day['entries'] as List? ?? []).cast<Map<String, dynamic>>();
      for (int i = 0; i < dayEntries.length; i++) {
        final e = dayEntries[i];
        newEntries.add(PlanEntrySchema()
          ..chapterName = e['chapter'] as String? ?? ''
          ..subjectName = e['subject'] as String? ?? ''
          ..plannedDate = date
          ..plannedHours = (e['hours'] as num?)?.toDouble() ?? 1.0
          ..orderIndex = i
          ..isRevision = e['is_revision'] as bool? ?? false
          ..status = 'pending');
      }
    }

    await db.writeTxn(() async {
      await db.planEntrySchemas
          .deleteAll(futureEntries.map((e) => e.id).toList());
      await db.planEntrySchemas.putAll(newEntries);
    });

    await refresh();
  }
}
