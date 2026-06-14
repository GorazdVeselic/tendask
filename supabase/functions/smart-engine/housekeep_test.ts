import { assertEquals } from 'jsr:@std/assert@1';
import { planHousekeeping, type SuggestionRow } from './housekeep.ts';
import { kDefaultEngine, kDefaultFrost, kDefaultThresholds } from './config.ts';
import type { ClimateSignals, EngineConfig, PlantTaskRule } from './types.ts';

const kCfg: EngineConfig = {
  engine: kDefaultEngine,
  weatherThresholds: kDefaultThresholds,
  frostDefaults: kDefaultFrost,
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

function plan(rows: SuggestionRow[], logKeys = new Set<string>()) {
  return planHousekeeping(
    rows,
    logKeys,
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

Deno.test('housekeep 2a: dismissed forever → infinity mute', () => {
  const p = plan([row({ status: 'dismissed', dismiss_scope: 'forever', subject_key: 'up:p1' })]);
  assertEquals(p.newMutes.length, 1);
  assertEquals(p.newMutes[0].dismissed_until, 'infinity');
  assertEquals(p.newMutes[0].guard_key, 'R3:treat');
});

Deno.test('housekeep 2a: dismissed season → updated_at + dismissDays mute', () => {
  const p = plan([
    row({ status: 'dismissed', rule_id: 'R3', updated_at: '2026-06-10T07:00:00+00:00' }),
  ]);
  assertEquals(p.newMutes.length, 1);
  assertEquals(p.newMutes[0].dismissed_until, '2026-06-20T00:00:00Z'); // +10 days (R3)
});

Deno.test('housekeep 2a: a dismissal already in the log is not re-muted', () => {
  const p = plan(
    [row({ status: 'dismissed', subject_key: 'up:p1' })],
    new Set(['R3:treat|up:p1']),
  );
  assertEquals(p.newMutes.length, 0);
});
