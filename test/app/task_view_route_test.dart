import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Regression guard for BUG-004: a screen ABOVE the shell (e.g. plant-detail)
/// must push the top-level twin `/task/:id` (task-view), not the shell-nested
/// `/tasks/:id` (task-detail). Pushing the nested route from above the shell
/// rebuilds the shell page and duplicates its page key → Navigator assertion.
void main() {
  // Mirrors the real router shape: a shell with a nested '/tasks/:id', a
  // top-level '/plant/:id' (above the shell) and the top-level twin '/task/:id'.
  GoRouter buildRouter() => GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => shell,
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (_, _) => const Text('HOME'))],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (_, _) => const Text('TASKS'),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, s) => Text('DETAIL ${s.pathParameters['id']}'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/plant/:id', builder: (_, _) => const Text('PLANT')),
      GoRoute(
        path: '/task/:id',
        builder: (_, s) => Text('TASK VIEW ${s.pathParameters['id']}'),
      ),
    ],
  );

  testWidgets('top-level task-view opens from above the shell without a '
      'duplicate page key', (tester) async {
    final router = buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    unawaited(router.push('/plant/p1'));
    await tester.pumpAndSettle();
    unawaited(router.push('/task/t1'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('TASK VIEW t1'), findsOneWidget);
  });
}
