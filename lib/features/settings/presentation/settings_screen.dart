import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/app_info.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/config.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/legal.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../application/profile_providers.dart';
import '../application/account_providers.dart';

/// Native language names (endonyms) — not translated; shown the same in every locale.
String _langLabel(AppLocale loc) => switch (loc) {
  AppLocale.sl => 'Slovenščina',
  AppLocale.en => 'English',
  AppLocale.de => 'Deutsch',
};

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _setLang(WidgetRef ref, AppLocale loc) {
    final userId = ref.read(authServiceProvider).userId;
    unawaited(LocaleSettings.setLocale(loc));
    unawaited(
      ref.read(profileRepositoryProvider).setLang(userId, loc.languageCode),
    );
  }

  /// Sign out + wipe local data, then return to onboarding — back to a clean
  /// local guest state (M7.5b). Cloud data stays and returns on re-sign-in.
  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final t = context.t;
    final confirmed = await showConfirmDialog(
      context,
      title: t.settings.logout_confirm_title,
      body: t.settings.logout_confirm_body,
      confirmLabel: t.settings.logout,
      cancelLabel: t.settings.logout_cancel,
    );
    if (!confirmed || !context.mounted) return;
    final auth = ref.read(authServiceProvider);
    // Signed in: flush pending to the cloud first so a re-login restores it;
    // clearUserData is irreversible, so abort if the cloud is unreachable. A
    // guest has no cloud account — nothing to flush, just reset to clean state.
    if (auth.hasSession) {
      final flushed = await ref.read(syncServiceProvider).flushPush();
      if (!context.mounted) return;
      if (!flushed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.settings.logout_offline),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }
    await auth.signOut();
    await ref.read(databaseProvider).clearUserData();
    if (!context.mounted) return;
    context.go('/onboarding');
  }

  /// GDPR export — writes all user data to a JSON file and opens the share sheet
  /// (save to Files/Drive, send, …). Works the same for guest and signed-in.
  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final t = context.t;
    try {
      final path = await ref.read(accountRepositoryProvider).writeExportFile();
      await SharePlus.instance.share(
        ShareParams(files: [XFile(path)], text: t.settings.export_share_text),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.settings.export_error),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// GDPR account deletion — confirm, then delete the cloud account (cascades)
  /// and wipe local data, returning to onboarding. A guest only wipes locally,
  /// so it shows "delete all data" wording (no cloud account to delete).
  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final t = context.t;
    final isGuest = ref.read(authServiceProvider).email == null;
    final confirmed = await showConfirmDialog(
      context,
      title: isGuest
          ? t.settings.delete_data_confirm_title
          : t.settings.delete_account_confirm_title,
      body: isGuest
          ? t.settings.delete_data_confirm_body
          : t.settings.delete_account_confirm_body,
      confirmLabel: isGuest
          ? t.settings.delete_data_confirm
          : t.settings.delete_account_confirm,
      cancelLabel: t.settings.logout_cancel,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(accountRepositoryProvider).deleteAccount();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.settings.delete_account_error),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!context.mounted) return;
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final current = LocaleSettings.currentLocale;
    // Rebuild on sign-in/out so the profile tile reflects the current account.
    ref.watch(authStateChangesProvider);
    final email = ref.read(authServiceProvider).email;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: context.pop,
        ),
        title: Text(t.settings.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            // Profile. Signed in → show the email; guest → entry point to sign in
            // (link account, keeps data). Sign-out is wired in M7.5.
            Card(
              child: email != null
                  ? ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(email),
                      subtitle: Text(t.settings.signed_in),
                    )
                  : ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(t.settings.profile_guest),
                      subtitle: Text(t.settings.sign_in_prompt),
                      trailing: const Icon(Icons.chevron_right),
                      // Signing in keeps the guest's local data (claimed on sign-in).
                      onTap: () => context.push('/login'),
                    ),
            ),

            // Location — opens the location screen (set/update garden location).
            SectionLabel(t.settings.section_location),
            Card(
              child: ListTile(
                leading: const Text('📍', style: TextStyle(fontSize: 22)),
                title: Text(t.settings.location_placeholder),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/location'),
              ),
            ),

            // Language (ACTIVE)
            SectionLabel(t.settings.section_language),
            SegmentedButton<AppLocale>(
              segments: [
                for (final loc in AppLocale.values)
                  ButtonSegment(value: loc, label: Text(_langLabel(loc))),
              ],
              selected: {current},
              onSelectionChanged: (s) => _setLang(ref, s.first),
              // Endonyms ("Slovenščina") are long; the selected-check would push
              // the row past the screen width, so drop it.
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),

            // Appearance — theme mode + colour palette (screen 12b), device-local.
            SectionLabel(t.settings.section_appearance),
            Card(
              child: ListTile(
                leading: const Text('🎨', style: TextStyle(fontSize: 22)),
                title: Text(t.settings.appearance_placeholder),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed('appearance'),
              ),
            ),

            // Notifications — screen 22 (M8.4)
            SectionLabel(t.settings.section_notifications),
            Card(
              child: ListTile(
                leading: const Text('🔔', style: TextStyle(fontSize: 22)),
                title: Text(t.settings.notifications_placeholder),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed('notification-settings'),
              ),
            ),

            // Account & data (placeholder — M7 / GDPR)
            SectionLabel(t.settings.section_account),
            Card(
              child: Column(
                children: [
                  _PlaceholderTile(
                    label: t.settings.export_data,
                    onTap: () => unawaited(_export(context, ref)),
                  ),
                  // Sign-out only for a signed-in account: a guest has no session
                  // to end, and logging out wipes local data the guest can never
                  // recover (it never reached the cloud) — see BUG-003.
                  if (email != null) ...[
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                    _PlaceholderTile(
                      label: t.settings.logout,
                      onTap: () => unawaited(_logout(context, ref)),
                    ),
                  ],
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  _PlaceholderTile(
                    label: email != null
                        ? t.settings.delete_account
                        : t.settings.delete_data,
                    destructive: true,
                    onTap: () => unawaited(_deleteAccount(context, ref)),
                  ),
                ],
              ),
            ),

            // About — public privacy policy (also the URL given to Play).
            SectionLabel(t.settings.section_about),
            Card(
              child: ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(t.settings.privacy_policy),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => unawaited(openPrivacyPolicy()),
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: Text(
                switch (ref.watch(packageInfoProvider).asData?.value) {
                  final info? =>
                    'Tendask · ${info.version}+${info.buildNumber}$kVersionChannel',
                  null => '',
                },
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTile extends StatelessWidget {
  const _PlaceholderTile({
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        label,
        style: destructive ? TextStyle(color: theme.colorScheme.error) : null,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
