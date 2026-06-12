// app_config loader. Defaults mirror supabase/migrations/0005 seed values so a
// missing/partial row degrades to spec behaviour instead of crashing.

// deno-lint-ignore-file no-explicit-any
import type { EngineConfig, EngineKnobs, WeatherThresholds } from './types.ts';

// Exported so tests assert against the single source of seed defaults.
export const kDefaultEngine: EngineKnobs = {
  score_weather_window: 2.0,
  score_season_window: 1.0,
  score_anniversary: 1.0,
  score_window_closing: 0.5,
  score_low_supply: 0.5,
  score_chain_ready: 2.0,
  score_overdue_per_day: 0.1,
  score_mow_boost: 1.0,
  score_frost_protect_boost: 2.0,
  emit_threshold: 2.0,
  push_cap_per_day: 1,
  band_max_active: 3,
  dedup_planned_within_days: 14,
  frost_safety_days: 7,
  suggestion_retention_days: 365,
};

export const kDefaultThresholds: WeatherThresholds = {
  dry_hours_min: 24,
  recent_rain_wet_mm: 2.0,
  rain_24h_mm: 1.0,
  rain_48h_mm: 2.0,
  heavy_rain_24h_mm: 10,
  wind_treat_kmh: 15,
  wind_transplant_kmh: 20,
  soil_moist_min_mm_72h: 5,
};

export const kDefaultFrost = { last_frost_doy: 110, first_frost_doy: 293 };

export async function loadAppConfig(db: any): Promise<EngineConfig> {
  const { data, error } = await db
    .from('app_config')
    .select('key,value')
    .in('key', ['engine', 'weather_thresholds', 'frost_defaults']);
  if (error) throw error;
  const map: Record<string, unknown> = Object.fromEntries(
    (data ?? []).map((r: { key: string; value: unknown }) => [r.key, r.value]),
  );
  return {
    engine: { ...kDefaultEngine, ...(map.engine as object ?? {}) },
    weatherThresholds: { ...kDefaultThresholds, ...(map.weather_thresholds as object ?? {}) },
    frostDefaults: { ...kDefaultFrost, ...(map.frost_defaults as object ?? {}) },
  };
}
