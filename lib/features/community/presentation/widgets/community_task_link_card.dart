import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../i18n/translations.g.dart';
import '../../application/community_providers.dart';
import '../../data/community_stats.dart';
import '../community_display.dart';

/// "V tvoji okolici" on a task detail (screen-map §2.2, wireframe A2): the
/// contextual way from a task the reader just logged into the same per-task
/// template every entry point leads to (§12.1).
///
/// With Plus the headline already carries where they stand; without it the card
/// is a plain way in and fetches nothing — the answer itself is the paid part
/// (§12.5), and the destination does the teasing.
class CommunityTaskLinkCard extends ConsumerWidget {
  const CommunityTaskLinkCard({
    required this.taskTypeId,
    required this.cohort,
    super.key,
  });

  final String taskTypeId;

  /// [kCommunityCohortSite] or the catalog plant id — see [cohortOfSubjects].
  final String cohort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final headline = ref.watch(hasPlusProvider)
        ? _standing(ref, t)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(t.community.entry.section),
        Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: ListTile(
            onTap: () => context.pushNamed(
              'community-task',
              pathParameters: {'taskTypeId': taskTypeId},
              queryParameters: {
                if (cohort != kCommunityCohortSite) 'plant': cohort,
              },
            ),
            leading: Icon(
              Icons.hexagon_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              headline ?? t.community.entry.cta,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: headline == null
                    ? FontWeight.w400
                    : FontWeight.w700,
              ),
            ),
            subtitle: headline == null
                ? null
                : Text(
                    t.community.entry.cta,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ],
    );
  }

  /// Where the reader stands, or null while it resolves / when no level of the
  /// cohort cleared the privacy threshold. Same wording as the detail screen.
  String? _standing(WidgetRef ref, Translations t) {
    final curve = ref
        .watch(communitySeasonCurveProvider(taskTypeId, cohort))
        .asData
        ?.value;
    if (curve == null) return null;
    final mine = ref.watch(mySeasonProvider(taskTypeId, cohort)).asData?.value;
    final first = mine?.first;
    return communityTimingHeadline(
      t,
      curve,
      first == null ? null : isoWeek(first.toLocal()),
    );
  }
}
