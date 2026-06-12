// weather_guard evaluator (docs/m11/02 §G). Codes form a conjunction; an unknown
// code fails closed (tolerant parser, but a visible signal in logs).
//
// Skip semantics (02 §G + op. 3): for a subject in a protected area OR a user
// without location the whole guard is skipped. The frost-gate exception
// (no_frost_forecast_48h evaluates despite the skip, docs/m11/03 R7) applies
// ONLY to protected subjects — for a no-location user weather is permanently
// null, so evaluating it would permanently disable the rule, which op. 3 forbids
// (frost safety falls back to climate frost_defaults anchors instead).

import type { WeatherSignals, WeatherThresholds } from './types.ts';

const kFrostCode = 'no_frost_forecast_48h';

type CodeEval = (w: WeatherSignals, t: WeatherThresholds) => boolean;

// Threshold policy (review M11.8): a code with a number in its NAME (dry12h,
// dry24h, wind_lt_15, soil_gt_8, temp_lt_30, soil_moist's 15 mm) is a fixed
// literal — the name is the contract visible in plant_task_rule.weather_guard
// rows. Only number-free codes read app_config.weather_thresholds.
// Null sub-signal → comparison false (fail-closed).
const kCodeEvals: Record<string, CodeEval> = {
  dry12h: (w) => w.forecastDryHours >= 12,
  dry24h: (w) => w.forecastDryHours >= 24,
  no_rain_forecast_24h: (w, t) => w.forecastRainMm24h != null && w.forecastRainMm24h < t.rain_24h_mm,
  no_rain_forecast_48h: (w, t) => w.forecastRainMm48h != null && w.forecastRainMm48h < t.rain_48h_mm,
  no_heavy_rain_24h: (w, t) =>
    w.forecastRainMm24h != null && w.forecastRainMm24h < t.heavy_rain_24h_mm,
  wind_lt_15: (w) => w.windSpeedKmh != null && w.windSpeedKmh < 15,
  wind_lt_20: (w) => w.windSpeedKmh != null && w.windSpeedKmh < 20,
  temp_gt_0: (w) => w.minTempC48h != null && w.minTempC48h > 0,
  temp_gt_5: (w) => w.minTempC48h != null && w.minTempC48h > 5,
  temp_lt_30: (w) => w.maxTempCToday != null && w.maxTempCToday < 30,
  soil_gt_8: (w) => w.soilTempC != null && w.soilTempC > 8,
  soil_gt_10: (w) => w.soilTempC != null && w.soilTempC > 10,
  soil_gt_12: (w) => w.soilTempC != null && w.soilTempC > 12,
  soil_moist: (w, t) =>
    w.recentRainMm72h != null && w.recentRainMm72h >= t.soil_moist_min_mm_72h &&
    w.recentRainMm24h != null && w.recentRainMm24h < 15,
  [kFrostCode]: (w) => w.minTempC48h != null && w.minTempC48h > 0,
  // drought7d: MVP approximation, forecast API cannot see 7 days back (02 op. 1).
  drought7d: (w, t) =>
    w.recentRainMm72h != null && w.recentRainMm72h < t.recent_rain_wet_mm &&
    w.forecastDryHours >= t.dry_hours_min,
};

export interface GuardOptions {
  /** Subject sits in a protected area (greenhouse) — guard skipped, frost gate not. */
  protectedSubject: boolean;
  /** profile.h3_r7 is null — guard skipped INCLUDING the frost code (02 op. 3). */
  noLocation: boolean;
  /** rule.frost_gate — frost code evaluates for protected subjects despite skip. */
  frostGate: boolean;
}

export interface GuardResult {
  pass: boolean;
  failedCodes: string[];
  skippedCodes: string[];
  unknownCodes: string[];
}

export function evaluateWeatherGuard(
  guardCsv: string | null | undefined,
  weather: WeatherSignals | null,
  thresholds: WeatherThresholds,
  opts: GuardOptions,
): GuardResult {
  const result: GuardResult = { pass: true, failedCodes: [], skippedCodes: [], unknownCodes: [] };
  const skipWeather = opts.protectedSubject || opts.noLocation;
  const codes = (guardCsv ?? '').split(',').map((c) => c.trim()).filter((c) => c.length > 0);
  for (const code of codes) {
    const frostException = code === kFrostCode && opts.frostGate && !opts.noLocation;
    if (skipWeather && !frostException) {
      result.skippedCodes.push(code);
      continue;
    }
    const evalFn = kCodeEvals[code];
    if (!evalFn) {
      console.error('smart-engine: unknown weather_guard code', code);
      result.unknownCodes.push(code);
      result.pass = false;
      continue;
    }
    // Weather unavailable (Open-Meteo down) → fail-closed (02 op. 2).
    if (weather == null || !evalFn(weather, thresholds)) {
      result.failedCodes.push(code);
      result.pass = false;
    }
  }
  return result;
}

/** All known codes evaluated against current weather — for the debug response. */
export function debugGuardCodes(
  weather: WeatherSignals | null,
  thresholds: WeatherThresholds,
): Record<string, boolean> {
  const out: Record<string, boolean> = {};
  for (const [code, evalFn] of Object.entries(kCodeEvals)) {
    out[code] = weather != null && evalFn(weather, thresholds);
  }
  return out;
}
