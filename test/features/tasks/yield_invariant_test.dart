import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/seed_service.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/supplies/data/supplies_repository.dart';
import 'package:tendask/features/tasks/data/tasks_repository.dart';
import 'package:tendask/features/tasks/yield_unit.dart';

/// In-memory property test: whatever yield the UI throws at the repository, the
/// stored row must always satisfy the Supabase CHECKs — both-or-neither AND a
/// positive amount. This is the invariant that keeps the sync push from wedging
/// on a row Postgres would reject.
void main() {
  late AppDatabase db;
  late TasksRepository repo;
  const areaId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  const userId = 'u1';
  final t0 = DateTime.utc(2026, 6, 2, 8);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TasksRepository(db, SuppliesRepository(db));
    await SeedService(db).runIfNeeded();
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
  });
  tearDown(() async => db.close());

  void expectInvariant(Task task) {
    final amount = task.yieldAmount;
    final unit = task.yieldUnit;
    expect(
      (amount == null) == (unit == null),
      isTrue,
      reason: 'both-or-neither violated: amount=$amount unit=$unit',
    );
    expect(
      amount == null || (amount.isFinite && amount > 0),
      isTrue,
      reason: 'non-positive or non-finite amount stored: $amount',
    );
  }

  // Every adversarial pair the UI/repo boundary could ever pass.
  final inputs = <({double? amount, YieldUnit? unit})>[
    (amount: null, unit: null),
    (amount: 2.5, unit: null), // half pair
    (amount: null, unit: YieldUnit.kg), // half pair
    (amount: 0, unit: YieldUnit.kg), // zero
    (amount: -3, unit: YieldUnit.kg), // negative
    (amount: 0.001, unit: YieldUnit.g), // tiny but positive
    (amount: double.infinity, unit: YieldUnit.kg), // pasted huge number
    (amount: double.nan, unit: YieldUnit.kg), // not a number
    (amount: 2.5, unit: YieldUnit.kg), // valid
  ];

  test('create never stores a row that violates the CHECKs', () async {
    for (final input in inputs) {
      final id = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'harvest',
        date: t0,
        status: TaskStatus.done,
        yieldAmount: input.amount,
        yieldUnit: input.unit,
      );
      expectInvariant((await repo.byId(id))!);
    }
  });

  test('setYield never stores a row that violates the CHECKs', () async {
    for (final input in inputs) {
      final id = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'harvest',
        date: t0,
        status: TaskStatus.done,
      );
      await repo.setYield(id, amount: input.amount, unit: input.unit);
      expectInvariant((await repo.byId(id))!);
    }
  });

  test('complete never stores a row that violates the CHECKs', () async {
    for (final input in inputs) {
      final id = await repo.create(
        userId: userId,
        subjects: const [TaskSubjectSpec.area(areaId)],
        taskTypeId: 'harvest',
        date: t0,
      );
      await repo.complete(id, yieldAmount: input.amount, yieldUnit: input.unit);
      expectInvariant((await repo.byId(id))!);
    }
  });

  test('the one valid input actually persists (guard not over-eager)', () async {
    final id = await repo.create(
      userId: userId,
      subjects: const [TaskSubjectSpec.area(areaId)],
      taskTypeId: 'harvest',
      date: t0,
      status: TaskStatus.done,
      yieldAmount: 2.5,
      yieldUnit: YieldUnit.kg,
    );
    final task = await repo.byId(id);
    expect(task!.yieldAmount, 2.5);
    expect(task.yieldUnit, 'kg');
  });
}
