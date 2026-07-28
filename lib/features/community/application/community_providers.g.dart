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
    r'e350feb9bc3a3eb219c12bfcc15a6dcbedcd62eb';

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
/// sign-in/out so the feed follows the account, and on a profile write so moving
/// the garden re-scopes it. Empty when no profile/cells yet.
///
/// keepAlive: every community read awaits this first, and an autoDispose stream
/// is torn down mid-flight before the awaiting provider ever sees a value.

@ProviderFor(communityBuckets)
final communityBucketsProvider = CommunityBucketsProvider._();

/// The current profile's aggregation buckets, finest → coarsest. Re-resolves on
/// sign-in/out so the feed follows the account, and on a profile write so moving
/// the garden re-scopes it. Empty when no profile/cells yet.
///
/// keepAlive: every community read awaits this first, and an autoDispose stream
/// is torn down mid-flight before the awaiting provider ever sees a value.

final class CommunityBucketsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Bucket>>,
          List<Bucket>,
          Stream<List<Bucket>>
        >
    with $FutureModifier<List<Bucket>>, $StreamProvider<List<Bucket>> {
  /// The current profile's aggregation buckets, finest → coarsest. Re-resolves on
  /// sign-in/out so the feed follows the account, and on a profile write so moving
  /// the garden re-scopes it. Empty when no profile/cells yet.
  ///
  /// keepAlive: every community read awaits this first, and an autoDispose stream
  /// is torn down mid-flight before the awaiting provider ever sees a value.
  CommunityBucketsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'communityBucketsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$communityBucketsHash();

  @$internal
  @override
  $StreamProviderElement<List<Bucket>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Bucket>> create(Ref ref) {
    return communityBuckets(ref);
  }
}

String _$communityBucketsHash() => r'4066668f4472558d3b0199ff48763bffc54b9222';

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

/// Whether the device holds any slice for the current scope. Every empty state
/// asks this before saying "not enough gardeners nearby": with no slice the
/// emptiness describes the device, and claiming the neighbourhood is thin would
/// be a fact we never received.

@ProviderFor(communityReached)
final communityReachedProvider = CommunityReachedProvider._();

/// Whether the device holds any slice for the current scope. Every empty state
/// asks this before saying "not enough gardeners nearby": with no slice the
/// emptiness describes the device, and claiming the neighbourhood is thin would
/// be a fact we never received.

final class CommunityReachedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the device holds any slice for the current scope. Every empty state
  /// asks this before saying "not enough gardeners nearby": with no slice the
  /// emptiness describes the device, and claiming the neighbourhood is thin would
  /// be a fact we never received.
  CommunityReachedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'communityReachedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$communityReachedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return communityReached(ref);
  }
}

String _$communityReachedHash() => r'c0fab875bb31148242f6dc6d4450789aa24a2c96';

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
    r'7d743898672f54e4f2c4350a8f36b3de00a68163';

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

/// The "this week" line for the task type inside [cohort], resolved like
/// [communitySeasonCurve]. Its scope can differ from the curve's — fewer
/// gardeners are active in any single week — so the UI labels it separately.
/// null = no level has this cohort in its 7-day slice.

@ProviderFor(communityWeekly)
final communityWeeklyProvider = CommunityWeeklyFamily._();

/// The "this week" line for the task type inside [cohort], resolved like
/// [communitySeasonCurve]. Its scope can differ from the curve's — fewer
/// gardeners are active in any single week — so the UI labels it separately.
/// null = no level has this cohort in its 7-day slice.

final class CommunityWeeklyProvider
    extends
        $FunctionalProvider<
          AsyncValue<CommunityWeekly?>,
          CommunityWeekly?,
          FutureOr<CommunityWeekly?>
        >
    with $FutureModifier<CommunityWeekly?>, $FutureProvider<CommunityWeekly?> {
  /// The "this week" line for the task type inside [cohort], resolved like
  /// [communitySeasonCurve]. Its scope can differ from the curve's — fewer
  /// gardeners are active in any single week — so the UI labels it separately.
  /// null = no level has this cohort in its 7-day slice.
  CommunityWeeklyProvider._({
    required CommunityWeeklyFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'communityWeeklyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$communityWeeklyHash();

  @override
  String toString() {
    return r'communityWeeklyProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<CommunityWeekly?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CommunityWeekly?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return communityWeekly(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityWeeklyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$communityWeeklyHash() => r'85f6eb86f02c1fc4f008812ea44b84bbb91fc9f4';

/// The "this week" line for the task type inside [cohort], resolved like
/// [communitySeasonCurve]. Its scope can differ from the curve's — fewer
/// gardeners are active in any single week — so the UI labels it separately.
/// null = no level has this cohort in its 7-day slice.

final class CommunityWeeklyFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<CommunityWeekly?>,
          (String, String)
        > {
  CommunityWeeklyFamily._()
    : super(
        retry: null,
        name: r'communityWeeklyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The "this week" line for the task type inside [cohort], resolved like
  /// [communitySeasonCurve]. Its scope can differ from the curve's — fewer
  /// gardeners are active in any single week — so the UI labels it separately.
  /// null = no level has this cohort in its 7-day slice.

  CommunityWeeklyProvider call(String taskTypeId, String cohort) =>
      CommunityWeeklyProvider._(argument: (taskTypeId, cohort), from: this);

  @override
  String toString() => r'communityWeeklyProvider';
}

/// My own record for the task type in [cohort] this season (drift only) — the
/// "you" marker on the season chart and the "you" bar on the frequency chart.

@ProviderFor(mySeason)
final mySeasonProvider = MySeasonFamily._();

/// My own record for the task type in [cohort] this season (drift only) — the
/// "you" marker on the season chart and the "you" bar on the frequency chart.

final class MySeasonProvider
    extends
        $FunctionalProvider<AsyncValue<MySeason>, MySeason, Stream<MySeason>>
    with $FutureModifier<MySeason>, $StreamProvider<MySeason> {
  /// My own record for the task type in [cohort] this season (drift only) — the
  /// "you" marker on the season chart and the "you" bar on the frequency chart.
  MySeasonProvider._({
    required MySeasonFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'mySeasonProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mySeasonHash();

  @override
  String toString() {
    return r'mySeasonProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<MySeason> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<MySeason> create(Ref ref) {
    final argument = this.argument as (String, String);
    return mySeason(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is MySeasonProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mySeasonHash() => r'a63b62e00a5882360529e52518acc92a8985a71a';

/// My own record for the task type in [cohort] this season (drift only) — the
/// "you" marker on the season chart and the "you" bar on the frequency chart.

final class MySeasonFamily extends $Family
    with $FunctionalFamilyOverride<Stream<MySeason>, (String, String)> {
  MySeasonFamily._()
    : super(
        retry: null,
        name: r'mySeasonProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// My own record for the task type in [cohort] this season (drift only) — the
  /// "you" marker on the season chart and the "you" bar on the frequency chart.

  MySeasonProvider call(String taskTypeId, String cohort) =>
      MySeasonProvider._(argument: (taskTypeId, cohort), from: this);

  @override
  String toString() => r'mySeasonProvider';
}

/// Every (task type, cohort) I completed this season (drift only).
///
/// keepAlive: [communityStandings] awaits this, and an autoDispose stream is
/// torn down mid-flight before the awaiting provider ever sees a value.

@ProviderFor(mySeasons)
final mySeasonsProvider = MySeasonsProvider._();

/// Every (task type, cohort) I completed this season (drift only).
///
/// keepAlive: [communityStandings] awaits this, and an autoDispose stream is
/// torn down mid-flight before the awaiting provider ever sees a value.

final class MySeasonsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<(String, String), MySeason>>,
          Map<(String, String), MySeason>,
          Stream<Map<(String, String), MySeason>>
        >
    with
        $FutureModifier<Map<(String, String), MySeason>>,
        $StreamProvider<Map<(String, String), MySeason>> {
  /// Every (task type, cohort) I completed this season (drift only).
  ///
  /// keepAlive: [communityStandings] awaits this, and an autoDispose stream is
  /// torn down mid-flight before the awaiting provider ever sees a value.
  MySeasonsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mySeasonsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mySeasonsHash();

  @$internal
  @override
  $StreamProviderElement<Map<(String, String), MySeason>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<(String, String), MySeason>> create(Ref ref) {
    return mySeasons(ref);
  }
}

String _$mySeasonsHash() => r'066d6d2784fb97ed8a8217286f8b94652121c5f5';

/// The "Where you stand" list plus, when it is empty, which of the three causes
/// applies. Cohorts the neighbourhood cannot answer for are left out.
/// One request per resolution level, not one per cohort (§12.4).

@ProviderFor(communityStandings)
final communityStandingsProvider = CommunityStandingsProvider._();

/// The "Where you stand" list plus, when it is empty, which of the three causes
/// applies. Cohorts the neighbourhood cannot answer for are left out.
/// One request per resolution level, not one per cohort (§12.4).

final class CommunityStandingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<({StandingsGap? gap, List<CommunityStanding> rows})>,
          ({StandingsGap? gap, List<CommunityStanding> rows}),
          FutureOr<({StandingsGap? gap, List<CommunityStanding> rows})>
        >
    with
        $FutureModifier<({StandingsGap? gap, List<CommunityStanding> rows})>,
        $FutureProvider<({StandingsGap? gap, List<CommunityStanding> rows})> {
  /// The "Where you stand" list plus, when it is empty, which of the three causes
  /// applies. Cohorts the neighbourhood cannot answer for are left out.
  /// One request per resolution level, not one per cohort (§12.4).
  CommunityStandingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'communityStandingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$communityStandingsHash();

  @$internal
  @override
  $FutureProviderElement<({StandingsGap? gap, List<CommunityStanding> rows})>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<({StandingsGap? gap, List<CommunityStanding> rows})> create(
    Ref ref,
  ) {
    return communityStandings(ref);
  }
}

String _$communityStandingsHash() =>
    r'faf91b631e36d619548762a8996d22fe5af58e4f';
