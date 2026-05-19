// lib/presentation/screens/onboarding/onboarding_screens.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../router/app_router.dart';
import '../../providers/all_providers.dart';

// ═══════════════════════════════════════════════════════════════════════════
// WELCOME SCREEN
// ═══════════════════════════════════════════════════════════════════════════
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _StepDots(current: 0, total: 4, isDark: isDark)
                  .animate().fadeIn(duration: 400.ms),
              const Spacer(flex: 1),
              Center(
                child: Text('🚀', style: const TextStyle(fontSize: 90))
                    .animate()
                    .scale(begin: const Offset(0, 0), duration: 800.ms, curve: Curves.elasticOut)
                    .then()
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: 0, end: -12, duration: 1800.ms, curve: Curves.easeInOut),
              ),
              const Spacer(flex: 1),
              Text('Let\'s build your\nperfect study plan',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800, height: 1.2,
                  )).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),
              const SizedBox(height: 16),
              Text(
                'We\'ll create a personalised AI-powered planner based on your target, timeline, and daily availability.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant,
                  height: 1.6,
                ),
              ).animate(delay: 450.ms).fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 28),
              ...[
                ('📅', '6–18 month personalised timeline'),
                ('⚖️', 'Chapters weighted by exam importance'),
                ('🔄', 'Spaced revision built in automatically'),
              ].asMap().entries.map((e) =>
                  _FeatureBullet(emoji: e.value.$1, text: e.value.$2, isDark: isDark)
                      .animate(delay: (500 + e.key * 100).ms).fadeIn().slideX(begin: -0.1)),
              const Spacer(flex: 2),
              FilledButton(
                onPressed: () => context.go(AppRoutes.targetSelector),
                child: const Text('Get Started'),
              ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.4),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TARGET SELECTOR SCREEN
// ═══════════════════════════════════════════════════════════════════════════
class TargetSelectorScreen extends ConsumerStatefulWidget {
  const TargetSelectorScreen({super.key});
  @override
  ConsumerState<TargetSelectorScreen> createState() => _TargetSelectorScreenState();
}

class _TargetSelectorScreenState extends ConsumerState<TargetSelectorScreen> {
  String? _selected;

  final _targets = [
    _Target('jee_main', '📐', 'JEE Main', 'Engineering entrance – NTA', 'Physics, Chemistry, Mathematics'),
    _Target('jee_advanced', '🏆', 'JEE Advanced', 'IIT entrance – prestigious', 'Physics, Chemistry, Mathematics'),
    _Target('neet', '🩺', 'NEET UG', 'Medical entrance – NMC', 'Physics, Chemistry, Biology'),
    _Target('both', '🎯', 'JEE + NEET', 'Attempting both exams', 'Physics, Chemistry, Maths + Bio'),
    _Target('class12_boards', '📚', 'Class 12 + Boards', 'Board exam focus first', 'All NCERT subjects'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OnboardingAppBar(onBack: () => context.pop()),
              const SizedBox(height: 8),
              _StepDots(current: 1, total: 4, isDark: isDark),
              const SizedBox(height: 28),
              Text('What\'s your\ntarget exam? 🎯',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800, height: 1.25,
                  )).animate().fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 8),
              Text(
                'This helps us load the right syllabus and weigh chapters correctly.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant,
                ),
              ).animate(delay: 100.ms).fadeIn(),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: _targets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final t = _targets[i];
                    return _TargetCard(
                      target: t,
                      selected: _selected == t.id,
                      isDark: isDark,
                      onTap: () => setState(() => _selected = t.id),
                    ).animate(delay: (i * 70).ms).fadeIn().slideX(begin: 0.08);
                  },
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _selected == null ? null : () {
                  ref.read(onboardingProvider.notifier).setTarget(_selected!);
                  context.go(AppRoutes.examYear);
                },
                child: const Text('Continue'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _Target {
  final String id, emoji, title, subtitle, subjects;
  const _Target(this.id, this.emoji, this.title, this.subtitle, this.subjects);
}

class _TargetCard extends StatelessWidget {
  final _Target target;
  final bool selected, isDark;
  final VoidCallback onTap;
  const _TargetCard({required this.target, required this.selected, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isDark ? DarkColors.primary : LightColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.1) : (isDark ? DarkColors.surfaceCard : LightColors.surface),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? accent : (isDark ? DarkColors.outline : LightColors.outline), width: selected ? 2 : 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: accent.withOpacity(0.12), borderRadius: BorderRadius.circular(13)),
              child: Center(child: Text(target.emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(target.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  Text(target.subtitle, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 3),
                  Text(target.subjects, style: theme.textTheme.labelSmall?.copyWith(color: accent)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? accent : Colors.transparent,
                border: Border.all(color: selected ? accent : (isDark ? DarkColors.outline : LightColors.outline), width: 2),
              ),
              child: selected ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAM YEAR SCREEN
// ═══════════════════════════════════════════════════════════════════════════
class ExamYearScreen extends ConsumerStatefulWidget {
  const ExamYearScreen({super.key});
  @override
  ConsumerState<ExamYearScreen> createState() => _ExamYearScreenState();
}

class _ExamYearScreenState extends ConsumerState<ExamYearScreen> {
  String? _selected;
  final _years = ['2025', '2026', '2027', '2028', '2029', '2030'];

  String _daysLeft(String year) {
    final ob = ref.read(onboardingProvider);
    final isNeet = ob.targetExam == 'neet';
    final examDate = DateTime(int.parse(year), isNeet ? 5 : 4, isNeet ? 5 : 15);
    final diff = examDate.difference(DateTime.now()).inDays;
    if (diff <= 0) return 'Past';
    return '$diff days left';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? DarkColors.primary : LightColors.primary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OnboardingAppBar(onBack: () => context.pop()),
              const SizedBox(height: 8),
              _StepDots(current: 2, total: 4, isDark: isDark),
              const SizedBox(height: 28),
              Text('When is your\nexam? 📅',
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, height: 1.25))
                  .animate().fadeIn(),
              const SizedBox(height: 8),
              Text(
                'We\'ll count down the days and calibrate your plan intensity.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant,
                ),
              ).animate(delay: 100.ms).fadeIn(),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: _years.asMap().entries.map((e) {
                    final year = e.value;
                    final sel = _selected == year;
                    final daysLeft = _daysLeft(year);
                    final isPast = daysLeft == 'Past';
                    return GestureDetector(
                      onTap: isPast ? null : () => setState(() => _selected = year),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: sel ? accent : (isDark ? DarkColors.surfaceCard : LightColors.surface),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: sel ? accent : (isDark ? DarkColors.outline : LightColors.outline),
                            width: sel ? 2 : 0.5,
                          ),
                          boxShadow: sel ? [BoxShadow(color: accent.withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 4))] : null,
                        ),
                        child: Opacity(
                          opacity: isPast ? 0.4 : 1.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(year,
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: sel ? Colors.white : null,
                                  )),
                              const SizedBox(height: 4),
                              Text(daysLeft,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: sel ? Colors.white70 : null,
                                  )),
                            ],
                          ),
                        ),
                      ).animate(delay: (e.key * 70).ms).fadeIn().scale(begin: const Offset(0.88, 0.88)),
                    );
                  }).toList(),
                ),
              ),
              FilledButton(
                onPressed: _selected == null ? null : () {
                  ref.read(onboardingProvider.notifier).setYear(_selected!);
                  context.go(AppRoutes.dailyHours);
                },
                child: const Text('Continue'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DAILY HOURS SCREEN
// ═══════════════════════════════════════════════════════════════════════════
class DailyHoursScreen extends ConsumerStatefulWidget {
  const DailyHoursScreen({super.key});
  @override
  ConsumerState<DailyHoursScreen> createState() => _DailyHoursScreenState();
}

class _DailyHoursScreenState extends ConsumerState<DailyHoursScreen> {
  double _hours = 6.0;

  String _hoursLabel() {
    if (_hours <= 3) return 'Light — balancing school & study';
    if (_hours <= 5) return 'Moderate — solid foundation!';
    if (_hours <= 7) return 'Dedicated aspirant 💪';
    if (_hours <= 9) return 'Intense — brilliant commitment!';
    return 'Full throttle — respect! 🔥';
  }

  String _emoji() {
    if (_hours <= 3) return '🌱';
    if (_hours <= 5) return '📚';
    if (_hours <= 7) return '⚡';
    if (_hours <= 9) return '🚀';
    return '🏆';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? DarkColors.primary : LightColors.primary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OnboardingAppBar(onBack: () => context.pop()),
              const SizedBox(height: 8),
              _StepDots(current: 3, total: 4, isDark: isDark),
              const SizedBox(height: 28),
              Text('How many hours\ncan you study daily? ⏱️',
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, height: 1.25))
                  .animate().fadeIn(),
              const SizedBox(height: 8),
              Text(
                'Be realistic — the plan adapts over time based on your actual pace.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant,
                ),
              ).animate(delay: 100.ms).fadeIn(),
              const Spacer(flex: 1),
              Center(
                child: Column(
                  children: [
                    Text(_emoji(), style: const TextStyle(fontSize: 72))
                        .animate(key: ValueKey(_emoji()))
                        .scale(begin: const Offset(0.5, 0.5), duration: 300.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 14),
                    Text(
                      '${_hours.toStringAsFixed(1)} hrs/day',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: isDark ? DarkColors.gradientPrimary : LightColors.gradientPrimary,
                          ).createShader(const Rect.fromLTWH(0, 0, 220, 80)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(_hoursLabel(),
                        style: theme.textTheme.titleMedium?.copyWith(color: accent, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 13),
                  activeTrackColor: accent,
                  inactiveTrackColor: isDark ? DarkColors.outline : LightColors.outline,
                  thumbColor: accent,
                  overlayColor: accent.withOpacity(0.2),
                ),
                child: Slider(
                  value: _hours, min: 2.0, max: 12.0, divisions: 20,
                  label: '${_hours.toStringAsFixed(1)}h',
                  onChanged: (v) => setState(() => _hours = v),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('2 hrs', style: theme.textTheme.labelSmall),
                  Text('12 hrs', style: theme.textTheme.labelSmall),
                ],
              ),
              const Spacer(flex: 2),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '4–6 focused hours with proper revision beats 10 hours of distracted studying.',
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  ref.read(onboardingProvider.notifier).setHours(_hours);
                  context.go(AppRoutes.generatingPlan);
                },
                child: const Text('Generate My Plan 🚀'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GENERATING PLAN SCREEN — fully wired
// ═══════════════════════════════════════════════════════════════════════════
class GeneratingPlanScreen extends ConsumerStatefulWidget {
  const GeneratingPlanScreen({super.key});
  @override
  ConsumerState<GeneratingPlanScreen> createState() => _GeneratingPlanScreenState();
}

class _GeneratingPlanScreenState extends ConsumerState<GeneratingPlanScreen> {
  int _step = 0;
  String? _error;
  bool _done = false;

  final _steps = [
    '📥  Loading your syllabus...',
    '⚖️  Calculating chapter priorities...',
    '📅  Building your timeline...',
    '🔄  Scheduling revision sessions...',
    '🧪  Adding mock test days...',
    '✅  Plan ready! Let\'s go!',
  ];

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    // Animate steps while plan generates in background
    final ob = ref.read(onboardingProvider);
    final auth = ref.read(authProvider);

    // Validate
    if (ob.examDate == null || auth.user == null) {
      setState(() => _error = 'Missing exam details. Please go back and try again.');
      return;
    }

    // Save onboarding data to user record
    await ref.read(authProvider.notifier).updateOnboarding(
      targetExam: ob.targetExam ?? 'jee_main',
      examYear: ob.examYear ?? '2027',
      dailyHours: ob.dailyHours,
      examDate: ob.examDate!,
    );

    // Animate steps with slight delay each
    for (int i = 0; i < _steps.length - 1; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() => _step = i + 1);
    }

    // Actually generate the plan
    try {
      await ref.read(planProvider.notifier).generatePlan(
        examDate: ob.examDate!,
        dailyHours: ob.dailyHours,
        blackoutDates: ob.blackoutDates,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Plan generation failed: $e');
      return;
    }

    setState(() => _done = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? DarkColors.primary : LightColors.primary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              if (_error != null) ...[
                const Text('😵', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text('Something went wrong', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: LightColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: LightColors.error.withOpacity(0.3)),
                  ),
                  child: Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: LightColors.error)),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => context.go(AppRoutes.dailyHours),
                  child: const Text('Go Back & Retry'),
                ),
              ] else ...[
                SizedBox(
                  width: 110, height: 110,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: (_step + 1) / _steps.length),
                    duration: const Duration(milliseconds: 600),
                    builder: (_, value, __) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 8,
                      backgroundColor: isDark ? DarkColors.outline : LightColors.outline,
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ).animate().scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: 36),
                Text('Building your\npersonalised plan',
                    style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, height: 1.3),
                    textAlign: TextAlign.center)
                    .animate().fadeIn(duration: 500.ms),

                const SizedBox(height: 28),
                ..._steps.asMap().entries.map((e) {
                  final done = e.key < _step;
                  final active = e.key == _step;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: e.key <= _step ? 1.0 : 0.3,
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done ? accent : Colors.transparent,
                              border: Border.all(
                                color: active ? accent : (isDark ? DarkColors.outline : LightColors.outline),
                                width: 2,
                              ),
                            ),
                            child: done
                                ? const Icon(Icons.check, size: 13, color: Colors.white)
                                : active
                                    ? Padding(
                                        padding: const EdgeInsets.all(3),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                                        ),
                                      )
                                    : null,
                          ),
                          const SizedBox(width: 12),
                          Text(e.value,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                                color: active ? accent : null,
                              )),
                        ],
                      ),
                    ),
                  );
                }),
              ],

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Onboarding Widgets
// ─────────────────────────────────────────────────────────────────────────────
class _StepDots extends StatelessWidget {
  final int current, total;
  final bool isDark;
  const _StepDots({required this.current, required this.total, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? DarkColors.primary : LightColors.primary;
    return Row(
      children: List.generate(total, (i) {
        final active = i == current;
        final done = i < current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 8),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: (done || active) ? accent : (isDark ? DarkColors.outline : LightColors.outline),
          ),
        );
      }),
    );
  }
}

class _OnboardingAppBar extends StatelessWidget {
  final VoidCallback onBack;
  const _OnboardingAppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
        ),
      ],
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final String emoji, text;
  final bool isDark;
  const _FeatureBullet({required this.emoji, required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
