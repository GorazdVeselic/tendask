// History rules (docs/m11/03 §R2, §R3). Neither needs an agronomy rule to fire,
// but R3 consults the matching cadence_only plant_task_rule (when one exists) for
// its season gate + weather_guard. Each returns candidates; the shared pipeline
// (guards → rank → emit) consumes them. The R1 dry-window reinforcement is read
// inline via dryWindowBonus (it ojača the need, never emits a standalone card).

import type {
  Candidate,
  ClimateSignals,
  EngineConfig,
  PlantTaskRule,
  TaskTypeMeta,
  UserBundle,
} from './types.ts';
import type { Signals } from './signals.ts';
import { dryWindowBonus, splitSubjectKey, subjectLabelParams } from './candidate.ts';
import { regionalizedWeekWindow } from './rules_agro.ts';
import { addDaysStr, dayDiff } from './dates.ts';

const kCadenceOverdueFactor = 1.25; // docs/m11/03 §R3 SPROŽILEC
const kMowBoostMinOverdue = 4;
const kScoreOverdueCap = 2.0;

/** The cadence_only rule governing (subjectKey, taskTypeId), honouring the
 * plant-over-category override (01 §B). null when no curated cadence rule applies
 * — R3 still fires on learned history; the rule only adds a season gate +
 * weather_guard. */
function cadenceRuleFor(
  subjectKey: string,
  taskTypeId: string,
  rules: PlantTaskRule[],
  bundle: UserBundle,
): PlantTaskRule | null {
  const cadence = rules.filter((r) =>
    r.timing_anchor === 'cadence_only' && r.task_type_id === taskTypeId
  );
  if (cadence.length === 0) return null;
  if (subjectKey.startsWith('up:')) {
    const plant = bundle.plants.find((p) => p.id === subjectKey.slice(3));
    if (!plant) return null;
    if (plant.plant_id != null) {
      const byPlant = cadence.find((r) => r.scope === 'plant' && r.ref_id === plant.plant_id);
      if (byPlant) return byPlant;
    }
    if (plant.is_custom || plant.category == null) return null;
    return cadence.find((r) => r.scope === 'category' && r.ref_id === plant.category) ?? null;
  }
  if (subjectKey.startsWith('ar:')) {
    const area = bundle.areas.find((a) => a.id === subjectKey.slice(3));
    if (!area) return null;
    return cadence.find((r) => r.scope === 'category' && r.ref_id === area.type) ?? null;
  }
  return null;
}

/** A cadence_only rule's optional seasonal limit (01 §0): today must fall inside
 * the regionalised ISO-week window. No season fields → always open; south
 * hemisphere → open (week regionalisation is northern-only, north is MVP scope). */
function seasonGateOpen(
  rule: PlantTaskRule,
  climate: ClimateSignals,
  cfg: EngineConfig,
  localToday: string,
): boolean {
  const w = rule.window;
  if (w.season_start_week == null || w.season_end_week == null) return true;
  const win = regionalizedWeekWindow(
    Number(w.season_start_week),
    Number(w.season_end_week),
    w.regionalize as string | undefined,
    climate,
    cfg,
    Number(localToday.slice(0, 4)),
  );
  if (win == null) return true;
  return localToday >= win.start && localToday <= win.end;
}

/** R3 — overdue against the learned/declared cadence. */
export function r3(
  bundle: UserBundle,
  rules: PlantTaskRule[],
  signals: Signals,
  taskTypes: Map<string, TaskTypeMeta>,
  cfg: EngineConfig,
): Candidate[] {
  const { history, weather, eligibility, climate, localToday } = signals;
  const k = cfg.engine;
  const out: Candidate[] = [];
  for (const { subjectKey, taskTypeId } of history.donePairs()) {
    const cad = history.cadenceDays(subjectKey, taskTypeId);
    if (cad == null) continue;
    const lastDone = history.lastDone(subjectKey, taskTypeId);
    if (lastDone == null) continue;
    const days = dayDiff(localToday, lastDone);
    if (days <= cad * kCadenceOverdueFactor) continue;
    const rule = cadenceRuleFor(subjectKey, taskTypeId, rules, bundle);
    // Out of the cadence rule's season → not due now (e.g. no mowing in winter).
    if (rule != null && !seasonGateOpen(rule, climate, cfg, localToday)) continue;
    const daysOverdue = days - cad;
    const type = taskTypes.get(taskTypeId);
    // No outdoor weather bonus for a protected subject — the dry window is
    // irrelevant under cover (docs/m11/03 §R1, same as guard g's skip).
    const dry = dryWindowBonus(
      weather,
      cfg.weatherThresholds,
      taskTypeId,
      type?.weather_sensitive ?? false,
      eligibility.isProtectedSubject(subjectKey),
      k.score_weather_window,
    );
    const mowBoost = taskTypeId === 'mow' && daysOverdue >= kMowBoostMinOverdue
      ? k.score_mow_boost
      : 0;
    const score = Math.min(daysOverdue * k.score_overdue_per_day, kScoreOverdueCap) +
      mowBoost + (dry?.score ?? 0);
    out.push({
      ruleId: 'R3',
      plantTaskRuleId: null,
      taskTypeId,
      subjectKey,
      ...splitSubjectKey(subjectKey),
      messageKey: 'suggestions.cadence.overdue',
      messageParams: {
        ...subjectLabelParams(subjectKey, bundle),
        task_type_id: taskTypeId,
        // Learned cadence can be fractional (even-count gap median) — round the
        // values shown to the user; the score keeps the raw daysOverdue.
        days_overdue: Math.round(daysOverdue),
        cadence_days: Math.round(cad),
        ...(dry?.params ?? {}),
        suggested_date: addDaysStr(localToday, 1),
      },
      score,
      suggestedDate: addDaysStr(localToday, 1),
      validUntil: addDaysStr(localToday, 5),
      cooldownDays: 5,
      // Cadence rule's guard (e.g. dry12h → don't mow wet grass); null when the
      // pair has no curated rule (purely learned cadence).
      weatherGuard: rule?.weather_guard ?? null,
      frostGate: false,
    });
  }
  return out;
}

/** R2 — personal anniversary ("a year ago you …"). Deliberately weak: 1.0 alone
 * stays below emit_threshold; it only surfaces combined with a weather/season
 * window (docs/m11/03 §R2). */
export function r2(
  bundle: UserBundle,
  signals: Signals,
  taskTypes: Map<string, TaskTypeMeta>,
  cfg: EngineConfig,
): Candidate[] {
  const { history, weather, eligibility, localToday } = signals;
  const k = cfg.engine;
  const startOfSeason = localToday.slice(0, 4) + '-01-01'; // north; south out of MVP scope
  const out: Candidate[] = [];
  for (const { subjectKey, taskTypeId } of history.donePairs()) {
    const type = taskTypes.get(taskTypeId);
    if (!type?.seasonal) continue; // don't anniversary non-seasonal types
    const lastYear = history.lastDoneYearAgo(subjectKey, taskTypeId);
    if (lastYear == null) continue;
    const lastDone = history.lastDone(subjectKey, taskTypeId);
    if (lastDone != null && lastDone >= startOfSeason) continue; // already done this season
    // No outdoor weather bonus for a protected subject (docs/m11/03 §R1).
    const dry = dryWindowBonus(
      weather,
      cfg.weatherThresholds,
      taskTypeId,
      type.weather_sensitive,
      eligibility.isProtectedSubject(subjectKey),
      k.score_weather_window,
    );
    const lastYearThisYear = localToday.slice(0, 4) + lastYear.slice(4);
    const suggestedDate = lastYearThisYear > addDaysStr(localToday, 1)
      ? lastYearThisYear
      : addDaysStr(localToday, 1);
    out.push({
      ruleId: 'R2',
      plantTaskRuleId: null,
      taskTypeId,
      subjectKey,
      ...splitSubjectKey(subjectKey),
      messageKey: 'suggestions.history.anniversary',
      messageParams: {
        ...subjectLabelParams(subjectKey, bundle),
        task_type_id: taskTypeId,
        last_year_date: lastYear,
        ...(dry?.params ?? {}),
        suggested_date: suggestedDate,
      },
      score: k.score_anniversary + (dry?.score ?? 0),
      suggestedDate,
      validUntil: addDaysStr(localToday, 7),
      cooldownDays: 30,
      weatherGuard: null,
      frostGate: false,
    });
  }
  return out;
}
