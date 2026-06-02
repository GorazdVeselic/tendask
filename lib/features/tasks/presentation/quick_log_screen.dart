import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/task_status.dart';
import '../../../core/widgets/save_bar.dart';
import '../../../i18n/translations.g.dart';
import '../../areas/application/areas_providers.dart';
import '../application/tasks_providers.dart';
import 'widgets/task_type_tile.dart';

enum _DateOption { today, yesterday, custom }

class QuickLogScreen extends ConsumerStatefulWidget {
  const QuickLogScreen({super.key});

  @override
  ConsumerState<QuickLogScreen> createState() => _QuickLogScreenState();
}

class _QuickLogScreenState extends ConsumerState<QuickLogScreen> {
  String? _taskTypeId;
  String? _areaId;
  _DateOption _dateOption = _DateOption.today;
  DateTime? _customDate;
  final _noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
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

  TaskStatus get _status {
    final today = startOfDay(DateTime.now());
    final day = startOfDay(_selectedDate);
    final isTodayOrPast = !day.isAfter(today);
    return isTodayOrPast ? TaskStatus.done : TaskStatus.waiting;
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

  Future<void> _save() async {
    final t = context.t;
    if (_taskTypeId == null) {
      _showError(t.quick_log.err_type);
      return;
    }
    if (_areaId == null) {
      _showError(t.quick_log.err_area);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final note = _noteController.text.trim();
      await ref.read(tasksRepositoryProvider).create(
            // TODO(gorazd, 2026-12-01): replace with real auth.uid() in M7
            userId: 'local',
            areaId: _areaId!,
            taskTypeId: _taskTypeId!,
            date: _selectedDate,
            status: _status,
            note: note.isEmpty ? null : note,
          );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  /// Opens the full form (07), carrying over whatever has been entered so far.
  /// Plant / supply / reminder all live there (07 covers M3.2/M3.3/M8).
  void _openAdvanced() {
    final params = <String, String>{'date': _selectedDate.toIso8601String()};
    if (_taskTypeId != null) params['type'] = _taskTypeId!;
    if (_areaId != null) params['area'] = _areaId!;
    final note = _noteController.text.trim();
    if (note.isNotEmpty) params['note'] = note;
    context.pushNamed('task-new', queryParameters: params);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final catalogAsync = ref.watch(taskTypesMapProvider);
    final areasAsync = ref.watch(areasMapProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: context.pop,
        ),
        title: Text(t.quick_log.title),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _openAdvanced,
            child: Text(
              t.quick_log.advanced,
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              children: [
                _NoteCard(
                  t: t,
                  onTap: () => context.pushNamed('note-new'),
                ),
                const SizedBox(height: 16),
                _SectionLabel(t.quick_log.what),
                catalogAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
                  error: (err, _) => const SizedBox.shrink(),
                  data: (catalog) => _TaskTypeGrid(
                    types: catalog.values.toList(),
                    selected: _taskTypeId,
                    onSelect: (id) => setState(() => _taskTypeId = id),
                  ),
                ),
                const SizedBox(height: 16),
                _SectionLabel(t.quick_log.when),
                _DateSegment(
                  option: _dateOption,
                  customDate: _customDate,
                  t: t,
                  onChanged: (opt) => setState(() => _dateOption = opt),
                  onPickDate: _pickDate,
                ),
                const SizedBox(height: 16),
                _SectionLabel(t.quick_log.where),
                areasAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (err, _) => const SizedBox.shrink(),
                  data: (areas) => areas.isEmpty
                      ? _EmptyAreas(t.quick_log.no_areas)
                      : _AreaChips(
                          areas: areas.values.toList(),
                          selected: _areaId,
                          onSelect: (id) => setState(() => _areaId = id),
                        ),
                ),
                const SizedBox(height: 16),
                _SectionLabel(t.quick_log.more),
                _MoreSection(t: t, onTap: _openAdvanced),
                const SizedBox(height: 16),
                _SectionLabel(t.quick_log.note_label),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: t.quick_log.note_hint,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          SaveBar(onSave: _save, isSaving: _isSaving, label: t.quick_log.save),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.t, required this.onTap});
  final Translations t;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Text('✍️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.quick_log.note_card_title,
                        style: theme.textTheme.bodyMedium),
                    Text(t.quick_log.note_card_sub,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Text(
                t.quick_log.note_card_action,
                style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 0.8,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _TaskTypeGrid extends StatelessWidget {
  const _TaskTypeGrid({
    required this.types,
    required this.selected,
    required this.onSelect,
  });

  final List<TaskType> types;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: types.length,
      itemBuilder: (context, i) {
        final type = types[i];
        return TaskTypeTile(
          icon: type.icon,
          label: catalogLabel(type.labels),
          selected: type.id == selected,
          onTap: () => onSelect(type.id),
        );
      },
    );
  }
}

class _DateSegment extends StatelessWidget {
  const _DateSegment({
    required this.option,
    required this.customDate,
    required this.t,
    required this.onChanged,
    required this.onPickDate,
  });

  final _DateOption option;
  final DateTime? customDate;
  final Translations t;
  final ValueChanged<_DateOption> onChanged;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final customLabel =
        customDate != null ? formatDmy(customDate!) : t.quick_log.pick_date;

    return SegmentedButton<_DateOption>(
      segments: [
        ButtonSegment(value: _DateOption.today, label: Text(t.quick_log.today)),
        ButtonSegment(
            value: _DateOption.yesterday, label: Text(t.quick_log.yesterday)),
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
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _AreaChips extends StatelessWidget {
  const _AreaChips({
    required this.areas,
    required this.selected,
    required this.onSelect,
  });

  final List<Area> areas;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final area in areas)
          ChoiceChip(
            label: Text(area.name),
            selected: area.id == selected,
            onSelected: (_) => onSelect(area.id),
          ),
      ],
    );
  }
}

class _EmptyAreas extends StatelessWidget {
  const _EmptyAreas(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

class _MoreSection extends StatelessWidget {
  const _MoreSection({required this.t, required this.onTap});
  final Translations t;

  /// All rows open the full form (07), which hosts plant/supply/reminder.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        children: [
          _AddRow(label: t.quick_log.add_plant, onTap: onTap),
          Divider(height: 1, indent: 16, color: theme.colorScheme.outlineVariant),
          _AddRow(label: t.quick_log.add_supply, onTap: onTap),
          Divider(height: 1, indent: 16, color: theme.colorScheme.outlineVariant),
          _AddRow(label: t.quick_log.add_reminder, onTap: onTap),
        ],
      ),
    );
  }
}

class _AddRow extends StatelessWidget {
  const _AddRow({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ),
    );
  }
}

