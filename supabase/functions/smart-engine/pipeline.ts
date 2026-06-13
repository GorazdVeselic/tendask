// Shared candidate pipeline (docs/m11/03 §Cevovod steps 5–8): guards → dedup →
// rank → emit. Rules feed candidates in; this writes the surviving ones to
// `suggestion` and stamps `suggestion_log`. R4 enrichment + housekeeping
// (expired/dismissed→log/retention) layer on in M11.11.
// deno-lint-ignore-file no-explicit-any
import type { Candidate, EngineConfig, UserBundle } from './types.ts';
import type { Signals } from './signals.ts';
import { guardKeyOf } from './candidate.ts';
import { evaluateWeatherGuard } from './guards.ts';
import { dayDiff } from './dates.ts';

const kCooldownDoneMinDays = 3; // docs/m11/03 §Cevovod 5d

/** Steps 5a–5h, fail-fast per candidate. Cooldown/dismiss state is keyed by the
 * fine-grained guard key (docs/m11/03 §Guard key). */
export function applyGuards(
  candidates: Candidate[],
  signals: Signals,
  cfg: EngineConfig,
  nowUtc: Date,
): Candidate[] {
  const { state, history, eligibility, weather, localToday, noLocation } = signals;
  const k = cfg.engine;
  const now = nowUtc.getTime();
  return candidates.filter((c) => {
    const guardKey = guardKeyOf(c);
    // a. subject still owned.
    if (!eligibility.subjectExists(c.subjectKey)) return false;
    // b. dismissed (season mute or "not interested" forever).
    if (state.dismissed(guardKey, c.subjectKey)) return false;
    // c. cooldown since the last suggestion of this guard key + subject.
    const lastAt = state.lastSuggestedAt(guardKey, c.subjectKey);
    if (lastAt != null && now - Date.parse(lastAt) < c.cooldownDays * 86_400_000) return false;
    // d. cooldown after a recent execution (cadence types: max(3, cadence/2)).
    const lastDone = history.lastDone(c.subjectKey, c.taskTypeId);
    if (lastDone != null) {
      const cad = history.cadenceDays(c.subjectKey, c.taskTypeId);
      if (cad != null) {
        const cooldownDone = Math.max(kCooldownDoneMinDays, cad / 2);
        if (dayDiff(localToday, lastDone) < cooldownDone) return false;
      }
    }
    // e. dedup vs a planned (waiting) task of the same type+subject.
    if (state.planned(c.subjectKey, c.taskTypeId, k.dedup_planned_within_days)) return false;
    // f. cross-run dedup vs an active suggestion of the same type+subject.
    if (state.activeSuggestion(c.taskTypeId, c.subjectKey)) return false;
    // g. weather guard (null for R2/R3 without a rule → passes).
    const guard = evaluateWeatherGuard(c.weatherGuard, weather, cfg.weatherThresholds, {
      protectedSubject: eligibility.isProtectedSubject(c.subjectKey),
      noLocation,
      frostGate: false, // R5/R7 set this in M11.10
    });
    if (!guard.pass) return false;
    // h. below the emit threshold.
    return c.score >= k.emit_threshold;
  });
}

/** Steps 6–7: keep the highest score per (taskType, subject), then rank and cap
 * to band_max_active. Ties break on rule_id then subject_key for determinism. */
export function dedupAndRank(candidates: Candidate[], cfg: EngineConfig): Candidate[] {
  const best = new Map<string, Candidate>();
  for (const c of candidates) {
    const key = c.taskTypeId + '|' + c.subjectKey;
    const cur = best.get(key);
    if (!cur || c.score > cur.score) best.set(key, c);
  }
  return [...best.values()]
    .sort((a, b) =>
      b.score - a.score ||
      a.ruleId.localeCompare(b.ruleId) ||
      a.subjectKey.localeCompare(b.subjectKey)
    )
    .slice(0, cfg.engine.band_max_active);
}

/** Step 8a/8b: insert each surviving candidate into `suggestion` and stamp
 * `suggestion_log.last_suggested_at`. The log upsert sets updated_at explicitly
 * (PG default fires only on INSERT) and omits dismissed_until so a prior mute
 * survives the merge (docs/m11/04 §4.3 gotcha). */
export async function emit(
  db: any,
  bundle: UserBundle,
  candidates: Candidate[],
  nowUtc: Date,
): Promise<number> {
  if (candidates.length === 0) return 0;
  const userId = bundle.profile.user_id;
  const nowIso = nowUtc.toISOString();
  const rows = candidates.map((c) => ({
    id: crypto.randomUUID(),
    user_id: userId,
    rule_id: c.ruleId,
    plant_task_rule_id: c.plantTaskRuleId,
    task_type_id: c.taskTypeId,
    user_plant_id: c.userPlantId,
    area_id: c.areaId,
    subject_key: c.subjectKey,
    message_key: c.messageKey,
    message_params: c.messageParams,
    score: c.score,
    status: 'new',
    valid_until: c.validUntil,
  }));
  const ins = await db.from('suggestion').insert(rows);
  if (ins.error) throw ins.error;

  const logRows = candidates.map((c) => ({
    user_id: userId,
    guard_key: guardKeyOf(c),
    subject_key: c.subjectKey,
    last_suggested_at: nowIso,
    updated_at: nowIso,
  }));
  const up = await db.from('suggestion_log')
    .upsert(logRows, { onConflict: 'user_id,guard_key,subject_key' });
  if (up.error) throw up.error;
  return rows.length;
}
