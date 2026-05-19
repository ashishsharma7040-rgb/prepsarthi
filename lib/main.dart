// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'data/local/isar/isar_service.dart';
import 'data/local/preload/syllabus_loader.dart';
import 'data/remote/vertex/gemini_service.dart';
import 'core/utils/notification_helper.dart';
import 'domain/usecases/backlog_adjuster.dart';
import 'app.dart';

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    // 1. Firebase
    await Firebase.initializeApp();

    // ✅ Crashlytics — catch all Flutter errors in production
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    // 2. Isar local database
    await IsarService.getInstance();

    // 3. Seed syllabus if first run
    await SyllabusLoader.loadIfNeeded();

    // 4. Notifications + timezone
    tz.initializeTimeZones();
    await NotificationHelper.initialize();

    // 5. Gemini AI
    GeminiService.initialize();

    // 6. Backlog auto-adjustment
    final backlogResult = await BacklogAdjuster.adjustIfNeeded();
    if (backlogResult.hasBacklog) {
      debugPrint('[Main] Backlog: ${backlogResult.message}');
    }

    // 7. IAP availability
    final iapAvailable = await InAppPurchase.instance.isAvailable();
    debugPrint('[Main] IAP available: $iapAvailable');

    runApp(
      ProviderScope(
        child: PrepSarthiApp(iapAvailable: iapAvailable),
      ),
    );
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
  });
}
