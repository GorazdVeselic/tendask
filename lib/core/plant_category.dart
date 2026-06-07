import '../i18n/translations.g.dart';

/// Coarse category buckets shown as filter chips, in display order. The catalog
/// seed uses finer botanical categories; [coarsePlantCategory] folds them here
/// so the picker chips stay short while every seeded plant remains reachable.
const kPlantCategories = [
  'all',
  'vegetable',
  'herbs',
  'fruit_tree',
  'berries',
  'ornamental',
  'houseplant',
  'lawn',
];

/// Folds a seed category onto its coarse filter bucket (e.g. shrub → ornamental);
/// categories that are already coarse map to themselves.
String coarsePlantCategory(String category) => switch (category) {
      'perennial' ||
      'shrub' ||
      'climber' ||
      'bulb' ||
      'conifer' ||
      'hedge' =>
        'ornamental',
      _ => category,
    };

String plantCategoryLabel(String coarse, Translations t) => switch (coarse) {
      'all' => t.plants.cat_all,
      'vegetable' => t.plants.cat_vegetable,
      'herbs' => t.plants.cat_herbs,
      'fruit_tree' => t.plants.cat_fruit_tree,
      'berries' => t.plants.cat_berries,
      'ornamental' => t.plants.cat_ornamental,
      'houseplant' => t.plants.cat_houseplant,
      'lawn' => t.plants.cat_lawn,
      _ => coarse,
    };
