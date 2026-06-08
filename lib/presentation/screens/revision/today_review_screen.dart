// lib/presentation/screens/revision/today_review_screen.dart
//
// Spaced Repetition Review Screen
// Shows due cards one at a time with a 3D flip animation.
// Hard / Good / Easy buttons apply the SM-2 algorithm and schedule next review.
//
// ⚠️  Full functionality requires [REVIEW_CARD_STEP] to be completed.
//     Until then, this screen shows a friendly "coming soon" state.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/usecases/review_card_usecase.dart';

// ── Temporary model used until [REVIEW_CARD_STEP] is complete ───────────────
class _ReviewCardModel {
  final int id;
  final String chapterName;
  final String subjectName;
  final String cardType;
  final String front;
  final String back;
  final int repetitions;

  const _ReviewCardModel({
    required this.id,
    required this.chapterName,
    required this.subjectName,
    required this.cardType,
    required this.front,
    required this.back,
    required this.repetitions,
  });

  String get cardTypeLabel {
    switch (cardType) {
      case 'formula':    return '📐 Formula';
      case 'concept':    return '💡 Concept';
      case 'definition': return '📖 Definition';
      case 'mistake':    return '⚠️ Mistake';
      case 'pyq':        return '📝 PYQ';
      default:           return '🃏 Card';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TODAY REVIEW SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class TodayReviewScreen extends ConsumerStatefulWidget {
  const TodayReviewScreen({super.key});

  @override
  ConsumerState<TodayReviewScreen> createState() => _TodayReviewScreenState();
}

class _TodayReviewScreenState extends ConsumerState<TodayReviewScreen>
    with TickerProviderStateMixin {
  // ── State ─────────────────────────────────────────────────────────────────
  List<_ReviewCardModel> _cards = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isLoading = true;
  bool _sessionComplete = false;

  // Session stats
  int _hardCount = 0;
  int _goodCount = 0;
  int _easyCount = 0;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  final ReviewCardUsecase _usecase = ReviewCardUsecase();

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );
    _loadCards();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    try {
      // [REVIEW_CARD_STEP] Replace with:
      // final real = await _usecase.getTodaysReviewCards();
      // _cards = real.map((c) => _ReviewCardModel(
      //   id: c.id, chapterName: c.chapterName, subjectName: c.subjectName,
      //   cardType: c.cardType, front: c.front, back: c.back,
      //   repetitions: c.repetitions,
      // )).toList();

      // Placeholder until build_runner is run:
      await Future.delayed(const Duration(milliseconds: 400));
      _cards = [];
    } catch (_) {
      _cards = [];
    }
    setState(() => _isLoading = false);
  }

  // ── Flip card ─────────────────────────────────────────────────────────────
  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  // ── Process review ────────────────────────────────────────────────────────
  // performance: 1 = Hard, 3 = Good, 5 = Easy
  Future<void> _processReview(int performance) async {
    if (_currentIndex >= _cards.length) return;

    final card = _cards[_currentIndex];

    // Update stats
    if (performance == 1)      _hardCount++;
    else if (performance == 3) _goodCount++;
    else                       _easyCount++;

    // Apply SM-2 (no-op until [REVIEW_CARD_STEP] is complete)
    await _usecase.markCardReviewed(
      cardId: card.id,
      performance: performance,
    );

    // Advance to next card
    if (_flipController.isCompleted) {
      await _flipController.reverse();
    }
    setState(() {
      _isFlipped = false;
      if (_currentIndex + 1 >= _cards.length) {
        _sessionComplete = true;
      } else {
        _currentIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? DarkColors.primary : LightColors.primary;

    return Scaffold(
      backgroundColor:
          isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: const Text('Today\'s Review'),
        backgroundColor:
            isDark ? DarkColors.surface : LightColors.surface,
        actions: [
          if (_cards.isNotEmpty && !_sessionComplete)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_currentIndex + 1} / ${_cards.length}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isDark
                        ? DarkColors.onSurfaceVariant
                        : LightColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoading(isDark, accent)
          : _cards.isEmpty
              ? _buildEmpty(theme, isDark, accent)
              : _sessionComplete
                  ? _buildSessionSummary(theme, isDark, accent)
                  : _buildReviewSession(theme, isDark, accent),
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────────
  Widget _buildLoading(bool isDark, Color accent) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: accent),
          const SizedBox(height: 16),
          Text('Loading your review cards…',
              style: TextStyle(
                color: isDark
                    ? DarkColors.onSurfaceVariant
                    : LightColors.onSurfaceVariant,
              )),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmpty(ThemeData theme, bool isDark, Color accent) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
                child: Text('🎉', style: TextStyle(fontSize: 44))),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 28),
          Text(
            'All Caught Up!',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 12),
          Text(
            'No reviews are due today.\n\nReview cards are created automatically when you mark a chapter as Learned. Complete your study sessions and come back tomorrow!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? DarkColors.onSurfaceVariant
                  : LightColors.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 250.ms).fadeIn(),
          const SizedBox(height: 32),
          // Activation note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withOpacity(0.20)),
            ),
            child: Column(
              children: [
                Row(children: [
                  Icon(Icons.info_outline_rounded, color: accent, size: 18),
                  const SizedBox(width: 8),
                  Text('Activation Required',
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: accent, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 8),
                Text(
                  'To activate spaced repetition cards, run:\n'
                  'dart run build_runner build --delete-conflicting-outputs\n\n'
                  'Then uncomment the [REVIEW_CARD_STEP] lines in '
                  'isar_service.dart and schemas.dart.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ).animate(delay: 350.ms).fadeIn(),
        ],
      ),
    );
  }

  // ── Review session (flip cards) ───────────────────────────────────────────
  Widget _buildReviewSession(ThemeData theme, bool isDark, Color accent) {
    final card = _cards[_currentIndex];
    final progress = (_currentIndex) / _cards.length;

    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: progress,
          backgroundColor: (isDark ? DarkColors.outline : LightColors.outline),
          valueColor: AlwaysStoppedAnimation<Color>(accent),
          minHeight: 3,
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              children: [
                // Card type + subject badge
                Row(children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      card.cardTypeLabel,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: accent, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      card.subjectName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? DarkColors.onSurfaceVariant
                            : LightColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),

                const SizedBox(height: 20),

                // Flip card
                Expanded(
                  child: GestureDetector(
                    onTap: _flipCard,
                    child: AnimatedBuilder(
                      animation: _flipAnimation,
                      builder: (context, child) {
                        final isShowingFront = _flipAnimation.value < 0.5;
                        final angle = _flipAnimation.value * math.pi;
                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                          alignment: Alignment.center,
                          child: isShowingFront
                              ? _CardFace(
                                  isDark: isDark,
                                  accent: accent,
                                  title: 'QUESTION',
                                  content: card.front,
                                  isFront: true,
                                  chapterName: card.chapterName,
                                )
                              : Transform(
                                  transform: Matrix4.identity()..rotateY(math.pi),
                                  alignment: Alignment.center,
                                  child: _CardFace(
                                    isDark: isDark,
                                    accent: accent,
                                    title: 'ANSWER',
                                    content: card.back,
                                    isFront: false,
                                    chapterName: card.chapterName,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Tap hint
                if (!_isFlipped)
                  Text(
                    'Tap the card to reveal the answer',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? DarkColors.onSurfaceVariant
                          : LightColors.onSurfaceVariant,
                    ),
                  ).animate(on: !_isFlipped).fadeIn(delay: 600.ms),

                // Rating buttons (only after flip)
                if (_isFlipped) ...[
                  Text(
                    'How well did you remember?',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? DarkColors.onSurfaceVariant
                          : LightColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _RatingButton(
                          label: 'Hard',
                          sublabel: 'Show again soon',
                          emoji: '😓',
                          color: const Color(0xFFBF5B65),
                          onTap: () => _processReview(1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _RatingButton(
                          label: 'Good',
                          sublabel: 'Normal interval',
                          emoji: '😊',
                          color: const Color(0xFFB87D3C),
                          onTap: () => _processReview(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _RatingButton(
                          label: 'Easy',
                          sublabel: 'Longer interval',
                          emoji: '🚀',
                          color: const Color(0xFF5C8C6C),
                          onTap: () => _processReview(5),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Session summary ───────────────────────────────────────────────────────
  Widget _buildSessionSummary(ThemeData theme, bool isDark, Color accent) {
    final total = _hardCount + _goodCount + _easyCount;
    final retentionPct =
        total > 0 ? ((_goodCount + _easyCount) / total * 100).round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text('🎊', style: const TextStyle(fontSize: 56))
              .animate()
              .scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text(
            'Session Complete!',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ).animate(delay: 150.ms).fadeIn(),
          const SizedBox(height: 8),
          Text(
            'You reviewed $total cards today.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? DarkColors.onSurfaceVariant
                  : LightColors.onSurfaceVariant,
            ),
          ).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 32),

          // Stats grid
          Row(children: [
            _StatCard(
                isDark: isDark,
                emoji: '😓',
                label: 'Hard',
                value: '$_hardCount',
                color: const Color(0xFFBF5B65)),
            const SizedBox(width: 10),
            _StatCard(
                isDark: isDark,
                emoji: '😊',
                label: 'Good',
                value: '$_goodCount',
                color: const Color(0xFFB87D3C)),
            const SizedBox(width: 10),
            _StatCard(
                isDark: isDark,
                emoji: '🚀',
                label: 'Easy',
                value: '$_easyCount',
                color: const Color(0xFF5C8C6C)),
          ]).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),

          const SizedBox(height: 20),

          // Retention score
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withOpacity(0.20)),
            ),
            child: Column(children: [
              Text(
                '$retentionPct%',
                style: theme.textTheme.displaySmall
                    ?.copyWith(color: accent, fontWeight: FontWeight.w800),
              ),
              Text(
                'Retention Rate',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDark
                      ? DarkColors.onSurfaceVariant
                      : LightColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                retentionPct >= 80
                    ? 'Excellent! Your memory is strong 💪'
                    : retentionPct >= 60
                        ? 'Good progress! Keep reviewing the harder cards.'
                        : 'Keep practising — spaced repetition will help!',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ]),
          ).animate(delay: 400.ms).fadeIn(),

          const SizedBox(height: 32),

          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Done'),
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ).animate(delay: 500.ms).fadeIn(),
        ],
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _CardFace extends StatelessWidget {
  final bool isDark;
  final Color accent;
  final String title;
  final String content;
  final bool isFront;
  final String chapterName;

  const _CardFace({
    required this.isDark,
    required this.accent,
    required this.title,
    required this.content,
    required this.isFront,
    required this.chapterName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surfaceCard : LightColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFront
              ? (isDark ? DarkColors.outline : LightColors.outline)
              : accent.withOpacity(0.30),
          width: isFront ? 0.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isFront
                ? Colors.black.withOpacity(0.06)
                : accent.withOpacity(0.10),
            blurRadius: isFront ? 8 : 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Label at top
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: (isFront ? LightColors.outline : accent).withOpacity(
                    isFront ? 0.3 : 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: isFront
                      ? (isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant)
                      : accent,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Main content
            Text(
              content,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                fontWeight: FontWeight.w500,
                color: isDark ? DarkColors.onSurface : LightColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            // Chapter name at bottom
            Text(
              chapterName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark
                    ? DarkColors.onSurfaceVariant
                    : LightColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _RatingButton({
    required this.label,
    required this.sublabel,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? DarkColors.onSurfaceVariant
                      : LightColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final bool isDark;
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.isDark,
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: color),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? DarkColors.onSurfaceVariant
                    : LightColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
