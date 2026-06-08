import 'dart:async' show unawaited;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/catalog_provider.dart';
import 'package:tendask/features/areas/application/areas_providers.dart';
import 'package:tendask/features/journal/application/notes_providers.dart';
import 'package:tendask/features/journal/data/notes_repository.dart';
import 'package:tendask/features/journal/presentation/journal_screen.dart';
import 'package:tendask/features/journal/presentation/note_form_screen.dart';
import 'package:tendask/features/plants/application/plants_providers.dart';
import 'package:tendask/features/tasks/application/tasks_providers.dart';
import 'package:tendask/i18n/translations.g.dart';

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  // ── NoteFormScreen saves a standalone note ─────────────────────────────────
  group('NoteFormScreen', () {
    testWidgets('entering text + save creates a note in DB', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = NotesRepository(db);

      // Two routes so _save()'s context.pop() has somewhere to return to.
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: Text('home')),
          ),
          GoRoute(path: '/note', builder: (_, _) => const NoteFormScreen()),
        ],
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: ProviderScope(
            overrides: [
              notesRepositoryProvider.overrideWith((ref) => repo),
              // Area is optional; an empty map keeps the picker out of the way.
              areasMapProvider.overrideWith((ref) => Stream.value({})),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        ),
      );

      unawaited(router.push('/note'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'Rjave pege na paradižniku',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Shrani opombo'));
      await tester.pumpAndSettle();

      final rows = await db.select(db.notes).get();
      expect(rows, hasLength(1));
      expect(rows.first.content, 'Rjave pege na paradižniku');
      expect(rows.first.deleted, false);
    });
  });

  // ── JournalScreen view switch: Timeline → Month ────────────────────────────
  group('JournalScreen', () {
    testWidgets('switching to Mesec shows the month calendar', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => const JournalScreen())],
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: ProviderScope(
            overrides: [
              completedTasksProvider.overrideWith(
                (ref) => Stream.value(<Task>[]),
              ),
              notesProvider.overrideWith((ref) => Stream.value(<Note>[])),
              allTasksProvider.overrideWith((ref) => Stream.value(<Task>[])),
              taskTypesMapProvider.overrideWith(
                (ref) => Stream.value(<String, TaskType>{}),
              ),
              areasMapProvider.overrideWith((ref) => Stream.value({})),
              allTaskSubjectsProvider.overrideWith(
                (ref) => Stream.value(<TaskSubject>[]),
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
      await tester.pumpAndSettle();

      // Timeline is the default view → month hint not shown yet.
      expect(find.textContaining('Tapni na dan'), findsNothing);

      // Switch to the Mesec segment.
      await tester.tap(find.text('Mesec'));
      await tester.pumpAndSettle();

      // Month calendar hint is now visible.
      expect(find.textContaining('Tapni na dan'), findsOneWidget);
    });
  });
}
