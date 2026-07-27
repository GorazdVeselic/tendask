import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/app/router/app_router.dart';

/// Okolica's detail (`community-task`) is nested inside the Okolica shell
/// branch, but its two main entry points push it from OTHER branches: the Home
/// band (branch 0) and the task detail (branch 1) — skupnost-agregacija.md
/// §12.1. That is the shape that already broke this app once: pushing a
/// shell-nested route from outside its branch rebuilds the shell page and
/// duplicates its page key → Navigator assertion (BUG-004, and the comment in
/// suggestion_history_screen.dart). Both feature and route are flag-dark, so
/// this path has never run in the app.
///
/// Mirrors the real router shape (five branches, community nested in the last)
/// with placeholder screens — the router structure is what is under test, not
/// the screens.
void main() {
  // The structural group builds a real GoRouter outside a widget pump.
  TestWidgetsFlutterBinding.ensureInitialized();

  GoRouter buildRouter() => GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => Scaffold(
          body: shell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: shell.goBranch,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'home'),
              NavigationDestination(icon: Icon(Icons.list), label: 'tasks'),
              NavigationDestination(icon: Icon(Icons.book), label: 'journal'),
              NavigationDestination(icon: Icon(Icons.grass), label: 'areas'),
              NavigationDestination(icon: Icon(Icons.hexagon), label: 'nearby'),
            ],
          ),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (_, _) => const Text('HOME'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                name: 'tasks',
                builder: (_, _) => const Text('TASKS'),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'task-detail',
                    builder: (_, s) => Text('TASK ${s.pathParameters['id']}'),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/journal',
                name: 'journal',
                builder: (_, _) => const Text('JOURNAL'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/areas',
                name: 'areas',
                builder: (_, _) => const Text('AREAS'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/community',
                name: 'community',
                builder: (_, _) => const Text('NEARBY'),
                routes: [
                  GoRoute(
                    path: 'task/:taskTypeId',
                    name: 'community-task',
                    builder: (_, s) => Text(
                      'COMPARE ${s.pathParameters['taskTypeId']}'
                      '${s.uri.queryParameters['plant'] == null ? '' : ' · ${s.uri.queryParameters['plant']}'}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  /// What the Home band and the task-detail card do: pushNamed with the cohort
  /// as a query parameter.
  void pushCompare(GoRouter router, {String? plant}) {
    // Site work carries no plant, exactly as CommunityFeedRow builds it.
    final query = <String, String>{};
    if (plant != null) query['plant'] = plant;
    unawaited(
      router.pushNamed(
        'community-task',
        pathParameters: {'taskTypeId': 'prune'},
        queryParameters: query,
      ),
    );
  }

  testWidgets('Home → comparison → back leaves Home intact', (tester) async {
    final router = buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);

    pushCompare(router, plant: 'apple');
    await tester.pumpAndSettle();
    expect(find.text('COMPARE prune · apple'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('task detail → comparison → back leaves the task open', (
    tester,
  ) async {
    final router = buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    unawaited(
      router.pushNamed('task-detail', pathParameters: {'id': 't1'}),
    );
    await tester.pumpAndSettle();
    expect(find.text('TASK t1'), findsOneWidget);

    pushCompare(router, plant: 'apple');
    await tester.pumpAndSettle();
    expect(find.text('COMPARE prune · apple'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    // The pushed task detail is still under it, not collapsed to the branch root.
    expect(find.text('TASK t1'), findsOneWidget);
  });

  testWidgets('switching tabs after a cross-branch push keeps every branch', (
    tester,
  ) async {
    final router = buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    pushCompare(router, plant: 'apple');
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();

    // The bottom nav is the path a user takes right after backing out; a
    // duplicated shell page key surfaces here as a Navigator assertion.
    await tester.tap(find.text('areas'));
    await tester.pumpAndSettle();
    expect(find.text('AREAS'), findsOneWidget);

    await tester.tap(find.text('nearby'));
    await tester.pumpAndSettle();
    expect(find.text('NEARBY'), findsOneWidget);

    await tester.tap(find.text('home'));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('site work carries no cohort and still resolves', (tester) async {
    final router = buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    pushCompare(router);
    await tester.pumpAndSettle();

    expect(find.text('COMPARE prune'), findsOneWidget);
  });

  group('the mirror matches the real route tree', () {
    /// Route names of the branch that owns Okolica, in the real router.
    List<String?> communityBranchNames({required bool community}) {
      final shell =
          createAppRouter(community: community).configuration.routes.first
              as StatefulShellRoute;
      return [
        for (final branch in shell.branches)
          for (final route in branch.routes)
            if (route is GoRoute && route.path == '/community') ...[
              route.name,
              for (final nested in route.routes)
                if (nested is GoRoute) nested.name,
            ],
      ];
    }

    test('Okolica appears with the flag and nowhere without it', () {
      expect(communityBranchNames(community: true), [
        'community',
        'community-task',
      ]);
      expect(communityBranchNames(community: false), isEmpty);
    });

    test('the flag adds exactly one branch, and it is the last', () {
      List<StatefulShellBranch> branches({required bool community}) =>
          (createAppRouter(community: community).configuration.routes.first
                  as StatefulShellRoute)
              .branches;

      final off = branches(community: false);
      final on = branches(community: true);
      expect(on.length, off.length + 1);
      // Last: MainShell appends the tab last, and NavigationBar matches tabs to
      // branches by index — inserting it anywhere else silently reroutes them.
      final last = on.last.routes.single as GoRoute;
      expect(last.path, '/community');
    });

  });

  testWidgets('the "see all" button switches branch instead of stacking', (
    tester,
  ) async {
    final router = buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    // goNamed, as the Home band's "All from your area" does.
    router.goNamed('community');
    await tester.pumpAndSettle();
    expect(find.text('NEARBY'), findsOneWidget);

    await tester.tap(find.text('home'));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });
}
