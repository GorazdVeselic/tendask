import 'package:flutter/material.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/sheet_handle.dart';
import '../../../i18n/translations.g.dart';
import 'widgets/reminder_sound_banner.dart';

/// Pre-permission priming sheet (wireframe 21). Shown the first time the user
/// adds a reminder, before the OS permission dialog — explains why and lets them
/// opt out gracefully. Returns true when the user chose to enable notifications
/// (the caller then fires the system request), false/null on "maybe later".
Future<bool?> showNotificationPriming(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _NotificationPrimingSheet(),
  );
}

/// Outcome of the reminder permission flow ([requestReminderPermissions]).
enum ReminderPermission { granted, primingDeclined, notifDenied, exactAlarmMissing }

/// Full permission flow for a reminder that must fire on time: priming (21) +
/// notifications (Android 13+) + the exact-alarm gate (Android 14+). Returns
/// [ReminderPermission.granted] only when both permissions are in place; the
/// other cases tell the caller why not. On [exactAlarmMissing] it has already
/// shown the explainer and (if confirmed) opened system settings — exact alarms
/// are grantable only there, so the caller stops and the user re-tries after.
///
/// Shared by the manual "add reminder" flow and the save-time check for an
/// auto-seeded reminder (T7), so both ask for the same permissions.
Future<ReminderPermission> requestReminderPermissions(
  BuildContext context,
  NotificationService notif,
) async {
  if (!await notif.areNotificationsEnabled()) {
    if (!context.mounted) return ReminderPermission.primingDeclined;
    if (await showNotificationPriming(context) != true) {
      return ReminderPermission.primingDeclined;
    }
    if (!await notif.requestPermission()) return ReminderPermission.notifDenied;
  }
  if (!await notif.canScheduleExactAlarms()) {
    if (!context.mounted) return ReminderPermission.exactAlarmMissing;
    final t = context.t;
    final open = await showConfirmDialog(
      context,
      title: t.entry.rem_exact_title,
      body: t.entry.rem_exact_body,
      confirmLabel: t.entry.rem_exact_open,
      cancelLabel: t.tasks_list.delete_cancel,
      destructive: false,
    );
    if (open) await notif.openExactAlarmSettings();
    return ReminderPermission.exactAlarmMissing;
  }
  return ReminderPermission.granted;
}

class _NotificationPrimingSheet extends StatelessWidget {
  const _NotificationPrimingSheet();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final p = t.notif_priming;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            const SizedBox(height: 8),
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Center(
                child: Text('🔔', style: TextStyle(fontSize: 42)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              p.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              p.why,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _Benefit(icon: '⏰', text: p.benefit_reminders),
            _Benefit(icon: '🌤️', text: p.benefit_weather),
            _Benefit(icon: '🌍', text: p.benefit_nearby),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🔒'),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      p.privacy,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Shown only when reminders would be silent (volume 0 / silent mode).
            const ReminderSoundBanner(),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(p.enable),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(p.later),
            ),
          ],
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 11),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
