import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../i18n/translations.g.dart';

/// The optional add target, pinned at the top of the plant picker — the catalog
/// list below can grow long, and "adding to what" must stay visible.
class PlantAreaBar extends StatelessWidget {
  const PlantAreaBar({
    super.key,
    required this.areaId,
    required this.areas,
    required this.onTap,
  });

  final String? areaId;
  final Map<String, Area> areas;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final name = areaId != null ? areas[areaId]?.name : null;
    return Material(
      color: cs.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.plants.add_to_label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      name ?? t.area_pick.none,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    t.plants.choose_area,
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant),
        ],
      ),
    );
  }
}
