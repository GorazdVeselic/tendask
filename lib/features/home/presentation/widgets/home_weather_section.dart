import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/location/place_label_repository.dart';
import '../../../../i18n/translations.g.dart';
import '../../../weather/application/weather_service.dart';
import '../../../weather/presentation/weather_card.dart';
import '../../../weather/presentation/weather_detail_sheet.dart';

/// Live weather context for the dashboard. Offline → a quiet "unavailable" card.
class HomeWeatherSection extends ConsumerWidget {
  const HomeWeatherSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(currentWeatherProvider);
    // Keep the last snapshot visible while a refresh is in flight — the spinner
    // is only for the very first load, when there is nothing to show yet.
    final snapshot = weather.value;
    if (snapshot != null) {
      final lang = LocaleSettings.currentLocale.languageCode;
      final placeLabel = ref.watch(placeLabelProvider(lang)).value;
      return CurrentWeatherCard(
        snapshot: snapshot,
        placeLabel: placeLabel,
        onTap: () => showWeatherDetailSheet(
          context,
          initial: snapshot,
          placeLabel: placeLabel,
        ),
      );
    }
    if (weather.isLoading) return const _WeatherLoadingCard();
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => ref.invalidate(currentWeatherProvider),
      child: const CurrentWeatherCard(snapshot: null),
    );
  }
}

class _WeatherLoadingCard extends StatelessWidget {
  const _WeatherLoadingCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              context.t.weather.loading,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
