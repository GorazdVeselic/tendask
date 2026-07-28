import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';

/// The upgrade a released device actually performs. Play carries `1.0.1+16` at
/// drift v13, so v13 → v17 (engine tables, community_cache) is the path every
/// existing install runs on first launch of the M11 build — while the only
/// migration test so far started at v8, a version nobody has.
///
/// The v13 fixture is not hand-written DDL: it is the real current schema with
/// exactly what steps 14–17 add removed again, so it cannot drift out of sync
/// with the table definitions the way a copied CREATE TABLE would. The one
/// exception is plant_task_rule in the second test: v17 *drops* it, so the only
/// way to have a device that still carries it is to write the DDL out.
void main() {
  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('tendask_migration');
    file = File('${dir.path}/app.db');
  });

  tearDown(() async => dir.delete(recursive: true));

  Future<void> rewindToV13() async {
    final db = AppDatabase.forTesting(NativeDatabase(file));
    // Touch it so drift creates the current schema and stamps user_version.
    await db.customStatement('select 1');
    // A row that must survive the upgrade untouched.
    await db
        .into(db.profiles)
        .insert(
          ProfilesCompanion.insert(
            userId: 'u1',
            h3R7: const Value('871f1d4ffffffff'),
            lang: const Value('sl'),
            updatedAt: DateTime.utc(2026, 6, 1),
          ),
        );
    // A catalog as a v13 device has it: seeded, and with no `seasonal` column
    // once the rewind below removes it again.
    await db.customStatement(
      "INSERT INTO task_type (id, labels, icon, category) VALUES "
      "('water', '{}', '💧', 'care'), ('prune', '{}', '✂️', 'care')",
    );
    for (final stmt in [
      'DROP TABLE community_cache', // v16
      'DROP TABLE suggestion', // v14
      'ALTER TABLE profile DROP COLUMN timezone',
      'ALTER TABLE profile DROP COLUMN climate_bucket',
      'ALTER TABLE profile DROP COLUMN climate_profile',
      'ALTER TABLE profile DROP COLUMN fcm_token',
      'ALTER TABLE profile DROP COLUMN fcm_token_updated_at',
      'ALTER TABLE task DROP COLUMN agg_context',
      'ALTER TABLE task_type DROP COLUMN seasonal',
      'PRAGMA user_version = 13',
    ]) {
      await db.customStatement(stmt);
    }
    await db.close();
  }

  test('a v13 device upgrades to v17 and keeps its rows', () async {
    await rewindToV13();

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    // The engine columns arrive empty on the existing row, which survives.
    final profile = await db.select(db.profiles).getSingle();
    expect(profile.userId, 'u1');
    expect(profile.h3R7, '871f1d4ffffffff');
    expect(profile.lang, 'sl');
    expect(profile.timezone, isNull);
    expect(profile.climateBucket, isNull);
    expect(profile.fcmToken, isNull);
    expect(profile.fcmTokenUpdatedAt, isNull);

    // …and are writable, not just present.
    await (db.update(db.profiles)..where((p) => p.userId.equals('u1'))).write(
      const ProfilesCompanion(
        timezone: Value('Europe/Ljubljana'),
        climateBucket: Value('e1_t5'),
      ),
    );
    expect((await db.select(db.profiles).getSingle()).timezone, 'Europe/Ljubljana');

    // The two tables the M11 build reads on its first frame exist.
    expect(await db.select(db.suggestions).get(), isEmpty);
    expect(await db.select(db.communityCaches).get(), isEmpty);
  });

  test('a v16 device loses the two unread engine tables on the way to v17', () async {
    final seeded = AppDatabase.forTesting(NativeDatabase(file));
    await seeded.customStatement('select 1');
    // The tables as v14/v15 created them — nothing reads these columns on the
    // device, which is the whole point of dropping them (O5). Rows go in so the
    // drop has to survive a non-empty table, not just an empty one.
    await seeded.customStatement(
      'CREATE TABLE plant_task_rule ('
      'id TEXT NOT NULL PRIMARY KEY, scope TEXT NOT NULL, '
      'ref_id TEXT NOT NULL, task_type_id TEXT NOT NULL, '
      'timing_anchor TEXT NOT NULL, window TEXT NOT NULL, cadence TEXT, '
      'frost_gate INTEGER NOT NULL DEFAULT 0, weather_guard TEXT, '
      'source_ref TEXT NOT NULL, confidence TEXT NOT NULL, '
      'message_key TEXT NOT NULL)',
    );
    await seeded.customStatement(
      "INSERT INTO plant_task_rule VALUES ('apple.prune.winter', 'plant', "
      "'apple', 'prune', 'month_window', '{}', NULL, 0, NULL, 'rhs', "
      "'high', 'suggestions.fruit_tree.prune_winter')",
    );
    await seeded.customStatement(
      'CREATE TABLE suggestion_log ('
      'user_id TEXT NOT NULL, guard_key TEXT NOT NULL, '
      'subject_key TEXT NOT NULL, last_suggested_at INTEGER, '
      'dismissed_until INTEGER, updated_at INTEGER NOT NULL, '
      'PRIMARY KEY (user_id, guard_key, subject_key))',
    );
    await seeded.customStatement(
      "INSERT INTO suggestion_log VALUES ('u1', 'R3:water', 'up:p1', "
      'NULL, NULL, 0)',
    );
    await seeded.customStatement('PRAGMA user_version = 16');
    await seeded.close();

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);
    // Touch it so the migration runs before the shape is read back.
    await db.customStatement('select 1');

    final tables = await db
        .customSelect(
          "select name from sqlite_master where type = 'table' "
          "and name in ('plant_task_rule', 'suggestion_log')",
        )
        .get();
    expect(tables, isEmpty);
  });

  test('the seasonal backfill runs on the v13 catalog, not just on v8', () async {
    await rewindToV13();

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    final types = {
      for (final t in await db.select(db.taskTypes).get()) t.id: t.seasonal,
    };
    // Without the backfill every existing type defaults to seasonal = true, and
    // the community screen would offer a time percentile for watering.
    expect(types['water'], isFalse);
    expect(types['prune'], isTrue);
  });
}
