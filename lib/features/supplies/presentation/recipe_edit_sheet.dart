import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/destructive_button.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/sheet_handle.dart';
import '../../../i18n/translations.g.dart';
import '../application/supplies_providers.dart';
import '../data/recipe_item.dart';
import 'add_supply_to_task_sheet.dart';

/// Opens the create/edit recipe sheet. Pass [recipeId] to edit an existing one.
Future<void> showRecipeEditSheet(BuildContext context, {String? recipeId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _RecipeEditSheet(recipeId: recipeId),
    ),
  );
}

class _RecipeEditSheet extends ConsumerStatefulWidget {
  const _RecipeEditSheet({this.recipeId});

  final String? recipeId;

  @override
  ConsumerState<_RecipeEditSheet> createState() => _RecipeEditSheetState();
}

class _RecipeEditSheetState extends ConsumerState<_RecipeEditSheet> {
  final _name = TextEditingController();
  final _equipment = TextEditingController();
  final _items = <RecipeItem>[];
  bool _loading = false;
  bool _saving = false;

  bool get _isEdit => widget.recipeId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loading = true;
      Future.microtask(_load);
    }
  }

  Future<void> _load() async {
    final r = await ref.read(recipesRepositoryProvider).byId(widget.recipeId!);
    if (!mounted) return;
    if (r != null) {
      _name.text = r.name;
      _equipment.text = r.equipment ?? '';
      _items.addAll(parseRecipeItems(r.items));
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _equipment.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    final spec = await showAddSupplyToTaskSheet(context);
    if (spec == null || !mounted) return;
    setState(() {
      _items.add(RecipeItem(supplyId: spec.supplyId, amount: spec.amount));
    });
  }

  Future<void> _save() async {
    final t = context.t;
    final name = _name.text.trim();
    if (name.isEmpty) {
      _err(t.recipes.err_name);
      return;
    }
    final equipment = _equipment.text.trim().isEmpty
        ? null
        : _equipment.text.trim();

    setState(() => _saving = true);
    final repo = ref.read(recipesRepositoryProvider);
    try {
      if (_isEdit) {
        await repo.update(
          id: widget.recipeId!,
          name: name,
          equipment: equipment,
          items: _items,
        );
      } else {
        await repo.create(
          userId: ref.read(authServiceProvider).userId,
          name: name,
          equipment: equipment,
          items: _items,
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _err(t.common.save_error);
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final t = context.t;
    final confirmed = await showConfirmDialog(
      context,
      title: t.recipes.form_delete,
      body: t.recipes.delete_note,
      confirmLabel: t.recipes.form_delete,
      cancelLabel: t.tasks_list.delete_cancel,
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(recipesRepositoryProvider).softDelete(widget.recipeId!);
    } catch (_) {
      if (mounted) _err(t.common.save_error);
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final catalog = ref.watch(suppliesListProvider).asData?.value ?? const [];
    final byId = {for (final s in catalog) s.id: s};

    String itemLabel(RecipeItem item) {
      final supply = byId[item.supplyId];
      // Supply may have been deleted since the recipe was saved — show a
      // placeholder instead of a bare UUID so the user can drop the stale item.
      final name = supply?.name ?? t.recipes.item_removed;
      final unit = supply?.unit ?? '';
      final amount = item.amount == item.amount.roundToDouble()
          ? item.amount.toInt().toString()
          : item.amount.toString();
      return '$name — $amount$unit';
    }

    return SafeArea(
      child: _loading
          ? const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SheetHandle(),
                  Text(
                    _isEdit ? t.recipes.form_edit : t.recipes.form_new,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _name,
                    autofocus: !_isEdit,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: t.recipes.form_name,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _equipment,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: t.recipes.form_equipment,
                      hintText: t.recipes.form_equipment_hint,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionLabel(t.recipes.items),
                  Card(
                    child: Column(
                      children: [
                        for (var i = 0; i < _items.length; i++)
                          ListTile(
                            dense: true,
                            leading: const Text(
                              '🧪',
                              style: TextStyle(fontSize: 18),
                            ),
                            title: Text(
                              itemLabel(_items[i]),
                              style: theme.textTheme.bodyMedium,
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 18,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () =>
                                  setState(() => _items.removeAt(i)),
                            ),
                          ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(t.recipes.add_item),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(t.recipes.form_save),
                    ),
                  ),
                  if (_isEdit)
                    DestructiveButton(
                      label: t.recipes.form_delete,
                      onPressed: _delete,
                    ),
                ],
              ),
            ),
    );
  }
}
