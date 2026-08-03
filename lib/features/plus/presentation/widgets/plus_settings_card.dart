import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_icons.dart';
import '../../../../core/config.dart';
import '../../../../i18n/translations.g.dart';
import '../plus_label.dart';

/// Gate for the Settings entry point: dark until ignition, so with
/// [kTendaskPlusEnabled] off Settings looks exactly as it does today.
class PlusSettingsCard extends StatelessWidget {
  const PlusSettingsCard({super.key});

  @override
  Widget build(BuildContext context) =>
      kTendaskPlusEnabled ? const PlusEntryCard() : const SizedBox.shrink();
}

/// The highlighted "✦ Tendask+" card in Settings, right under the profile
/// (screen-map §2.1) — the main way into `/tendask-plus`. Public so previews,
/// tests and the layout matrix can draw it without flipping the flag.
class PlusEntryCard extends StatelessWidget {
  const PlusEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final onContainer = theme.colorScheme.onPrimaryContainer;

    return Card(
      color: theme.colorScheme.primaryContainer,
      // On the dark theme the tinted fill sits a hair off the card beside it
      // (both are dark green), so the outline is what makes this read as the
      // highlighted row rather than one more setting.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary),
      ),
      child: ListTile(
        leading: const Icon(kPlusMarkIcon),
        title: Text(
          kPlusLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(t.plus.tagline),
        trailing: const Icon(kIconChevronRight),
        textColor: onContainer,
        iconColor: onContainer,
        onTap: () => context.pushNamed('tendask-plus'),
      ),
    );
  }
}
