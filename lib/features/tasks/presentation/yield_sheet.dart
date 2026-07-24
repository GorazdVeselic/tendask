import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/destructive_button.dart';
import '../../../core/widgets/sheet_handle.dart';
import '../../../i18n/translations.g.dart';
import '../yield_unit.dart';
import 'yield_format.dart';

/// A harvest yield the user entered: amount + unit.
class YieldDraft {
  const YieldDraft({required this.amount, required this.unit});
  final double amount;
  final YieldUnit unit;
}

/// Outcome of the yield sheet. Dismissing (or "Skip") returns null; "Save"
/// returns [YieldSaved]; "Remove yield" returns [YieldCleared].
sealed class YieldSheetResult {
  const YieldSheetResult();
}

class YieldSaved extends YieldSheetResult {
  const YieldSaved(this.draft);
  final YieldDraft draft;
}

class YieldCleared extends YieldSheetResult {
  const YieldCleared();
}

/// Bottom sheet to record/edit a harvest yield. One sheet for every entry point:
/// completion (skip-able), wizard review, and the detail screen (with remove).
Future<YieldSheetResult?> showYieldSheet(
  BuildContext context, {
  YieldDraft? initial,
  bool allowSkip = false,
  bool allowRemove = false,
}) {
  return showModalBottomSheet<YieldSheetResult>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: _YieldSheet(
        initial: initial,
        allowSkip: allowSkip,
        allowRemove: allowRemove,
      ),
    ),
  );
}

class _YieldSheet extends StatefulWidget {
  const _YieldSheet({
    required this.initial,
    required this.allowSkip,
    required this.allowRemove,
  });

  final YieldDraft? initial;
  final bool allowSkip;
  final bool allowRemove;

  @override
  State<_YieldSheet> createState() => _YieldSheetState();
}

class _YieldSheetState extends State<_YieldSheet> {
  late final TextEditingController _amount;
  late YieldUnit _unit;
  // Drives the Save button's enabled state without rebuilding the whole sheet.
  final ValueNotifier<bool> _valid = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _amount = TextEditingController(
      text: initial != null ? formatYieldAmount(initial.amount) : '',
    );
    _unit = initial?.unit ?? kDefaultYieldUnit;
    _valid.value = _parseAmount() != null;
    _amount.addListener(() => _valid.value = _parseAmount() != null);
  }

  @override
  void dispose() {
    _amount.dispose();
    _valid.dispose();
    super.dispose();
  }

  double? _parseAmount() {
    final value = double.tryParse(_amount.text.trim().replaceAll(',', '.'));
    // isFinite rejects a pasted huge number that parses to Infinity (it would
    // pass `> 0` and the Supabase CHECK, then crash formatYieldAmount).
    return (value != null && value.isFinite && value > 0) ? value : null;
  }

  // Guards every exit against a double-tap: a second pop would close the screen
  // behind the sheet, not just the sheet.
  bool _closed = false;
  void _close([YieldSheetResult? result]) {
    if (_closed) return;
    _closed = true;
    Navigator.of(context).pop(result);
  }

  void _save() {
    final amount = _parseAmount();
    if (amount == null) return;
    _close(YieldSaved(YieldDraft(amount: amount, unit: _unit)));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            Text(t.harvest.sheet_title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: _amount,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: InputDecoration(
                labelText: t.harvest.amount_label,
                hintText: t.harvest.amount_hint,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t.harvest.unit_label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final unit in YieldUnit.values)
                  ChoiceChip(
                    label: Text(yieldUnitLabel(unit, t)),
                    selected: unit == _unit,
                    onSelected: (_) => setState(() => _unit = unit),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: _valid,
              builder: (context, valid, _) => SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: valid ? _save : null,
                  child: Text(t.harvest.save),
                ),
              ),
            ),
            if (widget.allowSkip)
              TextButton(
                onPressed: _close,
                child: Text(t.harvest.skip),
              ),
            if (widget.allowRemove)
              DestructiveButton(
                label: t.harvest.remove,
                onPressed: () => _close(const YieldCleared()),
              ),
          ],
        ),
      ),
    );
  }
}
