import 'package:flutter/material.dart';

import '../../../../core/widgets/sheet_handle.dart';
import '../../../../i18n/translations.g.dart';

/// "How we read these numbers" — the honesty sheet behind every community
/// screen: where the sample comes from, why the comparison group and the scope
/// are what they are, and that this describes rather than advises (§1, §7.7).
void showCommunityExplainSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => const _ExplainSheet(),
  );
}

class _ExplainSheet extends StatelessWidget {
  const _ExplainSheet();

  @override
  Widget build(BuildContext context) {
    final t = context.t.community.detail.explain;
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  for (final paragraph in [
                    t.source,
                    t.cohort,
                    t.scope,
                    t.thresholds,
                    t.descriptive,
                  ]) ...[
                    const SizedBox(height: 12),
                    Text(paragraph, style: theme.textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(t.close),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
