// lib/core/startup/startup_controller.dart
//
// ── §5 ERROR HANDLING fix ─────────────────────────────────────────────────────
// • Replaced 2 silent `catch (_) {}` blocks with `AppLogger` calls:
//   1. reportZoneError — Crashlytics write failure now logged at warning level.
//   2. Inner Isar read for targetExam — failure now logged at warning level.
//      Both were genuinely swallowable (non-fatal) but are now visible in
//      debug mode and forwarded to Crashlytics in production.
// • All startup logic and timeouts are unchanged.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:isar/isar.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../core/utils/app_logger.dart';
import '../../core/utils/notification_helper.dart';
import '../../data/local/isar/isar_service.dart';
import '../../data/local/preload/syllabus_loader.dart';
import '../../data/remote/vertex/gemini_service.dart';
import '../../domain/usecases/backlog_adjuster.dart';

enum StartupPhase {
  starting,
  initializingDatabase,
  initializingFirebase,
  loadingSyllabus,
  preparingDashboard,
  completed,
  failed,
}

class StartupState {
  final StartupPhase phase;
  final String? errorMessage;
  final String? debugDetail;
  final bool iapAvailable;

  const StartupState({
    this.phase = StartupPhase.starting,
    this.errorMessage,
    this.debugDetail,
    this.iapAvailable = false,
  });

  bool get isCompleted => phase == StartupPhase.completed;
  bool get isFailed => phase == StartupPhase.failed;

  String get statusText => switch (phase) {
        StartupPhase.starting => 'Warming up...',
        StartupPhase.initializingDatabase => 'Loading your study data...',
        StartupPhase.initializingFirebase => 'Connecting to cloud...',
        StartupPhase.loadingSyllabus => 'Preparing syllabus...',
        StartupPhase.preparingDashboard => 'Preparing your dashboard...',
        StartupPhase.completed => 'Ready!',
        StartupPhase.failed => 'PrepSarthi could not finish startup',
      };

  StartupState copyWith({
    StartupPhase? phase,
    String? errorMessage,
    String? debugDetail,
    bool? iapAvailable,
  }) {
    return StartupState(
      phase: phase ?? this.phase,
      errorMessage: errorMessage ?? this.errorMessage,
      debugDetail: debugDetail ?? this.debugDetail,
      iapAvailable: iapAvailable ?? this.iapAvailable,
    );
  }
}

final iapAvailableProvider = StateProvider<bool>((ref) => false);

class StartupController extends AsyncNotifier<StartupState> {
  static FirebaseCrashlytics? _crashlytics;

  static const Duration _databaseTimeout = Duration(seconds: 10);
  static const Duration _firebaseTimeout = Duration(seconds: 12);
  static const Duration _syllabusTimeout = Duration(seconds: 10);
  static const Duration _iapTimeout = Duration(seconds: 6);
  static const Duration _backgroundBacklogTimeout = Duration(seconds: 5);
  static const Duration _overallTimeout = Duration(seconds: 30);

  @override
  Future<StartupState> build() async {
    debugPrint('[Startup] build started');
    return _runStartup();
  }

  static void reportZoneError(Object error, StackTrace stack) {
    // ✅ FIX §5: was `catch (_) {}` — now logs warning so Crashlytics write
    //    failures are visible in debug mode and tracked in production.
    try {
      _crashlytics?.recordError(error, stack, fatal: false);
    } catch (e, st) {
      AppLogger.w('startup.crashlytics', e, st);
    }
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_runStartup);
  }

  Future<StartupState> _runStartup() async {
    try {
      return await _doInit().timeout(
        _overallTimeout,
        onTimeout: () => const StartupState(
          phase: StartupPhase.failed,
          errorMessage: 'Startup timed out',
          debugDetail: 'Startup took longer than 30 seconds.',
        ),
      );
    } catch (error, stack) {
      debugPrint('[Startup] unexpected error: $error');
      reportZoneError(error, stack);
      return StartupState(
        phase: StartupPhase.failed,
        errorMessage: 'Startup failed unexpectedly',
        debugDetail: error.toString(),
      );
    }
  }

  Future<StartupState> _doInit() async {
    var current = const StartupState();

    current = current.copyWith(phase: StartupPhase.initializingDatabase);
    state = AsyncData(current);
    try {
      await IsarService.getInstance().timeout(_databaseTimeout);
      debugPrint('[Startup] Isar ready');
    } catch (error, stack) {
      debugPrint('[Startup] Isar failed: $error');
      reportZoneError(error, stack);
      return StartupState(
        phase: StartupPhase.failed,
        errorMessage: 'Local study database failed to open',
        debugDetail: 'IsarService: $error',
      );
    }

    current = current.copyWith(phase: StartupPhase.initializingFirebase);
    state = AsyncData(current);
    try {
      await Firebase.initializeApp().timeout(_firebaseTimeout);
      _crashlytics = FirebaseCrashlytics.instance;
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        reportZoneError(error, stack);
        return true;
      };
      unawaited(
        FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true),
      );
      final options = Firebase.app().options;
      debugPrint(
        '[Startup] Firebase ready '
        'projectId=${options.projectId} '
        'appIdPresent=${options.appId.isNotEmpty} '
        'apiKeyPresent=${options.apiKey.isNotEmpty}',
      );
    } catch (error, stack) {
      debugPrint('[Startup] Firebase failed, continuing offline: $error');
      reportZoneError(error, stack);
    }

    current = current.copyWith(phase: StartupPhase.loadingSyllabus);
    state = AsyncData(current);
    try {
      // ✅ FIX §5: was `catch (_) {}` — now logs at warning level so Isar
      //    read failures during syllabus load are visible in logs.
      String? targetExam;
      try {
        final db = IsarService.db;
        final user = await db.userSchemas.where().findFirst();
        targetExam = user?.targetExam;
      } catch (e, st) {
        AppLogger.w('startup.targetExam', e, st);
      }
      await SyllabusLoader.loadIfNeeded(targetExam: targetExam)
          .timeout(_syllabusTimeout);
      debugPrint('[Startup] Syllabus ready (target: $targetExam)');
    } catch (error, stack) {
      debugPrint('[Startup] Syllabus load failed: $error');
      reportZoneError(error, stack);
    }

    current = current.copyWith(phase: StartupPhase.preparingDashboard);
    state = AsyncData(current);

    var iapAvailable = false;
    try {
      iapAvailable =
          await InAppPurchase.instance.isAvailable().timeout(_iapTimeout);
      debugPrint('[Startup] IAP available: $iapAvailable');
    } catch (error, stack) {
      debugPrint('[Startup] IAP check failed: $error');
      reportZoneError(error, stack);
    }

    ref.read(iapAvailableProvider.notifier).state = iapAvailable;
    unawaited(_initializeBackgroundServices());

    return current.copyWith(
      phase: StartupPhase.completed,
      iapAvailable: iapAvailable,
    );
  }

  Future<void> _initializeBackgroundServices() async {
    try {
      tz.initializeTimeZones();
      await NotificationHelper.initialize();
      debugPrint('[Startup] Notifications ready');
    } catch (error, stack) {
      debugPrint('[Startup] Notifications failed: $error');
      reportZoneError(error, stack);
    }

    try {
      GeminiService.initialize();
      debugPrint('[Startup] Gemini ready');
    } catch (error, stack) {
      debugPrint('[Startup] Gemini failed: $error');
      reportZoneError(error, stack);
    }

    try {
      final result = await BacklogAdjuster.adjustIfNeeded().timeout(
        _backgroundBacklogTimeout,
      );
      if (result.hasBacklog) {
        debugPrint('[Startup] Backlog: ${result.message}');
      }
    } catch (error, stack) {
      debugPrint('[Startup] Backlog adjuster failed: $error');
      reportZoneError(error, stack);
    }
  }
}

final startupControllerProvider =
    AsyncNotifierProvider<StartupController, StartupState>(
  StartupController.new,
);
