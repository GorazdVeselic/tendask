// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'areas_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(areasRepository)
final areasRepositoryProvider = AreasRepositoryProvider._();

final class AreasRepositoryProvider
    extends
        $FunctionalProvider<AreasRepository, AreasRepository, AreasRepository>
    with $Provider<AreasRepository> {
  AreasRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'areasRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$areasRepositoryHash();

  @$internal
  @override
  $ProviderElement<AreasRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AreasRepository create(Ref ref) {
    return areasRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AreasRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AreasRepository>(value),
    );
  }
}

String _$areasRepositoryHash() => r'84bd14a4fdceb68441cf16289eb3e572f935add5';
