// smart-engine Edge Function — M11.8 skeleton: auth guard, batch loop, weather
// cache, signal layer. Rules R1–R7 + emit arrive in M11.9–M11.11; until then the
// function returns the computed signals as a debug response.
// Spec: docs/m11/04-supabase-shema.md §4.7 + 02-signalni-sloj.md.

import { createClient } from '@supabase/supabase-js';
import { cellToLatLng } from 'h3-js';
import { loadAppConfig } from './config.ts';
import { loadRules, loadTaskTypes, loadUserBundle } from './bundle.ts';
import { buildClimateSignals, buildSignals, type Signals } from './signals.ts';
import { debugGuardCodes } from './guards.ts';
import { r2, r3 } from './rules.ts';
import { r5, r7 } from './rules_agro.ts';
import { applyGuards, dedupAndRank, emit, enrichR4 } from './pipeline.ts';
import { housekeep } from './housekeep.ts';
import { fetchOpenMeteoWithRetry } from './weather.ts';
import { localDateStr, safeTimeZone } from './dates.ts';
import type { EngineConfig } from './types.ts';
import { fcmProjectId, sendSuggestionPush } from '../_shared/fcm.ts';
import { pushBody, pushTitle } from '../_shared/push_i18n.ts';

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
        // Housekeeping (03 §Cevovod 2) runs before signals so a just-dismissed
        // suggestion's mute is reflected in this run's guards.
        const climate = buildClimateSignals(bundle.profile, cfg, cacheDay);
        await housekeep(db, bundle, cacheDay, nowUtc, climate, rules, cfg);
        const weatherPayload = await cellWeather(db, bundle.profile.h3_r7, cacheDay, weatherMemo);
        const signals = buildSignals(bundle, taskTypes, weatherPayload, cfg, nowUtc);
        // Order per 03 §Cevovod 4; R1 is folded into R3/R5 (inline dry-window
        // bonus), R4 enriches survivors after the guards.
        const candidates = [
          ...r5(bundle, rules, signals, taskTypes, cfg),
          ...r7(bundle, rules, signals, cfg),
          ...r3(bundle, rules, signals, taskTypes, cfg),
          ...r2(bundle, signals, taskTypes, cfg),
        ];
        const guarded = applyGuards(candidates, signals, cfg, nowUtc);
        const enriched = enrichR4(guarded, signals.inventory, cfg);
        const ranked = dedupAndRank(enriched, cfg);
        const { count: emitted, topId } = await emit(db, bundle, ranked, nowUtc);
        // Step 8c: FCM push for the top candidate (max 1 per local day). The
        // per-day cap is structural (one dispatcher run/day + last_push_date gate);
        // push_cap_per_day=0 is an ops kill-switch that disables all pushes.
        let pushed = false;
        const pushCap = cfg.engine.push_cap_per_day ?? 1;
        if (pushCap >= 1 && topId && bundle.profile.fcm_token) {
          const ns = bundle.profile.notification_settings;
          const topCandidate = ranked[0];
          // R6 = community hints; all others = weather hints opt-in.
          const hintAllowed = topCandidate.ruleId === 'R6'
            ? (ns?.community_hints ?? false)
            : (ns?.weather_hints ?? false);
          if (hintAllowed) {
            const runRes = await db.from('engine_run')
              .select('last_push_date').eq('user_id', userId).maybeSingle();
            const lastPush: string | null = runRes.data?.last_push_date ?? null;
            if (!lastPush || lastPush < signals.localToday) {
              const ok = await sendSuggestionPush({
                fcmToken: bundle.profile.fcm_token,
                projectId: fcmProjectId(),
                title: pushTitle(topCandidate.messageKey, bundle.profile.lang),
                body: pushBody(bundle.profile.lang),
                suggestionId: topId,
              }).catch((e) => {
                console.error('smart-engine: FCM send failed', userId, e);
                return false as boolean;
              });
              if (ok) {
                pushed = true;
              } else {
                // UNREGISTERED or invalid token — clear it so we stop sending.
                // Deliberately does NOT bump updated_at: if the client has since
                // registered a fresh token (newer updated_at), bumping here would
                // let this null win the LWW pull and clobber the live token.
                await db.from('profile')
                  .update({ fcm_token: null }).eq('user_id', userId);
              }
            }
          }
        }
        const runUp = await db.from('engine_run').upsert({
          user_id: userId,
          last_run_date: signals.localToday,
          ...(pushed ? { last_push_date: signals.localToday } : {}),
        });
        if (runUp.error) console.error('smart-engine: engine_run upsert failed', runUp.error);
        results.push({
          user_id: userId,
          emitted,
          pushed,
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
