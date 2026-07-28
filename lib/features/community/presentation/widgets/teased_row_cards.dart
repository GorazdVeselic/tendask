import 'package:flutter/material.dart';

import 'tease_overlay.dart';

/// The free/Plus split both Okolica lists draw: the first row stays readable in
/// its own card, the rest sit blurred behind [TeaseOverlay] in a second one.
/// With Plus (or nothing to hide) it is a single plain card.
///
/// The two lists carry different row types, hence the generic — everything
/// below that (the divider between rows, the card shape, the 8 dp gap before
/// the teased half) was duplicated verbatim.
class TeasedRowCards<T> extends StatelessWidget {
  const TeasedRowCards({
    required this.items,
    required this.hasPlus,
    required this.rowBuilder,
    super.key,
  });

  final List<T> items;
  final bool hasPlus;
  final Widget Function(T item) rowBuilder;

  @override
  Widget build(BuildContext context) {
    final teased = !hasPlus && items.isNotEmpty;
    final visible = teased ? items.take(1).toList() : items;
    final hidden = teased ? items.skip(1).toList() : <T>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RowsCard(rows: [for (final item in visible) rowBuilder(item)]),
        if (teased)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TeaseOverlay(
              child: hidden.isEmpty
                  ? null
                  : _RowsCard(
                      rows: [for (final item in hidden) rowBuilder(item)],
                    ),
            ),
          ),
      ],
    );
  }
}

class _RowsCard extends StatelessWidget {
  const _RowsCard({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, indent: 56, color: cs.outlineVariant),
            rows[i],
          ],
        ],
      ),
    );
  }
}
