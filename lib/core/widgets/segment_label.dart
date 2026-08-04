import 'package:flutter/material.dart';

/// Text inside a [SegmentedButton] segment. Segments split the available width
/// between them, so a label that is one long word ("Tedensko", "Opravljeno",
/// German anything) breaks mid-word as soon as the row is tight — at 360 px, at
/// large text sizes, or with four segments. Scaling it down instead keeps every
/// segment on one line; ordinary sizes are untouched, because `scaleDown` never
/// enlarges.
class SegmentLabel extends StatelessWidget {
  const SegmentLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(text, maxLines: 1, softWrap: false),
  );
}
