import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/area_type.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/destructive_button.dart';
import '../../../core/widgets/save_bar.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../application/areas_providers.dart';
import 'area_type_display.dart';

/// Add or edit an area: name + type only. Plants are attached from the plant
/// side (add screen / move), never here — an area is a place, not a container
/// of plants (koncept.md §7.15).
class AreaFormScreen extends ConsumerStatefulWidget {
  const AreaFormScreen({super.key, this.areaId});

  /// Null = create mode; non-null = edit mode.
  final String? areaId;

  @override
  ConsumerState<AreaFormScreen> createState() => _AreaFormScreenState();
}

class _AreaFormScreenState extends ConsumerState<AreaFormScreen> {
  final _nameController = TextEditingController();
  AreaType _type = AreaType.other;
  bool _isLoading = false;
  bool _isSaving = false;

  bool get _isEdit => widget.areaId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _isLoading = true;
      Future.microtask(_loadArea);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadArea() async {
    final area = await ref.read(areasRepositoryProvider).byId(widget.areaId!);
    if (!mounted) return;
    if (area != null) {
      setState(() {
        _nameController.text = area.name;
        _type = area.type;
      });
    }
    setState(() => _isLoading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _save() async {
    final t = context.t;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError(t.areas.err_name);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(areasRepositoryProvider);
      if (_isEdit) {
        await repo.update(id: widget.areaId!, name: name, type: _type);
        if (mounted) context.pop();
      } else {
        final userId = ref.read(authServiceProvider).userId;
        final areaId = await repo.create(
          userId: userId,
          name: name,
          type: _type,
        );
        // Return the new id so callers can auto-select it (area-pick sheet,
        // entry subject step).
        if (mounted) context.pop(areaId);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final t = context.t;
    final confirmed = await showConfirmDialog(
      context,
      title: t.areas.delete_confirm_title,
      body: t.areas.delete_confirm_body,
      confirmLabel: t.areas.action_delete,
      cancelLabel: t.tasks_list.delete_cancel,
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(areasRepositoryProvider).softDelete(widget.areaId!);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: context.pop,
        ),
        title: Text(_isEdit ? t.areas.form_title_edit : t.areas.form_title_new),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    children: [
                      FieldLabel(t.areas.form_name),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: t.areas.form_name_hint,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),
                      FieldLabel(t.areas.form_type),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          for (final type in AreaType.values)
                            ChoiceChip(
                              label: Text(areaTypeLabel(type, t)),
                              selected: type == _type,
                              onSelected: (_) => setState(() => _type = type),
                            ),
                        ],
                      ),
                      if (_isEdit) ...[
                        const SizedBox(height: 24),
                        DestructiveButton(
                          label: t.areas.action_delete,
                          onPressed: _delete,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            t.areas.delete_reparent_note,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SaveBar(
                  onSave: _save,
                  isSaving: _isSaving,
                  label: t.areas.form_save,
                ),
              ],
            ),
    );
  }
}
