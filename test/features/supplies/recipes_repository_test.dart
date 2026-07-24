import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/features/supplies/data/recipe_item.dart';
import 'package:tendask/features/supplies/data/recipes_repository.dart';

class _FakeClock implements Clock {
  _FakeClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

void main() {
  late AppDatabase db;
  late RecipesRepository recipes;

  const userId = 'user-1';
  final t0 = DateTime.utc(2026, 6, 30, 8);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    recipes = RecipesRepository(db, clock: _FakeClock(t0));
  });

  tearDown(() async => db.close());

  test('create stores name, equipment and items', () async {
    final id = await recipes.create(
      userId: userId,
      name: 'Spring mix',
      equipment: '16 L sprayer',
      items: const [
        RecipeItem(supplyId: 'urea', amount: 100),
        RecipeItem(supplyId: 'algae', amount: 50),
      ],
    );
    final r = await recipes.byId(id);
    expect(r!.name, 'Spring mix');
    expect(r.equipment, '16 L sprayer');
    expect(parseRecipeItems(r.items), const [
      RecipeItem(supplyId: 'urea', amount: 100),
      RecipeItem(supplyId: 'algae', amount: 50),
    ]);
  });

  test('update replaces items', () async {
    final id = await recipes.create(
      userId: userId,
      name: 'Mix',
      items: const [RecipeItem(supplyId: 'a', amount: 1)],
    );
    await recipes.update(
      id: id,
      name: 'Mix',
      equipment: null,
      items: const [RecipeItem(supplyId: 'b', amount: 2)],
    );
    expect(parseRecipeItems((await recipes.byId(id))!.items), const [
      RecipeItem(supplyId: 'b', amount: 2),
    ]);
  });

  test('softDelete hides it from watchAll', () async {
    final id = await recipes.create(userId: userId, name: 'Mix');
    await recipes.softDelete(id);
    expect(await recipes.watchAll().first, isEmpty);
    expect((await recipes.byId(id))!.deleted, true); // soft, still present
  });
}
