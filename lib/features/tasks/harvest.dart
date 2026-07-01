import '../../core/database/app_database.dart';

/// Catalog category for harvesting task types (the single `harvest` type today).
/// Harvest yield capture (T11) is offered only for these.
const kHarvestCategory = 'harvest';

/// Whether a task type records a harvest — gates the yield input across the UI.
bool isHarvestType(TaskType? type) => type?.category == kHarvestCategory;
