// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps OS-scheduled reminders in sync with the `task_reminder` rows. Reconciles
/// once at startup and on every (debounced) write to task/task_reminder. Lives
/// for the whole app session; call `start()` after the bootstrap (M8.2).

@ProviderFor(ReminderCoordinator)
final reminderCoordinatorProvider = ReminderCoordinatorProvider._();

/// Keeps OS-scheduled reminders in sync with the `task_reminder` rows. Reconciles
/// once at startup and on every (debounced) write to task/task_reminder. Lives
/// for the whole app session; call `start()` after the bootstrap (M8.2).
final class ReminderCoordinatorProvider
    extends $NotifierProvider<ReminderCoordinator, void> {
  /// Keeps OS-scheduled reminders in sync with the `task_reminder` rows. Reconciles
  /// once at startup and on every (debounced) write to task/task_reminder. Lives
  /// for the whole app session; call `start()` after the bootstrap (M8.2).
  ReminderCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderCoordinatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderCoordinatorHash();

  @$internal
  @override
  ReminderCoordinator create() => ReminderCoordinator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$reminderCoordinatorHash() =>
    r'24c941f2ec29f85914b515eac4dba5e9dc786f99';

/// Keeps OS-scheduled reminders in sync with the `task_reminder` rows. Reconciles
/// once at startup and on every (debounced) write to task/task_reminder. Lives
/// for the whole app session; call `start()` after the bootstrap (M8.2).

abstract class _$ReminderCoordinator extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
