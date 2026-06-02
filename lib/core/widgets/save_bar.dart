import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
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
    );
  }
}
