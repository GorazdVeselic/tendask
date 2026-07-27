import 'package:flutter/material.dart';

import '../../../../core/config.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/community_models.dart';
import 'community_bars.dart';

/// "How often" (§7.3): the typical range among performers plus the distribution
/// of how many times each of them did it, with the reader's own count marked.
class CommunityFrequencyCard extends StatelessWidget {
  const CommunityFrequencyCard({
    required this.stats,
    required this.myCount,
    super.key,
  });

  final FrequencyStats stats;
  final int myCount;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // Always the full band set: the aggregate omits bands nobody landed in, so
    // reading the chart off the published keys drew a gapped distribution as a
    // continuous one — and dropped the reader's own bar onto the wrong band.
    const bands = kCommunityFrequencyBands;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.community.detail.frequency_title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            if (stats.nUsers >= kCommunityReliabilityMin) ...[
              Text(
                t.community.detail.freq_range(
                  from: _round(stats.p25),
                  to: _round(stats.p75),
                ),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                // The nightly cron counts whole seasons (migration 0009); a
                // per-month unit would also need my own count normalised, so it
                // arrives together with that, not before.
                t.community.detail.freq_unit,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ] else
              Text(
                t.community.detail.freq_low_n,
                style: theme.textTheme.bodyMedium,
              ),
            if (stats.hist.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                t.community.detail.freq_caption,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              CommunityBars(
                values: [
                  for (final band in bands)
                    (stats.hist[band] ?? 0).toDouble(),
                ],
                meIndex: _myIndex(bands),
                // Every band is labelled: with only the ends, the bar the
                // reader cares about most (their own) would be unreadable.
                axis: bands,
              ),
            ],
            const SizedBox(height: 10),
            Text(
              t.community.detail.among(n: stats.nUsers),
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Which bar is mine — the exact band, or the capped one the cron uses ('5+').
  /// null when I have not done it at all.
  int? _myIndex(List<String> bands) {
    if (myCount <= 0) return null;
    final index = bands.indexOf(myCount >= 5 ? '5+' : '$myCount');
    return index < 0 ? null : index;
  }

  /// Quartiles arrive as reals (percentile_cont interpolates); a gardener reads
  /// "2–4×", not "2.25–3.75×".
  String _round(double value) => value.round().toString();
}
