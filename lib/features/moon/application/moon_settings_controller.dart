import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/biodynamic/calendar_system.dart';
import '../../../core/local_prefs/local_prefs.dart';

part 'moon_settings_controller.g.dart';

/// Moon calendar settings (FR-19): the on/off switch and the zodiac system.
class MoonSettings {
  const MoonSettings({required this.enabled, required this.system});

  final bool enabled;
  final CalendarSystem system;

  @override
  bool operator ==(Object other) =>
      other is MoonSettings &&
      other.enabled == enabled &&
      other.system == system;

  @override
  int get hashCode => Object.hash(enabled, system);

  @override
  String toString() =>
      'MoonSettings(enabled: $enabled, system: ${system.name})';
}

/// Defaults when nothing is stored yet or the load failed: enabled (decision
/// A6), sidereal (matches the printed calendars the target market uses).
const _defaults = MoonSettings(
  enabled: true,
  system: CalendarSystem.sidereal,
);

/// The user's moon calendar settings, persisted device-locally (never synced —
/// the calendar is global, not user data). Warmed in bootstrap before the
/// first paint so the Home chip never flashes; kept alive because nothing
/// listens until the first moon UI subscribes (autoDispose would drop the
/// warmed value right after bootstrap). The single [MoonSettings.system] here
/// drives ALL moon screens (spec §11.6).
@Riverpod(keepAlive: true)
class MoonSettingsController extends _$MoonSettingsController {
  @override
  Future<MoonSettings> build() async {
    final prefs = ref.watch(localPrefsProvider);
    final enabled = await prefs.moonCalendarEnabled() ?? _defaults.enabled;
    final system = switch (await prefs.moonSystem()) {
      'tropical' => CalendarSystem.tropical,
      _ => _defaults.system,
    };
    return MoonSettings(enabled: enabled, system: system);
  }

  Future<void> setEnabled(bool enabled) async {
    final current = await _current();
    state = AsyncData(MoonSettings(enabled: enabled, system: current.system));
    await ref.read(localPrefsProvider).setMoonCalendarEnabled(enabled);
  }

  Future<void> setSystem(CalendarSystem system) async {
    final current = await _current();
    state = AsyncData(MoonSettings(enabled: current.enabled, system: system));
    await ref.read(localPrefsProvider).setMoonSystem(system.name);
  }

  /// Current settings, falling back to [_defaults] when the initial load
  /// failed — a toggle tap must still work (and repair state) in that case.
  Future<MoonSettings> _current() async {
    try {
      return await future;
    } catch (_) {
      return _defaults;
    }
  }
}
