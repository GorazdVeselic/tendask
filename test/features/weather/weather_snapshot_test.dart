import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/weather/data/open_meteo_response.dart';
import 'package:tendask/features/weather/data/weather_snapshot.dart';
import 'package:tendask/features/weather/data/weather_snapshot_builder.dart';

void main() {
  group('buildSnapshot', () {
    final at = DateTime(2026, 6, 4, 13);

    const full = OpenMeteoResponse(
      latitude: 46.05,
      longitude: 14.5,
      current: OpenMeteoCurrent(
        time: '2026-06-04T13:00',
        temperature2m: 22.5,
        relativeHumidity2m: 60,
        precipitation: 0,
        weatherCode: 3,
        windSpeed10m: 8,
      ),
      hourly: OpenMeteoHourly(
        time: [
          '2026-06-04T10:00',
          '2026-06-04T11:00',
          '2026-06-04T12:00',
          '2026-06-04T13:00',
          '2026-06-04T14:00',
        ],
        precipitation: [0.5, 0, 1, 0.5, 2],
        soilTemperature6cm: [10, 11, 12, 13, 14],
      ),
      daily: OpenMeteoDaily(
        time: ['2026-06-04', '2026-06-05', '2026-06-06', '2026-06-07'],
        weatherCode: [3, 1, 61, 0],
        temperature2mMax: [24, 25, 20, 26],
        temperature2mMin: [12, 13, 11, 14],
        precipitationSum: [0, 0, 5, 0],
        et0FaoEvapotranspiration: [2.1, 2.5, 1.8, 2.7],
      ),
    );

    test('band 1 — conditions at capture come from current', () {
      final snap = buildSnapshot(full, at: at);
      expect(snap.temperature, 22.5);
      expect(snap.humidity, 60);
      expect(snap.precipitation, 0);
      expect(snap.windSpeed, 8);
      expect(snap.weatherCode, 3);
      expect(snap.capturedAt, at.toUtc());
    });

    test('band 1 — soil temperature and today ET0 picked at "now"', () {
      final snap = buildSnapshot(full, at: at);
      expect(snap.soilTemperature, 13); // hourly index of 13:00
      expect(snap.et0, 2.1); // daily entry for today
    });

    test('band 2 — rain summed over hours up to "now" (14:00 excluded)', () {
      final snap = buildSnapshot(full, at: at);
      expect(snap.rainPast48h, 2.0); // 0.5 + 0 + 1 + 0.5
    });

    test('band 3 — up to 3 forecast days after today', () {
      final snap = buildSnapshot(full, at: at);
      expect(snap.forecast, hasLength(3));
      final first = snap.forecast.first;
      expect(first.date, DateTime(2026, 6, 5));
      expect(first.weatherCode, 1);
      expect(first.tempMax, 25);
      expect(first.tempMin, 13);
      expect(first.et0, 2.5);
    });

    test('empty response yields null fields, never throws', () {
      final snap = buildSnapshot(const OpenMeteoResponse(), at: at);
      expect(snap.temperature, isNull);
      expect(snap.soilTemperature, isNull);
      expect(snap.rainPast48h, isNull);
      expect(snap.et0, isNull);
      expect(snap.forecast, isEmpty);
      expect(snap.capturedAt, at.toUtc());
    });
  });

  group('WeatherSnapshot (de)serialization', () {
    test('toJson/fromJson round-trips through decodeWeatherSnapshot', () {
      final snap = WeatherSnapshot(
        capturedAt: DateTime.utc(2026, 6, 4, 11),
        temperature: 22.5,
        humidity: 60,
        rainPast48h: 2,
        forecast: [
          WeatherDay(
              date: DateTime.utc(2026, 6, 5),
              weatherCode: 1,
              tempMax: 25,
              tempMin: 13,
              et0: 2.5),
        ],
      );

      final back = decodeWeatherSnapshot(jsonEncode(snap.toJson()));
      expect(back, isNotNull);
      expect(back!.temperature, 22.5);
      expect(back.rainPast48h, 2);
      expect(back.capturedAt, snap.capturedAt);
      expect(back.forecast.single.tempMax, 25);
    });

    test('decode is tolerant of null/empty/garbage/incomplete', () {
      expect(decodeWeatherSnapshot(null), isNull);
      expect(decodeWeatherSnapshot(''), isNull);
      expect(decodeWeatherSnapshot('not json'), isNull);
      // Missing required capturedAt → unparseable → null, not a crash.
      expect(decodeWeatherSnapshot('{"temperature":20}'), isNull);
    });
  });
}
