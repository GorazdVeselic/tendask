import '../../../core/area_plant_relevance.dart';
import '../../../core/area_type.dart';
import '../../../core/catalog_labels.dart';
import '../../../core/catalog_relevance.dart';
import '../../../core/catalog_sort.dart';
import '../../../core/database/app_database.dart';
import '../../../core/plant_category.dart';
import 'plant_display.dart';

/// One plant the picker counts as "in the target": added during this session, or
/// already living in the target area. Carries the user-plant id so a tap can
/// remove it again.
class PickedPlant {
  const PickedPlant(this.id, this.plantId, this.label);

  final String id;
  final String? plantId;
  final String label;
}

/// The catalog rows to show: matching [category] and [query], sorted by label.
List<Plant> filterCatalog(
  List<Plant> plants, {
  required String category,
  required String query,
}) {
  final normQuery = query.trim().toLowerCase();
  return sortedByLabel(
    plants
        .where(
          (p) => category == 'all' || coarsePlantCategory(p.category) == category,
        )
        .where((p) => plantMatchesQuery(p, normQuery)),
    (p) => catalogLabel(p.labels),
  );
}

/// T4: plants that fit the target area's type come first, the rest are demoted
/// under a muted divider (you don't plant a tree in a raised bed) — never hidden.
/// No target / a catch-all area type → nothing to split.
({List<Plant> first, List<Plant> other, bool softSplit}) splitByRelevance(
  List<Plant> results,
  AreaType? targetType,
) {
  final relevantCats = relevantPlantCategories(targetType);
  final relevant = results
      .where((p) => isCategoryRelevant(relevantCats, p.category))
      .toList();
  final other = results
      .where((p) => !isCategoryRelevant(relevantCats, p.category))
      .toList();
  final softSplit = relevant.isNotEmpty && other.isNotEmpty;
  return (
    first: softSplit ? relevant : results,
    other: other,
    softSplit: softSplit,
  );
}

/// Everything the target bucket holds: this session's adds plus — in garden mode
/// — the plants already in the target area (or in "no area", when that is the
/// target). Drives the ✓ marks, the counter and the footer chips.
///
/// In subject mode ([managesArea] false) the screen only returns newly created
/// ids, so the user's existing plants are none of its business.
List<PickedPlant> pickerMembers({
  required List<PickedPlant> added,
  required Iterable<UserPlant> userPlants,
  required Map<String, Plant> catalog,
  required String? targetAreaId,
  required bool managesArea,
}) => [
  ...added,
  if (managesArea)
    for (final p in userPlants)
      if (p.areaId == targetAreaId && added.every((a) => a.id != p.id))
        PickedPlant(p.id, p.plantId, userPlantLabel(p, catalog)),
];

/// The member representing [plantId], or null when the target does not hold it.
PickedPlant? memberFor(List<PickedPlant> members, String plantId) {
  for (final m in members) {
    if (m.plantId == plantId) return m;
  }
  return null;
}
