import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/catalog_provider.dart';
import 'package:tendask/features/community/application/community_providers.dart';
import 'package:tendask/features/community/data/community_models.dart';
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

CommunityFeed _feed() => const CommunityFeed(
  bucket: _bucket,
  population: 40,
  items: [
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

Future<void> _pump(
  WidgetTester tester, {
  required CommunityFeed? feed,
  bool hasPlus = true,
  List<CommunityStanding> standings = const [],
}) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          communityFeedProvider.overrideWith((ref) async => feed),
          communityStandingsProvider.overrideWith((ref) async => standings),
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

    expect(
      find.textContaining(t.community.window_7d),
      findsOneWidget,
    );
    // r6 reads as "in your area", and the population must be visible (§7.4/7.7).
    expect(find.textContaining(t.community.scope.area), findsOneWidget);
    expect(
      find.textContaining(t.community.population(n: 40)),
      findsOneWidget,
    );
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
  });

  testWidgets('the "where you stand" segment switches the body', (tester) async {
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
}
