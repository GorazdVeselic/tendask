import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/catalog_provider.dart';
import 'package:tendask/features/community/application/community_providers.dart';
import 'package:tendask/features/community/data/community_models.dart';
import 'package:tendask/features/community/data/community_stats.dart';
import 'package:tendask/features/community/presentation/community_task_screen.dart';
import 'package:tendask/features/community/presentation/widgets/community_bars.dart';
import 'package:tendask/features/community/presentation/widgets/tease_overlay.dart';
import 'package:tendask/i18n/translations.g.dart';

const _r6 = Bucket(resolution: CommunityResolution.r6, key: 'cellB');
const _r5 = Bucket(resolution: CommunityResolution.r5, key: 'cellC');

TaskType _taskType() => const TaskType(
  id: 'prune',
  labels: '{"sl":"Obrez","en":"Pruning","de":"Schnitt"}',
  category: 'care',
  icon: '✂️',
  seasonal: true,
  requiresSubject: true,
  weatherSensitive: false,
  consumesSupplies: false,
);

Plant _plant() => const Plant(
  id: 'apple',
  labels: '{"sl":"Jablana","en":"Apple","de":"Apfel"}',
  category: 'fruit',
  icon: '🍎',
);

/// A curve with a reliable sample (n = 50) peaking in week 20.
SeasonCurve _curve({bool censored = false}) => buildSeasonCurve(
  [
    {'year': censored ? 2026 : 2025, 'iso_week': 18, 'first_user_count': 15},
    {'year': censored ? 2026 : 2025, 'iso_week': 20, 'first_user_count': 25},
    {'year': censored ? 2026 : 2025, 'iso_week': 22, 'first_user_count': 10},
  ],
  bucket: _r6,
  currentYear: 2026,
)!;

const _stats = FrequencyStats(
  bucket: _r6,
  p25: 2,
  p50: 3,
  p75: 4,
  unit: 'per_season',
  nUsers: 40,
  hist: {'1': 4, '2': 9, '3': 12, '4': 7, '5+': 3},
);

/// How many times the screen asked for a slice — a pull-to-refresh that does
/// not move this number is a gesture with no effect.
int _reads = 0;

Future<void> _pump(
  WidgetTester tester, {
  SeasonCurve? curve,
  FrequencyStats? stats = _stats,
  CommunityWeekly? weekly = const CommunityWeekly(
    bucket: _r5,
    distinctUsers7d: 9,
    intensity: CommunityIntensity.some,
  ),
  MySeason mine = const MySeason(first: null, count: 0),
  bool hasPlus = true,
  bool reached = true,
}) async {
  _reads = 0;
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: <Override>[
          taskTypesMapProvider.overrideWith(
            (ref) => Stream.value({'prune': _taskType()}),
          ),
          plantsMapProvider.overrideWith(
            (ref) => Stream.value({'apple': _plant()}),
          ),
          hasPlusProvider.overrideWithValue(hasPlus),
          communityReachedProvider.overrideWith((ref) async => reached),
          communitySeasonCurveProvider(
            'prune',
            'apple',
          ).overrideWith((ref) async {
            _reads++;
            return curve;
          }),
          communityFrequencyProvider(
            'prune',
            'apple',
          ).overrideWith((ref) async => stats),
          communityWeeklyProvider(
            'prune',
            'apple',
          ).overrideWith((ref) async => weekly),
          mySeasonProvider(
            'prune',
            'apple',
          ).overrideWith((ref) => Stream.value(mine)),
        ],
        child: const MaterialApp(
          home: CommunityTaskScreen(taskTypeId: 'prune', plantId: 'apple'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  testWidgets('names the act, its cohort and the scope', (tester) async {
    await _pump(tester, curve: _curve());

    expect(find.text('Pruning'), findsOneWidget); // app bar title
    expect(
      find.textContaining(t.community.scope.area),
      findsWidgets, // header + the "this week" row carry their own scope
    );
    expect(find.textContaining('Apple'), findsOneWidget);
  });

  testWidgets('a reliable sample states the rounded percentage', (
    tester,
  ) async {
    // First completion in week 20: 15 of 50 started before it, 25 during it →
    // mid-rank 0.55 → ~60 % started before the reader. (The cumulative 80 % is
    // the answer to a different question and still appears in the "by <date>"
    // line below the headline.)
    await _pump(
      tester,
      curve: _curve(),
      mine: MySeason(first: DateTime(2026, 5, 11), count: 3),
    );

    expect(find.text(t.community.detail.you_percent(percent: 60)), findsOneWidget);
    expect(
      find.textContaining(t.community.detail.by_date_percent(date: '11. 5.', percent: 80)),
      findsOneWidget,
    );
    expect(find.byType(CommunityBars), findsNWidgets(2)); // season + frequency
  });

  testWidgets('a thin sample stays descriptive, never a fake percentage', (
    tester,
  ) async {
    final thin = buildSeasonCurve(
      [
        {'year': 2025, 'iso_week': 20, 'first_user_count': 8},
      ],
      bucket: _r6,
      currentYear: 2026,
    )!;

    await _pump(
      tester,
      curve: thin,
      stats: null,
      mine: MySeason(first: DateTime(2026, 5, 11), count: 1),
    );

    // All 8 of them started in week 20 and so did the reader: the inclusive
    // F(20) = 1.0 used to call every single one of them "late", the first
    // included. Mid-rank puts them where they belong — in the middle.
    expect(find.text(t.community.detail.you_band.typical), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
  });

  testWidgets('not started yet says so instead of inventing a position', (
    tester,
  ) async {
    await _pump(tester, curve: _curve());

    expect(find.text(t.community.detail.not_started), findsOneWidget);
  });

  testWidgets('the first season is flagged as still moving', (tester) async {
    await _pump(tester, curve: _curve(censored: true));

    expect(find.text(t.community.detail.censored_note), findsOneWidget);
  });

  testWidgets('this week keeps its own scope label', (tester) async {
    await _pump(tester, curve: _curve());

    expect(
      find.text(t.community.detail.this_week.some),
      findsOneWidget,
    );
  });

  testWidgets('nothing anywhere is the honest empty state, not an error', (
    tester,
  ) async {
    await _pump(tester, curve: null, stats: null, weekly: null);

    expect(find.text(t.community.detail.no_curve), findsOneWidget);
    expect(find.text(t.community.empty_offline), findsNothing);
    expect(find.byType(CommunityBars), findsNothing);
  });

  testWidgets('a device that never read the scope blames itself, not the '
      'cohort', (tester) async {
    await _pump(
      tester,
      curve: null,
      stats: null,
      weekly: null,
      reached: false,
    );

    expect(find.text(t.community.empty_offline), findsOneWidget);
    expect(find.text(t.community.detail.no_curve), findsNothing);
  });

  testWidgets('the detail re-reads its slices on a pull', (tester) async {
    await _pump(tester, curve: null, stats: null, weekly: null);
    final before = _reads;

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(_reads, greaterThan(before));
  });

  testWidgets('without Plus the whole detail is teased', (tester) async {
    await _pump(tester, curve: _curve(), hasPlus: false);

    expect(find.byType(TeaseOverlay), findsOneWidget);
    expect(find.text(t.community.tease.title), findsOneWidget);
    // The redeem affordance stays inert until FR-20, and never links out.
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, t.community.tease.redeem),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('the explain sheet spells out how the numbers are read', (
    tester,
  ) async {
    await _pump(tester, curve: _curve());

    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();

    expect(find.text(t.community.detail.explain.title), findsOneWidget);
    expect(find.text(t.community.detail.explain.cohort), findsOneWidget);
    expect(find.text(t.community.detail.explain.descriptive), findsOneWidget);
  });
}
