import '../../../../core/config.dart';
import '../../../../core/task_status.dart';

/// Fixed page indices of the entry wizard. The active set is a subset — the
/// reminder and supplies steps are conditional.
enum EntryStep { type, subject, when, reminder, supplies, review }

/// The steps currently part of the flow, in order. A reminder only makes sense
/// for a planned task; supplies only for a type that draws from stock.
List<EntryStep> activeSteps({
  required TaskStatus status,
  required bool consumesSupplies,
}) => [
  EntryStep.type,
  EntryStep.subject,
  EntryStep.when,
  if (status == TaskStatus.waiting) EntryStep.reminder,
  if (consumesSupplies && kSuppliesEnabled) EntryStep.supplies,
  EntryStep.review,
];

/// The step after [current], or null when it is the last one.
EntryStep? nextStep(EntryStep current, List<EntryStep> active) {
  final pos = active.indexOf(current);
  if (pos < 0 || pos == active.length - 1) return null;
  return active[pos + 1];
}

/// The step before [current], or null when it is the first one (back leaves the
/// wizard).
EntryStep? previousStep(EntryStep current, List<EntryStep> active) {
  final pos = active.indexOf(current);
  return pos > 0 ? active[pos - 1] : null;
}

/// Whether the "continue" button is enabled on [step]. The optional steps
/// (reminder, supplies) and review never block.
bool canLeaveStep(
  EntryStep step, {
  required String? taskTypeId,
  required bool hasSubjects,
  required TaskStatus status,
  required bool recurrenceValid,
}) => switch (step) {
  EntryStep.type => taskTypeId != null,
  EntryStep.subject => hasSubjects,
  // Block while a shown recurrence field is empty/invalid.
  EntryStep.when => status != TaskStatus.waiting || recurrenceValid,
  EntryStep.reminder || EntryStep.supplies || EntryStep.review => true,
};
