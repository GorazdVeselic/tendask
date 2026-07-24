import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/notifications/reminder_audio.dart';
import 'package:tendask/features/notifications/presentation/widgets/reminder_sound_banner.dart';
import 'package:tendask/i18n/translations.g.dart';

class _RecordingAudioService extends ReminderAudioService {
  int showCalls = 0;

  @override
  Future<void> showVolumeUi() async => showCalls++;
}

Future<void> _pump(
  WidgetTester tester, {
  required ReminderAudio audio,
  ReminderAudioService? service,
}) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          reminderAudioProvider.overrideWith((ref) => Stream.value(audio)),
          if (service != null)
            reminderAudioServiceProvider.overrideWithValue(service),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ReminderSoundBanner()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  testWidgets('renders nothing when reminders are audible', (tester) async {
    await _pump(tester, audio: ReminderAudio.audible);

    expect(find.byType(TextButton), findsNothing);
    expect(find.text(t.reminder_sound.enable), findsNothing);
  });

  testWidgets('shows the volume hint + action when volume is 0', (tester) async {
    await _pump(tester, audio: ReminderAudio.volumeZero);

    expect(find.text(t.reminder_sound.silent_volume), findsOneWidget);
    expect(find.text(t.reminder_sound.enable), findsOneWidget);
  });

  testWidgets('shows the silent-mode hint when phone is silent', (tester) async {
    await _pump(tester, audio: ReminderAudio.silentMode);

    expect(find.text(t.reminder_sound.silent_mode), findsOneWidget);
  });

  testWidgets('tapping "turn on sound" calls showVolumeUi', (tester) async {
    final service = _RecordingAudioService();
    await _pump(tester, audio: ReminderAudio.volumeZero, service: service);

    await tester.tap(find.text(t.reminder_sound.enable));
    await tester.pumpAndSettle();

    expect(service.showCalls, 1);
  });
}
