// Shared helpers for rule candidates: guard key derivation, subject → user_plant/
// area split, subject label params, and the R1 "dry window" predicate that the
// history rules read directly for their weather bonus (docs/m11/03 §3).

import type { Candidate, UserBundle, WeatherSignals, WeatherThresholds } from './types.ts';

/** Cooldown/dismiss granularity (docs/m11/03 §Guard key): the concrete agronomy
 * rule id for R5/R7, else '<ruleId>:<taskTypeId>' for R1–R3/R6. */
export function guardKey(
  plantTaskRuleId: string | null,
  ruleId: string,
  taskTypeId: string,
): string {
  return plantTaskRuleId ?? `${ruleId}:${taskTypeId}`;
}

export function guardKeyOf(c: Candidate): string {
  return guardKey(c.plantTaskRuleId, c.ruleId, c.taskTypeId);
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
 * recently-dry surface. For `treat` (spraying) it additionally needs low wind +
 * no rain forecast 24h — drift resistance, which the generic window can't see. */
export function isDryWindow(
  weather: WeatherSignals | null,
  t: WeatherThresholds,
  taskTypeId?: string,
): boolean {
  if (weather == null) return false;
  if (weather.forecastDryHours < t.dry_hours_min) return false;
  if (weather.recentRainMm24h == null || weather.recentRainMm24h >= t.recent_rain_wet_mm) {
    return false;
  }
  if (taskTypeId === 'treat') {
    if (weather.windSpeedKmh == null || weather.windSpeedKmh >= t.wind_treat_kmh) return false;
    if (weather.forecastRainMm24h == null || weather.forecastRainMm24h >= t.rain_24h_mm) {
      return false;
    }
  }
  return true;
}

/** R1 reinforcement (docs/m11/03 §R1): a weather-sensitive, unprotected subject in
 * a dry forecast window earns the weather-window score plus the params the client
 * shows ("jutri kaže suho"). Returns null when no window applies — the history/
 * season rule keeps its own message_key and just gains the bonus (R1 never emits a
 * standalone card here; it only ojača R3/R5 need). */
export function dryWindowBonus(
  weather: WeatherSignals | null,
  t: WeatherThresholds,
  taskTypeId: string,
  weatherSensitive: boolean,
  protectedSubject: boolean,
  scoreWeatherWindow: number,
): { score: number; params: Record<string, unknown> } | null {
  if (!weatherSensitive || protectedSubject) return null;
  if (!isDryWindow(weather, t, taskTypeId)) return null;
  // weather is non-null: isDryWindow returned true.
  return {
    score: scoreWeatherWindow,
    params: { dry_window: true, dry_hours: weather!.forecastDryHours },
  };
}
