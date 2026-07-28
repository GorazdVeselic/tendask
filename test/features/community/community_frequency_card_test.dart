import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/features/community/data/community_models.dart';
import 'package:tendask/features/community/presentation/widgets/community_bars.dart';
import 'package:tendask/features/community/presentation/widgets/community_frequency_card.dart';
import 'package:tendask/i18n/translations.g.dart';

const _bucket = Bucket(resolution: CommunityResolution.r6, key: 'cellB');

FrequencyStats _stats(
  Map<String, int> hist, {
  double p25 = 2,
  double p75 = 4,
}) => FrequencyStats(
  bucket: _bucket,
  p25: p25,
  p50: 3,
  p75: p75,
  unit: 'per_season',
  nUsers: 40,
  hist: hist,
);

Future<CommunityBars> _pump(
  WidgetTester tester, {
  required Map<String, int> hist,
  required int myCount,
}) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: MaterialApp(
        home: Scaffold(
          body: CommunityFrequencyCard(stats: _stats(hist), myCount: myCount),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return tester.widget<CommunityBars>(find.byType(CommunityBars));
}

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  testWidgets('a band nobody landed in is still drawn, in its place', (
    tester,
  ) async {
    // The aggregate omits empty bands (migration 0009 jsonb_object_agg), so a
    // chart built from the published keys drew '1', '3', '5+' side by side and
    // read as a continuous distribution.
    final bars = await _pump(
      tester,
      hist: {'1': 4, '3': 12, '5+': 3},
      myCount: 1,
    );

    expect(bars.axis, kCommunityFrequencyBands);
    expect(bars.values, [4.0, 0.0, 12.0, 0.0, 3.0]);
  });

  testWidgets('my own bar is my count, not the "5+" fallback', (tester) async {
    // Twice is twice. With the bands read off the histogram, a missing '2' sent
    // the marker to the last bar — telling the reader they were in the top band.
    final bars = await _pump(
      tester,
      hist: {'1': 4, '3': 12, '5+': 3},
      myCount: 2,
    );

    expect(bars.meIndex, 1);
    expect(bars.values[1], 0.0); // nobody else did it exactly twice
  });

  testWidgets('the cap keeps counts of five and more on the last bar', (
    tester,
  ) async {
    final five = await _pump(tester, hist: {'1': 4, '5+': 3}, myCount: 5);
    expect(five.meIndex, 4);

    final many = await _pump(tester, hist: {'1': 4, '5+': 3}, myCount: 12);
    expect(many.meIndex, 4);
  });

  testWidgets('no completions of my own leaves every bar unmarked', (
    tester,
  ) async {
    final bars = await _pump(tester, hist: {'1': 4, '2': 9}, myCount: 0);
    expect(bars.meIndex, isNull);
  });

  testWidgets('equal quartiles read as one number, not a range', (
    tester,
  ) async {
    // Not an edge case: when everyone does it equally often — the settled,
    // most typical pattern — p25 and p75 land on the same value and the card
    // printed "2–2×" (najdba N21).
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: CommunityFrequencyCard(
              stats: _stats(const {'2': 40}, p25: 2, p75: 2.4),
              myCount: 2,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(t.community.detail.freq_single(count: '2')),
      findsOneWidget,
    );
    expect(
      find.text(t.community.detail.freq_range(from: '2', to: '2')),
      findsNothing,
    );
  });

  testWidgets('an unpublished histogram draws no chart at all', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: CommunityFrequencyCard(stats: _stats(const {}), myCount: 2),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CommunityBars), findsNothing);
  });
}
