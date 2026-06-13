import { assertEquals } from 'jsr:@std/assert@1';
import { buildSignals } from './signals.ts';
import { r2, r3 } from './rules.ts';
import { applyGuards, dedupAndRank, emit } from './pipeline.ts';
import { kDefaultEngine, kDefaultFrost, kDefaultThresholds } from './config.ts';
import type {
  Candidate,
  EngineConfig,
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
const kNow = new Date('2026-06-12T12:00:00Z');
const kTaskTypes = new Map<string, TaskTypeMeta>([
  ['treat', { id: 'treat', default_cadence: 7, weather_sensitive: true, seasonal: true }],
]);
const kPlant: TaskSubjectRef[] = [{ user_plant_id: 'p1', area_id: null }];

let seq = 0;
function done(taskTypeId: string, day: string): TaskRow {
  return {
    id: 't' + (++seq),
    task_type_id: taskTypeId,
    date: day + 'T10:00:00Z',
    status: 'done',
    subjects: kPlant,
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

// 17 days overdue + dry window → R3 scores 3.0 (clears the threshold) so each
// guard test isolates exactly one drop reason.
function overdueDry(overrides: Partial<UserBundle> = {}) {
  const b = bundle([done('treat', '2026-05-26')], overrides);
  const signals = buildSignals(b, kTaskTypes, dryPayload(), kCfg, kNow);
  const candidates = [...r3(b, signals, kTaskTypes, kCfg), ...r2(b, signals, kTaskTypes, kCfg)];
  return { b, signals, candidates };
}

function guardedCount(overrides: Partial<UserBundle> = {}): number {
  const { signals, candidates } = overdueDry(overrides);
  return applyGuards(candidates, signals, kCfg, kNow).length;
}

// ---------- guards (step 5) ----------

Deno.test('guard h: 10 days overdue without weather is dropped (1.0 < 2.0)', () => {
  const b = bundle([done('treat', '2026-05-26')]);
  const signals = buildSignals(b, kTaskTypes, null, kCfg, kNow);
  const candidates = r3(b, signals, kTaskTypes, kCfg);
  assertEquals(candidates.length, 1); // produced…
  assertEquals(applyGuards(candidates, signals, kCfg, kNow).length, 0); // …but dropped
});

Deno.test('guard h: a dry window pushes it through (one emit)', () => {
  assertEquals(guardedCount(), 1);
});

Deno.test('guard b: a future dismissed_until drops the candidate', () => {
  assertEquals(
    guardedCount({
      suggestionLog: [{
        guard_key: 'R3:treat',
        subject_key: 'up:p1',
        last_suggested_at: null,
        dismissed_until: '2026-07-01T00:00:00+00:00',
      }],
    }),
    0,
  );
});

Deno.test('guard c: a recent suggestion within cooldown drops it', () => {
  assertEquals(
    guardedCount({
      suggestionLog: [{
        guard_key: 'R3:treat',
        subject_key: 'up:p1',
        last_suggested_at: '2026-06-10T07:00:00+00:00', // 2 days < 5-day cooldown
        dismissed_until: null,
      }],
    }),
    0,
  );
});

Deno.test('guard e: a planned waiting task of the same type+subject drops it', () => {
  assertEquals(
    guardedCount({ tasks: [done('treat', '2026-05-26'), waiting('treat', '2026-06-15')] }),
    0,
  );
});

Deno.test('guard f: an active suggestion of the same type+subject drops it', () => {
  assertEquals(
    guardedCount({
      activeSuggestions: [{
        task_type_id: 'treat',
        subject_key: 'up:p1',
        valid_until: '2026-06-20',
      }],
    }),
    0,
  );
});

Deno.test('guard a: a removed subject drops it', () => {
  assertEquals(guardedCount({ plants: [] }), 0); // history references p1, but it is gone
});

function waiting(taskTypeId: string, day: string): TaskRow {
  return {
    id: 'w' + (++seq),
    task_type_id: taskTypeId,
    date: day + 'T08:00:00Z',
    status: 'waiting',
    subjects: kPlant,
    hasReminder: false,
    supplyIds: [],
  };
}

// ---------- dedup + rank (steps 6–7) ----------

function cand(overrides: Partial<Candidate> = {}): Candidate {
  return {
    ruleId: 'R3',
    plantTaskRuleId: null,
    taskTypeId: 'treat',
    subjectKey: 'up:p1',
    userPlantId: 'p1',
    areaId: null,
    messageKey: 'k',
    messageParams: {},
    score: 3.0,
    suggestedDate: '2026-06-13',
    validUntil: '2026-06-17',
    cooldownDays: 5,
    weatherGuard: null,
    ...overrides,
  };
}

Deno.test('dedup: highest score wins per (taskType, subject)', () => {
  const ranked = dedupAndRank([
    cand({ ruleId: 'R2', score: 2.5 }),
    cand({ ruleId: 'R3', score: 4.0 }),
  ], kCfg);
  assertEquals(ranked.length, 1);
  assertEquals(ranked[0].score, 4.0);
});

Deno.test('rank: caps at band_max_active and sorts by score desc', () => {
  const ranked = dedupAndRank([
    cand({ subjectKey: 'up:a', score: 2.0 }),
    cand({ subjectKey: 'up:b', score: 5.0 }),
    cand({ subjectKey: 'up:c', score: 3.0 }),
    cand({ subjectKey: 'up:d', score: 4.0 }),
  ], kCfg);
  assertEquals(ranked.map((c) => c.subjectKey), ['up:b', 'up:d', 'up:c']); // top 3
});

Deno.test('determinism: identical input twice yields identical ranking', () => {
  const run = () => {
    const { signals, candidates } = overdueDry();
    return dedupAndRank(applyGuards(candidates, signals, kCfg, kNow), kCfg);
  };
  assertEquals(JSON.stringify(run()), JSON.stringify(run()));
});

// ---------- emit (step 8) ----------

Deno.test('emit: inserts suggestion rows and stamps suggestion_log with updated_at', async () => {
  const state = { inserted: [] as Record<string, unknown>[], logRows: null as unknown };
  // deno-lint-ignore no-explicit-any
  const db: any = {
    from(table: string) {
      return {
        insert(rows: Record<string, unknown>[]) {
          if (table === 'suggestion') state.inserted.push(...rows);
          return Promise.resolve({ error: null });
        },
        upsert(rows: unknown) {
          if (table === 'suggestion_log') state.logRows = rows;
          return Promise.resolve({ error: null });
        },
      };
    },
  };
  const b = bundle([]);
  const n = await emit(db, b, [cand()], kNow);
  assertEquals(n, 1);
  assertEquals(state.inserted.length, 1);
  assertEquals(state.inserted[0].status, 'new');
  assertEquals(state.inserted[0].subject_key, 'up:p1');
  assertEquals(state.inserted[0].valid_until, '2026-06-17');
  const log = (state.logRows as Record<string, unknown>[])[0];
  assertEquals(log.guard_key, 'R3:treat');
  assertEquals(log.updated_at, kNow.toISOString()); // explicit (PG default only on INSERT)
  assertEquals('dismissed_until' in log, false); // omitted → a prior mute survives the merge
});
