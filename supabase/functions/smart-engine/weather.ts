// Open-Meteo forecast fetch + weather signal computation (docs/m11/02 §A).
// computeWeatherSignals is pure (payload + now in) so it is unit-testable.

import type { WeatherSignals } from './types.ts';
import { offsetDateStr } from './dates.ts';

/** Exact call from docs/m11/02 §A — do not extend without updating the spec. */
export function forecastUrl(lat: number, lon: number): string {
  const params = new URLSearchParams({
    latitude: lat.toFixed(4),
    longitude: lon.toFixed(4),
    hourly: 'temperature_2m,precipitation,wind_speed_10m,soil_temperature_6cm',
    daily: 'temperature_2m_min,precipitation_sum',
    // past_days 3 (not 2): the 72h recent-rain window must be fully covered at
    // a morning run — with 2 only ~55h of history exist and rain 56–72h ago
    // would count as 0 (review M11.8).
    past_days: '3',
    forecast_days: '3',
    timezone: 'auto',
  });
  return `https://api.open-meteo.com/v1/forecast?${params}`;
}

// Backoff 1s/3s/9s (CLAUDE.md network rules). Worst case incl. per-attempt 10s
// timeouts is ~53s — callers must share one in-flight result per cell
// (per-invocation memo in index.ts), or an outage multiplies this per user.
const kRetryDelaysMs = [1000, 3000, 9000];

export async function fetchOpenMeteoWithRetry(
  lat: number,
  lon: number,
  fetchFn: typeof fetch = fetch,
): Promise<Record<string, unknown> | null> {
  for (let attempt = 0;; attempt++) {
    try {
      const res = await fetchFn(forecastUrl(lat, lon), { signal: AbortSignal.timeout(10_000) });
      if (!res.ok) throw new Error(`open-meteo ${res.status}`);
      return await res.json();
    } catch (e) {
      if (attempt >= kRetryDelaysMs.length) {
        console.error('smart-engine: open-meteo fetch failed after retries', e);
        return null;
      }
      await new Promise((resolve) => setTimeout(resolve, kRetryDelaysMs[attempt]));
    }
  }
}

function numArr(value: unknown, length: number): (number | null)[] {
  const arr = Array.isArray(value) ? value : [];
  return Array.from(
    { length },
    (_, i) => (typeof arr[i] === 'number' ? arr[i] as number : null),
  );
}

/** Tolerant parser: malformed/missing payload → null (weather signals unavailable,
 * fail-closed downstream per 02 op. 2). Hourly times are LOCAL (timezone=auto);
 * "now" maps in via utc_offset_seconds. */
export function computeWeatherSignals(payload: unknown, nowUtc: Date): WeatherSignals | null {
  const p = payload as Record<string, unknown> | null;
  const offset = typeof p?.utc_offset_seconds === 'number' ? p.utc_offset_seconds : null;
  const hourly = p?.hourly as Record<string, unknown> | undefined;
  const hourlyTime = Array.isArray(hourly?.time) ? hourly.time as string[] : null;
  if (offset == null || !hourlyTime || hourlyTime.length === 0) return null;

  const n = hourlyTime.length;
  const times = hourlyTime.map((t) => Date.parse(t + 'Z'));
  const nowLocalMs = nowUtc.getTime() + offset * 1000;
  let nowIdx = -1;
  for (let i = 0; i < n; i++) {
    if (times[i] <= nowLocalMs) nowIdx = i;
  }
  if (nowIdx < 0) return null;

  const precip = numArr(hourly?.precipitation, n);
  const temp = numArr(hourly?.temperature_2m, n);
  const wind = numArr(hourly?.wind_speed_10m, n);
  const soil = numArr(hourly?.soil_temperature_6cm, n);

  let forecastDryHours = 0;
  for (let i = nowIdx; i < n && forecastDryHours < 48; i++) {
    const v = precip[i];
    // null hour = unknown → conservatively ends the dry streak.
    if (v == null || v >= 0.1) break;
    forecastDryHours++;
  }

  // Fail-closed (02 op. 2): a window not fully covered by known hours → null,
  // so rain guards FAIL instead of passing on missing data (null entries, or a
  // stale cached payload whose forecast no longer reaches the full window).
  const rainSum = (from: number, to: number): number | null => {
    if (from < 0 || to >= n) return null;
    let s = 0;
    for (let i = from; i <= to; i++) {
      const v = precip[i];
      if (v == null) return null;
      s += v;
    }
    return s;
  };

  // Next-48h minimum from HOURLY temps: the daily min would include today's
  // already-elapsed pre-dawn low and day+2 lows up to ~72h out (review M11.8).
  let minTemp: number | null = null;
  if (nowIdx + 48 < n) {
    for (let i = nowIdx + 1; i <= nowIdx + 48; i++) {
      const v = temp[i];
      if (v == null) {
        minTemp = null;
        break;
      }
      if (minTemp == null || v < minTemp) minTemp = v;
    }
  }

  let soilSum = 0;
  let soilCount = 0;
  for (let i = nowIdx; i <= Math.min(n - 1, nowIdx + 23); i++) {
    const v = soil[i];
    if (v != null) {
      soilSum += v;
      soilCount++;
    }
  }

  const localToday = offsetDateStr(nowUtc, offset);
  let windMax: number | null = null;
  let tempMax: number | null = null;
  for (let i = 0; i < n; i++) {
    const t = hourlyTime[i];
    if (!t.startsWith(localToday)) continue;
    const hour = Number(t.slice(11, 13));
    if (hour < 8 || hour > 20) continue;
    const w = wind[i];
    if (w != null && (windMax == null || w > windMax)) windMax = w;
    const c = temp[i];
    if (c != null && (tempMax == null || c > tempMax)) tempMax = c;
  }

  return {
    forecastDryHours,
    recentRainMm24h: rainSum(nowIdx - 23, nowIdx),
    recentRainMm72h: rainSum(nowIdx - 71, nowIdx),
    forecastRainMm24h: rainSum(nowIdx + 1, nowIdx + 24),
    forecastRainMm48h: rainSum(nowIdx + 1, nowIdx + 48),
    soilTempC: soilCount > 0 ? soilSum / soilCount : null,
    windSpeedKmh: windMax,
    minTempC48h: minTemp,
    maxTempCToday: tempMax,
  };
}
