// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(communityRepository)
final communityRepositoryProvider = CommunityRepositoryProvider._();

final class CommunityRepositoryProvider
    extends
        $FunctionalProvider<
          CommunityRepository,
          CommunityRepository,
          CommunityRepository
        >
    with $Provider<CommunityRepository> {
  CommunityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'communityRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$communityRepositoryHash();

  @$internal
  @override
  $ProviderElement<CommunityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CommunityRepository create(Ref ref) {
    return communityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommunityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommunityRepository>(value),
    );
  }
}

String _$communityRepositoryHash() =>
    r'fa3466b3576596194c4b1d351838282e59f5d335';

/// Whether the device may see the full community content. M11 ships a stub
/// (`kDevPlusStub`) so the tease can be built and tested; FR-20 swaps the body
/// for a signed licence token read from drift.

@ProviderFor(hasPlus)
final hasPlusProvider = HasPlusProvider._();

/// Whether the device may see the full community content. M11 ships a stub
/// (`kDevPlusStub`) so the tease can be built and tested; FR-20 swaps the body
/// for a signed licence token read from drift.

final class HasPlusProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the device may see the full community content. M11 ships a stub
  /// (`kDevPlusStub`) so the tease can be built and tested; FR-20 swaps the body
  /// for a signed licence token read from drift.
  HasPlusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasPlusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasPlusHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasPlus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasPlusHash() => r'72cdfaf78859094703aa21098a76e668db0f2fc0';

/// The current profile's aggregation buckets, finest → coarsest. Re-resolves on
/// sign-in/out so the feed follows the account. Empty when no profile/cells yet.

@ProviderFor(communityBuckets)
final communityBucketsProvider = CommunityBucketsProvider._();

/// The current profile's aggregation buckets, finest → coarsest. Re-resolves on
/// sign-in/out so the feed follows the account. Empty when no profile/cells yet.

final class CommunityBucketsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Bucket>>,
          List<Bucket>,
          FutureOr<List<Bucket>>
        >
    with $FutureModifier<List<Bucket>>, $FutureProvider<List<Bucket>> {
  /// The current profile's aggregation buckets, finest → coarsest. Re-resolves on
  /// sign-in/out so the feed follows the account. Empty when no profile/cells yet.
  CommunityBucketsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'communityBucketsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$communityBucketsHash();

  @$internal
  @override
  $FutureProviderElement<List<Bucket>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Bucket>> create(Ref ref) {
    return communityBuckets(ref);
  }
}

String _$communityBucketsHash() => r'ce99fde933627e559253d577ef3f73a05b9a7e5e';

/// The landing "This week" feed for the resolved scope. null = not enough
/// gardeners yet (cold-start / below privacy threshold).

@ProviderFor(communityFeed)
final communityFeedProvider = CommunityFeedProvider._();

/// The landing "This week" feed for the resolved scope. null = not enough
/// gardeners yet (cold-start / below privacy threshold).

final class CommunityFeedProvider
    extends
        $FunctionalProvider<
          AsyncValue<CommunityFeed?>,
          CommunityFeed?,
          FutureOr<CommunityFeed?>
        >
    with $FutureModifier<CommunityFeed?>, $FutureProvider<CommunityFeed?> {
  /// The landing "This week" feed for the resolved scope. null = not enough
  /// gardeners yet (cold-start / below privacy threshold).
  CommunityFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'communityFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$communityFeedHash();

  @$internal
  @override
  $FutureProviderElement<CommunityFeed?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CommunityFeed?> create(Ref ref) {
    return communityFeed(ref);
  }
}

String _$communityFeedHash() => r'4675b68c5fbcb2c79f3d2ac9758008ae2a91ec64';
