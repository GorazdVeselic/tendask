import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Fixed bottom action bar with a single full-width primary button.
/// Shows a spinner and disables itself while [isSaving].
class SaveBar extends StatelessWidget {
  const SaveBar({
    super.key,
    required this.onSave,
    required this.isSaving,
    required this.label,
  });

  final VoidCallback onSave;
  final bool isSaving;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      // Keep the button clear of the system gesture/navigation bar.
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: isSaving ? null : onSave,
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    )
                  : Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
