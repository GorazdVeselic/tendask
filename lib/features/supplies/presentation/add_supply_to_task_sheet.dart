import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/sheet_handle.dart';
import '../../../i18n/translations.g.dart';
import '../application/supplies_providers.dart';
import '../data/supply_spec.dart';
import 'supply_edit_sheet.dart';

/// Picks an existing supply (or creates a new one) plus a consumed amount.
/// Returns the chosen [SupplySpec], or null if dismissed.
Future<SupplySpec?> showAddSupplyToTaskSheet(BuildContext context) {
  return showModalBottomSheet<SupplySpec>(
    context: context,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: const _AddSupplySheet(),
    ),
  );
}

class _AddSupplySheet extends ConsumerStatefulWidget {
  const _AddSupplySheet();

  @override
  ConsumerState<_AddSupplySheet> createState() => _AddSupplySheetState();
}

class _AddSupplySheetState extends ConsumerState<_AddSupplySheet> {
  String? _selectedId;
  final _amount = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _confirm() {
    final amount = double.tryParse(_amount.text.trim().replaceAll(',', '.'));
    if (_selectedId == null || amount == null || amount <= 0) return;
    Navigator.of(
      context,
    ).pop(SupplySpec(supplyId: _selectedId!, amount: amount));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final supplies = ref.watch(suppliesListProvider).asData?.value ?? const [];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            Text(t.supplies.add_to_task, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (supplies.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  t.supplies.empty,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final s in supplies)
                    ChoiceChip(
                      label: Text(s.name),
                      selected: s.id == _selectedId,
                      onSelected: (_) => setState(() => _selectedId = s.id),
                    ),
                ],
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  final id = await showSupplyEditSheet(context);
                  if (id != null && mounted) {
                    setState(() => _selectedId = id);
                  }
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text(t.supplies.pick_new),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: InputDecoration(
                labelText: t.supplies.amount,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _confirm,
                child: Text(t.supplies.add_confirm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
