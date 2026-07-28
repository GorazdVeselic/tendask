import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/catalog_provider.dart';
import 'package:tendask/core/date_format.dart';
import 'package:tendask/features/community/application/community_providers.dart';
import 'package:tendask/features/community/data/community_models.dart';
import 'package:tendask/features/community/data/community_repository.dart';
import 'package:tendask/features/community/presentation/community_landing_screen.dart';
import 'package:tendask/features/community/presentation/widgets/tease_overlay.dart';
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
  defaultCadence: null,
);

final _catalog = {
  'water': _taskType('water', 'Watering', '💧'),
  'mow': _taskType('mow', 'Mowing', '🌾'),
  'prune': _taskType('prune', 'Pruning', '✂️'),
};

Plant _plant(String id, String en, String icon) => Plant(
  id: id,
  labels: '{"sl":"$en","en":"$en","de":"$en"}',
  category: 'fruit',
  icon: icon,
);

final _plants = {'apple': _plant('apple', 'Apple', '🍎')};

CommunityFeed _feed({DateTime? fetchedAt}) => CommunityFeed(
  bucket: _bucket,
  population: 40,
  fetchedAt: fetchedAt ?? DateTime.now(),
  items: const [
    CommunityFeedItem(
      taskTypeId: 'water',
      cohort: kCommunityCohortSite,
      distinctUsers7d: 20,
      intensity: CommunityIntensity.often,
    ),
    CommunityFeedItem(
      taskTypeId: 'mow',
      cohort: kCommunityCohortSite,
      distinctUsers7d: 6,
      intensity: CommunityIntensity.some,
    ),
    CommunityFeedItem(
      taskTypeId: 'prune',
      cohort: 'apple',
      distinctUsers7d: 2,
      intensity: CommunityIntensity.rare,
    ),
  ],
);

/// How many times the screen asked for a slice — a pull-to-refresh that does
/// not move this number is a gesture with no effect.
int _reads = 0;

/// Counts the one thing re-running the providers cannot prove: that the pull
/// reached the data layer. Invalidation alone re-reads the same day-cached
/// slice, so `_reads` moves while nothing refetches (najdba N19).
class _SpyRepository extends CommunityRepository {
  _SpyRepository(super.db, super.fetch);
  int refreshRequests = 0;
  @override
  void requestRefresh() {
    refreshRequests++;
    super.requestRefresh();
  }
}

Future<void> _pump(
  WidgetTester tester, {
  required CommunityFeed? feed,
  bool hasPlus = true,
  bool reached = true,
  List<CommunityStanding> standings = const [],
  StandingsGap? gap = StandingsGap.thinNeighbourhood,
  CommunityRepository? repo,
}) async {
  _reads = 0;
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          if (repo != null) communityRepositoryProvider.overrideWithValue(repo),
          communityFeedProvider.overrideWith((ref) async {
            _reads++;
            return feed;
          }),
          communityReachedProvider.overrideWith((ref) async => reached),
          communityStandingsProvider.overrideWith((ref) async {
            _reads++;
            return (rows: standings, gap: standings.isEmpty ? gap : null);
          }),
          taskTypesMapProvider.overrideWith((ref) => Stream.value(_catalog)),
          plantsMapProvider.overrideWith((ref) => Stream.value(_plants)),
          hasPlusProvider.overrideWithValue(hasPlus),
        ],
        child: const MaterialApp(home: CommunityLandingScreen()),
      ),
    ),
  );
  await tester.pump(); // resolve the override future/stream
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  testWidgets('feed lists task types with a qualitative intensity', (
    tester,
  ) async {
    await _pump(tester, feed: _feed());

    expect(find.text('Watering'), findsOneWidget);
    expect(find.text('Mowing'), findsOneWidget);
    expect(find.text('Pruning'), findsOneWidget);
    // A plant cohort names its plant — "pruning" alone spans apple and raspberry.
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text(t.community.intensity.often), findsOneWidget);
    expect(find.text(t.community.intensity.some), findsOneWidget);
    expect(find.text(t.community.intensity.rare), findsOneWidget);
  });

  testWidgets('every feed row opens its own comparison template', (
    tester,
  ) async {
    await _pump(tester, feed: _feed());

    // The real route only exists behind kSuggestionsEnabled, so this asserts
    // the rows carry a destination rather than driving a hand-built router.
    final tiles = tester.widgetList<ListTile>(find.byType(ListTile));
    expect(tiles, hasLength(3));
    expect(tiles.every((tile) => tile.onTap != null), isTrue);
  });

  testWidgets('meta row states the window, the scope and the population', (
    tester,
  ) async {
    await _pump(tester, feed: _feed());

    expect(find.textContaining(t.community.window_7d), findsOneWidget);
    // r6 reads as "in your area", and the population must be visible (§7.4/7.7).
    expect(find.textContaining(t.community.scope.area), findsOneWidget);
    expect(find.textContaining(t.community.population(n: 40)), findsOneWidget);
  });

  testWidgets('with Plus nothing is teased', (tester) async {
    await _pump(tester, feed: _feed());

    expect(find.byType(TeaseOverlay), findsNothing);
    expect(find.text(t.community.tease.title), findsNothing);
  });

  testWidgets('without Plus only the first row stays readable', (tester) async {
    await _pump(tester, feed: _feed(), hasPlus: false);

    expect(find.byType(TeaseOverlay), findsOneWidget);
    expect(find.text(t.community.tease.title), findsOneWidget);
    // First row outside the blur, the other two inside it.
    final blurred = find.byType(ImageFiltered);
    expect(
      find.descendant(of: blurred, matching: find.byType(ListTile)),
      findsNWidgets(2),
    );
    expect(find.byType(ListTile), findsNWidgets(3));
  });

  testWidgets('the tease offers only a neutral, inert redeem affordance', (
    tester,
  ) async {
    await _pump(tester, feed: _feed(), hasPlus: false);

    // Wording is guarded across locales by test/i18n/community_i18n_test.dart;
    // here the point is that nothing can be tapped towards a purchase.
    expect(find.text(t.community.tease.redeem), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('cold start says there are not enough gardeners yet', (
    tester,
  ) async {
    await _pump(tester, feed: null);

    expect(find.text(t.community.empty_feed), findsOneWidget);
    expect(find.text(t.community.empty_offline), findsNothing);
  });

  testWidgets('a device that never reached the cloud claims nothing about '
      'the neighbourhood', (tester) async {
    await _pump(tester, feed: null, reached: false);

    expect(find.text(t.community.empty_offline), findsOneWidget);
    expect(find.text(t.community.empty_feed), findsNothing);
  });

  testWidgets('the same distinction holds on "where you stand"', (
    tester,
  ) async {
    await _pump(tester, feed: null, reached: false);
    await tester.tap(find.text(t.community.seg_you));
    await tester.pumpAndSettle();

    expect(find.text(t.community.empty_offline), findsOneWidget);
    expect(find.text(t.community.empty_standing), findsNothing);
  });

  testWidgets('a slice read today carries no date line', (tester) async {
    await _pump(tester, feed: _feed());

    expect(find.textContaining(t.community.data_from(date: '')), findsNothing);
  });

  testWidgets('a slice from another day says which day it is from', (
    tester,
  ) async {
    final stale = DateTime.now().subtract(const Duration(days: 2));
    await _pump(tester, feed: _feed(fetchedAt: stale));

    expect(
      find.text(t.community.data_from(date: formatDmy(stale))),
      findsOneWidget,
    );
  });

  testWidgets('an empty state still accepts the pull-to-refresh gesture', (
    tester,
  ) async {
    await _pump(tester, feed: null, reached: false);
    final before = _reads;

    await tester.fling(
      find.text(t.community.empty_offline),
      const Offset(0, 300),
      1000,
    );
    await tester.pumpAndSettle();

    // The state a user is most likely to pull on: a bare Center would swallow
    // the gesture and the slice would never be re-read.
    expect(_reads, greaterThan(before));
  });

  testWidgets('a fed list can be pulled too', (tester) async {
    await _pump(tester, feed: _feed());
    final before = _reads;

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(_reads, greaterThan(before));
  });

  testWidgets('the pull also tells the data layer to leave the cache', (
    tester,
  ) async {
    // The assertion above passes even when the pull is a placebo: the providers
    // re-run and read the very slice they meant to replace. This is the half
    // that actually failed on device.
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final spy = _SpyRepository(db, null);

    await _pump(tester, feed: _feed(), repo: spy);
    expect(spy.refreshRequests, 0);

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(spy.refreshRequests, 1);
  });

  testWidgets('"where you stand" refreshes on its own pull', (tester) async {
    await _pump(tester, feed: _feed());
    await tester.tap(find.text(t.community.seg_you));
    await tester.pumpAndSettle();
    final before = _reads;

    await tester.fling(
      find.text(t.community.empty_standing),
      const Offset(0, 300),
      1000,
    );
    await tester.pumpAndSettle();

    expect(_reads, greaterThan(before));
  });

  testWidgets('the "where you stand" segment switches the body', (
    tester,
  ) async {
    await _pump(
      tester,
      feed: _feed(),
      standings: const [
        CommunityStanding(
          taskTypeId: 'prune',
          cohort: 'apple',
          band: CommunityTiming.early,
          scope: CommunityResolution.r6,
        ),
      ],
    );

    await tester.tap(find.text(t.community.seg_you));
    await tester.pumpAndSettle();

    expect(find.text('Pruning'), findsOneWidget);
    expect(find.text(t.community.standing.band.early), findsOneWidget);
    expect(find.text('Watering'), findsNothing);
  });

  testWidgets('nothing comparable yet says so instead of listing blanks', (
    tester,
  ) async {
    await _pump(tester, feed: _feed());

    await tester.tap(find.text(t.community.seg_you));
    await tester.pumpAndSettle();

    expect(find.text(t.community.empty_standing), findsOneWidget);
  });

  testWidgets('an empty own history does not blame the neighbourhood', (
    tester,
  ) async {
    await _pump(tester, feed: _feed(), gap: StandingsGap.noHistory);

    await tester.tap(find.text(t.community.seg_you));
    await tester.pumpAndSettle();

    expect(find.text(t.community.empty_standing_no_history), findsOneWidget);
    expect(find.text(t.community.empty_standing), findsNothing);
  });

  testWidgets('history of the wrong kind does not blame it either', (
    tester,
  ) async {
    // The measured case (najdba N17): three waterings, 40 neighbours, and the
    // screen still said there were too few gardeners.
    await _pump(tester, feed: _feed(), gap: StandingsGap.noSeasonalHistory);

    await tester.tap(find.text(t.community.seg_you));
    await tester.pumpAndSettle();

    expect(find.text(t.community.empty_standing_no_seasonal), findsOneWidget);
    expect(find.text(t.community.empty_standing), findsNothing);
  });
}
