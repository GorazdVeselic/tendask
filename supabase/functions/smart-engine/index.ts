// smart-engine Edge Function — M11.8 skeleton: auth guard, batch loop, weather
// cache, signal layer. Rules R1–R7 + emit arrive in M11.9–M11.11; until then the
// function returns the computed signals as a debug response.
// Spec: docs/m11/04-supabase-shema.md §4.7 + 02-signalni-sloj.md.

import { createClient } from '@supabase/supabase-js';
import { cellToLatLng } from 'h3-js';
import { loadAppConfig } from './config.ts';
import { loadRules, loadTaskTypes, loadUserBundle } from './bundle.ts';
import { buildSignals, type Signals } from './signals.ts';
import { debugGuardCodes } from './guards.ts';
import { r2, r3 } from './rules.ts';
import { r5, r7 } from './rules_agro.ts';
import { applyGuards, dedupAndRank, emit } from './pipeline.ts';
import { fetchOpenMeteoWithRetry } from './weather.ts';
import { localDateStr, safeTimeZone } from './dates.ts';
import type { EngineConfig } from './types.ts';

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

/** Only the dispatcher (pg_net with the service JWT from Vault) and manual ops
 * calls may invoke the engine — an anon/user JWT must never reach user bundles.
 * The platform (verify_jwt) has already validated the signature; a plain string
 * compare against the env key breaks under key rotation / new API key formats,
 * so we additionally accept any verified JWT whose role claim is service_role. */
function isServiceRole(req: Request, serviceKey: string): boolean {
  const token = (req.headers.get('authorization') ?? '').replace(/^Bearer\s+/i, '');
  if (token === serviceKey) return true;
  try {
    const payload = JSON.parse(
      atob(token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/')),
    );
    return payload?.role === 'service_role';
  } catch {
    return false;
  }
}

// Cache day = user-local day (coalesce(timezone,'UTC')) — mirrors the
// engine_dispatch window, so two consecutive local mornings never share a
// UTC-keyed payload (UTC+8..+11 cells would otherwise reuse a ~20h-old one).
// The memo also holds FAILED fetches (null) so one outage costs one retry
// ladder per cell per invocation, not one per user.
// deno-lint-ignore no-explicit-any
async function cellWeather(
  db: any,
  h3r7: string | null,
  cacheDay: string,
  memo: Map<string, unknown>,
): Promise<unknown> {
  if (!h3r7) return null; // no location → no weather signals (02 op. 3)
  const key = h3r7 + '|' + cacheDay;
  if (memo.has(key)) return memo.get(key);
  const hit = await db.from('weather_cache').select('payload')
    .eq('h3_r7', h3r7).eq('date', cacheDay).maybeSingle();
  if (hit.error) throw hit.error;
  let payload: unknown = hit.data?.payload ?? null;
  if (payload == null) {
    // Cell CENTROID — user coordinates never exist server-side.
    const [lat, lon] = cellToLatLng(h3r7);
    payload = await fetchOpenMeteoWithRetry(lat, lon);
    if (payload != null) {
      const up = await db.from('weather_cache')
        .upsert({ h3_r7: h3r7, date: cacheDay, payload });
      if (up.error) console.error('smart-engine: weather_cache upsert failed', up.error);
    }
  }
  memo.set(key, payload);
  return payload;
}

function debugSignals(signals: Signals, cfg: EngineConfig): unknown {
  return {
    local_today: signals.localToday,
    time_zone: signals.timeZone,
    no_location: signals.noLocation,
    weather: signals.weather,
    guard_codes: debugGuardCodes(signals.weather, cfg.weatherThresholds),
    climate: signals.climate,
    history: signals.history.debug(),
    inventory: signals.inventory.debug(),
    eligibility: signals.eligibility.debug(),
    state: signals.state.debug(),
  };
}

Deno.serve(async (req) => {
  try {
    if (req.method !== 'POST') return jsonResponse({ error: 'POST required' }, 405);
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    if (!supabaseUrl || !serviceKey) return jsonResponse({ error: 'missing env' }, 500);
    if (!isServiceRole(req, serviceKey)) return jsonResponse({ error: 'unauthorized' }, 401);

    const body = await req.json().catch(() => null);
    const userIds: unknown = body?.user_ids;
    if (
      !Array.isArray(userIds) || userIds.length === 0 ||
      !userIds.every((u) => typeof u === 'string')
    ) {
      return jsonResponse({ error: 'user_ids: non-empty string array required' }, 400);
    }

    const db = createClient(supabaseUrl, serviceKey);
    const cfg = await loadAppConfig(db);
    const taskTypes = await loadTaskTypes(db);
    const rules = await loadRules(db); // cached once per invocation (03 §Cevovod 1)
    const nowUtc = new Date();

    const results: unknown[] = [];
    const weatherMemo = new Map<string, unknown>();
    for (const userId of userIds) {
      try {
        const bundle = await loadUserBundle(db, userId, nowUtc);
        if (!bundle) {
          results.push({ user_id: userId, skipped: 'no profile' });
          continue;
        }
        const cacheDay = localDateStr(nowUtc, safeTimeZone(bundle.profile.timezone));
        const weatherPayload = await cellWeather(db, bundle.profile.h3_r7, cacheDay, weatherMemo);
        const signals = buildSignals(bundle, taskTypes, weatherPayload, cfg, nowUtc);
        // R1 + R4 enrichment join here in M11.11. Order per 03 §Cevovod 4.
        const candidates = [
          ...r5(bundle, rules, signals, taskTypes, cfg),
          ...r7(bundle, rules, signals, cfg),
          ...r3(bundle, signals, taskTypes, cfg),
          ...r2(bundle, signals, taskTypes, cfg),
        ];
        const guarded = applyGuards(candidates, signals, cfg, nowUtc);
        const ranked = dedupAndRank(guarded, cfg);
        const emitted = await emit(db, bundle, ranked, nowUtc);
        const runUp = await db.from('engine_run')
          .upsert({ user_id: userId, last_run_date: signals.localToday });
        if (runUp.error) console.error('smart-engine: engine_run upsert failed', runUp.error);
        results.push({
          user_id: userId,
          emitted,
          candidates: ranked.map((c) => ({ rule_id: c.ruleId, task_type_id: c.taskTypeId,
            subject_key: c.subjectKey, score: c.score, valid_until: c.validUntil })),
          signals: debugSignals(signals, cfg),
        });
      } catch (e) {
        // One failing user must not break the batch (04 §4.7).
        console.error('smart-engine: user failed', userId, e);
        results.push({ user_id: userId, error: String(e) });
      }
    }
    return jsonResponse({ ok: true, results });
  } catch (e) {
    console.error('smart-engine: request failed', e);
    return jsonResponse({ error: 'internal' }, 500);
  }
});
