import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';

class StartupErrorScreen extends StatelessWidget {
  final String? debugDetail;
  final VoidCallback onRetry;

  const StartupErrorScreen({
    super.key,
    required this.onRetry,
    this.debugDetail,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? DarkColors.onSurface : LightColors.onSurface;
    final onSurfaceVariant =
        isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant;
    final outline = isDark ? DarkColors.outline : LightColors.outline;
    final error = isDark ? DarkColors.error : LightColors.error;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: error.withValues(alpha: 0.10),
                    ),
                    child: Icon(
                      Icons.sync_problem_rounded,
                      size: 42,
                      color: error,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'PrepSarthi could not start',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'We could not prepare your study dashboard. Please retry. '
                    'If this keeps happening, reinstalling the app can help.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: onSurfaceVariant,
                          height: 1.6,
                        ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? DarkColors.primary : LightColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  if (kDebugMode && debugDetail != null) ...[
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? DarkColors.surfaceVariant
                            : LightColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: outline, width: 0.6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.bug_report_rounded,
                                size: 16,
                                color: Color(0xFFFF9800),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Debug details',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: const Color(0xFFFF9800),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: debugDetail!),
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Debug details copied'),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Copy'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            debugDetail!,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: onSurfaceVariant,
                                  fontFamily: 'monospace',
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
