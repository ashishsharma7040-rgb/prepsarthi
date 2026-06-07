// lib/core/utils/app_haptics.dart
//
// Centralized haptic feedback for PrepSarthi — Shanti Scholar edition.
//
// Usage philosophy:
//  • Haptics reinforce actions, not spam them. Use sparingly.
//  • light()   → navigation taps, chip selects, small toggles
//  • medium()  → card taps, form submits, task confirmations
//  • success() → correct answer, plan generated, goal hit
//  • error()   → wrong answer, validation fail, blocked action
//  • celebrate() → streak milestone, first session done
//  • timerEnd() → Pomodoro session complete
//
// All methods are static. Call them just before or after the state change
// they reinforce — never inside build() or initState() without a user trigger.

import 'package:flutter/services.dart';

class AppHaptics {
  AppHaptics._();

  // ─── Core Primitives ──────────────────────────────────────────────────────

  /// Very subtle — tab switches, filter chips, small toggles.
  static Future<void> light() => HapticFeedback.lightImpact();

  /// Moderate — card taps, form submit, navigation forward.
  static Future<void> medium() => HapticFeedback.mediumImpact();

  /// Strong — destructive or highly significant actions.
  static Future<void> heavy() => HapticFeedback.heavyImpact();

  /// Crisp click — radio, checkbox, bottom nav selection.
  static Future<void> select() => HapticFeedback.selectionClick();

  // ─── Semantic Haptics ─────────────────────────────────────────────────────

  /// Correct quiz answer, plan generated, goal achieved.
  /// Feel: medium → pause → light (rewarding double-tap).
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
  }

  /// Wrong answer, validation error, action blocked.
  /// Feel: two quick lights (gentle "no").
  static Future<void> error() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.lightImpact();
  }

  /// Streak milestone, daily goal hit, first Pomodoro done.
  /// Feel: light → medium → light (ascending–descending, celebratory).
  static Future<void> celebrate() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 70));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
  }

  /// Pomodoro session/timer end — attention-grabbing but not jarring.
  /// Feel: heavy → pause → medium.
  static Future<void> timerEnd() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.mediumImpact();
  }

  /// Pomodoro start (begin focus session).
  static Future<void> timerStart() => HapticFeedback.mediumImpact();

  /// Pomodoro pause.
  static Future<void> timerPause() => HapticFeedback.lightImpact();

  /// Pomodoro reset — slightly stronger, it's a disruptive action.
  static Future<void> timerReset() => HapticFeedback.mediumImpact();

  /// Pomodoro skip phase.
  static Future<void> timerSkip() => HapticFeedback.lightImpact();

  /// Primary CTA button pressed (Generate Plan, Start Test, etc.).
  static Future<void> buttonPress() => HapticFeedback.mediumImpact();

  /// Bottom nav item tapped.
  static Future<void> navTap() => HapticFeedback.selectionClick();

  /// Theme toggle switched (light ↔ dark).
  static Future<void> toggle() => HapticFeedback.selectionClick();

  /// Pull-to-refresh triggered.
  static Future<void> refresh() => HapticFeedback.lightImpact();

  /// Chapter / topic marked as done.
  /// Feel: light → medium (satisfying completion).
  static Future<void> markDone() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.mediumImpact();
  }

  /// Swipe-to-delete or destructive gesture.
  static Future<void> destructive() => HapticFeedback.heavyImpact();

  /// Long-press registered.
  static Future<void> longPress() => HapticFeedback.mediumImpact();

  /// Drag item picked up.
  static Future<void> dragStart() => HapticFeedback.selectionClick();

  /// Dragged item snapped into new position.
  static Future<void> dragSnap() => HapticFeedback.lightImpact();

  /// Quiz option selected (before answer revealed).
  static Future<void> quizSelect() => HapticFeedback.selectionClick();

  /// Quiz answer submitted.
  static Future<void> quizSubmit() => HapticFeedback.mediumImpact();

  /// Onboarding step forward.
  static Future<void> pageForward() => HapticFeedback.lightImpact();

  /// Onboarding step back.
  static Future<void> pageBack() => HapticFeedback.selectionClick();

  /// Google sign-in tapped.
  static Future<void> signIn() => HapticFeedback.mediumImpact();
}
