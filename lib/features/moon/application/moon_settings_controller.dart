import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/biodynamic/calendar_system.dart';
import '../../../core/local_prefs/local_prefs.dart';

part 'moon_settings_controller.g.dart';

/// Moon calendar settings (FR-19): the on/off switch and the zodiac system.
class MoonSettings {
  const MoonSettings({required this.enabled, required this.system});

  final bool enabled;
  final CalendarSystem system;
}

/// The user's moon calendar settings, persisted device-locally (never synced —
/// the calendar is global, not user data). Defaults: enabled (decision A6),
/// sidereal (matches the printed calendars the target market compares against).
/// Warmed in bootstrap before the first paint so the Home chip never flashes.
/// The single [MoonSettings.system] here drives ALL moon screens (spec §11.6).
@riverpod
class MoonSettingsController extends _$MoonSettingsController {
  @override
  Future<MoonSettings> build() async {
    final prefs = ref.watch(localPrefsProvider);
    final enabled = await prefs.moonCalendarEnabled() ?? true;
    final system = switch (await prefs.moonSystem()) {
      'tropical' => CalendarSystem.tropical,
      _ => CalendarSystem.sidereal,
    };
    return MoonSettings(enabled: enabled, system: system);
  }

  Future<void> setEnabled(bool enabled) async {
    final current = await future;
    state = AsyncData(MoonSettings(enabled: enabled, system: current.system));
    await ref.read(localPrefsProvider).setMoonCalendarEnabled(enabled);
  }

  Future<void> setSystem(CalendarSystem system) async {
    final current = await future;
    state = AsyncData(MoonSettings(enabled: current.enabled, system: system));
    await ref.read(localPrefsProvider).setMoonSystem(system.name);
  }
}
