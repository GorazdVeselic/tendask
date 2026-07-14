/// Outcome of `UserPlantsRepository.moveToArea` — a move is refused when the
/// destination area already holds that species (the (area, species) pair is
/// kept unique). Lives outside `data/` so presentation never has to import it.
enum PlantMoveResult { moved, duplicate }
