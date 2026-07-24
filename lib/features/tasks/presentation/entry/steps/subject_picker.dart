import '../../../../../core/catalog_labels.dart';
import '../../../../../core/catalog_relevance.dart';
import '../../../../../core/catalog_sort.dart';
import '../../../../../core/database/app_database.dart';
import '../../../../../core/plant_category.dart';
import '../../../../plants/presentation/plant_display.dart';

/// Derivation behind the subject step's plant/area picker, kept out of the
/// widget so the grouping, dedup and relevance ordering can be tested. All
/// inputs are plain maps/lists; nothing here touches Riverpod or BuildContext.

bool _inCategory(String? category, String selected) =>
    selected == 'all' ||
    (category != null && coarsePlantCategory(category) == selected);

/// The user's plants matching the [category] chip and [query], sorted by label.
List<UserPlant> filterSubjectPlants(
  Iterable<UserPlant> userPlants, {
  required Map<String, Plant> catalog,
  required String category,
  required String query,
}) {
  final normQuery = query.trim().toLowerCase();
  return sortedByLabel(
    userPlants
        .where((p) => _inCategory(catalog[p.plantId]?.category, category))
        .where(
          (p) =>
              normQuery.isEmpty ||
              userPlantLabel(p, catalog).toLowerCase().contains(normQuery),
        ),
    (p) => userPlantLabel(p, catalog),
  );
}

/// Stable partition: plants whose category the task type applies to (T3) first,
/// the rest under a muted divider. [softSplit] is true only when both groups are
/// non-empty, i.e. when the divider is worth showing.
({List<UserPlant> relevant, List<UserPlant> other, bool softSplit})
splitSubjectPlants(
  List<UserPlant> plants, {
  required Set<String> relevantCategories,
  required Map<String, Plant> catalog,
}) {
  bool isRelevant(UserPlant p) =>
      isCategoryRelevant(relevantCategories, catalog[p.plantId]?.category);
  final relevant = plants.where(isRelevant).toList();
  final other = plants.where((p) => !isRelevant(p)).toList();
  return (
    relevant: relevant,
    other: other,
    softSplit: relevant.isNotEmpty && other.isNotEmpty,
  );
}

/// Catalog ids the user already owns — excluded from the catalog search so a
/// plant is never offered twice.
Set<String> ownedPlantIds(Iterable<UserPlant> userPlants) => {
  for (final p in userPlants)
    if (p.plantId != null) p.plantId!,
};

/// Catalog rows to offer for the search [query]: not already owned, matching the
/// [category] chip, sorted by label, with task-relevant species (T3) first.
List<Plant> subjectCatalogMatches(
  List<Plant> catalogList, {
  required Set<String> owned,
  required Set<String> relevantCategories,
  required String category,
  required String query,
}) {
  final normQuery = query.trim().toLowerCase();
  if (normQuery.isEmpty) return const [];
  final sorted = sortedByLabel(
    catalogList.where(
      (p) =>
          !owned.contains(p.id) &&
          _inCategory(p.category, category) &&
          plantMatchesQuery(p, normQuery),
    ),
    (p) => catalogLabel(p.labels),
  );
  bool isRelevant(Plant p) => isCategoryRelevant(relevantCategories, p.category);
  return [...sorted.where(isRelevant), ...sorted.where((p) => !isRelevant(p))];
}

/// Names of the areas the selected plants live in — shown as context, not as
/// co-equal subjects.
Set<String> selectedPlantAreaNames({
  required Set<String> plantIds,
  required Map<String, UserPlant> userPlants,
  required Map<String, Area> areas,
}) => {
  for (final id in plantIds) ?areas[userPlants[id]?.areaId]?.name,
};

/// Category chips worth offering: only those the user actually has plants in
/// (an empty category would just return nothing), in catalog order with "all"
/// first. Empty when the user has no categorised plants at all.
List<String> subjectCategoryChips(
  Iterable<UserPlant> userPlants,
  Map<String, Plant> catalog,
) {
  final present = <String>{
    for (final p in userPlants)
      if (p.plantId != null && catalog[p.plantId] != null)
        coarsePlantCategory(catalog[p.plantId]!.category),
  };
  return present.isEmpty
      ? const []
      : [
          'all',
          for (final c in kPlantCategories)
            if (c != 'all' && present.contains(c)) c,
        ];
}
