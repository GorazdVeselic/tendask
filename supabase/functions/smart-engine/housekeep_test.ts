import { assertEquals } from 'jsr:@std/assert@1';
import { planHousekeeping, type SuggestionRow } from './housekeep.ts';
import {
  kDefaultCommunityThresholds,
  kDefaultEngine,
  kDefaultFrost,
  kDefaultThresholds,
  kMuteForeverDate,
} from './config.ts';
import type { ClimateSignals, EngineConfig, PlantTaskRule, SuggestionLogRow } from './types.ts';

const kCfg: EngineConfig = {
  enabled: true,
  engine: kDefaultEngine,
  weatherThresholds: kDefaultThresholds,
  frostDefaults: kDefaultFrost,
  thresholds: kDefaultCommunityThresholds,
};

const kClimate: ClimateSignals = {
  lastFrostDate: '2026-04-06',
  firstFrostDate: '2026-11-07',
  bucket: 'e1_t6',
  lastFrostWeek: 15,
  firstFrostWeek: 45,
  growingSeasonDays: 215,
  hemisphereSouth: false,
  fromDefaults: false,
};

const kToday = '2026-06-12';
const kCutoffMs = Date.parse('2025-06-12T00:00:00Z'); // retention boundary (~365 days)

let seq = 0;
function row(o: Partial<SuggestionRow>): SuggestionRow {
  return {
    id: 's' + (++seq),
    rule_id: o.rule_id ?? 'R3',
    plant_task_rule_id: o.plant_task_rule_id ?? null,
    task_type_id: o.task_type_id ?? 'treat',
    subject_key: o.subject_key ?? 'up:p1',
    status: o.status ?? 'new',
    dismiss_scope: o.dismiss_scope ?? 'season',
    valid_until: o.valid_until ?? '2026-06-30',
    updated_at: o.updated_at ?? '2026-06-10T07:00:00+00:00',
  };
}

/** The log row emit stamps for every suggestion it writes: cooldown only, no mute. */
function emitted(key: string, dismissedUntil: string | null = null): SuggestionLogRow {
  const [guard_key, subject_key] = key.split('|');
  return {
    guard_key,
    subject_key,
    last_suggested_at: '2026-06-10T03:00:00+00:00',
    dismissed_until: dismissedUntil,
  };
}

function plan(rows: SuggestionRow[], log: SuggestionLogRow[] = []) {
  return planHousekeeping(
    rows,
    new Map(log.map((l) => [l.guard_key + '|' + l.subject_key, l])),
    new Set(['up:p1']),
    kToday,
    kCutoffMs,
    kClimate,
    new Map<string, PlantTaskRule>(),
    kCfg,
  );
}

Deno.test('housekeep 2c: a new suggestion past valid_until expires', () => {
  const r = row({ status: 'new', valid_until: '2026-06-01' });
  assertEquals(plan([r]).expireIds, [r.id]);
});

Deno.test('housekeep 2d: a new suggestion for a removed subject expires', () => {
  const r = row({ status: 'new', subject_key: 'up:gone', valid_until: '2026-06-30' });
  assertEquals(plan([r]).expireIds, [r.id]);
});

Deno.test('housekeep: a valid new suggestion for an owned subject is left alone', () => {
  const p = plan([row({ status: 'new', subject_key: 'up:p1', valid_until: '2026-06-30' })]);
  assertEquals(p.expireIds, []);
  assertEquals(p.retentionIds, []);
});

Deno.test('housekeep 2e: a terminal row older than retention is soft-deleted', () => {
  const r = row({ status: 'planned', updated_at: '2024-01-01T00:00:00+00:00' });
  assertEquals(plan([r]).retentionIds, [r.id]);
});

Deno.test('housekeep 2a: dismissed forever → far-future mute, not "infinity"', () => {
  const p = plan([row({ status: 'dismissed', dismiss_scope: 'forever', subject_key: 'up:p1' })]);
  assertEquals(p.newMutes.length, 1);
  assertEquals(p.newMutes[0].dismissed_until, kMuteForeverDate);
  assertEquals(p.newMutes[0].guard_key, 'R3:treat');
  // The client parses this column; 'infinity' would throw and freeze the pull.
  assertEquals(Number.isNaN(Date.parse(p.newMutes[0].dismissed_until!)), false);
});

Deno.test('housekeep 2a: dismissed season → updated_at + dismissDays mute', () => {
  const p = plan([
    row({ status: 'dismissed', rule_id: 'R3', updated_at: '2026-06-10T07:00:00+00:00' }),
  ]);
  assertEquals(p.newMutes.length, 1);
  assertEquals(p.newMutes[0].dismissed_until, '2026-06-20T00:00:00Z'); // +10 days (R3)
});

Deno.test('housekeep 2a: dismissing R6 mutes it for the rest of that season', () => {
  // R6 has no rule window, and a fixed day count would either expire inside the
  // season or bleed into the next one.
  const p = plan([
    row({ status: 'dismissed', rule_id: 'R6', updated_at: '2026-06-10T07:00:00+00:00' }),
  ]);
  assertEquals(p.newMutes[0].dismissed_until, '2026-12-31T23:59:59Z');

  // Anchored to the dismissal, not to the run: a December dismissal must not
  // grow into next season when housekeeping runs again in January.
  const december = plan([
    row({ status: 'dismissed', rule_id: 'R6', updated_at: '2026-12-20T07:00:00+00:00' }),
  ], [emitted('R6:treat|up:p1', '2026-12-31T23:59:59Z')]);
  assertEquals(december.newMutes.length, 0);
});

Deno.test('housekeep 2a: the log row emit wrote does not block the mute', () => {
  // Every dismissed suggestion was emitted first, so its guard key is always in
  // the log — keying on row existence muted nothing at all.
  const p = plan(
    [row({ status: 'dismissed', subject_key: 'up:p1' })],
    [emitted('R3:treat|up:p1')],
  );
  assertEquals(p.newMutes.length, 1);
  assertEquals(p.newMutes[0].dismissed_until, '2026-06-20T00:00:00Z');
  // The cooldown stamp survives the merge (the upsert omits it, so must the plan).
  assertEquals(p.newMutes[0].last_suggested_at, '2026-06-10T03:00:00+00:00');
});

Deno.test('housekeep 2a: a mute that still covers the dismissal is not rewritten', () => {
  const p = plan(
    [row({ status: 'dismissed', subject_key: 'up:p1' })],
    [emitted('R3:treat|up:p1', '2026-06-20T00:00:00Z')], // exactly what this run computes
  );
  assertEquals(p.newMutes.length, 0);
});

Deno.test('housekeep 2a: a legacy "infinity" mute is never shortened', () => {
  const p = plan(
    [row({ status: 'dismissed', subject_key: 'up:p1' })],
    [emitted('R3:treat|up:p1', 'infinity')],
  );
  assertEquals(p.newMutes.length, 0);
});

Deno.test('housekeep 2a: an elapsed mute is refreshed by a new dismissal', () => {
  const p = plan(
    [row({ status: 'dismissed', subject_key: 'up:p1' })],
    [emitted('R3:treat|up:p1', '2026-01-01T00:00:00Z')],
  );
  assertEquals(p.newMutes.length, 1);
  assertEquals(p.newMutes[0].dismissed_until, '2026-06-20T00:00:00Z');
});

Deno.test('housekeep 2a: two dismissals of one guard key mute once, to the later end', () => {
  const p = plan([
    row({ status: 'dismissed', updated_at: '2026-06-10T07:00:00+00:00' }),
    row({ status: 'dismissed', updated_at: '2026-06-02T07:00:00+00:00' }),
  ]);
  assertEquals(p.newMutes.length, 1);
  assertEquals(p.newMutes[0].dismissed_until, '2026-06-20T00:00:00Z');
});
