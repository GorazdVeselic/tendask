import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../application/profile_providers.dart';

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
        ref.read(profileRepositoryProvider).setLang(userId, loc.languageCode));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final current = LocaleSettings.currentLocale;
    // Rebuild on sign-in/out so the profile tile reflects the current account.
    ref.watch(authStateChangesProvider);
    final email = ref.read(authServiceProvider).email;

    void comingSoon() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.settings.coming_soon),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: context.pop,
        ),
        title: Text(t.settings.title),
        centerTitle: true,
      ),
      body: ListView(
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
                    leading: const CircleAvatar(child: Text('👤')),
                    title: Text(t.settings.profile_guest),
                    subtitle: Text(t.settings.sign_in_prompt),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/login'),
                  ),
          ),

          // Location (placeholder — M7)
          SectionLabel(t.settings.section_location),
          Card(
            child: ListTile(
              leading: const Text('📍', style: TextStyle(fontSize: 22)),
              title: Text(t.settings.location_placeholder),
              subtitle: Text(t.settings.coming_soon),
              onTap: comingSoon,
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
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),

          // Notifications (placeholder — M8)
          SectionLabel(t.settings.section_notifications),
          Card(
            child: ListTile(
              leading: const Text('🔔', style: TextStyle(fontSize: 22)),
              title: Text(t.settings.notifications_placeholder),
              subtitle: Text(t.settings.coming_soon),
              onTap: comingSoon,
            ),
          ),

          // Garden (ACTIVE)
          SectionLabel(t.settings.section_garden),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Text('📦', style: TextStyle(fontSize: 22)),
                  title: Text(t.settings.supplies),
                  subtitle: Text(t.settings.supplies_sub),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.pushNamed('supplies'),
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                ListTile(
                  leading: const Text('🪴', style: TextStyle(fontSize: 22)),
                  title: Text(t.settings.areas),
                  subtitle: Text(t.settings.areas_sub),
                  trailing: const Icon(Icons.chevron_right),
                  // 'areas' is a shell-branch tab → switch to it (goNamed),
                  // never pushNamed a shell route from a full-screen page.
                  onTap: () => context.goNamed('areas'),
                ),
              ],
            ),
          ),

          // Account & data (placeholder — M7 / GDPR)
          SectionLabel(t.settings.section_account),
          Card(
            child: Column(
              children: [
                _PlaceholderTile(label: t.settings.units, onTap: comingSoon),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                _PlaceholderTile(
                    label: t.settings.export_data, onTap: comingSoon),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                _PlaceholderTile(label: t.settings.logout, onTap: comingSoon),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                _PlaceholderTile(
                  label: t.settings.delete_account,
                  destructive: true,
                  onTap: comingSoon,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Center(
            child: Text(
              t.settings.version,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
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
        style: destructive
            ? TextStyle(color: theme.colorScheme.error)
            : null,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
