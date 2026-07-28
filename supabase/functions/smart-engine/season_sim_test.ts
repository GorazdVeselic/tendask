// N8 — the season simulation (docs/m11/09 §plan testiranja motorja, point 2).
//
// Every other engine test fixes one runDate and asks whether a rule CAN fire.
// None of them can answer the question the product rests on: how often does it
// fire over a year? A rule that emits weekly for five months passes all 159 of
// them. So this drives the real handler across 365 consecutive days on one
// store, and the store is the point: `suggestion_log.last_suggested_at`,
// `dismissed_until`, live `suggestion` rows and `engine_run.last_push_date` are
// what hold a rule back, and they are written on day N and read on day N+1. A
// loop that rebuilt state each day would measure nothing and look green.

import { assertEquals } from 'jsr:@std/assert@1';
import { handleRequest } from './handler.ts';
import { SimDb } from './sim_db.ts';
import { kSeasonCalendar } from './testdata/season_calendar.ts';
import { tzOffsetSeconds, weatherPayload } from './synthetic_weather.ts';
import {
  type DoneTask,
  kCellR7,
  kTimeZone,
  kUserId,
  seedSimDb,
  subjectColumns,
} from './season_fixture.ts';
import { kDefaultEngine } from './config.ts';

const kUrl = 'https://example.supabase.co';
const kKey = 'service-key';
const kStartDay = '2026-01-01';
const kDays = 365;
// 07:00 UTC = 08:00 CET / 09:00 CEST — inside engine_dispatch's 07:00–12:00
// local window all year, and never on a day boundary.
const kRunHourUtc = 7;

// A seasonal job (R5 window, R6 community nudge, R2 anniversary, R7 chain step)
// is one decision per year. Measured: 1–4. Six leaves room for a window that
// straddles a cooldown without letting a rule become a weekly habit.
const kMaxSeasonalPerYear = 6;

// R3 is the cadence rule, and this ceiling is NOT a target — it is the measured
// high-water mark of an unresolved finding (N25 in 19-najdbe-med-izvedbo.md):
// an ignored cadence pair produces ~40–60 cards a year, because R3 has no
// per-season budget and no back-off for cards the user keeps ignoring. The cap
// is here so the number cannot grow unnoticed while the product decision is
// pending; it is meant to come DOWN, not to be raised.
const kMaxCadencePerYear = 70;

const maxFor = (ruleId: string) => ruleId === 'R3' ? kMaxCadencePerYear : kMaxSeasonalPerYear;

const kDayMs = 86_400_000;
const dayMs = (day: string) => Date.parse(day + 'T00:00:00Z');
const addDays = (day: string, n: number) =>
  new Date(dayMs(day) + n * kDayMs).toISOString().slice(0, 10);

interface Emission {
  day: string;
  ruleId: string;
  guardKey: string;
  subjectKey: string;
}

interface YearResult {
  emissions: Emission[];
  /** Day → the rule of the top-ranked candidate, which is the one pushed. */
  pushDays: string[];
  pushRules: string[];
  db: SimDb;
}

function request(): Request {
  return new Request('https://edge/smart-engine', {
    method: 'POST',
    headers: { authorization: `Bearer ${kKey}` },
    body: JSON.stringify({ user_ids: [kUserId] }),
  });
}

/** Runs one simulated year. [act] models a gardener who does the top suggestion
 * the next day, which is the other half of "does not spam": acting has to quiet
 * the engine down, not just the cooldown. */
async function runYear(
  opts: { seed: number; act?: boolean } = { seed: 1 },
): Promise<YearResult> {
  const db = seedSimDb();
  const emissions: Emission[] = [];
  const pushDays: string[] = [];
  const pushRules: string[] = [];
  let acted = 0;

  for (let i = 0; i < kDays; i++) {
    const day = addDays(kStartDay, i);
    const nowUtc = new Date(dayMs(day) + kRunHourUtc * 3_600_000);
    db.now = nowUtc;
    // Pre-seeded so the engine takes its cache hit and never reaches the
    // network; this is exactly the row a real run would have written.
    db.table('weather_cache').push({
      h3_r7: kCellR7,
      date: day,
      payload: weatherPayload(day, tzOffsetSeconds(nowUtc, kTimeZone), opts.seed),
    });

    const suggestions = db.table('suggestion');
    const before = suggestions.length;
    let pushed = false;
    const res = await handleRequest(request(), {
      env: { url: kUrl, serviceKey: kKey },
      makeDb: () => db,
      now: () => nowUtc,
      latLngOf: () => [46.05, 14.5],
      sendPush: () => {
        pushed = true;
        return Promise.resolve(true);
      },
      projectId: () => 'proj',
    });
    const json = await res.json();
    assertEquals(json.results?.[0]?.error, undefined, `day ${day} failed`);
    const fresh = suggestions.slice(before);
    if (pushed) {
      pushDays.push(day);
      // maybePush sends ranked[0], which emit() inserted first.
      pushRules.push(fresh[0].rule_id);
    }
    for (const row of fresh) {
      emissions.push({
        day,
        ruleId: row.rule_id,
        guardKey: row.plant_task_rule_id ?? `${row.rule_id}:${row.task_type_id}`,
        subjectKey: row.subject_key,
      });
    }
    if (opts.act && fresh.length > 0) {
      const top = fresh[0];
      const done: DoneTask = {
        day: addDays(day, 1),
        type: top.task_type_id,
        subject: top.subject_key,
      };
      db.table('task').push({
        id: `t-act-${acted++}`,
        user_id: kUserId,
        task_type_id: done.type,
        date: done.day + 'T10:00:00Z',
        status: 'done',
        deleted: false,
        task_subject: [subjectColumns(done.subject)],
        task_reminder: [],
        task_supply: [],
      });
    }
  }
  return { emissions, pushDays, pushRules, db };
}

function countBy<T>(items: T[], key: (item: T) => string): Map<string, number> {
  const out = new Map<string, number>();
  for (const item of items) {
    const k = key(item);
    out.set(k, (out.get(k) ?? 0) + 1);
  }
  return out;
}

function sortedEntries(counts: Map<string, number>): [string, number][] {
  return [...counts.entries()].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]));
}

/** The human-readable artefact: what a gardener would have been shown, month by
 * month, plus the per-guard-key yearly totals the caps below are about. */
function buildCalendar(result: YearResult): string {
  const perDay = countBy(result.emissions, (e) => e.day);
  const maxPerDay = Math.max(0, ...perDay.values());
  const lines = [
    `# Koledar predlogov ${kStartDay} → ${addDays(kStartDay, kDays - 1)}`,
    '# Vrt: trata + jablana + paradižnik + malina + bazilika (rastlinjak).',
    '# Uporabnik v tem teku ne izvede nobenega predloga — zgornja meja emisij.',
    `# Skupaj: ${result.emissions.length} predlogov · ${result.pushDays.length} pushov ` +
    `· največ na dan: ${maxPerDay}`,
    '# Pushi po pravilu: ' +
    sortedEntries(countBy(result.pushRules, (r) => r)).map(([r, n]) => `${r} ×${n}`).join(' · '),
    '',
    '## Po mesecih',
  ];

  for (let month = 1; month <= 12; month++) {
    const tag = `${kStartDay.slice(0, 4)}-${String(month).padStart(2, '0')}`;
    const inMonth = result.emissions.filter((e) => e.day.startsWith(tag));
    if (inMonth.length === 0) {
      lines.push(`${tag}  —`);
      continue;
    }
    const counts = sortedEntries(
      countBy(inMonth, (e) => `${e.ruleId} ${e.guardKey}/${e.subjectKey}`),
    );
    lines.push(`${tag}  ${counts.map(([k, n]) => `${k} ×${n}`).join(' · ')}`);
  }

  lines.push('', '## Na leto, po straži (guard_key/subject)');
  for (
    const [key, n] of sortedEntries(
      countBy(result.emissions, (e) => `${e.ruleId} ${e.guardKey}/${e.subjectKey}`),
    )
  ) {
    lines.push(`${String(n).padStart(4)}× ${key}`);
  }
  return lines.join('\n');
}

// ---------- the measurement ----------

Deno.test('season simulation: the year of suggestions matches the golden calendar', async () => {
  const result = await runYear({ seed: 1 });
  const calendar = buildCalendar(result);
  if (calendar !== kSeasonCalendar) {
    console.log('\n----- ACTUAL CALENDAR (paste into testdata/season_calendar.ts) -----');
    console.log(calendar);
    console.log('----- END -----\n');
  }
  assertEquals(calendar, kSeasonCalendar);
});

Deno.test('season simulation: no rule outstays its welcome', async () => {
  for (const seed of [1, 2, 3]) {
    const { emissions, pushDays } = await runYear({ seed });

    // A single agronomic decision (this guard key, this plant) may be raised at
    // most this often in a year. Above it the card stops being a reminder and
    // becomes noise the user learns to swipe away.
    const perGuardKey = countBy(emissions, (e) => `${e.ruleId} ${e.guardKey}/${e.subjectKey}`);
    for (const [key, n] of sortedEntries(perGuardKey)) {
      const max = maxFor(key.slice(0, key.indexOf(' ')));
      if (n > max) {
        throw new Error(
          `seed ${seed}: ${key} emitted ${n}× in a year (max ${max}). Full tally:\n` +
            sortedEntries(perGuardKey).map(([k, c]) => `  ${c}× ${k}`).join('\n'),
        );
      }
    }

    // The band is the shelf the client renders; more than this on one day means
    // dedupAndRank stopped capping.
    const perDay = countBy(emissions, (e) => e.day);
    for (const [day, n] of perDay) {
      assertEquals(n <= kDefaultEngine.band_max_active, true, `seed ${seed}: ${n} on ${day}`);
    }

    // Step 8c: at most one push per local day, for the top candidate only.
    assertEquals(new Set(pushDays).size, pushDays.length, `seed ${seed}: two pushes in one day`);
  }
});

Deno.test('season simulation: doing the task quiets the engine', async () => {
  const passive = await runYear({ seed: 1 });
  const responsive = await runYear({ seed: 1, act: true });
  // Acting must not cost the user MORE cards than ignoring everything: if it
  // did, the cooldown-after-execution guard (5d) would be inverted.
  assertEquals(
    responsive.emissions.length <= passive.emissions.length,
    true,
    `responsive ${responsive.emissions.length} > passive ${passive.emissions.length}`,
  );
});
