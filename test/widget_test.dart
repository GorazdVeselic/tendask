import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/features/journal/presentation/journal_screen.dart';
import 'package:tendask/features/tasks/presentation/tasks_screen.dart';
import 'package:tendask/i18n/translations.g.dart';

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  testWidgets('nav shell — tab switch works', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/dnevnik',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => Scaffold(
            body: shell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: shell.goBranch,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.today), label: 'Dnevnik'),
                NavigationDestination(icon: Icon(Icons.check_box), label: 'Opravila'),
              ],
            ),
          ),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: '/dnevnik', builder: (_, _) => const JournalScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/opravila', builder: (_, _) => const TasksScreen()),
            ]),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dnevnik'), findsWidgets);
    await tester.tap(find.text('Opravila').last);
    await tester.pumpAndSettle();
    expect(find.text('Opravila'), findsWidgets);
  });
}
