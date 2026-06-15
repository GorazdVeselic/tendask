import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/catalog_provider.dart';
import 'package:tendask/core/suggestion_status.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/areas/application/areas_providers.dart';
import 'package:tendask/features/areas/data/areas_repository.dart';
import 'package:tendask/features/plants/application/plants_providers.dart';
import 'package:tendask/features/suggestions/application/suggestion_providers.dart';
import 'package:tendask/features/suggestions/data/suggestion_repository.dart';
import 'package:tendask/features/suggestions/presentation/suggestion_band.dart';
import 'package:tendask/features/suggestions/presentation/suggestion_text.dart';
import 'package:tendask/features/suggestions/presentation/widgets/suggestion_card.dart';
import 'package:tendask/features/supplies/application/supplies_providers.dart';
import 'package:tendask/features/supplies/data/supplies_repository.dart';
import 'package:tendask/features/tasks/application/tasks_providers.dart';
import 'package:tendask/features/tasks/data/tasks_repository.dart';
import 'package:tendask/i18n/translations.g.dart';

const _areaId = 'area-1';
const _sugId = 'sug-1';
final _past = DateTime.utc(2026, 1, 1, 8);

/// In-memory DB with a 'mow' task type, one lawn area, and one active mow
/// suggestion for that area (R5-style). The band content is fed via a static
/// Stream.value override (below) — a live drift `watch` stream would leave a
/// pending timer at teardown (same reason tasks_widget_test avoids it). The
/// "card disappears after a decision" path is covered by the repository unit
/// test ('a decided suggestion leaves the active band'); here we verify the
/// action wiring (DB effects) and the ⋯ sheet / confirm flows.
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
        ),
      );
  await db
      .into(db.areas)
      .insert(
        AreasCompanion.insert(
          id: _areaId,
          userId: 'local',
          name: 'Trata',
          type: const Value(AreaType.lawn),
          updatedAt: _past,
        ),
      );
  await db
      .into(db.suggestions)
      .insert(
        SuggestionsCompanion.insert(
          id: _sugId,
          userId: 'local',
          ruleId: 'R5',
          taskTypeId: 'mow',
          subjectKey: 'ar:$_areaId',
          areaId: const Value(_areaId),
          messageKey: 'suggestions.lawn.mow_due',
          messageParams: const Value('{"suggested_date":"2026-06-20"}'),
          score: 3.0,
          validUntil: DateTime(2099, 1, 1),
          createdAt: _past,
          updatedAt: _past,
        ),
      );
  return db;
}

Future<void> _pumpBand(
  WidgetTester tester,
  AppDatabase db, {
  Stream<List<Suggestion>>? content,
}) async {
  final areas = {for (final a in await db.select(db.areas).get()) a.id: a};
  final taskTypes = {
    for (final t in await db.select(db.taskTypes).get()) t.id: t,
  };
  final sug = await (db.select(
    db.suggestions,
  )..where((s) => s.id.equals(_sugId))).getSingle();

  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          // Static band content (no live drift stream → no pending timer).
          // Defaults to the single seeded suggestion; tests override the shape.
          activeSuggestionsProvider.overrideWith(
            (ref) => content ?? Stream.value([sug]),
          ),
          // Real repos on the in-memory DB so action writes are observable.
          suggestionRepositoryProvider.overrideWith(
            (ref) => SuggestionRepository(db),
          ),
          tasksRepositoryProvider.overrideWith(
            (ref) => TasksRepository(db, SuppliesRepository(db)),
          ),
          areasRepositoryProvider.overrideWith((ref) => AreasRepository(db)),
          taskTypesMapProvider.overrideWith((ref) => Stream.value(taskTypes)),
          areasMapProvider.overrideWith((ref) => Stream.value(areas)),
          userPlantsMapProvider.overrideWith(
            (ref) => Stream.value(<String, UserPlant>{}),
          ),
          plantsMapProvider.overrideWith(
            (ref) => Stream.value(<String, Plant>{}),
          ),
          suppliesListProvider.overrideWith((ref) => Stream.value(<Supply>[])),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: SuggestionBand())),
        ),
      ),
    ),
  );
  await tester.pump(); // resolve override streams
  await tester.pump(const Duration(milliseconds: 50));
}

/// Lets async action futures complete, then steps the top-toast lifecycle to
/// the end. The toast chains forward → Future.delayed(2.2 s) → reverse → remove;
/// pumpAndSettle returns early during the static delay (no frames scheduled),
/// so we advance each stage explicitly to leave no pending timer at teardown.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump(); // start the action future
  await tester.pump(
    const Duration(milliseconds: 250),
  ); // db writes + toast forward
  await tester.pump(const Duration(milliseconds: 2300)); // fire the delay timer
  await tester.pump(
    const Duration(milliseconds: 300),
  ); // reverse + overlay remove
  await tester.pump(); // flush the onDone microtask
}

Future<Suggestion> _suggestion(AppDatabase db) =>
    (db.select(db.suggestions)..where((s) => s.id.equals(_sugId))).getSingle();

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  testWidgets('renders the localized title and a body filled from the row', (
    tester,
  ) async {
    final db = await _buildDb();
    addTearDown(db.close);
    await _pumpBand(tester, db);

    expect(find.text('Čas za košnjo'), findsOneWidget); // mow_due.title (sl)
    // body "{subject}: …" → the subject resolved from the area row ("Trata").
    final body = fillTemplate(t['suggestions.lawn.mow_due.body'] as String, {
      'subject': 'Trata',
    });
    expect(find.text(body), findsOneWidget);
  });

  testWidgets('empty list renders no band at all (no hole on Home)', (
    tester,
  ) async {
    final db = await _buildDb();
    addTearDown(db.close);
    await _pumpBand(tester, db, content: Stream.value(const []));

    expect(find.byType(SuggestionCard), findsNothing);
    expect(find.byType(Card), findsNothing); // no error hint either
    expect(find.text(t.suggestions.disclaimer), findsNothing);
  });

  testWidgets('caps the band at 3 cards with a single shared disclaimer', (
    tester,
  ) async {
    final db = await _buildDb();
    addTearDown(db.close);
    final sug = await _suggestion(db);
    await _pumpBand(
      tester,
      db,
      content: Stream.value([
        sug,
        sug.copyWith(id: 's2'),
        sug.copyWith(id: 's3'),
        sug.copyWith(id: 's4'),
      ]),
    );

    expect(find.byType(SuggestionCard), findsNWidgets(3)); // kSuggestionBandMax
    expect(find.text(t.suggestions.disclaimer), findsOneWidget); // not per-card
  });

  testWidgets('Načrtuj creates a waiting task on the suggested date', (
    tester,
  ) async {
    final db = await _buildDb();
    addTearDown(db.close);
    await _pumpBand(tester, db);

    await tester.tap(find.text('Načrtuj'));
    await _settle(tester);

    final tasks = await db.select(db.tasks).get();
    expect(tasks, hasLength(1));
    expect(tasks.single.status, TaskStatus.waiting);
    expect(tasks.single.taskTypeId, 'mow');
    expect(tasks.single.date.toLocal().day, 20); // suggested_date 2026-06-20
    final subjects = await db.select(db.taskSubjects).get();
    expect(subjects.single.areaId, _areaId);
    expect((await _suggestion(db)).status, kSuggestionPlanned);
  });

  testWidgets('double-tapping Načrtuj creates only one task', (tester) async {
    final db = await _buildDb();
    addTearDown(db.close);
    await _pumpBand(tester, db);

    // Two taps before the first action's rebuild: the _busy guard must drop the
    // second so the card never creates a duplicate task.
    await tester.tap(find.text('Načrtuj'));
    await tester.tap(find.text('Načrtuj'));
    await _settle(tester);

    expect(await db.select(db.tasks).get(), hasLength(1));
  });

  testWidgets('Preskoči dismisses for the season', (tester) async {
    final db = await _buildDb();
    addTearDown(db.close);
    await _pumpBand(tester, db);

    await tester.tap(find.text('Preskoči'));
    await _settle(tester);

    final s = await _suggestion(db);
    expect(s.status, kSuggestionDismissed);
    expect(s.dismissScope, kDismissScopeSeason);
  });

  testWidgets('Že opravljeno → Danes creates a done task and logs it', (
    tester,
  ) async {
    final db = await _buildDb();
    addTearDown(db.close);
    await _pumpBand(tester, db);

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Že opravljeno'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Danes'));
    await _settle(tester);

    final tasks = await db.select(db.tasks).get();
    expect(tasks, hasLength(1));
    expect(tasks.single.status, TaskStatus.done);
    expect((await _suggestion(db)).status, kSuggestionLogged);
  });

  testWidgets('Ne predlagaj več dismisses forever', (tester) async {
    final db = await _buildDb();
    addTearDown(db.close);
    await _pumpBand(tester, db);

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Ne predlagaj več'));
    await _settle(tester);

    final s = await _suggestion(db);
    expect(s.status, kSuggestionDismissed);
    expect(s.dismissScope, kDismissScopeForever);
  });

  testWidgets('Tega nimam več soft-deletes the area and dismisses', (
    tester,
  ) async {
    final db = await _buildDb();
    addTearDown(db.close);
    await _pumpBand(tester, db);

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Tega nimam več'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Odstrani')); // confirm dialog
    await _settle(tester);

    final area = await (db.select(
      db.areas,
    )..where((a) => a.id.equals(_areaId))).getSingle();
    expect(area.deleted, isTrue);
    expect((await _suggestion(db)).status, kSuggestionDismissed);
  });

  testWidgets('cancelling "Tega nimam več" deletes nothing', (tester) async {
    final db = await _buildDb();
    addTearDown(db.close);
    await _pumpBand(tester, db);

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Tega nimam več'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Prekliči')); // dismiss the confirm dialog
    await _settle(tester);

    final area = await (db.select(
      db.areas,
    )..where((a) => a.id.equals(_areaId))).getSingle();
    expect(area.deleted, isFalse);
    expect((await _suggestion(db)).status, kSuggestionNew);
  });
}
