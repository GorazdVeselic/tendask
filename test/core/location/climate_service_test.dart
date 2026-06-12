import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/location/climate_service.dart';
import 'package:tendask/core/location/open_meteo_archive_client.dart';

/// Builds a synthetic [ArchiveResponse]: for each year, daily tMin is below
/// zero up to (and including) [lastFrostDoy] and from [firstFrostDoy] on
/// (non-leap DOY), +5 °C between; tMean is constant [meanC]. Frost windows per
/// year are keyed by year index 0..n-1.
ArchiveResponse synthetic({
  required List<int?> lastFrostDoyByYear,
  required List<int?> firstFrostDoyByYear,
  double meanC = 10.8,
  double elevationM = 295,
  double latitude = 46.05,
  int startYear = 2016,
}) {
  final days = <DateTime>[];
  final tMin = <double?>[];
  final tMean = <double?>[];
  for (var y = 0; y < lastFrostDoyByYear.length; y++) {
    final year = startYear + y;
    var date = DateTime.utc(year);
    while (date.year == year) {
      // Non-leap DOY, mirroring the production rule (Feb 29 → Mar 1 = 60).
      final doy =
          DateTime.utc(
            2001,
            date.month,
            date.day,
          ).difference(DateTime.utc(2001)).inDays +
          1;
      final last = lastFrostDoyByYear[y];
      final first = firstFrostDoyByYear[y];
      final frost = (last != null && doy <= last) ||
          (first != null && doy >= first);
      days.add(date);
      tMin.add(frost ? -2.0 : 5.0);
      tMean.add(meanC);
      date = date.add(const Duration(days: 1));
    }
  }
  return ArchiveResponse(
    latitude: latitude,
    elevationM: elevationM,
    timezone: 'Europe/Ljubljana',
    days: days,
    tMin: tMin,
    tMean: tMean,
  );
}

void main() {
  final capturedAt = DateTime.utc(2026, 6, 12);

  group('computeClimateProfile', () {
    test('Ljubljana-like input → bucket e1_t5 and median frost DOYs', () {
      final r = synthetic(
        // Medians: last 108 (sorted 104..112, middle of 5), first 295.
        lastFrostDoyByYear: [104, 106, 108, 110, 112],
        firstFrostDoyByYear: [291, 293, 295, 297, 299],
      );
      final out = computeClimateProfile(r, capturedAt: capturedAt);

      expect(out.bucket, 'e1_t5'); // 295 m → e1, mean 10.8 → t5
      expect(out.profile.frostLastSpringDoy, 108);
      expect(out.profile.frostFirstAutumnDoy, 295);
      expect(out.profile.growingSeasonDays, 187);
      expect(out.profile.tAnnualMeanC, 10.8);
      expect(out.profile.tempMonthlyNormalsC, hasLength(12));
      expect(out.profile.hemisphere, isNull); // north → key absent
      expect(out.profile.toJson().containsKey('hemisphere'), isFalse);
      expect(out.profile.elevationM, 295);
      expect(out.profile.source, 'open-meteo-era5-10y');
    });

    test('elevation and temperature pick the right bands', () {
      ({String bucket, dynamic profile}) at(double elev, double mean) =>
          computeClimateProfile(
            synthetic(
              lastFrostDoyByYear: [100],
              firstFrostDoyByYear: [300],
              elevationM: elev,
              meanC: mean,
            ),
            capturedAt: capturedAt,
          );
      expect(at(299, 3.9).bucket, 'e1_t1');
      expect(at(300, 4).bucket, 'e2_t2');
      expect(at(650, 7.9).bucket, 'e3_t3');
      expect(at(900, 12).bucket, 'e4_t6');
    });

    test('frost-free location → null frost DOYs and growing season', () {
      final r = synthetic(
        // 6 of 10 years without any frost → frost-free (> half).
        lastFrostDoyByYear: [100, 102, 104, 106, null, null, null, null, null, null],
        firstFrostDoyByYear: [295, 297, 299, 301, null, null, null, null, null, null],
        meanC: 14,
      );
      final out = computeClimateProfile(r, capturedAt: capturedAt);

      expect(out.profile.frostLastSpringDoy, isNull);
      expect(out.profile.frostFirstAutumnDoy, isNull);
      expect(out.profile.growingSeasonDays, isNull);
      expect(out.bucket, 'e1_t6');
    });

    test('southern hemisphere swaps the frost windows and marks the profile',
        () {
      // Frost season mid-year (southern winter): frost between DOY 150
      // (≈30 May) and DOY 290 (≈17 Oct). South: last spring frost = max frost
      // DOY in Jul–Dec (290), first autumn frost = min frost DOY in Jan–Jun
      // — but DOY 150 is in the Jan–Jun window, so it lands there (150).
      final days = <DateTime>[];
      final tMin = <double?>[];
      var date = DateTime.utc(2024);
      while (date.year == 2024) {
        final doy =
            DateTime.utc(
              2001,
              date.month,
              date.day,
            ).difference(DateTime.utc(2001)).inDays +
            1;
        days.add(date);
        tMin.add(doy >= 150 && doy <= 290 ? -2.0 : 5.0);
        date = date.add(const Duration(days: 1));
      }
      final south = ArchiveResponse(
        latitude: -36.8,
        elevationM: 50,
        timezone: 'Pacific/Auckland',
        days: days,
        tMin: tMin,
        tMean: List<double?>.filled(days.length, 12.0),
      );
      final out = computeClimateProfile(south, capturedAt: capturedAt);

      expect(out.profile.hemisphere, 'south');
      expect(out.profile.frostLastSpringDoy, 290);
      expect(out.profile.frostFirstAutumnDoy, 150);
      // Growing season wraps the new year: 150 - 290 + 365 = 225 days.
      expect(out.profile.growingSeasonDays, 225);
    });

    test('even year count medians average the middle pair', () {
      final r = synthetic(
        lastFrostDoyByYear: [100, 104],
        firstFrostDoyByYear: [294, 297],
      );
      final out = computeClimateProfile(r, capturedAt: capturedAt);
      expect(out.profile.frostLastSpringDoy, 102);
      expect(out.profile.frostFirstAutumnDoy, 296); // 295.5 → rounds to 296
    });
  });

  group('ArchiveResponse.fromJson', () {
    test('parses a daily payload tolerantly (null gaps stay null)', () {
      final r = ArchiveResponse.fromJson({
        'latitude': 46.0,
        'elevation': 295.0,
        'timezone': 'Europe/Ljubljana',
        'daily': {
          'time': ['2025-01-01', '2025-01-02'],
          'temperature_2m_min': [-1.2, null],
          'temperature_2m_mean': [2.5, null],
        },
      });
      expect(r.days, hasLength(2));
      expect(r.tMin[1], isNull);
      expect(r.elevationM, 295);
    });

    test('throws on a body without the daily block', () {
      expect(
        () => ArchiveResponse.fromJson({'latitude': 46.0}),
        throwsFormatException,
      );
    });
  });

  group('ClimateService', () {
    test('returns null after exhausting retries (offline is not an error)',
        () async {
      var calls = 0;
      final service = ClimateService(
        _ThrowingClient(() => calls++),
        clock: _FixedClock(DateTime.utc(2026, 6, 12)),
        retryDelays: const [Duration.zero, Duration.zero],
      );
      final result = await service.fetchFor(latitude: 46, longitude: 14.5);
      expect(result, isNull);
      expect(calls, 3); // initial attempt + 2 retries
    });

    test('requests the 10 full years ending last year', () async {
      late int gotLastYear;
      late int gotYears;
      final service = ClimateService(
        _CannedClient((lastYear, years) {
          gotLastYear = lastYear;
          gotYears = years;
        }),
        clock: _FixedClock(DateTime.utc(2026, 6, 12)),
      );
      final result = await service.fetchFor(latitude: 46, longitude: 14.5);
      expect(result, isNotNull);
      expect(gotLastYear, 2025);
      expect(gotYears, 10);
      expect(result!.timezone, 'Europe/Ljubljana');
      expect(result.bucket, 'e1_t5');
    });
  });
}

class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

class _ThrowingClient extends OpenMeteoArchiveClient {
  _ThrowingClient(this._onCall) : super(Dio());
  final void Function() _onCall;
  @override
  Future<ArchiveResponse> fetch({
    required double latitude,
    required double longitude,
    required int lastYear,
    required int years,
  }) async {
    _onCall();
    throw const FormatException('boom');
  }
}

class _CannedClient extends OpenMeteoArchiveClient {
  _CannedClient(this._onCall) : super(Dio());
  final void Function(int lastYear, int years) _onCall;
  @override
  Future<ArchiveResponse> fetch({
    required double latitude,
    required double longitude,
    required int lastYear,
    required int years,
  }) async {
    _onCall(lastYear, years);
    return synthetic(
      lastFrostDoyByYear: [108],
      firstFrostDoyByYear: [295],
    );
  }
}
