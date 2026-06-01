// lib/core/utils/connectivity_service.dart
//
// ✅ FIX (Improvement #2 / Audit §5):
//   connectivity_plus was declared in pubspec.yaml but NEVER used anywhere.
//   This file provides a single, app-wide connectivity helper that:
//     • checks current network status before AI/Gemini calls
//     • exposes a snackbar helper so any screen can show a friendly
//       "No internet – AI features need a connection" message instead of
//       a raw exception or a frozen spinner.
//
// Usage:
//   // Before a Gemini call:
//   if (!await ConnectivityService.isOnline()) {
//     ConnectivityService.showOfflineSnackbar(context);
//     return;
//   }
//
//   // Or use the combined guard (returns false and shows snackbar if offline):
//   if (!await ConnectivityService.guardOnline(context)) return;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  ConnectivityService._(); // utility class — no instances

  // ── Check ─────────────────────────────────────────────────────────────────

  /// Returns `true` if the device has any usable network connection.
  /// Checks ALL reported connection types so VPN + WiFi + Mobile all pass.
  static Future<bool> isOnline() async {
    try {
      final results = await Connectivity().checkConnectivity();
      // connectivity_plus v6 returns a List<ConnectivityResult>
      if (results.isEmpty) return false;
      return results.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      // If the platform call itself fails, assume online to avoid blocking
      // users on devices where the permission is denied.
      return true;
    }
  }

  // ── Guard + Snackbar ──────────────────────────────────────────────────────

  /// Checks connectivity and shows a snackbar if offline.
  /// Returns `true` if online (safe to proceed), `false` if offline.
  ///
  /// Example:
  /// ```dart
  /// if (!await ConnectivityService.guardOnline(context)) return;
  /// // ... proceed with Gemini call
  /// ```
  static Future<bool> guardOnline(BuildContext context) async {
    final online = await isOnline();
    if (!online && context.mounted) {
      showOfflineSnackbar(context);
    }
    return online;
  }

  /// Shows a standardised "No internet" snackbar.
  /// Call this before any AI / Gemini feature that requires a connection.
  static void showOfflineSnackbar(
    BuildContext context, {
    String? customMessage,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                customMessage ??
                    'No internet — AI features need a connection',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF323232),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: const Color(0xFF90CAF9),
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
}
