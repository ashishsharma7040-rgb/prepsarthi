// lib/presentation/widgets/common/skeleton_loader.dart
//
// Soothing skeleton loaders — Shanti Scholar edition.
// Uses pure Flutter (TweenAnimationBuilder + ShaderMask).
// No external shimmer package required.
//
// Usage:
//   SkeletonLoader.card()                    → single card placeholder
//   SkeletonLoader.list(itemCount: 4)        → vertical list of rows
//   SkeletonLoader.dashboardHeader()         → greeting + streak row
//   SkeletonLoader.stats()                   → ring + stat cards
//   SkeletonLoader.chips(itemCount: 5)       → horizontal chip row
//
//   // Wrap real content for smooth skeleton → content fade:
//   SkeletonFade(
//     isLoading: isLoading,
//     skeleton: SkeletonLoader.card(),
//     child: RealWidget(),
//   )

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

// ─── Base Shimmer Box ─────────────────────────────────────────────────────────
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 10,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _shimmer = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF2A3035) : const Color(0xFFEDE9E1);
    final highlight = isDark ? const Color(0xFF363E44) : const Color(0xFFF5F3EE);

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) => ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment(_shimmer.value - 1, 0),
          end: Alignment(_shimmer.value + 1, 0),
          colors: [base, highlight, base],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds),
        blendMode: BlendMode.srcATop,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}

// ─── Shimmer Circle ───────────────────────────────────────────────────────────
class SkeletonCircle extends StatelessWidget {
  final double size;
  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) =>
      SkeletonBox(width: size, height: size, radius: size / 2);
}

// ─── Factory Widget ───────────────────────────────────────────────────────────
class SkeletonLoader extends StatelessWidget {
  final _SkeletonVariant _variant;
  final int _itemCount;

  const SkeletonLoader._({required _SkeletonVariant variant, int itemCount = 4})
      : _variant = variant,
        _itemCount = itemCount;

  factory SkeletonLoader.card() =>
      const SkeletonLoader._(variant: _SkeletonVariant.card);

  factory SkeletonLoader.list({int itemCount = 4}) =>
      SkeletonLoader._(variant: _SkeletonVariant.list, itemCount: itemCount);

  factory SkeletonLoader.dashboardHeader() =>
      const SkeletonLoader._(variant: _SkeletonVariant.dashboardHeader);

  factory SkeletonLoader.stats() =>
      const SkeletonLoader._(variant: _SkeletonVariant.stats);

  factory SkeletonLoader.chips({int itemCount = 5}) =>
      SkeletonLoader._(variant: _SkeletonVariant.chips, itemCount: itemCount);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (_variant) {
      case _SkeletonVariant.card:
        return _CardSkeleton(isDark: isDark);
      case _SkeletonVariant.list:
        return _ListSkeleton(isDark: isDark, count: _itemCount);
      case _SkeletonVariant.dashboardHeader:
        return _DashHeaderSkeleton(isDark: isDark);
      case _SkeletonVariant.stats:
        return _StatsSkeleton(isDark: isDark);
      case _SkeletonVariant.chips:
        return _ChipsSkeleton(isDark: isDark, count: _itemCount);
    }
  }
}

enum _SkeletonVariant { card, list, dashboardHeader, stats, chips }

// ─── Card Skeleton ────────────────────────────────────────────────────────────
class _CardSkeleton extends StatelessWidget {
  final bool isDark;
  const _CardSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardColor =
        isDark ? DarkColors.surfaceCard : LightColors.surfaceCard;
    final borderColor = isDark
        ? DarkColors.outline.withOpacity(0.4)
        : LightColors.outline.withOpacity(0.4);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonCircle(size: 40),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 120, height: 13),
                  SizedBox(height: 6),
                  SkeletonBox(width: 80, height: 10),
                ],
              ),
              const Spacer(),
              const SkeletonBox(width: 50, height: 26, radius: 20),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonBox(width: double.infinity, height: 11),
          const SizedBox(height: 7),
          const SkeletonBox(width: 200, height: 11),
          const SizedBox(height: 14),
          const SkeletonBox(width: double.infinity, height: 7, radius: 100),
        ],
      ),
    );
  }
}

// ─── List Skeleton ────────────────────────────────────────────────────────────
class _ListSkeleton extends StatelessWidget {
  final bool isDark;
  final int count;
  const _ListSkeleton({required this.isDark, required this.count});

  @override
  Widget build(BuildContext context) {
    final cardColor =
        isDark ? DarkColors.surfaceCard : LightColors.surfaceCard;
    final leftColor = isDark ? DarkColors.outline : LightColors.outline;

    return Column(
      children: List.generate(count, (i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(color: leftColor.withOpacity(0.5), width: 2.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: i.isEven ? 200.0 : 160.0, height: 12),
                    const SizedBox(height: 6),
                    const SkeletonBox(width: 100, height: 10),
                  ],
                ),
              ),
              const SkeletonCircle(size: 36),
            ],
          ),
        ),
      )),
    );
  }
}

// ─── Dashboard Header Skeleton ────────────────────────────────────────────────
class _DashHeaderSkeleton extends StatelessWidget {
  final bool isDark;
  const _DashHeaderSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          SkeletonBox(width: 190, height: 20),
          SizedBox(height: 10),
          Row(
            children: [
              SkeletonBox(width: 110, height: 30, radius: 20),
              SizedBox(width: 10),
              SkeletonBox(width: 70, height: 30, radius: 20),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Stats Skeleton ───────────────────────────────────────────────────────────
class _StatsSkeleton extends StatelessWidget {
  final bool isDark;
  const _StatsSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SkeletonCircle(size: 120),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 80, height: 28),
                SizedBox(height: 8),
                SkeletonBox(width: 120, height: 12),
                SizedBox(height: 6),
                SkeletonBox(width: 100, height: 10),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        _CardSkeleton(isDark: isDark),
        const SizedBox(height: 12),
        _CardSkeleton(isDark: isDark),
      ],
    );
  }
}

// ─── Chips Skeleton ───────────────────────────────────────────────────────────
class _ChipsSkeleton extends StatelessWidget {
  final bool isDark;
  final int count;
  const _ChipsSkeleton({required this.isDark, required this.count});

  @override
  Widget build(BuildContext context) {
    const widths = [72.0, 90.0, 60.0, 84.0, 70.0, 88.0, 65.0];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(count, (i) => SkeletonBox(
        width: widths[i % widths.length],
        height: 34,
        radius: 20,
      )),
    );
  }
}

// ─── SkeletonFade — smooth skeleton → content transition ─────────────────────
class SkeletonFade extends StatelessWidget {
  final bool isLoading;
  final Widget skeleton;
  final Widget child;

  const SkeletonFade({
    super.key,
    required this.isLoading,
    required this.skeleton,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: isLoading
          ? KeyedSubtree(key: const ValueKey('sk'), child: skeleton)
          : KeyedSubtree(key: const ValueKey('cn'), child: child),
    );
  }
}
