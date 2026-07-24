import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/date_format.dart';

/// A standalone note in the timeline.
class NoteEntryTile extends StatelessWidget {
  const NoteEntryTile({super.key, required this.note, required this.area});

  final Note note;
  final Area? area;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final noteArea = area;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: const Text('✍️', style: TextStyle(fontSize: 18)),
      ),
      title: Text(
        note.content,
        style: theme.textTheme.bodyMedium,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: noteArea != null
          ? Text(
              '🪴 ${noteArea.name}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Text(
        formatHm(note.date.toLocal()),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: () =>
          context.pushNamed('note-edit', pathParameters: {'id': note.id}),
    );
  }
}
