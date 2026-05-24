// lib/presentation/screens/pomodoro/pomodoro_timer_screen.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/local/isar/schemas/schemas.dart';
import '../../providers/all_providers.dart';

// ─── Pomodoro State ───────────────────────────────────────────────────────────
enum PomodoroPhase { idle, focus, shortBreak, longBreak }

class PomodoroState {
  final PomodoroPhase phase;
  final int secondsLeft;
  final int completedSessions;
  final bool isRunning;
  final String? activeChapter;
  final String? activeSubject;

  const PomodoroState({
    this.phase = PomodoroPhase.idle,
    this.secondsLeft = 25 * 60,
    this.completedSessions = 0,
    this.isRunning = false,
    this.activeChapter,
    this.activeSubject,
  });

  PomodoroState copyWith({
    PomodoroPhase? phase,
    int? secondsLeft,
    int? completedSessions,
    bool? isRunning,
    String? activeChapter,
    String? activeSubject,
  }) =>
      PomodoroState(
        phase: phase ?? this.phase,
        secondsLeft: secondsLeft ?? this.secondsLeft,
        completedSessions: completedSessions ?? this.completedSessions,
        isRunning: isRunning ?? this.isRunning,
        activeChapter: activeChapter ?? this.activeChapter,
        activeSubject: activeSubject ?? this.activeSubject,
      );

  String get timeString {
    final m = secondsLeft ~/ 60;
    final s = secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double progressRatio(int totalSeconds) =>
      1.0 - (secondsLeft / totalSeconds).clamp(0.0, 1.0);
}

class PomodoroNotifier extends Notifier<PomodoroState> {
  Timer? _timer;

  @override
  PomodoroState build() {
    ref.onDispose(() => _timer?.cancel());
    return const PomodoroState();
  }

  int get _workSeconds =>
      ref.read(settingsProvider).pomodoroWork * 60;
  int get _shortBreakSeconds =>
      ref.read(settingsProvider).pomodoroBreak * 60;
  int get _longBreakSeconds => 15 * 60;
  int get _cycles => ref.read(settingsProvider).pomodoroCycles;

  void selectChapter(String chapter, String subject) {
    state = state.copyWith(activeChapter: chapter, activeSubject: subject);
  }

  void start() {
    if (state.phase == PomodoroPhase.idle) {
      state = state.copyWith(
        phase: PomodoroPhase.focus,
        secondsLeft: _workSeconds,
        isRunning: true,
      );
    } else {
      state = state.copyWith(isRunning: true);
    }
    _startTick();
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _timer?.cancel();
    state = const PomodoroState();
  }

  void skipPhase() {
    if (state.phase == PomodoroPhase.idle) return;
    _timer?.cancel();
    _onPhaseComplete();
  }

  void _startTick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (state.secondsLeft <= 1) {
      _onPhaseComplete();
    } else {
      state = state.copyWith(secondsLeft: state.secondsLeft - 1);
    }
  }

  void _onPhaseComplete() {
    _timer?.cancel();

    if (state.phase == PomodoroPhase.focus) {
      final newCompleted = state.completedSessions + 1;
      // Log auto-session (fire-and-forget — void method can't await)
      if (state.activeChapter != null && state.activeSubject != null) {
        ref.read(studyLogProvider.notifier).logSession(
          chapterName: state.activeChapter!,
          subjectName: state.activeSubject!,
          hours: ref.read(settingsProvider).pomodoroWork / 60.0,
          activityTag: 'learned',
          isPomodoro: true,
          pomodoroSessions: 1,
        ).ignore();
      }

      // Long break every N cycles
      final isLongBreak = newCompleted % _cycles == 0;
      state = state.copyWith(
        phase: isLongBreak ? PomodoroPhase.longBreak : PomodoroPhase.shortBreak,
        secondsLeft: isLongBreak ? _longBreakSeconds : _shortBreakSeconds,
        completedSessions: newCompleted,
        isRunning: false,
      );
    } else {
      // Break over → back to focus
      state = state.copyWith(
        phase: PomodoroPhase.focus,
        secondsLeft: _workSeconds,
        isRunning: false,
      );
    }
  }

}

final pomodoroProvider =
    NotifierProvider<PomodoroNotifier, PomodoroState>(PomodoroNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class PomodoroTimerScreen extends ConsumerStatefulWidget {
  /// Optionally pre-fills the chapter & subject when launched from ChapterDetailScreen.
  final String? initialChapter;
  final String? initialSubject;

  const PomodoroTimerScreen({
    super.key,
    this.initialChapter,
    this.initialSubject,
  });

  @override
  ConsumerState<PomodoroTimerScreen> createState() =>
      _PomodoroTimerScreenState();
}

class _PomodoroTimerScreenState extends ConsumerState<PomodoroTimerScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confetti;
  late AnimationController _pulseCtrl;
  String? _selectedSubject;
  String? _selectedChapter;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Pre-fill chapter/subject if launched from ChapterDetailScreen
    if (widget.initialChapter != null && widget.initialSubject != null) {
      _selectedChapter = widget.initialChapter;
      _selectedSubject = widget.initialSubject;
      // Notify the notifier after first frame so providers are ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(pomodoroProvider.notifier).selectChapter(
              widget.initialChapter!,
              widget.initialSubject!,
            );
      });
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pomo = ref.watch(pomodoroProvider);
    final settings = ref.watch(settingsProvider);
    final planState = ref.watch(planProvider);

    final (phaseLabel, phaseEmoji, phaseColor) = _phaseInfo(pomo.phase, isDark);
    final totalSeconds = _totalSeconds(pomo.phase, settings);
    final progress = pomo.progressRatio(totalSeconds);

    // Watch for session completion
    ref.listen(pomodoroProvider, (prev, next) {
      if (prev?.phase == PomodoroPhase.focus &&
          next.phase != PomodoroPhase.focus &&
          next.completedSessions > (prev?.completedSessions ?? 0)) {
        _confetti.play();
        _showSessionCompleteSnack(context, next.completedSessions);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient by phase ─────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [
                  phaseColor.withOpacity(isDark ? 0.18 : 0.08),
                  isDark ? DarkColors.background : LightColors.background,
                ],
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 30,
              colors: [phaseColor, LightColors.secondary, LightColors.tertiary],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── AppBar ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text('Pomodoro Timer',
                            style: theme.textTheme.headlineMedium,
                            textAlign: TextAlign.center),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () => _showSettingsSheet(context, settings),
                      ),
                    ],
                  ),
                ),

                // ── Phase label ────────────────────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    key: ValueKey(pomo.phase),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: phaseColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: phaseColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      '$phaseEmoji  $phaseLabel',
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: phaseColor, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                // ── Session dots ───────────────────────────────────────────
                _SessionDots(
                  completed: pomo.completedSessions % settings.pomodoroCycles,
                  total: settings.pomodoroCycles,
                  color: phaseColor,
                ),

                const Spacer(flex: 1),

                // ── Circular Timer ─────────────────────────────────────────
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (context, child) {
                    final pulse = pomo.isRunning
                        ? 1.0 + _pulseCtrl.value * 0.03
                        : 1.0;
                    return Transform.scale(scale: pulse, child: child);
                  },
                  child: _CircularTimer(
                    progress: progress,
                    timeString: pomo.timeString,
                    color: phaseColor,
                    isDark: isDark,
                    size: 260,
                  ).animate().scale(
                    begin: const Offset(0.7, 0.7),
                    duration: 700.ms,
                    curve: Curves.elasticOut,
                  ),
                ),

                const Spacer(flex: 1),

                // ── Chapter selector ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _ChapterSelector(
                    chapters: planState.todayEntries,
                    selectedChapter: _selectedChapter,
                    selectedSubject: _selectedSubject,
                    isDark: isDark,
                    onSelect: (chapter, subject) {
                      setState(() {
                        _selectedChapter = chapter;
                        _selectedSubject = subject;
                      });
                      ref.read(pomodoroProvider.notifier)
                          .selectChapter(chapter, subject);
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // ── Controls ───────────────────────────────────────────────
                _TimerControls(
                  pomo: pomo,
                  phaseColor: phaseColor,
                  isDark: isDark,
                  onStart: () {
                    if (_selectedChapter == null &&
                        planState.todayEntries.isNotEmpty) {
                      final first = planState.todayEntries.first;
                      setState(() {
                        _selectedChapter = first.chapterName;
                        _selectedSubject = first.subjectName;
                      });
                      ref.read(pomodoroProvider.notifier)
                          .selectChapter(first.chapterName, first.subjectName);
                    }
                    ref.read(pomodoroProvider.notifier).start();
                  },
                  onPause: () => ref.read(pomodoroProvider.notifier).pause(),
                  onReset: () {
                    ref.read(pomodoroProvider.notifier).reset();
                    _confetti.stop();
                  },
                  onSkip: () => ref.read(pomodoroProvider.notifier).skipPhase(),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (String, String, Color) _phaseInfo(PomodoroPhase phase, bool isDark) {
    switch (phase) {
      case PomodoroPhase.focus:
        return ('Focus Time', '🍅', isDark ? DarkColors.primary : LightColors.primary);
      case PomodoroPhase.shortBreak:
        return ('Short Break', '☕', LightColors.tertiary);
      case PomodoroPhase.longBreak:
        return ('Long Break', '🌴', LightColors.secondary);
      case PomodoroPhase.idle:
        return ('Ready to Focus', '⚡', isDark ? DarkColors.primary : LightColors.primary);
    }
  }

  int _totalSeconds(PomodoroPhase phase, SettingsState settings) {
    switch (phase) {
      case PomodoroPhase.focus:
      case PomodoroPhase.idle:
        return settings.pomodoroWork * 60;
      case PomodoroPhase.shortBreak:
        return settings.pomodoroBreak * 60;
      case PomodoroPhase.longBreak:
        return 15 * 60;
    }
  }

  void _showSessionCompleteSnack(BuildContext context, int count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🍅 Session #$count complete! Great work!'),
        backgroundColor: LightColors.learned,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, SettingsState settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PomodoroSettingsSheet(settings: settings),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Circular Timer Painter
// ─────────────────────────────────────────────────────────────────────────────
class _CircularTimer extends StatelessWidget {
  final double progress;
  final String timeString;
  final Color color;
  final bool isDark;
  final double size;

  const _CircularTimer({
    required this.progress,
    required this.timeString,
    required this.color,
    required this.isDark,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Background ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 14,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? DarkColors.outline : LightColors.outline,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Progress ring
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 600),
              builder: (_, value, __) => CustomPaint(
                painter: _ArcPainter(
                  progress: value,
                  color: color,
                  strokeWidth: 14,
                ),
              ),
            ),
          ),
          // Inner content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeString,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).round()}% done',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ArcPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + math.pi * 2,
      colors: [color.withOpacity(0.6), color],
      stops: const [0.0, 1.0],
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      progress * math.pi * 2,
      false,
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Session dots (showing progress within a cycle)
// ─────────────────────────────────────────────────────────────────────────────
class _SessionDots extends StatelessWidget {
  final int completed;
  final int total;
  final Color color;

  const _SessionDots({
    required this.completed,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) {
          final done = i < completed;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: done ? 24 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: done ? color : color.withOpacity(0.25),
              borderRadius: BorderRadius.circular(5),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chapter Selector
// ─────────────────────────────────────────────────────────────────────────────
class _ChapterSelector extends StatelessWidget {
  final List<PlanEntrySchema> chapters;
  final String? selectedChapter;
  final String? selectedSubject;
  final bool isDark;
  final void Function(String chapter, String subject) onSelect;

  const _ChapterSelector({
    required this.chapters,
    required this.selectedChapter,
    required this.selectedSubject,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isDark ? DarkColors.primary : LightColors.primary;

    if (chapters.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surfaceVariant : LightColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Text('📚', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No chapters scheduled today. Add sessions in your plan.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }

    if (selectedChapter != null) {
      return GestureDetector(
        onTap: () => _showChapterPicker(context),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text('📖', style: TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(selectedChapter!,
                        style: theme.textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(selectedSubject ?? '',
                        style: theme.textTheme.labelSmall?.copyWith(color: accent)),
                  ],
                ),
              ),
              Icon(Icons.swap_horiz_rounded, color: accent, size: 20),
            ],
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _showChapterPicker(context),
      icon: const Text('📖', style: TextStyle(fontSize: 18)),
      label: const Text('Select Chapter to Focus On'),
      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
    );
  }

  void _showChapterPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today\'s Chapters',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 14),
            ...chapters.map((e) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text('📖', style: const TextStyle(fontSize: 22)),
              title: Text(e.chapterName,
                  style: Theme.of(context).textTheme.titleSmall),
              subtitle: Text('${e.subjectName} • ${e.plannedHours}h'),
              trailing: selectedChapter == e.chapterName
                  ? Icon(Icons.check_circle,
                      color: isDark ? DarkColors.primary : LightColors.primary)
                  : null,
              onTap: () {
                onSelect(e.chapterName, e.subjectName);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timer Controls
// ─────────────────────────────────────────────────────────────────────────────
class _TimerControls extends StatelessWidget {
  final PomodoroState pomo;
  final Color phaseColor;
  final bool isDark;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onSkip;

  const _TimerControls({
    required this.pomo,
    required this.phaseColor,
    required this.isDark,
    required this.onStart,
    required this.onPause,
    required this.onReset,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset
        _CircleBtn(
          icon: Icons.restart_alt_rounded,
          onTap: onReset,
          size: 52,
          color: isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant,
          filled: false,
          isDark: isDark,
        ),
        const SizedBox(width: 20),

        // Main CTA
        _CircleBtn(
          icon: pomo.isRunning
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          onTap: pomo.isRunning ? onPause : onStart,
          size: 80,
          color: phaseColor,
          filled: true,
          isDark: isDark,
        ),

        const SizedBox(width: 20),

        // Skip
        _CircleBtn(
          icon: Icons.skip_next_rounded,
          onTap: onSkip,
          size: 52,
          color: isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant,
          filled: false,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;
  final bool filled;
  final bool isDark;

  const _CircleBtn({
    required this.icon,
    required this.onTap,
    required this.size,
    required this.color,
    required this.filled,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? color : (isDark ? DarkColors.surfaceVariant : LightColors.surfaceVariant),
          boxShadow: filled
              ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))]
              : null,
        ),
        child: Icon(
          icon,
          color: filled ? Colors.white : color,
          size: size * 0.45,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pomodoro Settings Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _PomodoroSettingsSheet extends ConsumerWidget {
  final SettingsState settings;
  const _PomodoroSettingsSheet({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Timer Settings', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 20),
          _SettingSlider(
            label: 'Focus Duration',
            emoji: '🍅',
            value: settings.pomodoroWork.toDouble(),
            min: 10, max: 60, divisions: 10,
            unit: 'min',
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setPomodoroWork(v.round()),
          ),
          const SizedBox(height: 12),
          _SettingSlider(
            label: 'Break Duration',
            emoji: '☕',
            value: settings.pomodoroBreak.toDouble(),
            min: 3, max: 20, divisions: 17,
            unit: 'min',
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setPomodoroBreak(v.round()),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _SettingSlider extends StatelessWidget {
  final String label, emoji, unit;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SettingSlider({
    required this.label,
    required this.emoji,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(label, style: theme.textTheme.labelLarge),
            ]),
            Text('${value.round()} $unit',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
        Slider(
          value: value, min: min, max: max, divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
