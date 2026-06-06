import 'dart:async' show unawaited;
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/catalog_provider.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/areas/application/areas_providers.dart';
import 'package:tendask/features/plants/application/plants_providers.dart';
import 'package:tendask/features/supplies/application/supplies_providers.dart';
import 'package:tendask/features/supplies/data/supplies_repository.dart';
import 'package:tendask/features/tasks/application/tasks_providers.dart';
import 'package:tendask/features/tasks/data/tasks_repository.dart';
import 'package:tendask/features/tasks/presentation/entry/entry_screen.dart';
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
      type: const Value(AreaType.bed),
      updatedAt: _past,
    ),
  );
  return db;
}

// ─── tests ────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  // ── 1: QuickLogScreen saves task ────────────────────────────────────────────

  group('EntryScreen', () {
    testWidgets('type + subject + continue + save creates task in DB',
        (tester) async {
      // Taller viewport so area chips are not obscured by the fixed save bar.
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = await _buildDb();
      addTearDown(db.close);

      final repo = TasksRepository(db, SuppliesRepository(db));

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
            path: '/entry',
            builder: (_, _) => const EntryScreen(),
          ),
          GoRoute(
            path: '/note-new',
            name: 'note-new',
            builder: (_, _) => const SizedBox(),
          ),
        ],
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: ProviderScope(
            overrides: [
              tasksRepositoryProvider.overrideWith((ref) => repo),
              taskTypesMapProvider
                  .overrideWith((ref) => Stream.value(taskTypeMap)),
              areasMapProvider.overrideWith((ref) => Stream.value(areasMap)),
              userPlantsMapProvider
                  .overrideWith((ref) => Stream.value(<String, UserPlant>{})),
              plantsMapProvider
                  .overrideWith((ref) => Stream.value(<String, Plant>{})),
              plantsListProvider.overrideWith((ref) => Stream.value(<Plant>[])),
              suppliesListProvider
                  .overrideWith((ref) => Stream.value(<Supply>[])),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        ),
      );

      // Explicit pumps — the PageView's animateToPage transitions keep
      // pumpAndSettle from ever settling.
      unawaited(router.push('/entry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100)); // resolve futures

      // Step 1: tap the only type tile ("Košnja") — auto-advances to step 2.
      await tester.tap(find.text('Košnja'));
      await tester.pump(); // start page transition
      await tester.pump(const Duration(milliseconds: 400)); // transition done
      await tester.pump(); // rebuild with stream data (areas)

      // Step 2 (subjects): pick the area chip.
      await tester.tap(find.text('Moj vrt'));
      await tester.pump();
      await tester.tap(find.text('Nadaljuj')); // → step 3 (when)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      // Force status "done" so the flow is deterministic regardless of the run
      // clock (a future default date would add the conditional reminder step).
      await tester.tap(find.text('Opravljeno'));
      await tester.pump();
      await tester.tap(find.text('Nadaljuj')); // → review (mow: no supplies)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      // Review: save — writes to DB then calls context.pop().
      await tester.tap(find.text('Shrani opravilo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify task was persisted with the correct type and area
      final rows = await (db.select(db.tasks)).get();
      expect(rows, hasLength(1));
      expect(rows.first.taskTypeId, 'mow');
      final subs = await (db.select(db.taskSubjects)).get();
      expect(subs.single.areaId, _areaId);
    });
  });

  // ── 2: TasksScreen complete action ──────────────────────────────────────────

  group('TasksScreen', () {
    testWidgets('⋯ → Opravljeno moves task to done', (tester) async {
      final db = await _buildDb();
      addTearDown(db.close);

      final repo = TasksRepository(db, SuppliesRepository(db));
      final taskId = await repo.create(
        userId: 'local',
        taskTypeId: 'mow',
        date: _past,
        subjects: const [TaskSubjectSpec.area(_areaId)],
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
            path: '/tn',
            name: 'task-new',
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
              taskTypesMapProvider
                  .overrideWith((ref) => Stream.value(taskTypeMap)),
              areasMapProvider.overrideWith((ref) => Stream.value(areasMap)),
              pendingTasksProvider.overrideWith(
                (ref) => Stream.value([pendingTask!]),
              ),
              completedTasksProvider.overrideWith(
                (ref) => Stream.value(<Task>[]),
              ),
              taskIdsWithRemindersProvider.overrideWith(
                (ref) => Stream.value(<String>{}),
              ),
              // Subject label plumbing — kept static so the test stays hermetic.
              allTaskSubjectsProvider.overrideWith(
                (ref) => Stream.value([
                  TaskSubject(
                    id: 'ts1',
                    taskId: taskId,
                    areaId: _areaId,
                    updatedAt: _past,
                    deleted: false,
                    syncStatus: 'pending',
                  ),
                ]),
              ),
              userPlantsMapProvider.overrideWith(
                (ref) => Stream.value(<String, UserPlant>{}),
              ),
              plantsMapProvider.overrideWith(
                (ref) => Stream.value(<String, Plant>{}),
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
        expect(updated!.status, TaskStatus.done);

        final pending = await repo.watchPending().first;
        expect(pending, isEmpty);
      });
    });
  });
}
