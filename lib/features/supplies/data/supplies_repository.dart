import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import 'supply_spec.dart';

class SuppliesRepository {
  SuppliesRepository(this._db, {this._clock = const SystemClock()});

  final AppDatabase _db;
  final Clock _clock;
  final _uuid = const Uuid();

  Stream<List<Supply>> watchAll() => (
        _db.select(_db.supplies)
          ..where((s) => s.deleted.equals(false))
          ..orderBy([(s) => OrderingTerm.asc(s.name)])
      ).watch();

  Future<Supply?> byId(String id) =>
      (_db.select(_db.supplies)..where((s) => s.id.equals(id)))
          .getSingleOrNull();

  Stream<List<TaskSupply>> watchByTask(String taskId) => (
        _db.select(_db.taskSupplies)
          ..where((ts) => ts.deleted.equals(false) & ts.taskId.equals(taskId))
      ).watch();

  Future<List<TaskSupply>> suppliesForTask(String taskId) => _byTask(taskId);

  Future<List<TaskSupply>> _byTask(String taskId) => (
        _db.select(_db.taskSupplies)
          ..where((ts) => ts.deleted.equals(false) & ts.taskId.equals(taskId))
      ).get();

  Future<String> create({
    required String userId,
    required String name,
    String? unit,
    double quantity = 0,
    double? lowThreshold,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.supplies).insert(SuppliesCompanion.insert(
          id: id,
          userId: userId,
          name: name,
          unit: Value(unit),
          quantity: Value(quantity),
          lowThreshold: Value(lowThreshold),
          updatedAt: _clock.now(),
        ));
    return id;
  }

  Future<void> update({
    required String id,
    required String name,
    String? unit,
    required double quantity,
    double? lowThreshold,
  }) async {
    await (_db.update(_db.supplies)..where((s) => s.id.equals(id))).write(
      SuppliesCompanion(
        name: Value(name),
        unit: Value(unit),
        quantity: Value(quantity),
        lowThreshold: Value(lowThreshold),
        updatedAt: Value(_clock.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  Future<void> softDelete(String id) async {
    await (_db.update(_db.supplies)..where((s) => s.id.equals(id))).write(
      SuppliesCompanion(
        deleted: const Value(true),
        updatedAt: Value(_clock.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  // ─── task_supply consumption ─────────────────────────────────────────────

  /// Reconciles a task's consumed supplies with [specs]: returns any already
  /// booked stock, replaces the task_supply rows, and (when [isDone]) deducts.
  Future<void> syncForTask({
    required String taskId,
    required List<SupplySpec> specs,
    required bool isDone,
  }) async {
    await _db.transaction(() async {
      final existing = await _byTask(taskId);
      for (final ts in existing) {
        if (ts.applied) await _adjustQuantity(ts.supplyId, ts.amount);
        await _softDeleteTaskSupply(ts.id);
      }
      for (final spec in specs) {
        await _db.into(_db.taskSupplies).insert(TaskSuppliesCompanion.insert(
              id: _uuid.v4(),
              taskId: taskId,
              supplyId: spec.supplyId,
              amount: spec.amount,
              updatedAt: _clock.now(),
            ));
      }
      if (isDone) await applyForTask(taskId);
    });
  }

  /// Books each not-yet-applied consumption into stock (task became done).
  Future<void> applyForTask(String taskId) async {
    final rows = await _byTask(taskId);
    for (final ts in rows) {
      if (ts.applied) continue;
      await _adjustQuantity(ts.supplyId, -ts.amount);
      await _markApplied(ts.id, true);
    }
  }

  /// Returns each applied consumption back to stock (task reverted/deleted).
  Future<void> revertForTask(String taskId) async {
    final rows = await _byTask(taskId);
    for (final ts in rows) {
      if (!ts.applied) continue;
      await _adjustQuantity(ts.supplyId, ts.amount);
      await _markApplied(ts.id, false);
    }
  }

  Future<void> _adjustQuantity(String supplyId, double delta) async {
    final supply = await byId(supplyId);
    if (supply == null) return;
    await (_db.update(_db.supplies)..where((s) => s.id.equals(supplyId))).write(
      SuppliesCompanion(
        quantity: Value(supply.quantity + delta),
        updatedAt: Value(_clock.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  Future<void> _markApplied(String taskSupplyId, bool applied) async {
    await (_db.update(_db.taskSupplies)
          ..where((ts) => ts.id.equals(taskSupplyId)))
        .write(TaskSuppliesCompanion(
      applied: Value(applied),
      updatedAt: Value(_clock.now()),
      syncStatus: const Value('pending'),
    ));
  }

  Future<void> _softDeleteTaskSupply(String id) async {
    await (_db.update(_db.taskSupplies)..where((ts) => ts.id.equals(id))).write(
      TaskSuppliesCompanion(
        deleted: const Value(true),
        updatedAt: Value(_clock.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }
}
