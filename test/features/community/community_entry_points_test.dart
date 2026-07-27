import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/catalog_provider.dart';
import 'package:tendask/features/community/application/community_providers.dart';
import 'package:tendask/features/community/data/community_models.dart';
import 'package:tendask/features/community/data/community_stats.dart';
import 'package:tendask/features/community/presentation/widgets/community_home_section.dart';
import 'package:tendask/features/community/presentation/widgets/community_task_link_card.dart';
import 'package:tendask/features/plants/application/plants_providers.dart';
import 'package:tendask/i18n/translations.g.dart';

const _bucket = Bucket(resolution: CommunityResolution.r6, key: 'cellB');

TaskType _taskType(String id, String en, String icon) => TaskType(
  id: id,
  labels: '{"sl":"$en","en":"$en","de":"$en"}',
  icon: icon,
  category: 'other',
  requiresSubject: true,
  weatherSensitive: false,
  consumesSupplies: false,
  seasonal: true,
);

final _catalog = {
  'water': _taskType('water', 'Watering', '💧'),
  'prune': _taskType('prune', 'Pruning', '✂️'),
};

final _plants = {
  'apple': const Plant(
    id: 'apple',
    labels: '{"sl":"Jablana","en":"Apple","de":"Apfel"}',
    category: 'fruit',
    icon: '🍎',
  ),
};

UserPlant _userPlant(String id, String plantId) => UserPlant(
  id: id,
  userId: 'local',
  plantId: plantId,
  isCustom: false,
  updatedAt: DateTime.utc(2026),
  deleted: false,
  syncStatus: 'synced',
);

CommunityFeed _feed() => CommunityFeed(
  bucket: _bucket,
  population: 40,
  fetchedAt: DateTime.now(),
  items: const [
    CommunityFeedItem(
      taskTypeId: 'water',
      cohort: kCommunityCohortSite,
      distinctUsers7d: 20,
      intensity: CommunityIntensity.often,
    ),
    CommunityFeedItem(
      taskTypeId: 'prune',
      cohort: 'apple',
      distinctUsers7d: 6,
      intensity: CommunityIntensity.some,
    ),
  ],
);

/// A reliable curve (n = 50) peaking in week 20.
SeasonCurve _curve() => buildSeasonCurve(
  [
    {'year': 2025, 'iso_week': 18, 'first_user_count': 15},
    {'year': 2025, 'iso_week': 20, 'first_user_count': 25},
    {'year': 2025, 'iso_week': 22, 'first_user_count': 10},
  ],
  bucket: _bucket,
  currentYear: 2026,
)!;

/// Where a tap landed. A real router resolves the destination, and the
/// destination itself records the URL it was built with — the point of both
/// entry points is *where* they land, including whether the cohort travels as
/// `?plant=` or stays implicit (site work).
class _Landing {
  String? uri;
}

Future<_Landing> _pump(
  WidgetTester tester,
  Widget entry, {
  required List<Override> overrides,
}) async {
  final landing = _Landing();
  final router = GoRouter(
    initialLocation: '/host',
    routes: [
      GoRoute(path: '/host', builder: (context, state) => Scaffold(body: entry)),
      GoRoute(
        path: '/community',
        name: 'community',
        builder: (context, state) {
          landing.uri = state.uri.toString();
          return const Scaffold(body: Text('landing'));
        },
        routes: [
          GoRoute(
            path: 'task/:taskTypeId',
            name: 'community-task',
            builder: (context, state) {
              landing.uri = state.uri.toString();
              return const Scaffold(body: Text('detail'));
            },
          ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: overrides,
        child: MaterialApp.router(routerConfig: router),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return landing;
}

List<Override> _homeOverrides({
  CommunityFeed? feed,
  Map<String, UserPlant> garden = const {},
}) => <Override>[
  communityFeedProvider.overrideWith((ref) async => feed),
  taskTypesMapProvider.overrideWith((ref) => Stream.value(_catalog)),
  plantsMapProvider.overrideWith((ref) => Stream.value(_plants)),
  userPlantsMapProvider.overrideWith((ref) => Stream.value(garden)),
];

List<Override> _linkOverrides({
  required bool hasPlus,
  SeasonCurve? curve,
  MySeason mine = const MySeason(first: null, count: 0),
  String cohort = 'apple',
}) => <Override>[
  hasPlusProvider.overrideWithValue(hasPlus),
  communitySeasonCurveProvider('prune', cohort).overrideWith((ref) async => curve),
  mySeasonProvider('prune', cohort).overrideWith((ref) => Stream.value(mine)),
];

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  group('Home section', () {
    testWidgets('shows the hint from this garden and opens its template', (
      tester,
    ) async {
      final landing = await _pump(
        tester,
        const CommunityHomeSection(),
        overrides: _homeOverrides(
          feed: _feed(),
          garden: {'up1': _userPlant('up1', 'apple')},
        ),
      );

      // Watering leads the feed, but pruning is about a tree I actually have.
      expect(find.text('Pruning'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Watering'), findsNothing);

      await tester.tap(find.text('Pruning'));
      await tester.pumpAndSettle();

      expect(landing.uri, '/community/task/prune?plant=apple');
    });

    testWidgets('an empty garden falls back to the busiest row, site implicit', (
      tester,
    ) async {
      final landing = await _pump(
        tester,
        const CommunityHomeSection(),
        overrides: _homeOverrides(feed: _feed()),
      );

      expect(find.text('Watering'), findsOneWidget);

      await tester.tap(find.text('Watering'));
      await tester.pumpAndSettle();

      // Site work carries no plant, so the sentinel never reaches the URL.
      expect(landing.uri, '/community/task/water');
    });

    testWidgets('states the window, the scope and the population', (
      tester,
    ) async {
      await _pump(
        tester,
        const CommunityHomeSection(),
        overrides: _homeOverrides(feed: _feed()),
      );

      expect(find.textContaining(t.community.window_7d), findsOneWidget);
      expect(find.textContaining(t.community.scope.area), findsOneWidget);
      expect(find.textContaining(t.community.population(n: 40)), findsOneWidget);
    });

    testWidgets('"all from your area" opens the tab', (tester) async {
      final landing = await _pump(
        tester,
        const CommunityHomeSection(),
        overrides: _homeOverrides(feed: _feed()),
      );

      await tester.tap(find.textContaining(t.community.entry.see_all));
      await tester.pumpAndSettle();

      expect(landing.uri, '/community');
    });

    testWidgets('nothing to say leaves no heading and no gap on Home', (
      tester,
    ) async {
      await _pump(
        tester,
        const CommunityHomeSection(),
        overrides: _homeOverrides(feed: null),
      );

      expect(find.textContaining(t.community.entry.section.toUpperCase()),
          findsNothing);
      expect(find.byType(Card), findsNothing);
    });
  });

  group('Task detail card', () {
    testWidgets('without Plus it is a plain way in, no finding given away', (
      tester,
    ) async {
      final landing = await _pump(
        tester,
        const CommunityTaskLinkCard(taskTypeId: 'prune', cohort: 'apple'),
        overrides: _linkOverrides(
          hasPlus: false,
          curve: _curve(),
          mine: MySeason(first: DateTime(2026, 5, 11), count: 1),
        ),
      );

      expect(find.text(t.community.entry.cta), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);

      await tester.tap(find.text(t.community.entry.cta));
      await tester.pumpAndSettle();

      expect(landing.uri, '/community/task/prune?plant=apple');
    });

    testWidgets('with Plus the headline already says where you stand', (
      tester,
    ) async {
      await _pump(
        tester,
        const CommunityTaskLinkCard(taskTypeId: 'prune', cohort: 'apple'),
        overrides: _linkOverrides(
          hasPlus: true,
          curve: _curve(),
          // First completion in week 20: 15 of 50 started before that week and
          // 25 during it → mid-rank 0.55 → "~60 % started before you". The
          // cumulative 80 % answers a different question (by that date).
          mine: MySeason(first: DateTime(2026, 5, 11), count: 1),
        ),
      );

      expect(
        find.text(t.community.detail.you_percent(percent: 60)),
        findsOneWidget,
      );
      expect(find.text(t.community.entry.cta), findsOneWidget);
    });

    testWidgets('with Plus but no comparison it stays a plain way in', (
      tester,
    ) async {
      await _pump(
        tester,
        const CommunityTaskLinkCard(taskTypeId: 'prune', cohort: 'apple'),
        overrides: _linkOverrides(hasPlus: true, curve: null),
      );

      expect(find.text(t.community.entry.cta), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('site work keeps the sentinel out of the URL', (tester) async {
      final landing = await _pump(
        tester,
        const CommunityTaskLinkCard(
          taskTypeId: 'prune',
          cohort: kCommunityCohortSite,
        ),
        overrides: _linkOverrides(
          hasPlus: false,
          cohort: kCommunityCohortSite,
        ),
      );

      await tester.tap(find.text(t.community.entry.cta));
      await tester.pumpAndSettle();

      expect(landing.uri, '/community/task/prune');
    });
  });
}
