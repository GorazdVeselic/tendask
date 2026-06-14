import { assertEquals } from 'jsr:@std/assert@1';
import { buildSignals } from './signals.ts';
import { r2, r3 } from './rules.ts';
import { kDefaultEngine, kDefaultFrost, kDefaultThresholds } from './config.ts';
import type {
  EngineConfig,
  PlantTaskRule,
  TaskRow,
  TaskSubjectRef,
  TaskTypeMeta,
  UserBundle,
} from './types.ts';

const kCfg: EngineConfig = {
  engine: kDefaultEngine,
  weatherThresholds: kDefaultThresholds,
  frostDefaults: kDefaultFrost,
};

// 12:00 UTC = 14:00 Europe/Ljubljana (CEST) → local today 2026-06-12.
const kNow = new Date('2026-06-12T12:00:00Z');

const kTaskTypes = new Map<string, TaskTypeMeta>([
  ['treat', { id: 'treat', default_cadence: 7, weather_sensitive: true, seasonal: true }],
  ['mow', { id: 'mow', default_cadence: 10, weather_sensitive: true, seasonal: true }],
  ['prune', { id: 'prune', default_cadence: null, weather_sensitive: false, seasonal: true }],
  ['water', { id: 'water', default_cadence: 7, weather_sensitive: true, seasonal: false }],
]);

const kPlant: TaskSubjectRef[] = [{ user_plant_id: 'p1', area_id: null }];

let seq = 0;
function done(taskTypeId: string, day: string, subjects = kPlant): TaskRow {
  return {
    id: 't' + (++seq),
    task_type_id: taskTypeId,
    date: day + 'T10:00:00Z',
    status: 'done',
    subjects,
    hasReminder: false,
    supplyIds: [],
  };
}

function bundle(tasks: TaskRow[], overrides: Partial<UserBundle> = {}): UserBundle {
  return {
    profile: {
      user_id: 'u1',
      h3_r7: '871f1d4a9ffffff',
      timezone: 'Europe/Ljubljana',
      lang: 'sl',
      climate_bucket: 'e1_t6',
      climate_profile: null,
      fcm_token: null,
      notification_settings: null,
    },
    areas: [],
    plants: [{
      id: 'p1',
      area_id: null,
      plant_id: 'tomato',
      custom_name: null,
      personal_alias: null,
      is_custom: false,
      category: 'vegetable',
    }],
    tasks,
    supplies: [],
    suggestionLog: [],
    activeSuggestions: [],
    ...overrides,
  };
}

// All-zero-precip hourly payload around local now → forecastDryHours ≥ 48 and
// recent rain 0 → R1 "dry window" holds (docs/m11/02 §A parser shape).
function dryPayload(): Record<string, unknown> {
  const n = 24 * 6; // 3 past days + today + 2 forecast days
  const start = Date.parse('2026-06-09T00:00:00Z'); // local-naive (timezone=auto)
  const time = Array.from(
    { length: n },
    (_, i) => new Date(start + i * 3_600_000).toISOString().slice(0, 13) + ':00',
  );
  const fill = (v: number) => Array.from({ length: n }, () => v);
  return {
    utc_offset_seconds: 7200,
    hourly: {
      time,
      precipitation: fill(0),
      temperature_2m: fill(15),
      wind_speed_10m: fill(5),
      soil_temperature_6cm: fill(12),
    },
    daily: {},
  };
}

function signalsOf(b: UserBundle, payload: unknown = null) {
  return buildSignals(b, kTaskTypes, payload, kCfg, kNow);
}

// ---------- R3 (cadence overdue) ----------

Deno.test('R3: 10 days overdue without weather scores 1.0 (below threshold)', () => {
  const b = bundle([done('treat', '2026-05-26')]); // 17 days ago, default cadence 7
  const c = r3(b, [], signalsOf(b), kTaskTypes, kCfg);
  assertEquals(c.length, 1);
  assertEquals(c[0].score, 1.0); // min(10*0.1, 2.0)
  assertEquals(c[0].messageParams.days_overdue, 10);
  assertEquals(c[0].messageParams.cadence_days, 7);
  assertEquals(c[0].suggestedDate, '2026-06-13');
  assertEquals(c[0].validUntil, '2026-06-17');
});

Deno.test('R3: a dry window adds the weather bonus (3.0)', () => {
  const b = bundle([done('treat', '2026-05-26')]);
  const c = r3(b, [], signalsOf(b, dryPayload()), kTaskTypes, kCfg);
  assertEquals(c.length, 1);
  assertEquals(c[0].score, 3.0); // 1.0 + score_weather_window 2.0
});

Deno.test('R3: mow gets the +1.0 boost past 4 days overdue', () => {
  const b = bundle([done('mow', '2026-05-23', [{ user_plant_id: null, area_id: 'a1' }])], {
    areas: [{ id: 'a1', name: 'Lawn', type: 'lawn', protected: false }],
  });
  const c = r3(b, [], signalsOf(b), kTaskTypes, kCfg); // 20 days ago, cadence 10 → overdue 10
  assertEquals(c.length, 1);
  assertEquals(c[0].score, 2.0); // min(1.0,2.0)=1.0 + mow_boost 1.0
  assertEquals(c[0].areaId, 'a1');
});

Deno.test('R3: a protected subject gets no dry-window bonus (stays 1.0)', () => {
  const b = bundle([done('treat', '2026-05-26')], {
    areas: [{ id: 'g1', name: 'Greenhouse', type: 'bed', protected: true }],
    plants: [{
      id: 'p1',
      area_id: 'g1',
      plant_id: 'tomato',
      custom_name: null,
      personal_alias: null,
      is_custom: false,
      category: 'vegetable',
    }],
  });
  const c = r3(b, [], signalsOf(b, dryPayload()), kTaskTypes, kCfg);
  assertEquals(c.length, 1);
  assertEquals(c[0].score, 1.0); // dry window suppressed under cover
});

Deno.test('R3: not overdue until days > cadence × 1.25', () => {
  const b = bundle([done('treat', '2026-06-04')]); // 8 days ago, cadence 7 → 8 ≤ 8.75
  assertEquals(r3(b, [], signalsOf(b), kTaskTypes, kCfg).length, 0);
});

// ---------- R2 (anniversary) ----------

Deno.test('R2: anniversary alone scores 1.0 (stays below threshold)', () => {
  const b = bundle([done('prune', '2025-06-10')]); // ~today last year
  const c = r2(b, signalsOf(b), kTaskTypes, kCfg);
  assertEquals(c.length, 1);
  assertEquals(c[0].score, 1.0);
  assertEquals(c[0].messageParams.last_year_date, '2025-06-10');
  assertEquals(c[0].suggestedDate, '2026-06-13'); // max(tomorrow, this-year anniversary)
});

Deno.test('R2: skipped when already done this season', () => {
  const b = bundle([done('prune', '2025-06-10'), done('prune', '2026-03-01')]);
  assertEquals(r2(b, signalsOf(b), kTaskTypes, kCfg).length, 0);
});

Deno.test('R2: non-seasonal type is never anniversaried', () => {
  const b = bundle([done('water', '2025-06-10')]);
  assertEquals(r2(b, signalsOf(b), kTaskTypes, kCfg).length, 0);
});

Deno.test('R2: dry window on a weather-sensitive seasonal type lifts it to 3.0', () => {
  const b = bundle([done('treat', '2025-06-10')]);
  const c = r2(b, signalsOf(b, dryPayload()), kTaskTypes, kCfg);
  assertEquals(c.length, 1);
  assertEquals(c[0].score, 3.0); // anniversary 1.0 + dry window 2.0
});

// ---------- R1 (weather window, inline reinforcement) ----------

function windyDryPayload(): Record<string, unknown> {
  const p = dryPayload();
  // deno-lint-ignore no-explicit-any
  (p.hourly as any).wind_speed_10m = Array.from({ length: 24 * 6 }, () => 20);
  return p;
}

Deno.test('R1: a dry window stamps the dry_window param on the source candidate', () => {
  const b = bundle([done('treat', '2026-05-26')]);
  const c = r3(b, [], signalsOf(b, dryPayload()), kTaskTypes, kCfg);
  assertEquals(c[0].messageKey, 'suggestions.cadence.overdue'); // keeps source key
  assertEquals(c[0].messageParams.dry_window, true);
  assertEquals(c[0].messageParams.dry_hours, 48);
});

Deno.test('R1: treat loses the dry bonus when wind ≥ 15 (spray drift)', () => {
  const b = bundle([done('treat', '2026-05-26')]);
  const c = r3(b, [], signalsOf(b, windyDryPayload()), kTaskTypes, kCfg);
  assertEquals(c[0].score, 1.0); // overdue only; windy → no spray window
  assertEquals('dry_window' in c[0].messageParams, false);
});

// ---------- R3 cadence_only season gate + weather_guard ----------

const kLawnSubj: TaskSubjectRef[] = [{ user_plant_id: null, area_id: 'a1' }];

function lawnBundle(tasks: TaskRow[]): UserBundle {
  return bundle(tasks, { areas: [{ id: 'a1', name: 'Lawn', type: 'lawn', protected: false }] });
}

const kMowRule: PlantTaskRule = {
  id: 'lawn.mow',
  scope: 'category',
  ref_id: 'lawn',
  task_type_id: 'mow',
  timing_anchor: 'cadence_only',
  window: {
    min_days_since_last: 5,
    max_days_since_last: 10,
    season_start_week: 12,
    season_end_week: 46,
  },
  frost_gate: false,
  weather_guard: 'dry12h',
  message_key: 'suggestions.lawn.mow_due',
};

Deno.test('R3: cadence rule in season carries its weather_guard', () => {
  const b = lawnBundle([done('mow', '2026-05-23', kLawnSubj)]); // 20 days, cadence 10
  const c = r3(b, [kMowRule], signalsOf(b), kTaskTypes, kCfg); // June → week 24 ∈ 12–46
  assertEquals(c.length, 1);
  assertEquals(c[0].weatherGuard, 'dry12h');
  assertEquals(c[0].areaId, 'a1');
});

Deno.test('R3: cadence rule out of its season is skipped', () => {
  const dec = new Date('2026-12-15T12:00:00Z'); // week 51 > 46
  const b = lawnBundle([done('mow', '2026-11-20', kLawnSubj)]); // overdue, but off-season
  const c = r3(b, [kMowRule], buildSignals(b, kTaskTypes, null, kCfg, dec), kTaskTypes, kCfg);
  assertEquals(c.length, 0);
});
