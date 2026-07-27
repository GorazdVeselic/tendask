import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/catalog_labels.dart';
import '../../../../core/config.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/date_format.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/community_models.dart';
import '../community_display.dart';

/// One cohort: the act (task type) plus the plant it was done on, because the
/// plant is what makes it comparable — "pruning" alone spans an apple tree and a
/// raspberry cane. Site work (lawn, bed) has no plant line. Tapping opens the
/// same per-task template every entry point leads to (§12.1).
class CommunityFeedRow extends StatelessWidget {
  const CommunityFeedRow({
    required this.item,
    required this.taskType,
    this.plant,
    super.key,
  });

  final CommunityFeedItem item;
  final TaskType? taskType;
  final Plant? plant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = taskType;
    final subject = plant;
    return ListTile(
      onTap: () => context.pushNamed(
        'community-task',
        pathParameters: {'taskTypeId': item.taskTypeId},
        // Site work carries no plant, so the detail resolves the site cohort.
        queryParameters: {
          if (item.cohort != kCommunityCohortSite) 'plant': item.cohort,
        },
      ),
      leading: Text(
        subject?.icon ?? type?.icon ?? '🌱',
        style: const TextStyle(fontSize: 22),
      ),
      title: Text(
        // An unknown id means the catalog pull lags the aggregate — show the id
        // rather than an empty row.
        type == null ? item.taskTypeId : catalogLabel(type.labels),
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: subject == null
          ? null
          : Text(
              catalogLabel(subject.labels),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
      trailing: _IntensityPill(item.intensity),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

/// Qualitative pill: busiest task types in the brand container tone, the quiet
/// tail in a muted outline — a raw % over 7 days would mislead (§7.8).
class _IntensityPill extends StatelessWidget {
  const _IntensityPill(this.intensity);

  final CommunityIntensity intensity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final (Color? bg, Color fg) = switch (intensity) {
      CommunityIntensity.often => (cs.primaryContainer, cs.onPrimaryContainer),
      CommunityIntensity.some => (
        cs.secondaryContainer,
        cs.onSecondaryContainer,
      ),
      CommunityIntensity.rare => (null, cs.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: bg == null ? Border.all(color: cs.outline) : null,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        communityIntensityLabel(context.t, intensity),
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Window + scope + population: wherever a feed row is shown, the reader must
/// see how wide and how crowded the comparison behind it is (§7.4, §7.7).
class CommunityFeedMeta extends StatelessWidget {
  const CommunityFeedMeta({required this.feed, super.key});

  final CommunityFeed feed;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final fetchedAt = feed.fetchedAt.toLocal();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${t.community.window_7d} · '
          '${communityScopeLabel(t, feed.bucket.resolution)} · '
          '${t.community.population(n: feed.population)}',
          style: style,
        ),
        // Offline the last slice stays on screen (CLAUDE.md § Network): date it
        // rather than pass yesterday's neighbourhood off as today's.
        if (!isSameDay(fetchedAt, DateTime.now()))
          Text(t.community.data_from(date: formatDmy(fetchedAt)), style: style),
      ],
    );
  }
}
