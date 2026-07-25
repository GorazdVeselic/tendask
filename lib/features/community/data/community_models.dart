import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_models.freezed.dart';

/// Aggregation scope level, finest → coarsest. Mirrors the server `resolution`
/// enum in the aggregate tables (docs/m11/04 §4.4). There is intentionally no
/// 'global' bucket — the M11.16 cron only materializes r7/r6/r5/climate.
enum CommunityResolution { r7, r6, r5, climate }

/// A resolved aggregation bucket: a resolution level + its key (an H3 cell
/// string for r7/r6/r5, the coarse climate bucket, e.g. 'e1_t5', for climate).
@freezed
abstract class Bucket with _$Bucket {
  const factory Bucket({
    required CommunityResolution resolution,
    required String key,
  }) = _Bucket;
}

/// Qualitative feed intensity — a raw % over a 7-day window would mislead
/// (§7.8), so the "This week" feed stays qualitative.
enum CommunityIntensity { often, some, rare }

/// One row of the "This week" landing feed: a task type inside ONE comparison
/// cohort, and how busy that cohort has been over the sliding 7-day window.
@freezed
abstract class CommunityFeedItem with _$CommunityFeedItem {
  const factory CommunityFeedItem({
    required String taskTypeId,
    /// [kCommunityCohortSite] for site work, else the catalog plant id.
    required String cohort,
    required int distinctUsers7d,
    required CommunityIntensity intensity,
  }) = _CommunityFeedItem;
}

/// The landing "This week" feed for the resolved scope — the bucket that passed
/// the privacy threshold, the bucket population, and the ranked feed items.
@freezed
abstract class CommunityFeed with _$CommunityFeed {
  const factory CommunityFeed({
    required Bucket bucket,
    required int population,
    required List<CommunityFeedItem> items,
  }) = _CommunityFeed;
}

/// How busy ONE cohort has been over the sliding 7-day window, at the scope that
/// cleared the threshold — the "this week" line on the detail screen. Read from
/// the same daily feed slice, so it costs no extra request.
@freezed
abstract class CommunityWeekly with _$CommunityWeekly {
  const factory CommunityWeekly({
    required Bucket bucket,
    required int distinctUsers7d,
    required CommunityIntensity intensity,
  }) = _CommunityWeekly;
}

/// My own record for one task type in one cohort this season (drift only, never
/// leaves the device): [first] anchors the "you" marker on the season chart,
/// [count] the "you" bar on the frequency chart. Both come from one query.
@freezed
abstract class MySeason with _$MySeason {
  const factory MySeason({required DateTime? first, required int count}) =
      _MySeason;
}

/// Where a date falls against the season curve when a percentage would overstate
/// the precision (below `kCommunityReliabilityMin`, §7.7): the three terciles.
enum CommunityTiming { early, typical, late }

/// One row of "Where you stand": a cohort I worked this season, placed against
/// that group's curve. [scope] is the level that answered — it differs per row,
/// because each cohort widens its geography on its own (§7.4), so the row has to
/// carry it rather than the screen claiming one scope for the whole list.
@freezed
abstract class CommunityStanding with _$CommunityStanding {
  const factory CommunityStanding({
    required String taskTypeId,
    required String cohort,
    required CommunityTiming band,
    required CommunityResolution scope,
  }) = _CommunityStanding;
}

/// Historical seasonal CDF for one task type in one cohort: `cdf[w-1]` is the
/// cumulative fraction of gardeners whose first execution fell in ISO week ≤ w
/// (weeks 1..53), pooled over past complete seasons. Built on-device from ~53
/// `activity_season` rows; [pooledTotal] is the denominator (Σ season totals) —
/// a %/percentile is only shown when it clears [kCommunityReliabilityMin].
///
/// [censored] means no past season existed yet, so the curve is the *running*
/// current one (§7.6 year-1 mode): the share keeps moving as latecomers arrive,
/// so the UI must say "so far this year" and never present it as final.
@freezed
abstract class SeasonCurve with _$SeasonCurve {
  const factory SeasonCurve({
    required Bucket bucket,
    required List<double> cdf,
    required int pooledTotal,
    required bool censored,
  }) = _SeasonCurve;
}

/// Frequency stats for one task type at one scope (§7.3): the IQR of per-user
/// executions in the active season plus the distribution histogram for the bars.
/// The numeric range is only shown when [nUsers] clears [kCommunityReliabilityMin].
@freezed
abstract class FrequencyStats with _$FrequencyStats {
  const factory FrequencyStats({
    required Bucket bucket,
    required double p25,
    required double p50,
    required double p75,
    // e.g. 'per_season' / 'per_month' — the aggregate row's unit.
    required String unit,
    required int nUsers,
    // Distribution for the bars, e.g. {'1':4,'2':9,'3':12,'4':7,'5+':3}.
    required Map<String, int> hist,
  }) = _FrequencyStats;
}
