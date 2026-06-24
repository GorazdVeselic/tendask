import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reminder_audio.g.dart';

/// Whether task reminders will make a sound, or — if not — why. Vibration and
/// the heads-up are independent of this; only the audible signal is covered.
enum ReminderAudio { audible, volumeZero, silentMode }

/// Maps the platform reason to [ReminderAudio]; unknown / null → audible, so a
/// missing or future reason never nags the user with a false banner.
ReminderAudio reminderAudioFromReason(Object? reason) => switch (reason) {
  'volumeZero' => ReminderAudio.volumeZero,
  'silentMode' => ReminderAudio.silentMode,
  _ => ReminderAudio.audible,
};

/// Reads the device's notification-audio state and opens the system volume
/// slider. Android-only: on other platforms or if the channel is absent the
/// stream yields nothing (banner stays hidden) and the action no-ops.
class ReminderAudioService {
  ReminderAudioService({MethodChannel? methods, EventChannel? events})
    : _methods = methods ?? const MethodChannel('app.tendask/reminder_audio'),
      _events =
          events ?? const EventChannel('app.tendask/reminder_audio_events');

  final MethodChannel _methods;
  final EventChannel _events;

  /// Live audio state: the current value, then a fresh one whenever the device
  /// volume or ringer mode changes — so the banner hides the instant the user
  /// fixes it on the system slider. An absent channel errors the broadcast
  /// stream, which we swallow to "no events" (banner hidden).
  Stream<ReminderAudio> watch() => _events
      .receiveBroadcastStream()
      .map(reminderAudioFromReason)
      .handleError((Object _) {});

  /// Raises the notification volume one step and shows the system slider. The
  /// one-step bump is the consented effect of the user's "turn on sound" tap;
  /// the live [watch] stream then hides the banner on its own.
  Future<void> showVolumeUi() async {
    try {
      await _methods.invokeMethod<void>('showNotificationVolumeUi');
    } on PlatformException {
      // Best-effort; nothing to do if the platform refuses the adjustment.
    } on MissingPluginException {
      // Non-Android or channel absent — silently no-op.
    }
  }
}

@Riverpod(keepAlive: true)
ReminderAudioService reminderAudioService(Ref ref) => ReminderAudioService();

/// Reactive notification-audio state for the reminder-sound banner; updates live
/// as the user changes the volume, so the banner disappears the moment it's set.
final reminderAudioProvider = StreamProvider.autoDispose<ReminderAudio>(
  (ref) => ref.watch(reminderAudioServiceProvider).watch(),
);
