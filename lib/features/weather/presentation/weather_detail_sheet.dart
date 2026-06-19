import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/date_format.dart';
import '../../../core/widgets/sheet_handle.dart';
import '../../../i18n/translations.g.dart';
import '../application/weather_service.dart';
import '../data/weather_code.dart';
import '../data/weather_snapshot.dart';
import 'weather_card.dart';

/// Opens the weather detail sheet from the dashboard card. [initial] is the
/// light snapshot already shown on Home, so the sheet renders instantly with
/// the header + forecast while the full snapshot (humidity, wind, soil, ET₀,
/// 48 h rain) is fetched in the background.
Future<void> showWeatherDetailSheet(
  BuildContext context, {
  required WeatherSnapshot initial,
  String? placeLabel,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    // Root navigator so the sheet covers the shell's FAB + bottom nav (they live
    // on the shell Scaffold, outside this branch's body) instead of floating
    // above the sheet.
    useRootNavigator: true,
    builder: (_) => _WeatherDetailSheet(initial: initial, placeLabel: placeLabel),
  );
}

class _WeatherDetailSheet extends ConsumerWidget {
  const _WeatherDetailSheet({required this.initial, this.placeLabel});

  final WeatherSnapshot initial;
  final String? placeLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final detail = ref.watch(weatherDetailProvider);
    // Show the full snapshot once it arrives; until then fall back to the light
    // snapshot Home already had, so the sheet is never blank.
    final snap = detail.value ?? initial;
    final loadingMetrics = detail.isLoading && detail.value == null;

    final condition = weatherConditionFromCode(snap.weatherCode);
    final metrics = _metricsFor(snap, t);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (placeLabel != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 15,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            placeLabel!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Text(
                        weatherEmoji(condition),
                        style: const TextStyle(fontSize: 44),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _bigTemp(snap.temperature),
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            weatherConditionLabel(condition, t),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.weather.updated_at(time: _stamp(snap.capturedAt)),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (metrics.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _MetricsGrid(metrics),
                  ] else if (loadingMetrics) ...[
                    const SizedBox(height: 18),
                    const _MetricsLoading(),
                  ],
                  if (snap.forecast.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      t.weather.band_forecast.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    for (final day in snap.forecast) _ForecastRow(day),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One raw weather metric for the grid (icon + label + value + unit).
typedef _Metric = ({String icon, String label, String value, String unit});

List<_Metric> _metricsFor(WeatherSnapshot s, Translations t) => [
  if (s.humidity != null)
    (icon: '💧', label: t.weather.m_humidity, value: '${s.humidity!.round()}', unit: '%'),
  if (s.windSpeed != null)
    (icon: '🌬', label: t.weather.m_wind, value: _round1(s.windSpeed!), unit: 'km/h'),
  if (s.precipitation != null)
    (icon: '🌧', label: t.weather.m_precipitation, value: _round1(s.precipitation!), unit: 'mm'),
  if (s.soilTemperature != null)
    (icon: '🌱', label: t.weather.m_soil_temp, value: '${s.soilTemperature!.round()}', unit: '°C'),
  if (s.et0 != null)
    (icon: '☀️', label: t.weather.m_et0, value: _round1(s.et0!), unit: 'mm'),
  if (s.rainPast48h != null)
    (icon: '🌧', label: t.weather.m_rain48h, value: _round1(s.rainPast48h!), unit: 'mm'),
];

/// Lays the metric cells out three per row, filling the trailing gap so the
/// last row's cells keep the same width as the rest.
class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid(this.metrics);

  final List<_Metric> metrics;

  @override
  Widget build(BuildContext context) {
    const perRow = 3;
    final rows = <Widget>[];
    for (var i = 0; i < metrics.length; i += perRow) {
      final slice = metrics.skip(i).take(perRow).toList();
      rows.add(
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var c = 0; c < perRow; c++) ...[
                  if (c > 0) const SizedBox(width: 8),
                  Expanded(
                    child: c < slice.length
                        ? _MetricCell(slice[c])
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell(this.metric);

  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 11),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${metric.icon} ${metric.label}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(color: muted),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              text: metric.value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              children: [
                TextSpan(
                  text: ' ${metric.unit}',
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsLoading extends StatelessWidget {
  const _MetricsLoading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
        const SizedBox(width: 10),
        Text(
          context.t.weather.loading,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ForecastRow extends StatelessWidget {
  const _ForecastRow(this.day);

  final WeatherDay day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final rain = day.precipitationSum;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              formatDm(day.date),
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ),
          Text(
            weatherEmoji(weatherConditionFromCode(day.weatherCode)),
            style: const TextStyle(fontSize: 20),
          ),
          const Spacer(),
          Text.rich(
            TextSpan(
              text: _temp(day.tempMax),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: ' / ${_temp(day.tempMin)}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 64,
            child: Text(
              rain == null || rain == 0
                  ? context.t.weather.m_no_rain
                  : '${_round1(rain)} mm',
              textAlign: TextAlign.end,
              style: theme.textTheme.labelMedium?.copyWith(
                color: rain != null && rain > 0
                    ? theme.colorScheme.primary
                    : muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _bigTemp(double? c) => c == null ? '—' : '${c.round()}°';

String _temp(double? c) => c == null ? '—' : '${c.round()}°';

/// "Updated at" stamp for the sheet — always shown (unlike the card, which hides
/// it while fresh); time only for today, date + time otherwise.
String _stamp(DateTime capturedAtUtc) {
  final local = capturedAtUtc.toLocal();
  final time = formatHm(local);
  return startOfDay(local) == startOfDay(DateTime.now())
      ? time
      : '${formatDm(local)} $time';
}

String _round1(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
