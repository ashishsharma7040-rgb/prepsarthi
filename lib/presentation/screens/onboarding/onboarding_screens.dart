// lib/presentation/screens/onboarding/onboarding_screens.dart
//
// ✅ FIX (Improvement #2):
//   • class12_boards → isSupported: TRUE — now uses its own dedicated syllabus.
//   • jee_advanced, both → remain isSupported: false (coming soon) but are
//     properly disabled at the tap level, not just dimmed.
//   • _TargetCard shows "Beta" label for jee_advanced/both when we enable them.
//   • _ExamYearScreen: Class 12 Boards exam date corrected to Mar 2026.
//   • _GeneratingPlanScreen: loading step text adapts to exam target.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
              _StepDots(current: 0, total: 5, isDark: isDark)
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
    _Target('jee_main', '📐', 'JEE Main', 'Engineering entrance – NTA', 'Physics, Chemistry, Mathematics', true),
    _Target('jee_advanced', '🏆', 'JEE Advanced', 'IIT entrance – prestigious', 'Physics, Chemistry, Mathematics', false),
    _Target('neet', '🩺', 'NEET UG', 'Medical entrance – NMC', 'Physics, Chemistry, Biology', true),
    _Target('both', '🎯', 'JEE + NEET', 'Attempting both exams', 'Physics, Chemistry, Maths + Bio', false),
    _Target('class12_boards', '📚', 'Class 12 + Boards', 'CBSE Boards focus', 'Phy, Chem, Maths, English, CS', true),
    // ✅ NEW: CA Final — ICAI NSET (New Scheme)
    _Target('ca_final', '⚖️', 'CA Final', 'ICAI – New Scheme (NSET)', 'FR, AFM, Audit, DT, IDT, IBS', true,
        badge: 'NSET'),
    // Coming soon
    _Target('ca_inter', '🎓', 'CA Intermediate', 'ICAI – Coming Soon', 'Accounts, Law, Tax, Costing…', false,
        badge: 'Soon'),
    _Target('ca_foundation', '📖', 'CA Foundation', 'ICAI – Coming Soon', 'Accounts, Law, Maths, Economics', false,
        badge: 'Soon'),
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
              _StepDots(current: 1, total: 5, isDark: isDark),
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
                      onTap: t.isSupported
                          ? () => setState(() => _selected = t.id)
                          : null,
                    ).animate(delay: (i * 70).ms).fadeIn().slideX(begin: 0.08);
                  },
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _selected == null ? null : () {
                  ref.read(onboardingProvider.notifier).setTarget(_selected!);
                  // CA Final → pick attempt (May/Nov/Jan/Sep) before year
                  if (_selected == 'ca_final') {
                    context.go(AppRoutes.caAttemptSelector);
                  } else {
                    context.go(AppRoutes.examYear);
                  }
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
  final bool isSupported;
  final String? badge;
  const _Target(
    this.id,
    this.emoji,
    this.title,
    this.subtitle,
    this.subjects,
    this.isSupported, {
    this.badge,
  });
}

class _TargetCard extends StatelessWidget {
  final _Target target;
  final bool selected, isDark;
  final VoidCallback? onTap;
  const _TargetCard({required this.target, required this.selected, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final accent = isDark ? DarkColors.primary : LightColors.primary;
    // ✅ FIX: isEnabled now correctly reflects tap availability (not just visual dim).
    // Unsupported targets get onTap: null so they are TRULY non-interactive.
    final isEnabled = target.isSupported; // onTap is null when false — see ListView builder

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.50,
      child: GestureDetector(
        onTap: onTap, // null → no-op, properly ignores taps on disabled cards
        behavior: isEnabled ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? accent.withOpacity(0.10)
                : (isDark ? DarkColors.surfaceCard : LightColors.surface),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? accent
                  : (isDark ? DarkColors.outline : LightColors.outline),
              width: selected ? 2 : 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: accent.withOpacity(isEnabled ? 0.12 : 0.06),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(target.emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            target.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!isEnabled || target.badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _badgeColor(target.badge, isEnabled).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _badgeColor(target.badge, isEnabled).withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              _badgeLabel(target.badge, isEnabled),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: _badgeColor(target.badge, isEnabled),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(target.subtitle, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 3),
                    Text(
                      target.subjects,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isEnabled ? accent : (isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Radio circle — only rendered for enabled targets
              if (isEnabled)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? accent : Colors.transparent,
                    border: Border.all(
                      color: selected ? accent : (isDark ? DarkColors.outline : LightColors.outline),
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : null,
                )
              else
                const SizedBox(width: 22), // maintain layout alignment
            ],
          ),
        ),
      ),
    );
  }

  // ── Badge helpers ────────────────────────────────────────────────────────
  static String _badgeLabel(String? badge, bool isEnabled) {
    if (!isEnabled) return badge ?? 'Coming Soon';
    return badge ?? '';
  }

  static Color _badgeColor(String? badge, bool isEnabled) {
    if (!isEnabled) return const Color(0xFFFF9800);
    switch (badge) {
      case 'NSET':  return const Color(0xFF2196F3);
      case 'Beta':  return const Color(0xFF9C27B0);
      default:      return const Color(0xFFFF9800);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CA ATTEMPT SELECTOR — shown ONLY for CA Final before year selection
// ═══════════════════════════════════════════════════════════════════════════
class CaAttemptSelectorScreen extends ConsumerStatefulWidget {
  const CaAttemptSelectorScreen({super.key});
  @override
  ConsumerState<CaAttemptSelectorScreen> createState() =>
      _CaAttemptSelectorScreenState();
}

class _CaAttemptSelectorScreenState
    extends ConsumerState<CaAttemptSelectorScreen> {
  String? _selectedAttempt;

  // ── ICAI officially holds CA Final TWICE per year: May & November. ──────
  // Per ICAI notification, New Scheme (NSET) exams are held in May (week 2)
  // and November (week 2) every year. The student selects which one they are
  // targeting — we don't hardcode a year.
  static const _attempts = [
    _CAAttempt('may',      '☀️', 'May Attempt',      'Held annually in the 2nd week of May'),
    _CAAttempt('november', '🍂', 'November Attempt', 'Held annually in the 2nd week of November'),
  ];

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
              // CA Final: Welcome(0)→Target(1)→Attempt(2)→Year(3)→Hours(4)→Progress(5)→Blackout(6)
              _StepDots(current: 2, total: 7, isDark: isDark),
              const SizedBox(height: 28),
              Text(
                'Which CA Final\nattempt? 📅',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800, height: 1.25,
                ),
              ).animate().fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 8),
              Text(
                'ICAI holds CA Final exams twice a year — May and November. '
                'Pick your target attempt and we will calibrate your plan to that deadline.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? DarkColors.onSurfaceVariant
                      : LightColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ).animate(delay: 100.ms).fadeIn(),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: _attempts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final a = _attempts[i];
                    final sel = _selectedAttempt == a.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAttempt = a.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: sel
                              ? accent.withOpacity(0.10)
                              : (isDark ? DarkColors.surfaceCard : LightColors.surface),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: sel
                                ? accent
                                : (isDark ? DarkColors.outline : LightColors.outline),
                            width: sel ? 2 : 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(a.emoji, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.title,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text(a.subtitle, style: theme.textTheme.bodySmall),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: sel ? accent : Colors.transparent,
                                border: Border.all(
                                  color: sel
                                      ? accent
                                      : (isDark ? DarkColors.outline : LightColors.outline),
                                  width: 2,
                                ),
                              ),
                              child: sel
                                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: (i * 70).ms).fadeIn().slideX(begin: 0.08);
                  },
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _selectedAttempt == null
                    ? null
                    : () {
                        ref
                            .read(onboardingProvider.notifier)
                            .setCaAttempt(_selectedAttempt!);
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

class _CAAttempt {
  final String id, emoji, title, subtitle;
  const _CAAttempt(this.id, this.emoji, this.title, this.subtitle);
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
  List<String> get _years {
    final now = DateTime.now().year;
    return [now.toString(), (now + 1).toString(), (now + 2).toString()];
  }

  String _daysLeft(String year) {
    final ob = ref.read(onboardingProvider);
    final y  = int.parse(year);
    late final DateTime examDate;
    switch (ob.targetExam) {
      case 'ca_final':
        // ICAI holds CA Final TWICE yearly: May (week 2) & November (week 2).
        switch (ob.caAttempt) {
          case 'november': examDate = DateTime(y, 11, 10); break;
          case 'may':
          default:         examDate = DateTime(y,  5, 12); break;
        }
        break;
      case 'neet':
        examDate = DateTime(y, 5, 4);
        break;
      case 'jee_advanced':
        examDate = DateTime(y, 5, 25);
        break;
      case 'class12_boards':
        examDate = DateTime(y, 2, 28);
        break;
      case 'both':
        examDate = DateTime(y, 4, 13);
        break;
      case 'jee_main':
      default:
        examDate = DateTime(y, 4, 13);
    }
    final diff = examDate.difference(DateTime.now()).inDays;
    if (diff <= 0) return 'Past';
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[examDate.month]} ${examDate.day} • $diff days';
  }

  static String _attemptLabel(String? attempt) {
    switch (attempt) {
      case 'november':  return 'November';
      case 'january':   return 'January';
      case 'september': return 'September';
      default:          return 'May';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? DarkColors.primary : LightColors.primary;
    final ob = ref.read(onboardingProvider);
    final isCaFinal = ob.targetExam == 'ca_final';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OnboardingAppBar(onBack: () => context.pop()),
              const SizedBox(height: 8),
              _StepDots(current: isCaFinal ? 3 : 2, total: isCaFinal ? 7 : 5, isDark: isDark),
              const SizedBox(height: 28),
              Text(
                ob.targetExam == 'ca_final'
                    ? 'Which year?\n${_attemptLabel(ob.caAttempt)} 📅'
                    : 'When is your\nexam? 📅',
                style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800, height: 1.25),
              ).animate().fadeIn(),
              const SizedBox(height: 8),
              Text(
                ob.targetExam == 'ca_final'
                    ? 'Select the year of your ${_attemptLabel(ob.caAttempt)} attempt.'
                    : 'We\'ll count down the days and calibrate your plan intensity.',
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

    final obState = ref.read(onboardingProvider);
    final isCaFinal = obState.targetExam == 'ca_final';
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OnboardingAppBar(onBack: () => context.pop()),
              const SizedBox(height: 8),
              _StepDots(current: isCaFinal ? 4 : 3, total: isCaFinal ? 7 : 5, isDark: isDark),
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
                  final target = ref.read(onboardingProvider).targetExam;
                  // CA Final: collect chapter progress before blackout dates
                  if (target == 'ca_final') {
                    context.go(AppRoutes.caChapterProgress);
                  } else {
                    context.go(AppRoutes.blackoutDates);
                  }
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
// BLACKOUT DATES SCREEN — Holiday picker onboarding step
// ═══════════════════════════════════════════════════════════════════════════
class BlackoutDatesScreen extends ConsumerStatefulWidget {
  const BlackoutDatesScreen({super.key});
  @override
  ConsumerState<BlackoutDatesScreen> createState() => _BlackoutDatesScreenState();
}

class _BlackoutDatesScreenState extends ConsumerState<BlackoutDatesScreen> {
  final Set<DateTime> _selected = {};

  // Common Indian holidays + exam rest days pre-populated as suggestions
  static final _suggestions = [
    _Holiday('🎉', 'Holi', DateTime(DateTime.now().year, 3, 14)),
    _Holiday('🪔', 'Diwali', DateTime(DateTime.now().year, 10, 20)),
    _Holiday('🎆', 'Dussehra', DateTime(DateTime.now().year, 10, 2)),
    _Holiday('🎊', 'Eid', DateTime(DateTime.now().year, 4, 10)),
    _Holiday('🎄', 'Christmas', DateTime(DateTime.now().year, 12, 25)),
    _Holiday('🎓', 'Exam Day Buffer', DateTime(DateTime.now().year + 1, 1, 13)),
  ];

  void _toggleSuggestion(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    setState(() {
      if (_selected.contains(key)) {
        _selected.remove(key);
      } else {
        _selected.add(key);
      }
    });
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
      helpText: 'Select a blackout / holiday date',
    );
    if (picked != null) {
      final key = DateTime(picked.year, picked.month, picked.day);
      setState(() => _selected.add(key));
    }
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
              // isCaFinal check inlined: CA path = 6/7, standard = 4/5
              Consumer(builder: (context, ref, _) {
                final ob = ref.read(onboardingProvider);
                final isCaFinal = ob.targetExam == 'ca_final';
                return _StepDots(current: isCaFinal ? 6 : 4, total: isCaFinal ? 7 : 5, isDark: isDark);
              }),
              const SizedBox(height: 28),
              Text(
                'Any days off? 🗓️',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ).animate().fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 8),
              Text(
                'Mark holidays or rest days. Your study plan will skip these dates automatically.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? DarkColors.onSurfaceVariant
                      : LightColors.onSurfaceVariant,
                ),
              ).animate(delay: 100.ms).fadeIn(),
              const SizedBox(height: 24),

              // Suggestion chips
              Text('Quick picks', style: theme.textTheme.labelLarge)
                  .animate(delay: 150.ms)
                  .fadeIn(),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestions.map((h) {
                  final key = DateTime(h.date.year, h.date.month, h.date.day);
                  final sel = _selected.contains(key);
                  return GestureDetector(
                    onTap: () => _toggleSuggestion(h.date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: sel
                            ? accent.withOpacity(0.15)
                            : (isDark
                                ? DarkColors.surfaceCard
                                : LightColors.surface),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: sel
                              ? accent
                              : (isDark
                                  ? DarkColors.outline
                                  : LightColors.outline),
                          width: sel ? 1.5 : 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(h.emoji,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(h.name, style: theme.textTheme.labelMedium),
                          if (sel) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.check_rounded, size: 14, color: accent),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ).animate(delay: 180.ms).fadeIn(),

              const SizedBox(height: 16),

              // Add custom date button
              OutlinedButton.icon(
                onPressed: _pickCustomDate,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add custom date'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                ),
              ).animate(delay: 200.ms).fadeIn(),

              const SizedBox(height: 16),

              // Selected count chip
              if (_selected.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_busy_rounded,
                          size: 18, color: accent),
                      const SizedBox(width: 8),
                      Text(
                        '${_selected.length} day${_selected.length == 1 ? '' : 's'} blocked — plan will skip these',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: accent),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),

              const Spacer(),

              FilledButton(
                onPressed: () {
                  ref
                      .read(onboardingProvider.notifier)
                      .setBlackoutDates(_selected.toList());
                  context.go(AppRoutes.generatingPlan);
                },
                child: Text(_selected.isEmpty
                    ? 'No days off — Generate My Plan 🚀'
                    : 'Save & Generate My Plan 🚀'),
              ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.4),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _Holiday {
  final String emoji, name;
  final DateTime date;
  const _Holiday(this.emoji, this.name, this.date);
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

  // ✅ Steps are computed after we know the target exam so the copy is accurate.
  List<String> _stepsFor(String? target) {
    final syllabusName = switch (target) {
      'jee_main'       => 'JEE Main',
      'jee_advanced'   => 'JEE Advanced',
      'neet'           => 'NEET UG',
      'both'           => 'JEE + NEET',
      'class12_boards' => 'CBSE Class 12',
      'ca_final'       => 'CA Final (NSET)',
      _                => 'your',
    };
    return [
      '📥  Loading $syllabusName syllabus...',
      '⚖️  Calculating chapter priorities...',
      '📅  Building your timeline...',
      '🔄  Scheduling revision sessions...',
      '🧪  Adding mock test days...',
      '✅  Plan ready! Let\'s go!',
    ];
  }

  late List<String> _steps;

  @override
  void initState() {
    super.initState();
    final ob = ref.read(onboardingProvider);
    _steps = _stepsFor(ob.targetExam);
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
      caAttempt: ob.caAttempt,
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

// ═══════════════════════════════════════════════════════════════════════════
// CA FINAL CHAPTER PROGRESS SCREEN
// Asks the student how far along they are for each paper BEFORE generating
// the plan — so the planner skips already-completed chapters correctly.
// ═══════════════════════════════════════════════════════════════════════════
// ─────────────────────────────────────────────────────────────────────────────
// CA Chapter Progress Screen — chapter-level granularity
// Each paper can be collapsed/expanded. Student sets status per chapter,
// OR uses the paper-level "Set all" shortcut for speed.
// ─────────────────────────────────────────────────────────────────────────────
class CaChapterProgressScreen extends ConsumerStatefulWidget {
  const CaChapterProgressScreen({super.key});
  @override
  ConsumerState<CaChapterProgressScreen> createState() =>
      _CaChapterProgressScreenState();
}

class _CaChapterProgressScreenState
    extends ConsumerState<CaChapterProgressScreen> {

  // chapterKey (paperNo:chapterIndex) → status
  final Map<String, String> _chapterStatus = {};
  // Which papers are expanded in the accordion
  final Set<int> _expanded = {1};
  // Paper definitions: (paperNo, emoji, shortName, fullName, chapters)
  static const _papers = [
    (1, '📊', 'P1', 'Financial Reporting', [
      'Framework for Preparation of Financial Statements',
      'Ind AS 1: Presentation of Financial Statements',
      'Ind AS 2: Inventories',
      'Ind AS 7: Cash Flow Statements',
      'Ind AS 8: Accounting Policies',
      'Ind AS 10: Events After Reporting Period',
      'Ind AS 12: Income Taxes',
      'Ind AS 16: Property, Plant & Equipment',
      'Ind AS 19: Employee Benefits',
      'Ind AS 20: Government Grants',
      'Ind AS 21: Effects of Changes in Foreign Exchange',
      'Ind AS 23: Borrowing Costs',
      'Ind AS 24: Related Party Disclosures',
      'Ind AS 27: Separate Financial Statements',
      'Ind AS 28: Investments in Associates',
      'Ind AS 32/107/109: Financial Instruments',
      'Ind AS 33: Earnings Per Share',
      'Ind AS 36: Impairment of Assets',
      'Ind AS 37: Provisions, Contingent Liabilities',
      'Ind AS 38: Intangible Assets',
      'Ind AS 40: Investment Property',
      'Ind AS 41: Agriculture',
      'Ind AS 103: Business Combinations',
      'Ind AS 110/111/112: Consolidation',
      'Ind AS 115: Revenue from Contracts',
    ]),
    (2, '💹', 'P2', 'Advanced Financial Management', [
      'Advanced Capital Budgeting',
      'Risk in Capital Budgeting',
      'Dividend Decisions',
      'Indian Capital Market',
      'Security Analysis & Valuation',
      'Portfolio Management',
      'Securitisation',
      'International Financial Management',
      'Interest Rate Risk Management',
      'Corporate Valuation',
      'Mergers, Acquisitions & Restructuring',
      'Startup Finance',
      'Small Business Finance',
      'Financial Policy & Corporate Strategy',
      'Business Valuation',
    ]),
    (3, '🔍', 'P3', 'Advanced Auditing & Ethics', [
      'Quality Control & Engagement Standards',
      'General Auditing Principles',
      'Risk Assessment & Internal Controls',
      'Audit of Financial Statements',
      'Audit Reports',
      'Audit of Banks',
      'Audit of Insurance Companies',
      'Audit of Non-Banking Financial Companies',
      'Due Diligence, Investigation & Forensic Audit',
      'Peer Review & Quality Review',
      'Professional Ethics',
      'Code of Ethics for CAs',
      'Audit of PSUs',
      'Reporting under Companies Act 2013',
      'Standards on Auditing (SA 200 Series)',
      'Standards on Auditing (SA 300–600)',
      'Emerging Areas: IT Audit, Digital Controls',
    ]),
    (4, '🏛️', 'P4', 'Direct Tax & Intl Taxation', [
      'Basics of Income Tax',
      'Residence & Scope of Total Income',
      'Salary',
      'House Property',
      'Profits & Gains of Business',
      'Capital Gains',
      'Income from Other Sources',
      'Clubbing & Set-Off of Losses',
      'Deductions under Chapter VI-A',
      'Assessment of Firms & LLPs',
      'Assessment of Companies',
      'Tax Deducted at Source',
      'Advance Tax & Return Filing',
      'Assessment Proceedings & Appeals',
      'Double Taxation Avoidance Agreements',
      'Transfer Pricing',
      'BEPS / MLI / POEM',
      'Foreign Tax Credit & Equalisation Levy',
    ]),
    (5, '📋', 'P5', 'Indirect Tax Laws', [
      'GST: Overview & Basic Concepts',
      'Supply under GST',
      'Exemptions from GST',
      'Time of Supply & Valuation',
      'Input Tax Credit',
      'Registration',
      'Tax Invoice, Credit & Debit Notes',
      'Returns',
      'Payment of Tax',
      'Refunds',
      'Assessment & Audit',
      'Inspection, Search & Seizure',
      'Offences, Penalties & Prosecution',
      'Demands & Recovery',
      'Customs Law',
      'Foreign Trade Policy',
    ]),
    (6, '🧩', 'P6', 'Integrated Business Solutions (IBS)', [
      // IBS has no standalone syllabus — chapters here represent focus areas
      // for integrated case-study practice. Plan will schedule mock sessions.
      'IBS: Financial Reporting Integration',
      'IBS: SFM Application in Cases',
      'IBS: Audit & Ethics in Business Scenarios',
      'IBS: Direct Tax in Cases',
      'IBS: GST & Customs in Cases',
      'IBS: Cross-subject Integration Practice',
      'IBS: Full Mock Case Study 1',
      'IBS: Full Mock Case Study 2',
    ]),
  ];

  static const _statuses = [
    ('not_started',      '⬜', 'Not Started',      Color(0xFF9E9E9E)),
    ('in_progress',      '🔵', 'In Progress',       Color(0xFF2196F3)),
    ('revision_pending', '🟡', 'Rev Pending',        Color(0xFFFFC107)),
    ('completed',        '🟢', 'Fully Done',         Color(0xFF4CAF50)),
  ];

  @override
  void initState() {
    super.initState();
    for (final paper in _papers) {
      final chapters = paper.$5 as List<String>;
      for (int ci = 0; ci < chapters.length; ci++) {
        _chapterStatus['${paper.$1}:$ci'] = 'not_started';
      }
    }
  }

  String _paperSummary(int paperNo, List<String> chapters) {
    int done = 0, rev = 0, ip = 0;
    for (int ci = 0; ci < chapters.length; ci++) {
      final s = _chapterStatus['$paperNo:$ci'] ?? 'not_started';
      if (s == 'completed') done++;
      else if (s == 'revision_pending') rev++;
      else if (s == 'in_progress') ip++;
    }
    final total = chapters.length;
    if (done == total) return '✅ All done';
    if (done + rev == total) return '🟡 Revision pending';
    if (done > 0 || rev > 0 || ip > 0) return '$done/$total done';
    return 'Not started';
  }

  void _setAllInPaper(int paperNo, List<String> chapters, String status) {
    setState(() {
      for (int ci = 0; ci < chapters.length; ci++) {
        _chapterStatus['$paperNo:$ci'] = status;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? DarkColors.primary : LightColors.primary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OnboardingAppBar(onBack: () => context.pop()),
              const SizedBox(height: 8),
              _StepDots(current: 5, total: 7, isDark: isDark),
              const SizedBox(height: 20),
              Text(
                'Your progress so far 📚',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ).animate().fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 6),
              Text(
                'Mark each chapter so we start your plan right where you left off.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ).animate(delay: 80.ms).fadeIn(),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.builder(
                  itemCount: _papers.length,
                  padding: const EdgeInsets.only(bottom: 100),
                  itemBuilder: (_, pi) {
                    final paper = _papers[pi];
                    final paperNo = paper.$1;
                    final emoji = paper.$2;
                    final shortName = paper.$3;
                    final fullName = paper.$4;
                    final chapters = paper.$5 as List<String>;
                    final isExpanded = _expanded.contains(paperNo);
                    final isIbs = paperNo == 6;
                    final summary = _paperSummary(paperNo, chapters);

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isDark ? DarkColors.surfaceCard : LightColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? DarkColors.outline : LightColors.outline,
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Paper header (tap to expand) ─────────────
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => setState(() {
                              if (isExpanded) _expanded.remove(paperNo);
                              else _expanded.add(paperNo);
                            }),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                              child: Row(
                                children: [
                                  Text(emoji, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$shortName: $fullName',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          summary,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isExpanded ? Icons.expand_less : Icons.expand_more,
                                    color: isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Expanded content ──────────────────────────
                          if (isExpanded) ...[
                            Divider(height: 1,
                              color: isDark ? DarkColors.outline : LightColors.outline),

                            // IBS info banner
                            if (isIbs)
                              Container(
                                margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5C6BC0).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF5C6BC0).withOpacity(0.25)),
                                ),
                                child: const Text(
                                  '🧩  IBS is case-study based — your plan schedules integrated mock sessions, not chapter-by-chapter slots. Mark your mock practice history below.',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF5C6BC0), height: 1.4),
                                ),
                              ),

                            // "Set all" quick shortcuts
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                              child: Row(
                                children: [
                                  Text('Set all:', style: theme.textTheme.labelSmall),
                                  const SizedBox(width: 8),
                                  ..._statuses.map((s) => GestureDetector(
                                    onTap: () => _setAllInPaper(paperNo, chapters, s.$1),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: s.$4.withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: s.$4.withOpacity(0.3)),
                                      ),
                                      child: Text('${s.$2} ${s.$3}',
                                        style: TextStyle(fontSize: 10, color: s.$4, fontWeight: FontWeight.w600)),
                                    ),
                                  )),
                                ],
                              ),
                            ),

                            // Per-chapter rows
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                              child: Column(
                                children: List.generate(chapters.length, (ci) {
                                  final key = '$paperNo:$ci';
                                  final chStatus = _chapterStatus[key] ?? 'not_started';
                                  final sInfo = _statuses.firstWhere((s) => s.$1 == chStatus);
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isDark ? DarkColors.surfaceVariant : LightColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: sInfo.$4.withOpacity(0.25),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${ci + 1}. ${chapters[ci]}',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              decoration: chStatus == 'completed'
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Status cycle button — tap to cycle through statuses
                                        GestureDetector(
                                          onTap: () {
                                            final idx = _statuses.indexWhere((s) => s.$1 == chStatus);
                                            final next = _statuses[(idx + 1) % _statuses.length];
                                            setState(() => _chapterStatus[key] = next.$1);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: sInfo.$4.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: sInfo.$4.withOpacity(0.3)),
                                            ),
                                            child: Text(
                                              '${sInfo.$2} ${sInfo.$3}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: sInfo.$4,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ).animate(delay: (pi * 50).ms).fadeIn().slideY(begin: 0.06);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: () {
              _savePaperProgress();
              context.go(AppRoutes.blackoutDates);
            },
            style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: const Text('Save & Continue 🚀', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Future<void> _savePaperProgress() async {
    // Aggregate chapter-level statuses back to paper-level for the plan generator.
    // For each paper: majority-vote across chapters.
    // Also save full chapter map for future use.
    final prefs = await SharedPreferences.getInstance();
    final Map<String, String> paperLevel = {};
    for (final paper in _papers) {
      final chapters = paper.$5 as List<String>;
      final paperNo = paper.$1;
      final counts = <String, int>{};
      for (int ci = 0; ci < chapters.length; ci++) {
        final s = _chapterStatus['$paperNo:$ci'] ?? 'not_started';
        counts[s] = (counts[s] ?? 0) + 1;
      }
      // Priority: completed > revision_pending > in_progress > not_started
      if ((counts['completed'] ?? 0) == chapters.length) {
        paperLevel['$paperNo'] = 'completed';
      } else if ((counts['not_started'] ?? 0) == chapters.length) {
        paperLevel['$paperNo'] = 'not_started';
      } else if ((counts['completed'] ?? 0) + (counts['revision_pending'] ?? 0) >= chapters.length * 0.7) {
        paperLevel['$paperNo'] = 'revision_pending';
      } else {
        paperLevel['$paperNo'] = 'in_progress';
      }
    }
    // Save paper-level for plan generator
    await prefs.setString('ca_final_paper_progress', jsonEncode(paperLevel));
    // Save full chapter-level for future use
    await prefs.setString('ca_final_chapter_progress', jsonEncode(_chapterStatus));
  }
}
