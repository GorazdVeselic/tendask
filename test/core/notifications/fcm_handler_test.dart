import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/notifications/fcm_handler.dart';
import 'package:tendask/core/notifications/notification_service.dart';

typedef _Shown = ({String id, String? title, String? body});

class _FakeNotifications implements NotificationService {
  final shown = <_Shown>[];

  @override
  Future<void> showForegroundSuggestion({
    required String suggestionId,
    String? title,
    String? body,
  }) async => shown.add((id: suggestionId, title: title, body: body));

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  group('suggestionIdOf', () {
    test('returns the id for an engine suggestion message', () {
      const msg = RemoteMessage(
        data: {'type': 'suggestion', 'suggestion_id': 'abc-123'},
      );
      expect(suggestionIdOf(msg), 'abc-123');
    });

    test('ignores messages of another type', () {
      const msg = RemoteMessage(
        data: {'type': 'other', 'suggestion_id': 'abc-123'},
      );
      expect(suggestionIdOf(msg), isNull);
    });

    test('ignores a suggestion message without an id', () {
      const withEmpty = RemoteMessage(
        data: {'type': 'suggestion', 'suggestion_id': ''},
      );
      const withMissing = RemoteMessage(data: {'type': 'suggestion'});
      expect(suggestionIdOf(withEmpty), isNull);
      expect(suggestionIdOf(withMissing), isNull);
      expect(suggestionIdOf(null), isNull);
    });
  });

  group('suggestion payload', () {
    test('round-trips through the tap payload', () {
      final payload = NotificationService.suggestionPayload('abc-123');
      expect(NotificationService.suggestionIdFromPayload(payload), 'abc-123');
    });

    test('a bare reminder payload (task id) is not a suggestion', () {
      expect(
        NotificationService.suggestionIdFromPayload('5f0c2a1e-task-id'),
        isNull,
      );
    });
  });

  group('FcmHandler', () {
    late StreamController<RemoteMessage> onMessage;
    late StreamController<RemoteMessage> onOpened;
    late _FakeNotifications notifications;
    late int pulls;
    late FcmHandler handler;

    setUp(() {
      onMessage = StreamController<RemoteMessage>.broadcast();
      onOpened = StreamController<RemoteMessage>.broadcast();
      notifications = _FakeNotifications();
      pulls = 0;
      handler = FcmHandler(
        pull: () async => pulls++,
        notifications: notifications,
        onMessage: onMessage.stream,
        onMessageOpenedApp: onOpened.stream,
      );
    });

    tearDown(() async {
      await onMessage.close();
      await onOpened.close();
    });

    // The streams are broadcast + async, so a delivered event needs a turn of
    // the event loop before the assertion.
    Future<void> deliver(
      StreamController<RemoteMessage> to,
      RemoteMessage msg,
    ) async {
      to.add(msg);
      await Future<void>.delayed(Duration.zero);
    }

    test('a foreground suggestion pulls and shows a local notification', () async {
      handler.start();
      await deliver(
        onMessage,
        const RemoteMessage(
          data: {'type': 'suggestion', 'suggestion_id': 'abc-123'},
          notification: RemoteNotification(title: 'Suho okno', body: 'Jutri'),
        ),
      );

      expect(pulls, 1);
      expect(notifications.shown, [
        (id: 'abc-123', title: 'Suho okno', body: 'Jutri'),
      ]);
    });

    test('a foreign foreground message pulls nothing', () async {
      handler.start();
      await deliver(onMessage, const RemoteMessage(data: {'type': 'other'}));

      expect(pulls, 0);
      expect(notifications.shown, isEmpty);
    });

    test('a data-only suggestion pulls but shows nothing', () async {
      handler.start();
      await deliver(
        onMessage,
        const RemoteMessage(
          data: {'type': 'suggestion', 'suggestion_id': 'abc-123'},
        ),
      );

      expect(pulls, 1);
      expect(notifications.shown, isEmpty);
    });

    test('a tapped push emits its suggestion id', () async {
      handler.start();
      final taps = <String>[];
      final sub = handler.suggestionTaps.listen(taps.add);
      addTearDown(sub.cancel);

      await deliver(
        onOpened,
        const RemoteMessage(
          data: {'type': 'suggestion', 'suggestion_id': 'abc-123'},
        ),
      );
      await deliver(onOpened, const RemoteMessage(data: {'type': 'other'}));

      expect(taps, ['abc-123']);
    });

    test('start() twice keeps a single subscription', () async {
      handler.start();
      handler.start();
      await deliver(
        onMessage,
        const RemoteMessage(
          data: {'type': 'suggestion', 'suggestion_id': 'abc-123'},
          notification: RemoteNotification(title: 't', body: 'b'),
        ),
      );

      expect(pulls, 1);
      expect(notifications.shown.length, 1);
    });

    test('nothing arrives before start()', () async {
      await deliver(
        onMessage,
        const RemoteMessage(
          data: {'type': 'suggestion', 'suggestion_id': 'abc-123'},
        ),
      );

      expect(pulls, 0);
    });
  });
}
