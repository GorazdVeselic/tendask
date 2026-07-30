import 'package:flutter/material.dart';

import '../../../core/widgets/link_span.dart';
import '../../../i18n/translations.g.dart';
import '../data/weather_code.dart';

/// Stands in for the weather card when no garden location is set (FR-22): the
/// app has no honest weather to show, so it says whose weather is missing and
/// why, in the slot where the forecast would be. Deliberately the size of the
/// quiet "unavailable" card, not a full-screen prompt — Home is not a supplicant.
///
/// Takes no `ref`: the navigation arrives as [onSetLocation], so the layout
/// matrix can render it without a world of providers behind it.
class WeatherNoLocationCard extends StatelessWidget {
  const WeatherNoLocationCard({super.key, required this.onSetLocation});

  /// Opens the location screen. The whole card is the target; the underlined
  /// word is only the cue.
  final VoidCallback onSetLocation;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSetLocation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(kNoWeatherEmoji, style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.weather.no_location_title,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      // One translated sentence with the linked word inside it;
                      // splitting it into pieces would break German word order.
                      t.weather.no_location_body(
                        link: (text) => linkSpan(context, text),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
