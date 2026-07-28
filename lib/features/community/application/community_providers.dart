import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../../core/auth/auth_service.dart';
import '../../../core/config.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/database/database_provider.dart';
import '../data/community_models.dart';
import '../data/community_remote_fetch.dart';
import '../data/community_repository.dart';
import '../data/community_stats.dart';

part 'community_providers.g.dart';

@Riverpod(keepAlive: true)
CommunityRepository communityRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  // Offline / no backend → stale-cache-only repository (fetch = null).
  if (kSupabaseUrl.isEmpty) return CommunityRepository(db, null);
  return CommunityRepository(db, supabaseAggFetch(Supabase.instance.client));
}

/// Whether the device may see the full community content. M11 ships a stub
/// (`kDevPlusStub`) so the tease can be built and tested; FR-20 swaps the body
/// for a signed licence token read from drift.
@riverpod
bool hasPlus(Ref ref) => kDevPlusStub;

/// The current profile's aggregation buckets, finest → coarsest. Re-resolves on
/// sign-in/out so the feed follows the account, and on a profile write so moving
/// the garden re-scopes it. Empty when no profile/cells yet.
///
/// keepAlive: every community read awaits this first, and an autoDispose stream
/// is torn down mid-flight before the awaiting provider ever sees a value.
@Riverpod(keepAlive: true)
Stream<List<Bucket>> communityBuckets(Ref ref) {
  ref.watch(authStateChangesProvider);
  final userId = ref.read(authServiceProvider).userId;
  return ref.watch(communityRepositoryProvider).watchBuckets(userId);
}

/// The landing "This week" feed for the resolved scope. null = not enough
/// gardeners yet (cold-start / below privacy threshold).
@riverpod
Future<CommunityFeed?> communityFeed(Ref ref) async {
  final buckets = await ref.watch(communityBucketsProvider.future);
  if (buckets.isEmpty) return null;
  return ref.watch(communityRepositoryProvider).feed(buckets: buckets);
}

/// Whether the device holds any slice for the current scope. Every empty state
/// asks this before saying "not enough gardeners nearby": with no slice the
/// emptiness describes the device, and claiming the neighbourhood is thin would
/// be a fact we never received.
@riverpod
Future<bool> communityReached(Ref ref) async {
  final buckets = await ref.watch(communityBucketsProvider.future);
  if (buckets.isEmpty) return false;
  return ref.watch(communityRepositoryProvider).hasCachedScope(buckets);
}

/// Season curve for a task type inside [cohort], resolved by widening the
/// geography only (r7 → r6 → r5 → climate). The cohort is fixed by the subject
/// and is NEVER swapped: pooling apple and raspberry pruning would answer a
/// question nobody asked (§7.4). Always exactly ONE level. null = no level
/// cleared the privacy threshold → "not enough gardeners yet for this".
@riverpod
Future<SeasonCurve?> communitySeasonCurve(
  Ref ref,
  String taskTypeId,
  String cohort,
) async {
  if (!await _isSeasonal(ref, taskTypeId)) return null;
  final buckets = await ref.watch(communityBucketsProvider.future);
  final repo = ref.watch(communityRepositoryProvider);
  for (final bucket in buckets) {
    final curve = await repo.seasonCurve(
      bucket: bucket,
      taskTypeId: taskTypeId,
      cohort: cohort,
    );
    if (curve != null && curve.pooledTotal >= kCommunityPrivacyMin) return curve;
  }
  return null;
}

/// Frequency stats for a task type inside [cohort], resolved like
/// [communitySeasonCurve]. null = no level cleared the privacy threshold.
@riverpod
Future<FrequencyStats?> communityFrequency(
  Ref ref,
  String taskTypeId,
  String cohort,
) async {
  final buckets = await ref.watch(communityBucketsProvider.future);
  final repo = ref.watch(communityRepositoryProvider);
  for (final bucket in buckets) {
    final stats = await repo.frequency(
      bucket: bucket,
      taskTypeId: taskTypeId,
      cohort: cohort,
    );
    if (stats != null && stats.nUsers >= kCommunityPrivacyMin) return stats;
  }
  return null;
}

/// The "this week" line for the task type inside [cohort], resolved like
/// [communitySeasonCurve]. Its scope can differ from the curve's — fewer
/// gardeners are active in any single week — so the UI labels it separately.
/// null = no level has this cohort in its 7-day slice.
@riverpod
Future<CommunityWeekly?> communityWeekly(
  Ref ref,
  String taskTypeId,
  String cohort,
) async {
  final buckets = await ref.watch(communityBucketsProvider.future);
  final repo = ref.watch(communityRepositoryProvider);
  for (final bucket in buckets) {
    final weekly = await repo.recentActivity(
      bucket: bucket,
      taskTypeId: taskTypeId,
      cohort: cohort,
    );
    if (weekly != null) return weekly;
  }
  return null;
}

/// My own record for the task type in [cohort] this season (drift only) — the
/// "you" marker on the season chart and the "you" bar on the frequency chart.
@riverpod
Stream<MySeason> mySeason(Ref ref, String taskTypeId, String cohort) {
  ref.watch(authStateChangesProvider);
  return ref
      .watch(communityRepositoryProvider)
      .watchMySeason(taskTypeId, cohort: cohort);
}

/// Every (task type, cohort) I completed this season (drift only).
///
/// keepAlive: [communityStandings] awaits this, and an autoDispose stream is
/// torn down mid-flight before the awaiting provider ever sees a value.
@Riverpod(keepAlive: true)
Stream<Map<(String, String), MySeason>> mySeasons(Ref ref) {
  ref.watch(authStateChangesProvider);
  return ref.watch(communityRepositoryProvider).watchMySeasons();
}

/// Why "Where you stand" has no rows. Only [thinNeighbourhood] is a claim about
/// other gardeners; making it when the gap is in my own history was measurably
/// false — 40 neighbours and three watered plants still read "not enough
/// gardeners nearby" (najdba N17).
enum StandingsGap {
  /// Nothing logged this season at all.
  noHistory,

  /// Logged work, but none of it seasonal. A timing percentile on watering
  /// would measure when the gardener joined, not how they garden (§7.5).
  noSeasonalHistory,

  /// Seasonal history exists; no cohort of mine cleared the privacy threshold.
  thinNeighbourhood,
}

/// The "Where you stand" list plus, when it is empty, which of the three causes
/// applies. Cohorts the neighbourhood cannot answer for are left out.
/// One request per resolution level, not one per cohort (§12.4).
@riverpod
Future<({List<CommunityStanding> rows, StandingsGap? gap})> communityStandings(
  Ref ref,
) async {
  final mine = await ref.watch(mySeasonsProvider.future);
  if (mine.isEmpty) {
    return (rows: const <CommunityStanding>[], gap: StandingsGap.noHistory);
  }
  final types = await ref.watch(taskTypesMapProvider.future);
  final pairs = [
    for (final pair in mine.keys)
      if (types[pair.$1]?.seasonal ?? false) pair,
  ];
  if (pairs.isEmpty) {
    return (
      rows: const <CommunityStanding>[],
      gap: StandingsGap.noSeasonalHistory,
    );
  }
  final buckets = await ref.watch(communityBucketsProvider.future);
  if (buckets.isEmpty) {
    return (
      rows: const <CommunityStanding>[],
      gap: StandingsGap.thinNeighbourhood,
    );
  }
  final curves = await ref
      .watch(communityRepositoryProvider)
      .seasonCurves(buckets: buckets, pairs: pairs);
  final rows = buildStandings(mine, curves);
  return (
    rows: rows,
    gap: rows.isEmpty ? StandingsGap.thinNeighbourhood : null,
  );
}

/// A time percentile only means something for a seasonal act (§7.5): "when in
/// the season did you first water this year" measures when the gardener joined,
/// not how they garden. The nightly cron stopped materializing these curves
/// (migration 0018); this keeps rows from an earlier run out of the UI too.
Future<bool> _isSeasonal(Ref ref, String taskTypeId) async {
  final types = await ref.watch(taskTypesMapProvider.future);
  return types[taskTypeId]?.seasonal ?? false;
}
