import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_service.dart';

/// Whether the OS currently allows exact alarms — drives the permission row on
/// screen 22, and is re-read after the user returns from system settings.
final exactAlarmsAllowedProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(notificationServiceProvider).canScheduleExactAlarms(),
);
