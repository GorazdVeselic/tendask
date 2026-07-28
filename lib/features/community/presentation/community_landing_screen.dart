import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/catalog_provider.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/load_error_hint.dart';
import '../../../i18n/translations.g.dart';
import '../application/community_providers.dart';
import 'widgets/community_explain_sheet.dart';
import 'widgets/community_feed_list.dart';
import 'widgets/community_standing_list.dart';

/// Okolica (5th tab, ⬡ = H3 cell): what gardeners around you are doing. Two
/// views of the same aggregates (skupnost-agregacija.md §12.1) — "This week"
/// (qualitative feed) and "Where you stand" (your own timing per task type).
/// Reads only from providers; the daily slice and its offline cache live in
/// CommunityRepository.
class CommunityLandingScreen extends StatefulWidget {
  const CommunityLandingScreen({super.key});

  @override
  State<CommunityLandingScreen> createState() => _CommunityLandingScreenState();
}

enum _Segment { week, you }

class _CommunityLandingScreenState extends State<CommunityLandingScreen> {
  _Segment _segment = _Segment.week;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Text(
          t.community.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: t.community.detail.explain.cta,
            onPressed: () => showCommunityExplainSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: SegmentedButton<_Segment>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: _Segment.week,
                  label: Text(t.community.seg_week),
                ),
                ButtonSegment(
                  value: _Segment.you,
                  label: Text(t.community.seg_you),
                ),
              ],
              selected: {_segment},
              onSelectionChanged: (s) => setState(() => _segment = s.first),
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),
          ),
          Expanded(
            child: switch (_segment) {
              _Segment.week => const _WeekTab(),
              _Segment.you => const _StandingTab(),
            },
          ),
        ],
      ),
    );
  }
}

/// "This week" — the feed for the finest bucket that cleared the privacy
/// threshold. A null feed is the honest cold-start state, not an error: either
/// too few gardeners nearby yet or no slice cached while offline — and the two
/// say very different things, so [communityReachedProvider] tells them apart.
class _WeekTab extends ConsumerWidget {
  const _WeekTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final feed = ref.watch(communityFeedProvider);
    final catalog = ref.watch(taskTypesMapProvider);
    final reached = ref.watch(communityReachedProvider);
    // Plant labels name the cohort of a row ("Pruning · apple"), so an empty
    // plant map only costs the subtitle, never the row.
    final plants = ref.watch(plantsMapProvider).asData?.value ?? const {};
    final hasPlus = ref.watch(hasPlusProvider);

    // The repository already degrades gracefully offline, so an error on either
    // side is a local read/decode bug — show it quietly instead of leaving a
    // spinner that never resolves.
    if (feed.hasError || catalog.hasError) {
      return LoadErrorHint(t.common.load_error);
    }
    return RefreshIndicator(
      onRefresh: () => _refreshCommunity(ref),
      child: switch ((feed, catalog, reached)) {
        (AsyncData(value: null), _, AsyncData(value: false)) => PullableEmpty(
          t.community.empty_offline,
        ),
        (AsyncData(value: null), _, AsyncData()) => PullableEmpty(
          t.community.empty_feed,
        ),
        (AsyncData(:final value?), AsyncData(value: final types), _) =>
          CommunityFeedList(
            feed: value,
            catalog: types,
            plants: plants,
            hasPlus: hasPlus,
          ),
        _ => const Center(child: CircularProgressIndicator.adaptive()),
      },
    );
  }
}

/// Re-reads the daily slices. A no-op when today's are already cached — the
/// gesture earns its keep exactly when the device was offline earlier.
Future<void> _refreshCommunity(WidgetRef ref) async {
  // Invalidating alone re-runs the providers against the same day-cached slice,
  // so the spinner turns and nothing changes until midnight.
  ref.read(communityRepositoryProvider).requestRefresh();
  ref.invalidate(communityFeedProvider);
  ref.invalidate(communityReachedProvider);
  ref.invalidate(communityStandingsProvider);
  await ref.read(communityFeedProvider.future);
}

/// "Where you stand" — the cohorts you worked this season, each placed against
/// its group's curve. Cohorts the neighbourhood cannot answer for are left out,
/// so an empty list is the honest cold-start, not an error.
class _StandingTab extends ConsumerWidget {
  const _StandingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final standings = ref.watch(communityStandingsProvider);
    final catalog = ref.watch(taskTypesMapProvider);
    final reached = ref.watch(communityReachedProvider);
    final plants = ref.watch(plantsMapProvider).asData?.value ?? const {};
    final hasPlus = ref.watch(hasPlusProvider);

    if (standings.hasError || catalog.hasError) {
      return LoadErrorHint(t.common.load_error);
    }
    return RefreshIndicator(
      onRefresh: () => _refreshCommunity(ref),
      child: switch ((standings, catalog, reached)) {
        (AsyncData(value: final rows), AsyncData(value: final types), _)
            when rows.isNotEmpty =>
          CommunityStandingList(
            standings: rows,
            catalog: types,
            plants: plants,
            hasPlus: hasPlus,
          ),
        (AsyncData(), AsyncData(), AsyncData(value: false)) => PullableEmpty(
          t.community.empty_offline,
        ),
        (AsyncData(), AsyncData(), AsyncData()) => PullableEmpty(
          t.community.empty_standing,
        ),
        _ => const Center(child: CircularProgressIndicator.adaptive()),
      },
    );
  }
}
