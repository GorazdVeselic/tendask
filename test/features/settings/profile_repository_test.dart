import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/features/settings/data/profile_repository.dart';

class _FakeClock implements Clock {
  _FakeClock(this._now);
  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration d) => _now = _now.add(d);
}

void main() {
  late AppDatabase db;
  late _FakeClock clock;
  late ProfileRepository repo;

  final t0 = DateTime.utc(2026, 6, 2, 8);
  const userId = 'user-1';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = _FakeClock(t0);
    repo = ProfileRepository(db, clock: clock);
  });

  tearDown(() async => db.close());

  test('getLang returns null on an empty profile', () async {
    expect(await repo.getLang(userId), isNull);
  });

  test('setLang inserts the row and marks it pending', () async {
    await repo.setLang(userId, 'en');

    expect(await repo.getLang(userId), 'en');
    final row = await db.select(db.profiles).getSingle();
    expect(row.userId, userId);
    expect(row.syncStatus, 'pending');
  });

  test('setLang twice updates in place (single row, no duplicate)', () async {
    await repo.setLang(userId, 'en');
    clock.advance(const Duration(minutes: 5));
    await repo.setLang(userId, 'de');

    expect(await repo.getLang(userId), 'de');
    final rows = await db.select(db.profiles).get();
    expect(rows.length, 1);
  });
}
