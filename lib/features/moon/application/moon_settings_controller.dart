import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/biodynamic/calendar_system.dart';
import '../../../core/local_prefs/local_prefs.dart';

part 'moon_settings_controller.g.dart';

/// Moon calendar settings (FR-19): the on/off switch, the zodiac system and
/// the display sub-toggles (garden ★, Journal layer, astro details).
class MoonSettings {
  const MoonSettings({
    required this.enabled,
    required this.system,
    required this.highlightGarden,
    required this.showInJournal,
    required this.showAstroDetails,
  });

  final bool enabled;
  final CalendarSystem system;
  final bool highlightGarden;
  final bool showInJournal;
  final bool showAstroDetails;

  MoonSettings copyWith({
    bool? enabled,
    CalendarSystem? system,
    bool? highlightGarden,
    bool? showInJournal,
    bool? showAstroDetails,
  }) =>
      MoonSettings(
        enabled: enabled ?? this.enabled,
        system: system ?? this.system,
        highlightGarden: highlightGarden ?? this.highlightGarden,
        showInJournal: showInJournal ?? this.showInJournal,
        showAstroDetails: showAstroDetails ?? this.showAstroDetails,
      );

  @override
  bool operator ==(Object other) =>
      other is MoonSettings &&
      other.enabled == enabled &&
      other.system == system &&
      other.highlightGarden == highlightGarden &&
      other.showInJournal == showInJournal &&
      other.showAstroDetails == showAstroDetails;

  @override
  int get hashCode => Object.hash(
        enabled,
        system,
        highlightGarden,
        showInJournal,
        showAstroDetails,
      );

  @override
  String toString() =>
      'MoonSettings(enabled: $enabled, system: ${system.name}, '
      'highlightGarden: $highlightGarden, showInJournal: $showInJournal, '
      'showAstroDetails: $showAstroDetails)';
}

/// Defaults when nothing is stored yet or the load failed: enabled (decision
/// A6), sidereal (matches the printed calendars the target market uses),
/// display sub-toggles on (decision 2026-07-31).
const _defaults = MoonSettings(
  enabled: true,
  system: CalendarSystem.sidereal,
  highlightGarden: true,
  showInJournal: true,
  showAstroDetails: true,
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
    final highlightGarden =
        await prefs.moonHighlightGarden() ?? _defaults.highlightGarden;
    final showInJournal =
        await prefs.moonShowInJournal() ?? _defaults.showInJournal;
    final showAstroDetails =
        await prefs.moonShowAstroDetails() ?? _defaults.showAstroDetails;
    return MoonSettings(
      enabled: enabled,
      system: system,
      highlightGarden: highlightGarden,
      showInJournal: showInJournal,
      showAstroDetails: showAstroDetails,
    );
  }

  Future<void> setEnabled(bool enabled) async {
    state = AsyncData((await _current()).copyWith(enabled: enabled));
    await ref.read(localPrefsProvider).setMoonCalendarEnabled(enabled);
  }

  Future<void> setSystem(CalendarSystem system) async {
    state = AsyncData((await _current()).copyWith(system: system));
    await ref.read(localPrefsProvider).setMoonSystem(system.name);
  }

  Future<void> setHighlightGarden(bool highlightGarden) async {
    state = AsyncData(
      (await _current()).copyWith(highlightGarden: highlightGarden),
    );
    await ref.read(localPrefsProvider).setMoonHighlightGarden(highlightGarden);
  }

  Future<void> setShowInJournal(bool showInJournal) async {
    state = AsyncData((await _current()).copyWith(showInJournal: showInJournal));
    await ref.read(localPrefsProvider).setMoonShowInJournal(showInJournal);
  }

  Future<void> setShowAstroDetails(bool showAstroDetails) async {
    state = AsyncData(
      (await _current()).copyWith(showAstroDetails: showAstroDetails),
    );
    await ref
        .read(localPrefsProvider)
        .setMoonShowAstroDetails(showAstroDetails);
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

/// The zodiac system every moon surface reads (one system drives them all,
/// spec §11.6). Sidereal while the settings are still loading or if they
/// failed — the same fallback everywhere, so no two surfaces can disagree.
@riverpod
CalendarSystem moonSystem(Ref ref) =>
    ref.watch(moonSettingsControllerProvider).asData?.value.system ??
    CalendarSystem.sidereal;
