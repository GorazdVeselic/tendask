import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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

CommunityFeed _feed() => const CommunityFeed(
  bucket: _bucket,
  population: 40,
  items: [
    CommunityFeedItem(
      taskTypeId: 'water',
      plantId: '',
      distinctUsers7d: 20,
      intensity: CommunityIntensity.often,
    ),
    CommunityFeedItem(
      taskTypeId: 'mow',
      plantId: '',
      distinctUsers7d: 6,
      intensity: CommunityIntensity.some,
    ),
    CommunityFeedItem(
      taskTypeId: 'prune',
      plantId: '',
      distinctUsers7d: 2,
      intensity: CommunityIntensity.rare,
    ),
  ],
);

Future<void> _pump(
  WidgetTester tester, {
  required CommunityFeed? feed,
  bool hasPlus = true,
}) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          communityFeedProvider.overrideWith((ref) async => feed),
          taskTypesMapProvider.overrideWith((ref) => Stream.value(_catalog)),
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
    expect(find.text(t.community.intensity.often), findsOneWidget);
    expect(find.text(t.community.intensity.some), findsOneWidget);
    expect(find.text(t.community.intensity.rare), findsOneWidget);
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
    await _pump(tester, feed: _feed());

    await tester.tap(find.text(t.community.seg_you));
    await tester.pumpAndSettle();

    expect(find.text(t.community.empty_standing), findsOneWidget);
    expect(find.text('Watering'), findsNothing);
  });
}
