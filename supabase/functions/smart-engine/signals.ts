// Signal layer (docs/m11/02 §B–F): one Signals object per user per run, built
// from the user bundle + cached weather payload. Pure — all inputs explicit
// (nowUtc injected) so every signal is unit-testable.

import type {
  ClimateSignals,
  EngineConfig,
  Profile,
  Supply,
  TaskRow,
  TaskSubjectRef,
  TaskTypeMeta,
  UserBundle,
  UserPlant,
  WeatherSignals,
} from './types.ts';
import { computeWeatherSignals } from './weather.ts';
import {
  addDaysStr,
  dayDiff,
  doyToDateStr,
  isoWeek,
  localDateStr,
  offsetDateStr,
  safeTimeZone,
  sameDateLastYear,
} from './dates.ts';

/** UTC instant → user-local calendar day. */
type DayFn = (utc: Date) => string;

export interface HistorySignals {
  lastDone(subjectKey: string, taskTypeId: string): string | null;
  lastDoneAnySubject(taskTypeId: string): string | null;
  cadenceDays(subjectKey: string, taskTypeId: string): number | null;
  chainStepDate(subjectKey: string, stepTypeId: string): string | null;
  lastDoneYearAgo(subjectKey: string, taskTypeId: string): string | null;
  debug(): unknown;
}

export interface InventorySignals {
  suppliesForTaskType(taskTypeId: string): Supply[];
  hasSupply(supplyId: string): boolean;
  debug(): unknown;
}

export interface EligibilitySignals {
  areasByType(type: string): { id: string; name: string }[];
  plantsByCategory(category: string): UserPlant[];
  plantsById(plantId: string): UserPlant[];
  protectedAreas: Set<string>;
  isProtectedSubject(subjectKey: string): boolean;
  debug(): unknown;
}

export interface StateSignals {
  planned(subjectKey: string, taskTypeId: string, withinDays: number): boolean;
  reminderExists(subjectKey: string, taskTypeId: string, withinDays: number): boolean;
  dismissed(guardKey: string, subjectKey: string): boolean;
  lastSuggestedAt(guardKey: string, subjectKey: string): string | null;
  activeSuggestion(taskTypeId: string, subjectKey: string): boolean;
  debug(): unknown;
}

export interface Signals {
  weather: WeatherSignals | null;
  climate: ClimateSignals;
  history: HistorySignals;
  inventory: InventorySignals;
  eligibility: EligibilitySignals;
  state: StateSignals;
  noLocation: boolean;
  localToday: string;
  timeZone: string;
}

export function subjectKeysOf(subjects: TaskSubjectRef[]): string[] {
  const keys: string[] = [];
  for (const s of subjects) {
    if (s.user_plant_id) keys.push('up:' + s.user_plant_id);
    if (s.area_id) keys.push('ar:' + s.area_id);
  }
  return keys;
}

export function buildSignals(
  bundle: UserBundle,
  taskTypes: Map<string, TaskTypeMeta>,
  weatherPayload: unknown,
  cfg: EngineConfig,
  nowUtc: Date,
): Signals {
  const tz = bundle.profile.timezone;
  const tzValid = tz != null && safeTimeZone(tz) === tz;
  const payloadOffset = typeof (weatherPayload as Record<string, unknown> | null)
      ?.utc_offset_seconds === 'number'
    ? (weatherPayload as { utc_offset_seconds: number }).utc_offset_seconds
    : null;
  // Day binning: profile timezone when valid; else the cell's UTC offset from
  // the weather payload (closer to the garden than plain UTC); else UTC.
  const dayOf: DayFn = tzValid
    ? (d) => localDateStr(d, tz)
    : (d) => offsetDateStr(d, payloadOffset ?? 0);
  const timeZone = tzValid ? tz : payloadOffset != null ? `offset:${payloadOffset}s` : 'UTC';
  const localToday = dayOf(nowUtc);
  return {
    weather: weatherPayload == null ? null : computeWeatherSignals(weatherPayload, nowUtc),
    climate: buildClimateSignals(bundle.profile, cfg, localToday),
    history: buildHistorySignals(bundle.tasks, taskTypes, dayOf, localToday),
    inventory: buildInventorySignals(bundle),
    eligibility: buildEligibilitySignals(bundle),
    state: buildStateSignals(bundle, dayOf, localToday, nowUtc),
    noLocation: bundle.profile.h3_r7 == null,
    localToday,
    timeZone,
  };
}

// ---------- B) climate ----------

export function buildClimateSignals(
  profile: Profile,
  cfg: EngineConfig,
  localToday: string,
): ClimateSignals {
  const cp = profile.climate_profile;
  const year = Number(localToday.slice(0, 4));
  const fromDefaults = cp == null;
  // Frost-free location (profile present, doy null) stays null on purpose:
  // frost_offset rules skip; only month_window regionalisation falls back (07 §7.3).
  const lastDoy = fromDefaults ? cfg.frostDefaults.last_frost_doy : cp.frost_last_spring_doy ?? null;
  const firstDoy = fromDefaults
    ? cfg.frostDefaults.first_frost_doy
    : cp.frost_first_autumn_doy ?? null;
  const safety = cfg.engine.frost_safety_days;
  const lastFrostDate = lastDoy == null ? null : addDaysStr(doyToDateStr(year, lastDoy), safety);
  const firstFrostDate = firstDoy == null
    ? null
    : addDaysStr(doyToDateStr(year, firstDoy), -safety);
  return {
    lastFrostDate,
    firstFrostDate,
    bucket: profile.climate_bucket,
    lastFrostWeek: lastFrostDate == null ? null : isoWeek(lastFrostDate),
    firstFrostWeek: firstFrostDate == null ? null : isoWeek(firstFrostDate),
    growingSeasonDays: cp?.growing_season_days ??
      (lastDoy != null && firstDoy != null ? firstDoy - lastDoy : null),
    hemisphereSouth: cp?.hemisphere === 'south',
    fromDefaults,
  };
}

// ---------- C) history ----------

function buildHistorySignals(
  tasks: TaskRow[],
  taskTypes: Map<string, TaskTypeMeta>,
  dayOf: DayFn,
  localToday: string,
): HistorySignals {
  const byPair = new Map<string, string[]>();
  const byType = new Map<string, string[]>();
  const push = (map: Map<string, string[]>, key: string, day: string) => {
    const arr = map.get(key);
    if (arr) arr.push(day);
    else map.set(key, [day]);
  };
  for (const t of tasks) {
    if (t.status !== 'done') continue;
    const day = dayOf(new Date(t.date));
    push(byType, t.task_type_id, day);
    for (const key of subjectKeysOf(t.subjects)) push(byPair, key + '|' + t.task_type_id, day);
  }
  for (const arr of byPair.values()) arr.sort();
  for (const arr of byType.values()) arr.sort();

  const year = localToday.slice(0, 4);
  const yearAgo = sameDateLastYear(localToday);
  const last = (arr: string[] | undefined): string | null =>
    arr != null && arr.length > 0 ? arr[arr.length - 1] : null;

  const lastDone = (subjectKey: string, taskTypeId: string) =>
    last(byPair.get(subjectKey + '|' + taskTypeId));
  const cadenceDays = (subjectKey: string, taskTypeId: string): number | null => {
    const dates = byPair.get(subjectKey + '|' + taskTypeId) ?? [];
    if (dates.length < 3) return taskTypes.get(taskTypeId)?.default_cadence ?? null;
    const recent = dates.slice(-5);
    const gaps = recent.slice(1).map((d, i) => dayDiff(d, recent[i])).sort((a, b) => a - b);
    const mid = Math.floor(gaps.length / 2);
    return gaps.length % 2 === 1 ? gaps[mid] : (gaps[mid - 1] + gaps[mid]) / 2;
  };
  const chainStepDate = (subjectKey: string, stepTypeId: string): string | null => {
    // Current season = local calendar year (north; south handled in M11.10).
    const dates = byPair.get(subjectKey + '|' + stepTypeId) ?? [];
    return last(dates.filter((d) => d.slice(0, 4) === year));
  };
  const lastDoneYearAgo = (subjectKey: string, taskTypeId: string): string | null => {
    const dates = byPair.get(subjectKey + '|' + taskTypeId) ?? [];
    return last(dates.filter((d) => Math.abs(dayDiff(d, yearAgo)) <= 7));
  };

  return {
    lastDone,
    lastDoneAnySubject: (taskTypeId) => last(byType.get(taskTypeId)),
    cadenceDays,
    chainStepDate,
    lastDoneYearAgo,
    debug: () =>
      [...byPair.entries()].map(([key, dates]) => {
        const sep = key.lastIndexOf('|');
        const subjectKey = key.slice(0, sep);
        const taskTypeId = key.slice(sep + 1);
        return {
          subject_key: subjectKey,
          task_type_id: taskTypeId,
          done_count: dates.length,
          last_done: last(dates),
          cadence_days: cadenceDays(subjectKey, taskTypeId),
          last_done_this_season: chainStepDate(subjectKey, taskTypeId),
          last_done_year_ago: lastDoneYearAgo(subjectKey, taskTypeId),
        };
      }),
  };
}

// ---------- D) inventory ----------

function buildInventorySignals(bundle: UserBundle): InventorySignals {
  const supplies = new Map(bundle.supplies.map((s) => [s.id, s]));
  const doneDesc = bundle.tasks
    .filter((t) => t.status === 'done')
    .sort((a, b) => Date.parse(b.date) - Date.parse(a.date));
  const suppliesForTaskType = (taskTypeId: string): Supply[] => {
    const lastFive = doneDesc.filter((t) => t.task_type_id === taskTypeId).slice(0, 5);
    const ids = new Set(lastFive.flatMap((t) => t.supplyIds));
    return [...ids]
      .map((id) => supplies.get(id))
      .filter((s): s is Supply => s != null);
  };
  const hasSupply = (supplyId: string): boolean => {
    const s = supplies.get(supplyId);
    return s != null && s.quantity > (s.low_threshold ?? 0);
  };
  return {
    suppliesForTaskType,
    hasSupply,
    debug: () =>
      bundle.supplies.map((s) => ({ id: s.id, name: s.name, has_supply: hasSupply(s.id) })),
  };
}

// ---------- E) eligibility ----------

function buildEligibilitySignals(bundle: UserBundle): EligibilitySignals {
  const protectedAreas = new Set(
    bundle.areas.filter((a) => a.protected).map((a) => a.id),
  );
  const plantsByUid = new Map(bundle.plants.map((p) => [p.id, p]));
  const isProtectedSubject = (subjectKey: string): boolean => {
    if (subjectKey.startsWith('ar:')) return protectedAreas.has(subjectKey.slice(3));
    if (subjectKey.startsWith('up:')) {
      const plant = plantsByUid.get(subjectKey.slice(3));
      return plant?.area_id != null && protectedAreas.has(plant.area_id);
    }
    return false;
  };
  return {
    areasByType: (type) => bundle.areas.filter((a) => a.type === type),
    // Custom plants are excluded — no canonical category (02 §E).
    plantsByCategory: (category) =>
      bundle.plants.filter((p) => !p.is_custom && p.category === category),
    plantsById: (plantId) => bundle.plants.filter((p) => p.plant_id === plantId),
    protectedAreas,
    isProtectedSubject,
    debug: () => ({
      areas: bundle.areas.map((a) => ({ id: a.id, type: a.type, protected: a.protected })),
      plants: bundle.plants.map((p) => ({
        id: p.id,
        plant_id: p.plant_id,
        category: p.category,
        is_custom: p.is_custom,
        protected: isProtectedSubject('up:' + p.id),
      })),
    }),
  };
}

// ---------- F) suggestion state ----------

function buildStateSignals(
  bundle: UserBundle,
  dayOf: DayFn,
  localToday: string,
  nowUtc: Date,
): StateSignals {
  const waiting = bundle.tasks
    .filter((t) => t.status === 'waiting')
    .map((t) => ({
      day: dayOf(new Date(t.date)),
      taskTypeId: t.task_type_id,
      keys: subjectKeysOf(t.subjects),
      hasReminder: t.hasReminder,
    }));
  const matches = (
    e: typeof waiting[number],
    subjectKey: string,
    taskTypeId: string,
    withinDays: number,
  ): boolean =>
    e.taskTypeId === taskTypeId && e.keys.includes(subjectKey) &&
    e.day >= localToday && e.day <= addDaysStr(localToday, withinDays);

  const logMap = new Map(
    bundle.suggestionLog.map((r) => [r.guard_key + '|' + r.subject_key, r]),
  );
  const dismissed = (guardKey: string, subjectKey: string): boolean => {
    const row = logMap.get(guardKey + '|' + subjectKey);
    if (row?.dismissed_until == null) return false;
    // Postgres timestamptz 'infinity' (dismiss forever) serialises as "infinity".
    if (row.dismissed_until === 'infinity') return true;
    return Date.parse(row.dismissed_until) > nowUtc.getTime();
  };

  return {
    planned: (subjectKey, taskTypeId, withinDays) =>
      waiting.some((e) => matches(e, subjectKey, taskTypeId, withinDays)),
    reminderExists: (subjectKey, taskTypeId, withinDays) =>
      waiting.some((e) => e.hasReminder && matches(e, subjectKey, taskTypeId, withinDays)),
    dismissed,
    lastSuggestedAt: (guardKey, subjectKey) =>
      logMap.get(guardKey + '|' + subjectKey)?.last_suggested_at ?? null,
    activeSuggestion: (taskTypeId, subjectKey) =>
      bundle.activeSuggestions.some((s) =>
        s.task_type_id === taskTypeId && s.subject_key === subjectKey &&
        s.valid_until >= localToday
      ),
    debug: () => ({
      waiting_tasks: waiting,
      suggestion_log: bundle.suggestionLog,
      active_suggestions: bundle.activeSuggestions,
    }),
  };
}
