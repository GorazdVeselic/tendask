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

/// Default reminder offsets offered in settings — a subset of the reminder
/// sheet presets so the prefilled value always matches a selectable option.
const _offsetChoices = [0, 60, kDefaultReminderOffset];

String _quietHoursRange() {
  String hh(int h) => '${h.toString().padLeft(2, '0')}:00';
  return '${hh(kQuietHoursStartHour)} – ${hh(kQuietHoursEndHour)}';
}

/// Whether the OS currently allows exact alarms — drives the permission row.
final _exactAlarmsAllowedProvider = FutureProvider.autoDispose<bool>(
    (ref) => ref.watch(notificationServiceProvider).canScheduleExactAlarms());

/// Screen 22 — notification settings. Task reminders are local and live; weather
/// and community hints are server-side (FCM, deferred), so their toggles and the
/// anti-spam controls are persisted but shown disabled / inert for now.
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: context.pop),
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
        ref.read(profileRepositoryProvider).setNotificationSettings(userId, next));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
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
                secondary: const Text('🌤️', style: TextStyle(fontSize: 22)),
                title: Text(t.notif_settings.type_weather),
                subtitle: Text(t.notif_settings.type_weather_sub),
                value: settings.weatherHintsEnabled,
                onChanged: null, // FCM deferred
              ),
              SwitchListTile(
                secondary: const Text('🌍', style: TextStyle(fontSize: 22)),
                title: Text(t.notif_settings.type_community),
                subtitle: Text(t.notif_settings.type_community_sub),
                value: settings.communityHintsEnabled,
                onChanged: null, // V2
              ),
            ],
          ),
        ),

        // Default reminder offset — prefills the reminder edit sheet.
        SectionLabel(t.notif_settings.section_default_offset),
        SegmentedButton<int>(
          segments: [
            for (final offset in _offsetChoices)
              ButtonSegment(value: offset, label: Text(_offsetLabel(offset, t))),
          ],
          selected: {settings.defaultReminderOffset},
          onSelectionChanged: (sel) =>
              _save(ref, settings.copyWith(defaultReminderOffset: sel.first)),
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
          child: Text(
            t.notif_settings.default_offset_hint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                subtitle:
                    Text(t.notif_settings.quiet_hours_sub(range: _quietHoursRange())),
                value: settings.quietHoursEnabled,
                onChanged: (v) =>
                    _save(ref, settings.copyWith(quietHoursEnabled: v)),
              ),
              SwitchListTile(
                title: Text(t.notif_settings.frequency_cap),
                subtitle: Text(t.notif_settings.frequency_cap_sub),
                value: settings.frequencyCapEnabled,
                onChanged: (v) =>
                    _save(ref, settings.copyWith(frequencyCapEnabled: v)),
              ),
            ],
          ),
        ),

        // System permission status (exact alarms — the one reminders need).
        SectionLabel(t.notif_settings.section_more),
        const Card(child: _PermissionTile()),
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
      subtitle: Text(allowed == false
          ? t.notif_settings.system_permission_off
          : t.notif_settings.system_permission_on),
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
