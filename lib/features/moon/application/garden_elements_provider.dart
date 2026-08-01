import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/biodynamic/biodynamic_day.dart';
import '../../../core/biodynamic/category_element.dart';
import '../../../core/database/catalog_provider.dart';
import '../../plants/application/plants_providers.dart';

part 'garden_elements_provider.g.dart';

/// Elements covered by the user's garden (FR-19 ★ highlight): every
/// catalog-matched plant resolves via [plantElement]; custom plants carry no
/// recommendation. Empty while plants or the catalog are still loading, and
/// for an empty garden — the ★ layer then simply stays off.
@riverpod
Set<BiodynamicElement> gardenElements(Ref ref) {
  final plants = ref.watch(plantsMapProvider).asData?.value ?? const {};
  final userPlants = ref.watch(userPlantsMapProvider).asData?.value;
  if (userPlants == null) return const {};

  final elements = <BiodynamicElement>{};
  for (final userPlant in userPlants.values) {
    final plant = plants[userPlant.plantId];
    if (plant == null) continue;
    final element = plantElement(category: plant.category, plantId: plant.id);
    if (element != null) elements.add(element);
  }
  return elements;
}
