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
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/features/areas/application/areas_providers.dart';
import 'package:tendask/features/plants/application/plants_providers.dart';
import 'package:tendask/features/supplies/application/supplies_providers.dart';
import 'package:tendask/features/supplies/data/supplies_repository.dart';
import 'package:tendask/features/tasks/application/tasks_providers.dart';
import 'package:tendask/features/tasks/data/tasks_repository.dart';
import 'package:tendask/i18n/translations.g.dart';
import 'package:tendask/features/tasks/presentation/entry/entry_screen.dart';

const _areaId = 'area-test-1';
final _past = DateTime.utc(2026, 1, 1, 8);

/// In-memory DB with one task type + one area. The real database backs the seed
/// (profile read) and the save, so the test stays hermetic without manual fakes.
Future<AppDatabase> _buildDb() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await db
      .into(db.taskTypes)
      .insert(
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
  await db
      .into(db.areas)
      .insert(
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

Future<GoRouter> _pumpEntry(WidgetTester tester, AppDatabase db) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final taskTypeMap = {
    for (final t in await db.select(db.taskTypes).get()) t.id: t,
  };
  final areasMap = {for (final a in await db.select(db.areas).get()) a.id: a};

  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('home'))),
      GoRoute(path: '/entry', builder: (_, _) => const EntryScreen()),
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
          // Real DB so the seed's profile read and the save use one hermetic db.
          databaseProvider.overrideWithValue(db),
          // Plain repo (no weather capture) sharing the same db, so a "done" save
          // does not reach the garden-location providers.
          tasksRepositoryProvider.overrideWith(
            (ref) => TasksRepository(db, SuppliesRepository(db)),
          ),
          taskTypesMapProvider.overrideWith((ref) => Stream.value(taskTypeMap)),
          areasMapProvider.overrideWith((ref) => Stream.value(areasMap)),
          userPlantsMapProvider.overrideWith(
            (ref) => Stream.value(<String, UserPlant>{}),
          ),
          plantsMapProvider.overrideWith(
            (ref) => Stream.value(<String, Plant>{}),
          ),
          plantsListProvider.overrideWith((ref) => Stream.value(<Plant>[])),
          taskTypeCategoriesProvider.overrideWith(
            (ref) => Stream.value(<String, Set<String>>{}),
          ),
          suppliesListProvider.overrideWith((ref) => Stream.value(<Supply>[])),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    ),
  );

  unawaited(router.push('/entry'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  return router;
}

/// Type "Košnja" → subjects (area) → Continue → step 3 (when).
Future<void> _toWhenStep(WidgetTester tester) async {
  await tester.tap(find.text('Košnja'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();

  await tester.tap(find.text('Moj vrt'));
  await tester.pump();
  await tester.tap(find.text('Nadaljuj'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  testWidgets('planned task is seeded a removable default reminder', (
    tester,
  ) async {
    final db = await _buildDb();
    addTearDown(db.close);

    await _pumpEntry(tester, db);
    await _toWhenStep(tester);

    // Status defaults to waiting (date is the next full hour) → reminder step is
    // in the flow and the seed has run.
    await tester.tap(find.text('Nadaljuj')); // → step 4 (reminder)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    // Seeded "at event" reminder + the hint explaining it can be removed.
    expect(find.text('Ob dogodku'), findsOneWidget);
    expect(
      find.text('Dodali smo privzeti opomnik. Odstrani ga, če ga ne potrebuješ.'),
      findsOneWidget,
    );

    // Remove it via the row's close button → reminder and hint disappear.
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Ob dogodku'),
        matching: find.byIcon(Icons.close),
      ),
    );
    await tester.pump();
    expect(find.text('Ob dogodku'), findsNothing);
    expect(
      find.text('Dodali smo privzeti opomnik. Odstrani ga, če ga ne potrebuješ.'),
      findsNothing,
    );
  });

  testWidgets('a done task is saved without any reminder', (tester) async {
    final db = await _buildDb();
    addTearDown(db.close);

    await _pumpEntry(tester, db);
    await _toWhenStep(tester);

    // Force "done": the reminder step drops out and the seed is discarded on save.
    await tester.tap(find.text('Opravljeno'));
    await tester.pump();
    await tester.tap(find.text('Nadaljuj')); // → review (no reminder step)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    await tester.tap(find.text('Shrani opravilo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final tasks = await db.select(db.tasks).get();
    expect(tasks, hasLength(1));
    final reminders = await db.select(db.taskReminders).get();
    expect(reminders, isEmpty);
  });
}
