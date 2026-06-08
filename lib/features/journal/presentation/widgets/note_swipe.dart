import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/swipe_actions.dart';
import '../../../../i18n/translations.g.dart';
import '../../application/notes_providers.dart';

/// Wraps a journal note row in the shared reveal-swipe: edit (opens the note
/// editor) and delete (with confirmation).
class NoteSwipe extends ConsumerWidget {
  const NoteSwipe({required this.note, required this.child, super.key});

  final Note note;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final repo = ref.read(notesRepositoryProvider);
    return SwipeRow(
      itemKey: note.id,
      actions: [
        editSwipe(
          context,
          () => context.pushNamed('note-edit', pathParameters: {'id': note.id}),
        ),
        deleteSwipe(
          context,
          title: t.notes.delete,
          body: t.notes.delete_confirm,
          onConfirmed: () => repo.softDelete(note.id),
        ),
      ],
      child: child,
    );
  }
}
