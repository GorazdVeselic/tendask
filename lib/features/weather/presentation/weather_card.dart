import 'package:flutter/material.dart';

import '../../../i18n/translations.g.dart';
import '../data/weather_code.dart';
import '../data/weather_snapshot.dart';

/// Full three-band weather display for the task detail (§7.10): conditions at
/// capture, the 48 h rain look-back, and the short forecast. Used for a
/// completed task's frozen snapshot.
class WeatherSnapshotCard extends StatelessWidget {
  const WeatherSnapshotCard({super.key, required this.snapshot});

  final WeatherSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final condition = weatherConditionFromCode(snapshot.weatherCode);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Band 1 — conditions at capture.
            Row(
              children: [
                Text(weatherEmoji(condition),
                    style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(conditionLabel(condition, t),
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text(_temp(snapshot.temperature),
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _Metrics(snapshot: snapshot, t: t, theme: theme),
            if (snapshot.rainPast48h != null) ...[
              const SizedBox(height: 10),
              _BandRow(
                label: t.weather.rain_past48h,
                value: '${_round1(snapshot.rainPast48h!)} mm',
                theme: theme,
              ),
            ],
            if (snapshot.forecast.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(t.weather.band_forecast.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.4)),
              const SizedBox(height: 8),
              WeatherForecastStrip(days: snapshot.forecast, t: t, theme: theme),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact live-weather card for the dashboard: current conditions + a short
/// forecast strip. [snapshot] is null when offline → a quiet hint.
class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({super.key, required this.snapshot});

  final WeatherSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final snap = snapshot;

    if (snap == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.cloud_off_outlined,
                  color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(t.weather.home_unavailable,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ),
            ],
          ),
        ),
      );
    }

    final condition = weatherConditionFromCode(snap.weatherCode);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Text(weatherEmoji(condition), style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_temp(snap.temperature),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                Text(conditionLabel(condition, t),
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            const Spacer(),
            if (snap.forecast.isNotEmpty)
              Flexible(
                child: WeatherForecastStrip(
                    days: snap.forecast, t: t, theme: theme, compact: true),
              ),
          ],
        ),
      ),
    );
  }
}

/// A row of mini forecast days (date · emoji · max/min).
class WeatherForecastStrip extends StatelessWidget {
  const WeatherForecastStrip({
    super.key,
    required this.days,
    required this.t,
    required this.theme,
    this.compact = false,
  });

  final List<WeatherDay> days;
  final Translations t;
  final ThemeData theme;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          compact ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      children: [
        for (final day in days)
          Padding(
            padding: EdgeInsets.only(left: compact ? 12 : 0),
            child: Column(
              children: [
                Text('${day.date.day}. ${day.date.month}.',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(weatherEmoji(weatherConditionFromCode(day.weatherCode)),
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 2),
                Text(_minMax(day.tempMin, day.tempMax),
                    style: theme.textTheme.labelSmall),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Shared bits ───────────────────────────────────────────────────────────────

String conditionLabel(WeatherCondition c, Translations t) => switch (c) {
      WeatherCondition.clear => t.weather.cond_clear,
      WeatherCondition.mainlyClear => t.weather.cond_mainly_clear,
      WeatherCondition.cloudy => t.weather.cond_cloudy,
      WeatherCondition.fog => t.weather.cond_fog,
      WeatherCondition.drizzle => t.weather.cond_drizzle,
      WeatherCondition.rain => t.weather.cond_rain,
      WeatherCondition.snow => t.weather.cond_snow,
      WeatherCondition.showers => t.weather.cond_showers,
      WeatherCondition.thunderstorm => t.weather.cond_thunderstorm,
      WeatherCondition.unknown => t.weather.cond_unknown,
    };

String _temp(double? c) => c == null ? '—' : '${c.round()}°C';

String _minMax(double? min, double? max) {
  final lo = min == null ? '—' : '${min.round()}°';
  final hi = max == null ? '—' : '${max.round()}°';
  return '$hi/$lo';
}

String _round1(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

class _Metrics extends StatelessWidget {
  const _Metrics({required this.snapshot, required this.t, required this.theme});

  final WeatherSnapshot snapshot;
  final Translations t;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      if (snapshot.humidity != null) '💧 ${snapshot.humidity!.round()}%',
      if (snapshot.windSpeed != null)
        '🌬 ${_round1(snapshot.windSpeed!)} km/h',
      if (snapshot.precipitation != null)
        '🌧 ${_round1(snapshot.precipitation!)} mm',
      if (snapshot.soilTemperature != null)
        '🌱 ${snapshot.soilTemperature!.round()}°C',
      if (snapshot.et0 != null) 'ET₀ ${_round1(snapshot.et0!)} mm',
    ];
    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final chip in chips)
          Text(chip,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _BandRow extends StatelessWidget {
  const _BandRow(
      {required this.label, required this.value, required this.theme});

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(width: 8),
        Text(value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
