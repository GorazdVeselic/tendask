import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../task_specs.dart';
import '../subject_labels.dart';

/// The task's subjects (plants and/or areas), each row navigating to its detail.
class TaskSubjectsCard extends StatelessWidget {
  const TaskSubjectsCard({
    super.key,
    required this.subjects,
    required this.areas,
    required this.userPlants,
    required this.plants,
  });

  final List<TaskSubject> subjects;
  final Map<String, Area> areas;
  final Map<String, UserPlant> userPlants;
  final Map<String, Plant> plants;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < subjects.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 56,
                color: theme.colorScheme.outlineVariant,
              ),
            _row(context, subjects[i]),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, TaskSubject s) {
    final theme = Theme.of(context);
    final spec = TaskSubjectSpec(userPlantId: s.userPlantId, areaId: s.areaId);
    final label = specLabel(
      spec,
      areas: areas,
      userPlants: userPlants,
      plants: plants,
    );
    final icon = specIcon(
      spec,
      areas: areas,
      userPlants: userPlants,
      plants: plants,
    );
    // For a plant subject, show its area as a subtitle (derived from instance).
    final plantArea = s.userPlantId != null
        ? userPlants[s.userPlantId]?.areaId
        : null;
    final areaName = plantArea != null ? areas[plantArea]?.name : null;

    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(label, style: theme.textTheme.bodyMedium),
      subtitle: areaName != null
          ? Text(
              '🪴 $areaName',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: () {
        if (s.userPlantId != null) {
          context.pushNamed(
            'plant-detail',
            pathParameters: {'id': s.userPlantId!},
          );
        } else if (s.areaId != null) {
          context.pushNamed('area-detail', pathParameters: {'id': s.areaId!});
        }
      },
    );
  }
}
