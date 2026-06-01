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

  // ✅ FIX (Improvement #2 / Audit §5): Global error boundary.
  // Prevents the red "RenderFlex overflow" screen in release builds.
  // Shows a subtle fallback tile with a restart hint instead.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('[ErrorWidget] caught: ${details.exception}');
    return _AppErrorWidget(details: details);
  };

  // Suppress framework error noise in release builds only.
  // In debug we keep the default so the red screen is still visible.
  if (const bool.fromEnvironment('dart.vm.product')) {
    FlutterError.onError = (details) {
      debugPrint('[FlutterError] ${details.exception}\n${details.stack}');
    };
  }

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

// ── Global error widget — shown instead of red screen ────────────────────────
/// Renders a non-intrusive fallback when a widget subtree throws at build time.
/// Users see a neutral message rather than a crash screen.
class _AppErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;
  const _AppErrorWidget({required this.details});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.error.withOpacity(0.25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded,
                color: theme.colorScheme.error, size: 28),
            const SizedBox(height: 8),
            Text(
              'Something went wrong here.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onErrorContainer),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Try refreshing or restarting the app.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onErrorContainer.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

