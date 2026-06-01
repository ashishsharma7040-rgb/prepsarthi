// lib/presentation/providers/settings_provider.dart
//
// ✅ FIX (Improvement #2 / Audit §7):
//   Extracted from the 1124-line all_providers.dart god file.
//   Previously settings_provider.dart was a 2-line barrel re-export.
//   Now contains the real SettingsState + SettingsNotifier implementation.
//   all_providers.dart exports this file for backward compatibility.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/isar/isar_service.dart';
import '../../data/local/isar/schemas/user_settings_schema.dart';
import '../../core/utils/notification_helper.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SETTINGS PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

class SettingsState {
  final String themeMode;
  final bool notificationsEnabled;
  final String notificationTime;
  final int pomodoroWork;
  final int pomodoroBreak;
  final int pomodoroCycles;
  final bool soundEnabled;

  const SettingsState({
    this.themeMode = 'system',
    this.notificationsEnabled = true,
    this.notificationTime = '09:00',
    this.pomodoroWork = 25,
    this.pomodoroBreak = 5,
    this.pomodoroCycles = 4,
    this.soundEnabled = true,
  });

  SettingsState copyWith({
    String? themeMode,
    bool? notificationsEnabled,
    String? notificationTime,
    int? pomodoroWork,
    int? pomodoroBreak,
    int? pomodoroCycles,
    bool? soundEnabled,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        notificationTime: notificationTime ?? this.notificationTime,
        pomodoroWork: pomodoroWork ?? this.pomodoroWork,
        pomodoroBreak: pomodoroBreak ?? this.pomodoroBreak,
        pomodoroCycles: pomodoroCycles ?? this.pomodoroCycles,
        soundEnabled: soundEnabled ?? this.soundEnabled,
      );
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    _load();
    return const SettingsState();
  }

  Future<void> _load() async {
    final db = IsarService.db;
    final s = await db.userSettingsSchemas.where().findFirst();
    if (s != null) {
      state = SettingsState(
        themeMode: s.themeMode,
        notificationsEnabled: s.notificationsEnabled,
        notificationTime: s.notificationTime,
        pomodoroWork: s.pomodoroWorkMinutes,
        pomodoroBreak: s.pomodoroBreakMinutes,
        pomodoroCycles: s.pomodoroCycles,
        soundEnabled: s.soundEnabled,
      );
    }
  }

  Future<void> setThemeMode(String mode) async {
    state = state.copyWith(themeMode: mode);
    await _save();
  }

  Future<void> setNotifications(bool enabled, {String? userName}) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _save();
    if (enabled) {
      final parts = state.notificationTime.split(':');
      final time = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 9,
        minute: int.tryParse(parts[1]) ?? 0,
      );
      await NotificationHelper.scheduleDailyStudyReminder(
        time: time,
        userName: userName ?? 'Aspirant',
      );
    } else {
      await NotificationHelper.cancelDailyReminder();
    }
  }

  Future<void> setNotificationTime(String hhmm, {String? userName}) async {
    state = state.copyWith(notificationTime: hhmm);
    await _save();
    if (state.notificationsEnabled) {
      final parts = hhmm.split(':');
      final time = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 9,
        minute: int.tryParse(parts[1]) ?? 0,
      );
      await NotificationHelper.scheduleDailyStudyReminder(
        time: time,
        userName: userName ?? 'Aspirant',
      );
    }
  }

  Future<void> setPomodoroWork(int minutes) async {
    state = state.copyWith(pomodoroWork: minutes);
    await _save();
  }

  Future<void> setPomodoroBreak(int minutes) async {
    state = state.copyWith(pomodoroBreak: minutes);
    await _save();
  }

  Future<void> _save() async {
    final db = IsarService.db;
    await db.writeTxn(() async {
      var s = await db.userSettingsSchemas.where().findFirst() ??
          UserSettingsSchema();
      s.themeMode = state.themeMode;
      s.notificationsEnabled = state.notificationsEnabled;
      s.notificationTime = state.notificationTime;
      s.pomodoroWorkMinutes = state.pomodoroWork;
      s.pomodoroBreakMinutes = state.pomodoroBreak;
      s.pomodoroCycles = state.pomodoroCycles;
      s.soundEnabled = state.soundEnabled;
      await db.userSettingsSchemas.put(s);
    });
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
