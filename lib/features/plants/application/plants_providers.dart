import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../data/user_plants_repository.dart';

part 'plants_providers.g.dart';

@Riverpod(keepAlive: true)
UserPlantsRepository userPlantsRepository(Ref ref) {
  return UserPlantsRepository(ref.watch(databaseProvider));
}

// Manual StreamProvider — riverpod_generator can't resolve drift part-file types.
final userPlantsByAreaProvider =
    StreamProvider.autoDispose.family<List<UserPlant>, String>((ref, areaId) {
  return ref.watch(userPlantsRepositoryProvider).watchByArea(areaId);
});
