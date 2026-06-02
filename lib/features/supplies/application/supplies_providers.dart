import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../data/supplies_repository.dart';

part 'supplies_providers.g.dart';

@Riverpod(keepAlive: true)
SuppliesRepository suppliesRepository(Ref ref) {
  return SuppliesRepository(ref.watch(databaseProvider));
}

// Manual StreamProviders — riverpod_generator can't resolve drift part-file types.
final suppliesListProvider = StreamProvider.autoDispose<List<Supply>>((ref) {
  return ref.watch(suppliesRepositoryProvider).watchAll();
});

final taskSuppliesProvider =
    StreamProvider.autoDispose.family<List<TaskSupply>, String>((ref, taskId) {
  return ref.watch(suppliesRepositoryProvider).watchByTask(taskId);
});
