import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class PremiumIntroScreen extends StatefulWidget {
  final String statusText;

  const PremiumIntroScreen({
    super.key,
    required this.statusText,
  });

  @override
  State<PremiumIntroScreen> createState() => _PremiumIntroScreenState();
}

class _PremiumIntroScreenState extends State<PremiumIntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotsController;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? DarkColors.primary : LightColors.primary;
    final secondary = isDark ? DarkColors.secondary : LightColors.secondary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
                    Color(0xFF0A192F),
                    Color(0xFF10233F),
                    Color(0xFF0A192F),
                  ]
                : const [
                    Color(0xFFFFFFFF),
                    Color(0xFFF2FFFC),
                    Color(0xFFE8FAF7),
                  ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: _DecorCircle(
                size: 240,
                color: primary.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: _DecorCircle(
                size: 280,
                color: secondary.withValues(alpha: 0.08),
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: _showContent ? 1 : 0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        child: AnimatedScale(
                          scale: _showContent ? 1 : 0.9,
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutBack,
                          child:
                              _LogoCard(primary: primary, secondary: secondary),
                        ),
                      ),
                      const SizedBox(height: 28),
                      AnimatedSlide(
                        offset:
                            _showContent ? Offset.zero : const Offset(0, 0.08),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        child: AnimatedOpacity(
                          opacity: _showContent ? 1 : 0,
                          duration: const Duration(milliseconds: 500),
                          child: ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [primary, secondary],
                            ).createShader(bounds),
                            child: Text(
                              'PrepSarthi',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedOpacity(
                        opacity: _showContent ? 1 : 0,
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOut,
                        child: Text(
                          'Your smart study companion',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: isDark
                                        ? DarkColors.onSurfaceVariant
                                        : LightColors.onSurfaceVariant,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 56),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          widget.statusText,
                          key: ValueKey(widget.statusText),
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: isDark
                                        ? DarkColors.onSurfaceVariant
                                        : LightColors.onSurfaceVariant,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _AnimatedDots(
                        controller: _dotsController,
                        color: primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _LogoCard extends StatelessWidget {
  final Color primary;
  final Color secondary;

  const _LogoCard({
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, secondary],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.28),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        size: 50,
        color: Colors.white,
      ),
    );
  }
}

class _AnimatedDots extends StatelessWidget {
  final AnimationController controller;
  final Color color;

  const _AnimatedDots({
    required this.controller,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final offset = (controller.value - index * 0.18).clamp(0.0, 1.0);
            final pulse = offset < 0.5 ? offset * 2 : (1 - offset) * 2;
            final scale = 1 + (pulse * 0.35);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(
                      alpha: 0.45 + (pulse * 0.4),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
