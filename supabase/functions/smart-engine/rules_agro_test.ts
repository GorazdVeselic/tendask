import { assertEquals } from 'jsr:@std/assert@1';
import { buildSignals } from './signals.ts';
import { r5, r7, resolveWindow } from './rules_agro.ts';
import { dedupAndRank } from './pipeline.ts';
import { kDefaultEngine, kDefaultFrost, kDefaultThresholds } from './config.ts';
import { addDaysStr, isoWeek, isoWeekMonday } from './dates.ts';
import type {
  ClimateSignals,
  EngineConfig,
  PlantTaskRule,
  TaskRow,
  TaskSubjectRef,
  TaskTypeMeta,
  UserBundle,
  UserPlant,
} from './types.ts';

const kCfg: EngineConfig = {
  engine: kDefaultEngine,
  weatherThresholds: kDefaultThresholds,
  frostDefaults: kDefaultFrost,
};

const kNow = new Date('2026-06-12T12:00:00Z'); // local today 2026-06-12 (CEST)

const kTaskTypes = new Map<string, TaskTypeMeta>([
  ['prune', { id: 'prune', default_cadence: null, weather_sensitive: false, seasonal: true }],
  ['fertilize', {
    id: 'fertilize',
    default_cadence: null,
    weather_sensitive: true,
    seasonal: true,
  }],
  ['prick_out', {
    id: 'prick_out',
    default_cadence: null,
    weather_sensitive: false,
    seasonal: true,
  }],
  ['transplant', {
    id: 'transplant',
    default_cadence: null,
    weather_sensitive: false,
    seasonal: true,
  }],
  ['start_seedlings', {
    id: 'start_seedlings',
    default_cadence: null,
    weather_sensitive: false,
    seasonal: true,
  }],
  ['harden_off', {
    id: 'harden_off',
    default_cadence: null,
    weather_sensitive: false,
    seasonal: true,
  }],
  ['protect', { id: 'protect', default_cadence: null, weather_sensitive: false, seasonal: true }],
]);

// ---------- factories ----------

function climate(overrides: Partial<ClimateSignals> = {}): ClimateSignals {
  return {
    lastFrostDate: '2026-04-06',
    firstFrostDate: '2026-11-07',
    bucket: 'e1_t6',
    lastFrostWeek: isoWeek('2026-04-06'),
    firstFrostWeek: isoWeek('2026-11-07'),
    growingSeasonDays: 215,
    hemisphereSouth: false,
    fromDefaults: false,
    ...overrides,
  };
}

function rule(o: Partial<PlantTaskRule> & { window: Record<string, unknown> }): PlantTaskRule {
  return {
    id: o.id ?? 'r.test',
    scope: o.scope ?? 'plant',
    ref_id: o.ref_id ?? 'apple',
    task_type_id: o.task_type_id ?? 'prune',
    timing_anchor: o.timing_anchor ?? 'month_window',
    window: o.window,
    frost_gate: o.frost_gate ?? false,
    weather_guard: o.weather_guard ?? null,
    message_key: o.message_key ?? 'suggestions.test',
  };
}

function plant(
  id: string,
  plantId: string,
  category: string,
  areaId: string | null = null,
): UserPlant {
  return {
    id,
    area_id: areaId,
    plant_id: plantId,
    custom_name: null,
    personal_alias: null,
    is_custom: false,
    category,
  };
}

let seq = 0;
function done(taskTypeId: string, day: string, subjects: TaskSubjectRef[]): TaskRow {
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

function bundle(over: Partial<UserBundle> = {}): UserBundle {
  return {
    profile: {
      user_id: 'u1',
      h3_r7: '871f1d4a9ffffff',
      timezone: 'Europe/Ljubljana',
      lang: 'sl',
      climate_bucket: 'e1_t6',
      // frost doy 89 → +7 safety = 2026-04-06; doy 311 → −7 = 2026-11-07.
      climate_profile: {
        frost_last_spring_doy: 89,
        frost_first_autumn_doy: 318,
        hemisphere: 'north',
      },
      fcm_token: null,
    },
    areas: [],
    plants: [],
    tasks: [],
    supplies: [],
    suggestionLog: [],
    activeSuggestions: [],
    ...over,
  };
}

function signalsOf(b: UserBundle, payload: unknown = null, now: Date = kNow) {
  return buildSignals(b, kTaskTypes, payload, kCfg, now);
}

// All-zero-precip payload around local now → dry window holds (mirrors rules_test).
function dryPayload(): Record<string, unknown> {
  const n = 24 * 6;
  const start = Date.parse('2026-06-09T00:00:00Z');
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

// ==================== resolveWindow (window math) ====================

Deno.test('R5 window: apple prune weeks 2–11 (regionalize none, no shift)', () => {
  const w = resolveWindow(
    rule({
      ref_id: 'apple',
      window: { start_week: 2, end_week: 11, regionalize: 'none', climate_bucket_filter: null },
    }),
    climate(),
    kCfg,
    2026,
  );
  assertEquals(w.start, '2026-01-05'); // Monday of ISO week 2
  assertEquals(w.end, '2026-03-15'); // Sunday of ISO week 11
});

Deno.test('R5 window: tomato sowing frost_offset −56..−42 around last frost', () => {
  const c = climate();
  const w = resolveWindow(
    rule({
      ref_id: 'tomato',
      task_type_id: 'start_seedlings',
      timing_anchor: 'frost_offset',
      window: { anchor: 'last_frost', offset_min_days: -56, offset_max_days: -42 },
    }),
    c,
    kCfg,
    2026,
  );
  assertEquals(w.start, addDaysStr(c.lastFrostDate!, -56));
  assertEquals(w.end, addDaysStr(c.lastFrostDate!, -42));
});

Deno.test('R5 window: spring Δ clamps to +4 weeks for a very late frost', () => {
  const w = resolveWindow(
    rule({
      window: { start_week: 14, end_week: 17, regionalize: 'spring', climate_bucket_filter: null },
    }),
    climate({ lastFrostWeek: 99 }), // far later than baseline → clamp +4
    kCfg,
    2026,
  );
  assertEquals(w.start, isoWeekMonday(2026, 18));
  assertEquals(w.end, addDaysStr(isoWeekMonday(2026, 21), 6));
});

Deno.test('R5 window: spring Δ clamps to −4 weeks for a very early frost', () => {
  const w = resolveWindow(
    rule({
      window: { start_week: 14, end_week: 17, regionalize: 'spring', climate_bucket_filter: null },
    }),
    climate({ lastFrostWeek: 1 }), // far earlier than baseline → clamp −4
    kCfg,
    2026,
  );
  assertEquals(w.start, isoWeekMonday(2026, 10));
});

Deno.test('R5 window: default bucket (fromDefaults) yields Δ=0', () => {
  // climate_profile null → climate.lastFrostWeek == baseline → no shift.
  const c = buildSignals(
    bundle({ profile: { ...bundle().profile, climate_profile: null } }),
    kTaskTypes,
    null,
    kCfg,
    kNow,
  ).climate;
  const w = resolveWindow(
    rule({
      window: { start_week: 14, end_week: 17, regionalize: 'spring', climate_bucket_filter: null },
    }),
    c,
    kCfg,
    2026,
  );
  assertEquals(w.start, isoWeekMonday(2026, 14));
});

Deno.test('R5 window: south hemisphere skips month_window (returns null bounds)', () => {
  const w = resolveWindow(
    rule({
      window: { start_week: 14, end_week: 17, regionalize: 'spring', climate_bucket_filter: null },
    }),
    climate({ hemisphereSouth: true }),
    kCfg,
    2026,
  );
  assertEquals(w.start, null);
});

Deno.test('R5 window: frost-free location skips frost_offset (anchor null)', () => {
  const w = resolveWindow(
    rule({
      timing_anchor: 'frost_offset',
      window: { anchor: 'last_frost', offset_min_days: -10, offset_max_days: 0 },
    }),
    climate({ lastFrostDate: null }),
    kCfg,
    2026,
  );
  assertEquals(w.start, null);
});

// ==================== R5 emit behaviour ====================

Deno.test('R5: south hemisphere emits nothing for a month_window rule', () => {
  const b = bundle({
    plants: [plant('p1', 'apple', 'fruit_tree')],
    profile: {
      ...bundle().profile,
      climate_profile: {
        hemisphere: 'south',
        frost_last_spring_doy: 270,
        frost_first_autumn_doy: 100,
      },
    },
  });
  const r = rule({
    ref_id: 'apple',
    window: { start_week: 22, end_week: 28, regionalize: 'spring', climate_bucket_filter: null },
  });
  assertEquals(r5(b, [r], signalsOf(b), kTaskTypes, kCfg).length, 0);
});

Deno.test('R5: a dry window lifts a weather-sensitive season rule to 3.0', () => {
  const b = bundle({ plants: [plant('p1', 'pepper', 'vegetable')] });
  const r = rule({
    ref_id: 'pepper',
    task_type_id: 'fertilize',
    window: { start_week: 20, end_week: 28, regionalize: 'none', climate_bucket_filter: null },
  });
  const c = r5(b, [r], signalsOf(b, dryPayload()), kTaskTypes, kCfg);
  assertEquals(c.length, 1);
  assertEquals(c[0].score, 3.0); // season 1.0 + dry window 2.0
  assertEquals(c[0].plantTaskRuleId, 'r.test');
  assertEquals(c[0].ruleId, 'R5');
});

Deno.test('R5: a protected subject gets no dry-window bonus (stays 1.0)', () => {
  const b = bundle({
    areas: [{ id: 'g1', name: 'Greenhouse', type: 'bed', protected: true }],
    plants: [plant('p1', 'pepper', 'vegetable', 'g1')],
  });
  const r = rule({
    ref_id: 'pepper',
    task_type_id: 'fertilize',
    window: { start_week: 20, end_week: 28, regionalize: 'none', climate_bucket_filter: null },
  });
  const c = r5(b, [r], signalsOf(b, dryPayload()), kTaskTypes, kCfg);
  assertEquals(c.length, 1);
  assertEquals(c[0].score, 1.0);
});

Deno.test('R5: a category rule skips a plant that has its own override', () => {
  const b = bundle({ plants: [plant('p1', 'apple', 'fruit_tree')] });
  const cat = rule({
    id: 'fruit_tree.fertilize',
    scope: 'category',
    ref_id: 'fruit_tree',
    task_type_id: 'fertilize',
    window: { start_week: 20, end_week: 28, regionalize: 'none', climate_bucket_filter: null },
  });
  const over = rule({
    id: 'apple.fertilize',
    scope: 'plant',
    ref_id: 'apple',
    task_type_id: 'fertilize',
    window: { start_week: 20, end_week: 28, regionalize: 'none', climate_bucket_filter: null },
  });
  const c = r5(b, [cat, over], signalsOf(b), kTaskTypes, kCfg);
  // Only the plant override emits for the apple — the category rule is skipped for it.
  assertEquals(c.length, 1);
  assertEquals(c[0].plantTaskRuleId, 'apple.fertilize');
});

Deno.test('R5: climate_bucket_filter excludes a non-matching bucket', () => {
  const b = bundle({ plants: [plant('p1', 'pepper', 'vegetable')] });
  const r = rule({
    ref_id: 'pepper',
    task_type_id: 'fertilize',
    window: { start_week: 20, end_week: 28, regionalize: 'none', climate_bucket_filter: ['e2_t6'] },
  });
  assertEquals(r5(b, [r], signalsOf(b), kTaskTypes, kCfg).length, 0);
});

Deno.test('R5: already done within this window is skipped', () => {
  const subj: TaskSubjectRef[] = [{ user_plant_id: 'p1', area_id: null }];
  const b = bundle({
    plants: [plant('p1', 'pepper', 'vegetable')],
    tasks: [done('fertilize', '2026-06-01', subj)],
  });
  const r = rule({
    ref_id: 'pepper',
    task_type_id: 'fertilize',
    window: { start_week: 20, end_week: 28, regionalize: 'none', climate_bucket_filter: null },
  });
  assertEquals(r5(b, [r], signalsOf(b), kTaskTypes, kCfg).length, 0);
});

Deno.test('R5: frost_gate month_window — a task done before the gate still silences it', () => {
  // Week 10 opens 2026-03-02; frost_gate floors the start to the last frost
  // (2026-04-06). A task done 2026-03-15 falls in the gap — it must still count
  // as "done in the window" (compared to the calendar open, not the gated start).
  const subj: TaskSubjectRef[] = [{ user_plant_id: 'p1', area_id: null }];
  const r = rule({
    ref_id: 'apple',
    task_type_id: 'prune',
    frost_gate: true,
    window: { start_week: 10, end_week: 20, regionalize: 'none', climate_bucket_filter: null },
  });
  const now = new Date('2026-04-12T12:00:00Z');
  const fresh = bundle({ plants: [plant('p1', 'apple', 'fruit_tree')] });
  assertEquals(r5(fresh, [r], signalsOf(fresh, null, now), kTaskTypes, kCfg).length, 1);
  const withDone = bundle({
    plants: [plant('p1', 'apple', 'fruit_tree')],
    tasks: [done('prune', '2026-03-15', subj)],
  });
  assertEquals(r5(withDone, [r], signalsOf(withDone, null, now), kTaskTypes, kCfg).length, 0);
});

Deno.test('R5: first_frost protect rule scores 2.0 and emits without weather', () => {
  const b = bundle({ plants: [plant('p1', 'fig', 'shrub')] });
  // Window −28..−7 before the first frost (2026-11-07) → ~Oct 10..31; now Oct 15.
  const r = rule({
    ref_id: 'fig',
    task_type_id: 'protect',
    timing_anchor: 'frost_offset',
    window: { anchor: 'first_frost', offset_min_days: -28, offset_max_days: -7 },
  });
  const now = new Date('2026-10-15T12:00:00Z');
  const c = r5(b, [r], signalsOf(b, null, now), kTaskTypes, kCfg);
  assertEquals(c.length, 1);
  assertEquals(c[0].score, 2.0); // frost-protect base, no weather needed
});

Deno.test('R5: two hydrangea prune rules collapse to one (dedup by type+subject)', () => {
  const b = bundle({ plants: [plant('p1', 'hydrangea', 'shrub')] });
  const a = rule({
    id: 'hydrangea.prune.a',
    ref_id: 'hydrangea',
    window: { start_week: 20, end_week: 28, regionalize: 'none', climate_bucket_filter: null },
  });
  const c = rule({
    id: 'hydrangea.prune.b',
    ref_id: 'hydrangea',
    window: { start_week: 22, end_week: 30, regionalize: 'none', climate_bucket_filter: null },
  });
  const cands = r5(b, [a, c], signalsOf(b), kTaskTypes, kCfg);
  assertEquals(cands.length, 2); // both windows contain today
  assertEquals(dedupAndRank(cands, kCfg).length, 1); // only one survives per (type, subject)
});

// ==================== R7 chain (growth_stage) ====================

const kTomato: TaskSubjectRef[] = [{ user_plant_id: 'p1', area_id: null }];

function chainRule(over: Partial<PlantTaskRule> = {}): PlantTaskRule {
  return rule({
    id: 'tomato.prick_out',
    ref_id: 'tomato',
    task_type_id: 'prick_out',
    timing_anchor: 'growth_stage',
    window: { after_event: 'start_seedlings', offset_min_days: 14, offset_max_days: 28 },
    ...over,
  });
}

Deno.test('R7: step K done → proposes K+1 inside the offset window', () => {
  const b = bundle({
    plants: [plant('p1', 'tomato', 'vegetable')],
    tasks: [done('start_seedlings', '2026-05-20', kTomato)],
  });
  const c = r7(b, [chainRule()], signalsOf(b), kCfg);
  assertEquals(c.length, 1);
  assertEquals(c[0].ruleId, 'R7');
  assertEquals(c[0].score, 2.0); // chain_ready, on time
  assertEquals(c[0].messageParams.days_since, 23);
  assertEquals(c[0].messageParams.late, false);
});

Deno.test('R7: K+1 already done after K → nothing', () => {
  const b = bundle({
    plants: [plant('p1', 'tomato', 'vegetable')],
    tasks: [
      done('start_seedlings', '2026-05-20', kTomato),
      done('prick_out', '2026-06-05', kTomato),
    ],
  });
  assertEquals(r7(b, [chainRule()], signalsOf(b), kCfg).length, 0);
});

Deno.test('R7: no preceding step → no chain', () => {
  const b = bundle({ plants: [plant('p1', 'tomato', 'vegetable')] });
  assertEquals(r7(b, [chainRule()], signalsOf(b), kCfg).length, 0);
});

Deno.test('R7: past the window flags late and adds 0.5', () => {
  const b = bundle({
    plants: [plant('p1', 'tomato', 'vegetable')],
    tasks: [done('start_seedlings', '2026-05-01', kTomato)],
  });
  const c = r7(b, [chainRule()], signalsOf(b), kCfg); // 42 days > 28 → late
  assertEquals(c.length, 1);
  assertEquals(c[0].messageParams.late, true);
  assertEquals(c[0].score, 2.5);
});

Deno.test('R7: frost_gate holds the transplant back until the last frost', () => {
  // harden_off done 2026-03-20, window 0..14 → would start 03-20, but frost gate
  // floors the start to the last frost (2026-04-06). On 2026-03-25 → not yet.
  const b = bundle({
    plants: [plant('p1', 'tomato', 'vegetable')],
    tasks: [done('harden_off', '2026-03-20', kTomato)],
  });
  const transplant = rule({
    id: 'tomato.transplant',
    ref_id: 'tomato',
    task_type_id: 'transplant',
    timing_anchor: 'growth_stage',
    window: { after_event: 'harden_off', offset_min_days: 0, offset_max_days: 14 },
    frost_gate: true,
  });
  const before = new Date('2026-03-25T12:00:00Z');
  assertEquals(r7(b, [transplant], signalsOf(b, null, before), kCfg).length, 0);
  // By June the frost is long past → emits, carrying frostGate for the 48h guard.
  const c = r7(b, [transplant], signalsOf(b), kCfg);
  assertEquals(c.length, 1);
  assertEquals(c[0].frostGate, true);
});
