import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_status.dart';
import 'recipe_item.dart';

/// Saved supply mixtures (recipes): a named set of supply+amount items, bound to
/// optional equipment (e.g. "16L sprayer"). Used to prefill a task's supplies.
class RecipesRepository {
  RecipesRepository(this._db, {this._clock = const SystemClock()});

  final AppDatabase _db;
  final Clock _clock;
  final _uuid = const Uuid();

  Stream<List<Recipe>> watchAll() =>
      (_db.select(_db.recipes)
            ..where((r) => r.deleted.equals(false))
            ..orderBy([(r) => OrderingTerm.asc(r.name)]))
          .watch();

  Future<Recipe?> byId(String id) =>
      (_db.select(_db.recipes)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<String> create({
    required String userId,
    required String name,
    String? equipment,
    List<RecipeItem> items = const [],
  }) async {
    final id = _uuid.v4();
    await _db
        .into(_db.recipes)
        .insert(
          RecipesCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            equipment: Value(equipment),
            items: Value(encodeRecipeItems(items)),
            updatedAt: _clock.now(),
          ),
        );
    return id;
  }

  Future<void> update({
    required String id,
    required String name,
    String? equipment,
    required List<RecipeItem> items,
  }) async {
    await (_db.update(_db.recipes)..where((r) => r.id.equals(id))).write(
      RecipesCompanion(
        name: Value(name),
        equipment: Value(equipment),
        items: Value(encodeRecipeItems(items)),
        updatedAt: Value(_clock.now()),
        syncStatus: const Value(kSyncPending),
      ),
    );
  }

  Future<void> softDelete(String id) async {
    await (_db.update(_db.recipes)..where((r) => r.id.equals(id))).write(
      RecipesCompanion(
        deleted: const Value(true),
        updatedAt: Value(_clock.now()),
        syncStatus: const Value(kSyncPending),
      ),
    );
  }
}
