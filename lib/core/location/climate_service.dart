import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../clock.dart';
import '../config.dart';
import 'climate_profile.dart';
import 'open_meteo_archive_client.dart';

part 'climate_service.g.dart';

/// What one successful climate fetch yields: the rich owner-only profile, the
/// coarse public bucket, and the garden's IANA timezone from the archive call.
typedef ClimateResult = ({
  ClimateProfile profile,
  String bucket,
  String? timezone,
});

/// Fetches the ERA5 archive for a coordinate (the r7 cell centroid — never raw
/// GPS) and computes the climate profile, with bounded retry/backoff. Offline
/// is a normal state: after exhausting retries it returns null so the caller
/// saves the location without a climate profile (filled in on a later start).
class ClimateService {
  ClimateService(
    this._client, {
    this._clock = const SystemClock(),
    this._retryDelays = kWeatherRetryDelays,
  });

  final OpenMeteoArchiveClient _client;
  final Clock _clock;
  final List<Duration> _retryDelays;

  Future<ClimateResult?> fetchFor({
    required double latitude,
    required double longitude,
  }) async {
    // Last full calendar year: ERA5 lags ~5 days, so full past years give a
    // stable result year-round (docs/m11/07 §7.1).
    final lastYear = _clock.now().year - 1;
    for (var attempt = 0; ; attempt++) {
      try {
        final res = await _client.fetch(
          latitude: latitude,
          longitude: longitude,
          lastYear: lastYear,
          years: kClimateHistoryYears,
        );
        final computed = computeClimateProfile(
          res,
          capturedAt: _clock.now().toUtc(),
        );
        return (
          profile: computed.profile,
          bucket: computed.bucket,
          timezone: res.timezone,
        );
      } on Exception catch (e) {
        if (attempt >= _retryDelays.length) {
          debugPrint('Climate fetch failed after ${attempt + 1} attempts: $e');
          return null;
        }
        await Future<void>.delayed(_retryDelays[attempt]);
      }
    }
  }
}

/// Computes the climate profile + coarse bucket from one archive response.
/// Pure (no I/O, no clock — input is historical data), so it is unit-testable
/// with synthetic years. Algorithm: docs/m11/07 §7.2–7.4.
({ClimateProfile profile, String bucket}) computeClimateProfile(
  ArchiveResponse r, {
  required DateTime capturedAt,
}) {
  final meanValues = r.tMean.whereType<double>().toList();
  if (meanValues.isEmpty) {
    throw const FormatException('archive has no usable mean temperatures');
  }
  final annualMean = meanValues.reduce((a, b) => a + b) / meanValues.length;

  // 12 monthly normals: mean of daily means per calendar month over all years.
  final monthSums = List<double>.filled(12, 0);
  final monthCounts = List<int>.filled(12, 0);
  for (var i = 0; i < r.days.length; i++) {
    final t = r.tMean[i];
    if (t == null) continue;
    monthSums[r.days[i].month - 1] += t;
    monthCounts[r.days[i].month - 1]++;
  }
  final monthlyNormals = [
    for (var m = 0; m < 12; m++)
      monthCounts[m] == 0
          ? _round1(annualMean)
          : _round1(monthSums[m] / monthCounts[m]),
  ];

  // Frost day-of-year per year. Southern hemisphere swaps the search windows
  // (its frost season is mid-year); month_window rules are skipped server-side
  // for 'south' — decision S2, docs/m11/07 §7.3.
  final south = r.latitude < 0;
  final lastFrostByYear = <int, int?>{};
  final firstFrostByYear = <int, int?>{};
  for (var i = 0; i < r.days.length; i++) {
    final day = r.days[i];
    final min = r.tMin[i];
    lastFrostByYear.putIfAbsent(day.year, () => null);
    firstFrostByYear.putIfAbsent(day.year, () => null);
    if (min == null || min > 0.0) continue;
    final doy = _nonLeapDoy(day);
    final firstHalf = day.month <= 6;
    // last spring frost: max DOY in Jan–Jun (north) / Jul–Dec (south);
    // first autumn frost: min DOY in Jul–Dec (north) / Jan–Jun (south).
    if (firstHalf != south) {
      final prev = lastFrostByYear[day.year];
      if (prev == null || doy > prev) lastFrostByYear[day.year] = doy;
    } else {
      final prev = firstFrostByYear[day.year];
      if (prev == null || doy < prev) firstFrostByYear[day.year] = doy;
    }
  }
  final lastFrost = _frostMedian(lastFrostByYear.values);
  final firstFrost = _frostMedian(firstFrostByYear.values);
  // Southern growing season wraps the new year → normalize to a duration.
  final growingSeason = lastFrost == null || firstFrost == null
      ? null
      : (firstFrost - lastFrost + 365) % 365;

  final bucket =
      'e${_band(r.elevationM ?? 0, kClimateElevationBandsM)}'
      '_t${_band(annualMean, kClimateTempBandsC)}';

  return (
    profile: ClimateProfile(
      elevationM: r.elevationM,
      tAnnualMeanC: _round1(annualMean),
      tempMonthlyNormalsC: monthlyNormals,
      frostLastSpringDoy: lastFrost,
      frostFirstAutumnDoy: firstFrost,
      growingSeasonDays: growingSeason,
      capturedAt: capturedAt,
      source: 'open-meteo-era5-${kClimateHistoryYears}y',
      hemisphere: south ? 'south' : null,
    ),
    bucket: bucket,
  );
}

/// 1-based band index: values below the first cut-off → 1, above the last →
/// cutoffs.length + 1.
int _band(double value, List<double> cutoffs) =>
    1 + cutoffs.where((c) => value >= c).length;

/// Median of the years WITH frost, or null when more than half the years are
/// frost-free (docs/m11/07 §7.3 — the engine then treats the cell frost-free).
int? _frostMedian(Iterable<int?> perYear) {
  final values = perYear.whereType<int>().toList()..sort();
  final frostFreeYears = perYear.length - values.length;
  if (values.isEmpty || frostFreeYears > perYear.length ~/ 2) return null;
  final mid = values.length ~/ 2;
  return values.length.isOdd
      ? values[mid]
      : ((values[mid - 1] + values[mid]) / 2).round();
}

/// Day-of-year in a non-leap calendar (Feb 29 normalizes to Mar 1 = 60); the
/// ±1 day error is below the noise of a 10-year frost median.
int _nonLeapDoy(DateTime d) => DateTime.utc(
  2001,
  d.month,
  d.day,
).difference(DateTime.utc(2001)).inDays + 1;

double _round1(double v) => (v * 10).roundToDouble() / 10;

/// Own Dio: core must not import the weather feature's client providers.
@riverpod
Dio _archiveDio(Ref ref) => Dio(
  BaseOptions(
    connectTimeout: kWeatherConnectTimeout,
    receiveTimeout: kWeatherReceiveTimeout,
  ),
);

@riverpod
ClimateService climateService(Ref ref) =>
    ClimateService(OpenMeteoArchiveClient(ref.watch(_archiveDioProvider)));
