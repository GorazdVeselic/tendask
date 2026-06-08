import 'package:flutter/material.dart';

import '../../../core/widgets/sheet_handle.dart';
import '../../../i18n/translations.g.dart';

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
