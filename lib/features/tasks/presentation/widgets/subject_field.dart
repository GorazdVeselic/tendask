import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../i18n/translations.g.dart';
import '../../task_specs.dart';
import '../subject_labels.dart';

/// Selected-subjects field: chips for each chosen plant/area (removable) plus a
/// "Choose" action that opens the subject picker. Shared by Quick Log and Form.
class SubjectField extends StatelessWidget {
  const SubjectField({
    super.key,
    required this.subjects,
    required this.areas,
    required this.userPlants,
    required this.plants,
    required this.onPick,
    required this.onRemove,
  });

  final List<TaskSubjectSpec> subjects;
  final Map<String, Area> areas;
  final Map<String, UserPlant> userPlants;
  final Map<String, Plant> plants;
  final VoidCallback onPick;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var i = 0; i < subjects.length; i++)
              InputChip(
                avatar: Text(
                  specIcon(
                    subjects[i],
                    areas: areas,
                    userPlants: userPlants,
                    plants: plants,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                label: Text(
                  specLabel(
                    subjects[i],
                    areas: areas,
                    userPlants: userPlants,
                    plants: plants,
                  ),
                ),
                onDeleted: () => onRemove(i),
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: Text(t.subject_picker.choose),
              onPressed: onPick,
            ),
          ],
        ),
      ),
    );
  }
}
