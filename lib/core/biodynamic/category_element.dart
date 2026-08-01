import '../plant_category.dart';
import 'biodynamic_day.dart';

/// Sowing-calendar element per coarse plant category (FR-19 T5.1).
///
/// `vegetable` is deliberately absent: the bucket mixes fruit, root, leaf and
/// flower crops, so vegetables resolve per plant id via [kPlantElementOverride].
const kCategoryElement = <String, BiodynamicElement>{
  'fruit_tree': BiodynamicElement.fruit,
  'berries': BiodynamicElement.fruit,
  'herbs': BiodynamicElement.leaf,
  'ornamental': BiodynamicElement.flower,
  'lawn': BiodynamicElement.leaf,
};

/// Seed categories with deliberately no recommendation (decision 2026-07-31/08-01):
/// houseplants, conifers and hedges sit outside the sowing-calendar domain.
/// Checked on the fine seed category, before folding onto coarse buckets.
const kCategoryNoElement = <String>{'houseplant', 'conifer', 'hedge'};

/// Element per catalog plant id, consulted before the category default.
///
/// Holds every vegetable (the bucket is too mixed for one element) plus
/// cross-bucket exceptions: flower-harvested herbs. Classification follows the
/// Thun tradition of the harvested plant part (brassicas -> leaf with broccoli
/// the flower exception, alliums except leek -> root, legumes and corn ->
/// fruit), cross-checked against Slovenian sowing calendars 2026-08-01.
const kPlantElementOverride = <String, BiodynamicElement>{
  'tomato': BiodynamicElement.fruit,
  'pepper': BiodynamicElement.fruit,
  'chili': BiodynamicElement.fruit,
  'eggplant': BiodynamicElement.fruit,
  'cucumber': BiodynamicElement.fruit,
  'zucchini': BiodynamicElement.fruit,
  'pumpkin': BiodynamicElement.fruit,
  'bean': BiodynamicElement.fruit,
  'pea': BiodynamicElement.fruit,
  'corn': BiodynamicElement.fruit,
  'potato': BiodynamicElement.root,
  'carrot': BiodynamicElement.root,
  'beetroot': BiodynamicElement.root,
  'radish': BiodynamicElement.root,
  'black_radish': BiodynamicElement.root,
  'onion': BiodynamicElement.root,
  'garlic': BiodynamicElement.root,
  // Generic entry covers both varieties; celeriac (root day) dominates locally,
  // stalk celery would be leaf.
  'celery': BiodynamicElement.root,
  'lettuce': BiodynamicElement.leaf,
  'spinach': BiodynamicElement.leaf,
  'cabbage': BiodynamicElement.leaf,
  'chinese_cabbage': BiodynamicElement.leaf,
  // Cauliflower sows with the brassicas on leaf days; only broccoli is the
  // flower exception in the Thun tradition.
  'cauliflower': BiodynamicElement.leaf,
  'kale': BiodynamicElement.leaf,
  'kohlrabi': BiodynamicElement.leaf,
  'leek': BiodynamicElement.leaf,
  'chard': BiodynamicElement.leaf,
  'corn_salad': BiodynamicElement.leaf,
  'arugula': BiodynamicElement.leaf,
  'brussels_sprouts': BiodynamicElement.leaf,
  'purslane': BiodynamicElement.leaf,
  'broccoli': BiodynamicElement.flower,
  // Flower-harvested herbs, unlike the leafy rest of their bucket.
  'chamomile': BiodynamicElement.flower,
  'lavender': BiodynamicElement.flower,
};

/// Sowing-calendar element for a plant, or null when there is no
/// recommendation (houseplants, conifers, hedges, custom plants, unknown ids).
BiodynamicElement? plantElement({required String category, String? plantId}) {
  final override = plantId == null ? null : kPlantElementOverride[plantId];
  if (override != null) return override;
  if (kCategoryNoElement.contains(category)) return null;
  final coarse = coarsePlantCategory(category);
  if (coarse == 'vegetable') return null;
  return kCategoryElement[coarse];
}
