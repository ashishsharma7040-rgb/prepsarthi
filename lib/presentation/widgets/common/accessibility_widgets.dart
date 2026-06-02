// lib/presentation/widgets/common/accessibility_widgets.dart
//
// ── Purpose ──────────────────────────────────────────────────────────────────
// Zero Semantics was flagged as a Critical Play Store issue — TalkBack was
// completely broken. This file provides drop-in semantic wrappers used across
// all screens. Drop them in place of bare widgets to reach baseline WCAG 2.1 AA.
//
// Why a central file instead of one-off Semantics() calls?
//   • Single place to audit all a11y decisions
//   • Easy to extend with live-region support, custom actions, etc.
//   • Makes PR review surface all accessibility changes in one diff
//
// ── Migration guide ───────────────────────────────────────────────────────────
// Replace  →  With
// ───────────────────────────────────────────────────────────────────────
// IconButton(onPressed: fn, icon: Icon(Icons.edit_note))
//   → A11yIconButton(label: 'Log study session', onPressed: fn, icon: ...)
//
// GestureDetector(onTap: fn, child: Container(...))
//   → A11yTappable(label: 'Open chapter details', onTap: fn, child: ...)
//
// LinearProgressIndicator(value: 0.6)
//   → A11yProgressBar(value: 0.6, label: 'Syllabus 60% complete')
//
// CircularProgressIndicator()
//   → A11yLoadingIndicator(label: 'Loading study data')
//
// Text('5', style: ...) — numeric-only labels
//   → A11yLabel(label: '5 study sessions this week', child: Text('5'))
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

// ─── A11yTappable ─────────────────────────────────────────────────────────────
/// Wraps any tappable widget with a semantic label TalkBack/VoiceOver can read.
/// Use instead of bare GestureDetector or InkWell when the tap target lacks
/// a visible text label.
///
/// ```dart
/// A11yTappable(
///   label: 'Open SWOT Analysis report',
///   onTap: () => context.push(AppRoutes.swotReport),
///   child: _AIButton(label: 'SWOT Analysis', ...),
/// )
/// ```
class A11yTappable extends StatelessWidget {
  const A11yTappable({
    super.key,
    required this.label,
    required this.child,
    required this.onTap,
    this.hint,
    this.enabled = true,
  });

  final String label;
  final String? hint;
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      child: ExcludeSemantics(child: child),
    );
  }
}

// ─── A11yIconButton ───────────────────────────────────────────────────────────
/// An IconButton with a required semantic label.
/// Replaces all bare `IconButton(icon: Icon(...))` that have no tooltip.
///
/// ```dart
/// A11yIconButton(
///   label: 'Toggle dark mode',
///   icon: Icon(Icons.dark_mode_rounded),
///   onPressed: () => ...,
/// )
/// ```
class A11yIconButton extends StatelessWidget {
  const A11yIconButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: IconButton(
        // tooltip doubles as the visible a11y label for hover
        tooltip: label,
        icon: icon,
        onPressed: onPressed,
        color: color,
        iconSize: size,
      ),
    );
  }
}

// ─── A11yProgressBar ─────────────────────────────────────────────────────────
/// A LinearProgressIndicator with a live semantic label.
/// TalkBack reads both the label and the percentage value.
///
/// ```dart
/// A11yProgressBar(
///   value: summary.overallProgress,     // 0.0–1.0
///   label: 'Overall syllabus progress',
///   color: LightColors.primary,
/// )
/// ```
class A11yProgressBar extends StatelessWidget {
  const A11yProgressBar({
    super.key,
    required this.value,
    required this.label,
    this.color,
    this.backgroundColor,
    this.minHeight = 6,
  });

  final double value;
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();
    return Semantics(
      label: '$label: $pct percent',
      value: '$pct%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(minHeight / 2),
        child: LinearProgressIndicator(
          value: value,
          minHeight: minHeight,
          color: color,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}

// ─── A11yProgressRing ─────────────────────────────────────────────────────────
/// Wraps a circular progress widget with semantics.
///
/// ```dart
/// A11yProgressRing(
///   value: 0.72,
///   label: 'Readiness score',
///   child: ProgressRing(progress: 0.72, ...),
/// )
/// ```
class A11yProgressRing extends StatelessWidget {
  const A11yProgressRing({
    super.key,
    required this.value,
    required this.label,
    required this.child,
  });

  final double value;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();
    return Semantics(
      label: '$label: $pct percent',
      value: '$pct%',
      child: ExcludeSemantics(child: child),
    );
  }
}

// ─── A11yLoadingIndicator ────────────────────────────────────────────────────
/// A CircularProgressIndicator that announces itself to screen readers.
///
/// ```dart
/// A11yLoadingIndicator(label: 'Loading your study plan')
/// ```
class A11yLoadingIndicator extends StatelessWidget {
  const A11yLoadingIndicator({
    super.key,
    this.label = 'Loading',
    this.color,
  });

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      liveRegion: true,
      child: CircularProgressIndicator(color: color),
    );
  }
}

// ─── A11yLabel ───────────────────────────────────────────────────────────────
/// Wraps a widget (e.g. a numeric Text) with a more descriptive label.
/// The visual child is excluded from semantics; only `label` is spoken.
///
/// ```dart
/// A11yLabel(
///   label: '5-day study streak',
///   child: Text('5', style: ...),
/// )
/// ```
class A11yLabel extends StatelessWidget {
  const A11yLabel({
    super.key,
    required this.label,
    required this.child,
    this.isLiveRegion = false,
  });

  final String label;
  final Widget child;
  final bool isLiveRegion;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      liveRegion: isLiveRegion,
      child: ExcludeSemantics(child: child),
    );
  }
}

// ─── A11yCard ─────────────────────────────────────────────────────────────────
/// A semantic container for card-style content that groups children under
/// one accessibility node. TalkBack reads it as a single item rather than
/// traversing every child separately.
///
/// ```dart
/// A11yCard(
///   label: 'Readiness score card: 72 out of 100, Good status',
///   child: _ReadinessScoreCard(...),
/// )
/// ```
class A11yCard extends StatelessWidget {
  const A11yCard({
    super.key,
    required this.label,
    required this.child,
    this.onTap,
  });

  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: onTap != null,
      onTap: onTap,
      child: ExcludeSemantics(child: child),
    );
  }
}

// ─── A11yNavigationBar ────────────────────────────────────────────────────────
/// Wraps the bottom NavigationBar with a navigation landmark.
/// TalkBack announces "Navigation, tab bar, 5 items" context.
class A11yNavigationBar extends StatelessWidget {
  const A11yNavigationBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Navigation tabs',
      container: true,
      child: child,
    );
  }
}

// ─── A11yImage ───────────────────────────────────────────────────────────────
/// Image or emoji that carries a semantic description.
/// Prevents TalkBack from reading raw emoji codepoints.
///
/// ```dart
/// A11yImage(
///   label: 'Trophy icon — achievement earned',
///   child: Text('🏆', style: TextStyle(fontSize: 48)),
/// )
/// ```
class A11yImage extends StatelessWidget {
  const A11yImage({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      image: true,
      child: ExcludeSemantics(child: child),
    );
  }
}

// ─── A11yHeading ─────────────────────────────────────────────────────────────
/// Marks a Text widget as a section heading so TalkBack's heading navigation
/// (swipe up with one finger) can jump between sections.
///
/// ```dart
/// A11yHeading(child: Text('Today\'s Focus', style: ...))
/// ```
class A11yHeading extends StatelessWidget {
  const A11yHeading({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: child,
    );
  }
}

// ─── A11yEmptyState ───────────────────────────────────────────────────────────
/// Wraps an empty-state widget so TalkBack reads it as a status announcement
/// rather than silently skipping the decorative emoji.
///
/// ```dart
/// A11yEmptyState(
///   announcement: 'No mistakes logged yet. Log your first mistake to build a review library.',
///   child: _EmptyState(isDark: isDark),
/// )
/// ```
class A11yEmptyState extends StatelessWidget {
  const A11yEmptyState({
    super.key,
    required this.announcement,
    required this.child,
  });

  final String announcement;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: announcement,
      liveRegion: true,
      child: ExcludeSemantics(child: child),
    );
  }
}

// ─── A11yTab ─────────────────────────────────────────────────────────────────
/// A Tab widget with an explicit semantic label. Use when the tab label alone
/// is insufficient (e.g. emoji-only tabs).
class A11yTab extends StatelessWidget {
  const A11yTab({
    super.key,
    required this.label,
    required this.child,
    this.isSelected = false,
  });

  final String label;
  final Widget child;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      selected: isSelected,
      child: ExcludeSemantics(child: child),
    );
  }
}

// ─── Skip-to-content anchor ───────────────────────────────────────────────────
/// Places an invisible focus target at the top of a screen so keyboard/switch
/// users can jump past the AppBar to main content.
///
/// Place this as the FIRST child in your Scaffold body's Column.
class SkipToContent extends StatefulWidget {
  const SkipToContent({super.key, required this.child});

  final Widget child;

  @override
  State<SkipToContent> createState() => _SkipToContentState();
}

class _SkipToContentState extends State<SkipToContent> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Invisible 1px focus target — keyboard users Tab to this first
        SizedBox(
          height: 1,
          child: Focus(
            focusNode: _focusNode,
            child: const SizedBox.shrink(),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
