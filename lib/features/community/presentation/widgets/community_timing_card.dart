import 'package:flutter/material.dart';

import '../../../../core/date_format.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/community_models.dart';
import '../../data/community_stats.dart';
import '../community_display.dart';
import 'community_bars.dart';

/// "When · where you stand" (§7.2): the headline sentence plus the season
/// distribution with the reader's own week marked.
///
/// Everything is passed in rather than watched, so the card renders the same in
/// a test as on the device — including [today], which decides the "by now"
/// wording when the reader has not started yet.
class CommunityTimingCard extends StatelessWidget {
  const CommunityTimingCard({
    required this.curve,
    required this.mine,
    required this.today,
    super.key,
  });

  final SeasonCurve curve;
  final MySeason mine;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final myDate = mine.first?.toLocal();
    final myWeek = myDate == null ? null : isoWeek(myDate);
    final window = seasonWindow(curve, myWeek: myWeek);
    final (peakFrom, peakTo) = seasonPeakWeeks(curve);
    final year = today.year;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.community.detail.timing_kicker,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _headline(t, myWeek),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              [
                // Empty below kCommunityReliabilityMin — a thin sample gets the
                // band headline and the peak weeks, never a number.
                if (_detail(t, myDate, myWeek) case final line when line.isNotEmpty)
                  line,
                t.community.detail.peak_weeks(
                  from: formatDm(mondayOfIsoWeek(year, peakFrom)),
                  to: formatDm(mondayOfIsoWeek(year, peakTo)),
                ),
              ].join(' '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            CommunityBars(
              values: window.density,
              meIndex: window.myIndex,
              axis: _axis(window, year),
            ),
            const SizedBox(height: 10),
            Text(
              t.community.detail.among(n: curve.pooledTotal),
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            if (curve.censored) ...[
              const SizedBox(height: 6),
              Text(
                t.community.detail.censored_note,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Number when the sample carries one, descriptive band when it does not
  /// (§7.7) — never a precise-looking percentage over a thin sample.
  String _headline(Translations t, int? myWeek) {
    if (myWeek == null) return t.community.detail.not_started;
    final percent = seasonPercent(curve, myWeek);
    if (percent != null) return t.community.detail.you_percent(percent: percent);
    return communityTimingLabel(
      t,
      timingBand(seasonCdfForWeek(curve, myWeek)),
    );
  }

  String _detail(Translations t, DateTime? myDate, int? myWeek) {
    final week = myWeek ?? isoWeek(today);
    final percent = seasonPercent(curve, week);
    if (percent == null) return '';
    return myDate == null
        ? t.community.detail.by_now_percent(percent: percent)
        : t.community.detail.by_date_percent(
            date: formatDm(myDate),
            percent: percent,
          );
  }

  List<String> _axis(SeasonWindow window, int year) {
    final last = window.firstWeek + window.density.length - 1;
    final middle = window.firstWeek + (window.density.length - 1) ~/ 2;
    return [
      for (final week in {window.firstWeek, middle, last})
        formatDm(mondayOfIsoWeek(year, week)),
    ];
  }
}
