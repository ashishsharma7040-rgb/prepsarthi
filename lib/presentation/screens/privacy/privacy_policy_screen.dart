// lib/presentation/screens/privacy/privacy_policy_screen.dart
//
// Privacy Policy screen — required for Play Store apps using Firebase & AI.
// Privacy policy is hosted at https://prepsarthi.app/privacy

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Section(
              'PrepSarthi Privacy Policy',
              'Last updated: January 2026\n\n'
              'PrepSarthi ("we", "app") is committed to protecting your privacy. '
              'This policy explains what data we collect, how we use it, and your rights.',
              isDark: isDark, theme: theme, isTitle: true,
            ),
            _Section(
              '1. Data We Collect',
              '• Google Account information (name, email, profile photo) via Google Sign-In\n'
              '• Study data you enter: chapters studied, hours logged, test scores, plan entries\n'
              '• App usage data: study sessions, streaks, achievements\n'
              '• Device information for crash reporting and analytics',
              isDark: isDark, theme: theme,
            ),
            _Section(
              '2. How We Use Your Data',
              '• To generate and personalise your study plan\n'
              '• To power AI features (SWOT analysis, pattern report) using Google Vertex AI — your study data is sent to Google\'s servers for processing\n'
              '• To sync your progress and subscription status via Firebase Firestore\n'
              '• To send study reminders (only if you enable notifications)\n'
              '• To process subscription payments via Google Play Billing',
              isDark: isDark, theme: theme,
            ),
            _Section(
              '3. Third-Party Services',
              'PrepSarthi uses the following Google services:\n\n'
              '• Firebase Authentication — handles Google Sign-In securely\n'
              '• Firebase Firestore — stores your study progress and subscription status\n'
              '• Firebase Vertex AI (Gemini) — processes your study data to generate AI insights\n'
              '• Google Play Billing — handles subscription payments\n\n'
              'All data sent to these services is governed by Google\'s Privacy Policy: '
              'https://policies.google.com/privacy',
              isDark: isDark, theme: theme,
            ),
            _Section(
              '4. Data Storage',
              '• Study data is stored locally on your device using Isar database\n'
              '• Your progress and subscription status are also synced to Firebase Firestore\n'
              '• AI analysis data is processed on Google\'s servers and NOT stored long-term by us',
              isDark: isDark, theme: theme,
            ),
            _Section(
              '5. Your Rights',
              '• Delete your data: Use "Clear All Study Data" in Settings\n'
              '• Export your data: Use the PDF export feature\n'
              '• Request account deletion: Email support@prepsarthi.app\n'
              '• Opt out of notifications: Disable in Settings → Notifications',
              isDark: isDark, theme: theme,
            ),
            _Section(
              '6. Children\'s Privacy',
              'PrepSarthi is intended for students aged 15 and above. '
              'We do not knowingly collect personal data from children under 13. '
              'If you believe your child has provided us data, contact support@prepsarthi.app.',
              isDark: isDark, theme: theme,
            ),
            _Section(
              '7. Changes to This Policy',
              'We may update this policy periodically. We will notify you of significant changes '
              'via the app. Your continued use after changes constitutes acceptance.',
              isDark: isDark, theme: theme,
            ),
            _Section(
              '8. Contact Us',
              'For privacy questions or data deletion requests:\n'
              'Email: support@prepsarthi.app\n'
              'Website: https://prepsarthi.app/privacy',
              isDark: isDark, theme: theme,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? DarkColors.primary : LightColors.primary).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (isDark ? DarkColors.primary : LightColors.primary).withOpacity(0.2)),
              ),
              child: Text(
                '⚠️ AI Disclosure: When you use AI features (SWOT analysis, plan regeneration), '
                'your study data is transmitted to Google\'s Vertex AI servers for processing. '
                'Do not include sensitive personal information in study notes.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? DarkColors.primary : LightColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title, body;
  final bool isDark, isTitle;
  final ThemeData theme;

  const _Section(this.title, this.body, {
    required this.isDark, required this.theme, this.isTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: isTitle
                ? theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)
                : theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
