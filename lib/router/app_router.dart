// lib/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/providers/all_providers.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/onboarding/onboarding_screens.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/dashboard/today_command_center.dart';
import '../presentation/screens/plan/weekly_plan_screen.dart';
import '../presentation/screens/plan/chapter_detail_screen.dart';
import '../presentation/screens/plan/chapter_mastery_screen.dart';
import '../presentation/screens/calendar/monthly_calendar_screen.dart';
import '../presentation/screens/study_screens.dart';
import '../presentation/screens/ai/ai_screens.dart';
import '../presentation/screens/pomodoro/pomodoro_timer_screen.dart';
import '../presentation/screens/settings/settings_and_subscription.dart';
import '../presentation/screens/settings/premium_paywall_screen.dart';
import '../presentation/screens/past_papers/past_papers_screen.dart';
import '../presentation/screens/export/export_screen.dart';
import '../presentation/screens/test_score/test_score_screen.dart';
import '../presentation/screens/privacy/privacy_policy_screen.dart';
import '../presentation/screens/privacy/terms_of_service_screen.dart';
import '../presentation/screens/analytics/weakness_radar_screen.dart';
import '../presentation/screens/mistakes/mistake_notebook_screen.dart';
import '../presentation/screens/achievements/achievements_screen.dart';
import '../presentation/widgets/common/shared_widgets.dart';

// ─── Route paths ──────────────────────────────────────────────────────────────
class AppRoutes {
  static const login = '/login';

  static const welcome = '/onboarding/welcome';
  static const targetSelector = '/onboarding/target';
  static const examYear = '/onboarding/year';
  static const dailyHours = '/onboarding/hours';
  static const blackoutDates = '/onboarding/blackout';
  static const generatingPlan = '/onboarding/generating';

  static const dashboard = '/dashboard';
  static const plan = '/plan';
  static const calendar = '/calendar';
  static const log = '/log';
  static const revision = '/revision';

  static const swotReport = '/ai/swot';
  static const patternReport = '/ai/pattern';

  static const pomodoro = '/pomodoro';
  static const pastPapers = '/papers';
  static const export = '/export';
  static const testScore = '/test-score';
  static const privacyPolicy = '/privacy';
  static const termsOfService = '/terms';

  // Premium features
  static const todayMission = '/today';
  static const weaknessRadar = '/analytics/weakness';
  static const mistakeNotebook = '/mistakes';
  static const chapterMastery = '/plan/mastery';
  static const premiumPaywall = '/premium';

  static const settings = '/settings';
  static const subscription = '/settings/subscription';
  static const achievements = '/achievements';
}

// ─── Router provider ──────────────────────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoading = authNotifier.isLoading;
      if (isLoading) return null;

      final isLoggedIn = authNotifier.isLoggedIn;
      final onboarded = authNotifier.onboardingComplete;
      final path = state.uri.path;

      if (!isLoggedIn && path != AppRoutes.login) return AppRoutes.login;

      if (isLoggedIn && !onboarded &&
          !path.startsWith('/onboarding') &&
          path != AppRoutes.login) {
        return AppRoutes.welcome;
      }

      if (isLoggedIn && onboarded &&
          (path == AppRoutes.login || path.startsWith('/onboarding'))) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (_, s) => _fade(s, const LoginScreen()),
      ),

      GoRoute(path: AppRoutes.welcome,
          pageBuilder: (_, s) => _slide(s, const WelcomeScreen())),
      GoRoute(path: AppRoutes.targetSelector,
          pageBuilder: (_, s) => _slide(s, const TargetSelectorScreen())),
      GoRoute(path: AppRoutes.examYear,
          pageBuilder: (_, s) => _slide(s, const ExamYearScreen())),
      GoRoute(path: AppRoutes.dailyHours,
          pageBuilder: (_, s) => _slide(s, const DailyHoursScreen())),
      GoRoute(path: AppRoutes.blackoutDates,
          pageBuilder: (_, s) => _slide(s, const BlackoutDatesScreen())),
      GoRoute(path: AppRoutes.generatingPlan,
          pageBuilder: (_, s) => _fade(s, const GeneratingPlanScreen())),

      // Main Shell
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (_, s) => _fade(s, const DashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.plan,
            pageBuilder: (_, s) => _fade(s, const WeeklyPlanScreen()),
            routes: [
              GoRoute(
                path: 'chapter/:name',
                pageBuilder: (_, s) => _slide(s,
                    ChapterDetailScreen(
                      chapterName: Uri.decodeComponent(
                          s.pathParameters['name'] ?? ''),
                    )),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.calendar,
            pageBuilder: (_, s) => _fade(s, const MonthlyCalendarScreen()),
          ),
          GoRoute(
            path: AppRoutes.log,
            pageBuilder: (_, s) => _fade(s, const DailyLogScreen()),
          ),
          GoRoute(
            path: AppRoutes.revision,
            pageBuilder: (_, s) => _fade(s, const RevisionScheduleScreen()),
          ),
        ],
      ),

      // AI (premium-gated)
      GoRoute(path: AppRoutes.swotReport,
          pageBuilder: (_, s) => _slide(s, const SWOTReportScreen())),
      GoRoute(path: AppRoutes.patternReport,
          pageBuilder: (_, s) => _slide(s, const PatternReportScreen())),

      // Utilities
      GoRoute(
        path: AppRoutes.pomodoro,
        pageBuilder: (_, s) {
          final extras = s.extra as Map<String, String>?;
          return _slide(
            s,
            PomodoroTimerScreen(
              initialChapter: extras?['chapter'],
              initialSubject: extras?['subject'],
            ),
          );
        },
      ),
      GoRoute(path: AppRoutes.pastPapers,
          pageBuilder: (_, s) => _slide(s, const PastPapersScreen())),
      GoRoute(path: AppRoutes.export,
          pageBuilder: (_, s) => _slide(s, const ExportScreen())),
      GoRoute(path: AppRoutes.testScore,
          pageBuilder: (_, s) => _slide(s, const TestScoreScreen())),
      GoRoute(path: AppRoutes.privacyPolicy,
          pageBuilder: (_, s) => _slide(s, const PrivacyPolicyScreen())),
      GoRoute(path: AppRoutes.termsOfService,
          pageBuilder: (_, s) => _slide(s, const TermsOfServiceScreen())),

      // ── Premium features (NEW) ─────────────────────────────────────────────
      GoRoute(path: AppRoutes.todayMission,
          pageBuilder: (_, s) => _slide(s, const TodayCommandCenterPage())),
      GoRoute(path: AppRoutes.weaknessRadar,
          pageBuilder: (_, s) => _slide(s, const WeaknessRadarScreen())),
      GoRoute(path: AppRoutes.mistakeNotebook,
          pageBuilder: (_, s) => _slide(s, const MistakeNotebookScreen())),
      GoRoute(path: AppRoutes.chapterMastery,
          pageBuilder: (_, s) => _slide(s, const ChapterMasteryScreen())),
      GoRoute(path: AppRoutes.premiumPaywall,
          pageBuilder: (_, s) => _slide(s, const PremiumPaywallScreen())),
      GoRoute(path: AppRoutes.achievements,
          pageBuilder: (_, s) => _slide(s, const AchievementsScreen())),

      // Settings
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (_, s) => _slide(s, const SettingsScreen()),
        routes: [
          GoRoute(
            path: 'subscription',
            pageBuilder: (_, s) => _slide(s, const PremiumPaywallScreen()),
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚫', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Page not found',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

CustomTransitionPage<T> _fade<T>(GoRouterState s, Widget child) =>
    CustomTransitionPage<T>(
      key: s.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, animation, __, w) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: w,
      ),
    );

CustomTransitionPage<T> _slide<T>(GoRouterState s, Widget child) =>
    CustomTransitionPage<T>(
      key: s.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, __, w) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
        child: w,
      ),
    );
