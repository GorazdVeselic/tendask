import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../i18n/translations.g.dart';
import '../area_type_display.dart';
import '../garden_items.dart';

/// The group's parent line — its plants render in a card beneath it.
class AreaHeader extends StatelessWidget {
  const AreaHeader({super.key, required this.item, required this.catalog});

  final GardenAreaItem item;
  final Map<String, TaskType> catalog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final area = item.area;
    return InkWell(
      onTap: () =>
          context.pushNamed('area-detail', pathParameters: {'id': area.id}),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                areaTypeIcon(area.type),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    area.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    areaSubtitle(
                      context.t,
                      lastTask: item.lastTask,
                      catalog: catalog,
                      plantCount: item.plantCount,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
