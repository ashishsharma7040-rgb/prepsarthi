// lib/presentation/screens/auth/login_screen.dart
//
// ── Shanti Scholar changes (UI only, zero auth logic change) ─────────────────
// • Background Stack (gradient Container + decorative Positioned circle)
//   replaced with SoothingBackground(variant: BackgroundVariant.onboarding)
//   → warm gradient + rangoli dot pattern + slow ambient blobs
// • AppHaptics.signIn() fires at start of _signIn() for tactile feedback
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/firebase/firebase_diagnostics.dart';
import '../../../core/utils/app_haptics.dart';                         // ← NEW
import '../../../data/repositories/auth_repository.dart';
import '../../providers/all_providers.dart';
import '../../widgets/common/soothing_background.dart';               // ← NEW
import '../../../router/app_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // If already logged in, redirect immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authProvider);
      if (auth.isLoggedIn) {
        context.go(
            auth.onboardingComplete ? AppRoutes.dashboard : AppRoutes.welcome);
      }
    });
  }

  Future<void> _signIn() async {
    AppHaptics.signIn();                                               // ← NEW

    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await AuthRepository.signInWithGoogle();

    if (!mounted) return;

    if (result.isSuccess) {
      await ref.read(authProvider.notifier).saveUser(result.user!);
      if (!mounted) return;
      context.go(result.user!.onboardingComplete
          ? AppRoutes.dashboard
          : AppRoutes.welcome);
    } else if (result.cancelled) {
      setState(() => _loading = false);
    } else {
      String errorText = result.error ?? 'Sign-in failed. Please try again.';
      if (errorText.contains('signing certificate') ||
          errorText.contains('ApiException') ||
          errorText.contains('DEVELOPER_ERROR')) {
        final diagnostics = await FirebaseRuntimeDiagnostics.collect();
        if (!mounted) return;
        if (diagnostics.apkSha1 != null) {
          errorText = 'SHA mismatch (ApiException:10).\n'
              'Add these to Firebase Console for Android app com.prepsarthi.app:\n'
              'SHA-1: ${diagnostics.apkSha1}\n'
              'SHA-256: ${diagnostics.apkSha256 ?? "tap Copy Firebase diagnostics"}\n'
              'Then download fresh google-services.json, update Codemagic, and rebuild.';
        }
      }
      setState(() {
        _error = errorText;
        _loading = false;
      });
    }
  }

  Future<void> _copyFirebaseDiagnostics() async {
    final diagnostics = await FirebaseRuntimeDiagnostics.collect();
    final summary = diagnostics.toClipboardText(
      lastAuthErrorCode: AuthRepository.lastAuthErrorCode,
      lastAuthErrorMessage: AuthRepository.lastAuthErrorMessage,
      lastAuthErrorDetails: AuthRepository.lastAuthErrorDetails,
    );
    await Clipboard.setData(ClipboardData(text: summary));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Firebase diagnostics copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final firebaseConfigured = Firebase.apps.isNotEmpty;

    return Scaffold(
      // ── SoothingBackground replaces the old gradient + decorative circle ─
      body: SoothingBackground(                                        // ← CHANGED
        variant: BackgroundVariant.onboarding,                         // ← CHANGED
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // App icon — premium otter logo matching launcher icon
                Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? DarkColors.gradientPrimary
                          : LightColors.gradientPrimary,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark
                                ? DarkColors.primary
                                : LightColors.primary)
                            .withOpacity(0.40),
                        blurRadius: 32,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .scale(
                        begin: const Offset(0.5, 0.5),
                        duration: 700.ms,
                        curve: Curves.elasticOut)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 28),

                Text(
                  'PrepSarthi',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: isDark
                            ? DarkColors.gradientPrimary
                            : LightColors.gradientPrimary,
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                  ),
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),

                const SizedBox(height: 8),

                Text(
                  'Your Personal JEE / NEET\nRank Booster',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? DarkColors.onSurfaceVariant
                        : LightColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2),

                const Spacer(flex: 2),

                // Feature chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Chip('🧠', 'AI-Powered Plan', isDark),
                    _Chip('📊', 'Smart Progress', isDark),
                    _Chip('🔔', 'Spaced Revision', isDark),
                  ],
                ).animate(delay: 500.ms).fadeIn(),

                const Spacer(flex: 1),

                // Error
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: LightColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: LightColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: LightColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_error!,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: LightColors.error)),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),

                if (!firebaseConfigured)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: LightColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: LightColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_off_rounded,
                            color: LightColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            FirebaseRuntimeDiagnostics
                                .firebaseNotInitializedMessage,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: LightColors.error),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),

                if (kDebugMode)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _copyFirebaseDiagnostics,
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy Firebase diagnostics'),
                    ),
                  ).animate().fadeIn(),

                // Google Sign-In button
                _GoogleButton(
                  loading: _loading,
                  onTap: firebaseConfigured ? _signIn : null,
                  isDark: isDark,
                ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.4),

                const SizedBox(height: 16),

                Text(
                  'By continuing, you agree to our Terms of Service & Privacy Policy.\nYour study data is processed using Google Firebase & Vertex AI.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? DarkColors.onSurfaceVariant
                        : LightColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ).animate(delay: 700.ms).fadeIn(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final bool loading, isDark;
  final VoidCallback? onTap;
  const _GoogleButton(
      {required this.loading, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: onTap == null
              ? (isDark ? DarkColors.surface : LightColors.surfaceVariant)
              : (isDark ? DarkColors.surfaceVariant : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? DarkColors.outline : LightColors.outline,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4)),
          ],
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5)))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('G',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4285F4))),
                  const SizedBox(width: 12),
                  Text(
                    onTap == null
                        ? 'Firebase setup required'
                        : 'Continue with Google',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: onTap == null
                          ? (isDark
                              ? DarkColors.onSurfaceVariant
                              : LightColors.onSurfaceVariant)
                          : null,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String emoji, label;
  final bool isDark;
  const _Chip(this.emoji, this.label, this.isDark);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color:
                isDark ? DarkColors.surfaceVariant : LightColors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isDark ? DarkColors.outline : LightColors.outline,
                width: 0.5),
          ),
          child:
              Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center),
      ],
    );
  }
}
