import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/features/community/data/community_models.dart';
import 'package:tendask/features/community/data/community_stats.dart';

const _bucket = Bucket(resolution: CommunityResolution.r7, key: 'cellA');

Map<String, dynamic> _week(int year, int week, int count) => {
  'year': year,
  'iso_week': week,
  'first_user_count': count,
};

void main() {
  group('isoWeek mirrors Postgres extract(week from ...)', () {
    test('week 1 starts on the Monday that carries the first Thursday', () {
      expect(isoWeek(DateTime(2025, 12, 29)), 1); // Monday of 2026-W01
      expect(isoWeek(DateTime(2026, 1, 1)), 1); // Thursday
      expect(isoWeek(DateTime(2026, 1, 4)), 1); // Sunday
      expect(isoWeek(DateTime(2026, 1, 5)), 2);
    });

    test('a 53-week year keeps its last week, and 1 Jan can belong to it', () {
      expect(isoWeek(DateTime(2026, 12, 31)), 53);
      expect(isoWeek(DateTime(2027, 1, 1)), 53); // still 2026-W53
      expect(isoWeek(DateTime(2027, 1, 4)), 1);
    });

    test('mid-season weeks land where the cron counts them', () {
      expect(isoWeek(DateTime(2026, 5, 11)), 20);
      expect(isoWeek(DateTime(2026, 3, 24)), 13);
    });
  });

  group('buildSeasonCurve', () {
    test('pools completed past seasons and ignores the running year', () {
      final curve = buildSeasonCurve(
        [
          _week(2024, 10, 2),
          _week(2024, 12, 3),
          _week(2024, 14, 5),
          _week(2025, 10, 2),
          _week(2025, 12, 3),
          _week(2025, 14, 5),
          // Current year must not move the percentages (§8.1 censoring).
          _week(2026, 10, 99),
        ],
        bucket: _bucket,
        currentYear: 2026,
      );

      expect(curve, isNotNull);
      // Two seasons of ten gardeners each is not twenty gardeners — the same
      // ten may have come back. The denominator is the busiest single season.
      expect(curve!.pooledTotal, 10);
      expect(curve.censored, isFalse);
      expect(curve.cdf.length, 53);
      expect(seasonCdfForWeek(curve, 9), 0);
      expect(seasonCdfForWeek(curve, 10), closeTo(0.2, 1e-9));
      expect(seasonCdfForWeek(curve, 11), closeTo(0.2, 1e-9)); // stays flat
      expect(seasonCdfForWeek(curve, 12), closeTo(0.5, 1e-9));
      expect(seasonCdfForWeek(curve, 14), closeTo(1.0, 1e-9));
      expect(seasonCdfForWeek(curve, 53), closeTo(1.0, 1e-9));
    });

    test('year 1 falls back to the running season, flagged censored', () {
      final curve = buildSeasonCurve(
        [_week(2026, 10, 4), _week(2026, 12, 6)],
        bucket: _bucket,
        currentYear: 2026,
      );

      expect(curve, isNotNull);
      expect(curve!.censored, isTrue);
      expect(curve.pooledTotal, 10);
      expect(seasonCdfForWeek(curve, 10), closeTo(0.4, 1e-9));
    });

    test('null when there is nothing to build from', () {
      expect(
        buildSeasonCurve(const [], bucket: _bucket, currentYear: 2026),
        isNull,
      );
      expect(
        buildSeasonCurve(
          [_week(2025, 10, 0)],
          bucket: _bucket,
          currentYear: 2026,
        ),
        isNull,
      );
    });

    test('tolerates missing and out-of-range fields instead of crashing', () {
      final curve = buildSeasonCurve(
        [
          _week(2025, 10, 5),
          {'year': 2025, 'iso_week': 54, 'first_user_count': 7}, // impossible
          {'year': 2025, 'iso_week': 0, 'first_user_count': 7}, // impossible
          {'year': 2025, 'first_user_count': 7}, // no week
          {'year': 2025, 'iso_week': 11}, // no count
        ],
        bucket: _bucket,
        currentYear: 2026,
      );

      expect(curve!.pooledTotal, 5);
    });

    test('the clamp keeps a week outside the curve from throwing', () {
      final curve = buildSeasonCurve(
        [_week(2025, 20, 8)],
        bucket: _bucket,
        currentYear: 2026,
      )!;

      expect(seasonCdfForWeek(curve, 0), 0);
      expect(seasonCdfForWeek(curve, 99), closeTo(1.0, 1e-9));
    });
  });

  group('season window (what the detail chart draws)', () {
    /// A curve whose mass sits in weeks 10..16, with a long empty tail.
    SeasonCurve curve() => buildSeasonCurve(
      [
        _week(2025, 10, 2),
        _week(2025, 12, 6),
        _week(2025, 14, 8),
        _week(2025, 16, 4),
      ],
      bucket: _bucket,
      currentYear: 2026,
    )!;

    test('density sums back to the whole season', () {
      final density = seasonDensity(curve());
      expect(density.length, 53);
      expect(density.reduce((a, b) => a + b), closeTo(1.0, 1e-9));
      expect(density[9], closeTo(0.1, 1e-9)); // week 10 = 2/20
    });

    test('covers the mass, never fewer than the minimum width', () {
      final window = seasonWindow(curve());

      expect(window.density.length, greaterThanOrEqualTo(13));
      expect(window.myIndex, isNull);
      // The mass (weeks 10..16) has to be inside the drawn range.
      expect(window.firstWeek, lessThanOrEqualTo(10));
      expect(
        window.firstWeek + window.density.length - 1,
        greaterThanOrEqualTo(16),
      );
    });

    test('always contains my week, however far outside the season', () {
      final window = seasonWindow(curve(), myWeek: 40);

      expect(window.myIndex, isNotNull);
      expect(window.firstWeek + window.myIndex!, 40 - 1 + 1);
      expect(window.density.length, greaterThanOrEqualTo(13));
    });

    test('a week at the very start does not push the window off the year', () {
      final window = seasonWindow(curve(), myWeek: 1);

      expect(window.firstWeek, 1);
      expect(window.myIndex, 0);
    });

    test('peak weeks bracket the middle half of the season', () {
      expect(seasonPeakWeeks(curve()), (12, 14));
    });
  });

  group('display rounding', () {
    test('a percentage needs a reliable sample, and is rounded to 10', () {
      final thin = buildSeasonCurve(
        [_week(2025, 10, 4), _week(2025, 12, 6)],
        bucket: _bucket,
        currentYear: 2026,
      )!;
      expect(seasonPercent(thin, 12), isNull); // n = 10 < kReliab

      final solid = buildSeasonCurve(
        [_week(2025, 10, 13), _week(2025, 12, 27)],
        bucket: _bucket,
        currentYear: 2026,
      )!;
      expect(solid.pooledTotal, 40);
      expect(seasonPercent(solid, 10), 30); // 13/40 = 32.5 %
      expect(seasonPercent(solid, 12), 100);
    });

    test('the reliability threshold is exact: 29 stays a band, 30 gets a number', () {
      SeasonCurve of(int n) => buildSeasonCurve(
        [_week(2025, 10, n)],
        bucket: _bucket,
        currentYear: 2026,
      )!;

      expect(of(kCommunityReliabilityMin - 1).pooledTotal, 29);
      expect(seasonPercent(of(kCommunityReliabilityMin - 1), 10), isNull);
      expect(seasonRankPercent(of(kCommunityReliabilityMin - 1), 10), isNull);
      expect(seasonPercent(of(kCommunityReliabilityMin), 10), 100);
      expect(seasonRankPercent(of(kCommunityReliabilityMin), 10), 50);
    });

    test('a rank is not the cumulative share it sits on', () {
      // 13 start in week 10, 27 in week 12. By the end of week 12 everyone has
      // started (100 %) — but someone starting in week 12 is not last: 13 were
      // ahead and 27 shared the week, so ~65 % of the field started before them.
      final curve = buildSeasonCurve(
        [_week(2025, 10, 13), _week(2025, 12, 27)],
        bucket: _bucket,
        currentYear: 2026,
      )!;
      expect(seasonPercent(curve, 12), 100);
      expect(seasonRankPercent(curve, 12), 70); // mid-rank 0.325 + 0.675/2
      expect(seasonRankPercent(curve, 10), 20); // 0 + 0.325/2
    });

    test('a single-week season does not make everyone late', () {
      // The whole neighbourhood starts in week 20. The inclusive F(20) = 1.0
      // put every one of them in the last tercile, the first one included.
      final curve = buildSeasonCurve(
        [_week(2025, 20, 40)],
        bucket: _bucket,
        currentYear: 2026,
      )!;
      expect(seasonCdfForWeek(curve, 20), 1.0);
      expect(seasonRank(curve, 20), 0.5);
      expect(timingBand(seasonRank(curve, 20)), CommunityTiming.typical);
      expect(seasonRankPercent(curve, 20), 50);
    });

    test('the tercile still separates early from late', () {
      final curve = buildSeasonCurve(
        [_week(2025, 10, 20), _week(2025, 20, 20), _week(2025, 30, 20)],
        bucket: _bucket,
        currentYear: 2026,
      )!;
      expect(timingBand(seasonRank(curve, 10)), CommunityTiming.early);
      expect(timingBand(seasonRank(curve, 20)), CommunityTiming.typical);
      expect(timingBand(seasonRank(curve, 30)), CommunityTiming.late);
    });
  });

  group('how many gardeners stand behind the curve', () {
    test('the same neighbours over three seasons are not three times as many', () {
      // 12 gardeners × 3 seasons summed to 36 and crossed the reliability bar,
      // so the screen put a percentage on a group of twelve — and said "~36".
      final curve = buildSeasonCurve(
        [
          _week(2023, 20, 12),
          _week(2024, 20, 12),
          _week(2025, 20, 12),
        ],
        bucket: _bucket,
        currentYear: 2026,
      )!;
      expect(curve.pooledTotal, 12);
      expect(seasonPercent(curve, 20), isNull); // below kReliab → band only
    });

    test('a growing neighbourhood counts by its busiest season', () {
      final curve = buildSeasonCurve(
        [_week(2024, 20, 8), _week(2025, 20, 31)],
        bucket: _bucket,
        currentYear: 2026,
      )!;
      expect(curve.pooledTotal, 31);
      expect(seasonPercent(curve, 20), 100); // clears kReliab on its own
    });

    test('pooling still shapes the curve, only the denominator changes', () {
      final curve = buildSeasonCurve(
        [_week(2024, 10, 10), _week(2025, 30, 10)],
        bucket: _bucket,
        currentYear: 2026,
      )!;
      expect(curve.pooledTotal, 10);
      expect(seasonCdfForWeek(curve, 10), closeTo(0.5, 1e-9)); // both seasons
      expect(seasonCdfForWeek(curve, 30), closeTo(1.0, 1e-9));
    });
  });

  group('mondayOfIsoWeek', () {
    test('inverts isoWeek', () {
      for (final week in [1, 5, 20, 52]) {
        expect(isoWeek(mondayOfIsoWeek(2026, week)), week);
      }
    });

    test('week 1 is the week carrying the first Thursday', () {
      expect(mondayOfIsoWeek(2026, 1), DateTime(2025, 12, 29));
      expect(mondayOfIsoWeek(2027, 1), DateTime(2027, 1, 4));
    });
  });

  test('timingBand splits the curve into terciles', () {
    expect(timingBand(0), CommunityTiming.early);
    expect(timingBand(0.33), CommunityTiming.early);
    expect(timingBand(1 / 3), CommunityTiming.typical);
    expect(timingBand(0.5), CommunityTiming.typical);
    expect(timingBand(2 / 3), CommunityTiming.late);
    expect(timingBand(1), CommunityTiming.late);
  });

  group('parseFrequency', () {
    Map<String, dynamic> row(int year, {int n = 40}) => {
      'season_year': year,
      'n_users': n,
      'per_user_p25': 2,
      'per_user_p50': 3,
      'per_user_p75': 4,
      'unit': 'per_month',
      'hist': {'1': 4, '2': 9, '3': 12, '4': 7, '5+': 3},
    };

    test('prefers the current season and parses the histogram', () {
      final stats = parseFrequency(
        [row(2025, n: 10), row(2026)],
        bucket: _bucket,
        seasonYear: 2026,
      );

      expect(stats, isNotNull);
      expect(stats!.nUsers, 40);
      expect(stats.p25, 2);
      expect(stats.p75, 4);
      expect(stats.unit, 'per_month');
      expect(stats.hist['5+'], 3);
    });

    test('falls back to the newest published season', () {
      final stats = parseFrequency(
        [row(2023, n: 7), row(2025, n: 12)],
        bucket: _bucket,
        seasonYear: 2026,
      );

      expect(stats!.nUsers, 12);
    });

    test('null without rows, without users or without a median', () {
      expect(parseFrequency(const [], bucket: _bucket, seasonYear: 2026), isNull);
      expect(
        parseFrequency(
          [row(2026, n: 0)],
          bucket: _bucket,
          seasonYear: 2026,
        ),
        isNull,
      );
      expect(
        parseFrequency(
          [
            {'season_year': 2026, 'n_users': 40},
          ],
          bucket: _bucket,
          seasonYear: 2026,
        ),
        isNull,
      );
    });

    test('missing quartiles fall back to the median', () {
      final stats = parseFrequency(
        [
          {'season_year': 2026, 'n_users': 40, 'per_user_p50': 3},
        ],
        bucket: _bucket,
        seasonYear: 2026,
      );

      expect(stats!.p25, 3);
      expect(stats.p75, 3);
      expect(stats.unit, 'per_season'); // documented default
      expect(stats.hist, isEmpty);
    });
  });

  group('buildStandings', () {
    /// Everyone started in week 20, so a first execution before it is early,
    /// in it is typical and after it is late.
    SeasonCurve curve({
      Bucket bucket = _bucket,
      int week = 20,
      int count = 50,
    }) => buildSeasonCurve(
      [
        {'year': 2025, 'iso_week': week, 'first_user_count': count},
      ],
      bucket: bucket,
      currentYear: 2026,
    )!;

    test('places each cohort against its own curve', () {
      final rows = buildStandings(
        {
          ('sow', 'tomato'): MySeason(first: DateTime(2026, 3, 2), count: 1),
          ('mow', '@site'): MySeason(first: DateTime(2026, 9, 7), count: 4),
        },
        {('sow', 'tomato'): curve(), ('mow', '@site'): curve()},
      );

      expect(rows.map((r) => (r.cohort, r.band)), [
        ('@site', CommunityTiming.late), // September, curve peaked in May
        ('tomato', CommunityTiming.early),
      ]);
    });

    test('most recently started comes first', () {
      final rows = buildStandings(
        {
          ('a', '@site'): MySeason(first: DateTime(2026, 1, 5), count: 1),
          ('b', '@site'): MySeason(first: DateTime(2026, 6, 1), count: 1),
          ('c', '@site'): MySeason(first: DateTime(2026, 3, 2), count: 1),
        },
        {
          ('a', '@site'): curve(),
          ('b', '@site'): curve(),
          ('c', '@site'): curve(),
        },
      );

      expect(rows.map((r) => r.taskTypeId), ['b', 'c', 'a']);
    });

    test('a cohort without a curve is left out, never blended', () {
      final rows = buildStandings(
        {
          ('sow', 'tomato'): MySeason(first: DateTime(2026, 3, 2), count: 1),
          ('prune', 'pear'): MySeason(first: DateTime(2026, 3, 2), count: 1),
        },
        {('sow', 'tomato'): curve()},
      );

      expect(rows.map((r) => r.cohort), ['tomato']);
    });

    test('the row carries the level that answered, not the screen', () {
      const climate = Bucket(
        resolution: CommunityResolution.climate,
        key: 'e1_t5',
      );
      final rows = buildStandings(
        {
          ('sow', 'tomato'): MySeason(first: DateTime(2026, 3, 2), count: 1),
          ('mow', '@site'): MySeason(first: DateTime(2026, 3, 2), count: 1),
        },
        {
          ('sow', 'tomato'): curve(bucket: climate),
          ('mow', '@site'): curve(),
        },
      );

      expect(
        {for (final r in rows) r.cohort: r.scope},
        {'tomato': CommunityResolution.climate, '@site': CommunityResolution.r7},
      );
    });
  });
}
