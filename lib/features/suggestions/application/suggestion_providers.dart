import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../data/suggestion_repository.dart';

part 'suggestion_providers.g.dart';

@Riverpod(keepAlive: true)
SuggestionRepository suggestionRepository(Ref ref) =>
    SuggestionRepository(ref.watch(databaseProvider));

/// Active suggestions for the Home band — drift stream, newest score first.
// Manual StreamProvider: riverpod_generator can't resolve the drift part-file
// `Suggestion` row type (same pattern as tasks_providers).
final activeSuggestionsProvider = StreamProvider.autoDispose<List<Suggestion>>((
  ref,
) {
  return ref.watch(suggestionRepositoryProvider).watchActive();
});
