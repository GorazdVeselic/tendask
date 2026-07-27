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
  final perYear = <int, int>{};
  for (final row in used) {
    final week = (row['iso_week'] as num?)?.toInt();
    final count = (row['first_user_count'] as num?)?.toInt();
    // Tolerant parser: a week outside 1..53 is server nonsense, not a crash.
    if (week == null || count == null) continue;
    if (week < 1 || week > kIsoWeeksPerYear) continue;
    weekly[week - 1] += count;
    final year = yearOf(row) ?? currentYear;
    perYear[year] = (perYear[year] ?? 0) + count;
  }

  final total = weekly.fold(0, (sum, c) => sum + c);
  if (total <= 0) return null;
  var running = 0;
  return SeasonCurve(
    bucket: bucket,
    // The shape pools every past season — more seasons, steadier curve.
    cdf: [for (final c in weekly) (running += c) / total],
    // The denominator must not: pooling counts the same gardener once per
    // season, so three seasons of the same twelve neighbours would read as 36
    // and cross the reliability bar. The busiest single season is the honest
    // lower bound on how many distinct people stand behind the curve.
    pooledTotal: perYear.values.reduce((a, b) => a > b ? a : b),
    censored: censored,
  );
}

/// Historic share that had already started by the end of ISO [week] — `F(w)` in
/// §7.2, used both for the "you" marker and for "by now, ~X % have started".
double seasonCdfForWeek(SeasonCurve curve, int week) =>
    curve.cdf[week.clamp(1, kIsoWeeksPerYear) - 1];

/// The Monday of ISO [week] in [year] — the inverse of [isoWeek]. The chart
/// labels its axis with real dates rather than month names, which would cost 36
/// translated strings for less precision on a weekly chart.
DateTime mondayOfIsoWeek(int year, int week) {
  // 4 January is by definition in ISO week 1, whatever weekday it lands on.
  final jan4 = DateTime(year, 1, 4);
  final mondayOfWeek1 = jan4.subtract(Duration(days: jan4.weekday - 1));
  return mondayOfWeek1.add(Duration(days: (week - 1) * 7));
}

/// The weeks carrying the middle half of the season (CDF 25 %..75 %) — "most
/// start between X and Y". Both bounds are ISO week numbers.
(int, int) seasonPeakWeeks(SeasonCurve curve) {
  var from = curve.cdf.indexWhere((c) => c >= 0.25);
  var to = curve.cdf.indexWhere((c) => c >= 0.75);
  if (from < 0) from = 0;
  if (to < from) to = from;
  return (from + 1, to + 1);
}

/// The slice of the season curve the detail chart draws: [density] holds the
/// share of gardeners whose FIRST completion fell in each week of the window,
/// starting at ISO week [firstWeek]. [myIndex] points at the reader's own week
/// inside [density], or is null when they have not started this season.
typedef SeasonWindow = ({int firstWeek, List<double> density, int? myIndex});

/// Per-week shares behind the cumulative [SeasonCurve.cdf] — the bars in the
/// wireframe are the density, while the headline percentage stays cumulative.
List<double> seasonDensity(SeasonCurve curve) => [
  for (var w = 0; w < curve.cdf.length; w++)
    w == 0 ? curve.cdf[0] : curve.cdf[w] - curve.cdf[w - 1],
];

/// Picks the window worth drawing (see [kCommunitySeasonWindowMinWeeks]): the
/// weeks carrying the season's mass, widened to the minimum width and always
/// containing [myWeek] — a marker outside the chart would be a lie by omission.
SeasonWindow seasonWindow(SeasonCurve curve, {int? myWeek}) {
  final density = seasonDensity(curve);
  var first = curve.cdf.indexWhere((c) => c > kCommunitySeasonWindowLowCdf);
  var last = curve.cdf.indexWhere((c) => c >= kCommunitySeasonWindowHighCdf);
  // An all-zero or degenerate curve cannot happen (pooledTotal > 0), but a
  // single-week season legitimately collapses to first == last.
  if (first < 0) first = 0;
  if (last < first) last = curve.cdf.length - 1;

  final me = myWeek == null ? null : myWeek.clamp(1, curve.cdf.length) - 1;
  if (me != null) {
    if (me < first) first = me;
    if (me > last) last = me;
  }
  // Grow symmetrically to the minimum width, then shift back inside the year.
  while (last - first + 1 < kCommunitySeasonWindowMinWeeks) {
    if (first > 0) first--;
    if (last - first + 1 < kCommunitySeasonWindowMinWeeks &&
        last < curve.cdf.length - 1) {
      last++;
    }
    if (first == 0 && last == curve.cdf.length - 1) break;
  }

  return (
    firstWeek: first + 1,
    density: density.sublist(first, last + 1),
    myIndex: me == null ? null : me - first,
  );
}

/// Where a first completion in ISO [week] sits on the curve, as a share in
/// 0..1: `F(w−1) + f(w)/2`. Mid-rank, not the inclusive `F(w)` — when a whole
/// neighbourhood starts in one week, `F(w) = 1.0` would place every one of them
/// in the last tercile, the first of them included.
double seasonRank(SeasonCurve curve, int week) {
  final w = week.clamp(1, kIsoWeeksPerYear);
  final before = w >= 2 ? curve.cdf[w - 2] : 0.0;
  return (before + curve.cdf[w - 1]) / 2;
}

int? _percentOf(SeasonCurve curve, double share) {
  if (curve.pooledTotal < kCommunityReliabilityMin) return null;
  return (share * 100 / kCommunityPercentStep).round() * kCommunityPercentStep;
}

/// Cumulative share rounded for display (§7.7) — "by that date ~X % had started".
/// null when the sample is too thin for a number and only [timingBand] may show.
int? seasonPercent(SeasonCurve curve, int week) =>
    _percentOf(curve, seasonCdfForWeek(curve, week));

/// The reader's own place in the field, rounded (§7.7). Separate from
/// [seasonPercent] because the two answer different questions: the cumulative
/// share is about a DATE, this is about a PERSON, and only the latter may be
/// worded as a rank.
int? seasonRankPercent(SeasonCurve curve, int week) =>
    _percentOf(curve, seasonRank(curve, week));

/// Descriptive band for a CDF value — the honest form below
/// [kCommunityReliabilityMin], where a percentage would fake precision (§7.7).
CommunityTiming timingBand(double cdf) {
  if (cdf < 1 / 3) return CommunityTiming.early;
  if (cdf < 2 / 3) return CommunityTiming.typical;
  return CommunityTiming.late;
}

/// The "Where you stand" list: every cohort I worked this season that [curves]
/// could actually place, most recently started first (this season's activity
/// reads top-down). A cohort with no curve is left out — no level had enough
/// gardeners, and a row that says nothing is worse than a shorter list (§7.4).
List<CommunityStanding> buildStandings(
  Map<(String, String), MySeason> mine,
  Map<(String, String), SeasonCurve> curves,
) {
  final placed = <(DateTime, CommunityStanding)>[];
  for (final entry in curves.entries) {
    final first = mine[entry.key]?.first;
    if (first == null) continue;
    final curve = entry.value;
    placed.add((
      first,
      CommunityStanding(
        taskTypeId: entry.key.$1,
        cohort: entry.key.$2,
        band: timingBand(seasonRank(curve, isoWeek(first.toLocal()))),
        scope: curve.bucket.resolution,
      ),
    ));
  }
  placed.sort((a, b) => b.$1.compareTo(a.$1));
  return [for (final row in placed) row.$2];
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
