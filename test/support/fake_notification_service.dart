import 'package:tendask/core/notifications/notification_service.dart';

/// Records the OS-notification calls so a test can assert what a coordinator
/// scheduled/cancelled. Overrides every method that would touch the real
/// plugin, so the inherited FlutterLocalNotificationsPlugin is never used.
class FakeNotificationService extends NotificationService {
  FakeNotificationService([Iterable<int> seed = const []]) : pending = {...seed};

  final Set<int> pending;
  final scheduledReminders = <int>[];
  final scheduledNudges = <int>[];
  final nudgeTitles = <String>[];
  final nudgeBodies = <String>[];
  final nudgeTimes = <DateTime>[];
  final cancelled = <int>[];

  /// What the OS reports about the POST_NOTIFICATIONS grant. Granted by
  /// default, which is what lets an opt-in tap skip the priming sheet.
  bool notificationsEnabled = true;

  @override
  Future<bool> areNotificationsEnabled() async => notificationsEnabled;

  @override
  Future<bool> requestPermission() async => notificationsEnabled;

  @override
  Future<void> scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    String? payload,
  }) async {
    pending.add(id);
    scheduledReminders.add(id);
  }

  @override
  Future<void> scheduleNudge({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    pending.add(id);
    scheduledNudges.add(id);
    nudgeTitles.add(title);
    nudgeBodies.add(body);
    nudgeTimes.add(when);
  }

  @override
  Future<void> cancel(int id) async {
    pending.remove(id);
    cancelled.add(id);
  }

  @override
  Future<Set<int>> pendingIds() async => {...pending};
}
