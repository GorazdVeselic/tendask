import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../data/notes_repository.dart';

part 'notes_providers.g.dart';

@Riverpod(keepAlive: true)
NotesRepository notesRepository(Ref ref) {
  return NotesRepository(ref.watch(databaseProvider));
}

// Manual StreamProvider — riverpod_generator can't resolve drift part-file types.
final notesProvider = StreamProvider.autoDispose<List<Note>>((ref) {
  return ref.watch(notesRepositoryProvider).watchAll();
});
