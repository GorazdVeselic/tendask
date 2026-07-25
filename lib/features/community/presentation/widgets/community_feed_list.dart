import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../data/community_models.dart';
import 'community_feed_row.dart';
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
        CommunityFeedMeta(feed: feed),
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
          if (i > 0) Divider(height: 1, indent: 56, color: cs.outlineVariant),
          CommunityFeedRow(
            item: items[i],
            taskType: catalog[items[i].taskTypeId],
            plant: plants[items[i].cohort],
          ),
        ],
      ],
    );
  }
}
