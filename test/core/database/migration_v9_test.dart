import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/suggestion_status.dart';

/// Verifies the v8 → v9 onUpgrade path (M11.2): a database created with the
/// pre-M11 schema (only the tables the migration touches, with their exact v8
/// columns) upgrades in place — new columns appear, suggestion tables exist,
/// the seasonal backfill lands — and existing rows survive untouched.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (raw) {
          raw
            ..execute('''
              CREATE TABLE profile (
                user_id TEXT NOT NULL PRIMARY KEY,
                h3_r7 TEXT, h3_r6 TEXT, h3_r5 TEXT, lang TEXT,
                notification_settings TEXT,
                updated_at INTEGER NOT NULL,
                sync_status TEXT NOT NULL DEFAULT 'pending'
              )''')
            ..execute('''
              CREATE TABLE task_type (
                id TEXT NOT NULL PRIMARY KEY,
                labels TEXT NOT NULL, icon TEXT NOT NULL, category TEXT NOT NULL,
                requires_subject INTEGER NOT NULL DEFAULT 0,
                weather_sensitive INTEGER NOT NULL DEFAULT 0,
                consumes_supplies INTEGER NOT NULL DEFAULT 0,
                default_cadence INTEGER
              )''')
            ..execute('''
              CREATE TABLE task (
                id TEXT NOT NULL PRIMARY KEY,
                user_id TEXT NOT NULL, task_type_id TEXT NOT NULL,
                date INTEGER NOT NULL,
                status TEXT NOT NULL DEFAULT 'waiting',
                note TEXT, weather TEXT, recurrence TEXT,
                updated_at INTEGER NOT NULL,
                deleted INTEGER NOT NULL DEFAULT 0,
                sync_status TEXT NOT NULL DEFAULT 'pending'
              )''')
            // supply exists in the pre-M11 schema; the reconcile re-sequenced the
            // engine step above main's v13 (supply.category), which the full v8→
            // current ladder now runs, so this table must be present to migrate.
            ..execute('''
              CREATE TABLE supply (
                id TEXT NOT NULL PRIMARY KEY,
                user_id TEXT NOT NULL, name TEXT NOT NULL,
                updated_at INTEGER NOT NULL,
                deleted INTEGER NOT NULL DEFAULT 0,
                sync_status TEXT NOT NULL DEFAULT 'pending'
              )''')
            ..execute(
              "INSERT INTO task_type (id, labels, icon, category) VALUES "
              "('water', '{}', 'i', 'general'), ('prune', '{}', 'i', 'plant_care')",
            )
            ..execute(
              "INSERT INTO profile (user_id, h3_r7, updated_at) "
              "VALUES ('u1', '871f1d4ffffffff', 1700000000)",
            )
            ..execute(
              "INSERT INTO task (id, user_id, task_type_id, date, updated_at) "
              "VALUES ('t1', 'u1', 'water', 1700000000, 1700000000)",
            )
            ..execute('PRAGMA user_version = 8');
        },
      ),
    );
  });

  tearDown(() => db.close());

  test('v8 database upgrades to v9 with data intact', () async {
    // Existing rows survive and expose the new columns as null.
    final profile = await db.select(db.profiles).getSingle();
    expect(profile.h3R7, '871f1d4ffffffff');
    expect(profile.timezone, isNull);
    expect(profile.climateBucket, isNull);
    expect(profile.climateProfile, isNull);
    expect(profile.fcmToken, isNull);
    expect(profile.fcmTokenUpdatedAt, isNull);

    final task = await db.select(db.tasks).getSingle();
    expect(task.id, 't1');
    expect(task.aggContext, isNull);

    // Seasonal backfill: the four non-seasonal ids flip, the rest stay true.
    final types = {
      for (final t in await db.select(db.taskTypes).get()) t.id: t.seasonal,
    };
    expect(types['water'], isFalse);
    expect(types['prune'], isTrue);

    // New columns are writable.
    await (db.update(db.profiles)..where((p) => p.userId.equals('u1'))).write(
      const ProfilesCompanion(
        timezone: Value('Europe/Ljubljana'),
        climateBucket: Value('e1_t5'),
      ),
    );
    final updated = await db.select(db.profiles).getSingle();
    expect(updated.timezone, 'Europe/Ljubljana');
    expect(updated.climateBucket, 'e1_t5');

    // The new tables exist and accept rows.
    await db
        .into(db.suggestions)
        .insert(
          SuggestionsCompanion.insert(
            id: 's1',
            userId: 'u1',
            ruleId: 'R5',
            taskTypeId: 'prune',
            subjectKey: 'cat:fruit_tree',
            messageKey: 'suggestions.prune',
            score: 2.5,
            validUntil: DateTime.utc(2026, 7, 1),
            createdAt: DateTime.utc(2026, 6, 1),
            updatedAt: DateTime.utc(2026, 6, 1),
          ),
        );
    final suggestion = await db.select(db.suggestions).getSingle();
    expect(suggestion.status, kSuggestionNew);
    expect(suggestion.dismissScope, kDismissScopeSeason);
    expect(suggestion.syncStatus, 'synced');

    await db
        .into(db.suggestionLogs)
        .insert(
          SuggestionLogsCompanion.insert(
            userId: 'u1',
            guardKey: 'R5:prune',
            subjectKey: 'cat:fruit_tree',
            updatedAt: DateTime.utc(2026, 6, 1),
          ),
        );
    expect(await db.select(db.suggestionLogs).get(), hasLength(1));
  });
}
