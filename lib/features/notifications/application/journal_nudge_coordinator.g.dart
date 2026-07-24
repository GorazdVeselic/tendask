// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_nudge_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps the local re-engagement journal nudge (FR-16) armed. Reschedules the
/// decaying chain once at startup, on every (debounced) task/note/profile write,
/// and on app resume — every such "touch" pushes the nudge forward, so an active
/// user never sees it. Lives for the whole session; call [start] after bootstrap.

@ProviderFor(JournalNudgeCoordinator)
final journalNudgeCoordinatorProvider = JournalNudgeCoordinatorProvider._();

/// Keeps the local re-engagement journal nudge (FR-16) armed. Reschedules the
/// decaying chain once at startup, on every (debounced) task/note/profile write,
/// and on app resume — every such "touch" pushes the nudge forward, so an active
/// user never sees it. Lives for the whole session; call [start] after bootstrap.
final class JournalNudgeCoordinatorProvider
    extends $NotifierProvider<JournalNudgeCoordinator, void> {
  /// Keeps the local re-engagement journal nudge (FR-16) armed. Reschedules the
  /// decaying chain once at startup, on every (debounced) task/note/profile write,
  /// and on app resume — every such "touch" pushes the nudge forward, so an active
  /// user never sees it. Lives for the whole session; call [start] after bootstrap.
  JournalNudgeCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'journalNudgeCoordinatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$journalNudgeCoordinatorHash();

  @$internal
  @override
  JournalNudgeCoordinator create() => JournalNudgeCoordinator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$journalNudgeCoordinatorHash() =>
    r'3bdd42caf71c87b41ecbb14cb720a905564904a0';

/// Keeps the local re-engagement journal nudge (FR-16) armed. Reschedules the
/// decaying chain once at startup, on every (debounced) task/note/profile write,
/// and on app resume — every such "touch" pushes the nudge forward, so an active
/// user never sees it. Lives for the whole session; call [start] after bootstrap.

abstract class _$JournalNudgeCoordinator extends $Notifier<void> {
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
