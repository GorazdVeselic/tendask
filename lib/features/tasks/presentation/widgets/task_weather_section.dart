import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/location/location_repository.dart';
import '../../../../core/task_status.dart';
import '../../../../i18n/translations.g.dart';
import '../../../weather/data/weather_snapshot.dart';
import '../../../weather/presentation/weather_card.dart';

/// The frozen weather snapshot, or a hint when the task carries none.
class TaskWeatherSection extends ConsumerWidget {
  const TaskWeatherSection({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final snapshot = decodeWeatherSnapshot(task.weather);
    if (snapshot != null) return WeatherSnapshotCard(snapshot: snapshot);

    // A waiting task's snapshot is still ahead of it, so the current location
    // decides whether there will be one — that may be said, and offered. A done
    // task's is not: the task does not record *why* it has none, and the current
    // location says nothing about the past, so it gets no claim and no CTA.
    final hasLocation = ref.watch(gardenLocationProvider).value != null;
    final (:hint, :icon, :showCta) = switch ((task.status, hasLocation)) {
      (TaskStatus.waiting, true) => (
        hint: t.weather.detail_waiting,
        icon: Icons.cloud_outlined,
        showCta: false,
      ),
      (TaskStatus.waiting, false) => (
        hint: t.weather.detail_no_location,
        icon: Icons.place_outlined,
        showCta: true,
      ),
      _ => (
        hint: t.weather.detail_none,
        icon: Icons.cloud_outlined,
        showCta: false,
      ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (showCta)
                    TextButton(
                      // Flush with the hint above it, but still a 40 dp target.
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        minimumSize: const Size(0, 40),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => context.push('/location'),
                      child: Text(t.weather.no_location_cta),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
