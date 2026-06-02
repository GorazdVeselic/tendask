import 'dart:async' show unawaited;
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/catalog_provider.dart';
import 'package:tendask/features/tasks/application/tasks_providers.dart';
import 'package:tendask/features/tasks/data/tasks_repository.dart';
import 'package:tendask/features/tasks/presentation/quick_log_screen.dart';
import 'package:tendask/features/tasks/presentation/tasks_screen.dart';
import 'package:tendask/i18n/translations.g.dart';

// ─── shared setup ─────────────────────────────────────────────────────────────

const _areaId = 'area-test-1';
final _past = DateTime.utc(2026, 1, 1, 8);

/// In-memory database with one task type ("Košnja") and one area ("Moj vrt").
/// A single type keeps the grid small so area chips stay in the test viewport.
Future<AppDatabase> _buildDb() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await db.into(db.taskTypes).insert(
    TaskTypesCompanion.insert(
      id: 'mow',
      labels: jsonEncode({'sl': 'Košnja', 'en': 'Mowing', 'de': 'Mähen'}),
      icon: '🌱',
      category: 'lawn_care',
      requiresSubject: const Value(false),
      weatherSensitive: const Value(true),
      defaultCadence: const Value(null),
    ),
  );
  await db.into(db.areas).insert(
    AreasCompanion.insert(
      id: _areaId,
      userId: 'local',
      name: 'Moj vrt',
      type: 'bed',
      updatedAt: _past,
    ),
  );
  return db;
}

// ─── tests ────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  // ── 1: QuickLogScreen saves task ────────────────────────────────────────────

  group('QuickLogScreen', () {
    testWidgets('tapping type + area + save creates task in DB', (tester) async {
      // Taller viewport so area chips are not obscured by the fixed save bar.
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = await _buildDb();
      addTearDown(db.close);

      final repo = TasksRepository(db);

      // Query once for static provider overrides (completing streams/futures).
      // Overriding tasksRepositoryProvider (not databaseProvider) so that the
      // flutter test scheduler never sees drift's NativeDatabase isolate traffic,
      // which would prevent pumpAndSettle from settling.
      final taskTypeMap = {
        for (final t in await db.select(db.taskTypes).get()) t.id: t
      };
      final areasMap = {
        for (final a in await db.select(db.areas).get()) a.id: a
      };

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: Text('home')),
          ),
          GoRoute(
            path: '/quick-log',
            builder: (_, _) => const QuickLogScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: ProviderScope(
            overrides: [
              tasksRepositoryProvider.overrideWith((ref) => repo),
              taskTypesMapProvider.overrideWith((ref) async => taskTypeMap),
              areasMapProvider.overrideWith((ref) => Stream.value(areasMap)),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        ),
      );

      unawaited(router.push('/quick-log'));
      await tester.pumpAndSettle();

      // Tap the only type tile ("Košnja")
      await tester.tap(find.text('Košnja'));
      await tester.pumpAndSettle();

      // Tap the area chip ("Moj vrt")
      await tester.tap(find.text('Moj vrt'));
      await tester.pumpAndSettle();

      // Tap save — _save() writes to DB then calls context.pop()
      await tester.tap(find.text('Shrani opravilo'));
      await tester.pumpAndSettle();

      // Verify task was persisted with the correct type and area
      final rows = await (db.select(db.tasks)).get();
      expect(rows, hasLength(1));
      expect(rows.first.taskTypeId, 'mow');
      expect(rows.first.areaId, _areaId);
    });
  });

  // ── 2: TasksScreen complete action ──────────────────────────────────────────

  group('TasksScreen', () {
    testWidgets('⋯ → Opravljeno moves task to done', (tester) async {
      final db = await _buildDb();
      addTearDown(db.close);

      final repo = TasksRepository(db);
      final taskId = await repo.create(
        userId: 'local',
        areaId: _areaId,
        taskTypeId: 'mow',
        date: _past,
      );

      // Query once for static provider overrides.
      final taskTypeMap = {
        for (final t in await db.select(db.taskTypes).get()) t.id: t
      };
      final areasMap = {
        for (final a in await db.select(db.areas).get()) a.id: a
      };
      final pendingTask = await repo.byId(taskId);

      // Named routes referenced by TasksScreen (not navigated in this test)
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const TasksScreen()),
          GoRoute(
            path: '/ql',
            name: 'quick-log',
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: '/td/:id',
            name: 'task-detail',
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: '/te/:id',
            name: 'task-edit',
            builder: (_, _) => const SizedBox(),
          ),
        ],
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: ProviderScope(
            overrides: [
              tasksRepositoryProvider.overrideWith((ref) => repo),
              taskTypesMapProvider.overrideWith((ref) async => taskTypeMap),
              areasMapProvider.overrideWith((ref) => Stream.value(areasMap)),
              pendingTasksProvider.overrideWith(
                (ref) => Stream.value([pendingTask!]),
              ),
              completedTasksProvider.overrideWith(
                (ref) => Stream.value(<Task>[]),
              ),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        ),
      );

      // Use explicit pump() — showModalBottomSheet+GoRouter prevents pumpAndSettle
      // from settling (animation controllers are never fully quiescent).
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Task row is visible (area shown as subtitle)
      expect(find.text('🪴 Moj vrt'), findsOneWidget);

      // Open action sheet via ⋯ button
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pump(); // register tap
      await tester.pump(const Duration(milliseconds: 400)); // sheet slide-in

      // Tap "Opravljeno" — calls repo.complete(taskId) fire-and-forget
      await tester.tap(find.text('Opravljeno'));
      await tester.pump(); // register tap + trigger complete()
      await tester.pump(const Duration(milliseconds: 400)); // sheet slide-out

      // runAsync gives repo.complete() time to settle on the real event loop.
      await tester.runAsync(() async {
        final updated = await repo.byId(taskId);
        expect(updated!.status, 'done');

        final pending = await repo.watchPending().first;
        expect(pending, isEmpty);
      });
    });
  });
}
