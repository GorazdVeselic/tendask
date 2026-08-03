import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_icons.dart';
import '../../../core/date_format.dart';
import '../../../core/glyphs.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../application/plus_provider.dart';
import '../application/plus_token.dart';
import 'plus_label.dart';

/// The Tendask+ screen (FR-20, wireframe board 2): what the entitlement grants
/// and how long it lasts, plus the list of features it unlocks.
///
/// It is also the second way into the moon calendar settings, the one that does
/// not depend on the moon switch itself — turning that switch off would
/// otherwise be one-way (plan T6 step 5).
///
/// Nothing here may lead towards a purchase (FR-20 §3.1): no price, no address,
/// no hint where a code comes from. Code entry arrives with T8.
class TendaskPlusScreen extends ConsumerWidget {
  const TendaskPlusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final statusAsync = ref.watch(plusProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(kIconArrowBack),
          onPressed: context.pop,
        ),
        title: const PlusTitle(),
        centerTitle: true,
      ),
      body: statusAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (_, _) => Center(child: Text(t.plus.load_error)),
        data: (status) => PlusScreenBody(status: status),
      ),
    );
  }
}

/// The screen's content for a given entitlement — public so previews, tests and
/// the layout matrix can render both states without a database behind them.
class PlusScreenBody extends StatelessWidget {
  const PlusScreenBody({super.key, required this.status});

  final PlusStatus status;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _StatusCard(status),
        if (!status.isActive)
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 10, 2, 0),
            child: Text(
              t.plus.tagline,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),

        SectionLabel(t.plus.features_label),
        Card(
          child: Column(
            children: [
              _FeatureTile(
                glyph: kGlyphMoon,
                title: t.plus.moon,
                subtitle: t.plus.moon_sub,
                // The settings are only worth opening once the calendar is
                // unlocked; without Plus the row stays a description.
                onTap: status.isActive
                    ? () => context.pushNamed('moon-settings')
                    : null,
              ),
              _FeatureTile(
                glyph: kGlyphAreaBed,
                title: t.plus.multi_garden,
                subtitle: t.plus.soon,
                dimmed: true,
              ),
              _FeatureTile(
                glyph: kGlyphAnalytics,
                title: t.plus.analytics,
                subtitle: t.plus.soon,
                dimmed: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Whether the entitlement is running and until when — the wireframe's tinted
/// "active" banner, or a calm neutral row when there is none.
class _StatusCard extends StatelessWidget {
  const _StatusCard(this.status);

  final PlusStatus status;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    if (!status.isActive) {
      return Card(
        child: ListTile(
          leading: Icon(kPlusMarkIcon, color: theme.colorScheme.onSurfaceVariant),
          title: const Text(kPlusLabel),
          subtitle: Text(t.plus.inactive),
        ),
      );
    }

    final until = status.until;
    // A lifetime grant has no useful date to show (FR-20 §6.2 caps the token at
    // a year, so its expiry would read as an end that is not one).
    final line = status.kind == kPlusKindLifetime || until == null
        ? t.plus.active_lifetime
        : t.plus.active_until(date: formatDmy(until.toLocal()));
    final onContainer = theme.colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(kIconCheckCircle, color: onContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kPlusLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: onContainer,
                  ),
                ),
                Text(
                  line,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: onContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One feature row. [dimmed] marks a feature that does not exist yet ("Soon"),
/// which is a different thing from a feature that is merely locked.
class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.glyph,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.dimmed = false,
  });

  final String glyph;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      leading: Text(glyph, style: const TextStyle(fontSize: 22)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap == null ? null : const Icon(kIconChevronRight),
      onTap: onTap,
    );
    return dimmed ? Opacity(opacity: 0.5, child: tile) : tile;
  }
}
