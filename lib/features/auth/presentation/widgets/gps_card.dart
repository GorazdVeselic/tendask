import 'package:flutter/material.dart';

import '../../../../i18n/translations.g.dart';

/// Alternative option: let the device GPS fill in the location.
class GpsCard extends StatelessWidget {
  const GpsCard({
    super.key,
    required this.loading,
    required this.onTap,
    this.emphasised = false,
  });

  final bool loading;
  final VoidCallback onTap;

  /// The filled variant, used in onboarding while no location is set: it is the
  /// only prominent surface on the screen, so nothing emphasised leads past the
  /// step (FR-24).
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final background = emphasised ? cs.primary : cs.surface;
    final foreground = emphasised ? cs.onPrimary : cs.onSurface;
    final muted = emphasised
        ? cs.onPrimary.withValues(alpha: 0.82)
        : cs.onSurfaceVariant;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: loading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: emphasised ? background : cs.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: emphasised
                      ? cs.onPrimary.withValues(alpha: 0.18)
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.my_location,
                  color: emphasised ? cs.onPrimary : cs.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.location.use_gps,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.location.gps_sub,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}

/// A centred "or" between the two location options.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            context.t.location.or,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
