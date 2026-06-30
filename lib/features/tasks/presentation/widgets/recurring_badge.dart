import 'package:flutter/material.dart';

import '../../../../i18n/translations.g.dart';

/// Small "repeats" marker shown next to a recurring task in lists (FR-5). One
/// source for the icon + tooltip so every list reads the same.
class RecurringBadge extends StatelessWidget {
  const RecurringBadge({super.key});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: context.t.tasks_list.recurring_badge_tooltip,
    child: Icon(
      Icons.repeat,
      size: 15,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}
