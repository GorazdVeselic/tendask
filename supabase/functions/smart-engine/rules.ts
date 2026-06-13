// History rules (docs/m11/03 §R2, §R3). Neither needs plant_task_rule, so they
// land first (M11.9). Each returns candidates; the shared pipeline (guards →
// rank → emit) consumes them. The weather bonus reads the R1 "dry window"
// predicate directly — R1's own candidate + per-rule weather_guard for cadence_
// only rules arrive with M11.10/M11.11 (weatherGuard stays null here).

import type { Candidate, EngineConfig, TaskTypeMeta, UserBundle } from './types.ts';
import type { Signals } from './signals.ts';
import { isDryWindow, splitSubjectKey, subjectLabelParams } from './candidate.ts';
import { addDaysStr, dayDiff } from './dates.ts';

const kCadenceOverdueFactor = 1.25; // docs/m11/03 §R3 SPROŽILEC
const kMowBoostMinOverdue = 4;
const kScoreOverdueCap = 2.0;

/** R3 — overdue against the learned/declared cadence. */
export function r3(
  bundle: UserBundle,
  signals: Signals,
  taskTypes: Map<string, TaskTypeMeta>,
  cfg: EngineConfig,
): Candidate[] {
  const { history, weather, eligibility, localToday } = signals;
  const k = cfg.engine;
  const out: Candidate[] = [];
  for (const { subjectKey, taskTypeId } of history.donePairs()) {
    const cad = history.cadenceDays(subjectKey, taskTypeId);
    if (cad == null) continue;
    const lastDone = history.lastDone(subjectKey, taskTypeId);
    if (lastDone == null) continue;
    const days = dayDiff(localToday, lastDone);
    if (days <= cad * kCadenceOverdueFactor) continue;
    const daysOverdue = days - cad;
    const type = taskTypes.get(taskTypeId);
    // No outdoor weather bonus for a protected subject — the dry window is
    // irrelevant under cover (docs/m11/03 §R1, same as guard g's skip).
    const dry = type?.weather_sensitive && !eligibility.isProtectedSubject(subjectKey) &&
      isDryWindow(weather, cfg.weatherThresholds);
    const mowBoost = taskTypeId === 'mow' && daysOverdue >= kMowBoostMinOverdue
      ? k.score_mow_boost
      : 0;
    const score = Math.min(daysOverdue * k.score_overdue_per_day, kScoreOverdueCap) +
      mowBoost + (dry ? k.score_weather_window : 0);
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
        suggested_date: addDaysStr(localToday, 1),
      },
      score,
      suggestedDate: addDaysStr(localToday, 1),
      validUntil: addDaysStr(localToday, 5),
      cooldownDays: 5,
      weatherGuard: null,
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
  const startOfSeason = localToday.slice(0, 4) + '-01-01'; // north; south → M11.10
  const out: Candidate[] = [];
  for (const { subjectKey, taskTypeId } of history.donePairs()) {
    const type = taskTypes.get(taskTypeId);
    if (!type?.seasonal) continue; // don't anniversary non-seasonal types
    const lastYear = history.lastDoneYearAgo(subjectKey, taskTypeId);
    if (lastYear == null) continue;
    const lastDone = history.lastDone(subjectKey, taskTypeId);
    if (lastDone != null && lastDone >= startOfSeason) continue; // already done this season
    // No outdoor weather bonus for a protected subject (docs/m11/03 §R1).
    const dry = type.weather_sensitive && !eligibility.isProtectedSubject(subjectKey) &&
      isDryWindow(weather, cfg.weatherThresholds);
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
        suggested_date: suggestedDate,
      },
      score: k.score_anniversary + (dry ? k.score_weather_window : 0),
      suggestedDate,
      validUntil: addDaysStr(localToday, 7),
      cooldownDays: 30,
      weatherGuard: null,
    });
  }
  return out;
}
