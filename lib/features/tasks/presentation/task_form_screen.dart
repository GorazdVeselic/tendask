import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/task_status.dart';
import '../../../core/widgets/save_bar.dart';
import '../../../core/widgets/sheet_handle.dart';
import '../../../i18n/translations.g.dart';
import '../../areas/application/areas_providers.dart';
import '../application/tasks_providers.dart';
import 'widgets/task_type_tile.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key, this.taskId});

  /// Null = create mode; non-null = edit mode.
  final String? taskId;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  String? _taskTypeId;
  String? _areaId;
  TaskStatus _status = TaskStatus.waiting;
  DateTime _date = DateTime.now();
  final _noteController = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;

  bool get _isEdit => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _isLoading = true;
      Future.microtask(_loadTask);
    }
  }

  Future<void> _loadTask() async {
    final task =
        await ref.read(tasksRepositoryProvider).byId(widget.taskId!);
    if (!mounted) return;
    if (task != null) {
      setState(() {
        _taskTypeId = task.taskTypeId;
        _areaId = task.areaId;
        _status = task.status;
        _date = task.date.toLocal();
        _noteController.text = task.note ?? '';
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null && mounted) {
      setState(() {
        _date = DateTime(
            picked.year, picked.month, picked.day, _date.hour, _date.minute);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _date.hour, minute: _date.minute),
    );
    if (picked != null && mounted) {
      setState(() {
        _date = DateTime(
            _date.year, _date.month, _date.day, picked.hour, picked.minute);
      });
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _save() async {
    final t = context.t;
    if (_taskTypeId == null) {
      _showError(t.task_form.err_type);
      return;
    }
    if (_areaId == null) {
      _showError(t.task_form.err_area);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final note = _noteController.text.trim();
      final repo = ref.read(tasksRepositoryProvider);

      if (_isEdit) {
        await repo.updateTask(
          id: widget.taskId!,
          taskTypeId: _taskTypeId!,
          areaId: _areaId!,
          status: _status,
          date: _date,
          note: note.isEmpty ? null : note,
        );
      } else {
        await repo.create(
          // TODO(gorazd, 2026-12-01): replace with real auth.uid() in M7
          userId: 'local',
          areaId: _areaId!,
          taskTypeId: _taskTypeId!,
          date: _date,
          status: _status,
          note: note.isEmpty ? null : note,
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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.close), onPressed: context.pop),
          title: Text(t.task_form.title_edit),
        ),
        body: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final catalogAsync = ref.watch(taskTypesMapProvider);
    final areasAsync = ref.watch(areasMapProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: context.pop,
        ),
        title:
            Text(_isEdit ? t.task_form.title_edit : t.task_form.title_new),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: catalogAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
              error: (err, _) => const SizedBox.shrink(),
              data: (catalog) => areasAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (err, _) => const SizedBox.shrink(),
                data: (areas) => _FormBody(
                  catalog: catalog,
                  areas: areas,
                  taskTypeId: _taskTypeId,
                  areaId: _areaId,
                  status: _status,
                  date: _date,
                  noteController: _noteController,
                  t: t,
                  theme: theme,
                  onTaskTypeChanged: (id) =>
                      setState(() => _taskTypeId = id),
                  onAreaChanged: (id) => setState(() => _areaId = id),
                  onStatusChanged: (s) => setState(() => _status = s),
                  onPickDate: _pickDate,
                  onPickTime: _pickTime,
                ),
              ),
            ),
          ),
          SaveBar(
              onSave: _save,
              isSaving: _isSaving,
              label: t.task_form.save),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form body (extracted so rebuild is clean when state changes)
// ---------------------------------------------------------------------------

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.catalog,
    required this.areas,
    required this.taskTypeId,
    required this.areaId,
    required this.status,
    required this.date,
    required this.noteController,
    required this.t,
    required this.theme,
    required this.onTaskTypeChanged,
    required this.onAreaChanged,
    required this.onStatusChanged,
    required this.onPickDate,
    required this.onPickTime,
  });

  final Map<String, TaskType> catalog;
  final Map<String, Area> areas;
  final String? taskTypeId;
  final String? areaId;
  final TaskStatus status;
  final DateTime date;
  final TextEditingController noteController;
  final Translations t;
  final ThemeData theme;
  final ValueChanged<String> onTaskTypeChanged;
  final ValueChanged<String> onAreaChanged;
  final ValueChanged<TaskStatus> onStatusChanged;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    final selectedType = taskTypeId != null ? catalog[taskTypeId] : null;
    final requiresSubject = selectedType?.requiresSubject ?? false;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      children: [
        // Kaj
        _FieldLabel(t.task_form.what),
        _TypePickerField(
          selected: selectedType,
          hint: t.task_form.what_hint,
          catalog: catalog,
          theme: theme,
          onChanged: onTaskTypeChanged,
        ),
        const SizedBox(height: 16),

        // Kdaj
        _FieldLabel(t.task_form.when),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _TappableField(
                text: formatDmy(date),
                icon: Icons.calendar_today_outlined,
                onTap: onPickDate,
                theme: theme,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _TappableField(
                text: formatHm(date),
                icon: Icons.access_time_outlined,
                onTap: onPickTime,
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Status
        _FieldLabel(t.task_form.status),
        SegmentedButton<TaskStatus>(
          segments: [
            ButtonSegment(
                value: TaskStatus.waiting,
                label: Text(t.task_form.status_waiting)),
            ButtonSegment(
                value: TaskStatus.done, label: Text(t.task_form.status_done)),
          ],
          selected: {status},
          onSelectionChanged: (s) => onStatusChanged(s.first),
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
        ),
        const SizedBox(height: 16),

        // Območje
        _FieldLabel(t.task_form.area),
        if (areas.isEmpty)
          Text(t.task_form.no_areas,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant))
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final area in areas.values)
                ChoiceChip(
                  label: Text(area.name),
                  selected: area.id == areaId,
                  onSelected: (_) => onAreaChanged(area.id),
                ),
            ],
          ),
        const SizedBox(height: 16),

        // Rastlina (conditional)
        if (requiresSubject) ...[
          _FieldLabel('${t.task_form.plant} '
              '${t.task_form.plant_hint}'),
          Card(
            child: Column(
              children: [
                InkWell(
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
                        Text(t.task_form.plant_add,
                            style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Text(t.task_form.plant_note,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(height: 16),
        ],

        // Sredstva (placeholder)
        _FieldLabel(t.task_form.supplies),
        Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {}, // M3.3
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text('🧪',
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Text(t.task_form.supplies_add,
                      style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Opomnik (placeholder)
        _FieldLabel(t.task_form.reminders),
        Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {}, // M8
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text('🔔',
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Text(t.task_form.reminders_add,
                      style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Ponavljanje (placeholder — MVP = enkratno)
        _FieldLabel(t.task_form.recurrence),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(
                value: 'once',
                label: Text(t.task_form.recurrence_once)),
            ButtonSegment(
                value: 'weekly',
                label: Text(t.task_form.recurrence_weekly)),
            ButtonSegment(
                value: 'seasonal',
                label: Text(t.task_form.recurrence_seasonal)),
          ],
          selected: const {'once'}, // always once for MVP
          onSelectionChanged: (_) {},
          style: const ButtonStyle(
              visualDensity: VisualDensity.compact),
        ),
        const SizedBox(height: 16),

        // Opomba
        _FieldLabel(t.task_form.note),
        TextField(
          controller: noteController,
          decoration: InputDecoration(
            hintText: t.task_form.note_hint,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Task type picker field + bottom sheet
// ---------------------------------------------------------------------------

class _TypePickerField extends StatelessWidget {
  const _TypePickerField({
    required this.selected,
    required this.hint,
    required this.catalog,
    required this.theme,
    required this.onChanged,
  });

  final TaskType? selected;
  final String hint;
  final Map<String, TaskType> catalog;
  final ThemeData theme;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = selected != null
        ? '${selected!.icon}  ${catalogLabel(selected!.labels)}'
        : null;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _openPicker(context),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label ?? hint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: label != null
                      ? null
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down,
                color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (_, controller) => Column(
          children: [
            const SheetHandle(),
            const SizedBox(height: 4),
            Expanded(
              child: GridView.builder(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemCount: catalog.length,
                itemBuilder: (_, i) {
                  final type = catalog.values.elementAt(i);
                  return TaskTypeTile(
                    icon: type.icon,
                    label: catalogLabel(type.labels),
                    selected: type.id == selected?.id,
                    onTap: () {
                      onChanged(type.id);
                      Navigator.of(ctx).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

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

class _TappableField extends StatelessWidget {
  const _TappableField({
    required this.text,
    required this.icon,
    required this.onTap,
    required this.theme,
  });

  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(text, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

