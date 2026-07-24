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
import '../../harvest.dart';
import '../../task_specs.dart';
import '../../yield_unit.dart';
import '../yield_sheet.dart';
import 'entry_defaults.dart';
import 'entry_flow.dart';
import 'entry_save_spec.dart';
import 'steps/reminder_step.dart';
import 'steps/review_step.dart';
import 'steps/subject_step.dart';
import 'steps/supplies_step.dart';
import 'steps/type_step.dart';
import 'steps/when_step.dart';
import 'widgets/entry_bottom_bar.dart';
import 'widgets/entry_progress_bar.dart';
import 'widgets/entry_step_title.dart';

/// Single horizontal wizard that creates or edits a task. Replaces the old
/// Quick Log + Task Form (concept §7.16). The step flow, the date/status
/// defaults and the rules for what gets persisted live in `entry_flow.dart`,
/// `entry_defaults.dart` and `entry_save_spec.dart` — this screen holds the
/// draft and wires it to the steps.
class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({
    super.key,
    this.taskId,
    this.initialDate,
    this.initialTaskTypeId,
    this.initialPlantId,
    this.initialAreaId,
  });

  /// Null = create; non-null = edit (opens on the review step, pre-filled).
  final String? taskId;

  /// Preselected date for create mode (calendar day tap, or a suggestion's
  /// suggested date when planning).
  final DateTime? initialDate;

  /// Pre-filled type/subject for create mode — set when planning a suggestion
  /// (concept §0.5): type + subject are already known, so the form opens on the
  /// "when" step for the user to pick the date and an optional reminder, then
  /// save. Null for a blank new task.
  final String? initialTaskTypeId;
  final String? initialPlantId;
  final String? initialAreaId;

  @override
  ConsumerState<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends ConsumerState<EntryScreen> {
  // Edit opens on the review step; the controller must start there too, since
  // the PageView is first built only after loading finishes.
  late final _pageController = PageController(
    initialPage: widget.taskId != null
        ? EntryStep.review.index
        : widget.initialTaskTypeId != null
        ? EntryStep.when.index
        : 0,
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
  // Harvest yield (T11), captured only when logging a done harvest in create.
  double? _yieldAmount;
  YieldUnit? _yieldUnit;

  // T7: a planned task is seeded one default reminder, once.
  bool _didSeedReminder = false;

  EntryStep _step = EntryStep.type;
  bool _isLoading = false;
  bool _isSaving = false;

  bool get _isEdit => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = widget.initialDate ?? nextFullHour(now);
    _status = statusFromDate(_date, now);
    if (_isEdit) {
      _isLoading = true;
      _step = EntryStep.review;
      Future.microtask(_loadTask);
    } else {
      if (widget.initialTaskTypeId != null) {
        // Prefilled create (calendar / planning a suggestion): type + subject
        // are known, so open on "when" for the user to pick the date + reminder.
        _taskTypeId = widget.initialTaskTypeId;
        if (widget.initialPlantId != null) {
          _plantIds.add(widget.initialPlantId!);
        }
        if (widget.initialAreaId != null) _areaIds.add(widget.initialAreaId!);
        _step = EntryStep.when;
      }
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

  List<EntryStep> get _activeSteps => activeSteps(
    status: _status,
    consumesSupplies: _selectedType?.consumesSupplies ?? false,
  );

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
      _fillSubjects(subjects);
      _fillSupplies(supplies);
      _reminders
        ..clear()
        ..addAll(
          reminders.map(
            (r) => ReminderSpec(offsetMinutes: r.offset, time: r.reminderTime),
          ),
        );
      // Stored reminders are authoritative — never auto-seed in edit mode.
      _didSeedReminder = true;
      _isLoading = false;
    });
  }

  void _fillSubjects(List<TaskSubject> subjects) {
    _plantIds
      ..clear()
      ..addAll(subjects.map((s) => s.userPlantId).whereType<String>());
    _areaIds
      ..clear()
      ..addAll(subjects.map((s) => s.areaId).whereType<String>());
  }

  void _fillSupplies(List<TaskSupply> supplies) {
    _supplies
      ..clear()
      ..addAll(
        supplies.map((ts) => SupplySpec(supplyId: ts.supplyId, amount: ts.amount)),
      );
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
      _fillSubjects(subjects);
      _fillSupplies(supplies);
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
    final step = nextStep(_step, _activeSteps);
    if (step != null) _goTo(step);
  }

  void _back() {
    final step = previousStep(_step, _activeSteps);
    if (step != null) {
      _goTo(step);
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
      if (!_statusManual) _status = statusFromDate(date, DateTime.now());
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

  /// Seeds one default reminder for a planned task so the phone actually
  /// notifies the user. Whether the user has reminders enabled is only known
  /// after the await, so the first check assumes they are.
  Future<void> _maybeSeedReminder() async {
    if (!_seedWanted(remindersEnabled: true)) return;

    final userId = ref.read(authServiceProvider).userId;
    final settings = await ref
        .read(profileRepositoryProvider)
        .notificationSettings(userId);
    if (!mounted) return;
    // Re-check after the await: status/reminders may have changed meanwhile.
    if (!_seedWanted(remindersEnabled: settings.taskRemindersEnabled)) return;

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

  bool _seedWanted({required bool remindersEnabled}) => shouldSeedReminder(
    didSeed: _didSeedReminder,
    status: _status,
    hasReminders: _reminders.isNotEmpty,
    remindersEnabled: remindersEnabled,
  );

  // ── Yield (harvest only) ──────────────────────────────────────────────────

  Future<void> _editYield() async {
    final initial = (_yieldAmount != null && _yieldUnit != null)
        ? YieldDraft(amount: _yieldAmount!, unit: _yieldUnit!)
        : null;
    final result = await showYieldSheet(
      context,
      initial: initial,
      allowRemove: initial != null,
    );
    if (!mounted || result == null) return;
    setState(() {
      switch (result) {
        case YieldSaved(:final draft):
          _yieldAmount = draft.amount;
          _yieldUnit = draft.unit;
        case YieldCleared():
          _yieldAmount = null;
          _yieldUnit = null;
      }
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

    // A planned task keeping a reminder needs OS permission to ever fire, so ask
    // for the same set as the manual "add reminder" flow (priming + notifications
    // + exact alarms). Without exact alarms the reminder can never fire, so — like
    // the manual flow — we stop and let the user enable it and tap Save again.
    // Notifications declined is non-fatal: the task still saves (offline-first),
    // with a quiet heads-up that reminders are off.
    final wantsReminders =
        _status == TaskStatus.waiting && _reminders.isNotEmpty;
    var notifBlocked = false;
    if (wantsReminders) {
      final notif = ref.read(notificationServiceProvider);
      final outcome = await requestReminderPermissions(context, notif);
      if (!mounted) return;
      switch (outcome) {
        case ReminderPermission.exactAlarmMissing:
          return;
        case ReminderPermission.primingDeclined:
        case ReminderPermission.notifDenied:
          notifBlocked = true;
        case ReminderPermission.granted:
          break;
      }
    }

    setState(() => _isSaving = true);
    try {
      final note = _noteController.text.trim();
      final spec = resolveSave(
        type: _selectedType,
        isEdit: _isEdit,
        status: _status,
        reminders: _reminders,
        recurrence: _recurrence,
        supplies: _supplies,
        yieldAmount: _yieldAmount,
        yieldUnit: _yieldUnit,
      );
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
          recurrence: spec.recurrence?.encode(),
          reminders: spec.reminders,
          typeRecordsYield: spec.typeRecordsYield,
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
          recurrence: spec.recurrence?.encode(),
          reminders: spec.reminders,
          yieldAmount: spec.yieldAmount,
          yieldUnit: spec.yieldUnit,
        );
      }
      await ref
          .read(suppliesRepositoryProvider)
          .syncForTask(
            taskId: taskId,
            specs: spec.supplies,
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
      // Return the task id so a planning caller (suggestion card) can link it.
      context.pop(taskId);
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
          EntryProgressBar(
            count: active.length - 1,
            current: pos < 0 ? 0 : pos,
          ),
          EntryStepTitle(step: _step, position: pos),
          Expanded(child: _pages(type)),
          EntryBottomBar(
            isReview: isReview,
            isOptional:
                _step == EntryStep.reminder || _step == EntryStep.supplies,
            canContinue: canLeaveStep(
              _step,
              taskTypeId: _taskTypeId,
              hasSubjects: _plantIds.isNotEmpty || _areaIds.isNotEmpty,
              status: _status,
              recurrenceValid: _recurrenceValid,
            ),
            isSaving: _isSaving,
            onContinue: _next,
            onSave: _save,
          ),
        ],
      ),
    );
  }

  Widget _pages(TaskType? type) => PageView(
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
        onTogglePlant: (id, sel) =>
            setState(() => sel ? _plantIds.add(id) : _plantIds.remove(id)),
        onToggleArea: (id, sel) =>
            setState(() => sel ? _areaIds.add(id) : _areaIds.remove(id)),
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
        showYield:
            !_isEdit && _status == TaskStatus.done && isHarvestType(type),
        yieldAmount: _yieldAmount,
        yieldUnit: _yieldUnit,
        onEditYield: _editYield,
      ),
    ],
  );
}
