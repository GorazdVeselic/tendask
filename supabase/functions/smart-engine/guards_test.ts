import { assertEquals } from 'jsr:@std/assert@1';
import { evaluateWeatherGuard } from './guards.ts';
import { kDefaultThresholds } from './config.ts';
import type { WeatherSignals } from './types.ts';

function weather(overrides: Partial<WeatherSignals> = {}): WeatherSignals {
  return {
    forecastDryHours: 30,
    recentRainMm24h: 0,
    recentRainMm72h: 0,
    forecastRainMm24h: 0,
    forecastRainMm48h: 0,
    soilTempC: 11,
    windSpeedKmh: 5,
    minTempC48h: 4,
    maxTempCToday: 22,
    ...overrides,
  };
}

const kEval = { protectedSubject: false, noLocation: false, frostGate: false };

Deno.test('empty/null guard passes', () => {
  assertEquals(evaluateWeatherGuard(null, weather(), kDefaultThresholds, kEval).pass, true);
  assertEquals(evaluateWeatherGuard('', weather(), kDefaultThresholds, kEval).pass, true);
});

Deno.test('guard is a conjunction — one failing code fails the guard', () => {
  const r = evaluateWeatherGuard(
    'dry24h,wind_lt_15',
    weather({ windSpeedKmh: 20 }),
    kDefaultThresholds,
    kEval,
  );
  assertEquals(r.pass, false);
  assertEquals(r.failedCodes, ['wind_lt_15']);
});

Deno.test('all §G codes evaluate per spec', () => {
  const cases: [string, Partial<WeatherSignals>, boolean][] = [
    ['dry12h', { forecastDryHours: 12 }, true],
    ['dry12h', { forecastDryHours: 11 }, false],
    ['dry24h', { forecastDryHours: 24 }, true],
    ['dry24h', { forecastDryHours: 23 }, false],
    ['no_rain_forecast_24h', { forecastRainMm24h: 0.9 }, true],
    ['no_rain_forecast_24h', { forecastRainMm24h: 1.0 }, false],
    ['no_rain_forecast_48h', { forecastRainMm48h: 1.9 }, true],
    ['no_rain_forecast_48h', { forecastRainMm48h: 2.0 }, false],
    ['no_heavy_rain_24h', { forecastRainMm24h: 9.9 }, true],
    ['no_heavy_rain_24h', { forecastRainMm24h: 10 }, false],
    ['wind_lt_15', { windSpeedKmh: 14.9 }, true],
    ['wind_lt_15', { windSpeedKmh: 15 }, false],
    ['wind_lt_20', { windSpeedKmh: 19.9 }, true],
    ['wind_lt_20', { windSpeedKmh: 20 }, false],
    ['temp_gt_0', { minTempC48h: 0.1 }, true],
    ['temp_gt_0', { minTempC48h: 0 }, false],
    ['temp_gt_5', { minTempC48h: 5.1 }, true],
    ['temp_gt_5', { minTempC48h: 5 }, false],
    ['temp_lt_30', { maxTempCToday: 29.9 }, true],
    ['temp_lt_30', { maxTempCToday: 30 }, false],
    ['soil_gt_8', { soilTempC: 8.1 }, true],
    ['soil_gt_8', { soilTempC: 8 }, false],
    ['soil_gt_10', { soilTempC: 10.1 }, true],
    ['soil_gt_12', { soilTempC: 12.1 }, true],
    ['soil_moist', { recentRainMm72h: 5, recentRainMm24h: 14 }, true],
    ['soil_moist', { recentRainMm72h: 4.9 }, false],
    ['soil_moist', { recentRainMm72h: 8, recentRainMm24h: 15 }, false],
    ['no_frost_forecast_48h', { minTempC48h: 0.1 }, true],
    ['no_frost_forecast_48h', { minTempC48h: -1 }, false],
    ['drought7d', { recentRainMm72h: 1.9, forecastDryHours: 24 }, true],
    ['drought7d', { recentRainMm72h: 2.0, forecastDryHours: 48 }, false],
    ['drought7d', { recentRainMm72h: 0, forecastDryHours: 23 }, false],
  ];
  for (const [code, w, expected] of cases) {
    const r = evaluateWeatherGuard(code, weather(w), kDefaultThresholds, kEval);
    assertEquals(r.pass, expected, `${code} with ${JSON.stringify(w)}`);
  }
});

Deno.test('unknown code fails closed and is reported', () => {
  const r = evaluateWeatherGuard('dry24h,not_a_code', weather(), kDefaultThresholds, kEval);
  assertEquals(r.pass, false);
  assertEquals(r.unknownCodes, ['not_a_code']);
});

Deno.test('weather unavailable fails closed', () => {
  const r = evaluateWeatherGuard('dry24h', null, kDefaultThresholds, kEval);
  assertEquals(r.pass, false);
  assertEquals(r.failedCodes, ['dry24h']);
});

Deno.test('null sub-signal fails its code closed', () => {
  const cases: [string, Partial<WeatherSignals>][] = [
    ['wind_lt_15', { windSpeedKmh: null }],
    ['no_rain_forecast_24h', { forecastRainMm24h: null }],
    ['no_rain_forecast_48h', { forecastRainMm48h: null }],
    ['soil_moist', { recentRainMm72h: null }],
    ['drought7d', { recentRainMm72h: null }],
  ];
  for (const [code, w] of cases) {
    const r = evaluateWeatherGuard(code, weather(w), kDefaultThresholds, kEval);
    assertEquals(r.pass, false, code);
  }
});

Deno.test('protected subject skips the whole guard', () => {
  const r = evaluateWeatherGuard(
    'dry24h,wind_lt_15',
    weather({ forecastDryHours: 0, windSpeedKmh: 99 }),
    kDefaultThresholds,
    { protectedSubject: true, noLocation: false, frostGate: false },
  );
  assertEquals(r.pass, true);
  assertEquals(r.skippedCodes, ['dry24h', 'wind_lt_15']);
});

Deno.test('frost gate still evaluates the frost code for a protected subject', () => {
  const r = evaluateWeatherGuard(
    'dry24h,no_frost_forecast_48h',
    weather({ forecastDryHours: 0, minTempC48h: -2 }),
    kDefaultThresholds,
    { protectedSubject: true, noLocation: false, frostGate: true },
  );
  assertEquals(r.pass, false);
  assertEquals(r.skippedCodes, ['dry24h']);
  assertEquals(r.failedCodes, ['no_frost_forecast_48h']);
});

Deno.test('no-location user skips even the frost code (02 op. 3 — no permanent disable)', () => {
  const r = evaluateWeatherGuard(
    'dry24h,no_frost_forecast_48h',
    null, // weather is permanently unavailable without a location
    kDefaultThresholds,
    { protectedSubject: false, noLocation: true, frostGate: true },
  );
  assertEquals(r.pass, true);
  assertEquals(r.skippedCodes, ['dry24h', 'no_frost_forecast_48h']);
});
