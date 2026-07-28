// Deterministic year of Open-Meteo-shaped forecasts for the season simulation.
//
// NOT a capture: the forecast endpoint cannot be replayed for past days, and a
// test that reached the network would be neither offline-safe nor repeatable.
// Instead every hourly value is a pure function of (absolute hour, seed), so a
// day's forecast and the previous day's forecast agree about the hours they
// share — the way a real forecast series does — and the whole year replays
// identically on every machine.
//
// The seasonal shape is continental-Slovenia-like (Jan mean ≈ -1 °C, Jul ≈ 22 °C,
// wetter spring/autumn) because that is the market the agronomy rules are
// written for. `seed` varies the weather without changing that shape: the
// simulation asserts its caps across several seeds, so a result cannot be an
// artefact of one lucky year.

const kHoursPerDay = 24;
const kPastDays = 3; // mirrors forecastUrl(): past_days=3 + forecast_days=3
const kForecastDays = 3;

const kDayMs = 86_400_000;

function dayMs(day: string): number {
  return Date.parse(day + 'T00:00:00Z');
}

function addDays(day: string, n: number): string {
  return new Date(dayMs(day) + n * kDayMs).toISOString().slice(0, 10);
}

function dayOfYear(day: string): number {
  const start = Date.UTC(Number(day.slice(0, 4)), 0, 1);
  return Math.round((dayMs(day) - start) / kDayMs) + 1;
}

/** Hash → [0,1). Deterministic and stateless, so any (day, hour) can be sampled
 * in any order without carrying a generator around. */
function rand(seed: number, ...parts: number[]): number {
  let h = 2166136261 ^ seed;
  for (const p of parts) {
    h = Math.imul(h ^ (p + 0x9e3779b9), 16777619);
    h = (h ^ (h >>> 13)) >>> 0;
  }
  return ((h ^ (h >>> 16)) >>> 0) / 4294967296;
}

function meanTempC(doy: number): number {
  return 10.5 - 11.5 * Math.cos((2 * Math.PI * (doy - 15)) / 365);
}

/** Rain probability peaks in spring and autumn, dips in midwinter and midsummer. */
function rainChance(doy: number): number {
  return 0.3 + 0.12 * Math.sin((4 * Math.PI * (doy - 20)) / 365);
}

interface RainSpell {
  from: number; // first wet hour of the day
  to: number; // exclusive
  mmPerHour: number;
}

function rainSpell(day: string, seed: number): RainSpell | null {
  const doy = dayOfYear(day);
  const key = Math.round(dayMs(day) / kDayMs);
  if (rand(seed, key, 1) >= rainChance(doy)) return null;
  const from = Math.floor(rand(seed, key, 2) * 20);
  const hours = 2 + Math.floor(rand(seed, key, 3) * 8);
  return { from, to: from + hours, mmPerHour: 0.4 + rand(seed, key, 4) * 2.6 };
}

function precipitationMm(day: string, hour: number, seed: number): number {
  const spell = rainSpell(day, seed);
  if (spell == null || hour < spell.from || hour >= spell.to) return 0;
  return Math.round(spell.mmPerHour * 10) / 10;
}

function temperatureC(day: string, hour: number, seed: number): number {
  const key = Math.round(dayMs(day) / kDayMs);
  const daily = meanTempC(dayOfYear(day)) + (rand(seed, key, 5) - 0.5) * 7;
  const diurnal = -6 * Math.cos((2 * Math.PI * (hour - 15)) / kHoursPerDay);
  const wet = rainSpell(day, seed) != null ? -1.5 : 0;
  return Math.round((daily + diurnal + wet) * 10) / 10;
}

/** 6 cm soil: damped and lagged against air — no frost spikes, slower spring rise. */
function soilTempC(day: string, hour: number, seed: number): number {
  const key = Math.round(dayMs(day) / kDayMs);
  const lagged = meanTempC(dayOfYear(day) - 10) + (rand(seed, key, 6) - 0.5) * 3;
  const diurnal = -1.5 * Math.cos((2 * Math.PI * (hour - 17)) / kHoursPerDay);
  return Math.round((lagged * 0.9 + 2.0 + diurnal) * 10) / 10;
}

function windKmh(day: string, hour: number, seed: number): number {
  const key = Math.round(dayMs(day) / kDayMs);
  const base = 4 + rand(seed, key, 7) * 16;
  const gust = rand(seed, key, hour + 100) * 8;
  return Math.round((base + gust) * 10) / 10;
}

/** One `/v1/forecast` response as of [localDay], covering past_days=3 through
 * forecast_days=3 in local wall-clock hours (timezone=auto, as the engine asks). */
export function weatherPayload(
  localDay: string,
  utcOffsetSeconds: number,
  seed: number,
): Record<string, unknown> {
  const time: string[] = [];
  const temperature: number[] = [];
  const precipitation: number[] = [];
  const wind: number[] = [];
  const soil: number[] = [];
  const dailyTime: string[] = [];
  const dailyMin: number[] = [];
  const dailySum: number[] = [];

  for (let d = -kPastDays; d < kForecastDays; d++) {
    const day = addDays(localDay, d);
    dailyTime.push(day);
    let min = Infinity;
    let sum = 0;
    for (let h = 0; h < kHoursPerDay; h++) {
      const t = temperatureC(day, h, seed);
      const p = precipitationMm(day, h, seed);
      time.push(`${day}T${String(h).padStart(2, '0')}:00`);
      temperature.push(t);
      precipitation.push(p);
      wind.push(windKmh(day, h, seed));
      soil.push(soilTempC(day, h, seed));
      if (t < min) min = t;
      sum += p;
    }
    dailyMin.push(Math.round(min * 10) / 10);
    dailySum.push(Math.round(sum * 10) / 10);
  }

  return {
    latitude: 46.05,
    longitude: 14.5,
    utc_offset_seconds: utcOffsetSeconds,
    timezone: 'Europe/Ljubljana',
    hourly: {
      time,
      temperature_2m: temperature,
      precipitation,
      wind_speed_10m: wind,
      soil_temperature_6cm: soil,
    },
    daily: {
      time: dailyTime,
      temperature_2m_min: dailyMin,
      precipitation_sum: dailySum,
    },
  };
}

/** The zone's UTC offset at [utc], so the payload's offset moves with DST the
 * way `timezone=auto` does. */
export function tzOffsetSeconds(utc: Date, timeZone: string): number {
  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone,
    hour12: false,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  }).formatToParts(utc);
  const get = (type: string) => Number(parts.find((p) => p.type === type)?.value ?? 0);
  const asUtc = Date.UTC(
    get('year'),
    get('month') - 1,
    get('day'),
    get('hour') % 24,
    get('minute'),
    get('second'),
  );
  return Math.round((asUtc - utc.getTime()) / 1000);
}
