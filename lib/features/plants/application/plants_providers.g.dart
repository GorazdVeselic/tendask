// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plants_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userPlantsRepository)
final userPlantsRepositoryProvider = UserPlantsRepositoryProvider._();

final class UserPlantsRepositoryProvider
    extends
        $FunctionalProvider<
          UserPlantsRepository,
          UserPlantsRepository,
          UserPlantsRepository
        >
    with $Provider<UserPlantsRepository> {
  UserPlantsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPlantsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPlantsRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserPlantsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserPlantsRepository create(Ref ref) {
    return userPlantsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserPlantsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserPlantsRepository>(value),
    );
  }
}

String _$userPlantsRepositoryHash() =>
    r'ed4a3a51bd0275111947266d25267f838fc23e18';
