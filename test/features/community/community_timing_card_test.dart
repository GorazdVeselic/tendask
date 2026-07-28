import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/community/data/community_models.dart';
import 'package:tendask/features/community/data/community_stats.dart';
import 'package:tendask/features/community/presentation/widgets/community_timing_card.dart';
import 'package:tendask/i18n/translations.g.dart';

const _r6 = Bucket(resolution: CommunityResolution.r6, key: 'cellB');

/// A reliable curve (n = 50) spread over three weeks — the peak-week sentence
/// needs a spread, or `from` and `to` collapse onto one date.
SeasonCurve _curve() => buildSeasonCurve(
  const [
    {'year': 2025, 'iso_week': 16, 'first_user_count': 15},
    {'year': 2025, 'iso_week': 20, 'first_user_count': 25},
    {'year': 2025, 'iso_week': 23, 'first_user_count': 10},
  ],
  bucket: _r6,
  currentYear: 2026,
)!;

Future<List<String>> _texts(WidgetTester tester, {DateTime? myFirst}) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: MaterialApp(
        home: Scaffold(
          body: CommunityTimingCard(
            curve: _curve(),
            mine: MySeason(first: myFirst, count: myFirst == null ? 0 : 1),
            today: DateTime(2026, 6, 10),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((w) => w.data ?? '')
      .toList();
}

void main() {
  for (final locale in AppLocale.values) {
    group(locale.languageCode, () {
      setUp(() => LocaleSettings.setLocale(locale));

      testWidgets('a date that ends a sentence brings only one full stop', (
        tester,
      ) async {
        // formatDm already ends in a period ("1. 6."), and the template added
        // its own → "1. 6.." on device (najdba N20). Either the date carries
        // the stop or the template does, never both.
        final texts = await _texts(tester);

        // The peak-week sentence is the one that ends on a formatted date.
        final stem = t.community.detail
            .peak_weeks(from: '', to: '')
            .split(RegExp(r'\s+'))
            .first;
        expect(texts.any((s) => s.contains(stem)), isTrue);
        for (final text in texts) {
          expect(text, isNot(contains('..')), reason: 'in "$text"');
        }
      });

      testWidgets('the same holds once my own date joins the line', (
        tester,
      ) async {
        final texts = await _texts(tester, myFirst: DateTime(2026, 5, 4));

        for (final text in texts) {
          expect(text, isNot(contains('..')), reason: 'in "$text"');
        }
      });
    });
  }
}
