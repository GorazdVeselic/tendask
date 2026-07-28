import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/catalog_labels.dart';
import '../../../../core/config.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/community_models.dart';
import '../community_display.dart';
import 'community_privacy_note.dart';
import 'teased_row_cards.dart';

/// "Kje si ti" (§7.2, wireframe B2): the cohorts I worked this season, each
/// placed against its group's curve as early / usual / late. The number behind
/// the band lives on the detail screen, where the sample size and the first-year
/// caveat sit right next to it (§7.7) — a bare percentage in a scan list would
/// be a figure without its denominator.
///
/// Without Plus only the first row stays readable, exactly as "This week" does.
class CommunityStandingList extends StatelessWidget {
  const CommunityStandingList({
    required this.standings,
    required this.catalog,
    required this.plants,
    required this.hasPlus,
    super.key,
  });

  final List<CommunityStanding> standings;
  final Map<String, TaskType> catalog;
  final Map<String, Plant> plants;
  final bool hasPlus;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return ListView(
      // A short list must still accept the pull-to-refresh gesture.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        Text(
          t.community.standing.meta,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        TeasedRowCards<CommunityStanding>(
          items: standings,
          hasPlus: hasPlus,
          rowBuilder: (standing) => _StandingRow(
            standing: standing,
            taskType: catalog[standing.taskTypeId],
            plant: plants[standing.cohort],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
          child: Text(
            t.community.standing.footnote,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const CommunityPrivacyNote(),
      ],
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({
    required this.standing,
    required this.taskType,
    this.plant,
  });

  final CommunityStanding standing;
  final TaskType? taskType;
  final Plant? plant;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final type = taskType;
    final subject = plant;
    // Each cohort resolved its own level, so the scope belongs on the row — the
    // screen cannot claim one for the whole list (§7.4).
    final subtitle = [
      ?subject == null ? null : catalogLabel(subject.labels),
      communityScopeLabel(t, standing.scope),
    ].join(' · ');

    return ListTile(
      onTap: () => context.pushNamed(
        'community-task',
        pathParameters: {'taskTypeId': standing.taskTypeId},
        queryParameters: {
          if (standing.cohort != kCommunityCohortSite) 'plant': standing.cohort,
        },
      ),
      leading: Text(
        subject?.icon ?? type?.icon ?? '🌱',
        style: const TextStyle(fontSize: 22),
      ),
      title: Text(
        type == null ? standing.taskTypeId : catalogLabel(type.labels),
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: _BandPill(standing.band),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

/// Early / usual / late in the same pill vocabulary the feed uses for intensity,
/// so one glance down the tab reads as one scale.
class _BandPill extends StatelessWidget {
  const _BandPill(this.band);

  final CommunityTiming band;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (Color? bg, Color fg) = switch (band) {
      CommunityTiming.early => (cs.primaryContainer, cs.onPrimaryContainer),
      CommunityTiming.typical => (
        cs.secondaryContainer,
        cs.onSecondaryContainer,
      ),
      CommunityTiming.late => (null, cs.onSurfaceVariant),
    };
    return StatusPill(
      label: communityStandingBandLabel(context.t, band),
      background: bg,
      foreground: fg,
    );
  }
}
