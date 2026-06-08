import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../i18n/translations.g.dart';
import '../../application/plants_providers.dart';
import '../../../../core/database/catalog_provider.dart';
import '../plant_display.dart';

/// Picks a plant belonging to [areaId] (chips), or adds a new one via the
/// catalog picker ([onAdd]). Used by the note form.
class PlantField extends ConsumerWidget {
  const PlantField({
    super.key,
    required this.areaId,
    required this.selectedId,
    required this.onChanged,
    required this.onAdd,
  });

  final String areaId;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final plants = ref.watch(userPlantsByAreaProvider(areaId)).asData?.value;
    final catalog = ref.watch(plantsMapProvider).asData?.value ?? const {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (plants == null)
              const Center(child: CircularProgressIndicator.adaptive())
            else if (plants.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  t.plants.field_empty,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final p in plants)
                    ChoiceChip(
                      avatar: Text(
                        userPlantIcon(p, catalog),
                        style: const TextStyle(fontSize: 14),
                      ),
                      label: Text(userPlantLabel(p, catalog)),
                      selected: p.id == selectedId,
                      onSelected: (sel) => onChanged(sel ? p.id : null),
                    ),
                ],
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: Text(t.plants.field_add),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
