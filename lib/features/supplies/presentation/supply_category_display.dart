import '../../../core/supply_category.dart';
import '../../../i18n/translations.g.dart';

/// Emoji avatar for a supply category (presentation mapping, not domain logic).
String supplyCategoryIcon(SupplyCategory category) => switch (category) {
  SupplyCategory.fertilizer => '🧪',
  SupplyCategory.treatment => '🧴',
  SupplyCategory.equipment => '🛢️',
  SupplyCategory.other => '📦',
};

/// Localized label for a supply category.
String supplyCategoryLabel(SupplyCategory category, Translations t) =>
    switch (category) {
      SupplyCategory.fertilizer => t.supplies.cat_fertilizer,
      SupplyCategory.treatment => t.supplies.cat_treatment,
      SupplyCategory.equipment => t.supplies.cat_equipment,
      SupplyCategory.other => t.supplies.cat_other,
    };
