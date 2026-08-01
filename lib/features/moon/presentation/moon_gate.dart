import '../application/moon_settings_controller.dart';

/// Whether a moon surface (chip, badge, task section, journal button) may show
/// for these settings. The feature flag is checked separately by each gate
/// widget, before it touches Riverpod — host screens pump without a
/// ProviderScope while the feature is dark. Settings that failed to load
/// (null) count as off: a disabled feature is safer than a half-configured one.
bool moonSurfaceOn(MoonSettings? settings) => settings?.enabled ?? false;

/// The journal colour layer additionally needs its own sub-switch (wireframe
/// board C, "show in journal" from T3.6) — unlike the 🌙 entry button, which
/// follows the master switch alone.
bool journalMoonLayerOn(MoonSettings? settings) =>
    settings != null && settings.enabled && settings.showInJournal;
