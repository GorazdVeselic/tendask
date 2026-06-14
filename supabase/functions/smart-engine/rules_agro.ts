// Agronomy rules R5 (seasonal windows: month_window + frost_offset) and R7
// (seedling chain: growth_stage). Both feed the shared pipeline (guards → rank →
// emit). Window resolution regionalises ISO-week windows by the user's climate
// and anchors frost windows to local frost dates (docs/m11/03 §R5/§R7, 01 §0,
// 07 §7.3). R1 reinforcement (+weather score) is read inline via isDryWindow.

import type {
  Candidate,
  ClimateSignals,
  EngineConfig,
  PlantTaskRule,
  TaskTypeMeta,
  UserBundle,
} from './types.ts';
import type { EligibilitySignals, Signals } from './signals.ts';
import { dryWindowBonus, splitSubjectKey, subjectLabelParams } from './candidate.ts';
import { addDaysStr, dayDiff, doyToDateStr, isoWeek, isoWeekMonday } from './dates.ts';

export interface ResolvedWindow {
  start: string | null; // null → rule does not apply (south hemisphere / frost-free)
  end: string | null;
  anchor: string | null; // 'last_frost' | 'first_frost' for frost_offset, else null
}

function clamp(n: number, lo: number, hi: number): number {
  return Math.max(lo, Math.min(hi, n));
}

function deriveReg(startWeek: number): 'spring' | 'autumn' | 'none' {
  if (startWeek <= 6) return 'none'; // winter dormancy — not frost-sensitive (01 §0)
  return startWeek <= 26 ? 'spring' : 'autumn';
}

// Regionalisation baseline = the safety-adjusted ISO week of the DEFAULT frost
// doy, so a user on the default bucket (or with no climate profile) yields Δ=0
// (07 §7.3 l.107). The +/-frost_safety_days offset cancels in the user−baseline
// subtraction, so comparing adjusted weeks is consistent.
function baselineWeeks(cfg: EngineConfig, year: number): { spring: number; autumn: number } {
  const safety = cfg.engine.frost_safety_days;
  return {
    spring: isoWeek(addDaysStr(doyToDateStr(year, cfg.frostDefaults.last_frost_doy), safety)),
    autumn: isoWeek(addDaysStr(doyToDateStr(year, cfg.frostDefaults.first_frost_doy), -safety)),
  };
}

/** Regionalise an ISO-week window (month_window + cadence_only season gates).
 * Shifts spring/autumn windows by the user's frost week (clamped ±4); returns
 * null when the window cannot apply (southern hemisphere — the 26-week shift
 * exceeds the clamp, 07 §7.3, decision S2). */
export function regionalizedWeekWindow(
  startWeek: number,
  endWeek: number,
  regionalize: string | undefined,
  climate: ClimateSignals,
  cfg: EngineConfig,
  year: number,
): { start: string; end: string } | null {
  if (climate.hemisphereSouth) return null;
  const reg = regionalize ?? deriveReg(startWeek);
  const base = baselineWeeks(cfg, year);
  let delta = 0;
  if (reg === 'spring') {
    delta = clamp((climate.lastFrostWeek ?? base.spring) - base.spring, -4, 4);
  } else if (reg === 'autumn') {
    delta = clamp((climate.firstFrostWeek ?? base.autumn) - base.autumn, -4, 4);
  }
  return {
    start: isoWeekMonday(year, startWeek + delta),
    end: addDaysStr(isoWeekMonday(year, endWeek + delta), 6), // Sunday of the end week
  };
}

/** Resolve a rule's window to concrete dates for the given climate + year.
 * month_window regionalises by frost week (clamped ±4); frost_offset anchors to a
 * local frost date. Returns null bounds when the rule must be skipped. */
export function resolveWindow(
  rule: PlantTaskRule,
  climate: ClimateSignals,
  cfg: EngineConfig,
  year: number,
): ResolvedWindow {
  const w = rule.window;
  if (rule.timing_anchor === 'month_window') {
    const win = regionalizedWeekWindow(
      Number(w.start_week),
      Number(w.end_week),
      w.regionalize as string | undefined,
      climate,
      cfg,
      year,
    );
    if (win == null) return { start: null, end: null, anchor: null };
    return { start: win.start, end: win.end, anchor: null };
  }
  if (rule.timing_anchor === 'frost_offset') {
    const anchor = w.anchor as string;
    const anchorDate = anchor === 'first_frost' ? climate.firstFrostDate : climate.lastFrostDate;
    if (anchorDate == null) return { start: null, end: null, anchor }; // frost-free → skip
    return {
      start: addDaysStr(anchorDate, Number(w.offset_min_days)),
      end: addDaysStr(anchorDate, Number(w.offset_max_days)),
      anchor,
    };
  }
  return { start: null, end: null, anchor: null }; // growth_stage → handled by r7
}

/** Plant-scoped (ref_id, task_type) pairs — a category rule skips any plant that
 * has its own override for the same task type (01 §B override semantics). */
function plantOverrideSet(rules: PlantTaskRule[]): Set<string> {
  const s = new Set<string>();
  for (const r of rules) {
    if (r.scope === 'plant') s.add(r.ref_id + '|' + r.task_type_id);
  }
  return s;
}

/** Subject keys a rule applies to: lawn category → lawn areas; other categories →
 * plants of that category (minus overridden ones); plant scope → that plant. */
function subjectsForRule(
  rule: PlantTaskRule,
  eligibility: EligibilitySignals,
  overrides: Set<string>,
): string[] {
  if (rule.scope === 'plant') {
    return eligibility.plantsById(rule.ref_id).map((p) => 'up:' + p.id);
  }
  if (rule.ref_id === 'lawn') {
    return eligibility.areasByType('lawn').map((a) => 'ar:' + a.id);
  }
  return eligibility.plantsByCategory(rule.ref_id)
    .filter((p) => !(p.plant_id != null && overrides.has(p.plant_id + '|' + rule.task_type_id)))
    .map((p) => 'up:' + p.id);
}

/** R5 — seasonal window from a plant_task_rule (month_window or frost_offset). */
export function r5(
  bundle: UserBundle,
  rules: PlantTaskRule[],
  signals: Signals,
  taskTypes: Map<string, TaskTypeMeta>,
  cfg: EngineConfig,
): Candidate[] {
  const { climate, history, eligibility, weather, localToday } = signals;
  const k = cfg.engine;
  const year = Number(localToday.slice(0, 4));
  const overrides = plantOverrideSet(rules);
  const out: Candidate[] = [];
  for (const rule of rules) {
    if (rule.timing_anchor !== 'month_window' && rule.timing_anchor !== 'frost_offset') continue;
    // climate_bucket_filter (rule-level): skip the whole rule if the bucket is excluded.
    const filter = rule.window.climate_bucket_filter;
    if (
      Array.isArray(filter) && filter.length > 0 &&
      !(climate.bucket != null && filter.includes(climate.bucket))
    ) continue;
    const win = resolveWindow(rule, climate, cfg, year);
    if (win.start == null || win.end == null) continue;
    const windowOpen = win.start; // calendar open, before any frost-gate clamp
    let start = win.start;
    // frost_gate climatological floor: never schedule before the last frost (R5).
    if (rule.frost_gate && climate.lastFrostDate != null && climate.lastFrostDate > start) {
      start = climate.lastFrostDate;
    }
    if (localToday < start || localToday > win.end) continue;
    const type = taskTypes.get(rule.task_type_id);
    // overwinter / first_frost rules: lateness = dead plant → +2.0 base, so they
    // emit without a weather window (docs/m11/03 §R5 special case).
    const base = win.anchor === 'first_frost' ? k.score_frost_protect_boost : k.score_season_window;
    const len = dayDiff(win.end, start);
    const closingStart = addDaysStr(win.end, -Math.ceil(len / 4));
    const frostParam = rule.frost_gate && climate.lastFrostDate != null
      ? { frost_date: climate.lastFrostDate }
      : {};
    for (const subjectKey of subjectsForRule(rule, eligibility, overrides)) {
      // Already done since this year's window opened → cooldown-after keeps it
      // silent. Compared to the calendar open (not the frost-gated start), so a
      // task done before the gate still counts as done in the window (03 §R5).
      const lastDone = history.lastDone(subjectKey, rule.task_type_id);
      if (lastDone != null && lastDone >= windowOpen) continue;
      const dry = dryWindowBonus(
        weather,
        cfg.weatherThresholds,
        rule.task_type_id,
        type?.weather_sensitive ?? false,
        eligibility.isProtectedSubject(subjectKey),
        k.score_weather_window,
      );
      const anniversary = history.lastDoneYearAgo(subjectKey, rule.task_type_id) != null;
      const score = base +
        (localToday >= closingStart ? k.score_window_closing : 0) +
        (dry?.score ?? 0) +
        (anniversary ? k.score_anniversary : 0);
      const suggestedDate = start > addDaysStr(localToday, 1) ? start : addDaysStr(localToday, 1);
      out.push({
        ruleId: 'R5',
        plantTaskRuleId: rule.id,
        taskTypeId: rule.task_type_id,
        subjectKey,
        ...splitSubjectKey(subjectKey),
        messageKey: rule.message_key,
        messageParams: {
          ...subjectLabelParams(subjectKey, bundle),
          task_type_id: rule.task_type_id,
          window_end_date: win.end,
          ...frostParam,
          ...(dry?.params ?? {}),
          suggested_date: suggestedDate,
        },
        score,
        suggestedDate,
        validUntil: win.end < addDaysStr(localToday, 7) ? win.end : addDaysStr(localToday, 7),
        cooldownDays: 10,
        weatherGuard: rule.weather_guard,
        frostGate: rule.frost_gate,
      });
    }
  }
  return out;
}

/** R7 — seedling chain: propose step K+1 once step K (after_event) is done this
 * season and K+1 has not followed (docs/m11/03 §R7). Event-driven; never expires. */
export function r7(
  bundle: UserBundle,
  rules: PlantTaskRule[],
  signals: Signals,
  cfg: EngineConfig,
): Candidate[] {
  const { climate, history, eligibility, localToday } = signals;
  const k = cfg.engine;
  const overrides = plantOverrideSet(rules);
  const out: Candidate[] = [];
  for (const rule of rules) {
    if (rule.timing_anchor !== 'growth_stage') continue;
    const afterEvent = rule.window.after_event as string;
    const offMin = Number(rule.window.offset_min_days);
    const offMax = Number(rule.window.offset_max_days);
    for (const subjectKey of subjectsForRule(rule, eligibility, overrides)) {
      const prev = history.chainStepDate(subjectKey, afterEvent); // last K this season
      if (prev == null) continue; // preceding step never done → no chain
      const lastDone = history.lastDone(subjectKey, rule.task_type_id);
      if (lastDone != null && lastDone >= prev) continue; // K+1 already done after K
      let start = addDaysStr(prev, offMin);
      const end = addDaysStr(prev, offMax);
      // frost-gate exception: a transplant-out step waits for the last frost even
      // if the seedling is under cover now (guards.ts evaluates the 48h code too).
      if (rule.frost_gate && climate.lastFrostDate != null && climate.lastFrostDate > start) {
        start = climate.lastFrostDate;
      }
      if (localToday < start) continue;
      const late = localToday > end; // chain does not expire — message flags late
      const suggestedDate = start > addDaysStr(localToday, 1) ? start : addDaysStr(localToday, 1);
      out.push({
        ruleId: 'R7',
        plantTaskRuleId: rule.id,
        taskTypeId: rule.task_type_id,
        subjectKey,
        ...splitSubjectKey(subjectKey),
        messageKey: rule.message_key,
        messageParams: {
          ...subjectLabelParams(subjectKey, bundle),
          task_type_id: rule.task_type_id,
          days_since: dayDiff(localToday, prev),
          late,
          suggested_date: suggestedDate,
        },
        score: k.score_chain_ready + (late ? k.score_window_closing : 0),
        suggestedDate,
        validUntil: addDaysStr(localToday, 7),
        cooldownDays: 5,
        weatherGuard: rule.weather_guard,
        frostGate: rule.frost_gate,
      });
    }
  }
  return out;
}
