import { assertEquals } from 'jsr:@std/assert@1';
import { computeWeatherSignals } from './weather.ts';

// Synthetic payload: 6 local days (past_days=3 + today + 2 forecast), offset
// UTC+2. nowUtc 05:30Z → local 07:30 → nowIdx = 79 (today 07:00).
const kDays = ['2026-06-09', '2026-06-10', '2026-06-11', '2026-06-12', '2026-06-13', '2026-06-14'];
const kHours = kDays.length * 24; // 144
const kNow = new Date('2026-06-12T05:30:00Z');
const kNowIdx = 79;
const kTodayBase = 72; // index of today 00:00

// deno-lint-ignore no-explicit-any
function makePayload(mutate?: (p: any) => void): unknown {
  const time: string[] = [];
  for (const d of kDays) {
    for (let h = 0; h < 24; h++) time.push(`${d}T${String(h).padStart(2, '0')}:00`);
  }
  const payload = {
    utc_offset_seconds: 7200,
    hourly: {
      time,
      temperature_2m: new Array(kHours).fill(15),
      precipitation: new Array(kHours).fill(0),
      wind_speed_10m: new Array(kHours).fill(5),
      soil_temperature_6cm: new Array(kHours).fill(10),
    },
  };
  mutate?.(payload);
  return payload;
}

Deno.test('forecastDryHours caps at 48 on a fully dry forecast', () => {
  const s = computeWeatherSignals(makePayload(), kNow);
  assertEquals(s?.forecastDryHours, 48);
});

Deno.test('forecastDryHours stops at the first wet hour', () => {
  const s = computeWeatherSignals(
    makePayload((p) => p.hourly.precipitation[kNowIdx + 5] = 0.5),
    kNow,
  );
  assertEquals(s?.forecastDryHours, 5);
});

Deno.test('recent rain sums the 24h and 72h windows separately', () => {
  const s = computeWeatherSignals(
    makePayload((p) => {
      p.hourly.precipitation[64] = 3; // yesterday 16:00 — inside last 24h
      p.hourly.precipitation[20] = 2; // three days ago 20:00 — only inside 72h
    }),
    kNow,
  );
  assertEquals(s?.recentRainMm24h, 3);
  assertEquals(s?.recentRainMm72h, 5);
});

Deno.test('forecast rain sums next 24h vs next 48h', () => {
  const s = computeWeatherSignals(
    makePayload((p) => {
      p.hourly.precipitation[kNowIdx + 5] = 2; // within next 24h
      p.hourly.precipitation[kNowIdx + 45] = 4; // within next 48h only
    }),
    kNow,
  );
  assertEquals(s?.forecastRainMm24h, 2);
  assertEquals(s?.forecastRainMm48h, 6);
});

Deno.test('soilTempC averages the next 24 hours', () => {
  const s = computeWeatherSignals(
    makePayload((p) => {
      for (let i = kNowIdx; i < kNowIdx + 24; i++) p.hourly.soil_temperature_6cm[i] = 12;
    }),
    kNow,
  );
  assertEquals(s?.soilTempC, 12);
});

Deno.test('wind and max temp use only today 08–20 local', () => {
  const s = computeWeatherSignals(
    makePayload((p) => {
      p.hourly.wind_speed_10m[kTodayBase + 2] = 50; // today 02:00 — outside the day window
      p.hourly.wind_speed_10m[kTodayBase + 8] = 30; // today 08:00
      p.hourly.temperature_2m[kTodayBase + 20] = 28; // today 20:00
    }),
    kNow,
  );
  assertEquals(s?.windSpeedKmh, 30);
  assertEquals(s?.maxTempCToday, 28);
});

Deno.test('minTempC48h takes the hourly minimum over the next 48 hours', () => {
  const s = computeWeatherSignals(
    makePayload((p) => {
      p.hourly.temperature_2m[kNowIdx - 2] = -3; // pre-dawn low already elapsed — excluded
      p.hourly.temperature_2m[kNowIdx + 30] = 1.5;
    }),
    kNow,
  );
  assertEquals(s?.minTempC48h, 1.5);
});

Deno.test('windows beyond the payload end fail closed (stale cached payload)', () => {
  // Local 2026-06-13 00:30 → nowIdx = 96; only 47 future hours remain.
  const lateNow = new Date('2026-06-12T22:30:00Z');
  const s = computeWeatherSignals(makePayload(), lateNow);
  assertEquals(s?.forecastRainMm24h, 0); // still covered
  assertEquals(s?.forecastRainMm48h, null); // not covered → null
  assertEquals(s?.minTempC48h, null);
});

Deno.test('malformed payload returns null', () => {
  assertEquals(computeWeatherSignals(null, kNow), null);
  assertEquals(computeWeatherSignals({}, kNow), null);
  assertEquals(computeWeatherSignals({ utc_offset_seconds: 0 }, kNow), null);
});

Deno.test('now before the payload range returns null', () => {
  const s = computeWeatherSignals(makePayload(), new Date('2026-06-01T00:00:00Z'));
  assertEquals(s, null);
});

Deno.test('null precipitation hour ends the dry streak and nulls affected sums', () => {
  const s = computeWeatherSignals(
    makePayload((p) => p.hourly.precipitation[kNowIdx + 3] = null),
    kNow,
  );
  assertEquals(s?.forecastDryHours, 3);
  assertEquals(s?.forecastRainMm24h, null); // unknown hour inside the window → fail-closed
  assertEquals(s?.recentRainMm24h, 0); // past window unaffected
});
