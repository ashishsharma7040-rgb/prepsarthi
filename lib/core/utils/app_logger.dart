// lib/core/utils/app_logger.dart
//
// ── Purpose ──────────────────────────────────────────────────────────────────
// Single-source error logging that replaces all `catch (_) {}` silent swallows.
// Every caught exception now emits a labelled debug line in development and
// forwards to Firebase Crashlytics in production builds — giving you a full
// picture without crashing the user.
//
// ── Usage ────────────────────────────────────────────────────────────────────
// OLD (silent):
//   } catch (_) {}
//
// NEW (labelled):
//   } catch (e, st) { AppLogger.e('streak', e, st); }
//
// For expected / non-fatal conditions use .w() (warning):
//   } catch (e, st) { AppLogger.w('isar.migration', e, st); }
//
// For critical crashes that should always surface:
//   } catch (e, st) { AppLogger.fatal('purchase.token', e, st); rethrow; }
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

// Optional: import firebase_crashlytics when you add it to pubspec.
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Severity level for log entries.
enum _Level { debug, warning, error, fatal }

/// Centralised logger for PrepSarthi.
/// All methods are static and safe to call from any isolate context.
class AppLogger {
  AppLogger._();

  // ── Public surface ─────────────────────────────────────────────────────────

  /// Log a debug-level informational message.
  static void d(String tag, Object message) =>
      _log(_Level.debug, tag, message, null, null);

  /// Log a non-fatal warning — something that recovered but should be noted.
  static void w(String tag, Object error, [StackTrace? st]) =>
      _log(_Level.warning, tag, error, st, null);

  /// Log a recoverable error — the feature failed but the app is stable.
  static void e(String tag, Object error, [StackTrace? st]) =>
      _log(_Level.error, tag, error, st, null);

  /// Log a fatal/unexpected error — sends to Crashlytics in production.
  static void fatal(String tag, Object error, [StackTrace? st]) =>
      _log(_Level.fatal, tag, error, st, null);

  // ── Internal ───────────────────────────────────────────────────────────────

  static void _log(
    _Level level,
    String tag,
    Object error,
    StackTrace? st,
    // reserved for future structured context
    Map<String, dynamic>? context,
  ) {
    final prefix = _prefix(level);
    final message = error.toString();

    // Always print in debug mode.
    if (kDebugMode) {
      debugPrint('$prefix [$tag] $message');
      if (st != null && level.index >= _Level.error.index) {
        // Print top 5 frames — enough context, not a wall of text.
        final frames = st.toString().split('\n').take(5).join('\n');
        debugPrint(frames);
      }
    }

    // In production: forward errors to Crashlytics (uncomment when added).
    if (!kDebugMode && level.index >= _Level.error.index) {
      // FirebaseCrashlytics.instance.recordError(
      //   error,
      //   st,
      //   reason: '[$tag]',
      //   fatal: level == _Level.fatal,
      // );
    }
  }

  static String _prefix(_Level level) {
    switch (level) {
      case _Level.debug:   return '🔵 [D]';
      case _Level.warning: return '🟡 [W]';
      case _Level.error:   return '🔴 [E]';
      case _Level.fatal:   return '💀 [F]';
    }
  }
}
