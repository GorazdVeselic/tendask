import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/supply_category.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../i18n/translations.g.dart';
import '../../application/supplies_providers.dart';
import '../recipe_edit_sheet.dart';
import '../supply_category_display.dart';
import '../supply_edit_sheet.dart';
import '../supply_format.dart';

/// Stock list grouped by [SupplyCategory]. Hosted by the garden screen's
/// "Zaloge" segment; tap a row to edit, add via the screen's "+" action.
class SupplyListView extends ConsumerWidget {
  const SupplyListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return ref
        .watch(suppliesListProvider)
        .when(
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (_, _) => Center(child: Text(t.common.load_error)),
          data: (supplies) => supplies.isEmpty
              ? EmptyState(t.supplies.empty)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  children: _grouped(supplies, t),
                ),
        );
  }

  /// Sections in [SupplyCategory] declaration order; empty categories are
  /// dropped. Supplies arrive already name-sorted from the provider.
  List<Widget> _grouped(List<Supply> supplies, Translations t) {
    final widgets = <Widget>[];
    for (final category in SupplyCategory.values) {
      final inGroup = supplies.where((s) => s.category == category).toList();
      if (inGroup.isEmpty) continue;
      widgets.add(SectionLabel(supplyCategoryLabel(category, t)));
      widgets.addAll(inGroup.map((s) => _SupplyRow(supply: s)));
    }
    return widgets;
  }
}

/// Saved mixtures. Hosted by the garden screen's "Recepti" segment.
class RecipeListView extends ConsumerWidget {
  const RecipeListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return ref
        .watch(recipesListProvider)
        .when(
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (_, _) => Center(child: Text(t.common.load_error)),
          data: (recipes) => recipes.isEmpty
              ? EmptyState(t.recipes.empty)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: recipes.length,
                  itemBuilder: (_, i) => _RecipeRow(recipe: recipes[i]),
                ),
        );
  }
}

class _RecipeRow extends StatelessWidget {
  const _RecipeRow({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        leading: const Text('📋', style: TextStyle(fontSize: 22)),
        title: Text(recipe.name, style: theme.textTheme.bodyMedium),
        subtitle: recipe.equipment != null
            ? Text(recipe.equipment!, style: theme.textTheme.bodySmall)
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onTap: () => showRecipeEditSheet(context, recipeId: recipe.id),
      ),
    );
  }
}

class _SupplyRow extends StatelessWidget {
  const _SupplyRow({required this.supply});

  final Supply supply;

  // Out of stock (including a deficit — quantity can go negative on
  // over-consumption) or at/under the user's low threshold.
  bool get _isLow =>
      supply.quantity <= 0 ||
      (supply.lowThreshold != null && supply.quantity <= supply.lowThreshold!);

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final unit = supply.unit ?? '';
    final qtyText = t.supplies.qty(
      q: formatSupplyQuantity(supply.quantity, clampNegative: true),
      unit: unit,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        leading: Text(
          supplyCategoryIcon(supply.category),
          style: const TextStyle(fontSize: 22),
        ),
        title: Text(supply.name, style: theme.textTheme.bodyMedium),
        subtitle: supply.unit != null
            ? Text(supply.unit!, style: theme.textTheme.bodySmall)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isLow
                ? Text(
                    '⚠️ ${t.supplies.low}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  )
                : Text(
                    qtyText,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
            const SizedBox(width: 2),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        onTap: () => showSupplyEditSheet(context, supplyId: supply.id),
      ),
    );
  }
}
