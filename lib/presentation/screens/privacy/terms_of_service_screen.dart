// lib/presentation/screens/privacy/terms_of_service_screen.dart
//
// Terms of Service displayed in-app.
//
// ✅ PRODUCTION FIX (v6): Inline content means the screen always renders
//    even when https://prepsarthi.app/terms is not yet live. Once the hosted
//    page is live, the paywall external link will open it; this screen serves
//    as a guaranteed fallback for Play Store review and in-app navigation.
//
// Play Store requirement checklist for this content:
//  ✅ Subscription terms — 7-day free trial, auto-renewal, cancellation method
//  ✅ Refund policy reference
//  ✅ App-specific acceptable use
//  ✅ Disclaimer of warranty
//  ✅ Contact information

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Use'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Section(
              'PrepSarthi — Terms of Use',
              'Last updated: January 2026\n\n'
              'Please read these Terms of Use ("Terms") carefully before using PrepSarthi. '
              'By using the app, you agree to these Terms. If you do not agree, '
              'do not use the app.',
              isDark: isDark, theme: theme, isTitle: true,
            ),
            _Section(
              '1. Eligibility',
              '• You must be at least 13 years old to use PrepSarthi.\n'
              '• If you are under 18, your parent or guardian must review and agree to these Terms.\n'
              '• By creating an account, you confirm that the information you provide is accurate.',
              isDark: isDark, theme: theme,
            ),
            _Section(
              '2. PrepSarthi Premium — Subscription Terms',
              'PrepSarthi offers an optional subscription called PrepSarthi Premium.\n\n'
              '• Free Trial: New eligible users may receive a 7-day free trial. '
              'Your Google Play account will be charged at the end of the trial unless '
              'you cancel at least 24 hours before the trial period ends.\n\n'
              '• Billing Cycle: Subscriptions are available on Monthly, Quarterly, '
              'and Annual plans. Pricing is shown in the app before purchase.\n\n'
              '• Auto-renewal: Subscriptions automatically renew unless auto-renewal '
              'is turned off at least 24 hours before the end of the current period.\n\n'
              '• Cancellation: Cancel anytime via Google Play → Account → '
              'Subscriptions → PrepSarthi. Access continues until the end of the paid period.\n\n'
              '• Refunds: Purchases are processed by Google Play. Refund requests are '
              'subject to Google Play\'s refund policy. Contact Google Play Support for refunds.\n\n'
              '• Price Changes: We may change subscription prices. We will notify you '
              'before any price change takes effect on your renewal.',
              isDark: isDark, theme: theme,
            ),
            _Section(
              '3. Acceptable Use',
              'You agree NOT to:\n'
              '• Attempt to reverse-engineer, decompile, or modify the app\n'
              '• Use the app for any unlawful purpose\n'
              '• Share your account credentials with others\n'
              '• Circumvent or attempt to bypass any subscription or access control\n'
              '• Misuse the AI features to generate inappropriate or harmful content',
              isDark: isDark, theme: theme,
            ),
            _Section(
              '4. AI Features',
              'PrepSarthi uses Google Vertex AI (Gemini) to generate study plans, '
              'SWOT analysis, and pattern reports. AI-generated content is provided '
              'for study guidance only and should not be taken as professional academic '
              'or medical advice. Accuracy is not guaranteed. We are not responsible for '
              'outcomes based on AI-generated suggestions.',
              isDark: isDark, theme: theme,
            ),
            _Section(
              '5. Intellectual Property',
              'All content in PrepSarthi — including study plans, UI design, icons, '
              'and text — is the intellectual property of PrepSarthi or its licensors. '
              'You may not reproduce, distribute, or create derivative works '
              'without explicit written permission.',
              isDark: isDark, theme: theme,
            ),
            _Section(
              '6. Disclaimer of Warranty',
              'PrepSarthi is provided "as is" without warranty of any kind. '
              'We do not guarantee that the app will be error-free, uninterrupted, '
              'or that it will help you achieve specific exam scores or results. '
              'Study outcomes depend on your effort, consistency, and many factors '
              'outside our control.',
              isDark: isDark, theme: theme,
            ),
            _Section(
              '7. Limitation of Liability',
              'To the maximum extent permitted by applicable law, PrepSarthi and its '
              'team shall not be liable for any indirect, incidental, or consequential '
              'damages arising out of your use of the app, including but not limited to '
              'loss of data, missed exam preparation, or exam results.',
              isDark: isDark, theme: theme,
            ),
            _Section(
              '8. Termination',
              'We reserve the right to suspend or terminate your account if you violate '
              'these Terms. Upon termination, your right to use the app ceases '
              'immediately. Subscription refunds in this case are at our discretion.',
              isDark: isDark, theme: theme,
            ),
            _Section(
              '9. Changes to Terms',
              'We may update these Terms from time to time. We will notify you of '
              'material changes via the app or by email. Continued use of the app '
              'after changes constitutes your acceptance of the revised Terms.',
              isDark: isDark, theme: theme,
            ),
            _Section(
              '10. Governing Law',
              'These Terms are governed by the laws of India. Any disputes '
              'shall be resolved in the courts of Gujarat, India.',
              isDark: isDark, theme: theme,
            ),
            _Section(
              '11. Contact',
              'For questions about these Terms:\n'
              'Email: support@prepsarthi.app\n'
              'Website: https://prepsarthi.app/terms',
              isDark: isDark, theme: theme,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? DarkColors.primary : LightColors.primary)
                    .withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: (isDark ? DarkColors.primary : LightColors.primary)
                        .withOpacity(0.2)),
              ),
              child: Text(
                '💡 Subscription Management: To cancel, go to Google Play Store → '
                'Menu → Subscriptions → PrepSarthi → Cancel. '
                'You keep access until the end of the paid period.',
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
                ? theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)
                : theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? DarkColors.onSurfaceVariant
                  : LightColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
