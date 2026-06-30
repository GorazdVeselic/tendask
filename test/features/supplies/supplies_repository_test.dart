import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/supply_category.dart';
import 'package:tendask/features/supplies/data/supplies_repository.dart';
import 'package:tendask/features/supplies/data/supply_spec.dart';
import 'package:tendask/features/tasks/data/tasks_repository.dart';

class _FakeClock implements Clock {
  _FakeClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

void main() {
  late AppDatabase db;
  late SuppliesRepository supplies;
  late TasksRepository tasks;

  const userId = 'user-1';
  const areaId = 'area-1';
  final t0 = DateTime.utc(2026, 6, 2, 8);
  late String taskId;
  late String ureaId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final clock = _FakeClock(t0);
    supplies = SuppliesRepository(db, clock: clock);
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
    ureaId = await supplies.create(
      userId: userId,
      name: 'Urea',
      unit: 'kg',
      quantity: 5,
    );
    taskId = await tasks.create(
      userId: userId,
      taskTypeId: 'mow',
      date: t0,
      subjects: const [TaskSubjectSpec.area(areaId)],
    );
  });

  tearDown(() async => db.close());

  Future<double> qty(String id) async => (await supplies.byId(id))!.quantity;

  test('create stores fields', () async {
    final s = await supplies.byId(ureaId);
    expect(s!.name, 'Urea');
    expect(s.unit, 'kg');
    expect(s.quantity, 5);
    expect(s.category, SupplyCategory.other); // unspecified → default
  });

  test('create + update round-trips category', () async {
    final id = await supplies.create(
      userId: userId,
      name: 'Mospilan',
      category: SupplyCategory.treatment,
    );
    expect((await supplies.byId(id))!.category, SupplyCategory.treatment);

    await supplies.update(
      id: id,
      name: 'Mospilan',
      category: SupplyCategory.equipment,
      quantity: 1,
    );
    expect((await supplies.byId(id))!.category, SupplyCategory.equipment);
  });

  test('syncForTask isDone=false records but does not deduct', () async {
    await supplies.syncForTask(
      taskId: taskId,
      specs: [SupplySpec(supplyId: ureaId, amount: 2)],
      isDone: false,
    );
    expect(await qty(ureaId), 5);
    final rows = await supplies.suppliesForTask(taskId);
    expect(rows.single.applied, false);
  });

  test('syncForTask isDone=true deducts and marks applied', () async {
    await supplies.syncForTask(
      taskId: taskId,
      specs: [SupplySpec(supplyId: ureaId, amount: 2)],
      isDone: true,
    );
    expect(await qty(ureaId), 3);
    expect((await supplies.suppliesForTask(taskId)).single.applied, true);
  });

  test('applyForTask is idempotent (no double deduction)', () async {
    await supplies.syncForTask(
      taskId: taskId,
      specs: [SupplySpec(supplyId: ureaId, amount: 2)],
      isDone: false,
    );
    await supplies.applyForTask(taskId);
    await supplies.applyForTask(taskId);
    expect(await qty(ureaId), 3);
  });

  test('complete deducts, revertToWaiting returns stock', () async {
    await supplies.syncForTask(
      taskId: taskId,
      specs: [SupplySpec(supplyId: ureaId, amount: 2)],
      isDone: false,
    );
    expect(await qty(ureaId), 5);

    await tasks.complete(taskId);
    expect(await qty(ureaId), 3);

    await tasks.revertToWaiting(taskId);
    expect(await qty(ureaId), 5);
  });

  test('softDelete returns booked stock', () async {
    await supplies.syncForTask(
      taskId: taskId,
      specs: [SupplySpec(supplyId: ureaId, amount: 2)],
      isDone: true,
    );
    expect(await qty(ureaId), 3);

    await tasks.softDelete(taskId);
    expect(await qty(ureaId), 5);
  });

  test('diff on a done task returns old and deducts new', () async {
    final npkId = await supplies.create(
      userId: userId,
      name: 'NPK',
      unit: 'kg',
      quantity: 10,
    );

    await supplies.syncForTask(
      taskId: taskId,
      specs: [SupplySpec(supplyId: ureaId, amount: 2)],
      isDone: true,
    );
    expect(await qty(ureaId), 3);

    // Replace urea with NPK while the task stays done.
    await supplies.syncForTask(
      taskId: taskId,
      specs: [SupplySpec(supplyId: npkId, amount: 1)],
      isDone: true,
    );
    expect(await qty(ureaId), 5); // returned
    expect(await qty(npkId), 9); // deducted
  });
}
