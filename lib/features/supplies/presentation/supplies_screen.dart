import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/supply_category.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../application/supplies_providers.dart';
import 'recipe_edit_sheet.dart';
import 'supply_category_display.dart';
import 'supply_edit_sheet.dart';

enum _Tab { supplies, recipes }

class SuppliesScreen extends ConsumerStatefulWidget {
  const SuppliesScreen({super.key});

  @override
  ConsumerState<SuppliesScreen> createState() => _SuppliesScreenState();
}

class _SuppliesScreenState extends ConsumerState<SuppliesScreen> {
  _Tab _tab = _Tab.supplies;

  void _add() => switch (_tab) {
    _Tab.supplies => showSupplyEditSheet(context),
    _Tab.recipes => showRecipeEditSheet(context),
  };

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: context.pop,
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.supplies.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              t.supplies.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _add),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SegmentedButton<_Tab>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: _Tab.supplies, label: Text(t.supplies.seg_supplies)),
                ButtonSegment(value: _Tab.recipes, label: Text(t.supplies.seg_recipes)),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => setState(() => _tab = s.first),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              _Tab.supplies => const _SuppliesList(),
              _Tab.recipes => const _RecipesList(),
            },
          ),
        ],
      ),
    );
  }
}

class _SuppliesList extends ConsumerWidget {
  const _SuppliesList();

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
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
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

class _RecipesList extends ConsumerWidget {
  const _RecipesList();

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
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
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
    final qtyText = t.supplies.qty(q: _fmt(supply.quantity), unit: unit);

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
        trailing: _isLow
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
        onTap: () => showSupplyEditSheet(context, supplyId: supply.id),
      ),
    );
  }

  // Never surface a negative stock (a deficit reads as "low" above); the exact
  // signed value is kept in the DB for symmetric revert, only display clamps.
  static String _fmt(double v) {
    final c = v < 0 ? 0.0 : v;
    return c == c.roundToDouble() ? c.toInt().toString() : c.toString();
  }
}
