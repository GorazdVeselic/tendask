// Shared types for the smart-engine Edge Function (M11.8 — signal layer).
// Spec: docs/m11/02-signalni-sloj.md + 04-supabase-shema.md §4.7.

export interface ClimateProfileJson {
  frost_last_spring_doy?: number | null;
  frost_first_autumn_doy?: number | null;
  growing_season_days?: number | null;
  hemisphere?: string | null;
}

export interface Profile {
  user_id: string;
  h3_r7: string | null;
  timezone: string | null;
  lang: string | null;
  climate_bucket: string | null;
  climate_profile: ClimateProfileJson | null;
  fcm_token: string | null;
}

export interface Area {
  id: string;
  name: string;
  type: string;
  protected: boolean;
}

export interface UserPlant {
  id: string;
  area_id: string | null;
  plant_id: string | null;
  custom_name: string | null;
  personal_alias: string | null;
  is_custom: boolean;
  category: string | null; // from plant join; null for custom plants
}

export interface TaskSubjectRef {
  user_plant_id: string | null;
  area_id: string | null;
}

export interface TaskRow {
  id: string;
  task_type_id: string;
  date: string; // ISO timestamptz (UTC)
  status: 'waiting' | 'done';
  subjects: TaskSubjectRef[];
  hasReminder: boolean;
  supplyIds: string[];
}

export interface TaskTypeMeta {
  id: string;
  default_cadence: number | null;
  weather_sensitive: boolean;
  seasonal: boolean;
}

export interface Supply {
  id: string;
  name: string;
  quantity: number;
  low_threshold: number | null;
}

export interface SuggestionLogRow {
  guard_key: string;
  subject_key: string;
  last_suggested_at: string | null;
  dismissed_until: string | null; // timestamptz; Postgres 'infinity' arrives as the string "infinity"
}

export interface ActiveSuggestionRow {
  task_type_id: string;
  subject_key: string;
  valid_until: string; // date (YYYY-MM-DD)
}

export interface UserBundle {
  profile: Profile;
  areas: Area[];
  plants: UserPlant[];
  tasks: TaskRow[];
  supplies: Supply[];
  suggestionLog: SuggestionLogRow[];
  activeSuggestions: ActiveSuggestionRow[];
}

export interface WeatherThresholds {
  dry_hours_min: number;
  recent_rain_wet_mm: number;
  rain_24h_mm: number;
  rain_48h_mm: number;
  heavy_rain_24h_mm: number;
  wind_treat_kmh: number;
  wind_transplant_kmh: number;
  soil_moist_min_mm_72h: number;
}

export interface EngineKnobs {
  frost_safety_days: number;
  dedup_planned_within_days: number;
  [key: string]: number;
}

export interface EngineConfig {
  engine: EngineKnobs;
  weatherThresholds: WeatherThresholds;
  frostDefaults: { last_frost_doy: number; first_frost_doy: number };
}

export interface WeatherSignals {
  forecastDryHours: number;
  // Rain sums are null when the payload does not fully cover the window
  // (fail-closed, 02 op. 2) — guards must treat null as failing.
  recentRainMm24h: number | null;
  recentRainMm72h: number | null;
  forecastRainMm24h: number | null;
  forecastRainMm48h: number | null;
  soilTempC: number | null;
  windSpeedKmh: number | null;
  minTempC48h: number | null;
  maxTempCToday: number | null;
}

export interface ClimateSignals {
  lastFrostDate: string | null; // YYYY-MM-DD this year, +frost_safety_days
  firstFrostDate: string | null; // YYYY-MM-DD this year, -frost_safety_days
  bucket: string | null;
  lastFrostWeek: number | null;
  firstFrostWeek: number | null;
  growingSeasonDays: number | null;
  hemisphereSouth: boolean;
  fromDefaults: boolean; // true when climate_profile is missing → app_config.frost_defaults
}
