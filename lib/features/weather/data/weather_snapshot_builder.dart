import '../../../core/date_format.dart';
import 'open_meteo_response.dart';
import 'weather_snapshot.dart';

/// Builds the frozen [WeatherSnapshot] from a raw Open-Meteo response, as of
/// [at] (the capture moment, local time — Open-Meteo series use timezone=auto so
/// their timestamps are local to the queried location). Pure and total: a
/// partial/empty response yields a snapshot with null fields, never throws.
WeatherSnapshot buildSnapshot(OpenMeteoResponse res, {required DateTime at}) {
  final current = res.current;
  final today = startOfDay(at);

  final (soilTemperature, rainPast48h) = _bandTwo(res.hourly, at);
  final (forecast, todayEt0) = _bandThree(res.daily, today);

  return WeatherSnapshot(
    capturedAt: at.toUtc(),
    temperature: current?.temperature2m,
    humidity: current?.relativeHumidity2m,
    precipitation: current?.precipitation,
    windSpeed: current?.windSpeed10m,
    weatherCode: current?.weatherCode,
    soilTemperature: soilTemperature,
    et0: todayEt0,
    rainPast48h: rainPast48h,
    forecast: forecast,
  );
}

/// Band 2: soil temperature at "now" + rain summed over the past ~48 hours.
(double?, double?) _bandTwo(OpenMeteoHourly? hourly, DateTime at) {
  if (hourly == null || hourly.time.isEmpty) return (null, null);

  // Index of the latest hour not after [at].
  var nowIdx = 0;
  for (var i = 0; i < hourly.time.length; i++) {
    final t = DateTime.tryParse(hourly.time[i]);
    if (t == null) continue;
    if (t.isAfter(at)) break;
    nowIdx = i;
  }

  final soil = nowIdx < hourly.soilTemperature6cm.length
      ? hourly.soilTemperature6cm[nowIdx]
      : null;

  final from = (nowIdx - 47).clamp(0, hourly.precipitation.length).toInt();
  var sum = 0.0;
  var any = false;
  for (var i = from; i <= nowIdx && i < hourly.precipitation.length; i++) {
    final p = hourly.precipitation[i];
    if (p != null) {
      sum += p;
      any = true;
    }
  }
  return (soil, any ? sum : null);
}

/// Band 3: up to 3 forecast days after [today], plus today's ET₀.
(List<WeatherDay>, double?) _bandThree(OpenMeteoDaily? daily, DateTime today) {
  if (daily == null) return (const [], null);

  final forecast = <WeatherDay>[];
  double? todayEt0;
  for (var i = 0; i < daily.time.length; i++) {
    final parsed = DateTime.tryParse(daily.time[i]);
    if (parsed == null) continue;
    final day = startOfDay(parsed);
    final et0 = i < daily.et0FaoEvapotranspiration.length
        ? daily.et0FaoEvapotranspiration[i]
        : null;
    if (day == today) {
      todayEt0 = et0;
      continue;
    }
    if (day.isAfter(today) && forecast.length < 3) {
      forecast.add(
        WeatherDay(
          date: parsed,
          weatherCode: i < daily.weatherCode.length
              ? daily.weatherCode[i]
              : null,
          tempMax: i < daily.temperature2mMax.length
              ? daily.temperature2mMax[i]
              : null,
          tempMin: i < daily.temperature2mMin.length
              ? daily.temperature2mMin[i]
              : null,
          precipitationSum: i < daily.precipitationSum.length
              ? daily.precipitationSum[i]
              : null,
          et0: et0,
        ),
      );
    }
  }
  return (forecast, todayEt0);
}
