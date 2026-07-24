import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/task_status.dart';
import '../../../../i18n/translations.g.dart';
import '../../../weather/data/weather_snapshot.dart';
import '../../../weather/presentation/weather_card.dart';

/// The frozen weather snapshot, or a hint when the task carries none.
class TaskWeatherSection extends StatelessWidget {
  const TaskWeatherSection({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final snapshot = decodeWeatherSnapshot(task.weather);
    if (snapshot != null) return WeatherSnapshotCard(snapshot: snapshot);

    // No snapshot: waiting tasks capture on completion; a done task without one
    // was logged offline (graceful — it may fill in later).
    final hint = task.status == TaskStatus.waiting
        ? t.weather.detail_waiting
        : t.weather.detail_none;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              Icons.cloud_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
