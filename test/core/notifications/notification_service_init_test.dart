import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/notifications/notification_service.dart';

/// The plugin validates the status-bar icon against the app package, so an
/// install with an incomplete resource table (Play pre-launch emulators, which
/// skip config splits) makes `initialize` throw `invalid_icon`. That used to
/// escape `init()` and take down every caller — scheduling a reminder, reading
/// the launch payload, the journal nudge coordinator. Reminders are genuinely
/// unavailable on such an install, but the app must keep working.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const notifications = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );
  const timezone = MethodChannel('flutter_timezone');

  // Counted on the timezone channel, which `init` touches first: it is the only
  // step observable from a host test, since the notification plugin fails
  // earlier still (no platform implementation is registered off-device).
  var setupAttempts = 0;

  setUp(() {
    setupAttempts = 0;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    messenger.setMockMethodCallHandler(timezone, (call) async {
      setupAttempts++;
      return 'Europe/Ljubljana';
    });
    messenger.setMockMethodCallHandler(notifications, (call) async {
      if (call.method != 'initialize') return null;
      throw PlatformException(
        code: 'invalid_icon',
        message: 'The resource ic_stat_notify could not be found.',
      );
    });
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(timezone, null);
    messenger.setMockMethodCallHandler(notifications, null);
  });

  test('init swallows a setup failure and reports not ready', () async {
    final service = NotificationService();

    await expectLater(service.init(), completes);
    expect(service.isReady, isFalse);
  });

  test('init does not retry a deterministic failure', () async {
    final service = NotificationService();

    await service.init();
    await service.init();
    await service.init();

    expect(setupAttempts, 1);
  });

  test('initialPayload returns null instead of throwing when init failed', () {
    final service = NotificationService();

    expect(service.initialPayload(), completion(isNull));
  });
}
