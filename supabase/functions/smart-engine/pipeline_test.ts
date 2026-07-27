import { assertEquals, assertNotEquals } from 'jsr:@std/assert@1';
import { buildSignals } from './signals.ts';
import { r2, r3 } from './rules.ts';
import { applyGuards, dedupAndRank, emit, enrichR4 } from './pipeline.ts';
import { planHousekeeping } from './housekeep.ts';
import {
  kDefaultCommunityThresholds,
  kDefaultEngine,
  kDefaultFrost,
  kDefaultThresholds,
} from './config.ts';
import type {
  Candidate,
  EngineConfig,
  TaskRow,
  TaskSubjectRef,
  TaskTypeMeta,
  UserBundle,
} from './types.ts';

const kCfg: EngineConfig = {
  enabled: true,
  engine: kDefaultEngine,
  weatherThresholds: kDefaultThresholds,
  frostDefaults: kDefaultFrost,
  thresholds: kDefaultCommunityThresholds,
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
      h3_r6: null,
      h3_r5: null,
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
  const candidates = [...r3(b, [], signals, kTaskTypes, kCfg), ...r2(b, signals, kTaskTypes, kCfg)];
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
  const candidates = r3(b, [], signals, kTaskTypes, kCfg);
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

Deno.test('guard b: a dismiss made through housekeeping silences the next run', () => {
  // The chain neither unit covers on its own: dismissing writes a mute only if
  // housekeeping looks past the log row emit already stamped for that candidate.
  const { b, signals, candidates } = overdueDry({
    suggestionLog: [{
      guard_key: 'R3:treat',
      subject_key: 'up:p1',
      last_suggested_at: '2026-06-01T07:00:00+00:00', // emitted, then dismissed
      dismissed_until: null,
    }],
  });
  assertEquals(applyGuards(candidates, signals, kCfg, kNow).length, 1); // before

  const plan = planHousekeeping(
    [{
      id: 's1',
      rule_id: 'R3',
      plant_task_rule_id: null,
      task_type_id: 'treat',
      subject_key: 'up:p1',
      status: 'dismissed',
      dismiss_scope: 'season',
      valid_until: '2026-06-30',
      updated_at: '2026-06-11T18:00:00+00:00',
    }],
    new Map(b.suggestionLog.map((l) => [l.guard_key + '|' + l.subject_key, l])),
    new Set(['up:p1']),
    '2026-06-12',
    Date.parse('2025-06-12T00:00:00Z'),
    signals.climate,
    new Map(),
    kCfg,
  );
  assertEquals(plan.newMutes.length, 1);

  b.suggestionLog.push(...plan.newMutes); // what housekeep() reflects in-memory
  const after = buildSignals(b, kTaskTypes, dryPayload(), kCfg, kNow);
  assertEquals(applyGuards(candidates, after, kCfg, kNow).length, 0); // after
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

// Guard 5d: after an execution, wait max(3, cadence/2) days before suggesting
// the same act again — the only guard with no test until now. The candidate is
// built directly: R3 fires only once something is overdue, which is past the
// cooldown by definition, so no rule can exercise this guard on its own.
function cooldownSurvives(
  lastDoneDay: string,
  declaredCadence: number | null,
  taskTypeId = 'treat',
): boolean {
  const types = new Map<string, TaskTypeMeta>([
    [taskTypeId, {
      id: taskTypeId,
      default_cadence: declaredCadence,
      weather_sensitive: false,
      seasonal: true,
    }],
  ]);
  const b = bundle([done(taskTypeId, lastDoneDay)]);
  const signals = buildSignals(b, types, null, kCfg, kNow);
  return applyGuards([cand({ taskTypeId, score: 5 })], signals, kCfg, kNow).length === 1;
}

Deno.test('guard d: the cooldown after doing it is half the cadence', () => {
  // Declared cadence 14 → wait 7 days. Today is 2026-06-12.
  assertEquals(cooldownSurvives('2026-06-05', 14), true); // exactly at the bound
  assertEquals(cooldownSurvives('2026-06-06', 14), false); // 6 days — too soon
});

Deno.test('guard d: a short cadence still keeps a 3-day floor', () => {
  // cadence/2 would be 2, but nothing is suggested again within three days.
  assertEquals(cooldownSurvives('2026-06-09', 4), true);
  assertEquals(cooldownSurvives('2026-06-10', 4), false);
});

Deno.test('guard d: without a cadence there is nothing to wait for', () => {
  // No declared cadence and too few executions to learn one → the guard is
  // skipped, and an event-driven rule may follow the very next day.
  assertEquals(cooldownSurvives('2026-06-11', null, 'prune'), true);
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
    frostGate: false,
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

// ---------- full pipeline scenarios (docs/m11/03 §Cevovod) ----------

function wetPayload(): Record<string, unknown> {
  const p = dryPayload();
  // deno-lint-ignore no-explicit-any
  (p.hourly as any).precipitation = Array.from({ length: 24 * 6 }, () => 1);
  return p;
}

function runPipeline(b: UserBundle, payload: unknown): Candidate[] {
  const signals = buildSignals(b, kTaskTypes, payload, kCfg, kNow);
  const candidates = [...r3(b, [], signals, kTaskTypes, kCfg), ...r2(b, signals, kTaskTypes, kCfg)];
  const guarded = applyGuards(candidates, signals, kCfg, kNow);
  return dedupAndRank(enrichR4(guarded, signals.inventory, kCfg), kCfg);
}

Deno.test('scenario: rain over an overdue treat emits nothing (R1 absent)', () => {
  const b = bundle([done('treat', '2026-05-26')]); // overdue 10 → 1.0 alone, < 2.0
  assertEquals(runPipeline(b, wetPayload()).length, 0);
});

Deno.test('scenario: dry + overdue treat emits one card at 4.0', () => {
  const b = bundle([done('treat', '2026-05-16')]); // overdue 20 → 2.0 + dry 2.0
  const ranked = runPipeline(b, dryPayload());
  assertEquals(ranked.length, 1);
  assertEquals(ranked[0].score, 4.0);
  assertEquals(ranked[0].messageParams.dry_window, true);
});

Deno.test('scenario: five overdue+dry subjects collapse to the top 3', () => {
  const plants = Array.from({ length: 5 }, (_, i) => ({
    id: 'q' + i,
    area_id: null,
    plant_id: 'tomato',
    custom_name: null,
    personal_alias: null,
    is_custom: false,
    category: 'vegetable',
  }));
  const tasks = plants.map((p) => ({
    ...done('treat', '2026-05-16'),
    subjects: [{ user_plant_id: p.id, area_id: null }],
  }));
  const ranked = runPipeline(bundle(tasks, { plants }), dryPayload());
  assertEquals(ranked.length, 3); // band_max_active
});

Deno.test('R4: a low supply bumps the score and adds the supply params', () => {
  const b = bundle([{ ...done('treat', '2026-05-16'), supplyIds: ['s1'] }], {
    supplies: [{ id: 's1', name: 'Copper spray', quantity: 0, low_threshold: 1 }],
  });
  const ranked = runPipeline(b, dryPayload());
  assertEquals(ranked.length, 1);
  assertEquals(ranked[0].score, 4.5); // 4.0 + low supply 0.5
  assertEquals(ranked[0].messageParams.low_supply, true);
  assertEquals(ranked[0].messageParams.supply_name, 'Copper spray');
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
  const { count, topId } = await emit(db, b, [cand()], kNow);
  assertEquals(count, 1);
  assertNotEquals(topId, null);
  assertEquals(state.inserted.length, 1);
  assertEquals(state.inserted[0].status, 'new');
  assertEquals(state.inserted[0].subject_key, 'up:p1');
  assertEquals(state.inserted[0].valid_until, '2026-06-17');
  const log = (state.logRows as Record<string, unknown>[])[0];
  assertEquals(log.guard_key, 'R3:treat');
  assertEquals(log.updated_at, kNow.toISOString()); // explicit (PG default only on INSERT)
  assertEquals('dismissed_until' in log, false); // omitted → a prior mute survives the merge
});
