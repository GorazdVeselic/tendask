import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/notifications/fcm_handler.dart';
import 'package:tendask/core/notifications/notification_service.dart';

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
}
