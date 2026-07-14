import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../plants/presentation/widgets/plant_row.dart';

/// One card holding the plants of an area (or the unassigned ones).
class PlantGroupCard extends StatelessWidget {
  const PlantGroupCard({
    super.key,
    required this.plants,
    required this.catalog,
  });

  final List<UserPlant> plants;
  final Map<String, Plant> catalog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < plants.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 56,
                color: theme.colorScheme.outlineVariant,
              ),
            PlantRow(plant: plants[i], catalog: catalog),
          ],
        ],
      ),
    );
  }
}
