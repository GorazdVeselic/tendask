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

/// One user plant by id — for the plant detail screen.
final userPlantByIdProvider =
    StreamProvider.autoDispose.family<UserPlant?, String>((ref, id) {
  return ref.watch(userPlantsRepositoryProvider).watchById(id);
});

/// All user plants keyed by id — for resolving plant subject labels.
final userPlantsMapProvider =
    StreamProvider.autoDispose<Map<String, UserPlant>>((ref) {
  return ref
      .watch(userPlantsRepositoryProvider)
      .watchAll()
      .map((list) => {for (final p in list) p.id: p});
});

/// Recently used catalog species (ids) for the "Frequent" row on the plant-add
/// screen. Re-fetches when the plant set changes so fresh picks bubble up.
final recentPlantsProvider = FutureProvider.autoDispose<List<String>>((ref) {
  ref.watch(userPlantsMapProvider);
  return ref.watch(userPlantsRepositoryProvider).recentPlantIds();
});
