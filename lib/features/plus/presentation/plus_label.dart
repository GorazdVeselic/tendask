import 'package:flutter/widgets.dart';

import '../../../core/app_icons.dart';

/// The product name. Not translated — a brand name reads the same in every
/// locale — so it lives here rather than in the i18n files.
const kPlusLabel = 'Tendask+';

/// The "✦" mark of screen-map §4, drawn as an icon rather than a text glyph:
/// Plus Jakarta Sans has no ✦ and fell back to a stand-in box. It appears once
/// per surface — never in [kPlusLabel] as well, or every card carries it twice.
const kPlusMarkIcon = kIconAutoAwesome;

/// The mark and the name side by side, for surfaces with no leading slot of
/// their own (the app bar title).
class PlusTitle extends StatelessWidget {
  const PlusTitle({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(kPlusMarkIcon, size: 18),
      SizedBox(width: 6),
      Flexible(child: Text(kPlusLabel)),
    ],
  );
}
