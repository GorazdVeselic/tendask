import { assertEquals } from 'jsr:@std/assert@1';
import { buildClimateSignals, buildSignals } from './signals.ts';
import { kDefaultEngine, kDefaultFrost, kDefaultThresholds } from './config.ts';
import type {
  EngineConfig,
  Profile,
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

// 12:00 UTC = 14:00 in Europe/Ljubljana (CEST) → local today 2026-06-12.
const kNow = new Date('2026-06-12T12:00:00Z');

function profile(overrides: Partial<Profile> = {}): Profile {
  return {
    user_id: 'u1',
    h3_r7: '871f1d4a9ffffff',
    timezone: 'Europe/Ljubljana',
    lang: 'sl',
    climate_bucket: 'e1_t6',
    climate_profile: {
      frost_last_spring_doy: 108,
      frost_first_autumn_doy: 295,
      growing_season_days: 187,
    },
    fcm_token: null,
    ...overrides,
  };
}

let taskSeq = 0;
function task(
  taskTypeId: string,
  dateIso: string,
  status: 'waiting' | 'done',
  subjects: TaskSubjectRef[],
  opts: { hasReminder?: boolean; supplyIds?: string[] } = {},
): TaskRow {
  return {
    id: 't' + (++taskSeq),
    task_type_id: taskTypeId,
    date: dateIso,
    status,
    subjects,
    hasReminder: opts.hasReminder ?? false,
    supplyIds: opts.supplyIds ?? [],
  };
}

const kPlantSubject: TaskSubjectRef[] = [{ user_plant_id: 'p1', area_id: null }];

function bundle(overrides: Partial<UserBundle> = {}): UserBundle {
  return {
    profile: profile(),
    areas: [],
    plants: [],
    tasks: [],
    supplies: [],
    suggestionLog: [],
    activeSuggestions: [],
    ...overrides,
  };
}

const kTaskTypes = new Map<string, TaskTypeMeta>([
  ['mow', { id: 'mow', default_cadence: 10, weather_sensitive: true, seasonal: true }],
  ['water', { id: 'water', default_cadence: null, weather_sensitive: true, seasonal: false }],
]);

function signalsOf(b: UserBundle) {
  return buildSignals(b, kTaskTypes, null, kCfg, kNow);
}

// ---------- climate (B) ----------

Deno.test('climate: frost DOYs → safety-adjusted dates + ISO weeks', () => {
  const c = buildClimateSignals(profile(), kCfg, '2026-06-12');
  assertEquals(c.lastFrostDate, '2026-04-25'); // DOY 108 = Apr 18 + 7 safety
  assertEquals(c.firstFrostDate, '2026-10-15'); // DOY 295 = Oct 22 − 7 safety
  assertEquals(c.lastFrostWeek, 17);
  assertEquals(c.firstFrostWeek, 42);
  assertEquals(c.growingSeasonDays, 187);
  assertEquals(c.bucket, 'e1_t6');
  assertEquals(c.hemisphereSouth, false);
  assertEquals(c.fromDefaults, false);
});

Deno.test('climate: missing profile falls back to frost_defaults', () => {
  const c = buildClimateSignals(profile({ climate_profile: null }), kCfg, '2026-06-12');
  assertEquals(c.fromDefaults, true);
  assertEquals(c.lastFrostDate, '2026-04-27'); // DOY 110 = Apr 20 + 7
  assertEquals(c.firstFrostDate, '2026-10-13'); // DOY 293 = Oct 20 − 7
  assertEquals(c.growingSeasonDays, 183);
});

Deno.test('climate: frost-free location keeps null frost dates', () => {
  const c = buildClimateSignals(
    profile({
      climate_profile: { frost_last_spring_doy: null, frost_first_autumn_doy: null },
    }),
    kCfg,
    '2026-06-12',
  );
  assertEquals(c.lastFrostDate, null);
  assertEquals(c.firstFrostDate, null);
  assertEquals(c.fromDefaults, false);
});

Deno.test('climate: southern hemisphere flag from the profile', () => {
  const c = buildClimateSignals(
    profile({ climate_profile: { hemisphere: 'south' } }),
    kCfg,
    '2026-06-12',
  );
  assertEquals(c.hemisphereSouth, true);
});

// ---------- history (C) ----------

Deno.test('history: done dates bin into the user-local day', () => {
  // 22:30 UTC = next day 00:30 in Europe/Ljubljana.
  const s = signalsOf(bundle({
    tasks: [task('mow', '2026-06-11T22:30:00Z', 'done', kPlantSubject)],
  }));
  assertEquals(s.history.lastDone('up:p1', 'mow'), '2026-06-12');
});

Deno.test('history: lastDone per subject vs any subject', () => {
  const s = signalsOf(bundle({
    tasks: [
      task('mow', '2026-05-01T10:00:00Z', 'done', kPlantSubject),
      task('mow', '2026-06-01T10:00:00Z', 'done', [{ user_plant_id: null, area_id: 'a1' }]),
      task('mow', '2026-06-05T10:00:00Z', 'waiting', kPlantSubject), // waiting ignored
    ],
  }));
  assertEquals(s.history.lastDone('up:p1', 'mow'), '2026-05-01');
  assertEquals(s.history.lastDone('ar:a1', 'mow'), '2026-06-01');
  assertEquals(s.history.lastDoneAnySubject('mow'), '2026-06-01');
  assertEquals(s.history.lastDone('up:p1', 'water'), null);
});

Deno.test('history: cadence = median of gaps over the last 5 executions', () => {
  const dates = ['2026-04-01', '2026-04-08', '2026-04-15', '2026-04-22', '2026-05-01'];
  const s = signalsOf(bundle({
    tasks: dates.map((d) => task('mow', d + 'T10:00:00Z', 'done', kPlantSubject)),
  }));
  assertEquals(s.history.cadenceDays('up:p1', 'mow'), 7); // gaps 7,7,7,9 → median 7
});

Deno.test('history: cadence falls back to default_cadence under 3 executions', () => {
  const s = signalsOf(bundle({
    tasks: [
      task('mow', '2026-05-01T10:00:00Z', 'done', kPlantSubject),
      task('mow', '2026-05-10T10:00:00Z', 'done', kPlantSubject),
      task('water', '2026-06-01T10:00:00Z', 'done', kPlantSubject),
    ],
  }));
  assertEquals(s.history.cadenceDays('up:p1', 'mow'), 10); // task_type.default_cadence
  assertEquals(s.history.cadenceDays('up:p1', 'water'), null); // no default either
});

Deno.test('history: chainStepDate sees only the current season (calendar year)', () => {
  const s = signalsOf(bundle({
    tasks: [
      task('sow', '2025-12-01T10:00:00Z', 'done', kPlantSubject),
      task('sow', '2026-03-15T10:00:00Z', 'done', kPlantSubject),
    ],
  }));
  assertEquals(s.history.chainStepDate('up:p1', 'sow'), '2026-03-15');
  const previousYearOnly = signalsOf(bundle({
    tasks: [task('sow', '2025-12-01T10:00:00Z', 'done', kPlantSubject)],
  }));
  assertEquals(previousYearOnly.history.chainStepDate('up:p1', 'sow'), null);
});

Deno.test('history: lastDoneYearAgo matches within ±7 days of today−1y', () => {
  const hit = signalsOf(bundle({
    tasks: [task('prune', '2025-06-08T10:00:00Z', 'done', kPlantSubject)],
  }));
  assertEquals(hit.history.lastDoneYearAgo('up:p1', 'prune'), '2025-06-08');
  const miss = signalsOf(bundle({
    tasks: [task('prune', '2025-05-20T10:00:00Z', 'done', kPlantSubject)],
  }));
  assertEquals(miss.history.lastDoneYearAgo('up:p1', 'prune'), null);
});

// ---------- inventory (D) ----------

Deno.test('inventory: supplies from the last 5 done tasks of the type', () => {
  const tasks = [
    task('fertilize', '2026-01-01T10:00:00Z', 'done', [], { supplyIds: ['s3'] }), // 6th newest
    task('fertilize', '2026-02-01T10:00:00Z', 'done', [], { supplyIds: ['s1'] }),
    task('fertilize', '2026-03-01T10:00:00Z', 'done', [], { supplyIds: ['s2'] }),
    task('fertilize', '2026-04-01T10:00:00Z', 'done', [], { supplyIds: ['s1'] }),
    task('fertilize', '2026-05-01T10:00:00Z', 'done', [], { supplyIds: [] }),
    task('fertilize', '2026-06-01T10:00:00Z', 'done', [], { supplyIds: ['s1'] }),
  ];
  const s = signalsOf(bundle({
    tasks,
    supplies: [
      { id: 's1', name: 'NPK', quantity: 0, low_threshold: null },
      { id: 's2', name: 'Compost', quantity: 5, low_threshold: 2 },
      { id: 's3', name: 'Lime', quantity: 9, low_threshold: null },
    ],
  }));
  const ids = s.inventory.suppliesForTaskType('fertilize').map((x) => x.id).sort();
  assertEquals(ids, ['s1', 's2']); // s3 only on the 6th-newest task → excluded
  assertEquals(s.inventory.hasSupply('s1'), false); // 0 > 0 is false
  assertEquals(s.inventory.hasSupply('s2'), true);
});

// ---------- eligibility (E) ----------

Deno.test('eligibility: areas by type, plants by category/id, protected subjects', () => {
  const s = signalsOf(bundle({
    areas: [
      { id: 'a1', name: 'Lawn', type: 'lawn', protected: false },
      { id: 'a2', name: 'Greenhouse', type: 'bed', protected: true },
    ],
    plants: [
      {
        id: 'p1',
        area_id: 'a2',
        plant_id: 'tomato',
        custom_name: null,
        personal_alias: null,
        is_custom: false,
        category: 'vegetable',
      },
      {
        id: 'p2',
        area_id: 'a1',
        plant_id: null,
        custom_name: 'Mystery',
        personal_alias: null,
        is_custom: true,
        category: null,
      },
    ],
  }));
  assertEquals(s.eligibility.areasByType('lawn').map((a) => a.id), ['a1']);
  assertEquals(s.eligibility.plantsByCategory('vegetable').map((p) => p.id), ['p1']);
  assertEquals(s.eligibility.plantsById('tomato').map((p) => p.id), ['p1']);
  assertEquals(s.eligibility.isProtectedSubject('up:p1'), true); // in greenhouse area
  assertEquals(s.eligibility.isProtectedSubject('up:p2'), false);
  assertEquals(s.eligibility.isProtectedSubject('ar:a2'), true);
  assertEquals(s.eligibility.isProtectedSubject('ar:a1'), false);
});

// ---------- state (F) ----------

Deno.test('state: planned matches waiting task of same type+subject within N days', () => {
  const s = signalsOf(bundle({
    tasks: [
      task('mow', '2026-06-20T08:00:00Z', 'waiting', kPlantSubject),
      task('mow', '2026-06-27T08:00:00Z', 'waiting', [{ user_plant_id: 'p9', area_id: null }]),
      task('mow', '2026-06-10T08:00:00Z', 'waiting', [{ user_plant_id: null, area_id: 'a1' }]),
    ],
  }));
  assertEquals(s.state.planned('up:p1', 'mow', 14), true);
  assertEquals(s.state.planned('up:p1', 'water', 14), false); // other type
  assertEquals(s.state.planned('up:p9', 'mow', 14), false); // 06-27 > today+14
  assertEquals(s.state.planned('up:p9', 'mow', 15), true);
  assertEquals(s.state.planned('ar:a1', 'mow', 14), false); // past task
});

Deno.test('state: reminderExists requires a reminder on the matching task', () => {
  const s = signalsOf(bundle({
    tasks: [
      task('mow', '2026-06-20T08:00:00Z', 'waiting', kPlantSubject, { hasReminder: true }),
      task('water', '2026-06-20T08:00:00Z', 'waiting', kPlantSubject),
    ],
  }));
  assertEquals(s.state.reminderExists('up:p1', 'mow', 14), true);
  assertEquals(s.state.reminderExists('up:p1', 'water', 14), false);
});

Deno.test('state: dismissed honours dismissed_until incl. infinity', () => {
  const s = signalsOf(bundle({
    suggestionLog: [
      {
        guard_key: 'R3:mow',
        subject_key: 'up:p1',
        last_suggested_at: '2026-06-01T07:00:00+00:00',
        dismissed_until: '2026-07-01T00:00:00+00:00',
      },
      {
        guard_key: 'R3:mow',
        subject_key: 'up:p2',
        last_suggested_at: null,
        dismissed_until: '2026-06-01T00:00:00+00:00',
      },
      {
        guard_key: 'apple.prune.winter',
        subject_key: 'up:p1',
        last_suggested_at: null,
        dismissed_until: 'infinity',
      },
    ],
  }));
  assertEquals(s.state.dismissed('R3:mow', 'up:p1'), true);
  assertEquals(s.state.dismissed('R3:mow', 'up:p2'), false); // already elapsed
  assertEquals(s.state.dismissed('apple.prune.winter', 'up:p1'), true);
  assertEquals(s.state.dismissed('R3:mow', 'up:p9'), false); // no row
  assertEquals(s.state.lastSuggestedAt('R3:mow', 'up:p1'), '2026-06-01T07:00:00+00:00');
  assertEquals(s.state.lastSuggestedAt('R3:mow', 'up:p9'), null);
});

Deno.test('state: activeSuggestion dedups by type+subject while valid', () => {
  const s = signalsOf(bundle({
    activeSuggestions: [
      { task_type_id: 'mow', subject_key: 'up:p1', valid_until: '2026-06-15' },
      { task_type_id: 'prune', subject_key: 'up:p1', valid_until: '2026-06-10' },
    ],
  }));
  assertEquals(s.state.activeSuggestion('mow', 'up:p1'), true);
  assertEquals(s.state.activeSuggestion('prune', 'up:p1'), false); // expired
  assertEquals(s.state.activeSuggestion('mow', 'up:p2'), false);
});

// ---------- top level ----------

Deno.test('buildSignals: no location → noLocation flag and null weather', () => {
  const s = signalsOf(bundle({ profile: profile({ h3_r7: null }) }));
  assertEquals(s.noLocation, true);
  assertEquals(s.weather, null);
  assertEquals(s.localToday, '2026-06-12');
});

Deno.test('buildSignals: invalid timezone falls back to UTC', () => {
  const s = signalsOf(bundle({ profile: profile({ timezone: 'Not/AZone' }) }));
  assertEquals(s.timeZone, 'UTC');
});

Deno.test('buildSignals: null timezone falls back to the cell offset from the payload', () => {
  // UTC+13 cell, 12:00Z → local 2026-06-13 01:00 (UTC day would be 06-12).
  const payload = { utc_offset_seconds: 46800, hourly: { time: [] } };
  const s = buildSignals(
    bundle({ profile: profile({ timezone: null }) }),
    kTaskTypes,
    payload,
    kCfg,
    kNow,
  );
  assertEquals(s.localToday, '2026-06-13');
  assertEquals(s.timeZone, 'offset:46800s');
});
