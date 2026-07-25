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

/// Season curve for a task type inside [cohort], resolved by widening the
/// geography only (r7 → r6 → r5 → climate). The cohort is fixed by the subject
/// and is NEVER swapped: pooling apple and raspberry pruning would answer a
/// question nobody asked (§7.4). Always exactly ONE level. null = no level
/// cleared the privacy threshold → "not enough gardeners yet for this".

@ProviderFor(communitySeasonCurve)
final communitySeasonCurveProvider = CommunitySeasonCurveFamily._();

/// Season curve for a task type inside [cohort], resolved by widening the
/// geography only (r7 → r6 → r5 → climate). The cohort is fixed by the subject
/// and is NEVER swapped: pooling apple and raspberry pruning would answer a
/// question nobody asked (§7.4). Always exactly ONE level. null = no level
/// cleared the privacy threshold → "not enough gardeners yet for this".

final class CommunitySeasonCurveProvider
    extends
        $FunctionalProvider<
          AsyncValue<SeasonCurve?>,
          SeasonCurve?,
          FutureOr<SeasonCurve?>
        >
    with $FutureModifier<SeasonCurve?>, $FutureProvider<SeasonCurve?> {
  /// Season curve for a task type inside [cohort], resolved by widening the
  /// geography only (r7 → r6 → r5 → climate). The cohort is fixed by the subject
  /// and is NEVER swapped: pooling apple and raspberry pruning would answer a
  /// question nobody asked (§7.4). Always exactly ONE level. null = no level
  /// cleared the privacy threshold → "not enough gardeners yet for this".
  CommunitySeasonCurveProvider._({
    required CommunitySeasonCurveFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'communitySeasonCurveProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$communitySeasonCurveHash();

  @override
  String toString() {
    return r'communitySeasonCurveProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<SeasonCurve?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SeasonCurve?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return communitySeasonCurve(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunitySeasonCurveProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$communitySeasonCurveHash() =>
    r'b4d4fe3389e9c837b1944b4e059a43141b390825';

/// Season curve for a task type inside [cohort], resolved by widening the
/// geography only (r7 → r6 → r5 → climate). The cohort is fixed by the subject
/// and is NEVER swapped: pooling apple and raspberry pruning would answer a
/// question nobody asked (§7.4). Always exactly ONE level. null = no level
/// cleared the privacy threshold → "not enough gardeners yet for this".

final class CommunitySeasonCurveFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SeasonCurve?>, (String, String)> {
  CommunitySeasonCurveFamily._()
    : super(
        retry: null,
        name: r'communitySeasonCurveProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Season curve for a task type inside [cohort], resolved by widening the
  /// geography only (r7 → r6 → r5 → climate). The cohort is fixed by the subject
  /// and is NEVER swapped: pooling apple and raspberry pruning would answer a
  /// question nobody asked (§7.4). Always exactly ONE level. null = no level
  /// cleared the privacy threshold → "not enough gardeners yet for this".

  CommunitySeasonCurveProvider call(String taskTypeId, String cohort) =>
      CommunitySeasonCurveProvider._(
        argument: (taskTypeId, cohort),
        from: this,
      );

  @override
  String toString() => r'communitySeasonCurveProvider';
}

/// Frequency stats for a task type inside [cohort], resolved like
/// [communitySeasonCurve]. null = no level cleared the privacy threshold.

@ProviderFor(communityFrequency)
final communityFrequencyProvider = CommunityFrequencyFamily._();

/// Frequency stats for a task type inside [cohort], resolved like
/// [communitySeasonCurve]. null = no level cleared the privacy threshold.

final class CommunityFrequencyProvider
    extends
        $FunctionalProvider<
          AsyncValue<FrequencyStats?>,
          FrequencyStats?,
          FutureOr<FrequencyStats?>
        >
    with $FutureModifier<FrequencyStats?>, $FutureProvider<FrequencyStats?> {
  /// Frequency stats for a task type inside [cohort], resolved like
  /// [communitySeasonCurve]. null = no level cleared the privacy threshold.
  CommunityFrequencyProvider._({
    required CommunityFrequencyFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'communityFrequencyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$communityFrequencyHash();

  @override
  String toString() {
    return r'communityFrequencyProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<FrequencyStats?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FrequencyStats?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return communityFrequency(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityFrequencyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$communityFrequencyHash() =>
    r'b3f848eeae46e850e50434aa44d903492342f334';

/// Frequency stats for a task type inside [cohort], resolved like
/// [communitySeasonCurve]. null = no level cleared the privacy threshold.

final class CommunityFrequencyFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<FrequencyStats?>, (String, String)> {
  CommunityFrequencyFamily._()
    : super(
        retry: null,
        name: r'communityFrequencyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Frequency stats for a task type inside [cohort], resolved like
  /// [communitySeasonCurve]. null = no level cleared the privacy threshold.

  CommunityFrequencyProvider call(String taskTypeId, String cohort) =>
      CommunityFrequencyProvider._(argument: (taskTypeId, cohort), from: this);

  @override
  String toString() => r'communityFrequencyProvider';
}

/// My own first completion of the task type in [cohort] this season (drift
/// only) — the "you" marker on the curve. null = not started yet this year.

@ProviderFor(myFirstThisSeason)
final myFirstThisSeasonProvider = MyFirstThisSeasonFamily._();

/// My own first completion of the task type in [cohort] this season (drift
/// only) — the "you" marker on the curve. null = not started yet this year.

final class MyFirstThisSeasonProvider
    extends
        $FunctionalProvider<
          AsyncValue<DateTime?>,
          DateTime?,
          FutureOr<DateTime?>
        >
    with $FutureModifier<DateTime?>, $FutureProvider<DateTime?> {
  /// My own first completion of the task type in [cohort] this season (drift
  /// only) — the "you" marker on the curve. null = not started yet this year.
  MyFirstThisSeasonProvider._({
    required MyFirstThisSeasonFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'myFirstThisSeasonProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myFirstThisSeasonHash();

  @override
  String toString() {
    return r'myFirstThisSeasonProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DateTime?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return myFirstThisSeason(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is MyFirstThisSeasonProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myFirstThisSeasonHash() => r'8c130f92fcf497b80fdf0b6d78f1324a86e917c8';

/// My own first completion of the task type in [cohort] this season (drift
/// only) — the "you" marker on the curve. null = not started yet this year.

final class MyFirstThisSeasonFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DateTime?>, (String, String)> {
  MyFirstThisSeasonFamily._()
    : super(
        retry: null,
        name: r'myFirstThisSeasonProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// My own first completion of the task type in [cohort] this season (drift
  /// only) — the "you" marker on the curve. null = not started yet this year.

  MyFirstThisSeasonProvider call(String taskTypeId, String cohort) =>
      MyFirstThisSeasonProvider._(argument: (taskTypeId, cohort), from: this);

  @override
  String toString() => r'myFirstThisSeasonProvider';
}
