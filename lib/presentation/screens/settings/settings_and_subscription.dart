// lib/presentation/screens/settings/settings_and_subscription.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'premium_paywall_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/local/isar/isar_service.dart';
import '../../../data/local/preload/syllabus_loader.dart';
import '../../providers/all_providers.dart';
import '../../../router/app_router.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SETTINGS SCREEN
// ═══════════════════════════════════════════════════════════════════════════
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final auth = ref.watch(authProvider);
    final subscription = ref.watch(subscriptionProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverAppBar(title: Text('Settings'), pinned: true),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // Profile
                  _ProfileCard(
                    user: auth.user,
                    isPremium: subscription.isPremium,
                    isDark: isDark,
                    onUpgrade: () => context.push(AppRoutes.subscription),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 22),

                  // Appearance
                  _Section(title: 'Appearance', isDark: isDark, children: [
                    _ThemeTile(current: settings.themeMode, isDark: isDark,
                        onChanged: (m) => ref.read(settingsProvider.notifier).setThemeMode(m)),
                  ]).animate(delay: 60.ms).fadeIn(),
                  const SizedBox(height: 14),

                  // Notifications
                  _Section(title: 'Notifications', isDark: isDark, children: [
                    _SwitchTile(
                      emoji: '🔔', label: 'Study Reminders',
                      subtitle: 'Daily reminder at ${settings.notificationTime}',
                      value: settings.notificationsEnabled, isDark: isDark,
                      onChanged: (v) => ref.read(settingsProvider.notifier).setNotifications(
                        v, userName: auth.displayName,
                      ),
                    ),
                    _Divider(isDark: isDark),
                    _NavTile(
                      emoji: '⏰', label: 'Reminder Time',
                      subtitle: settings.notificationTime, isDark: isDark,
                      onTap: () => _pickTime(context, ref, settings, auth.displayName),
                    ),
                  ]).animate(delay: 100.ms).fadeIn(),
                  const SizedBox(height: 14),

                  // Pomodoro
                  _Section(title: 'Pomodoro Timer', isDark: isDark, children: [
                    _StepperTile(emoji: '🍅', label: 'Focus Duration',
                        value: settings.pomodoroWork, unit: 'min', min: 10, max: 60, step: 5, isDark: isDark,
                        onChanged: (v) => ref.read(settingsProvider.notifier).setPomodoroWork(v)),
                    _Divider(isDark: isDark),
                    _StepperTile(emoji: '☕', label: 'Break Duration',
                        value: settings.pomodoroBreak, unit: 'min', min: 3, max: 20, step: 1, isDark: isDark,
                        onChanged: (v) => ref.read(settingsProvider.notifier).setPomodoroBreak(v)),
                  ]).animate(delay: 140.ms).fadeIn(),
                  const SizedBox(height: 14),

                  // Subscription
                  _Section(title: 'Subscription', isDark: isDark, children: [
                    _NavTile(
                      emoji: subscription.isPremium ? '👑' : '🔓',
                      label: subscription.isPremium ? 'Premium Active' : 'Upgrade to Premium',
                      subtitle: subscription.isPremium
                          ? '${subscription.planType ?? ''} plan • expires ${_fmtDate(subscription.expiryDate)}'
                          : '7-day free trial available',
                      isDark: isDark,
                      trailing: subscription.isPremium
                          ? _ActiveBadge(theme: theme)
                          : null,
                      onTap: () => context.push(AppRoutes.subscription),
                    ),
                  ]).animate(delay: 180.ms).fadeIn(),
                  const SizedBox(height: 14),

                  // Data
                  _Section(title: 'Data & Export', isDark: isDark, children: [
                    _NavTile(emoji: '🏅', label: 'Achievements',
                        subtitle: 'View earned badges & milestones', isDark: isDark,
                        onTap: () => context.push(AppRoutes.achievements)),
                    _Divider(isDark: isDark),
                    _NavTile(emoji: '📤', label: 'Export Progress PDF',
                        subtitle: 'Share with parents or coaching', isDark: isDark,
                        onTap: () => context.push(AppRoutes.export)),
                    _Divider(isDark: isDark),
                    _NavTile(emoji: '📊', label: 'Mock Test Scores',
                        subtitle: 'Track marks, percentile & subject analysis', isDark: isDark,
                        onTap: () => context.push(AppRoutes.testScore)),
                    _Divider(isDark: isDark),
                    _NavTile(emoji: '🔄', label: 'Reload Syllabus',
                        subtitle: 'Reset chapter data from bundled JSON', isDark: isDark,
                        onTap: () => _confirmReload(context)),
                    _Divider(isDark: isDark),
                    _NavTile(emoji: '🗑️', label: 'Clear All Study Data',
                        subtitle: 'Deletes logs, plans and progress permanently',
                        labelColor: LightColors.error, isDark: isDark,
                        onTap: () => _confirmClear(context, ref)),
                  ]).animate(delay: 220.ms).fadeIn(),
                  const SizedBox(height: 14),

                  // About
                  _Section(title: 'About', isDark: isDark, children: [
                    _NavTile(emoji: '📄', label: 'Privacy Policy', isDark: isDark,
                        onTap: () => context.push(AppRoutes.privacyPolicy)),
                    _Divider(isDark: isDark),
                    _NavTile(emoji: '📮', label: 'Contact Support', isDark: isDark,
                        onTap: () => _launch('mailto:support@prepsarthi.app')),
                    _Divider(isDark: isDark),
                    _NavTile(emoji: '⭐', label: 'Rate the App', isDark: isDark,
                        onTap: () => _launch('https://play.google.com/store/apps/details?id=com.prepsarthi.app')),
                    _Divider(isDark: isDark),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Text('ℹ️', style: TextStyle(fontSize: 22)),
                      title: Text('Version', style: theme.textTheme.bodyMedium),
                      trailing: Text('1.2.0', style: theme.textTheme.labelMedium),
                    ),
                  ]).animate(delay: 260.ms).fadeIn(),
                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: () => _signOut(context, ref),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: LightColors.error,
                      side: const BorderSide(color: LightColors.error),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ).animate(delay: 300.ms).fadeIn(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '';
    return '${d.day}/${d.month}/${d.year}';
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref, SettingsState s, String name) async {
    final parts = s.notificationTime.split(':');
    final current = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked != null) {
      final hhmm = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await ref.read(settingsProvider.notifier).setNotificationTime(hhmm, userName: name);
    }
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This permanently deletes all logs, plans and progress. Cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: LightColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await IsarService.clearAllStudyData();
      await SyllabusLoader.safeReload();
      ref.invalidate(planProvider);
      ref.invalidate(studyLogProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ All data cleared and syllabus reloaded')),
        );
      }
    }
  }

  Future<void> _confirmReload(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reload Syllabus?'),
        content: const Text(
          'This updates chapter metadata (weightage, hours, difficulty) '
          'from the bundled syllabus JSON.\n\n'
          'Your study progress, mastery levels, logs, and plan are fully '
          'preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reload'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await SyllabusLoader.safeReload();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Syllabus reloaded')),
        );
      }
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).signOut();
    if (context.mounted) context.go(AppRoutes.login);
  }

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUBSCRIPTION SCREEN — real IAP wired
// ═══════════════════════════════════════════════════════════════════════════
// SubscriptionScreen redirects to the new full-featured PremiumPaywallScreen
// to avoid breaking any existing references.
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PremiumPaywallScreen();
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.user,
    required this.isPremium,
    required this.isDark,
    required this.onUpgrade,
  });

  final UserSchema? user;
  final bool isPremium;
  final bool isDark;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = user?.displayName.trim() ?? '';
    final name = displayName.isNotEmpty ? displayName : 'Aspirant';
    final email = user?.email?.trim();
    final accent = isPremium ? LightColors.primary : LightColors.secondary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surfaceCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accent.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: accent.withValues(alpha: 0.14),
                child: Text(
                  name.characters.first.toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email?.isNotEmpty == true ? email! : 'Signed in student',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              if (isPremium) _ActiveBadge(theme: theme),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isPremium
                ? 'PrepSarthi Pro is active on this account.'
                : 'Unlock AI planning, analytics, and premium study tools.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.82),
            ),
          ),
          if (!isPremium) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onUpgrade,
              icon: const Icon(Icons.workspace_premium_rounded),
              label: const Text('View Premium Plans'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.isDark,
    required this.children,
  });

  final String title;
  final bool isDark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surfaceCard : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.current,
    required this.isDark,
    required this.onChanged,
  });

  final String current;
  final bool isDark;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Text('Theme', style: TextStyle(fontSize: 16)),
      title: Text(
        'App Theme',
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        'Choose how the app should look',
        style: theme.textTheme.bodySmall,
      ),
      trailing: DropdownButton<String>(
        value: current,
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(value: 'system', child: Text('System')),
          DropdownMenuItem(value: 'light', child: Text('Light')),
          DropdownMenuItem(value: 'dark', child: Text('Dark')),
        ],
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  final String emoji;
  final String label;
  final String subtitle;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(emoji, style: const TextStyle(fontSize: 22)),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: Switch.adaptive(value: value, onChanged: onChanged),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.emoji,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.labelColor,
  });

  final String emoji;
  final String label;
  final String? subtitle;
  final bool isDark;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Text(emoji, style: const TextStyle(fontSize: 22)),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: labelColor,
        ),
      ),
      subtitle: subtitle == null ? null : Text(subtitle!, style: theme.textTheme.bodySmall),
      trailing: trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
          ),
    );
  }
}

class _StepperTile extends StatelessWidget {
  const _StepperTile({
    required this.emoji,
    required this.label,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.step,
    required this.isDark,
    required this.onChanged,
  });

  final String emoji;
  final String label;
  final int value;
  final String unit;
  final int min;
  final int max;
  final int step;
  final bool isDark;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDecrease = value > min;
    final canIncrease = value < max;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(emoji, style: const TextStyle(fontSize: 22)),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text('$value $unit', style: theme.textTheme.bodySmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: canDecrease ? () => onChanged(value - step) : null,
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),
          Text(
            '$value',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          IconButton(
            onPressed: canIncrease ? () => onChanged(value + step) : null,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Divider(
      height: 1,
      color: theme.colorScheme.outline.withValues(alpha: 0.12),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: LightColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'PRO',
        style: theme.textTheme.labelMedium?.copyWith(
          color: LightColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
