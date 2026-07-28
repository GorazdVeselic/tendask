// Seams are named for a clear public contract, so they are assigned in the
// initializer list rather than as initializing formals (which would force the
// private `_name:` at call sites). Same pattern as SyncService.
// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../sync/sync_service.dart';
import 'notification_service.dart';

part 'fcm_handler.g.dart';

/// Wires the FCM message paths (docs/m11/06-fcm.md §6.3): a foreground push
/// triggers a sync pull and a local notification (the OS renders nothing while
/// the app is in foreground); background/terminated taps deep-link to Home.
/// No onBackgroundMessage handler — the engine sends notification messages the
/// OS displays on its own.
class FcmHandler {
  FcmHandler({
    required Future<void> Function() pull,
    required NotificationService notifications,
    Stream<RemoteMessage>? onMessage,
    Stream<RemoteMessage>? onMessageOpenedApp,
  }) : _pull = pull,
       _notifications = notifications,
       _onMessage = onMessage,
       _onMessageOpenedApp = onMessageOpenedApp;

  final Future<void> Function() _pull;
  final NotificationService _notifications;
  // Test seams; null = the real plugin streams, resolved lazily in start().
  final Stream<RemoteMessage>? _onMessage;
  final Stream<RemoteMessage>? _onMessageOpenedApp;
  StreamSubscription<RemoteMessage>? _messageSub;
  StreamSubscription<RemoteMessage>? _openedSub;

  // Suggestion ids of tapped pushes, consumed by the app layer to navigate.
  // The handler stays decoupled from the router (core/ must not call features/).
  final _taps = StreamController<String>.broadcast();

  /// Suggestion ids from pushes tapped while the app is alive (background).
  /// Cold-start taps are resolved via [initialSuggestionId] instead.
  Stream<String> get suggestionTaps => _taps.stream;

  /// Subscribes to the FCM streams. Call once at bootstrap, after a successful
  /// Firebase.initializeApp. Idempotent.
  void start() {
    // The plugin streams are read here, not in the constructor: the provider is
    // built before Firebase.initializeApp on some paths.
    _messageSub ??= (_onMessage ?? FirebaseMessaging.onMessage).listen(
      _onForeground,
    );
    _openedSub ??=
        (_onMessageOpenedApp ?? FirebaseMessaging.onMessageOpenedApp).listen(
          _onOpened,
        );
  }

  /// Suggestion id of the push that cold-started the app, or null when the app
  /// was launched normally.
  Future<String?> initialSuggestionId() async =>
      suggestionIdOf(await FirebaseMessaging.instance.getInitialMessage());

  void _onForeground(RemoteMessage msg) {
    final id = suggestionIdOf(msg);
    if (id == null) return;
    // The band (M11.13) refreshes from the drift stream once the pull lands;
    // sync() never throws (phases are isolated), so no error path here.
    unawaited(_pull());
    final content = msg.notification;
    if (content == null) return;
    unawaited(
      _notifications.showForegroundSuggestion(
        suggestionId: id,
        title: content.title,
        body: content.body,
      ),
    );
  }

  void _onOpened(RemoteMessage msg) {
    final id = suggestionIdOf(msg);
    if (id != null) _taps.add(id);
  }

  /// Drops the FCM subscriptions and closes the tap stream. The provider is
  /// keepAlive, so in the app this only runs when the container itself goes —
  /// but a test that builds a handler per case would otherwise leave both
  /// subscriptions live on a shared stream.
  Future<void> dispose() async {
    await _messageSub?.cancel();
    await _openedSub?.cancel();
    _messageSub = null;
    _openedSub = null;
    await _taps.close();
  }
}

/// The suggestion id of a smart-engine push, or null for any other message.
String? suggestionIdOf(RemoteMessage? msg) {
  if (msg == null || msg.data['type'] != 'suggestion') return null;
  final id = msg.data['suggestion_id'];
  return (id is String && id.isNotEmpty) ? id : null;
}

@Riverpod(keepAlive: true)
FcmHandler fcmHandler(Ref ref) {
  final sync = ref.watch(syncServiceProvider);
  final handler = FcmHandler(
    // Reuses the serialized sync cycle (08 §8.5) — pull brings the suggestion
    // row; the extra push of pending rows is harmless.
    pull: sync.sync,
    notifications: ref.watch(notificationServiceProvider),
  );
  ref.onDispose(() => unawaited(handler.dispose()));
  return handler;
}
