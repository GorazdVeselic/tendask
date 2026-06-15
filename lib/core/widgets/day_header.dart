import 'package:flutter/material.dart';

import '../../i18n/translations.g.dart';
import '../date_format.dart';

/// Date heading above a day group in a timeline (journal, suggestion history):
/// "Today"/"Yesterday" for the two most recent days, otherwise the full date.
/// Muted — the single day-group heading style across the app.
class DayHeader extends StatelessWidget {
  const DayHeader(this.date, {super.key});

  /// Already-localized date (the caller passes `.toLocal()`).
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final today = startOfDay(DateTime.now());
    final d = startOfDay(date);

    final String label;
    if (d == today) {
      label = t.common.today;
    } else if (d == today.subtract(const Duration(days: 1))) {
      label = t.common.yesterday;
    } else {
      label = formatDmy(date);
    }

    return Text(
      label,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
