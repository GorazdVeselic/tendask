import 'package:flutter/material.dart';

import '../../../../../i18n/translations.g.dart';

/// The wizard's sticky footer: continue (or save, on review), plus a skip link
/// on the optional steps.
class EntryBottomBar extends StatelessWidget {
  const EntryBottomBar({
    super.key,
    required this.isReview,
    required this.isOptional,
    required this.canContinue,
    required this.isSaving,
    required this.onContinue,
    required this.onSave,
  });

  final bool isReview;
  final bool isOptional;
  final bool canContinue;
  final bool isSaving;
  final VoidCallback onContinue;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: isSaving || (!isReview && !canContinue)
                    ? null
                    : (isReview ? onSave : onContinue),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(isReview ? t.entry.save : t.entry.kContinue),
              ),
            ),
            if (isOptional)
              TextButton(onPressed: onContinue, child: Text(t.entry.skip)),
          ],
        ),
      ),
    );
  }
}
