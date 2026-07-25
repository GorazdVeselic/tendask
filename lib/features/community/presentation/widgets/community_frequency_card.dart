import 'package:flutter/material.dart';

import '../../../../core/config.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/community_models.dart';
import '../community_display.dart';
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
    final bands = _bands();

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
                communityFrequencyUnitLabel(t, stats.unit),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ] else
              Text(
                t.community.detail.freq_low_n,
                style: theme.textTheme.bodyMedium,
              ),
            if (bands.isNotEmpty) ...[
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

  /// Histogram bands in the server's order ('1'..'4', then '5+'); an unknown
  /// key from a future server sorts last rather than breaking the chart.
  List<String> _bands() {
    final bands = stats.hist.keys.toList()
      ..sort((a, b) => (int.tryParse(a) ?? 99).compareTo(int.tryParse(b) ?? 99));
    return bands;
  }

  /// Which bar is mine — the exact band, else the capped one the cron uses
  /// ('5+'). null when I have not done it, or the band is not in this histogram.
  int? _myIndex(List<String> bands) {
    if (myCount <= 0) return null;
    final index = bands.indexOf(
      bands.contains('$myCount') ? '$myCount' : '5+',
    );
    return index < 0 ? null : index;
  }

  /// Quartiles arrive as reals (percentile_cont interpolates); a gardener reads
  /// "2–4×", not "2.25–3.75×".
  String _round(double value) => value.round().toString();
}
