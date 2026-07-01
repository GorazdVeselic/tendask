import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/widgets/sheet_handle.dart';
import '../../../i18n/translations.g.dart';
import '../application/supplies_providers.dart';
import '../data/supply_spec.dart';
import 'supply_category_display.dart';
import 'supply_edit_sheet.dart';

/// Picks an existing supply (or creates a new one) plus a consumed amount.
/// Returns the chosen [SupplySpec], or null if dismissed.
///
/// Layout is keyboard-safe: the supply list scrolls in the middle while the
/// amount field + confirm button stay pinned above the keyboard (viewInsets is
/// read inside the sheet so it tracks the keyboard).
Future<SupplySpec?> showAddSupplyToTaskSheet(BuildContext context) {
  return showModalBottomSheet<SupplySpec>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _AddSupplySheet(),
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
  final _amountFocus = FocusNode();
  final _search = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _amountFocus.dispose();
    _search.dispose();
    super.dispose();
  }

  void _toggle(String id) {
    // Tapping the selected supply again clears it.
    setState(() => _selectedId = _selectedId == id ? null : id);
    if (_selectedId != null) {
      _amountFocus.requestFocus(); // jump straight to entering the amount
    }
  }

  void _select(String id) {
    setState(() => _selectedId = id);
    _amountFocus.requestFocus();
  }

  double? get _parsedAmount =>
      double.tryParse(_amount.text.trim().replaceAll(',', '.'));

  bool get _valid => _selectedId != null && (_parsedAmount ?? 0) > 0;

  void _confirm() {
    if (!_valid) return;
    Navigator.of(
      context,
    ).pop(SupplySpec(supplyId: _selectedId!, amount: _parsedAmount!));
  }

  Future<void> _addNew() async {
    final id = await showSupplyEditSheet(context);
    if (id != null && mounted) _select(id);
  }

  Supply? _byId(List<Supply> all, String? id) {
    if (id == null) return null;
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final all = ref.watch(suppliesListProvider).asData?.value ?? const <Supply>[];

    final query = _search.text.trim().toLowerCase();
    final visible = query.isEmpty
        ? all
        : all.where((s) => s.name.toLowerCase().contains(query)).toList();
    final selected = _byId(all, _selectedId);
    final unit = selected?.unit ?? '';
    final showSearch = all.length > 8;

    return Padding(
      // Read viewInsets INSIDE the sheet so it tracks the keyboard; the pinned
      // footer then always sits just above it.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHandle(),
              Text(t.supplies.add_to_task, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              if (all.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    t.supplies.empty,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else ...[
                if (showSearch) ...[
                  TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: t.supplies.search,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: visible.length,
                    itemBuilder: (_, i) =>
                        _SupplyPickRow(supply: visible[i], selectedId: _selectedId, onTap: _toggle),
                  ),
                ),
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addNew,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(t.supplies.pick_new),
                ),
              ),
              const Divider(height: 8),
              // ── Pinned footer: amount (with unit) + confirm, above keyboard ──
              TextField(
                controller: _amount,
                focusNode: _amountFocus,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _confirm(),
                decoration: InputDecoration(
                  labelText: selected == null
                      ? t.supplies.amount
                      : '${t.supplies.amount} · ${selected.name}',
                  suffixText: unit.isEmpty ? null : unit,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _valid ? _confirm : null,
                  child: Text(t.supplies.add_confirm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupplyPickRow extends StatelessWidget {
  const _SupplyPickRow({
    required this.supply,
    required this.selectedId,
    required this.onTap,
  });

  final Supply supply;
  final String? selectedId;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final isSelected = supply.id == selectedId;
    final isLow =
        supply.quantity <= 0 ||
        (supply.lowThreshold != null && supply.quantity <= supply.lowThreshold!);
    final qty = supply.quantity < 0 ? 0.0 : supply.quantity;
    final qtyText = qty == qty.roundToDouble()
        ? qty.toInt().toString()
        : qty.toString();

    final qtyLabel = Text(
      isLow ? '⚠️ ${t.supplies.low}' : t.supplies.qty(q: qtyText, unit: supply.unit ?? ''),
      style: theme.textTheme.labelMedium?.copyWith(
        color: isLow ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
      ),
    );
    return ListTile(
      dense: true,
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer,
      selectedColor: theme.colorScheme.onPrimaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: Text(
        supplyCategoryIcon(supply.category),
        style: const TextStyle(fontSize: 20),
      ),
      title: Text(
        supply.name,
        style: isSelected ? const TextStyle(fontWeight: FontWeight.w700) : null,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          qtyLabel,
          if (isSelected) ...[
            const SizedBox(width: 8),
            Icon(Icons.check_circle, size: 18, color: theme.colorScheme.primary),
          ],
        ],
      ),
      onTap: () => onTap(supply.id),
    );
  }
}
