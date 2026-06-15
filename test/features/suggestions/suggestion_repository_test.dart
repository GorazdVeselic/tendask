import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/suggestion_status.dart';
import 'package:tendask/core/sync/sync_status.dart';
import 'package:tendask/features/suggestions/data/suggestion_repository.dart';

class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

void main() {
  late AppDatabase db;
  late SuggestionRepository repo;
  // Local "today" — local (not UTC) so the repo's .toLocal() is a no-op and the
  // valid_until comparison stays timezone-independent across CI machines.
  final today = DateTime(2026, 6, 14, 9);
  final clock = _FixedClock(today);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SuggestionRepository(db, clock: clock);
  });
  tearDown(() async => db.close());

  Future<void> insertSuggestion(
    String id, {
    String status = kSuggestionNew,
    double score = 3.0,
    DateTime? validUntil,
    String? userPlantId,
    String? areaId,
    bool deleted = false,
    String ruleId = 'R3',
    String subjectKey = 'up:p1',
    DateTime? updatedAt,
    String? plannedTaskId,
    String dismissScope = kDismissScopeSeason,
  }) => db
      .into(db.suggestions)
      .insert(
        SuggestionsCompanion.insert(
          id: id,
          userId: 'u1',
          ruleId: ruleId,
          taskTypeId: 'mow',
          subjectKey: subjectKey,
          messageKey: 'suggestions.cadence.overdue',
          score: score,
          validUntil: validUntil ?? DateTime(2026, 6, 20),
          createdAt: today,
          updatedAt: updatedAt ?? today,
          status: Value(status),
          userPlantId: Value(userPlantId),
          areaId: Value(areaId),
          deleted: Value(deleted),
          plannedTaskId: Value(plannedTaskId),
          dismissScope: Value(dismissScope),
        ),
      );

  Future<void> insertUserPlant(String id, {bool deleted = false}) => db
      .into(db.userPlants)
      .insert(
        UserPlantsCompanion.insert(
          id: id,
          userId: 'u1',
          updatedAt: today,
          deleted: Value(deleted),
        ),
      );

  Future<void> insertArea(String id, {bool deleted = false}) => db
      .into(db.areas)
      .insert(
        AreasCompanion.insert(
          id: id,
          userId: 'u1',
          name: 'Lawn',
          updatedAt: today,
          deleted: Value(deleted),
        ),
      );

  Future<Suggestion> read(String id) =>
      (db.select(db.suggestions)..where((s) => s.id.equals(id))).getSingle();

  test('watchActive returns fresh new suggestions, highest score first', () async {
    await insertSuggestion('low', score: 2.0);
    await insertSuggestion('high', score: 4.0);
    final rows = await repo.watchActive().first;
    expect(rows.map((r) => r.id), ['high', 'low']);
  });

  test('excludes suggestions whose valid_until is before today', () async {
    await insertSuggestion('expired', validUntil: DateTime(2026, 6, 13));
    await insertSuggestion('lastDay', validUntil: DateTime(2026, 6, 14));
    final rows = await repo.watchActive().first;
    expect(rows.map((r) => r.id), ['lastDay']);
  });

  test('excludes non-new statuses', () async {
    await insertSuggestion('planned', status: kSuggestionPlanned);
    await insertSuggestion('fresh');
    final rows = await repo.watchActive().first;
    expect(rows.map((r) => r.id), ['fresh']);
  });

  test('excludes soft-deleted suggestions (retention housekeeping)', () async {
    await insertSuggestion('purged', deleted: true);
    await insertSuggestion('fresh');
    final rows = await repo.watchActive().first;
    expect(rows.map((r) => r.id), ['fresh']);
  });

  test('hides a suggestion whose plant subject is deleted', () async {
    await insertUserPlant('p1', deleted: true);
    await insertUserPlant('p2');
    await insertSuggestion('gone', userPlantId: 'p1', subjectKey: 'up:p1');
    await insertSuggestion('kept', userPlantId: 'p2', subjectKey: 'up:p2');
    final rows = await repo.watchActive().first;
    expect(rows.map((r) => r.id), ['kept']);
  });

  test('hides a suggestion whose area subject is deleted', () async {
    await insertArea('a1', deleted: true);
    await insertSuggestion('gone', areaId: 'a1');
    final rows = await repo.watchActive().first;
    expect(rows, isEmpty);
  });

  test('keeps cat: suggestions that have no subject FK', () async {
    await insertSuggestion('cat', subjectKey: 'cat:fruit_tree');
    final rows = await repo.watchActive().first;
    expect(rows.map((r) => r.id), ['cat']);
  });

  test('orders tied scores deterministically by id (stable band)', () async {
    // Same score, rule and subject — only id differs. Inserted out of order to
    // prove the ordering is the id tiebreak, not insertion order.
    await insertSuggestion('z', score: 3.0);
    await insertSuggestion('a', score: 3.0);
    final rows = await repo.watchActive().first;
    expect(rows.map((r) => r.id), ['a', 'z']);
  });

  test('markPlanned links the task, retires the suggestion, marks pending', () async {
    await insertSuggestion('s1');
    await repo.markPlanned('s1', plannedTaskId: 't9');
    final row = await read('s1');
    expect(row.status, kSuggestionPlanned);
    expect(row.plannedTaskId, 't9');
    expect(row.syncStatus, kSyncPending);
  });

  test('dismiss writes season by default and forever on request', () async {
    await insertSuggestion('s1');
    await insertSuggestion('s2');
    await repo.dismiss('s1');
    await repo.dismiss('s2', scope: DismissScope.forever);
    expect((await read('s1')).status, kSuggestionDismissed);
    expect((await read('s1')).dismissScope, kDismissScopeSeason);
    expect((await read('s2')).dismissScope, kDismissScopeForever);
  });

  test('markLogged links the done task and retires the suggestion', () async {
    await insertSuggestion('s1');
    await repo.markLogged('s1', doneTaskId: 'd5');
    final row = await read('s1');
    expect(row.status, kSuggestionLogged);
    expect(row.plannedTaskId, 'd5');
  });

  test('a second decision is a no-op (double-tap race is ignored)', () async {
    await insertSuggestion('s1');
    await repo.markPlanned('s1', plannedTaskId: 't9');
    await repo.dismiss('s1'); // arrives after the card already left the band
    final row = await read('s1');
    expect(row.status, kSuggestionPlanned);
    expect(row.plannedTaskId, 't9');
    expect(row.dismissScope, kDismissScopeSeason); // default, untouched
  });

  test('a decided suggestion leaves the active band', () async {
    await insertSuggestion('s1');
    expect(await repo.watchActive().first, hasLength(1));
    await repo.dismiss('s1');
    expect(await repo.watchActive().first, isEmpty);
  });

  test('watchHistory returns only decided rows, newest first', () async {
    await insertSuggestion('fresh'); // status new → excluded
    await insertSuggestion(
      'planned',
      status: kSuggestionPlanned,
      updatedAt: DateTime(2026, 6, 10),
    );
    await insertSuggestion(
      'dismissed',
      status: kSuggestionDismissed,
      updatedAt: DateTime(2026, 6, 12),
    );
    await insertSuggestion(
      'expired',
      status: kSuggestionExpired,
      updatedAt: DateTime(2026, 6, 11),
    );
    final rows = await repo.watchHistory().first;
    // 'new' excluded; ordered by updated_at desc.
    expect(rows.map((r) => r.id), ['dismissed', 'expired', 'planned']);
  });

  test('watchHistory excludes soft-deleted rows (retention)', () async {
    await insertSuggestion(
      'purged',
      status: kSuggestionLogged,
      deleted: true,
    );
    await insertSuggestion('kept', status: kSuggestionLogged);
    final rows = await repo.watchHistory().first;
    expect(rows.map((r) => r.id), ['kept']);
  });

  test('watchActiveCount mirrors the active band size', () async {
    await insertSuggestion('a');
    await insertSuggestion('b');
    await insertSuggestion('decided', status: kSuggestionPlanned);
    expect(await repo.watchActiveCount().first, 2);
  });
}
