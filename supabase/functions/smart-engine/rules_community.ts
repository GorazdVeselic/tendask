// R6 — the neighbourhood has already started, you have not (docs/m11/03 §R6).
// The only rule that reads community aggregates; everything it needs is resolved
// up front in community.ts, so the rule itself stays a pure function like the
// others.

import type { Candidate, EngineConfig, TaskTypeMeta, UserBundle } from './types.ts';
import type { Signals } from './signals.ts';
import type { SeasonCdf } from './community.ts';
import { cdfKey } from './community.ts';
import { dryWindowBonus, splitSubjectKey, subjectLabelParams } from './candidate.ts';
import { addDaysStr, isoWeek } from './dates.ts';

const kStartedShare = 0.5; // §R6 SPROŽILEC — "most have already started"
const kStrongShare = 0.68; // §R6 OCENA — a clear majority earns the boost
const kScoreBase = 1.0;
const kScoreStrong = 0.5;
const kPercentStep = 10; // §7.7 — never a precise-looking percentage

/** The catalog species this garden grows, each with the plant that will carry
 * the card. One card per species, not one per specimen: three tomato plants are
 * one gardening decision, and three identical cards would eat the whole band.
 * Sorted by id so a tie is resolved the same way on every run (§Determinizem). */
function speciesSubjects(bundle: UserBundle): Map<string, string> {
  const out = new Map<string, string>();
  for (const plant of [...bundle.plants].sort((a, b) => a.id.localeCompare(b.id))) {
    if (plant.is_custom || plant.plant_id == null) continue;
    if (!out.has(plant.plant_id)) out.set(plant.plant_id, plant.id);
  }
  return out;
}

/** R6 — "most gardeners around you have already started this; you have not."
 *
 * [cdfs] holds one resolved curve per (task type, species), already narrowed to
 * the levels that cleared k_privacy. The rule still applies k_reliab itself: a
 * group may be publishable and still too thin to put a number on (§7.7).
 *
 * Like R2, R6 is deliberately weak — 1.0/1.5 stays under emit_threshold, so
 * "the neighbours are doing it" alone never becomes a card. It surfaces when a
 * dry window agrees (the R1 reinforcement, §R1), i.e. when the nudge is also
 * actionable today.
 */
export function r6(
  bundle: UserBundle,
  signals: Signals,
  taskTypes: Map<string, TaskTypeMeta>,
  cdfs: Map<string, SeasonCdf>,
  cfg: EngineConfig,
): Candidate[] {
  const { history, localToday } = signals;
  const week = isoWeek(localToday);
  const seasonStart = localToday.slice(0, 4) + '-01-01'; // north; south out of MVP scope
  const out: Candidate[] = [];

  for (const [plantId, userPlantId] of speciesSubjects(bundle)) {
    for (const type of taskTypes.values()) {
      if (!type.seasonal) continue; // §7.5 — no season curve, no percentile
      const cdf = cdfs.get(cdfKey(type.id, plantId));
      if (cdf == null || cdf.pooledTotal < cfg.thresholds.kReliab) continue;
      const share = cdf.shareBy(week);
      if (share < kStartedShare) continue;
      // Already started this season on ANY specimen of the species — the answer
      // is "yes, and so have you", which is not a suggestion.
      const started = bundle.plants.some((p) =>
        p.plant_id === plantId && !p.is_custom &&
        (history.lastDone('up:' + p.id, type.id) ?? '') >= seasonStart
      );
      if (started) continue;

      const subjectKey = 'up:' + userPlantId;
      const dry = dryWindowBonus(
        signals.weather,
        cfg.weatherThresholds,
        type.id,
        type.weather_sensitive,
        signals.eligibility.isProtectedSubject(subjectKey),
        cfg.engine.score_weather_window,
      );
      out.push({
        ruleId: 'R6',
        plantTaskRuleId: null,
        taskTypeId: type.id,
        subjectKey,
        ...splitSubjectKey(subjectKey),
        messageKey: 'suggestions.community.most_started',
        messageParams: {
          ...subjectLabelParams(subjectKey, bundle),
          task_type_id: type.id,
          // Kept as the evidence behind the card even though no free surface
          // prints it: the number belongs to the Plus screen (§12.5), and the
          // row has to stay auditable.
          percent: Math.round((share * 100) / kPercentStep) * kPercentStep,
          scope: cdf.resolution,
          n: cdf.pooledTotal,
          ...(dry?.params ?? {}),
          suggested_date: addDaysStr(localToday, 1),
        },
        score: kScoreBase + (share >= kStrongShare ? kScoreStrong : 0) + (dry?.score ?? 0),
        suggestedDate: addDaysStr(localToday, 1),
        validUntil: addDaysStr(localToday, 7),
        cooldownDays: 14,
        weatherGuard: null,
        frostGate: false,
      });
    }
  }
  return out;
}
