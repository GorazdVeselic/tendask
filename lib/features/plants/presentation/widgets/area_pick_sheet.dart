import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/sheet_handle.dart';
import '../../../../i18n/translations.g.dart';
import '../../../areas/application/areas_providers.dart';
import '../../../areas/presentation/area_type_display.dart';

/// Result of [showAreaPickSheet]: [areaId] is null for "no area", otherwise a
/// real area id. The sheet writes NOTHING — the caller persists the choice
/// (so it stays reusable for both moving a plant and choosing an add target).
typedef AreaPick = ({String? areaId});

/// Single-select area picker as a bottom sheet. Resolves to null when dismissed
/// without choosing, or an [AreaPick] (possibly `(areaId: null)` = no area).
Future<AreaPick?> showAreaPickSheet(
  BuildContext context, {
  required String title,
  String? currentAreaId,
}) {
  return showModalBottomSheet<AreaPick>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _AreaPickSheet(title: title, currentAreaId: currentAreaId),
  );
}

class _AreaPickSheet extends ConsumerWidget {
  const _AreaPickSheet({required this.title, this.currentAreaId});

  final String title;
  final String? currentAreaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final areas = ref.watch(areasListProvider).asData?.value ?? const <Area>[];

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(t.area_pick.note,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                _OptionTile(
                  leading: Icon(Icons.inbox_outlined,
                      color: theme.colorScheme.onSurfaceVariant),
                  label: t.area_pick.none,
                  selected: currentAreaId == null,
                  onTap: () =>
                      Navigator.of(context).pop<AreaPick>((areaId: null)),
                ),
                for (final a in areas)
                  _OptionTile(
                    leading: Text(areaTypeIcon(a.type),
                        style: const TextStyle(fontSize: 20)),
                    label: a.name,
                    subtitle: a.id == currentAreaId ? t.area_pick.current : null,
                    selected: a.id == currentAreaId,
                    onTap: () =>
                        Navigator.of(context).pop<AreaPick>((areaId: a.id)),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          ListTile(
            leading: Icon(Icons.add, color: theme.colorScheme.primary),
            title: Text(t.area_pick.new_area,
                style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600)),
            onTap: () async {
              final newId = await context.pushNamed<String>('area-new');
              if (newId != null && context.mounted) {
                Navigator.of(context).pop<AreaPick>((areaId: newId));
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.leading,
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final Widget leading;
  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: SizedBox(width: 26, child: Center(child: leading)),
      title: Text(label),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant))
          : null,
      trailing: selected
          ? Icon(Icons.check, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
