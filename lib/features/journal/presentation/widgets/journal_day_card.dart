import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../i18n/translations.g.dart';
import '../../../tasks/presentation/widgets/task_swipe.dart';
import '../journal_entry.dart';
import '../journal_timeline.dart';
import 'note_entry_tile.dart';
import 'note_swipe.dart';
import 'task_entry_tile.dart';

/// One day of the timeline: its heading and a card of that day's entries.
class JournalDayCard extends StatelessWidget {
  const JournalDayCard({
    super.key,
    required this.group,
    required this.now,
    required this.catalog,
    required this.areas,
    required this.subjectLabels,
  });

  final JournalDayGroup group;
  final DateTime now;
  final Map<String, TaskType> catalog;
  final Map<String, Area> areas;
  final Map<String, String> subjectLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = group.entries;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            journalDayLabel(group.date, now, context.t),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  switch (entries[i]) {
                    TaskJournalEntry(:final task) => TaskSwipe(
                      task: task,
                      child: TaskEntryTile(
                        task: task,
                        taskType: catalog[task.taskTypeId],
                        subjectLabel: subjectLabels[task.id],
                      ),
                    ),
                    NoteJournalEntry(:final note) => NoteSwipe(
                      note: note,
                      child: NoteEntryTile(
                        note: note,
                        area: note.areaId != null ? areas[note.areaId] : null,
                      ),
                    ),
                  },
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
