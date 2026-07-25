import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/catalog_labels.dart';
import '../../../../core/config.dart';
import '../../../../core/database/app_database.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/community_models.dart';
import '../community_display.dart';
import 'community_privacy_note.dart';
import 'tease_overlay.dart';

/// The "This week" feed: what the resolved bucket has been doing over the sliding
/// 7-day window, qualitatively (§7.1). Without Plus only the first row stays
/// readable and the rest is teased.
class CommunityFeedList extends StatelessWidget {
  const CommunityFeedList({
    required this.feed,
    required this.catalog,
    required this.plants,
    required this.hasPlus,
    super.key,
  });

  final CommunityFeed feed;
  final Map<String, TaskType> catalog;
  final Map<String, Plant> plants;
  final bool hasPlus;

  @override
  Widget build(BuildContext context) {
    final items = feed.items;
    final teased = !hasPlus && items.isNotEmpty;
    final visible = teased ? items.take(1).toList() : items;
    final hidden = teased ? items.skip(1).toList() : const <CommunityFeedItem>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        _MetaRow(feed: feed),
        const SizedBox(height: 10),
        Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: _Rows(items: visible, catalog: catalog, plants: plants),
        ),
        if (teased)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TeaseOverlay(
              child: hidden.isEmpty
                  ? null
                  : Card(
                      clipBehavior: Clip.antiAlias,
                      margin: EdgeInsets.zero,
                      child: _Rows(
                        items: hidden,
                        catalog: catalog,
                        plants: plants,
                      ),
                    ),
            ),
          ),
        const CommunityPrivacyNote(),
      ],
    );
  }
}

class _Rows extends StatelessWidget {
  const _Rows({
    required this.items,
    required this.catalog,
    required this.plants,
  });

  final List<CommunityFeedItem> items;
  final Map<String, TaskType> catalog;
  final Map<String, Plant> plants;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Divider(height: 1, indent: 56, color: cs.outlineVariant),
          _FeedRow(
            item: items[i],
            taskType: catalog[items[i].taskTypeId],
            plant: plants[items[i].cohort],
          ),
        ],
      ],
    );
  }
}

/// One cohort: the act (task type) plus the plant it was done on, because the
/// plant is what makes it comparable — "pruning" alone spans an apple tree and a
/// raspberry cane. Site work (lawn, bed) has no plant line.
class _FeedRow extends StatelessWidget {
  const _FeedRow({required this.item, required this.taskType, this.plant});

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
      CommunityIntensity.some => (cs.secondaryContainer, cs.onSecondaryContainer),
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

/// Window + scope + population: the reader must always see how wide and how
/// crowded the comparison is (§7.4, §7.7).
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.feed});

  final CommunityFeed feed;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Text(
      '${t.community.window_7d} · '
      '${communityScopeLabel(t, feed.bucket.resolution)} · '
      '${t.community.population(n: feed.population)}',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

