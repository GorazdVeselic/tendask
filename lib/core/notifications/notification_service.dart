import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

part 'notification_service.g.dart';

/// Channel for deterministic, offline task reminders (tech-stack §4, layer A).
const _kReminderChannelId = 'task_reminders';
const _kReminderChannelName = 'Opomniki opravil';

const _reminderDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    _kReminderChannelId,
    _kReminderChannelName,
    importance: Importance.high,
    priority: Priority.high,
  ),
);

/// Thin wrapper around flutter_local_notifications for local task reminders.
/// [init] runs at bootstrap (timezone + plugin); the permission prompt is
/// deferred to the priming screen (21) and never fired at startup. Scheduling
/// lands in M8.2, deep-link handling in M8.3.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  /// Loads the timezone database, resolves the device's local zone, and
  /// initializes the plugin. Idempotent. Safe to fire-and-forget at bootstrap.
  Future<void> init() async {
    if (_ready) return;
    tz_data.initializeTimeZones();
    final local = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(local.identifier));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_notify'),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onTap,
    );
    _ready = true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  /// Requests POST_NOTIFICATIONS (Android 13+). Call from the priming screen
  /// (21), after explaining the value — not at startup. Returns whether granted.
  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? false;

  /// Ensures exact-alarm scheduling is allowed (Android 13+). When not granted,
  /// opens the system "Alarms & reminders" page. Reminders use exact alarms so
  /// they fire on time even in Doze. Returns whether exact alarms can be used.
  Future<bool> ensureExactAlarms() async {
    final android = _android;
    if (android == null) return false;
    if (await android.canScheduleExactNotifications() ?? false) return true;
    await android.requestExactAlarmsPermission();
    return await android.canScheduleExactNotifications() ?? false;
  }

  void _onTap(NotificationResponse response) {
    // Deep-link to the task detail (17) is wired in M8.3.
    debugPrint('notification tapped: ${response.payload}');
  }

  // ── M8.1 smoke-test helpers ────────────────────────────────────────────────
  // Temporary: drive the notification pipeline by hand from a debug button to
  // verify it works on-device (incl. Samsung Doze timing) before the real,
  // task_reminder-driven scheduling lands in M8.2. Remove with the debug button.

  Future<void> showNow({required String title, required String body}) async {
    await init();
    await _plugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: _reminderDetails,
    );
  }

  Future<void> scheduleIn(
    Duration delay, {
    required String title,
    required String body,
  }) async {
    await init();
    await _plugin.zonedSchedule(
      id: 1,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.now(tz.local).add(delay),
      notificationDetails: _reminderDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) => NotificationService();
