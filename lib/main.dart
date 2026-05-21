import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/startup/startup_controller.dart';

void main() {
  runZonedGuarded(_bootstrap, _onZoneError);
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[Main] bootstrap started');

  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (error, stack) {
    debugPrint('[Main] orientation setup failed: $error');
    StartupController.reportZoneError(error, stack);
  }

  try {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  } catch (error, stack) {
    debugPrint('[Main] system UI setup failed: $error');
    StartupController.reportZoneError(error, stack);
  }

  runApp(
    const ProviderScope(
      child: PrepSarthiApp(),
    ),
  );
  debugPrint('[Main] runApp completed');
}

void _onZoneError(Object error, StackTrace stack) {
  debugPrint('[Main] zone error: $error');
  StartupController.reportZoneError(error, stack);
}
