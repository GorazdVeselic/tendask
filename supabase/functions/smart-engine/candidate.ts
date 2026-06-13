// Shared helpers for rule candidates: guard key derivation, subject → user_plant/
// area split, subject label params, and the R1 "dry window" predicate that the
// history rules read directly for their weather bonus (docs/m11/03 §3).

import type { Candidate, UserBundle, WeatherSignals, WeatherThresholds } from './types.ts';

/** Cooldown/dismiss granularity (docs/m11/03 §Guard key): the concrete agronomy
 * rule id for R5/R7, else '<ruleId>:<taskTypeId>' for R1–R3/R6. */
export function guardKeyOf(c: Candidate): string {
  return c.plantTaskRuleId ?? `${c.ruleId}:${c.taskTypeId}`;
}

/** 'up:<id>'/'ar:<id>' → the suggestion row's user_plant_id/area_id columns. */
export function splitSubjectKey(
  subjectKey: string,
): { userPlantId: string | null; areaId: string | null } {
  if (subjectKey.startsWith('up:')) return { userPlantId: subjectKey.slice(3), areaId: null };
  if (subjectKey.startsWith('ar:')) return { userPlantId: null, areaId: subjectKey.slice(3) };
  return { userPlantId: null, areaId: null }; // 'cat:' — neither column
}

/** Label params per docs/m11/03 §Sporočila: catalog id when known, else a raw
 * string the client shows verbatim (personal alias wins, then custom name, then
 * the area name). The client never decodes anything itself. */
export function subjectLabelParams(
  subjectKey: string,
  bundle: UserBundle,
): Record<string, string> {
  if (subjectKey.startsWith('up:')) {
    const plant = bundle.plants.find((p) => p.id === subjectKey.slice(3));
    if (!plant) return {};
    if (plant.personal_alias) return { subject_label_raw: plant.personal_alias };
    if (!plant.is_custom && plant.plant_id) return { subject_label_key: plant.plant_id };
    return { subject_label_raw: plant.custom_name ?? '' };
  }
  if (subjectKey.startsWith('ar:')) {
    const area = bundle.areas.find((a) => a.id === subjectKey.slice(3));
    return area ? { subject_label_raw: area.name } : {};
  }
  return {};
}

/** R1's core condition (docs/m11/03 §R1 SPROŽILEC): a dry forecast window over a
 * recently-dry surface. The history rules add a weather bonus when it holds;
 * R1's own candidate (with wind handling for treat) lands in M11.11. */
export function isDryWindow(
  weather: WeatherSignals | null,
  t: WeatherThresholds,
): boolean {
  return weather != null &&
    weather.forecastDryHours >= t.dry_hours_min &&
    weather.recentRainMm24h != null && weather.recentRainMm24h < t.recent_rain_wet_mm;
}
