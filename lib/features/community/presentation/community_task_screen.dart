import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/catalog_labels.dart';
import '../../../core/config.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/widgets/load_error_hint.dart';
import '../../../i18n/translations.g.dart';
import '../application/community_providers.dart';
import '../data/community_models.dart';
import 'community_display.dart';
import 'widgets/community_explain_sheet.dart';
import 'widgets/community_frequency_card.dart';
import 'widgets/community_privacy_note.dart';
import 'widgets/community_timing_card.dart';
import 'widgets/tease_overlay.dart';

/// One task type inside ONE comparison cohort: when people around you start it,
/// how often they do it, and what happened this week (skupnost-agregacija.md
/// §12.1 — every entry point lands on this same template with different data).
///
/// [plantId] names the cohort; absent means site work (lawn, bed, a private
/// custom plant). The cohort is never swapped for a busier one — only the
/// geography widens, which is why a screen can legitimately end up empty (§7.4).
class CommunityTaskScreen extends ConsumerWidget {
  const CommunityTaskScreen({required this.taskTypeId, this.plantId, super.key});

  final String taskTypeId;
  final String? plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final cohort = plantId ?? kCommunityCohortSite;
    final catalog = ref.watch(taskTypesMapProvider);
    final plants = ref.watch(plantsMapProvider).asData?.value ?? const {};
    final curve = ref.watch(communitySeasonCurveProvider(taskTypeId, cohort));
    final frequency = ref.watch(communityFrequencyProvider(taskTypeId, cohort));
    final weekly = ref.watch(communityWeeklyProvider(taskTypeId, cohort));
    final mine = ref.watch(mySeasonProvider(taskTypeId, cohort));
    final reached = ref.watch(communityReachedProvider);
    final hasPlus = ref.watch(hasPlusProvider);

    final taskType = catalog.asData?.value[taskTypeId];
    final plant = plants[cohort];
    final title = taskType == null
        ? taskTypeId
        : catalogLabel(taskType.labels);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: t.community.detail.explain.cta,
            onPressed: () => showCommunityExplainSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Without this the invalidated providers re-read the same day-cached
          // slice and the gesture changes nothing (see the landing screen).
          ref.read(communityRepositoryProvider).requestRefresh();
          ref.invalidate(communityReachedProvider);
          ref.invalidate(communitySeasonCurveProvider(taskTypeId, cohort));
          ref.invalidate(communityFrequencyProvider(taskTypeId, cohort));
          ref.invalidate(communityWeeklyProvider(taskTypeId, cohort));
          await ref.read(
            communitySeasonCurveProvider(taskTypeId, cohort).future,
          );
        },
        child: switch ((curve, frequency, weekly, mine)) {
          (AsyncError(), _, _, _) ||
          (_, AsyncError(), _, _) ||
          (_, _, AsyncError(), _) ||
          (_, _, _, AsyncError()) => LoadErrorHint(t.common.load_error),
          (
            AsyncData(value: final seasonCurve),
            AsyncData(value: final stats),
            AsyncData(value: final thisWeek),
            AsyncData(value: final myRecord),
          ) =>
            _Body(
              subject: plant == null ? null : catalogLabel(plant.labels),
              icon: plant?.icon ?? taskType?.icon ?? '🌱',
              curve: seasonCurve,
              stats: stats,
              weekly: thisWeek,
              mine: myRecord,
              hasPlus: hasPlus,
              // Unknown while it loads: the cold-start line waits rather than
              // guessing which of the two truths to tell.
              reached: reached.asData?.value ?? true,
            ),
          _ => const Center(child: CircularProgressIndicator.adaptive()),
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.subject,
    required this.icon,
    required this.curve,
    required this.stats,
    required this.weekly,
    required this.mine,
    required this.hasPlus,
    required this.reached,
  });

  final String? subject;
  final String icon;
  final SeasonCurve? curve;
  final FrequencyStats? stats;
  final CommunityWeekly? weekly;
  final MySeason mine;
  final bool hasPlus;
  final bool reached;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final season = curve;
    final frequency = stats;
    final week = weekly;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (season != null) ...[
          CommunityTimingCard(
            curve: season,
            mine: mine,
            today: DateTime.now(),
          ),
          const SizedBox(height: 12),
        ],
        if (frequency != null) ...[
          CommunityFrequencyCard(stats: frequency, myCount: mine.count),
          const SizedBox(height: 12),
        ],
        if (week != null)
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Text('🔥', style: TextStyle(fontSize: 20)),
              title: Text(
                communityThisWeekLabel(t, week.intensity),
                style: theme.textTheme.bodyMedium,
              ),
              subtitle: Text(
                '${t.community.window_7d} · '
                '${communityScopeLabel(t, week.bucket.resolution)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
        // Everything null is the honest cold-start, not an error: this cohort
        // has too few gardeners at any level (§7.4) — unless the device has
        // never read the scope at all, which says nothing about the cohort.
        if (season == null && frequency == null && week == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              reached ? t.community.detail.no_curve : t.community.empty_offline,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );

    return ListView(
      // A short detail must still accept the pull-to-refresh gesture.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _Header(icon: icon, subject: subject, scope: _scopeLabel(t)),
        const SizedBox(height: 12),
        // Without Plus the detail is teased whole: unlike the landing feed there
        // is no first row worth giving away (screen-map §1.5).
        if (hasPlus) content else TeaseOverlay(child: content),
        const CommunityPrivacyNote(),
      ],
    );
  }

  /// The curve decides the headline scope; the "this week" row carries its own,
  /// because fewer gardeners are active in any single week.
  String? _scopeLabel(Translations t) {
    final resolution = curve?.bucket.resolution ?? stats?.bucket.resolution;
    return resolution == null ? null : communityScopeLabel(t, resolution);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.icon, this.subject, this.scope});

  final String icon;
  final String? subject;
  final String? scope;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final line = [?subject, ?scope].join(' · ');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 26)),
        const SizedBox(width: 10),
        if (line.isNotEmpty)
          Expanded(
            child: Text(
              line,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
