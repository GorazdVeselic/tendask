import '../../../core/biodynamic/category_element.dart';
import '../application/moon_settings_controller.dart';

/// Whether the element labels on tasks and plants may render: the when-step
/// badge, the task-detail section and the plant chip. They are the paid half of
/// FR-19 (spec §6.5), so they need [isPlus] — which reads false while the
/// entitlement is still loading, so a walled surface never flashes open — plus
/// their own sub-switch (decision B3). The feature flag is checked separately
/// by each gate widget, before it touches Riverpod: host screens pump without a
/// ProviderScope while the feature is dark. Settings that failed to load (null)
/// count as off: a disabled feature is safer than a half-configured one.
///
/// The moon phase on Home has no gate of its own — it is free forever and can
/// no longer be switched off (spec §6.4).
bool moonElementLabelsOn(MoonSettings? settings, bool isPlus) =>
    isPlus && (settings?.showElementLabels ?? false);

/// The journal colour layer has its own sub-switch (wireframe board C, "show in
/// journal" from T3.6) — unlike the 🌙 entry button, which the entitlement alone
/// governs.
bool journalMoonLayerOn(MoonSettings? settings, bool isPlus) =>
    isPlus && (settings?.showInJournal ?? false);

/// Catalog id the plant-detail chip should hand to the finder, or null when the
/// chip must stay hidden: no entitlement, the element-label switch is off, the
/// plant is a private entry ([category] or [plantId] null), or the sowing
/// calendar has no recommendation for it (houseplants, conifers, hedges) — the
/// finder would only answer "no recommendation".
String? plantMoonChipTarget(
  MoonSettings? settings, {
  required bool isPlus,
  required String? category,
  required String? plantId,
}) {
  if (!moonElementLabelsOn(settings, isPlus)) return null;
  if (category == null || plantId == null) return null;
  if (plantElement(category: category, plantId: plantId) == null) return null;
  return plantId;
}
