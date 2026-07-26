// Community aggregate reads for R6 (docs/m11/03 §R6, skupnost-agregacija.md
// §7.2/§7.4). The engine reads the same public activity_season rows the app
// reads, resolves the same one-level-at-a-time fallback and builds the CDF the
// same way — a number in a push that disagreed with the number on screen would
// be worse than no push.
//
// Two deliberate differences from the client:
//  * PAST SEASONS ONLY. The client may fall back to the running current year in
//    a flagged, censored mode (§7.6). A proactive claim ("most have already
//    started") cannot: a running curve trends to 100 % by construction, so it
//    would fire for everyone every year. No past season → no R6.
//  * The site cohort is not read. R6 has to name a subject, and '@site' blends
//    lawn, bed and private plants into one group with nothing to point at.

// deno-lint-ignore-file no-explicit-any

/** One resolved comparison group: the level that answered, its denominator and
 * the cumulative share by ISO week. */
export interface SeasonCdf {
  taskTypeId: string;
  cohort: string;
  resolution: string;
  pooledTotal: number;
  /** F(w) in §7.2 — share whose FIRST execution fell in ISO week ≤ w. */
  shareBy(week: number): number;
}

export interface AggBucket {
  resolution: string;
  key: string;
}

export const kIsoWeeksPerYear = 53;

/** The profile's aggregation buckets, finest → coarsest (§7.4). */
export function bucketsOf(profile: {
  h3_r7: string | null;
  h3_r6: string | null;
  h3_r5: string | null;
  climate_bucket: string | null;
}): AggBucket[] {
  return [
    { resolution: 'r7', key: profile.h3_r7 },
    { resolution: 'r6', key: profile.h3_r6 },
    { resolution: 'r5', key: profile.h3_r5 },
    { resolution: 'climate', key: profile.climate_bucket },
  ].filter((b): b is AggBucket => b.key != null);
}

export function cdfKey(taskTypeId: string, cohort: string): string {
  return taskTypeId + '|' + cohort;
}

/** Builds one CDF per (task type, cohort) from ONE bucket's activity_season
 * rows. Rows of the current or a later year are ignored (see header). Groups
 * with no completed season at all simply do not appear. */
export function buildSeasonCdfs(
  rows: {
    task_type_id?: unknown;
    plant_id?: unknown;
    year?: unknown;
    iso_week?: unknown;
    first_user_count?: unknown;
  }[],
  currentYear: number,
  resolution: string,
): Map<string, SeasonCdf> {
  const weekly = new Map<string, number[]>();
  for (const row of rows) {
    const taskTypeId = row.task_type_id;
    const cohort = row.plant_id;
    const year = Number(row.year);
    const week = Number(row.iso_week);
    const count = Number(row.first_user_count);
    // Tolerant parser: server nonsense is skipped, never thrown on.
    if (typeof taskTypeId !== 'string' || typeof cohort !== 'string') continue;
    if (!Number.isFinite(year) || year >= currentYear) continue;
    if (!Number.isFinite(week) || week < 1 || week > kIsoWeeksPerYear) continue;
    if (!Number.isFinite(count) || count <= 0) continue;
    const key = cdfKey(taskTypeId, cohort);
    let bins = weekly.get(key);
    if (!bins) {
      bins = new Array(kIsoWeeksPerYear).fill(0);
      weekly.set(key, bins);
    }
    bins[week - 1] += count;
  }

  const out = new Map<string, SeasonCdf>();
  for (const [key, bins] of weekly) {
    const total = bins.reduce((a, b) => a + b, 0);
    if (total <= 0) continue;
    const cdf: number[] = [];
    let running = 0;
    for (const c of bins) {
      running += c;
      cdf.push(running / total);
    }
    const [taskTypeId, cohort] = key.split('|');
    out.set(key, {
      taskTypeId,
      cohort,
      resolution,
      pooledTotal: total,
      shareBy: (week) => cdf[Math.min(Math.max(week, 1), kIsoWeeksPerYear) - 1],
    });
  }
  return out;
}

/** Merges per-level maps, finest first: the first level that clears [kPrivacy]
 * answers for a group and coarser levels never override it (§7.4 — always
 * exactly one level, never a blend). */
export function resolveSeasonCdfs(
  perBucket: Map<string, SeasonCdf>[],
  kPrivacy: number,
): Map<string, SeasonCdf> {
  const out = new Map<string, SeasonCdf>();
  for (const level of perBucket) {
    for (const [key, cdf] of level) {
      if (out.has(key)) continue;
      if (cdf.pooledTotal < kPrivacy) continue;
      out.set(key, cdf);
    }
  }
  return out;
}

/** Reads and resolves the season CDFs for [cohorts] × [taskTypeIds] across the
 * profile's buckets: ONE query per level, not one per group. [memo] is shared
 * across the batch so neighbours in the same cell pay for the slice once. */
export async function loadSeasonCdfs(
  db: any,
  buckets: AggBucket[],
  taskTypeIds: string[],
  cohorts: string[],
  currentYear: number,
  kPrivacy: number,
  memo: Map<string, Map<string, SeasonCdf>>,
): Promise<Map<string, SeasonCdf>> {
  if (buckets.length === 0 || taskTypeIds.length === 0 || cohorts.length === 0) {
    return new Map();
  }
  const types = [...taskTypeIds].sort();
  const groups = [...cohorts].sort();
  const perBucket: Map<string, SeasonCdf>[] = [];
  for (const bucket of buckets) {
    const memoKey = [bucket.resolution, bucket.key, types.join(','), groups.join(',')].join('|');
    let level = memo.get(memoKey);
    if (!level) {
      const res = await db
        .from('activity_season')
        .select('task_type_id,plant_id,year,iso_week,first_user_count')
        .eq('resolution', bucket.resolution)
        .eq('bucket_key', bucket.key)
        .in('task_type_id', types)
        .in('plant_id', groups);
      if (res.error) throw res.error;
      level = buildSeasonCdfs(res.data ?? [], currentYear, bucket.resolution);
      memo.set(memoKey, level);
    }
    perBucket.push(level);
  }
  return resolveSeasonCdfs(perBucket, kPrivacy);
}
