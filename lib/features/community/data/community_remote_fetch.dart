// hide Bucket: supabase's storage_client also exports a `Bucket` — ours wins.
import 'package:supabase_flutter/supabase_flutter.dart' hide Bucket;

import '../../../core/config.dart';
import 'community_repository.dart';

/// Sort key per aggregate table: (column, ascending).
const _aggOrder = <String, (String, bool)>{
  'activity_recent': ('distinct_users_7d', false), // busiest cohorts first
  'activity_season': ('year', false), // newest seasons first
  'activity_frequency': ('season_year', false),
};

/// The live PostgREST reader behind [CommunityRepository]. Lives in data/ (the
/// repository owns the wire, not the providers) and takes the client as an
/// argument so the ordering and cap contract can be asserted against a real
/// request.
RemoteAggFetch supabaseAggFetch(SupabaseClient client) {
  return (table, filter) async {
    var query = client.from(table).select();
    for (final e in filter.entries) {
      final value = e.value;
      query = value is List
          ? query.inFilter(e.key, value)
          : query.eq(e.key, value);
    }
    // Order first, then cap: PostgREST cuts at max_rows regardless, so the only
    // choice is WHICH rows survive. Each table is ordered so the cut drops what
    // matters least; the repository still refuses a slice that hit the cap.
    final order = _aggOrder[table];
    final capped = order == null
        ? query.limit(kCommunityRowLimit)
        : query.order(order.$1, ascending: order.$2).limit(kCommunityRowLimit);
    final data = await capped;
    return data.cast<Map<String, dynamic>>();
  };
}

/// The reader the app runs with, or null when there is no backend configured
/// (tests, a build without `--dart-define` secrets) — the repository then serves
/// the stale cache only. Resolving the client here keeps `supabase_flutter` out
/// of the application layer, which must not know where rows come from.
RemoteAggFetch? liveAggFetch() =>
    kSupabaseUrl.isEmpty ? null : supabaseAggFetch(Supabase.instance.client);
