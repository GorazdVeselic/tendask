// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'climate_refresh_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps `profile.timezone` + `climate_*` filled for whoever is signed in
/// (docs/m11/07 §7.5). Runs at start AND on every auth change.
///
/// Both halves matter, and both were missing (findings N14 + N1):
///
///  * it used to sit behind `kSuggestionsEnabled`, a define production does not
///    set — so on production it never ran at all, and *every* profile had a null
///    timezone. The binding was wrong on its own terms: the timezone also bins
///    `agg_event.local_day` for the community aggregates and picks the
///    `engine_dispatch` send window, neither of which is a suggestion;
///  * it ran once at boot with whatever user id existed then. Set the garden up
///    as a guest, sign in, and the refresh never ran for the new id.
///
/// A sign-in claims (or pulls) the profile row moments later, so this waits
/// briefly for the row before looking — otherwise it reads an empty table and
/// silently does nothing until the next cold start.

@ProviderFor(ClimateRefreshService)
final climateRefreshServiceProvider = ClimateRefreshServiceProvider._();

/// Keeps `profile.timezone` + `climate_*` filled for whoever is signed in
/// (docs/m11/07 §7.5). Runs at start AND on every auth change.
///
/// Both halves matter, and both were missing (findings N14 + N1):
///
///  * it used to sit behind `kSuggestionsEnabled`, a define production does not
///    set — so on production it never ran at all, and *every* profile had a null
///    timezone. The binding was wrong on its own terms: the timezone also bins
///    `agg_event.local_day` for the community aggregates and picks the
///    `engine_dispatch` send window, neither of which is a suggestion;
///  * it ran once at boot with whatever user id existed then. Set the garden up
///    as a guest, sign in, and the refresh never ran for the new id.
///
/// A sign-in claims (or pulls) the profile row moments later, so this waits
/// briefly for the row before looking — otherwise it reads an empty table and
/// silently does nothing until the next cold start.
final class ClimateRefreshServiceProvider
    extends $AsyncNotifierProvider<ClimateRefreshService, void> {
  /// Keeps `profile.timezone` + `climate_*` filled for whoever is signed in
  /// (docs/m11/07 §7.5). Runs at start AND on every auth change.
  ///
  /// Both halves matter, and both were missing (findings N14 + N1):
  ///
  ///  * it used to sit behind `kSuggestionsEnabled`, a define production does not
  ///    set — so on production it never ran at all, and *every* profile had a null
  ///    timezone. The binding was wrong on its own terms: the timezone also bins
  ///    `agg_event.local_day` for the community aggregates and picks the
  ///    `engine_dispatch` send window, neither of which is a suggestion;
  ///  * it ran once at boot with whatever user id existed then. Set the garden up
  ///    as a guest, sign in, and the refresh never ran for the new id.
  ///
  /// A sign-in claims (or pulls) the profile row moments later, so this waits
  /// briefly for the row before looking — otherwise it reads an empty table and
  /// silently does nothing until the next cold start.
  ClimateRefreshServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'climateRefreshServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$climateRefreshServiceHash();

  @$internal
  @override
  ClimateRefreshService create() => ClimateRefreshService();
}

String _$climateRefreshServiceHash() =>
    r'28070ab41ea11cbe8db8703d9cf5f444dd087d30';

/// Keeps `profile.timezone` + `climate_*` filled for whoever is signed in
/// (docs/m11/07 §7.5). Runs at start AND on every auth change.
///
/// Both halves matter, and both were missing (findings N14 + N1):
///
///  * it used to sit behind `kSuggestionsEnabled`, a define production does not
///    set — so on production it never ran at all, and *every* profile had a null
///    timezone. The binding was wrong on its own terms: the timezone also bins
///    `agg_event.local_day` for the community aggregates and picks the
///    `engine_dispatch` send window, neither of which is a suggestion;
///  * it ran once at boot with whatever user id existed then. Set the garden up
///    as a guest, sign in, and the refresh never ran for the new id.
///
/// A sign-in claims (or pulls) the profile row moments later, so this waits
/// briefly for the row before looking — otherwise it reads an empty table and
/// silently does nothing until the next cold start.

abstract class _$ClimateRefreshService extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
