import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/features/supplies/data/recipe_item.dart';
import 'package:tendask/features/supplies/data/recipes_repository.dart';
import 'package:tendask/features/supplies/data/supplies_repository.dart';
import 'package:tendask/features/supplies/data/supply_spec.dart';
import 'package:tendask/features/tasks/data/tasks_repository.dart';

class _FakeClock implements Clock {
  _FakeClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

/// End-to-end (in-memory drift): a saved recipe prefills a task's supplies and
/// deducting on completion draws each supply's stock down by the recipe amount.
void main() {
  late AppDatabase db;
  late SuppliesRepository supplies;
  late RecipesRepository recipes;
  late TasksRepository tasks;

  const userId = 'user-1';
  const areaId = 'area-1';
  final t0 = DateTime.utc(2026, 6, 30, 8);
  late String ureaId;
  late String algaeId;
  late String taskId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final clock = _FakeClock(t0);
    supplies = SuppliesRepository(db, clock: clock);
    recipes = RecipesRepository(db, clock: clock);
    tasks = TasksRepository(db, supplies, clock: clock);

    await db
        .into(db.areas)
        .insert(
          AreasCompanion.insert(
            id: areaId,
            userId: userId,
            name: 'Vrt',
            type: const Value(AreaType.bed),
            updatedAt: t0,
          ),
        );
    ureaId = await supplies.create(userId: userId, name: 'Urea', quantity: 1000);
    algaeId = await supplies.create(
      userId: userId,
      name: 'Algae',
      quantity: 500,
    );
    taskId = await tasks.create(
      userId: userId,
      taskTypeId: 'fertilize',
      date: t0,
      subjects: const [TaskSubjectSpec.area(areaId)],
    );
  });

  tearDown(() async => db.close());

  Future<double> qty(String id) async => (await supplies.byId(id))!.quantity;

  List<SupplySpec> specsFrom(Recipe r) => parseRecipeItems(r.items)
      .map((i) => SupplySpec(supplyId: i.supplyId, amount: i.amount))
      .toList();

  test('recipe → task supplies → deduct on done draws stock down', () async {
    final recipeId = await recipes.create(
      userId: userId,
      name: 'Spring mix',
      equipment: '16 L sprayer',
      items: [
        RecipeItem(supplyId: ureaId, amount: 100),
        RecipeItem(supplyId: algaeId, amount: 50),
      ],
    );

    final specs = specsFrom((await recipes.byId(recipeId))!);
    expect(specs, hasLength(2));

    await supplies.syncForTask(taskId: taskId, specs: specs, isDone: true);
    expect(await qty(ureaId), 900);
    expect(await qty(algaeId), 450);

    await tasks.revertToWaiting(taskId);
    expect(await qty(ureaId), 1000);
    expect(await qty(algaeId), 500);
  });
}
