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
/// sign-in/out so the feed follows the account. Empty when no profile/cells yet.
@riverpod
Future<List<Bucket>> communityBuckets(Ref ref) async {
  ref.watch(authStateChangesProvider);
  final db = ref.watch(databaseProvider);
  final userId = ref.read(authServiceProvider).userId;
  final profile =
      await (db.select(db.profiles)
        ..where((p) => p.userId.equals(userId))).getSingleOrNull();
  if (profile == null) return const [];
  return [
    if (profile.h3R7 != null)
      Bucket(resolution: CommunityResolution.r7, key: profile.h3R7!),
    if (profile.h3R6 != null)
      Bucket(resolution: CommunityResolution.r6, key: profile.h3R6!),
    if (profile.h3R5 != null)
      Bucket(resolution: CommunityResolution.r5, key: profile.h3R5!),
    if (profile.climateBucket != null)
      Bucket(resolution: CommunityResolution.climate, key: profile.climateBucket!),
  ];
}

/// The landing "This week" feed for the resolved scope. null = not enough
/// gardeners yet (cold-start / below privacy threshold).
@riverpod
Future<CommunityFeed?> communityFeed(Ref ref) async {
  final buckets = await ref.watch(communityBucketsProvider.future);
  if (buckets.isEmpty) return null;
  return ref.watch(communityRepositoryProvider).feed(buckets: buckets);
}
