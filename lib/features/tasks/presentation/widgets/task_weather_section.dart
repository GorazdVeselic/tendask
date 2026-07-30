import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/location/location_repository.dart';
import '../../../../core/task_status.dart';
import '../../../../core/widgets/link_span.dart';
import '../../../../i18n/translations.g.dart';
import '../../../weather/data/weather_code.dart';
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
    // location says nothing about the past, so it gets no claim and no way out.
    final hasLocation = ref.watch(gardenLocationProvider).value != null;
    final hintStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final (:hint, :onTap) = switch ((task.status, hasLocation)) {
      (TaskStatus.waiting, true) => (
        hint: TextSpan(text: t.weather.detail_waiting),
        onTap: null,
      ),
      (TaskStatus.waiting, false) => (
        // Deliberately the dashboard invite, word for word in shape: same card,
        // same glyph, a sentence with the same linked word. The app asks for a
        // location in one voice, wherever it asks.
        hint: t.weather.detail_no_location(
          link: (text) => linkSpan(context, text),
        ),
        onTap: () => context.push('/location'),
      ),
      _ => (hint: TextSpan(text: t.weather.detail_none), onTap: null),
    };

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(kNoWeatherEmoji, style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(child: Text.rich(hint, style: hintStyle)),
        ],
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(onTap: onTap, child: content),
    );
  }
}
