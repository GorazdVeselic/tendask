import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/catalog_provider.dart';
import 'package:tendask/core/suggestion_status.dart';
import 'package:tendask/features/areas/application/areas_providers.dart';
import 'package:tendask/features/plants/application/plants_providers.dart';
import 'package:tendask/features/suggestions/application/suggestion_providers.dart';
import 'package:tendask/features/suggestions/presentation/suggestion_history_screen.dart';
import 'package:tendask/i18n/translations.g.dart';

final _past = DateTime.utc(2026, 1, 1, 8);

/// In-memory DB with a 'mow' task type, one area, and a suggestion in every
/// lifecycle state (incl. 'new', which history must exclude). The screen is fed
/// via a static Stream.value override of [suggestionHistoryProvider] (a live
/// drift watch would leave a pending timer at teardown) — but the list itself
/// comes from the real repo.watchHistory(), so the 'new' exclusion is exercised
/// end-to-end.
Future<AppDatabase> _buildDb() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await db
      .into(db.taskTypes)
      .insert(
        TaskTypesCompanion.insert(
          id: 'mow',
          labels: '{"sl":"Košnja","en":"Mowing","de":"Mähen"}',
          icon: '🌾',
          category: 'lawn_care',
        ),
      );
  await db
      .into(db.areas)
      .insert(
        AreasCompanion.insert(
          id: 'a1',
          userId: 'local',
          name: 'Trata',
          type: const Value(AreaType.lawn),
          updatedAt: _past,
        ),
      );

  Future<void> add(
    String id, {
    required String status,
    required DateTime updatedAt,
    String? plannedTaskId,
    String dismissScope = kDismissScopeSeason,
  }) => db
      .into(db.suggestions)
      .insert(
        SuggestionsCompanion.insert(
          id: id,
          userId: 'local',
          ruleId: 'R5',
          taskTypeId: 'mow',
          subjectKey: 'ar:a1',
          areaId: const Value('a1'),
          messageKey: 'suggestions.lawn.mow_due',
          score: 3.0,
          validUntil: DateTime(2099, 1, 1),
          createdAt: _past,
          updatedAt: updatedAt,
          status: Value(status),
          plannedTaskId: Value(plannedTaskId),
          dismissScope: Value(dismissScope),
        ),
      );

  await add('fresh', status: kSuggestionNew, updatedAt: DateTime(2026, 6, 15));
  await add(
    'planned',
    status: kSuggestionPlanned,
    updatedAt: DateTime(2026, 6, 14),
    plannedTaskId: 't-planned',
  );
  await add(
    'logged',
    status: kSuggestionLogged,
    updatedAt: DateTime(2026, 6, 13),
    plannedTaskId: 't-logged',
  );
  await add(
    'dismissed',
    status: kSuggestionDismissed,
    updatedAt: DateTime(2026, 6, 12),
  );
  await add(
    'muted',
    status: kSuggestionDismissed,
    updatedAt: DateTime(2026, 6, 11),
    dismissScope: kDismissScopeForever,
  );
  await add('missed', status: kSuggestionExpired, updatedAt: DateTime(2026, 6, 10));
  return db;
}

Future<void> _pump(WidgetTester tester, AppDatabase db) async {
  // Mirror watchHistory's filter with a one-shot .get() (a drift .watch().first
  // stream hangs under the testWidgets binding) — excludes 'new'/deleted, desc.
  // The repo's own filter is covered by suggestion_repository_test.
  final all = await db.select(db.suggestions).get();
  final history =
      all.where((s) => s.status != kSuggestionNew && !s.deleted).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  final areas = {for (final a in await db.select(db.areas).get()) a.id: a};
  final taskTypes = {
    for (final tt in await db.select(db.taskTypes).get()) tt.id: tt,
  };

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SuggestionHistoryScreen(),
      ),
      GoRoute(
        // History lives above the shell, so it opens the top-level 'task-view'
        // sibling (not the shell-nested 'task-detail') to avoid a duplicate
        // shell page key.
        path: '/task/:id',
        name: 'task-view',
        builder: (context, state) =>
            Scaffold(body: Text('TASK ${state.pathParameters['id']}')),
      ),
    ],
  );

  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          suggestionHistoryProvider.overrideWith(
            (ref) => Stream.value(history),
          ),
          taskTypesMapProvider.overrideWith((ref) => Stream.value(taskTypes)),
          areasMapProvider.overrideWith((ref) => Stream.value(areas)),
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
  await tester.pump(); // resolve override streams
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  testWidgets('shows every terminal status and excludes new', (tester) async {
    final db = await _buildDb();
    addTearDown(db.close);
    await _pump(tester, db);

    expect(find.text('Načrtovano'), findsOneWidget);
    expect(find.text('Zabeleženo'), findsOneWidget);
    expect(find.text('Opuščeno'), findsOneWidget); // dismissed season
    expect(find.text('Utišano'), findsOneWidget); // dismissed forever
    expect(find.text('Zamujeno'), findsOneWidget); // expired
    // The 'new' suggestion is excluded → 5 rows, not 6.
    expect(find.byType(ListTile), findsNWidgets(5));
  });

  testWidgets('tapping a planned row opens the created task', (tester) async {
    final db = await _buildDb();
    addTearDown(db.close);
    await _pump(tester, db);

    await tester.tap(find.text('Načrtovano'));
    await tester.pumpAndSettle();

    expect(find.text('TASK t-planned'), findsOneWidget);
  });

  testWidgets('tapping a dismissed row does not navigate', (tester) async {
    final db = await _buildDb();
    addTearDown(db.close);
    await _pump(tester, db);

    await tester.tap(find.text('Opuščeno'));
    await tester.pumpAndSettle();

    // Still on the history screen (no task opened).
    expect(find.text(t.suggestions.past_title), findsOneWidget);
    expect(find.textContaining('TASK'), findsNothing);
  });

  testWidgets('empty history shows the empty state', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await _pump(tester, db);

    expect(find.text(t.suggestions.past_empty), findsOneWidget);
  });
}
