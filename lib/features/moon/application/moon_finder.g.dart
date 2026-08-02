// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moon_finder.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs for the finder screen, memoized per (element, day, system): one call
/// walks [kMoonFinderHorizonDays] days through the engine (~0.19 ms per day,
/// measurement T1.11), too much to redo on every rebuild.

@ProviderFor(moonFinderRuns)
final moonFinderRunsProvider = MoonFinderRunsFamily._();

/// Runs for the finder screen, memoized per (element, day, system): one call
/// walks [kMoonFinderHorizonDays] days through the engine (~0.19 ms per day,
/// measurement T1.11), too much to redo on every rebuild.

final class MoonFinderRunsProvider
    extends
        $FunctionalProvider<
          List<MoonDayRun>,
          List<MoonDayRun>,
          List<MoonDayRun>
        >
    with $Provider<List<MoonDayRun>> {
  /// Runs for the finder screen, memoized per (element, day, system): one call
  /// walks [kMoonFinderHorizonDays] days through the engine (~0.19 ms per day,
  /// measurement T1.11), too much to redo on every rebuild.
  MoonFinderRunsProvider._({
    required MoonFinderRunsFamily super.from,
    required (BiodynamicElement, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'moonFinderRunsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$moonFinderRunsHash();

  @override
  String toString() {
    return r'moonFinderRunsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<MoonDayRun>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<MoonDayRun> create(Ref ref) {
    final argument = this.argument as (BiodynamicElement, DateTime);
    return moonFinderRuns(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MoonDayRun> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MoonDayRun>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MoonFinderRunsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$moonFinderRunsHash() => r'f416a8d6646d9c84d4f5d3c519ab29e21d068fb7';

/// Runs for the finder screen, memoized per (element, day, system): one call
/// walks [kMoonFinderHorizonDays] days through the engine (~0.19 ms per day,
/// measurement T1.11), too much to redo on every rebuild.

final class MoonFinderRunsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          List<MoonDayRun>,
          (BiodynamicElement, DateTime)
        > {
  MoonFinderRunsFamily._()
    : super(
        retry: null,
        name: r'moonFinderRunsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Runs for the finder screen, memoized per (element, day, system): one call
  /// walks [kMoonFinderHorizonDays] days through the engine (~0.19 ms per day,
  /// measurement T1.11), too much to redo on every rebuild.

  MoonFinderRunsProvider call(BiodynamicElement element, DateTime from) =>
      MoonFinderRunsProvider._(argument: (element, from), from: this);

  @override
  String toString() => r'moonFinderRunsProvider';
}
