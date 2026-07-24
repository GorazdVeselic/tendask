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

@ProviderFor(recipesRepository)
final recipesRepositoryProvider = RecipesRepositoryProvider._();

final class RecipesRepositoryProvider
    extends
        $FunctionalProvider<
          RecipesRepository,
          RecipesRepository,
          RecipesRepository
        >
    with $Provider<RecipesRepository> {
  RecipesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recipesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recipesRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecipesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecipesRepository create(Ref ref) {
    return recipesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecipesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecipesRepository>(value),
    );
  }
}

String _$recipesRepositoryHash() => r'4760f1e0745eee0f1e46a4b71bf50d5fa81dbe6e';
