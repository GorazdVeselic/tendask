import '../../../core/biodynamic/category_element.dart';
import '../application/moon_settings_controller.dart';

/// Whether the FREE part of the moon calendar may show for these settings: the
/// phase on the Home chip, which stays free forever (spec §6.5). The feature
/// flag is checked separately by each gate widget, before it touches Riverpod —
/// host screens pump without a ProviderScope while the feature is dark.
/// Settings that failed to load (null) count as off: a disabled feature is
/// safer than a half-configured one.
bool moonSurfaceOn(MoonSettings? settings) => settings?.enabled ?? false;

/// Whether a surface that shows the ELEMENT DAY may render — everything the
/// entitlement pays for (spec §6.5): the when-step badge, the task section, the
/// journal layer, the calendar entries and the hint. [isPlus] comes from
/// `plusActiveProvider`; while it is still loading it reads as false, so a
/// walled surface never flashes open.
bool moonPlusSurfaceOn(MoonSettings? settings, bool isPlus) =>
    isPlus && moonSurfaceOn(settings);

/// The journal colour layer additionally needs its own sub-switch (wireframe
/// board C, "show in journal" from T3.6) — unlike the 🌙 entry button, which
/// follows the master switch alone.
bool journalMoonLayerOn(MoonSettings? settings, bool isPlus) =>
    settings != null &&
    settings.showInJournal &&
    moonPlusSurfaceOn(settings, isPlus);

/// Catalog id the plant-detail chip should hand to the finder, or null when the
/// chip must stay hidden: no entitlement, the switch is off, the plant is a
/// private entry ([category] or [plantId] null), or the sowing calendar has no
/// recommendation for it (houseplants, conifers, hedges) — the finder would
/// only answer "no recommendation".
String? plantMoonChipTarget(
  MoonSettings? settings, {
  required bool isPlus,
  required String? category,
  required String? plantId,
}) {
  if (!moonPlusSurfaceOn(settings, isPlus)) return null;
  if (category == null || plantId == null) return null;
  if (plantElement(category: category, plantId: plantId) == null) return null;
  return plantId;
}
