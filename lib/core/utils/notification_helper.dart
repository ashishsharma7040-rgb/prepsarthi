// lib/core/utils/notification_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'prepsarthi_main';
  static const _channelName = 'PrepSarthi Reminders';
  static const _channelDesc = 'Study reminders, revision alerts and streak notifications';

  // Notification IDs (reserved ranges)
  static const int _dailyStudyId = 1;
  static const int _revisionBaseId = 100;   // 100–199 for revisions
  static const int _streakBaseId = 200;      // 200–299 for streak
  static const int _milestoneBaseId = 300;   // 300+ for milestones

  // ─── Initialise ────────────────────────────────────────────────────────────
  static Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel (Android 8+)
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ─── Permission request ────────────────────────────────────────────────────
  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  // ─── Daily study reminder ──────────────────────────────────────────────────
  static Future<void> scheduleDailyStudyReminder({
    required TimeOfDay time,
    required String userName,
  }) async {
    await _plugin.cancel(_dailyStudyId);

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year, now.month, now.day, time.hour, time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final messages = [
      '📚 Time to study, $userName! Your exam is getting closer.',
      '🔥 Keep the streak alive! Open PrepSarthi and log today\'s session.',
      '🧠 Your future self will thank you for studying today.',
      '⚡ Every chapter you complete today is one less to stress about tomorrow.',
      '🎯 Consistent daily effort beats last-minute cramming. Let\'s go!',
    ];
    final message = messages[scheduledDate.day % messages.length];

    await _plugin.zonedSchedule(
      _dailyStudyId,
      'PrepSarthi – Study Time! 📚',
      message,
      tz.TZDateTime.from(scheduledDate, tz.local),
      _notifDetails(
        title: 'PrepSarthi – Study Time!',
        body: message,
        ongoing: false,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily
    );
  }

  // ─── Cancel daily reminder ─────────────────────────────────────────────────
  static Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_dailyStudyId);
  }

  // ─── Revision reminder ─────────────────────────────────────────────────────
  /// Schedules a one-time notification for a revision task.
  static Future<void> scheduleRevisionReminder({
    required int id, // use _revisionBaseId + index
    required String chapterName,
    required String subjectName,
    required DateTime scheduledDate,
    required double recommendedHours,
  }) async {
    final notifDate = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      9, 0, // 9 AM on revision day
    );

    if (notifDate.isBefore(DateTime.now())) return;

    final body = 'Revise $chapterName ($subjectName) today – '
        '${recommendedHours.toStringAsFixed(0)} min recommended.';

    await _plugin.zonedSchedule(
      _revisionBaseId + id,
      '🔄 Revision Due – $chapterName',
      body,
      tz.TZDateTime.from(notifDate, tz.local),
      _notifDetails(title: '🔄 Revision Due – $chapterName', body: body),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ─── Streak milestone ──────────────────────────────────────────────────────
  static Future<void> showStreakNotification(int streakDays) async {
    if (streakDays < 3) return;

    final (title, body) = switch (streakDays) {
      3 => ('🔥 3-Day Streak!', 'You\'ve studied 3 days in a row. Keep it up!'),
      7 => ('🦁 Week Warrior!', '7 days straight! You\'re on fire!'),
      14 => ('⚡ Fortnight Fire!', '14-day streak! You are unstoppable!'),
      30 => ('🏆 Month Master!', '30 days! This is legendary dedication.'),
      60 => ('🌟 60 Days!', 'Incredible. Two months of consistent effort!'),
      100 => ('👑 100 Days!', 'You are the definition of dedication. LEGEND!'),
      _ => (null, null),
    };

    if (title == null) return;

    await _plugin.show(
      _streakBaseId + streakDays,
      title,
      body,
      _notifDetails(title: title!, body: body!),
    );
  }

  // ─── Achievement unlocked ──────────────────────────────────────────────────
  static Future<void> showAchievementNotification({
    required String badgeTitle,
    required String badgeEmoji,
    required String description,
  }) async {
    final id = _milestoneBaseId + badgeTitle.hashCode.abs() % 100;
    await _plugin.show(
      id,
      '$badgeEmoji Achievement Unlocked!',
      '$badgeTitle – $description',
      _notifDetails(
        title: '$badgeEmoji Achievement Unlocked!',
        body: '$badgeTitle – $description',
      ),
    );
  }

  // ─── Instant notification (for Pomodoro) ──────────────────────────────────
  static Future<void> showPomodoroComplete({
    required bool isFocusComplete,
    required int sessionNumber,
    required String? chapterName,
  }) async {
    final (title, body) = isFocusComplete
        ? (
            '🍅 Focus Session #$sessionNumber Complete!',
            chapterName != null
                ? 'Great work on $chapterName! Take a break.'
                : 'Excellent focus! You\'ve earned a break.',
          )
        : (
            '☕ Break Over!',
            'Ready to get back to it? Start your next session.',
          );

    await _plugin.show(
      999,
      title,
      body,
      _notifDetails(title: title, body: body, ongoing: false),
    );
  }

  // ─── Danger zone: cancel all ───────────────────────────────────────────────
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  static NotificationDetails _notifDetails({
    required String title,
    required String body,
    bool ongoing = false,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        ongoing: ongoing,
        styleInformation: BigTextStyleInformation(
          body,
          htmlFormatBigText: false,
          contentTitle: title,
          summaryText: 'PrepSarthi',
        ),
        color: const Color(0xFF00C4B4),
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      ),
    );
  }

  // Global navigator key — set this in app.dart for navigation from notifications
  static GlobalKey<NavigatorState>? navigatorKey;

  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload ?? '';
    final nav = navigatorKey?.currentState;
    if (nav == null) return;

    if (payload.startsWith('revision:')) {
      // Navigate to revision schedule screen
      nav.pushNamed('/revision');
    } else if (payload.startsWith('study:')) {
      // Navigate to daily log screen
      nav.pushNamed('/log');
    } else if (payload.startsWith('streak')) {
      // Navigate to dashboard
      nav.pushNamed('/dashboard');
    } else {
      nav.pushNamed('/dashboard');
    }
  }
}
