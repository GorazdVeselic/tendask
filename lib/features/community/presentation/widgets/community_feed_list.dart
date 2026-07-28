import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../data/community_models.dart';
import 'community_feed_row.dart';
import 'community_privacy_note.dart';
import 'teased_row_cards.dart';

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
    return ListView(
      // A short feed must still accept the pull-to-refresh gesture.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        CommunityFeedMeta(feed: feed),
        const SizedBox(height: 10),
        TeasedRowCards<CommunityFeedItem>(
          items: feed.items,
          hasPlus: hasPlus,
          rowBuilder: (item) => CommunityFeedRow(
            item: item,
            taskType: catalog[item.taskTypeId],
            plant: plants[item.cohort],
          ),
        ),
        const CommunityPrivacyNote(),
      ],
    );
  }
}
