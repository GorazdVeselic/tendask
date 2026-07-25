import 'package:flutter/material.dart';

/// The one bar chart of the community screens: the season distribution and the
/// frequency distribution differ only in what they count, so they share this
/// widget rather than each growing its own copy.
///
/// [meIndex] is the reader's own bar, drawn in the accent colour — it is the
/// whole point of both charts ("where do I sit in this distribution").
class CommunityBars extends StatelessWidget {
  const CommunityBars({
    required this.values,
    required this.axis,
    this.meIndex,
    super.key,
  });

  final List<double> values;

  /// Labels spread under the chart, first to last. Two or three read best.
  final List<String> axis;
  final int? meIndex;

  static const _height = 88.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final peak = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < values.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        // A non-zero week still deserves a visible sliver.
                        height: peak <= 0
                            ? 2
                            : (values[i] / peak * _height).clamp(2.0, _height),
                        decoration: BoxDecoration(
                          color: i == meIndex ? cs.primary : cs.primaryContainer,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final label in axis)
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
