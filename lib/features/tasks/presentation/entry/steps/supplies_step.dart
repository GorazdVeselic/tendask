import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../i18n/translations.g.dart';
import '../../../../supplies/application/supplies_providers.dart';
import '../../../../supplies/data/supply_spec.dart';
import '../../../../supplies/presentation/add_supply_to_task_sheet.dart';

/// Step 5 — supplies consumed by the task (deducted from stock on completion).
/// Shown only for supply-consuming types (task_type.consumes_supplies).
class SuppliesStepBody extends ConsumerWidget {
  const SuppliesStepBody({
    super.key,
    required this.supplies,
    required this.onAdd,
    required this.onRemove,
  });

  final List<SupplySpec> supplies;
  final ValueChanged<SupplySpec> onAdd;
  final ValueChanged<int> onRemove;

  Future<void> _add(BuildContext context) async {
    final spec = await showAddSupplyToTaskSheet(context);
    if (spec != null) onAdd(spec);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final catalog = ref.watch(suppliesListProvider).asData?.value ?? const [];
    final byId = {for (final s in catalog) s.id: s};

    String label(SupplySpec spec) {
      final supply = byId[spec.supplyId];
      final name = supply?.name ?? spec.supplyId;
      final unit = supply?.unit ?? '';
      final amount = spec.amount == spec.amount.roundToDouble()
          ? spec.amount.toInt().toString()
          : spec.amount.toString();
      return '$name — $amount$unit';
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        Card(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Text('🧪', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.entry.supplies_why,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < supplies.length; i++)
                ListTile(
                  dense: true,
                  leading: const Text('🧪', style: TextStyle(fontSize: 18)),
                  title: Text(
                    label(supplies[i]),
                    style: theme.textTheme.bodyMedium,
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => onRemove(i),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _add(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(t.entry.supplies_add),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          t.entry.supplies_note,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
