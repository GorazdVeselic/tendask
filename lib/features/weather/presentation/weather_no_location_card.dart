import 'package:flutter/material.dart';

import '../../../i18n/translations.g.dart';

/// Stands in for the weather card when no garden location is set (FR-22): the
/// app has no honest weather to show, so it offers the one way forward instead.
/// Not a state of CurrentWeatherCard — that card shows weather, and an invite
/// is not weather.
///
/// Takes no `ref`: the navigation arrives as [onSetLocation], so the layout
/// matrix can render it without a world of providers behind it.
class WeatherNoLocationCard extends StatelessWidget {
  const WeatherNoLocationCard({super.key, required this.onSetLocation});

  /// Opens the location screen. Both the button and the whole card call it —
  /// the button is the visual cue, the card is the target.
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.place, size: 26, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.weather.no_location_title,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                t.weather.no_location_body,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: onSetLocation,
                  child: Text(t.weather.no_location_cta),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 12, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  // Flexible, not fixed: the German line wraps at 320 dp with a
                  // large system font.
                  Flexible(
                    child: Text(
                      t.weather.no_location_privacy,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
