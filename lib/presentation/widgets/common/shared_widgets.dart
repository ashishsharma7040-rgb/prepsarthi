// lib/presentation/widgets/common/shared_widgets.dart
//
// Shanti Scholar — Redesigned shared widgets.
//
// BACKWARD COMPATIBLE: every constructor signature is identical to the original.
// Barrel exports (gradient_card.dart, main_shell.dart, etc.) require NO changes.
//
// Changes vs original:
//  GradientCard   — richer shadow system; warm sage glow; TappableScale press
//  ProgressRing   — gradient arc with gentle sweep; smoother didUpdateWidget
//  StreakBadge    — Shanti Scholar amber/sage palette; compact remains intact
//  HeatmapWeek   — sage-tinted heat cells; animated cell transitions
//  MainShell      — pill indicator on active item; haptics on every nav tap

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_haptics.dart';
import 'soothing_background.dart';

// ─── GradientCard ─────────────────────────────────────────────────────────────
// API unchanged: child, padding, isDark, gradientColors, onTap, borderRadius
class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool isDark;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;
  final double borderRadius;

  const GradientCard({
    super.key,
    required this.child,
    this.padding,
    this.isDark = false,
    this.gradientColors,
    this.onTap,
    this.borderRadius = 16,
  });

  BoxDecoration _decoration() {
    if (gradientColors != null) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors!,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: gradientColors!.first.withOpacity(isDark ? 0.22 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: isDark ? DarkColors.surfaceCard : LightColors.surfaceCard,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark
            ? DarkColors.outline.withOpacity(0.7)
            : LightColors.outline.withOpacity(0.55),
        width: 0.8,
      ),
      boxShadow: [
        BoxShadow(
          // Sage-tinted shadow — warmer than grey
          color: isDark
              ? Colors.black.withOpacity(0.28)
              : const Color(0xFF5C7A6B).withOpacity(0.06),
          blurRadius: 18,
          offset: const Offset(0, 5),
        ),
        if (!isDark)
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final inner = Container(
      decoration: _decoration(),
      padding: padding,
      child: child,
    );

    if (onTap == null) return inner;

    return TappableScale(
      onTap: onTap,
      pressedScale: 0.97,
      child: inner,
    );
  }
}

// ─── ProgressRing ─────────────────────────────────────────────────────────────
// API unchanged: progress, size, strokeWidth, primaryColor (required),
//                backgroundColor (required), centerWidget, animate
class ProgressRing extends StatefulWidget {
  final double progress; // 0.0 – 1.0
  final double size;
  final double strokeWidth;
  final Color primaryColor;
  final Color backgroundColor;
  final Widget? centerWidget;
  final bool animate;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.size,
    this.strokeWidth = 8,
    required this.primaryColor,
    required this.backgroundColor,
    this.centerWidget,
    this.animate = true,
  });

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    if (widget.animate) _ctrl.forward();
  }

  @override
  void didUpdateWidget(ProgressRing old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (_, __) => Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _ShantiRingPainter(
                progress: widget.animate ? _animation.value : widget.progress,
                primaryColor: widget.primaryColor,
                backgroundColor: widget.backgroundColor,
                strokeWidth: widget.strokeWidth,
              ),
            ),
            if (widget.centerWidget != null) widget.centerWidget!,
          ],
        ),
      ),
    );
  }
}

class _ShantiRingPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color backgroundColor;
  final double strokeWidth;

  const _ShantiRingPainter({
    required this.progress,
    required this.primaryColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  static const _startAngle = -1.5708; // -π/2 (top)
  static const _fullCircle = 6.2832;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final trackPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Track ring
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0, _fullCircle, false, trackPaint,
    );

    if (progress <= 0) return;

    // Gradient progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      _startAngle,
      progress * _fullCircle,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: _startAngle,
          endAngle: _startAngle + _fullCircle,
          colors: [primaryColor.withOpacity(0.45), primaryColor, primaryColor],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ShantiRingPainter old) =>
      old.progress != progress || old.primaryColor != primaryColor;
}

// ─── StreakBadge ──────────────────────────────────────────────────────────────
// API unchanged: streak, isDark
class StreakBadge extends StatelessWidget {
  final int streak;
  final bool isDark;

  const StreakBadge({super.key, required this.streak, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = streak >= 1;
    final isHot    = streak >= 7;

    // Shanti Scholar: warm amber for hot streaks, sage-muted for inactive
    final Color color;
    if (isHot) {
      color = AppColors.gold;               // warm amber
    } else if (isActive) {
      color = isDark ? DarkColors.secondary : LightColors.secondary; // terracotta
    } else {
      color = isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.32), width: 1),
        boxShadow: isHot
            ? [BoxShadow(color: color.withOpacity(0.18), blurRadius: 8)]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isActive ? '🔥' : '💤',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HeatmapWeekWidget ────────────────────────────────────────────────────────
// API unchanged: isDark, weekData
class HeatmapWeekWidget extends StatelessWidget {
  final bool isDark;
  final Map<String, double>? weekData;

  const HeatmapWeekWidget({super.key, required this.isDark, this.weekData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = weekData ?? {
      'Mon': 0.0, 'Tue': 0.0, 'Wed': 0.0,
      'Thu': 0.0, 'Fri': 0.0, 'Sat': 0.0, 'Sun': 0.0,
    };
    final rawMax = data.values.fold(0.0, (a, b) => a > b ? a : b);
    final maxHours = rawMax > 0 ? rawMax : 1.0;

    return GradientCard(
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data.entries.map((entry) {
              final intensity = entry.value / maxHours;
              final isToday = entry.key ==
                  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      [DateTime.now().weekday - 1];
              return _HeatCell(
                label: entry.key,
                hours: entry.value,
                intensity: intensity,
                isToday: isToday,
                isDark: isDark,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            children: [
              Text('Less', style: theme.textTheme.labelSmall),
              const SizedBox(width: 6),
              ...List.generate(5, (i) => Container(
                width: 12, height: 12,
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color: _heatColor(i / 4.0, isDark),
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
              const SizedBox(width: 6),
              Text('More', style: theme.textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  static Color _heatColor(double intensity, bool dark) {
    if (intensity == 0)     return dark ? AppColors.heatEmptyDark : AppColors.heatEmpty;
    if (intensity < 0.25)   return dark ? AppColors.heat1Dark     : AppColors.heat1;
    if (intensity < 0.5)    return dark ? AppColors.heat2Dark     : AppColors.heat2;
    if (intensity < 0.75)   return dark ? AppColors.heat3Dark     : AppColors.heat3;
    return                         dark ? AppColors.heat4Dark     : AppColors.heat4;
  }
}

class _HeatCell extends StatelessWidget {
  final String label;
  final double hours;
  final double intensity;
  final bool isToday;
  final bool isDark;

  const _HeatCell({
    required this.label,
    required this.hours,
    required this.intensity,
    required this.isToday,
    required this.isDark,
  });

  Color _cellColor() {
    if (intensity == 0)    return isDark ? AppColors.heatEmptyDark : AppColors.heatEmpty;
    if (intensity < 0.25)  return isDark ? AppColors.heat1Dark     : AppColors.heat1;
    if (intensity < 0.5)   return isDark ? AppColors.heat2Dark     : AppColors.heat2;
    if (intensity < 0.75)  return isDark ? AppColors.heat3Dark     : AppColors.heat3;
    return                        isDark ? AppColors.heat4Dark     : AppColors.heat4;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isDark ? DarkColors.primary : LightColors.primary;

    return Column(
      children: [
        Tooltip(
          message: '${hours.toStringAsFixed(1)}h',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _cellColor(),
              borderRadius: BorderRadius.circular(9),
              border: isToday
                  ? Border.all(color: accent, width: 2)
                  : Border.all(color: Colors.transparent),
            ),
            child: isToday
                ? Center(
                    child: Text(
                      '${hours.toStringAsFixed(0)}h',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
            color: isToday ? accent : null,
          ),
        ),
      ],
    );
  }
}

// ─── MainShell — Bottom Navigation ────────────────────────────────────────────
// API unchanged: child
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/dashboard')) return 0;
    if (loc.startsWith('/plan'))      return 1;
    if (loc.startsWith('/log'))       return 2;
    if (loc.startsWith('/revision'))  return 3;
    if (loc.startsWith('/calendar'))  return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedIndex = _selectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : LightColors.surface,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? DarkColors.outline.withOpacity(0.5)
                  : LightColors.outline.withOpacity(0.5),
              width: 0.8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  outlinedIcon: Icons.dashboard_outlined,
                  label: 'Home',
                  selected: selectedIndex == 0,
                  onTap: () {
                    AppHaptics.navTap();
                    context.go('/dashboard');
                  },
                  isDark: isDark,
                ),
                _NavItem(
                  icon: Icons.list_alt_rounded,
                  outlinedIcon: Icons.list_alt_outlined,
                  label: 'Plan',
                  selected: selectedIndex == 1,
                  onTap: () {
                    AppHaptics.navTap();
                    context.go('/plan');
                  },
                  isDark: isDark,
                ),
                _NavItem(
                  icon: Icons.edit_note_rounded,
                  outlinedIcon: Icons.edit_note_outlined,
                  label: 'Log',
                  selected: selectedIndex == 2,
                  onTap: () {
                    AppHaptics.navTap();
                    context.go('/log');
                  },
                  isDark: isDark,
                ),
                _NavItem(
                  icon: Icons.replay_rounded,
                  outlinedIcon: Icons.replay_outlined,
                  label: 'Revision',
                  selected: selectedIndex == 3,
                  onTap: () {
                    AppHaptics.navTap();
                    context.go('/revision');
                  },
                  isDark: isDark,
                ),
                _NavItem(
                  icon: Icons.more_horiz_rounded,
                  outlinedIcon: Icons.more_horiz_outlined,
                  label: 'More',
                  selected: selectedIndex == 4,
                  onTap: () {
                    AppHaptics.navTap();
                    context.go('/calendar');
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _NavItem({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor   = isDark ? DarkColors.primary : LightColors.primary;
    final inactiveColor = isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pill indicator with animated container
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: selected
                  ? BoxDecoration(
                      color: activeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: AnimatedScale(
                scale: selected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: Icon(
                  selected ? icon : outlinedIcon,
                  color: selected ? activeColor : inactiveColor,
                  size: 23,
                ),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
                color: selected ? activeColor : inactiveColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 10.5,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
