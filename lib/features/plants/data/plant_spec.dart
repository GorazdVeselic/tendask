/// One plant to attach to an area — the drift-free shape used by the area form
/// buffer and [UserPlantsRepository.syncForArea]. A catalog match sets [plantId];
/// a private custom entry sets [customName] instead.
class PlantSpec {
  const PlantSpec({
    this.userPlantId,
    this.plantId,
    this.customName,
    this.personalAlias,
  });

  /// Existing row id (edit), or null for a not-yet-saved plant.
  final String? userPlantId;
  final String? plantId;
  final String? customName;
  final String? personalAlias;

  bool get isCustom => plantId == null;
}
