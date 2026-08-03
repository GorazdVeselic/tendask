import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/app/router/app_router.dart';
import 'package:tendask/features/plus/application/plus_provider.dart';
import 'package:tendask/features/plus/application/plus_token.dart';
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

  // The real router's moon routes must carry the guard — the widget test
  // below exercises the guard's behavior, but only this check fails if
  // someone detaches `redirect:` from a route in app_router.dart.
  test('the real moon routes carry the redirect guard', () {
    final router = createAppRouter();
    GoRoute routeAt(String path) => router.configuration.routes
        .whereType<GoRoute>()
        .singleWhere((r) => r.path == path);

    // The two paid screens (T6.6) share the walled guard…
    for (final path in ['/moon-calendar', '/moon-finder']) {
      expect(routeAt(path).redirect, same(moonCalendarRedirect), reason: path);
    }
    // …while the settings are reachable without an entitlement on purpose: the
    // master switch there also governs the free phase chip, so walling this
    // route would make switching that chip off one-way again.
    expect(routeAt('/moon-settings').redirect, same(moonSettingsRedirect));
  });

  // Same for the Tendask+ screen (FR-20): its Settings card is flag-gated, but
  // a deep link would reach the route regardless.
  test('the real /tendask-plus route carries the redirect guard', () {
    final route = createAppRouter().configuration.routes
        .whereType<GoRoute>()
        .singleWhere((r) => r.path == '/tendask-plus');
    expect(route.redirect, same(tendaskPlusRedirect));
  });

  testWidgets('dark /tendask-plus deep link is guarded on the route', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const Text('HOME')),
        GoRoute(
          path: '/tendask-plus',
          redirect: tendaskPlusRedirect,
          builder: (_, _) => const Text('PLUS'),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    unawaited(router.push('/tendask-plus'));
    await tester.pumpAndSettle();

    expect(find.text(kTendaskPlusEnabled ? 'PLUS' : 'HOME'), findsOneWidget);
    expect(find.text(kTendaskPlusEnabled ? 'HOME' : 'PLUS'), findsNothing);
  });

  // The moon calendar (FR-19) must be guarded on the route itself, not only on
  // its CTAs: a deep link reaches the route past any flag-gated buttons. Uses
  // the real [moonCalendarRedirect] with no entitlement, so this stays green
  // when the flag flips on at ignition (T7) — it then asserts that the deep
  // link lands on the unlock screen instead of the calendar.
  testWidgets('a /moon-calendar deep link never opens it unentitled', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const Text('HOME')),
        GoRoute(path: '/tendask-plus', builder: (_, _) => const Text('PLUS')),
        GoRoute(
          path: '/moon-calendar',
          redirect: moonCalendarRedirect,
          builder: (_, _) => const Text('MOON'),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          plusProvider.overrideWith(
            (ref) => Stream.value(const PlusStatus.none()),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    unawaited(router.push('/moon-calendar'));
    await tester.pumpAndSettle();

    // Dark flag → home; lit flag without Tendask+ → the unlock screen. Either
    // way the calendar itself stays out of reach.
    expect(
      find.text(kMoonCalendarEnabled ? 'PLUS' : 'HOME'),
      findsOneWidget,
    );
    expect(find.text('MOON'), findsNothing);
  });
}
