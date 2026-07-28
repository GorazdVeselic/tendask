import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/features/community/data/community_models.dart';
import 'package:tendask/features/community/presentation/widgets/community_frequency_card.dart';
import 'package:tendask/i18n/translations.g.dart';

/// The server's shipped `app_config` values (supabase/migrations/0006, read back
/// off staging 2026-07-28). Duplicated here on purpose: the client cannot read
/// `app_config` (RLS on, no policy), so the mirror in config.dart is hand-kept
/// and this file is what makes a silent drift fail the build instead of the UI.
const _serverKPrivacy = 5;
const _serverKReliab = 30;

const _bucket = Bucket(resolution: CommunityResolution.r6, key: 'cellB');

FrequencyStats _stats(int nUsers) => FrequencyStats(
  bucket: _bucket,
  p25: 2,
  p50: 3,
  p75: 4,
  unit: 'per_season',
  nUsers: nUsers,
  hist: const {'1': 3, '2': 8, '3': 6},
);

void main() {
  setUp(() => LocaleSettings.setLocale(AppLocale.en));

  group('client floor mirrors the server gate', () {
    // One-directional: the client may be stricter than the server, never looser.
    // Looser would print a percentage off a sample the server judged too thin.
    test('never below the server values', () {
      expect(kCommunityPrivacyMin, greaterThanOrEqualTo(_serverKPrivacy));
      expect(kCommunityReliabilityMin, greaterThanOrEqualTo(_serverKReliab));
    });

    test('equal to them today, which is why no middle band ever renders', () {
      // Pins najdba N22 as a decision rather than an accident: with these two
      // equal, RLS never delivers a row the low-n branch could catch, so a user
      // sees numbers or nothing. If someone deliberately raises the client
      // floor, this test fails and the band below becomes user-visible — which
      // is the moment to check the copy, not after a release.
      expect(kCommunityReliabilityMin, _serverKReliab);
    });
  });

  group('low-n branch stays exercised even though RLS hides it', () {
    testWidgets('a thin sample gets words, never the numeric range', (
      tester,
    ) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: CommunityFrequencyCard(
                stats: _stats(kCommunityReliabilityMin - 1),
                myCount: 0,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(t.community.detail.freq_low_n), findsOneWidget);
      expect(
        find.text(t.community.detail.freq_range(from: 2, to: 4)),
        findsNothing,
      );
    });

    testWidgets('a sample at the floor gets the numeric range', (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: CommunityFrequencyCard(
                stats: _stats(kCommunityReliabilityMin),
                myCount: 0,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(t.community.detail.freq_range(from: 2, to: 4)),
        findsOneWidget,
      );
      expect(find.text(t.community.detail.freq_low_n), findsNothing);
    });
  });
}
