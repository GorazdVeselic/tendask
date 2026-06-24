import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/notifications/reminder_audio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  group('reminderAudioFromReason', () {
    test('maps known reasons', () {
      expect(reminderAudioFromReason('volumeZero'), ReminderAudio.volumeZero);
      expect(reminderAudioFromReason('silentMode'), ReminderAudio.silentMode);
      expect(reminderAudioFromReason('audible'), ReminderAudio.audible);
    });

    test('unknown / null fall back to audible', () {
      expect(reminderAudioFromReason('something-new'), ReminderAudio.audible);
      expect(reminderAudioFromReason(null), ReminderAudio.audible);
    });
  });

  group('watch', () {
    const channel = EventChannel('app.tendask/reminder_audio_events');
    final service = ReminderAudioService(events: channel);

    tearDown(() => messenger.setMockStreamHandler(channel, null));

    test('maps platform events to a live stream', () {
      messenger.setMockStreamHandler(
        channel,
        MockStreamHandler.inline(
          onListen: (args, sink) {
            sink.success('volumeZero');
            sink.success('audible');
          },
        ),
      );

      expect(
        service.watch(),
        emitsInOrder([ReminderAudio.volumeZero, ReminderAudio.audible]),
      );
    });

    test('a stream error is swallowed so no banner shows', () {
      messenger.setMockStreamHandler(
        channel,
        MockStreamHandler.inline(
          onListen: (args, sink) {
            sink.error(code: 'unavailable', message: 'no', details: null);
            sink.endOfStream();
          },
        ),
      );

      expect(service.watch(), emitsDone);
    });
  });

  group('showVolumeUi', () {
    const channel = MethodChannel('app.tendask/reminder_audio');
    final service = ReminderAudioService(methods: channel);

    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test('invokes the platform method', () async {
      final calls = <String>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        return null;
      });

      await service.showVolumeUi();
      expect(calls, ['showNotificationVolumeUi']);
    });

    test('swallows a platform failure', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'denied');
      });

      await expectLater(service.showVolumeUi(), completes);
    });
  });
}
