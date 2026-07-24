import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/config.dart';
import '../../../core/notifications/notification_settings.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../../settings/application/profile_providers.dart';
import '../application/fcm_token_service.dart';
import 'notification_priming_sheet.dart';
import 'widgets/reminder_sound_banner.dart';

/// Default reminder offsets offered in settings — a subset of the reminder
/// sheet presets so the prefilled value always matches a selectable option.
const _offsetChoices = [0, 60, kMinutesPerDay];

String _quietHoursRange() {
  String hh(int h) => '${h.toString().padLeft(2, '0')}:00';
  return '${hh(kQuietHoursStartHour)} – ${hh(kQuietHoursEndHour)}';
}

/// Whether the OS currently allows exact alarms — drives the permission row.
final _exactAlarmsAllowedProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(notificationServiceProvider).canScheduleExactAlarms(),
);

/// Screen 22 — notification settings. Task reminders are local; weather and
/// community hints are server-side pushes (M11) — their opt-ins are stored in
/// the profile and the engine enforces them (the client only records intent).
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: context.pop,
        ),
        title: Text(t.notif_settings.title),
        centerTitle: true,
      ),
      body: settingsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (_, _) => Center(child: Text(t.notif_settings.load_error)),
        data: (s) => _Body(settings: s),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.settings});

  final NotificationSettings settings;

  void _save(WidgetRef ref, NotificationSettings next) {
    final userId = ref.read(authServiceProvider).userId;
    unawaited(
      ref.read(profileRepositoryProvider).setNotificationSettings(userId, next),
    );
  }

  /// Enabling a hint type needs POST_NOTIFICATIONS: run the M8 priming +
  /// permission flow first, then save and (re)kick the FCM token sync.
  /// Disabling goes straight through [_save] — no permission involved.
  Future<void> _enableHints(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings next,
  ) async {
    final t = context.t;
    final notif = ref.read(notificationServiceProvider);
    final messenger = ScaffoldMessenger.of(context);

    if (!await notif.areNotificationsEnabled()) {
      if (!context.mounted) return;
      if (await showNotificationPriming(context) != true) return;
    }
    if (!await notif.requestPermission()) {
      messenger.showSnackBar(
        SnackBar(content: Text(t.notif_settings.hints_perm_denied)),
      );
      return;
    }
    // The permission dialog is async — bail if the screen was popped meanwhile,
    // so we never touch a defunct WidgetRef.
    if (!context.mounted) return;
    _save(ref, next);
    // The permission may have just been granted — re-run the token flow now
    // instead of waiting for the next auth change.
    ref.invalidate(fcmTokenServiceProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        // Shown only when reminders would be silent (volume 0 / silent mode).
        const ReminderSoundBanner(),

        // Types — only task reminders are live; the rest await FCM.
        SectionLabel(t.notif_settings.section_types),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Text('⏰', style: TextStyle(fontSize: 22)),
                title: Text(t.notif_settings.type_reminders),
                subtitle: Text(t.notif_settings.type_reminders_sub),
                value: settings.taskRemindersEnabled,
                onChanged: (v) =>
                    _save(ref, settings.copyWith(taskRemindersEnabled: v)),
              ),
              SwitchListTile(
                secondary: const Text('🌱', style: TextStyle(fontSize: 22)),
                title: Text(t.notif_settings.type_journal_nudge),
                subtitle: Text(t.notif_settings.type_journal_nudge_sub),
                value: settings.journalNudgeEnabled,
                onChanged: (v) =>
                    _save(ref, settings.copyWith(journalNudgeEnabled: v)),
              ),
              SwitchListTile(
                secondary: const Text('🌤️', style: TextStyle(fontSize: 22)),
                title: Text(t.notif_settings.type_weather),
                subtitle: Text(t.notif_settings.type_weather_sub),
                value: settings.weatherHintsEnabled,
                // Dark until launch (kSuggestionsEnabled): the hint pushes are
                // server-side (FCM/engine), so keep the toggle inert — enabling
                // it would only request permission + a pointless token.
                onChanged: kSuggestionsEnabled
                    ? (v) => v
                          ? unawaited(
                              _enableHints(
                                context,
                                ref,
                                settings.copyWith(weatherHintsEnabled: true),
                              ),
                            )
                          : _save(
                              ref,
                              settings.copyWith(weatherHintsEnabled: false),
                            )
                    : null,
              ),
              SwitchListTile(
                secondary: const Text('🌍', style: TextStyle(fontSize: 22)),
                title: Text(t.notif_settings.type_community),
                subtitle: Text(t.notif_settings.type_community_sub),
                value: settings.communityHintsEnabled,
                // Dark until launch (kSuggestionsEnabled) — see weather toggle.
                onChanged: kSuggestionsEnabled
                    ? (v) => v
                          ? unawaited(
                              _enableHints(
                                context,
                                ref,
                                settings.copyWith(communityHintsEnabled: true),
                              ),
                            )
                          : _save(
                              ref,
                              settings.copyWith(communityHintsEnabled: false),
                            )
                    : null,
              ),
            ],
          ),
        ),

        // Default reminder offset — prefills the reminder edit sheet.
        SectionLabel(t.notif_settings.section_default_offset),
        SegmentedButton<int>(
          segments: [
            for (final offset in _offsetChoices)
              ButtonSegment(
                value: offset,
                label: Text(_offsetLabel(offset, t)),
              ),
          ],
          selected: {settings.defaultReminderOffset},
          showSelectedIcon: false,
          onSelectionChanged: (sel) =>
              _save(ref, settings.copyWith(defaultReminderOffset: sel.first)),
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
          child: Text(
            t.notif_settings.default_offset_hint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        // Anti-spam — applies to the future weather/community hints, not the
        // explicit task reminders (koncept §"Vodenje proti motečnosti").
        SectionLabel(t.notif_settings.section_quiet),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: Text(t.notif_settings.quiet_hours),
                subtitle: Text(
                  t.notif_settings.quiet_hours_sub(range: _quietHoursRange()),
                ),
                value: settings.quietHoursEnabled,
                onChanged: (v) =>
                    _save(ref, settings.copyWith(quietHoursEnabled: v)),
              ),
              // The frequency-cap toggle is hidden in MVP: the engine always
              // caps at 1 hint/day (06 §6.5); the switch returns with digests.
            ],
          ),
        ),

        // Preview + system permission status (exact alarms — reminders need it).
        SectionLabel(t.notif_settings.section_more),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Text('👁', style: TextStyle(fontSize: 20)),
                title: Text(t.notif_settings.preview),
                subtitle: Text(t.notif_settings.preview_sub),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed('notification-preview'),
              ),
              const _PermissionTile(),
            ],
          ),
        ),
      ],
    );
  }

  String _offsetLabel(int offset, Translations t) => switch (offset) {
    0 => t.entry.rem_event,
    60 => t.entry.rem_1hour,
    _ => t.entry.rem_1day,
  };
}

class _PermissionTile extends ConsumerWidget {
  const _PermissionTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final allowed = ref.watch(_exactAlarmsAllowedProvider).asData?.value;

    return ListTile(
      title: Text(t.notif_settings.system_permission),
      subtitle: Text(
        allowed == false
            ? t.notif_settings.system_permission_off
            : t.notif_settings.system_permission_on,
      ),
      trailing: allowed == false
          ? Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error)
          : Icon(Icons.check, color: theme.colorScheme.primary),
      // Grant happens out-of-app; re-check when the user returns.
      onTap: allowed == false
          ? () async {
              await ref
                  .read(notificationServiceProvider)
                  .openExactAlarmSettings();
              ref.invalidate(_exactAlarmsAllowedProvider);
            }
          : null,
    );
  }
}
