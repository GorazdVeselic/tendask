import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/features/community/data/community_models.dart';
import 'package:tendask/features/community/presentation/widgets/community_standing_list.dart';
import 'package:tendask/features/community/presentation/widgets/tease_overlay.dart';
import 'package:tendask/i18n/translations.g.dart';

final _catalog = {
  'prune': const TaskType(
    id: 'prune',
    labels: '{"sl":"Obrez","en":"Pruning","de":"Schnitt"}',
    icon: '✂️',
    category: 'care',
    requiresSubject: true,
    weatherSensitive: false,
    consumesSupplies: false,
    seasonal: true,
  ),
  'mow': const TaskType(
    id: 'mow',
    labels: '{"sl":"Košnja","en":"Mowing","de":"Mähen"}',
    icon: '🌾',
    category: 'lawn_care',
    requiresSubject: true,
    weatherSensitive: false,
    consumesSupplies: false,
    seasonal: true,
  ),
};

final _plants = {
  'apple': const Plant(
    id: 'apple',
    labels: '{"sl":"Jablana","en":"Apple","de":"Apfel"}',
    category: 'fruit',
    icon: '🍎',
  ),
};

const _rows = [
  CommunityStanding(
    taskTypeId: 'prune',
    cohort: 'apple',
    band: CommunityTiming.early,
    scope: CommunityResolution.r6,
  ),
  CommunityStanding(
    taskTypeId: 'mow',
    cohort: kCommunityCohortSite,
    band: CommunityTiming.late,
    scope: CommunityResolution.climate,
  ),
];

class _Landing {
  String? uri;
}

Future<_Landing> _pump(
  WidgetTester tester, {
  List<CommunityStanding> rows = _rows,
  bool hasPlus = true,
}) async {
  final landing = _Landing();
  final router = GoRouter(
    initialLocation: '/host',
    routes: [
      GoRoute(
        path: '/host',
        builder: (context, state) => Scaffold(
          body: CommunityStandingList(
            standings: rows,
            catalog: _catalog,
            plants: _plants,
            hasPlus: hasPlus,
          ),
        ),
      ),
      GoRoute(
        path: '/community/task/:taskTypeId',
        name: 'community-task',
        builder: (context, state) {
          landing.uri = state.uri.toString();
          return const Scaffold(body: Text('detail'));
        },
      ),
    ],
  );
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: const <Override>[],
        child: MaterialApp.router(routerConfig: router),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return landing;
}

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  testWidgets('each row names the act, the cohort and its own scope', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Pruning'), findsOneWidget);
    expect(find.text('Mowing'), findsOneWidget);
    // Every cohort widened on its own, so the scope belongs on the row.
    expect(
      find.text('Apple · ${t.community.scope.area}'),
      findsOneWidget,
    );
    expect(find.text(t.community.scope.climate), findsOneWidget);
  });

  testWidgets('the band is a word, never a percentage without its sample', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text(t.community.standing.band.early), findsOneWidget);
    expect(find.text(t.community.standing.band.late), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
  });

  testWidgets('a row opens its own comparison template', (tester) async {
    final landing = await _pump(tester);

    await tester.tap(find.text('Pruning'));
    await tester.pumpAndSettle();

    expect(landing.uri, '/community/task/prune?plant=apple');
  });

  testWidgets('site work keeps the sentinel out of the URL', (tester) async {
    final landing = await _pump(tester);

    await tester.tap(find.text('Mowing'));
    await tester.pumpAndSettle();

    expect(landing.uri, '/community/task/mow');
  });

  testWidgets('without Plus only the first row stays readable', (tester) async {
    await _pump(tester, hasPlus: false);

    expect(find.byType(TeaseOverlay), findsOneWidget);
    final blurred = find.byType(ImageFiltered);
    expect(
      find.descendant(of: blurred, matching: find.byType(ListTile)),
      findsOneWidget,
    );
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('the footnote says why the list is short', (tester) async {
    await _pump(tester);

    expect(find.text(t.community.standing.footnote), findsOneWidget);
  });
}
