import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/destructive_button.dart';
import '../../../core/widgets/sheet_handle.dart';
import '../../../i18n/translations.g.dart';
import '../application/supplies_providers.dart';

/// Opens the create/edit supply sheet. Returns the supply id on save, or null
/// if dismissed. Pass [supplyId] to edit an existing supply.
Future<String?> showSupplyEditSheet(BuildContext context, {String? supplyId}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _SupplyEditSheet(supplyId: supplyId),
    ),
  );
}

class _SupplyEditSheet extends ConsumerStatefulWidget {
  const _SupplyEditSheet({this.supplyId});

  final String? supplyId;

  @override
  ConsumerState<_SupplyEditSheet> createState() => _SupplyEditSheetState();
}

class _SupplyEditSheetState extends ConsumerState<_SupplyEditSheet> {
  final _name = TextEditingController();
  final _unit = TextEditingController();
  final _quantity = TextEditingController();
  final _threshold = TextEditingController();
  bool _loading = false;
  bool _saving = false;

  bool get _isEdit => widget.supplyId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loading = true;
      Future.microtask(_load);
    }
  }

  Future<void> _load() async {
    final s = await ref.read(suppliesRepositoryProvider).byId(widget.supplyId!);
    if (!mounted) return;
    if (s != null) {
      _name.text = s.name;
      _unit.text = s.unit ?? '';
      _quantity.text = _fmt(s.quantity);
      _threshold.text = s.lowThreshold != null ? _fmt(s.lowThreshold!) : '';
    }
    setState(() => _loading = false);
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  static double? _parse(String s) =>
      double.tryParse(s.trim().replaceAll(',', '.'));

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    _quantity.dispose();
    _threshold.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = context.t;
    final name = _name.text.trim();
    if (name.isEmpty) {
      _err(t.supplies.err_name);
      return;
    }
    final quantity = _parse(_quantity.text) ?? 0;
    final unit = _unit.text.trim().isEmpty ? null : _unit.text.trim();
    final threshold = _parse(_threshold.text);

    setState(() => _saving = true);
    final repo = ref.read(suppliesRepositoryProvider);
    final String id;
    if (_isEdit) {
      await repo.update(
        id: widget.supplyId!,
        name: name,
        unit: unit,
        quantity: quantity,
        lowThreshold: threshold,
      );
      id = widget.supplyId!;
    } else {
      id = await repo.create(
        userId: ref.read(authServiceProvider).userId,
        name: name,
        unit: unit,
        quantity: quantity,
        lowThreshold: threshold,
      );
    }
    if (mounted) Navigator.of(context).pop(id);
  }

  Future<void> _delete() async {
    final t = context.t;
    final confirmed = await showConfirmDialog(
      context,
      title: t.supplies.form_delete,
      body: t.supplies.delete_note,
      confirmLabel: t.supplies.form_delete,
      cancelLabel: t.tasks_list.delete_cancel,
    );
    if (!confirmed || !mounted) return;
    await ref.read(suppliesRepositoryProvider).softDelete(widget.supplyId!);
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
                    _isEdit ? t.supplies.form_edit : t.supplies.form_new,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _name,
                    autofocus: !_isEdit,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: t.supplies.form_name,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _quantity,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]'),
                            ),
                          ],
                          decoration: InputDecoration(
                            labelText: t.supplies.form_quantity,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _unit,
                          decoration: InputDecoration(
                            labelText: t.supplies.form_unit,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _threshold,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: InputDecoration(
                      labelText: t.supplies.form_threshold,
                      border: const OutlineInputBorder(),
                      isDense: true,
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
                          : Text(t.supplies.form_save),
                    ),
                  ),
                  if (_isEdit)
                    DestructiveButton(
                      label: t.supplies.form_delete,
                      onPressed: _delete,
                    ),
                ],
              ),
            ),
    );
  }
}
