import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/catalog_provider.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/load_error_hint.dart';
import '../../../i18n/translations.g.dart';
import '../application/community_providers.dart';
import 'widgets/community_explain_sheet.dart';
import 'widgets/community_feed_list.dart';

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
/// too few gardeners nearby yet or no slice cached while offline.
class _WeekTab extends ConsumerWidget {
  const _WeekTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final feed = ref.watch(communityFeedProvider);
    final catalog = ref.watch(taskTypesMapProvider);
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
    return switch ((feed, catalog)) {
      (AsyncData(value: null), _) => EmptyState(t.community.empty_feed),
      (AsyncData(:final value?), AsyncData(value: final types)) =>
        CommunityFeedList(
          feed: value,
          catalog: types,
          plants: plants,
          hasPlus: hasPlus,
        ),
      _ => const Center(child: CircularProgressIndicator.adaptive()),
    };
  }
}

/// "Where you stand" — your own timing per task type. The on-device percentile
/// arrives with M11.18 (step 7–8); until then there is nothing to list.
class _StandingTab extends StatelessWidget {
  const _StandingTab();

  @override
  Widget build(BuildContext context) {
    // TODO(gorazd, 2026-08-31): list task types with a season curve (M11.18).
    return EmptyState(context.t.community.empty_standing);
  }
}
