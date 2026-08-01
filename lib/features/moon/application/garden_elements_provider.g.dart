// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garden_elements_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Elements covered by the user's garden (FR-19 ★ highlight): every
/// catalog-matched plant resolves via [plantElement]; custom plants carry no
/// recommendation. Empty while plants or the catalog are still loading, and
/// for an empty garden — the ★ layer then simply stays off.

@ProviderFor(gardenElements)
final gardenElementsProvider = GardenElementsProvider._();

/// Elements covered by the user's garden (FR-19 ★ highlight): every
/// catalog-matched plant resolves via [plantElement]; custom plants carry no
/// recommendation. Empty while plants or the catalog are still loading, and
/// for an empty garden — the ★ layer then simply stays off.

final class GardenElementsProvider
    extends
        $FunctionalProvider<
          Set<BiodynamicElement>,
          Set<BiodynamicElement>,
          Set<BiodynamicElement>
        >
    with $Provider<Set<BiodynamicElement>> {
  /// Elements covered by the user's garden (FR-19 ★ highlight): every
  /// catalog-matched plant resolves via [plantElement]; custom plants carry no
  /// recommendation. Empty while plants or the catalog are still loading, and
  /// for an empty garden — the ★ layer then simply stays off.
  GardenElementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gardenElementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gardenElementsHash();

  @$internal
  @override
  $ProviderElement<Set<BiodynamicElement>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Set<BiodynamicElement> create(Ref ref) {
    return gardenElements(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<BiodynamicElement> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<BiodynamicElement>>(value),
    );
  }
}

String _$gardenElementsHash() => r'15d789661060e9297d93928ec26859b9469c1085';
