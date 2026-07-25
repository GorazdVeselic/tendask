import 'package:riverpod_annotation/riverpod_annotation.dart';
// hide Bucket: supabase's storage_client also exports a `Bucket` — ours wins.
import 'package:supabase_flutter/supabase_flutter.dart' hide Bucket;

import '../../../core/auth/auth_service.dart';
import '../../../core/config.dart';
import '../../../core/database/database_provider.dart';
import '../data/community_models.dart';
import '../data/community_repository.dart';

part 'community_providers.g.dart';

@Riverpod(keepAlive: true)
CommunityRepository communityRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  // Offline / no backend → stale-cache-only repository (fetch = null).
  if (kSupabaseUrl.isEmpty) return CommunityRepository(db, null);
  final client = Supabase.instance.client;
  return CommunityRepository(db, (table, filter) async {
    var query = client.from(table).select();
    for (final e in filter.entries) {
      query = query.eq(e.key, e.value);
    }
    final data = await query;
    return data.cast<Map<String, dynamic>>();
  });
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
