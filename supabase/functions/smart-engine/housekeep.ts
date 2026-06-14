// Housekeeping (docs/m11/03 §Cevovod step 2): runs before signals each user run.
// 2a dismissed → suggestion_log mute, 2c expire past valid_until, 2d expire
// orphaned subject, 2e retention soft-delete. The client (faza D) writes the
// status changes this consumes; until then it mostly no-ops, but it must exist so
// a real dismiss is honoured the same run (the new mute is reflected in-memory).
// deno-lint-ignore-file no-explicit-any
import type {
  ClimateSignals,
  EngineConfig,
  PlantTaskRule,
  SuggestionLogRow,
  UserBundle,
} from './types.ts';
import { guardKey } from './candidate.ts';
import { resolveWindow } from './rules_agro.ts';
import { addDaysStr } from './dates.ts';

// dismiss_scope='season' mute length per engine rule (docs/m11/03 §R* DISMISS).
// R5 uses the regionalised window end instead (computed below); this covers the
// rules with no window (R1–R3/R6) and R7's event-driven chain.
const kDismissDays: Record<string, number> = { R1: 7, R2: 60, R3: 10, R6: 90, R7: 14 };
const kDefaultDismissDays = 30;

export interface SuggestionRow {
  id: string;
  rule_id: string;
  plant_task_rule_id: string | null;
  task_type_id: string;
  subject_key: string;
  status: string;
  dismiss_scope: string;
  valid_until: string;
  updated_at: string;
}

export interface HousekeepPlan {
  expireIds: string[]; // 2c + 2d: status 'new' → 'expired'
  retentionIds: string[]; // 2e: terminal + old → deleted = true
  newMutes: SuggestionLogRow[]; // 2a: dismissed without an existing log mute
}

function dismissedUntil(
  row: SuggestionRow,
  climate: ClimateSignals,
  ruleById: Map<string, PlantTaskRule>,
  cfg: EngineConfig,
  localToday: string,
): string {
  if (row.dismiss_scope === 'forever') return 'infinity';
  const rule = row.plant_task_rule_id ? ruleById.get(row.plant_task_rule_id) : undefined;
  if (
    rule != null && (rule.timing_anchor === 'month_window' || rule.timing_anchor === 'frost_offset')
  ) {
    const win = resolveWindow(rule, climate, cfg, Number(localToday.slice(0, 4)));
    if (win.end != null) return win.end + 'T23:59:59Z'; // mute until the window closes
  }
  const days = kDismissDays[row.rule_id] ?? kDefaultDismissDays;
  return addDaysStr(row.updated_at.slice(0, 10), days) + 'T00:00:00Z';
}

/** Pure planner — decides the writes from the loaded suggestion rows. */
export function planHousekeeping(
  rows: SuggestionRow[],
  logKeys: Set<string>,
  ownedSubjects: Set<string>,
  localToday: string,
  cutoffMs: number,
  climate: ClimateSignals,
  ruleById: Map<string, PlantTaskRule>,
  cfg: EngineConfig,
): HousekeepPlan {
  const plan: HousekeepPlan = { expireIds: [], retentionIds: [], newMutes: [] };
  for (const row of rows) {
    if (row.status === 'new') {
      const subjectGone =
        !(row.subject_key.startsWith('cat:') || ownedSubjects.has(row.subject_key));
      if (row.valid_until < localToday || subjectGone) plan.expireIds.push(row.id);
      continue;
    }
    // terminal (planned/dismissed/logged/expired)
    if (Date.parse(row.updated_at) < cutoffMs) plan.retentionIds.push(row.id);
    if (row.status === 'dismissed') {
      const gk = guardKey(row.plant_task_rule_id, row.rule_id, row.task_type_id);
      if (!logKeys.has(gk + '|' + row.subject_key)) {
        plan.newMutes.push({
          guard_key: gk,
          subject_key: row.subject_key,
          last_suggested_at: null,
          dismissed_until: dismissedUntil(row, climate, ruleById, cfg, localToday),
        });
      }
    }
  }
  return plan;
}

/** Executor — loads the user's live suggestions, applies the plan, and reflects
 * new mutes into bundle.suggestionLog so this run's guards honour a just-made
 * dismiss. Every UPDATE stamps updated_at (PG default fires only on INSERT). */
export async function housekeep(
  db: any,
  bundle: UserBundle,
  localToday: string,
  nowUtc: Date,
  climate: ClimateSignals,
  rules: PlantTaskRule[],
  cfg: EngineConfig,
): Promise<void> {
  const userId = bundle.profile.user_id;
  const res = await db.from('suggestion')
    .select(
      'id,rule_id,plant_task_rule_id,task_type_id,subject_key,status,dismiss_scope,valid_until,updated_at',
    )
    .eq('user_id', userId).eq('deleted', false)
    .order('updated_at', { ascending: false }).limit(1000);
  if (res.error) throw res.error;
  const rows: SuggestionRow[] = res.data ?? [];
  if (rows.length === 0) return;

  const ownedSubjects = new Set<string>([
    ...bundle.plants.map((p) => 'up:' + p.id),
    ...bundle.areas.map((a) => 'ar:' + a.id),
  ]);
  const logKeys = new Set(bundle.suggestionLog.map((l) => l.guard_key + '|' + l.subject_key));
  const ruleById = new Map(rules.map((r) => [r.id, r]));
  const cutoffMs = nowUtc.getTime() - cfg.engine.suggestion_retention_days * 86_400_000;
  const plan = planHousekeeping(
    rows,
    logKeys,
    ownedSubjects,
    localToday,
    cutoffMs,
    climate,
    ruleById,
    cfg,
  );
  const nowIso = nowUtc.toISOString();

  if (plan.expireIds.length > 0) {
    const up = await db.from('suggestion')
      .update({ status: 'expired', updated_at: nowIso })
      .in('id', plan.expireIds);
    if (up.error) throw up.error;
  }
  if (plan.retentionIds.length > 0) {
    const up = await db.from('suggestion')
      .update({ deleted: true, updated_at: nowIso })
      .in('id', plan.retentionIds);
    if (up.error) throw up.error;
  }
  if (plan.newMutes.length > 0) {
    const muteRows = plan.newMutes.map((m) => ({
      user_id: userId,
      guard_key: m.guard_key,
      subject_key: m.subject_key,
      dismissed_until: m.dismissed_until,
      updated_at: nowIso,
    }));
    const up = await db.from('suggestion_log')
      .upsert(muteRows, { onConflict: 'user_id,guard_key,subject_key' });
    if (up.error) throw up.error;
    for (const m of plan.newMutes) bundle.suggestionLog.push(m);
  }
}
