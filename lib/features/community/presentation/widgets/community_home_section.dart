import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/catalog_provider.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../i18n/translations.g.dart';
import '../../../plants/application/plants_providers.dart';
import '../../application/community_providers.dart';
import '../../data/community_cohort.dart';
import 'community_feed_row.dart';

/// "V tvoji okolici ⬡" above TODAY on Home — the proactive way into the tab
/// (skupnost-agregacija.md §12.1: this and the task detail are the main routes
/// of discovery; the tab itself is the third). One row from the feed slice the
/// repository already caches daily, so the section costs no extra request.
///
/// Renders nothing at all — no heading, no gap — until a row exists: a dashboard
/// must not carry a permanent empty hole, and a neighbourhood below the privacy
/// threshold has genuinely nothing to say. The tab reports load failures
/// properly; here they simply mean no hint today.
class CommunityHomeSection extends ConsumerWidget {
  const CommunityHomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final feed = ref.watch(communityFeedProvider).asData?.value;
    final catalog = ref.watch(taskTypesMapProvider).asData?.value ?? const {};
    final plants = ref.watch(plantsMapProvider).asData?.value ?? const {};
    final userPlants =
        ref.watch(userPlantsMapProvider).asData?.value ?? const {};

    if (feed == null) return const SizedBox.shrink();
    final hint = pickHomeHint(feed.items, {
      for (final userPlant in userPlants.values) ?catalogPlantOf(userPlant),
    });
    if (hint == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(
          '${t.community.entry.section} ⬡',
          padding: const EdgeInsets.only(bottom: 8),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: CommunityFeedRow(
            item: hint,
            taskType: catalog[hint.taskTypeId],
            plant: plants[hint.cohort],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CommunityFeedMeta(feed: feed),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.goNamed('community'),
            child: Text('${t.community.entry.see_all} ›'),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
