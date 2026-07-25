import '../../../core/config.dart';
import 'community_models.dart';

/// ISO 8601 week (1..53) of a **local** day, mirroring Postgres `extract(week
/// from ...)` so the on-device marker lands in the same bucket the nightly cron
/// counted. Computed in UTC so a DST jump cannot shift the day arithmetic.
///
/// Note the ISO quirk the server shares: 1 January can belong to week 52/53 of
/// the previous year, so a first completion on that day sits at the far end of
/// the curve. Garden seasons do not start on 1 January, and mirroring the server
/// matters more than smoothing this.
int isoWeek(DateTime localDay) {
  final day = DateTime.utc(localDay.year, localDay.month, localDay.day);
  // The Thursday of this ISO week decides which ISO year the week belongs to.
  final thursday = day.add(Duration(days: 4 - day.weekday));
  final jan1 = DateTime.utc(thursday.year, 1, 1);
  return 1 + thursday.difference(jan1).inDays ~/ 7;
}

/// Builds the season CDF from `activity_season` rows (§7.2). Percentages come
/// from **completed** past seasons only — mid-season the current year is still
/// censored (§8.1: you cannot know who has yet to start). With no past season
/// the curve falls back to the running current year, flagged
/// [SeasonCurve.censored] so the UI says "so far this year" (§7.6).
///
/// null = nothing to build from (RLS hid the group, or no completions yet).
SeasonCurve? buildSeasonCurve(
  List<Map<String, dynamic>> rows, {
  required Bucket bucket,
  required int currentYear,
}) {
  int? yearOf(Map<String, dynamic> row) => (row['year'] as num?)?.toInt();
  final past = rows.where((r) => (yearOf(r) ?? currentYear) < currentYear);
  final censored = past.isEmpty;
  final used = censored
      ? rows.where((r) => yearOf(r) == currentYear)
      : past;

  final weekly = List<int>.filled(kIsoWeeksPerYear, 0);
  for (final row in used) {
    final week = (row['iso_week'] as num?)?.toInt();
    final count = (row['first_user_count'] as num?)?.toInt();
    // Tolerant parser: a week outside 1..53 is server nonsense, not a crash.
    if (week == null || count == null) continue;
    if (week < 1 || week > kIsoWeeksPerYear) continue;
    weekly[week - 1] += count;
  }

  final total = weekly.fold(0, (sum, c) => sum + c);
  if (total <= 0) return null;
  var running = 0;
  return SeasonCurve(
    bucket: bucket,
    cdf: [for (final c in weekly) (running += c) / total],
    pooledTotal: total,
    censored: censored,
  );
}

/// Historic share that had already started by the end of ISO [week] — `F(w)` in
/// §7.2, used both for the "you" marker and for "by now, ~X % have started".
double seasonCdfForWeek(SeasonCurve curve, int week) =>
    curve.cdf[week.clamp(1, kIsoWeeksPerYear) - 1];

/// Descriptive band for a CDF value — the honest form below
/// [kCommunityReliabilityMin], where a percentage would fake precision (§7.7).
CommunityTiming timingBand(double cdf) {
  if (cdf < 1 / 3) return CommunityTiming.early;
  if (cdf < 2 / 3) return CommunityTiming.typical;
  return CommunityTiming.late;
}

/// Picks the frequency row for [seasonYear] (falling back to the most recent
/// season the server has published, e.g. before the first nightly refresh of a
/// new year) and parses it. null = nothing usable.
FrequencyStats? parseFrequency(
  List<Map<String, dynamic>> rows, {
  required Bucket bucket,
  required int seasonYear,
}) {
  Map<String, dynamic>? best;
  for (final row in rows) {
    final year = (row['season_year'] as num?)?.toInt();
    if (year == null) continue;
    if (year == seasonYear) {
      best = row;
      break;
    }
    if (best == null || year > (best['season_year'] as num).toInt()) best = row;
  }
  if (best == null) return null;

  final nUsers = (best['n_users'] as num?)?.toInt() ?? 0;
  final p50 = (best['per_user_p50'] as num?)?.toDouble();
  if (nUsers <= 0 || p50 == null) return null;

  final hist = <String, int>{};
  final rawHist = best['hist'];
  if (rawHist is Map) {
    rawHist.forEach((bucketLabel, count) {
      if (count is num) hist['$bucketLabel'] = count.toInt();
    });
  }

  return FrequencyStats(
    bucket: bucket,
    p25: (best['per_user_p25'] as num?)?.toDouble() ?? p50,
    p50: p50,
    p75: (best['per_user_p75'] as num?)?.toDouble() ?? p50,
    unit: (best['unit'] as String?) ?? 'per_season',
    nUsers: nUsers,
    hist: hist,
  );
}
