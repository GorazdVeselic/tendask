import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/community/data/community_models.dart';
import 'package:tendask/features/community/data/community_stats.dart';
import 'package:tendask/features/community/presentation/community_display.dart';
import 'package:tendask/i18n/translations.g.dart';

const _bucket = Bucket(resolution: CommunityResolution.r7, key: 'cellA');

Map<String, dynamic> _week(int week, int count) => {
  'year': 2025,
  'iso_week': week,
  'first_user_count': count,
};

SeasonCurve _curve(List<Map<String, dynamic>> rows) =>
    buildSeasonCurve(rows, bucket: _bucket, currentYear: 2026)!;

/// Whatever the headline says, it must hold for a reader who started in [week].
/// The sentence is asserted verbatim: the bug this guards was a true number in
/// a false sentence, so a numeric assertion alone would have passed.
void main() {
  setUp(() => LocaleSettings.setLocale(AppLocale.en));

  test('near the front of the field, the wording is not a percentage', () {
    // Mid-rank 0.04: rounding gives 0, and "~0 % started before you" is a
    // rounding artefact, not a finding.
    final curve = _curve([_week(5, 2), _week(10, 4), _week(30, 94)]);

    expect(seasonRank(curve, 10), closeTo(0.04, 1e-9));
    expect(
      communityTimingHeadline(t, curve, 10),
      t.community.detail.you_band.early,
    );
  });

  test('in the middle of the field, half the neighbours are ahead', () {
    final curve = _curve([_week(10, 40), _week(20, 20), _week(30, 40)]);

    expect(seasonRank(curve, 20), closeTo(0.5, 1e-9));
    expect(
      communityTimingHeadline(t, curve, 20),
      t.community.detail.you_percent(percent: 50),
    );
  });

  test('near the back of the field, the sentence says so', () {
    // This is the case that used to read "You were among the first ~90 %" for
    // someone 92 % of the way down the curve.
    final curve = _curve([_week(10, 90), _week(20, 4), _week(30, 6)]);

    expect(seasonRank(curve, 20), closeTo(0.92, 1e-9));
    final headline = communityTimingHeadline(t, curve, 20);
    expect(headline, t.community.detail.you_percent(percent: 90));
    expect(headline.toLowerCase(), contains('before you'));
    expect(headline.toLowerCase(), isNot(contains('among the first')));
  });

  test('at the very back, rounding must not claim literally everyone', () {
    // Mid-rank 0.95 rounds to 100, which would say every single gardener
    // started earlier — untrue for the 5 % who came after.
    final curve = _curve([_week(10, 90), _week(20, 10)]);

    expect(seasonRank(curve, 20), closeTo(0.95, 1e-9));
    expect(
      communityTimingHeadline(t, curve, 20),
      t.community.detail.you_band.late,
    );
  });

  test('a thin sample is described, never numbered', () {
    final thin = _curve([_week(10, 10), _week(20, 10)]);

    expect(thin.pooledTotal, 20); // < kCommunityReliabilityMin
    expect(
      communityTimingHeadline(t, thin, 20),
      t.community.detail.you_band.late,
    );
  });

  test('no first completion this season is said plainly, not placed', () {
    final curve = _curve([_week(10, 40), _week(20, 20), _week(30, 40)]);
    expect(communityTimingHeadline(t, curve, null), t.community.detail.not_started);
  });

  test('the Slovene sentence names the field, not the reader', () {
    // Gender-neutral by construction: no participle agrees with the reader.
    LocaleSettings.setLocale(AppLocale.sl);
    final curve = _curve([_week(10, 90), _week(20, 4), _week(30, 6)]);

    final headline = communityTimingHeadline(t, curve, 20);
    expect(headline, 'Pred tabo je začelo ~90 % vrtnarjev');
    for (final gendered in ['zamudil', 'začel ', 'bil ', 'bila ', 'pozen']) {
      expect(headline, isNot(contains(gendered)));
    }
  });
}
