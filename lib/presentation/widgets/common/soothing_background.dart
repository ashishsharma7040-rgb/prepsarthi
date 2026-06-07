// lib/presentation/widgets/common/soothing_background.dart
//
// SoothingBackground — Visual atmosphere layer for PrepSarthi Shanti Scholar.
//
// Visual layers (bottom → top):
//  1. Warm gradient base      (barely perceptible; adapts per screen variant)
//  2. Rangoli-inspired dots   (CustomPainter; ~3.5% opacity — almost invisible)
//  3. Two slow ambient blobs  (organic warmth; home/onboarding only, 18–22s cycle)
//  4. Child content           (your actual page)
//
// Usage:
//   // Wraps the body of dashboard, login, results screens
//   SoothingBackground(
//     variant: BackgroundVariant.home,
//     child: YourScrollableContent(),
//   )
//
//   // Quiz / test — no distractions
//   SoothingBackground(
//     variant: BackgroundVariant.quiz,
//     enableBlobs: false,
//     enableDotPattern: false,
//     child: QuizContent(),
//   )

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

// ─── Screen Variant ───────────────────────────────────────────────────────────
enum BackgroundVariant {
  home,        // Full experience — gradient + dots + blobs
  quiz,        // Minimal, distraction-free (no dots, no blobs)
  results,     // Soft radial celebration gradient
  profile,     // Warm surface gradient + blobs
  onboarding,  // Hero — slightly stronger gradient + blobs
}

// ─── SoothingBackground ───────────────────────────────────────────────────────
class SoothingBackground extends StatefulWidget {
  final Widget child;
  final BackgroundVariant variant;
  final bool enableBlobs;
  final bool enableDotPattern;

  const SoothingBackground({
    super.key,
    required this.child,
    this.variant = BackgroundVariant.home,
    this.enableBlobs = true,
    this.enableDotPattern = true,
  });

  @override
  State<SoothingBackground> createState() => _SoothingBackgroundState();
}

class _SoothingBackgroundState extends State<SoothingBackground>
    with TickerProviderStateMixin {
  late AnimationController _blob1Ctrl;
  late AnimationController _blob2Ctrl;
  late Animation<Offset> _blob1Offset;
  late Animation<Offset> _blob2Offset;

  @override
  void initState() {
    super.initState();

    // Blob 1 — drifts top-right → slightly down-left (18s cycle)
    _blob1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    _blob1Offset = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(18, 12))
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(18, 12), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
    ]).animate(_blob1Ctrl);

    // Blob 2 — opposite phase (22s cycle)
    _blob2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    );
    _blob2Offset = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(-16, -10))
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-16, -10), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
    ]).animate(_blob2Ctrl);

    if (widget.enableBlobs && _blobsVisible) {
      _blob1Ctrl.repeat();
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) _blob2Ctrl.repeat();
      });
    }
  }

  bool get _blobsVisible =>
      widget.variant == BackgroundVariant.home ||
      widget.variant == BackgroundVariant.onboarding ||
      widget.variant == BackgroundVariant.profile;

  @override
  void dispose() {
    _blob1Ctrl.dispose();
    _blob2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // ── Layer 1: Gradient base ──────────────────────────────────────────
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: _gradientDecoration(isDark),
          ),
        ),

        // ── Layer 2: Rangoli micro-dot pattern ──────────────────────────────
        if (widget.enableDotPattern && widget.variant != BackgroundVariant.quiz)
          Positioned.fill(
            child: CustomPaint(painter: _DotPatternPainter(isDark: isDark)),
          ),

        // ── Layer 3: Ambient blobs ──────────────────────────────────────────
        if (widget.enableBlobs && _blobsVisible) ...[
          // Blob 1 — top-right (sage tint)
          AnimatedBuilder(
            animation: _blob1Offset,
            builder: (_, __) => Positioned(
              top: -80 + _blob1Offset.value.dy,
              right: -60 + _blob1Offset.value.dx,
              child: _AmbientBlob(
                size: 270,
                color: isDark
                    ? DarkColors.primary.withOpacity(0.07)
                    : LightColors.primary.withOpacity(0.09),
              ),
            ),
          ),
          // Blob 2 — bottom-left (terracotta tint)
          AnimatedBuilder(
            animation: _blob2Offset,
            builder: (_, __) => Positioned(
              bottom: -90 + _blob2Offset.value.dy,
              left: -70 + _blob2Offset.value.dx,
              child: _AmbientBlob(
                size: 230,
                color: isDark
                    ? DarkColors.secondary.withOpacity(0.06)
                    : LightColors.secondary.withOpacity(0.07),
              ),
            ),
          ),
        ],

        // ── Layer 4: Content ────────────────────────────────────────────────
        Positioned.fill(child: widget.child),
      ],
    );
  }

  BoxDecoration _gradientDecoration(bool isDark) {
    switch (widget.variant) {
      case BackgroundVariant.quiz:
        return BoxDecoration(
          color: isDark ? DarkColors.background : const Color(0xFFFDFCF8),
        );
      case BackgroundVariant.results:
        return BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: isDark
                ? [DarkColors.primaryContainer, DarkColors.background]
                : [LightColors.primaryContainer, const Color(0xFFF5F3EE)],
          ),
        );
      case BackgroundVariant.onboarding:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [DarkColors.background, const Color(0xFF1A2428)]
                : [const Color(0xFFEDF5F0), const Color(0xFFF5F3EE)],
          ),
        );
      default: // home, profile
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [DarkColors.background, const Color(0xFF1F2428)]
                : [const Color(0xFFF5F3EE), const Color(0xFFEDE9E1)],
            stops: const [0.0, 1.0],
          ),
        );
    }
  }
}

// ─── Ambient Blob ─────────────────────────────────────────────────────────────
class _AmbientBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _AmbientBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

// ─── Rangoli Micro-Dot Pattern Painter ───────────────────────────────────────
// Staggered grid of tiny dots at ~3.5% opacity.
// Inspired by kolam rangoli — orderly dots that feel calm, not busy.
class _DotPatternPainter extends CustomPainter {
  final bool isDark;
  static const _spacing = 22.0;
  static const _dotRadius = 1.1;

  const _DotPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.028)
          : const Color(0xFF5C7A6B).withOpacity(0.055)
      ..style = PaintingStyle.fill;

    final cols = (size.width / _spacing).ceil() + 1;
    final rows = (size.height / _spacing).ceil() + 1;

    for (var r = 0; r < rows; r++) {
      final y = r * _spacing;
      // Offset alternate rows for a staggered, rangoli-like grid
      final xShift = (r.isOdd) ? _spacing / 2 : 0.0;
      for (var c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset(c * _spacing + xShift, y),
          _dotRadius,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DotPatternPainter old) => old.isDark != isDark;
}

// ─── TappableScale — gentle press-down feedback ───────────────────────────────
// Replaces plain GestureDetector wherever you want a 96% scale-on-press feel.
class TappableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final Duration duration;

  const TappableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.96,
    this.duration = const Duration(milliseconds: 110),
  });

  @override
  State<TappableScale> createState() => _TappableScaleState();
}

class _TappableScaleState extends State<TappableScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween(begin: 1.0, end: widget.pressedScale).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}
