import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';

/// The upgrade a released device actually performs. Play carries `1.0.1+16` at
/// drift v13, so v13 → v16 (engine tables, plant_task_rule, community_cache) is
/// the path every existing install runs on first launch of the M11 build — while
/// the only migration test so far started at v8, a version nobody has.
///
/// The v13 fixture is not hand-written DDL: it is the real current schema with
/// exactly what steps 14–16 add removed again, so it cannot drift out of sync
/// with the table definitions the way a copied CREATE TABLE would.
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
      'DROP TABLE plant_task_rule', // v15
      'DROP TABLE suggestion_log', // v14
      'DROP TABLE suggestion',
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

  test('a v13 device upgrades to v16 and keeps its rows', () async {
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

    // The four tables the M11 build reads on its first frame exist.
    expect(await db.select(db.suggestions).get(), isEmpty);
    expect(await db.select(db.suggestionLogs).get(), isEmpty);
    expect(await db.select(db.plantTaskRules).get(), isEmpty);
    expect(await db.select(db.communityCaches).get(), isEmpty);
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
