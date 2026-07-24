import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../i18n/translations.g.dart';
import '../location_labels.dart';

/// Shows whether a garden location is already set, with an inline remove action
/// when it is. Calm by design: set = green, unset = amber (attention, not error).
class LocationStatusBanner extends StatelessWidget {
  const LocationStatusBanner({
    super.key,
    required this.isSet,
    this.placeName,
    this.onClear,
  });

  final bool isSet;

  /// The resolved place name, shown next to "set" when available.
  final String? placeName;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    // Set = palette primary-container (follows the colour theme); unset = the
    // fixed warn tone (attention, not error, and constant across all palettes).
    final bg = isSet ? theme.colorScheme.primaryContainer : AppColors.warnSoft;
    final fg = isSet ? theme.colorScheme.onPrimaryContainer : AppColors.warn;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isSet ? Icons.check_circle : Icons.error_outline,
            size: 18,
            color: fg,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              locationStatusLabel(t, isSet: isSet, placeName: placeName),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onClear != null)
            TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(t.location.clear),
            ),
        ],
      ),
    );
  }
}
