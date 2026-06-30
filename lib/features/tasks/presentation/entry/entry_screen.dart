import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_service.dart';
import '../../../../core/catalog_labels.dart';
import '../../../../core/config.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/catalog_provider.dart';
import '../../../../core/haptics.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/task_status.dart';
import '../../../../i18n/translations.g.dart';
import '../../../notifications/presentation/notification_priming_sheet.dart';
import '../../../settings/application/profile_providers.dart';
import '../../../supplies/application/supplies_providers.dart';
import '../../../supplies/data/supply_spec.dart';
import '../../application/tasks_providers.dart';
import '../../data/recurrence.dart';
import '../../data/tasks_repository.dart';
import 'steps/reminder_step.dart';
import 'steps/review_step.dart';
import 'steps/subject_step.dart';
import 'steps/supplies_step.dart';
import 'steps/type_step.dart';
import 'steps/when_step.dart';

/// Fixed page indices. The active set is a subset (conditional steps).
enum EntryStep { type, subject, when, reminder, supplies, review }

/// Single horizontal wizard that creates or edits a task. Replaces the old
/// Quick Log + Task Form (concept §7.16). Conditional steps: reminder shows
/// only when the task is waiting; supplies only for supply-consuming types.
class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({super.key, this.taskId, this.initialDate});

  /// Null = create; non-null = edit (opens on the review step, pre-filled).
  final String? taskId;

  /// Preselected date for create mode (e.g. tapping a day in the calendar).
  final DateTime? initialDate;

  @override
  ConsumerState<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends ConsumerState<EntryScreen> {
  // Edit opens on the review step; the controller must start there too, since
  // the PageView is first built only after loading finishes.
  late final _pageController = PageController(
    initialPage: widget.taskId != null ? EntryStep.review.index : 0,
  );
  String? _taskTypeId;
  final Set<String> _plantIds = {};
  final Set<String> _areaIds = {};
  final List<ReminderSpec> _reminders = [];
  final List<SupplySpec> _supplies = [];
  final _noteController = TextEditingController();
  late DateTime _date;
  late TaskStatus _status;
  bool _statusManual = false;
  Recurrence? _recurrence;
  bool _recurrenceValid = true;

  // T7: a planned task is seeded one default reminder, once. The sentinel sticks
  // even after the user removes it, so it never silently comes back.
  bool _didSeedReminder = false;

  EntryStep _step = EntryStep.type;
  bool _isLoading = false;
  bool _isSaving = false;

  bool get _isEdit => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? _nextFullHour(DateTime.now());
    _status = _statusFromDate(_date);
    if (_isEdit) {
      _isLoading = true;
      _step = EntryStep.review;
      Future.microtask(_loadTask);
    } else {
      Future.microtask(_maybeSeedReminder);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ── Derived state ─────────────────────────────────────────────────────────

  TaskType? get _selectedType {
    final id = _taskTypeId;
    if (id == null) return null;
    return ref.read(taskTypesMapProvider).asData?.value[id];
  }

  List<TaskSubjectSpec> get _subjects => [
    for (final id in _plantIds) TaskSubjectSpec.plant(id),
    for (final id in _areaIds) TaskSubjectSpec.area(id),
  ];

  /// Ordered fixed steps that are currently part of the flow.
  List<EntryStep> get _activeSteps {
    final consumes = _selectedType?.consumesSupplies ?? false;
    return [
      EntryStep.type,
      EntryStep.subject,
      EntryStep.when,
      if (_status == TaskStatus.waiting) EntryStep.reminder,
      // Supplies step gated off for now (kSuppliesEnabled).
      if (consumes && kSuppliesEnabled) EntryStep.supplies,
      EntryStep.review,
    ];
  }

  static DateTime _nextFullHour(DateTime now) =>
      DateTime(now.year, now.month, now.day, now.hour + 1);

  // Derived from the full date+time vs now: anything in the future is planned
  // (waiting), now/past is logged as done.
  TaskStatus _statusFromDate(DateTime d) =>
      d.isAfter(DateTime.now()) ? TaskStatus.waiting : TaskStatus.done;

  // ── Loading (edit) ────────────────────────────────────────────────────────

  Future<void> _loadTask() async {
    final repo = ref.read(tasksRepositoryProvider);
    final task = await repo.byId(widget.taskId!);
    final subjects = await repo.subjectsForTask(widget.taskId!);
    final reminders = await repo.remindersForTask(widget.taskId!);
    final supplies = await ref
        .read(suppliesRepositoryProvider)
        .suppliesForTask(widget.taskId!);
    if (!mounted) return;
    setState(() {
      if (task != null) {
        _taskTypeId = task.taskTypeId;
        _date = task.date.toLocal();
        _status = task.status;
        _statusManual = true; // stored status is authoritative
        _noteController.text = task.note ?? '';
        _recurrence = Recurrence.tryParse(task.recurrence);
      }
      _plantIds
        ..clear()
        ..addAll(subjects.map((s) => s.userPlantId).whereType<String>());
      _areaIds
        ..clear()
        ..addAll(subjects.map((s) => s.areaId).whereType<String>());
      _reminders
        ..clear()
        ..addAll(
          reminders.map(
            (r) => ReminderSpec(offsetMinutes: r.offset, time: r.reminderTime),
          ),
        );
      _supplies
        ..clear()
        ..addAll(
          supplies.map(
            (ts) => SupplySpec(supplyId: ts.supplyId, amount: ts.amount),
          ),
        );
      // Stored reminders are authoritative — never auto-seed in edit mode.
      _didSeedReminder = true;
      _isLoading = false;
    });
  }

  // ── Repeat last (FR-6) ──────────────────────────────────────────────────────

  /// Pre-fills type/subjects/supplies/note from a prior task and jumps straight
  /// to review. Date/status keep the "now" defaults; reminders are not copied
  /// (they are tied to a specific planned date).
  Future<void> _repeatLast(String taskId) async {
    final repo = ref.read(tasksRepositoryProvider);
    final task = await repo.byId(taskId);
    if (task == null) return;
    final subjects = await repo.subjectsForTask(taskId);
    final supplies = await ref
        .read(suppliesRepositoryProvider)
        .suppliesForTask(taskId);
    if (!mounted) return;
    setState(() {
      _taskTypeId = task.taskTypeId;
      _noteController.text = task.note ?? '';
      _plantIds
        ..clear()
        ..addAll(subjects.map((s) => s.userPlantId).whereType<String>());
      _areaIds
        ..clear()
        ..addAll(subjects.map((s) => s.areaId).whereType<String>());
      _supplies
        ..clear()
        ..addAll(
          supplies.map(
            (ts) => SupplySpec(supplyId: ts.supplyId, amount: ts.amount),
          ),
        );
    });
    unawaited(_maybeSeedReminder());
    _goTo(EntryStep.review);
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _goTo(EntryStep step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step.index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    final active = _activeSteps;
    final pos = active.indexOf(_step);
    if (pos >= 0 && pos < active.length - 1) _goTo(active[pos + 1]);
  }

  void _back() {
    final active = _activeSteps;
    final pos = active.indexOf(_step);
    if (pos > 0) {
      _goTo(active[pos - 1]);
    } else {
      context.pop();
    }
  }

  void _selectType(String id) {
    setState(() => _taskTypeId = id);
    _next();
  }

  // ── When step mutations ───────────────────────────────────────────────────

  void _setDate(DateTime date) {
    setState(() {
      _date = date;
      if (!_statusManual) _status = _statusFromDate(date);
    });
    unawaited(_maybeSeedReminder());
  }

  void _setStatus(TaskStatus status) {
    setState(() {
      _status = status;
      _statusManual = true;
    });
    unawaited(_maybeSeedReminder());
  }

  // ── Default reminder seed (T7) ────────────────────────────────────────────

  /// Seeds one default reminder for a planned task so the phone actually notifies
  /// the user. Runs once (tracked by [_didSeedReminder]); skips a done/logged
  /// task, one that already has reminders, or when task reminders are disabled.
  Future<void> _maybeSeedReminder() async {
    if (_didSeedReminder ||
        _status != TaskStatus.waiting ||
        _reminders.isNotEmpty) {
      return;
    }
    final userId = ref.read(authServiceProvider).userId;
    final settings = await ref
        .read(profileRepositoryProvider)
        .notificationSettings(userId);
    if (!mounted) return;
    // Re-check after the await: status/reminders may have changed meanwhile.
    if (_didSeedReminder ||
        _status != TaskStatus.waiting ||
        _reminders.isNotEmpty ||
        !settings.taskRemindersEnabled) {
      return;
    }
    setState(() {
      _reminders.add(
        defaultReminderSpec(
          offsetMinutes: settings.defaultReminderOffset,
          taskDateLocal: _date,
          nowLocal: DateTime.now(),
        ),
      );
      _didSeedReminder = true;
    });
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final t = context.t;
    final messenger = ScaffoldMessenger.of(context);
    if (_subjects.isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.entry.err_subject),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _goTo(EntryStep.subject);
      return;
    }

    // A planned task keeping a reminder needs OS permission to ever fire. Ask once
    // here (priming + request); save regardless of the answer (offline-first: the
    // task always saves, the reminder simply waits until permission is granted).
    final wantsReminders =
        _status == TaskStatus.waiting && _reminders.isNotEmpty;
    var notifBlocked = false;
    if (wantsReminders) {
      final notif = ref.read(notificationServiceProvider);
      notifBlocked =
          await requestNotificationPermission(context, notif) !=
          NotifPermission.granted;
      if (!mounted) return;
    }

    setState(() => _isSaving = true);
    try {
      final note = _noteController.text.trim();
      // Reminders and recurrence only make sense for a planned (waiting) task.
      final reminders = _status == TaskStatus.waiting
          ? _reminders
          : const <ReminderSpec>[];
      final recurrence = _status == TaskStatus.waiting ? _recurrence : null;
      final repo = ref.read(tasksRepositoryProvider);
      final String taskId;
      if (_isEdit) {
        await repo.updateTask(
          id: widget.taskId!,
          taskTypeId: _taskTypeId!,
          status: _status,
          date: _date,
          note: note.isEmpty ? null : note,
          subjects: _subjects,
          recurrence: recurrence?.encode(),
          reminders: reminders,
        );
        taskId = widget.taskId!;
      } else {
        taskId = await repo.create(
          userId: ref.read(authServiceProvider).userId,
          taskTypeId: _taskTypeId!,
          date: _date,
          status: _status,
          note: note.isEmpty ? null : note,
          subjects: _subjects,
          recurrence: recurrence?.encode(),
          reminders: reminders,
        );
      }
      await ref
          .read(suppliesRepositoryProvider)
          .syncForTask(
            taskId: taskId,
            specs: _supplies,
            isDone: _status == TaskStatus.done,
          );
      AppHaptics.saved();
      if (!mounted) return;
      if (notifBlocked) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(t.entry.rem_saved_notif_off),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: context.pop,
          ),
        ),
        body: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final active = _activeSteps;
    final pos = active.indexOf(_step);
    final isFirst = pos <= 0;
    final isReview = _step == EntryStep.review;
    final type = _selectedType;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(isFirst ? Icons.close : Icons.arrow_back),
          onPressed: _back,
        ),
        title: Text(
          isReview
              ? t.entry.title_review
              : type != null
              ? '${type.icon}  ${catalogLabel(type.labels)}'
              : t.entry.title_new,
        ),
        centerTitle: true,
        actions: [
          if (!isFirst)
            IconButton(icon: const Icon(Icons.close), onPressed: context.pop),
        ],
      ),
      body: Column(
        children: [
          _ProgressBar(count: active.length, current: pos < 0 ? 0 : pos),
          _StepTitle(step: _step, position: pos),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                TypeStepBody(
                  selected: _taskTypeId,
                  onSelect: _selectType,
                  onNoteTap: () => context.pushNamed('note-new'),
                  onRepeatLast: _isEdit ? null : _repeatLast,
                ),
                SubjectStepBody(
                  taskTypeId: _taskTypeId,
                  plantIds: _plantIds,
                  areaIds: _areaIds,
                  onTogglePlant: (id, sel) => setState(
                    () => sel ? _plantIds.add(id) : _plantIds.remove(id),
                  ),
                  onToggleArea: (id, sel) => setState(
                    () => sel ? _areaIds.add(id) : _areaIds.remove(id),
                  ),
                ),
                WhenStepBody(
                  date: _date,
                  status: _status,
                  recurrence: _recurrence,
                  onSetDate: _setDate,
                  onSetStatus: _setStatus,
                  onSetRecurrence: (r, valid) => setState(() {
                    _recurrence = r;
                    _recurrenceValid = valid;
                  }),
                ),
                ReminderStepBody(
                  reminders: _reminders,
                  taskDate: _date,
                  seededDefault: _didSeedReminder,
                  onAdd: (spec) => setState(() => _reminders.add(spec)),
                  onRemove: (i) => setState(() => _reminders.removeAt(i)),
                ),
                SuppliesStepBody(
                  supplies: _supplies,
                  onAdd: (spec) => setState(() => _supplies.add(spec)),
                  onRemove: (i) => setState(() => _supplies.removeAt(i)),
                ),
                ReviewStepBody(
                  taskTypeId: _taskTypeId,
                  subjects: _subjects,
                  date: _date,
                  status: _status,
                  recurrence: _status == TaskStatus.waiting ? _recurrence : null,
                  reminders: _reminders,
                  supplies: _supplies,
                  noteController: _noteController,
                  consumesSupplies:
                      kSuppliesEnabled && (type?.consumesSupplies ?? false),
                  onFix: _goTo,
                ),
              ],
            ),
          ),
          _BottomBar(
            isReview: isReview,
            isOptional:
                _step == EntryStep.reminder || _step == EntryStep.supplies,
            canContinue: switch (_step) {
              EntryStep.type => _taskTypeId != null,
              EntryStep.subject => _plantIds.isNotEmpty || _areaIds.isNotEmpty,
              // Block while a shown recurrence field is empty/invalid.
              EntryStep.when => _status != TaskStatus.waiting || _recurrenceValid,
              _ => true,
            },
            isSaving: _isSaving,
            onContinue: _next,
            onSave: _save,
          ),
        ],
      ),
    );
  }
}

// ─── Shell widgets ───────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Row(
        children: [
          for (var i = 0; i < count; i++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= current
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (i < count - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.step, required this.position});
  final EntryStep step;
  final int position;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final text = switch (step) {
      EntryStep.type =>
        '${t.entry.step} ${position + 1} · ${t.entry.type_title}',
      EntryStep.subject =>
        '${t.entry.step} ${position + 1} · ${t.entry.subject_title}',
      EntryStep.when =>
        '${t.entry.step} ${position + 1} · ${t.entry.when_title}',
      EntryStep.reminder =>
        '${t.entry.step} ${position + 1} · ${t.entry.reminder_title} ${t.entry.optional}',
      EntryStep.supplies =>
        '${t.entry.step} ${position + 1} · ${t.entry.supplies_title} ${t.entry.optional}',
      EntryStep.review => t.entry.review_title,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isReview,
    required this.isOptional,
    required this.canContinue,
    required this.isSaving,
    required this.onContinue,
    required this.onSave,
  });

  final bool isReview;
  final bool isOptional;
  final bool canContinue;
  final bool isSaving;
  final VoidCallback onContinue;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: isSaving || (!isReview && !canContinue)
                    ? null
                    : (isReview ? onSave : onContinue),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(isReview ? t.entry.save : t.entry.kContinue),
              ),
            ),
            if (isOptional)
              TextButton(onPressed: onContinue, child: Text(t.entry.skip)),
          ],
        ),
      ),
    );
  }
}
