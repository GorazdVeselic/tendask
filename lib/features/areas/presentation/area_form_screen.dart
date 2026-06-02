import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/area_type.dart';
import '../../../core/widgets/save_bar.dart';
import '../../../i18n/translations.g.dart';
import '../application/areas_providers.dart';
import 'area_type_display.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
      } else {
        await repo.create(
          // TODO(gorazd, 2026-12-01): replace with real auth.uid() in M7
          userId: 'local',
          name: name,
          type: _type,
        );
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
                      _FieldLabel(t.areas.form_name),
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
                      _FieldLabel(t.areas.form_type),
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
                      const SizedBox(height: 16),
                      // Plants in area — placeholder until M3.2 (plant picker).
                      _FieldLabel(t.areas.form_plants),
                      Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {}, // M3.2
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                const Text('🌿',
                                    style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 10),
                                Text(t.areas.form_plants_add,
                                    style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Text(
                          t.areas.form_plants_note,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _LocationInfo(text: t.areas.form_location_info),
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _LocationInfo extends StatelessWidget {
  const _LocationInfo({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📍', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
