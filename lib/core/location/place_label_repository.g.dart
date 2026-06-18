// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_label_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(placeLabelRepository)
final placeLabelRepositoryProvider = PlaceLabelRepositoryProvider._();

final class PlaceLabelRepositoryProvider
    extends
        $FunctionalProvider<
          PlaceLabelRepository,
          PlaceLabelRepository,
          PlaceLabelRepository
        >
    with $Provider<PlaceLabelRepository> {
  PlaceLabelRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'placeLabelRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$placeLabelRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlaceLabelRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlaceLabelRepository create(Ref ref) {
    return placeLabelRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaceLabelRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaceLabelRepository>(value),
    );
  }
}

String _$placeLabelRepositoryHash() =>
    r'735441fb101a745486dc33a387bbf5649554effc';

/// The place name for the current garden cell in [language] (FR-12), or null
/// when no location is set, none resolved yet, or we are offline with no usable
/// last-known label. Reactive to the garden cell (re-resolves when it changes).
///
/// Order: a cache hit for the same cell+language needs no network; otherwise we
/// reverse-geocode the cell centroid and cache it. On a network failure (or a
/// response with no usable name) we fall back to the last-known label only when
/// it is for the same cell — so a moved garden never shows a stale, wrong place.

@ProviderFor(placeLabel)
final placeLabelProvider = PlaceLabelFamily._();

/// The place name for the current garden cell in [language] (FR-12), or null
/// when no location is set, none resolved yet, or we are offline with no usable
/// last-known label. Reactive to the garden cell (re-resolves when it changes).
///
/// Order: a cache hit for the same cell+language needs no network; otherwise we
/// reverse-geocode the cell centroid and cache it. On a network failure (or a
/// response with no usable name) we fall back to the last-known label only when
/// it is for the same cell — so a moved garden never shows a stale, wrong place.

final class PlaceLabelProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The place name for the current garden cell in [language] (FR-12), or null
  /// when no location is set, none resolved yet, or we are offline with no usable
  /// last-known label. Reactive to the garden cell (re-resolves when it changes).
  ///
  /// Order: a cache hit for the same cell+language needs no network; otherwise we
  /// reverse-geocode the cell centroid and cache it. On a network failure (or a
  /// response with no usable name) we fall back to the last-known label only when
  /// it is for the same cell — so a moved garden never shows a stale, wrong place.
  PlaceLabelProvider._({
    required PlaceLabelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'placeLabelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$placeLabelHash();

  @override
  String toString() {
    return r'placeLabelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return placeLabel(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlaceLabelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$placeLabelHash() => r'957fbf88deb9ad6b8a6c296a41e3ebeeb5775b3e';

/// The place name for the current garden cell in [language] (FR-12), or null
/// when no location is set, none resolved yet, or we are offline with no usable
/// last-known label. Reactive to the garden cell (re-resolves when it changes).
///
/// Order: a cache hit for the same cell+language needs no network; otherwise we
/// reverse-geocode the cell centroid and cache it. On a network failure (or a
/// response with no usable name) we fall back to the last-known label only when
/// it is for the same cell — so a moved garden never shows a stale, wrong place.

final class PlaceLabelFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  PlaceLabelFamily._()
    : super(
        retry: null,
        name: r'placeLabelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The place name for the current garden cell in [language] (FR-12), or null
  /// when no location is set, none resolved yet, or we are offline with no usable
  /// last-known label. Reactive to the garden cell (re-resolves when it changes).
  ///
  /// Order: a cache hit for the same cell+language needs no network; otherwise we
  /// reverse-geocode the cell centroid and cache it. On a network failure (or a
  /// response with no usable name) we fall back to the last-known label only when
  /// it is for the same cell — so a moved garden never shows a stale, wrong place.

  PlaceLabelProvider call(String language) =>
      PlaceLabelProvider._(argument: language, from: this);

  @override
  String toString() => r'placeLabelProvider';
}
