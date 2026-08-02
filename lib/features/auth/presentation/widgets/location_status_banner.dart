import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../core/app_icons.dart';
import '../../../../i18n/translations.g.dart';

/// How long the banner takes to swap states. Long enough to read as a change
/// that just happened — this banner is the screen's only save confirmation, so
/// an instant swap would go unnoticed (FR-24).
const _flipDuration = kMotionSlow;

/// How far the second line is indented, so the place name starts under the
/// status text rather than under its icon.
const _textIndent = 26.0;

/// Shows whether a garden location is already set, with an inline remove action
/// when it is. Calm by design: set = green, unset = amber (attention, not error).
///
/// Set reads as two lines — status above, place name and "remove" below — so the
/// banner keeps its height whatever the place is called; a single line with the
/// name and the button beside it wrapped to three on narrow phones.
class LocationStatusBanner extends StatelessWidget {
  const LocationStatusBanner({
    super.key,
    required this.isSet,
    this.placeName,
    this.onClear,
  });

  final bool isSet;

  /// The place name for the second line; null while it is still unresolved
  /// (or offline), which leaves the line to the remove action alone.
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
    final label = isSet ? t.location.status_set : t.location.status_unset;

    // Cross-fade on every content change (set, cleared, place name resolved):
    // the movement is what tells the user their tap landed. AnimatedSize keeps
    // the height change smooth when a long place name wraps to a second line.
    return AnimatedSize(
      duration: _flipDuration,
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: _flipDuration,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1).animate(animation),
            child: child,
          ),
        ),
        child: Container(
          key: ValueKey('$isSet·$placeName'),
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isSet ? kIconCheckCircle : kIconErrorOutline,
                    size: 18,
                    color: fg,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (isSet)
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: _textIndent),
                        child: Text(
                          placeName ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w700,
                          ),
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
            ],
          ),
        ),
      ),
    );
  }
}
