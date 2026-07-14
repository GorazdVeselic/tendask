import 'package:flutter/material.dart';

import '../../../../i18n/translations.g.dart';
import '../journal_timeline.dart';

/// The all / tasks / notes chips above the timeline.
class JournalFilterBar extends StatelessWidget {
  const JournalFilterBar({
    super.key,
    required this.filter,
    required this.onChanged,
  });

  final JournalFilter filter;
  final ValueChanged<JournalFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _Chip(
            label: t.journal.filter_all,
            selected: filter == JournalFilter.all,
            onTap: () => onChanged(JournalFilter.all),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: t.journal.filter_tasks,
            selected: filter == JournalFilter.tasks,
            onTap: () => onChanged(JournalFilter.tasks),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: t.journal.filter_notes,
            selected: filter == JournalFilter.notes,
            onTap: () => onChanged(JournalFilter.notes),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
