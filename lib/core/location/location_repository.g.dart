// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the native H3 library once per session (FFI load is not free).

@ProviderFor(h3)
final h3Provider = H3Provider._();

/// Loads the native H3 library once per session (FFI load is not free).

final class H3Provider extends $FunctionalProvider<H3, H3, H3>
    with $Provider<H3> {
  /// Loads the native H3 library once per session (FFI load is not free).
  H3Provider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'h3Provider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$h3Hash();

  @$internal
  @override
  $ProviderElement<H3> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  H3 create(Ref ref) {
    return h3(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(H3 value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<H3>(value),
    );
  }
}

String _$h3Hash() => r'457ada9cf505b5160640999ed2c151ce1dbbf654';

@ProviderFor(locationRepository)
final locationRepositoryProvider = LocationRepositoryProvider._();

final class LocationRepositoryProvider
    extends
        $FunctionalProvider<
          LocationRepository,
          LocationRepository,
          LocationRepository
        >
    with $Provider<LocationRepository> {
  LocationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationRepositoryHash();

  @$internal
  @override
  $ProviderElement<LocationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocationRepository create(Ref ref) {
    return locationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationRepository>(value),
    );
  }
}

String _$locationRepositoryHash() =>
    r'4b6927e710ae6da1cb8731f58a227abde192fdb6';

/// The garden location for the weather lookup: the stored device-local
/// coordinates, or [kDefaultLatitude]/[kDefaultLongitude] until onboarding sets
/// one. Reactive — weather re-fetches when the user picks a location.

@ProviderFor(gardenLocation)
final gardenLocationProvider = GardenLocationProvider._();

/// The garden location for the weather lookup: the stored device-local
/// coordinates, or [kDefaultLatitude]/[kDefaultLongitude] until onboarding sets
/// one. Reactive — weather re-fetches when the user picks a location.

final class GardenLocationProvider
    extends
        $FunctionalProvider<
          AsyncValue<GardenCoords>,
          GardenCoords,
          Stream<GardenCoords>
        >
    with $FutureModifier<GardenCoords>, $StreamProvider<GardenCoords> {
  /// The garden location for the weather lookup: the stored device-local
  /// coordinates, or [kDefaultLatitude]/[kDefaultLongitude] until onboarding sets
  /// one. Reactive — weather re-fetches when the user picks a location.
  GardenLocationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gardenLocationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gardenLocationHash();

  @$internal
  @override
  $StreamProviderElement<GardenCoords> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<GardenCoords> create(Ref ref) {
    return gardenLocation(ref);
  }
}

String _$gardenLocationHash() => r'207ed7babddad27361e25e83c80fe72ce5d797a4';
