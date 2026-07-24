import 'package:flutter/material.dart';

import '../../../../../i18n/translations.g.dart';
import '../entry_flow.dart';

/// "Korak 2 · Za kaj" — the step's number comes from its position in the active
/// flow, not from the enum (conditional steps shift it).
class EntryStepTitle extends StatelessWidget {
  const EntryStepTitle({
    super.key,
    required this.step,
    required this.position,
  });

  final EntryStep step;
  final int position;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final n = position + 1;
    final text = switch (step) {
      EntryStep.type => '${t.entry.step} $n · ${t.entry.type_title}',
      EntryStep.subject => '${t.entry.step} $n · ${t.entry.subject_title}',
      EntryStep.when => '${t.entry.step} $n · ${t.entry.when_title}',
      EntryStep.reminder =>
        '${t.entry.step} $n · ${t.entry.reminder_title} ${t.entry.optional}',
      EntryStep.supplies =>
        '${t.entry.step} $n · ${t.entry.supplies_title} ${t.entry.optional}',
      EntryStep.review => t.entry.review_title,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
