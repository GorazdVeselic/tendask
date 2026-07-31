import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/app/router/app_router.dart';
import 'package:tendask/core/config.dart';

/// Regression guard: a full-screen "create" route must NOT live under the same
/// single-segment prefix as a shell detail route (`/areas/:id`), or go_router
/// resolves `/areas/new` to the detail with id="new" (endless loader / crash).
/// Create routes therefore use a distinct prefix (`/area-new`, `/task-new`).
void main() {
  GoRouter buildRouter(String createPath) => GoRouter(
    initialLocation: '/areas',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => shell,
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/areas',
                builder: (_, _) => const Text('LIST'),
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
      GoRoute(path: createPath, builder: (_, _) => const Text('NEW FORM')),
    ],
  );

  testWidgets('distinct-prefix create route resolves to the form', (
    tester,
  ) async {
    final router = buildRouter('/area-new');
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    unawaited(router.push('/area-new'));
    await tester.pumpAndSettle();

    expect(find.text('NEW FORM'), findsOneWidget);
    expect(find.textContaining('DETAIL'), findsNothing);
  });

  testWidgets(
    'colliding /areas/new would resolve to detail (the bug we avoid)',
    (tester) async {
      final router = buildRouter('/areas/new');
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      unawaited(router.push('/areas/new'));
      await tester.pumpAndSettle();

      // Demonstrates the collision: ':id' captures "new" → detail, not the form.
      expect(find.text('DETAIL new'), findsOneWidget);
    },
  );

  // The moon calendar (FR-19) must be guarded on the route itself, not only on
  // its CTAs: a deep link reaches the route past any flag-gated buttons. Uses
  // the real [moonCalendarRedirect], so this stays green when the flag flips
  // on at ignition (T7) — it then asserts the route opens instead.
  testWidgets('dark /moon-calendar deep link is guarded on the route', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const Text('HOME')),
        GoRoute(
          path: '/moon-calendar',
          redirect: moonCalendarRedirect,
          builder: (_, _) => const Text('MOON'),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    unawaited(router.push('/moon-calendar'));
    await tester.pumpAndSettle();

    expect(
      find.text(kMoonCalendarEnabled ? 'MOON' : 'HOME'),
      findsOneWidget,
    );
    expect(
      find.text(kMoonCalendarEnabled ? 'HOME' : 'MOON'),
      findsNothing,
    );
  });
}
