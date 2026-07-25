import 'package:flutter/material.dart';

import '../../../../i18n/translations.g.dart';

/// The footer every community screen carries: what the numbers are made of and
/// that nobody's individual garden is visible in them (§1). One widget, so the
/// promise is worded and styled identically wherever it appears.
class CommunityPrivacyNote extends StatelessWidget {
  const CommunityPrivacyNote({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
      child: Text(
        context.t.community.privacy_note,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
