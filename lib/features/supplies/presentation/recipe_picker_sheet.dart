import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/sheet_handle.dart';
import '../../../i18n/translations.g.dart';
import '../application/supplies_providers.dart';
import '../data/recipe_item.dart';
import '../data/supply_spec.dart';

/// Picks a saved recipe; returns its items as task supply specs, or null if
/// dismissed. Used by the entry supplies step to prefill from a mixture.
Future<List<SupplySpec>?> showRecipePickerSheet(BuildContext context) {
  return showModalBottomSheet<List<SupplySpec>>(
    context: context,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: const _RecipePickerSheet(),
    ),
  );
}

class _RecipePickerSheet extends ConsumerWidget {
  const _RecipePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final recipes = ref.watch(recipesListProvider).asData?.value ?? const [];
    // Only prefill items whose supply still exists — a deleted supply can't be
    // consumed and would otherwise add a task_supply against a removed row.
    final liveSupplyIds = {
      for (final s in ref.watch(suppliesListProvider).asData?.value ?? const [])
        s.id,
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            Text(t.recipes.pick_title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (recipes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  t.recipes.empty,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              for (final r in recipes)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  child: ListTile(
                    leading: const Text('📋', style: TextStyle(fontSize: 22)),
                    title: Text(r.name, style: theme.textTheme.bodyMedium),
                    subtitle: r.equipment != null
                        ? Text(r.equipment!, style: theme.textTheme.bodySmall)
                        : null,
                    onTap: () {
                      final specs = parseRecipeItems(r.items)
                          .where((i) => liveSupplyIds.contains(i.supplyId))
                          .map(
                            (i) =>
                                SupplySpec(supplyId: i.supplyId, amount: i.amount),
                          )
                          .toList();
                      Navigator.of(context).pop(specs);
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
