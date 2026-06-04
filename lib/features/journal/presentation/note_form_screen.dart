import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/date_format.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/destructive_button.dart';
import '../../../core/widgets/save_bar.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../../areas/application/areas_providers.dart';
import '../../plants/application/plants_providers.dart';
import '../../plants/presentation/plant_picker_screen.dart';
import '../../plants/presentation/widgets/plant_field.dart';
import '../application/notes_providers.dart';

enum _DateOption { today, yesterday, custom }

class NoteFormScreen extends ConsumerStatefulWidget {
  const NoteFormScreen({super.key, this.noteId});

  /// Null = create mode; non-null = edit mode.
  final String? noteId;

  @override
  ConsumerState<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends ConsumerState<NoteFormScreen> {
  final _contentController = TextEditingController();
  String? _areaId;
  String? _userPlantId;
  _DateOption _dateOption = _DateOption.today;
  DateTime? _customDate;
  bool _isLoading = false;
  bool _isSaving = false;

  bool get _isEdit => widget.noteId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _isLoading = true;
      Future.microtask(_loadNote);
    }
  }

  Future<void> _loadNote() async {
    final note = await ref.read(notesRepositoryProvider).byId(widget.noteId!);
    if (!mounted) return;
    if (note != null) {
      setState(() {
        _contentController.text = note.content;
        _areaId = note.areaId;
        _userPlantId = note.userPlantId;
        _customDate = note.date.toLocal();
        _dateOption = _optionForDate(_customDate!);
      });
    }
    setState(() => _isLoading = false);
  }

  static _DateOption _optionForDate(DateTime date) {
    final today = startOfDay(DateTime.now());
    final day = startOfDay(date);
    if (day == today) return _DateOption.today;
    if (day == today.subtract(const Duration(days: 1))) {
      return _DateOption.yesterday;
    }
    return _DateOption.custom;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  DateTime get _selectedDate {
    final now = DateTime.now();
    return switch (_dateOption) {
      _DateOption.today => now,
      _DateOption.yesterday => now.subtract(const Duration(days: 1)),
      _DateOption.custom => _customDate ?? now,
    };
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _customDate = picked;
        _dateOption = _DateOption.custom;
      });
    }
  }

  Future<void> _addPlant() async {
    if (_areaId == null) return;
    final pick = await context.pushNamed<PlantPick>('plant-picker');
    if (pick == null || !mounted) return;
    final id = await ref.read(userPlantsRepositoryProvider).createForArea(
          // TODO(gorazd, 2026-12-01): replace with real auth.uid() in M7
          userId: 'local',
          areaId: _areaId!,
          plantId: pick.plantId,
          customName: pick.customName,
        );
    if (mounted) setState(() => _userPlantId = id);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _save() async {
    final t = context.t;
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      _showError(t.notes.err_content);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(notesRepositoryProvider);
      if (_isEdit) {
        await repo.updateNote(
          id: widget.noteId!,
          date: _selectedDate,
          content: content,
          areaId: _areaId,
          userPlantId: _userPlantId,
        );
      } else {
        await repo.create(
          // TODO(gorazd, 2026-12-01): replace with real auth.uid() in M7
          userId: 'local',
          date: _selectedDate,
          content: content,
          areaId: _areaId,
          userPlantId: _userPlantId,
        );
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final t = context.t;
    final confirmed = await showConfirmDialog(
      context,
      title: t.notes.delete,
      body: t.notes.delete_confirm,
      confirmLabel: t.notes.delete,
      cancelLabel: t.tasks_list.delete_cancel,
    );
    if (!confirmed || !mounted) return;
    await ref.read(notesRepositoryProvider).softDelete(widget.noteId!);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: context.pop,
        ),
        title: Text(_isEdit ? t.notes.title_edit : t.notes.title_new),
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
                      FieldLabel(t.notes.content_label),
                      TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          hintText: t.notes.content_hint,
                          border: const OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        minLines: 6,
                        maxLines: 10,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),
                      FieldLabel(t.notes.when),
                      _DateSegment(
                        option: _dateOption,
                        customDate: _customDate,
                        onChanged: (opt) => setState(() => _dateOption = opt),
                        onPickDate: _pickDate,
                      ),
                      const SizedBox(height: 16),
                      FieldLabel(t.notes.area),
                      _AreaField(
                        selectedId: _areaId,
                        onChanged: (id) => setState(() {
                          _areaId = id;
                          _userPlantId = null;
                        }),
                      ),
                      if (_areaId != null) ...[
                        const SizedBox(height: 16),
                        FieldLabel(t.notes.plant),
                        PlantField(
                          areaId: _areaId!,
                          selectedId: _userPlantId,
                          onChanged: (id) =>
                              setState(() => _userPlantId = id),
                          onAdd: _addPlant,
                        ),
                      ],
                      const SizedBox(height: 16),
                      _InfoHint(text: t.notes.info),
                      if (_isEdit) ...[
                        const SizedBox(height: 24),
                        DestructiveButton(
                          label: t.notes.delete,
                          onPressed: _delete,
                        ),
                      ],
                    ],
                  ),
                ),
                SaveBar(
                  onSave: _save,
                  isSaving: _isSaving,
                  label: t.notes.save,
                ),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _DateSegment extends StatelessWidget {
  const _DateSegment({
    required this.option,
    required this.customDate,
    required this.onChanged,
    required this.onPickDate,
  });

  final _DateOption option;
  final DateTime? customDate;
  final ValueChanged<_DateOption> onChanged;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final customLabel = customDate != null && option == _DateOption.custom
        ? formatDmy(customDate!)
        : t.notes.pick_date;

    return SegmentedButton<_DateOption>(
      segments: [
        ButtonSegment(value: _DateOption.today, label: Text(t.notes.today)),
        ButtonSegment(
            value: _DateOption.yesterday, label: Text(t.notes.yesterday)),
        ButtonSegment(
          value: _DateOption.custom,
          label: Text(customLabel, overflow: TextOverflow.ellipsis),
        ),
      ],
      selected: {option},
      onSelectionChanged: (s) {
        final picked = s.first;
        if (picked == _DateOption.custom) {
          onPickDate();
        } else {
          onChanged(picked);
        }
      },
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
    );
  }
}

class _AreaField extends ConsumerWidget {
  const _AreaField({required this.selectedId, required this.onChanged});

  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final areas = ref.watch(areasMapProvider).asData?.value;

    if (areas == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (areas.isEmpty) {
      return Text(
        t.notes.no_areas,
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final area in areas.values)
          ChoiceChip(
            label: Text(area.name),
            selected: area.id == selectedId,
            onSelected: (sel) => onChanged(sel ? area.id : null),
          ),
      ],
    );
  }
}

class _InfoHint extends StatelessWidget {
  const _InfoHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall
          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}
