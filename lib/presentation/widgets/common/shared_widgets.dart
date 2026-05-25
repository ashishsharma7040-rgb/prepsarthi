// lib/presentation/widgets/common/shared_widgets.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradientColors != null
              ? LinearGradient(
                  colors: gradientColors!,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: gradientColors == null
              ? (isDark ? DarkColors.surfaceCard : LightColors.surface)
              : null,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isDark ? DarkColors.outline : LightColors.outline,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/presentation/widgets/common/progress_ring.dart
// ─────────────────────────────────────────────────────────────────────────────

class ProgressRing extends StatefulWidget {
  final double progress; // 0.0 to 1.0
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
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    if (widget.animate) _ctrl.forward();
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
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: widget.animate ? _animation.value : widget.progress,
                  primaryColor: widget.primaryColor,
                  backgroundColor: widget.backgroundColor,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
              if (widget.centerWidget != null) widget.centerWidget!,
            ],
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color backgroundColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.primaryColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Gradient progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -1.5708, // -π/2 (start from top)
      endAngle: -1.5708 + 6.2832, // full circle
      colors: [
        primaryColor.withOpacity(0.5),
        primaryColor,
      ],
      stops: const [0.0, 1.0],
    );

    canvas.drawArc(
      rect,
      -1.5708, // start at top
      progress * 6.2832, // end angle
      false,
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/presentation/widgets/common/streak_badge.dart
// ─────────────────────────────────────────────────────────────────────────────

class StreakBadge extends StatelessWidget {
  final int streak;
  final bool isDark;

  const StreakBadge({super.key, required this.streak, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = streak >= 7 ? const Color(0xFFFF8C00) : const Color(0xFF94A3B8);
    // Compact horizontal layout — avoids 42px overflow in the FlexibleSpaceBar
    // when greeting text + countdown chip + badge all compete for width.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
        boxShadow: streak >= 7
            ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 6)]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            streak >= 1 ? '🔥' : '💤',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color, fontWeight: FontWeight.w800, fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/presentation/widgets/common/heatmap_week.dart
// Weekly heatmap (GitHub-style) for this week's study hours
// ─────────────────────────────────────────────────────────────────────────────

class HeatmapWeekWidget extends StatelessWidget {
  final bool isDark;
  final Map<String, double>? weekData;

  const HeatmapWeekWidget({super.key, required this.isDark, this.weekData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Uses real data passed from provider; defaults to zeros if none yet
    final data = weekData ?? {
      'Mon': 0.0, 'Tue': 0.0, 'Wed': 0.0,
      'Thu': 0.0, 'Fri': 0.0, 'Sat': 0.0, 'Sun': 0.0,
    };
    final rawMax = data.values.fold(0.0, (a, b) => a > b ? a : b);
    final maxHours = rawMax > 0 ? rawMax : 1.0; // avoid divide-by-zero

    return GradientCard(
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data.entries.map((entry) {
              final intensity = maxHours > 0 ? entry.value / maxHours : 0.0;
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
          Row(
            children: [
              Text('Less', style: theme.textTheme.labelSmall),
              const SizedBox(width: 6),
              ...List.generate(5, (i) {
                final color = _heatColor(i / 4, isDark);
                return Container(
                  width: 12, height: 12,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
              const SizedBox(width: 6),
              Text('More', style: theme.textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Color _heatColor(double intensity, bool dark) {
    if (intensity == 0) return dark ? AppColors.heatEmptyDark : AppColors.heatEmpty;
    if (intensity < 0.25) return dark ? AppColors.heat1Dark : AppColors.heat1;
    if (intensity < 0.5) return dark ? AppColors.heat2Dark : AppColors.heat2;
    if (intensity < 0.75) return dark ? AppColors.heat3Dark : AppColors.heat3;
    return dark ? AppColors.heat4Dark : AppColors.heat4;
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

  Color _heatColor() {
    if (intensity == 0) return isDark ? AppColors.heatEmptyDark : AppColors.heatEmpty;
    if (intensity < 0.25) return isDark ? AppColors.heat1Dark : AppColors.heat1;
    if (intensity < 0.5) return isDark ? AppColors.heat2Dark : AppColors.heat2;
    if (intensity < 0.75) return isDark ? AppColors.heat3Dark : AppColors.heat3;
    return isDark ? AppColors.heat4Dark : AppColors.heat4;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cellColor = _heatColor();
    final accent = isDark ? DarkColors.primary : LightColors.primary;

    return Column(
      children: [
        Tooltip(
          message: '${hours.toStringAsFixed(1)}h',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cellColor,
              borderRadius: BorderRadius.circular(8),
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

// ─────────────────────────────────────────────────────────────────────────────
// Main Shell (Bottom Navigation)
// ─────────────────────────────────────────────────────────────────────────────

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/dashboard')) return 0;
    if (loc.startsWith('/plan')) return 1;
    if (loc.startsWith('/log')) return 2;
    if (loc.startsWith('/revision')) return 3;
    if (loc.startsWith('/calendar')) return 4;
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
              color: isDark ? DarkColors.outline : LightColors.outline,
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
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
                _NavItem(icon: Icons.dashboard_rounded, label: 'Home',
                    selected: selectedIndex == 0,
                    onTap: () => context.go('/dashboard'), isDark: isDark),
                _NavItem(icon: Icons.list_alt_rounded, label: 'Plan',
                    selected: selectedIndex == 1,
                    onTap: () => context.go('/plan'), isDark: isDark),
                _NavItem(icon: Icons.edit_note_rounded, label: 'Log',
                    selected: selectedIndex == 2,
                    onTap: () => context.go('/log'), isDark: isDark),
                _NavItem(icon: Icons.replay_rounded, label: 'Revision',
                    selected: selectedIndex == 3,
                    onTap: () => context.go('/revision'), isDark: isDark),
                _NavItem(icon: Icons.more_horiz_rounded, label: 'More',
                    selected: selectedIndex == 4,
                    onTap: () => context.go('/calendar'), isDark: isDark),
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
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = isDark ? DarkColors.primary : LightColors.primary;
    final inactiveColor = isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: selected
            ? BoxDecoration(
                color: activeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: selected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: selected ? activeColor : inactiveColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: selected ? activeColor : inactiveColor,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

