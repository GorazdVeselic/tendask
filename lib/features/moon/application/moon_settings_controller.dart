import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/biodynamic/calendar_system.dart';
import '../../../core/local_prefs/local_prefs.dart';

part 'moon_settings_controller.g.dart';

/// Moon calendar settings (FR-19): the zodiac system and the display
/// sub-toggles (garden ★, Journal layer, astro details, element labels). There
/// is no master switch — the phase on Home is always on (decision B3).
class MoonSettings {
  const MoonSettings({
    required this.system,
    required this.highlightGarden,
    required this.showInJournal,
    required this.showAstroDetails,
    required this.showElementLabels,
  });

  final CalendarSystem system;
  final bool highlightGarden;
  final bool showInJournal;
  final bool showAstroDetails;
  final bool showElementLabels;

  MoonSettings copyWith({
    CalendarSystem? system,
    bool? highlightGarden,
    bool? showInJournal,
    bool? showAstroDetails,
    bool? showElementLabels,
  }) =>
      MoonSettings(
        system: system ?? this.system,
        highlightGarden: highlightGarden ?? this.highlightGarden,
        showInJournal: showInJournal ?? this.showInJournal,
        showAstroDetails: showAstroDetails ?? this.showAstroDetails,
        showElementLabels: showElementLabels ?? this.showElementLabels,
      );

  @override
  bool operator ==(Object other) =>
      other is MoonSettings &&
      other.system == system &&
      other.highlightGarden == highlightGarden &&
      other.showInJournal == showInJournal &&
      other.showAstroDetails == showAstroDetails &&
      other.showElementLabels == showElementLabels;

  @override
  int get hashCode => Object.hash(
        system,
        highlightGarden,
        showInJournal,
        showAstroDetails,
        showElementLabels,
      );

  @override
  String toString() =>
      'MoonSettings(system: ${system.name}, '
      'highlightGarden: $highlightGarden, showInJournal: $showInJournal, '
      'showAstroDetails: $showAstroDetails, '
      'showElementLabels: $showElementLabels)';
}

/// Defaults when nothing is stored yet or the load failed: sidereal (matches
/// the printed calendars the target market uses) and every sub-toggle on
/// (decision 2026-07-31, extended by B3). This is also the picture the
/// settings screen shows without Tendask+ — what the licence brings, not the
/// user's own state.
const kMoonSettingsDefaults = MoonSettings(
  system: CalendarSystem.sidereal,
  highlightGarden: true,
  showInJournal: true,
  showAstroDetails: true,
  showElementLabels: true,
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
    final system = switch (await prefs.moonSystem()) {
      'tropical' => CalendarSystem.tropical,
      _ => kMoonSettingsDefaults.system,
    };
    final highlightGarden = await prefs.moonHighlightGarden() ??
        kMoonSettingsDefaults.highlightGarden;
    final showInJournal =
        await prefs.moonShowInJournal() ?? kMoonSettingsDefaults.showInJournal;
    final showAstroDetails = await prefs.moonShowAstroDetails() ??
        kMoonSettingsDefaults.showAstroDetails;
    final showElementLabels = await prefs.moonShowElementLabels() ??
        kMoonSettingsDefaults.showElementLabels;
    return MoonSettings(
      system: system,
      highlightGarden: highlightGarden,
      showInJournal: showInJournal,
      showAstroDetails: showAstroDetails,
      showElementLabels: showElementLabels,
    );
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

  Future<void> setShowElementLabels(bool showElementLabels) async {
    state = AsyncData(
      (await _current()).copyWith(showElementLabels: showElementLabels),
    );
    await ref
        .read(localPrefsProvider)
        .setMoonShowElementLabels(showElementLabels);
  }

  /// Current settings, falling back to [kMoonSettingsDefaults] when the initial
  /// load failed — a toggle tap must still work (and repair state) in that case.
  Future<MoonSettings> _current() async {
    try {
      return await future;
    } catch (_) {
      return kMoonSettingsDefaults;
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
