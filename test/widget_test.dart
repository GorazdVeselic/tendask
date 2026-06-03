import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/catalog_provider.dart';
import 'package:tendask/features/areas/application/areas_providers.dart';
import 'package:tendask/features/journal/application/notes_providers.dart';
import 'package:tendask/features/journal/presentation/journal_screen.dart';
import 'package:tendask/features/plants/application/plants_providers.dart';
import 'package:tendask/features/tasks/application/tasks_providers.dart';
import 'package:tendask/features/tasks/presentation/tasks_screen.dart';
import 'package:tendask/i18n/translations.g.dart';

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  testWidgets('nav shell — tab switch works', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/journal',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => Scaffold(
            body: shell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: shell.goBranch,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.today), label: 'Journal'),
                NavigationDestination(icon: Icon(Icons.check_box), label: 'Tasks'),
              ],
            ),
          ),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: '/journal', builder: (_, _) => const JournalScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/tasks', builder: (_, _) => const TasksScreen()),
            ]),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          overrides: [
            // Provide empty data so JournalScreen and TasksScreen resolve immediately
            pendingTasksProvider
                .overrideWith((ref) => Stream.value(<Task>[])),
            completedTasksProvider
                .overrideWith((ref) => Stream.value(<Task>[])),
            notesProvider.overrideWith((ref) => Stream.value(<Note>[])),
            taskTypesMapProvider
                .overrideWith((ref) async => <String, TaskType>{}),
            areasMapProvider
                .overrideWith((ref) => Stream.value(<String, Area>{})),
            allTaskSubjectsProvider
                .overrideWith((ref) => Stream.value(<TaskSubject>[])),
            userPlantsMapProvider
                .overrideWith((ref) => Stream.value(<String, UserPlant>{})),
            plantsMapProvider.overrideWith((ref) async => <String, Plant>{}),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Journal'), findsWidgets);
    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();
    expect(find.text('Tasks'), findsWidgets);
  });
}
