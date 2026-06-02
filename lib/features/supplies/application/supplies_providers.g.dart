// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplies_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(suppliesRepository)
final suppliesRepositoryProvider = SuppliesRepositoryProvider._();

final class SuppliesRepositoryProvider
    extends
        $FunctionalProvider<
          SuppliesRepository,
          SuppliesRepository,
          SuppliesRepository
        >
    with $Provider<SuppliesRepository> {
  SuppliesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suppliesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suppliesRepositoryHash();

  @$internal
  @override
  $ProviderElement<SuppliesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SuppliesRepository create(Ref ref) {
    return suppliesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SuppliesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SuppliesRepository>(value),
    );
  }
}

String _$suppliesRepositoryHash() =>
    r'b76528c8a676ad0474b2c6bc990a439b6b7f5c71';
