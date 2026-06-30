import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/supply_category.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../application/supplies_providers.dart';
import 'supply_category_display.dart';
import 'supply_edit_sheet.dart';

class SuppliesScreen extends ConsumerWidget {
  const SuppliesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final supplies = ref.watch(suppliesListProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: context.pop,
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.supplies.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              t.supplies.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showSupplyEditSheet(context),
          ),
        ],
      ),
      body: supplies == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : supplies.isEmpty
          ? EmptyState(t.supplies.empty)
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: _grouped(supplies, t),
            ),
    );
  }

  /// Sections in [SupplyCategory] declaration order; empty categories are
  /// dropped. Supplies arrive already name-sorted from the provider.
  List<Widget> _grouped(List<Supply> supplies, Translations t) {
    final widgets = <Widget>[];
    for (final category in SupplyCategory.values) {
      final inGroup = supplies.where((s) => s.category == category).toList();
      if (inGroup.isEmpty) continue;
      widgets.add(SectionLabel(supplyCategoryLabel(category, t)));
      widgets.addAll(inGroup.map((s) => _SupplyRow(supply: s)));
    }
    return widgets;
  }
}

class _SupplyRow extends StatelessWidget {
  const _SupplyRow({required this.supply});

  final Supply supply;

  bool get _isLow =>
      supply.lowThreshold != null && supply.quantity <= supply.lowThreshold!;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final unit = supply.unit ?? '';
    final qtyText = t.supplies.qty(q: _fmt(supply.quantity), unit: unit);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        leading: Text(
          supplyCategoryIcon(supply.category),
          style: const TextStyle(fontSize: 22),
        ),
        title: Text(supply.name, style: theme.textTheme.bodyMedium),
        subtitle: supply.unit != null
            ? Text(supply.unit!, style: theme.textTheme.bodySmall)
            : null,
        trailing: _isLow
            ? Text(
                '⚠️ ${t.supplies.low}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              )
            : Text(
                qtyText,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
        onTap: () => showSupplyEditSheet(context, supplyId: supply.id),
      ),
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}
