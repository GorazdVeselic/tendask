import { assertEquals } from 'jsr:@std/assert@1';
import { buildSignals } from './signals.ts';
import { r6 } from './rules_community.ts';
import { buildSeasonCdfs, cdfKey, resolveSeasonCdfs, type SeasonCdf } from './community.ts';
import { applyGuards } from './pipeline.ts';
import {
  kDefaultCommunityThresholds,
  kDefaultEngine,
  kDefaultFrost,
  kDefaultThresholds,
} from './config.ts';
import type {
  EngineConfig,
  TaskRow,
  TaskTypeMeta,
  UserBundle,
  UserPlant,
} from './types.ts';

const kCfg: EngineConfig = {
  engine: kDefaultEngine,
  weatherThresholds: kDefaultThresholds,
  frostDefaults: kDefaultFrost,
  thresholds: kDefaultCommunityThresholds,
};

// 12:00 UTC = 14:00 Europe/Ljubljana → local today 2026-06-12, ISO week 24.
const kNow = new Date('2026-06-12T12:00:00Z');

const kTaskTypes = new Map<string, TaskTypeMeta>([
  ['sow', { id: 'sow', default_cadence: null, weather_sensitive: true, seasonal: true }],
  ['prune', { id: 'prune', default_cadence: null, weather_sensitive: false, seasonal: true }],
  ['water', { id: 'water', default_cadence: 7, weather_sensitive: true, seasonal: false }],
]);

function plant(id: string, plantId: string | null, isCustom = false): UserPlant {
  return {
    id,
    area_id: null,
    plant_id: plantId,
    custom_name: isCustom ? 'Babičina vrtnica' : null,
    personal_alias: null,
    is_custom: isCustom,
    category: 'vegetable',
  };
}

let seq = 0;
function done(taskTypeId: string, day: string, userPlantId: string): TaskRow {
  return {
    id: 't' + (++seq),
    task_type_id: taskTypeId,
    date: day + 'T10:00:00Z',
    status: 'done',
    subjects: [{ user_plant_id: userPlantId, area_id: null }],
    hasReminder: false,
    supplyIds: [],
  };
}

function bundle(overrides: Partial<UserBundle> = {}): UserBundle {
  return {
    profile: {
      user_id: 'u1',
      h3_r7: '871f1d4a9ffffff',
      h3_r6: '861f1d4a7ffffff',
      h3_r5: null,
      timezone: 'Europe/Ljubljana',
      lang: 'sl',
      climate_bucket: 'e1_t6',
      climate_profile: null,
      fcm_token: null,
      notification_settings: null,
    },
    areas: [],
    plants: [plant('p1', 'tomato')],
    tasks: [],
    supplies: [],
    suggestionLog: [],
    activeSuggestions: [],
    ...overrides,
  };
}

/** Rows for one group: `count` gardeners all starting in ISO week `week` of a
 * past season, so F(w) is 0 before it and 1 from it on. */
function rows(taskTypeId: string, cohort: string, week: number, count: number, year = 2025) {
  return [{
    task_type_id: taskTypeId,
    plant_id: cohort,
    year,
    iso_week: week,
    first_user_count: count,
  }];
}

/** A window still open at today's week 24: most of the group already started
 * (week 22), the rest are still starting (week 25). Both halves matter — R6
 * needs "most have started" AND "people are starting right now". */
function openWindow(taskTypeId: string, cohort: string, count: number) {
  const started = Math.round(count * 0.75);
  return [
    ...rows(taskTypeId, cohort, 22, started),
    ...rows(taskTypeId, cohort, 25, count - started),
  ];
}

function cdfsOf(
  raw: Record<string, unknown>[],
  resolution = 'r7',
): Map<string, SeasonCdf> {
  return buildSeasonCdfs(raw, 2026, resolution);
}

function signalsOf(b: UserBundle, now = kNow) {
  return buildSignals(b, kTaskTypes, null, kCfg, now);
}

Deno.test('fires when most nearby have started and you have not', () => {
  const b = bundle();
  const out = r6(b, signalsOf(b), kTaskTypes, cdfsOf(openWindow('sow', 'tomato', 40)), kCfg);

  assertEquals(out.length, 1);
  assertEquals(out[0].ruleId, 'R6');
  assertEquals(out[0].taskTypeId, 'sow');
  assertEquals(out[0].subjectKey, 'up:p1');
  assertEquals(out[0].messageKey, 'suggestions.community.most_started');
  assertEquals(out[0].messageParams.percent, 80); // F(24) = 0.75, rounded to the 10 % step
  assertEquals(out[0].messageParams.subject_label_key, 'tomato');
  assertEquals(out[0].cooldownDays, 14);
});

Deno.test('a season that is over is not "most have started"', () => {
  const b = bundle();
  // Everyone started in week 10 and nobody since: F(24) = 1.0 — true, and
  // useless. Left ungated it also fires every week until New Year.
  assertEquals(
    r6(b, signalsOf(b), kTaskTypes, cdfsOf(rows('sow', 'tomato', 10, 40)), kCfg).length,
    0,
  );
  const november = new Date('2026-11-10T12:00:00Z');
  assertEquals(
    r6(b, signalsOf(b, november), kTaskTypes, cdfsOf(openWindow('sow', 'tomato', 40)), kCfg).length,
    0,
  );
});

Deno.test('the year turn does not fire every seasonal type at once', () => {
  // isoWeek('2027-01-01') = 53 (ISO week 53 of 2026), where F = 1.0 for every
  // finished curve — the one day that would push all seasonal types together.
  const b = bundle();
  const newYear = new Date('2027-01-01T12:00:00Z');
  for (const raw of [openWindow('sow', 'tomato', 40), rows('sow', 'tomato', 10, 40)]) {
    assertEquals(r6(b, signalsOf(b, newYear), kTaskTypes, cdfsOf(raw), kCfg).length, 0);
  }
});

Deno.test('closed-window gate: entering the week at 0.9 still fires, above it does not', () => {
  const b = bundle();
  // 90 of 100 started by week 23, the last 10 during weeks 24–25.
  const atBound = [
    ...rows('sow', 'tomato', 23, 90),
    ...rows('sow', 'tomato', 24, 5),
    ...rows('sow', 'tomato', 25, 5),
  ];
  assertEquals(r6(b, signalsOf(b), kTaskTypes, cdfsOf(atBound), kCfg).length, 1);

  const overBound = [
    ...rows('sow', 'tomato', 23, 91),
    ...rows('sow', 'tomato', 24, 4),
    ...rows('sow', 'tomato', 25, 5),
  ];
  assertEquals(r6(b, signalsOf(b), kTaskTypes, cdfsOf(overBound), kCfg).length, 0);
});

Deno.test('a bimodal species is silent between its two peaks', () => {
  const b = bundle();
  // Spring sowing (weeks 8–12) then an autumn one (weeks 35–38). In week 24 the
  // cumulative share says "most have started" while nobody is sowing at all.
  const bimodal = [
    ...rows('sow', 'tomato', 8, 30),
    ...rows('sow', 'tomato', 12, 30),
    ...rows('sow', 'tomato', 35, 20),
    ...rows('sow', 'tomato', 38, 20),
  ];
  assertEquals(r6(b, signalsOf(b), kTaskTypes, cdfsOf(bimodal), kCfg).length, 0);
});

Deno.test('a thin sample never becomes a claim (k_reliab)', () => {
  const b = bundle();
  // 29 < k_reliab (30): publishable, but not enough to say "most".
  assertEquals(
    r6(b, signalsOf(b), kTaskTypes, cdfsOf(openWindow('sow', 'tomato', 29)), kCfg).length,
    0,
  );
  assertEquals(
    r6(b, signalsOf(b), kTaskTypes, cdfsOf(openWindow('sow', 'tomato', 30)), kCfg).length,
    1,
  );
});

Deno.test('below half started is not "most" yet', () => {
  const b = bundle();
  // 20 in week 10 (past) + 30 still to come in week 25 → F(24) = 0.4.
  const early = rows('sow', 'tomato', 10, 20);
  const late = rows('sow', 'tomato', 25, 30);
  assertEquals(r6(b, signalsOf(b), kTaskTypes, cdfsOf([...early, ...late]), kCfg).length, 0);

  // 30 early + 20 still to come → F(24) = 0.6 → fires, but below the 0.68 boost.
  const majority = [...rows('sow', 'tomato', 10, 30), ...rows('sow', 'tomato', 25, 20)];
  const out = r6(b, signalsOf(b), kTaskTypes, cdfsOf(majority), kCfg);
  assertEquals(out.length, 1);
  assertEquals(out[0].score, 1.0);
  assertEquals(out[0].messageParams.percent, 60);
});

Deno.test('a clear majority earns the score boost', () => {
  const b = bundle();
  // 35 early + 15 still to come → F(24) = 0.7 ≥ 0.68.
  const raw = [...rows('sow', 'tomato', 10, 35), ...rows('sow', 'tomato', 25, 15)];
  const out = r6(b, signalsOf(b), kTaskTypes, cdfsOf(raw), kCfg);

  assertEquals(out[0].score, 1.5);
  assertEquals(out[0].messageParams.percent, 70);
});

Deno.test('already done this season is not a suggestion', () => {
  const b = bundle({ tasks: [done('sow', '2026-04-01', 'p1')] });
  assertEquals(
    r6(b, signalsOf(b), kTaskTypes, cdfsOf(openWindow('sow', 'tomato', 40)), kCfg).length,
    0,
  );

  // Last season does not count — that is exactly the case R6 is for.
  const lastYear = bundle({ tasks: [done('sow', '2025-04-01', 'p1')] });
  assertEquals(
    r6(lastYear, signalsOf(lastYear), kTaskTypes, cdfsOf(openWindow('sow', 'tomato', 40)), kCfg)
      .length,
    1,
  );
});

Deno.test('doing it on one specimen answers for the whole species', () => {
  const b = bundle({
    plants: [plant('p1', 'tomato'), plant('p2', 'tomato')],
    tasks: [done('sow', '2026-04-01', 'p2')],
  });
  assertEquals(
    r6(b, signalsOf(b), kTaskTypes, cdfsOf(openWindow('sow', 'tomato', 40)), kCfg).length,
    0,
  );
});

Deno.test('three tomato plants are one card, not three', () => {
  const b = bundle({ plants: [plant('p3', 'tomato'), plant('p1', 'tomato'), plant('p2', 'tomato')] });
  const out = r6(b, signalsOf(b), kTaskTypes, cdfsOf(openWindow('sow', 'tomato', 40)), kCfg);

  assertEquals(out.length, 1);
  assertEquals(out[0].subjectKey, 'up:p1'); // lowest id — deterministic across runs
});

Deno.test('non-seasonal types have no curve to stand against', () => {
  const b = bundle();
  assertEquals(
    r6(b, signalsOf(b), kTaskTypes, cdfsOf(openWindow('water', 'tomato', 40)), kCfg).length,
    0,
  );
});

Deno.test('a private plant is never compared — it would be a group of one', () => {
  const b = bundle({ plants: [plant('p9', null, true)] });
  assertEquals(
    r6(b, signalsOf(b), kTaskTypes, cdfsOf(openWindow('sow', 'tomato', 40)), kCfg).length,
    0,
  );
});

Deno.test('the cohort is never swapped for another species', () => {
  const b = bundle(); // grows tomato
  assertEquals(
    r6(b, signalsOf(b), kTaskTypes, cdfsOf(openWindow('sow', 'apple', 40)), kCfg).length,
    0,
  );
});

Deno.test('alone it stays under the emit threshold — it needs a dry window', () => {
  const b = bundle();
  const signals = signalsOf(b); // no weather payload → no dry window
  const out = r6(b, signals, kTaskTypes, cdfsOf(openWindow('sow', 'tomato', 40)), kCfg);

  assertEquals(out[0].score < kCfg.engine.emit_threshold, true);
  assertEquals(applyGuards(out, signals, kCfg, kNow).length, 0);
});

Deno.test('cooldown holds the card back for 14 days', () => {
  const b = bundle({
    suggestionLog: [{
      guard_key: 'R6:sow',
      subject_key: 'up:p1',
      last_suggested_at: '2026-06-05T06:00:00Z', // 7 days ago
      dismissed_until: null,
    }],
  });
  const signals = signalsOf(b);
  // Score it past the threshold so only the cooldown can stop it.
  const out = r6(b, signals, kTaskTypes, cdfsOf(openWindow('sow', 'tomato', 40)), kCfg)
    .map((c) => ({ ...c, score: 5 }));

  assertEquals(applyGuards(out, signals, kCfg, kNow).length, 0);

  const old = bundle({
    suggestionLog: [{
      guard_key: 'R6:sow',
      subject_key: 'up:p1',
      last_suggested_at: '2026-05-01T06:00:00Z', // 42 days ago
      dismissed_until: null,
    }],
  });
  const oldSignals = signalsOf(old);
  const oldOut = r6(old, oldSignals, kTaskTypes, cdfsOf(openWindow('sow', 'tomato', 40)), kCfg)
    .map((c) => ({ ...c, score: 5 }));
  assertEquals(applyGuards(oldOut, oldSignals, kCfg, kNow).length, 1);
});

Deno.test('the running season is never a curve — a claim needs a finished one', () => {
  const b = bundle();
  // Only current-year rows: a running curve trends to 100 % by construction.
  const current = cdfsOf(rows('sow', 'tomato', 10, 40, 2026));
  assertEquals(current.size, 0);
  assertEquals(r6(b, signalsOf(b), kTaskTypes, current, kCfg).length, 0);
});

Deno.test('the finest level that clears k_privacy answers, and coarser never overrides', () => {
  const fine = cdfsOf(rows('sow', 'tomato', 10, 6), 'r7');
  const coarse = cdfsOf(rows('sow', 'tomato', 40, 900), 'r6');
  const resolved = resolveSeasonCdfs([fine, coarse], kCfg.thresholds.kPrivacy);

  assertEquals(resolved.get(cdfKey('sow', 'tomato'))!.resolution, 'r7');
  assertEquals(resolved.get(cdfKey('sow', 'tomato'))!.pooledTotal, 6);

  // Below k_privacy the level cannot answer, so the chain widens.
  const tooThin = cdfsOf(rows('sow', 'tomato', 10, 4), 'r7');
  const widened = resolveSeasonCdfs([tooThin, coarse], kCfg.thresholds.kPrivacy);
  assertEquals(widened.get(cdfKey('sow', 'tomato'))!.resolution, 'r6');
});

Deno.test('server nonsense is skipped, never thrown on', () => {
  const built = buildSeasonCdfs(
    [
      { task_type_id: 'sow', plant_id: 'tomato', year: 2025, iso_week: 10, first_user_count: 8 },
      { task_type_id: 'sow', plant_id: 'tomato', year: 2025, iso_week: 99, first_user_count: 5 },
      { task_type_id: 'sow', plant_id: 'tomato', year: 2025, iso_week: 12 }, // no count
      { plant_id: 'tomato', year: 2025, iso_week: 12, first_user_count: 3 }, // no type
      { task_type_id: 'sow', year: 2025, iso_week: 12, first_user_count: 3 }, // no cohort
    ],
    2026,
    'r7',
  );

  assertEquals(built.size, 1);
  assertEquals(built.get(cdfKey('sow', 'tomato'))!.pooledTotal, 8);
});
