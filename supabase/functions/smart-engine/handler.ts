// Engine request handling: auth guard, batch loop, per-user pipeline. Split
// from index.ts so every branch is testable — index.ts keeps only the wiring of
// the npm-backed pieces (supabase client, h3, FCM), which a test cannot load.
// Spec: docs/m11/04-supabase-shema.md §4.7 + 02-signalni-sloj.md.

// deno-lint-ignore-file no-explicit-any
import { loadAppConfig } from './config.ts';
import { loadRules, loadTaskTypes, loadUserBundle } from './bundle.ts';
import { buildClimateSignals, buildSignals, type Signals } from './signals.ts';
import { debugGuardCodes } from './guards.ts';
import { r2, r3 } from './rules.ts';
import { r5, r7 } from './rules_agro.ts';
import { r6 } from './rules_community.ts';
import { bucketsOf, loadSeasonCdfs, type SeasonCdf } from './community.ts';
import { applyGuards, dedupAndRank, emit, enrichR4 } from './pipeline.ts';
import { housekeep } from './housekeep.ts';
import { fetchOpenMeteoWithRetry } from './weather.ts';
import { localDateStr, safeTimeZone } from './dates.ts';
import type { EngineConfig, PlantTaskRule, TaskTypeMeta, UserBundle } from './types.ts';
import { pushBody } from '../_shared/push_i18n.ts';
import { pushTitleFor } from './push_text.ts';
import { reportError } from '../_shared/report.ts';

/** Everything the handler cannot construct itself: the supabase client factory,
 * the h3 centroid lookup and the FCM sender all come from npm modules, and the
 * clock has to be fixed for a test to assert a date. */
export interface EngineDeps {
  /** Read by the entry point, not here: a unit under test must not depend on
   * ambient process env (and CI would need --allow-env for it). */
  env: { url: string; serviceKey: string };
  makeDb: (url: string, key: string) => any;
  now: () => Date;
  latLngOf: (h3r7: string) => number[];
  sendPush: (opts: {
    fcmToken: string;
    projectId: string;
    title: string;
    body: string;
    suggestionId: string;
  }) => Promise<boolean>;
  projectId: () => string;
}

export function jsonResponse(body: unknown, status = 200): Response {
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
export function isServiceRole(req: Request, serviceKey: string): boolean {
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
async function cellWeather(
  db: any,
  h3r7: string | null,
  cacheDay: string,
  memo: Map<string, unknown>,
  latLngOf: (h3r7: string) => number[],
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
    const [lat, lon] = latLngOf(h3r7);
    payload = await fetchOpenMeteoWithRetry(lat, lon);
    if (payload != null) {
      const up = await db.from('weather_cache')
        .upsert({ h3_r7: h3r7, date: cacheDay, payload });
      if (up.error) reportError('weather_cache_upsert', up.error, { h3r7 });
    }
  }
  memo.set(key, payload);
  return payload;
}

/** The community curves R6 needs for this user: the species they grow × the
 * seasonal task types, resolved through the bucket chain. Empty (and free) for a
 * profile with no cells or no catalog plants — the common case before launch. */
async function seasonCdfsFor(
  db: any,
  bundle: UserBundle,
  taskTypes: Map<string, TaskTypeMeta>,
  signals: Signals,
  cfg: EngineConfig,
  memo: Map<string, Map<string, SeasonCdf>>,
): Promise<Map<string, SeasonCdf>> {
  const cohorts = [
    ...new Set(
      bundle.plants.filter((p) => !p.is_custom && p.plant_id != null)
        .map((p) => p.plant_id as string),
    ),
  ];
  if (cohorts.length === 0) return new Map();
  const seasonal = [...taskTypes.values()].filter((t) => t.seasonal).map((t) => t.id);
  return await loadSeasonCdfs(
    db,
    bucketsOf(bundle.profile),
    seasonal,
    cohorts,
    Number(signals.localToday.slice(0, 4)),
    cfg.thresholds.kPrivacy,
    memo,
  );
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

/** Per-invocation state shared by every user in the batch. */
export interface BatchContext {
  db: any;
  deps: EngineDeps;
  cfg: EngineConfig;
  taskTypes: Map<string, TaskTypeMeta>;
  rules: PlantTaskRule[];
  nowUtc: Date;
  weatherMemo: Map<string, unknown>;
  communityMemo: Map<string, Map<string, SeasonCdf>>;
  debug: boolean;
}

/** One user's full pipeline (03 §Cevovod): housekeeping → signals → rules →
 * guards → emit → push → engine_run. Exported for tests; the batch loop below
 * catches whatever it throws so one user can never break the others. */
export async function runUser(userId: string, ctx: BatchContext): Promise<unknown> {
  const { db, deps, cfg, taskTypes, rules, nowUtc } = ctx;
  const bundle = await loadUserBundle(db, userId, nowUtc);
  if (!bundle) return { user_id: userId, skipped: 'no profile' };

  const cacheDay = localDateStr(nowUtc, safeTimeZone(bundle.profile.timezone));
  // Housekeeping (03 §Cevovod 2) runs before signals so a just-dismissed
  // suggestion's mute is reflected in this run's guards.
  const climate = buildClimateSignals(bundle.profile, cfg, cacheDay);
  const ignoredStreaks = await housekeep(db, bundle, cacheDay, nowUtc, climate, rules, cfg);
  const weatherPayload = await cellWeather(
    db,
    bundle.profile.h3_r7,
    cacheDay,
    ctx.weatherMemo,
    deps.latLngOf,
  );
  const signals = buildSignals(bundle, taskTypes, weatherPayload, cfg, nowUtc, ignoredStreaks);
  const cdfs = await seasonCdfsFor(db, bundle, taskTypes, signals, cfg, ctx.communityMemo);
  // Order per 03 §Cevovod 4; R1 is folded into R3/R5/R6 (inline dry-window
  // bonus), R4 enriches survivors after the guards.
  const candidates = [
    ...r5(bundle, rules, signals, taskTypes, cfg),
    ...r7(bundle, rules, signals, cfg),
    ...r3(bundle, rules, signals, taskTypes, cfg),
    ...r2(bundle, signals, taskTypes, cfg),
    ...r6(bundle, signals, taskTypes, cdfs, cfg),
  ];
  const guarded = applyGuards(candidates, signals, cfg, nowUtc);
  const enriched = enrichR4(guarded, signals.inventory, cfg);
  const ranked = dedupAndRank(enriched, cfg);
  const { count: emitted, topId } = await emit(db, bundle, ranked, nowUtc);
  const push = await maybePush(userId, bundle, ranked, topId, signals, ctx);
  const pushed = push === 'sent';

  const runUp = await db.from('engine_run').upsert({
    user_id: userId,
    last_run_date: signals.localToday,
    ...(pushed ? { last_push_date: signals.localToday } : {}),
  });
  if (runUp.error) reportError('engine_run_upsert', runUp.error, { userId });

  return {
    user_id: userId,
    emitted,
    pushed,
    // Only when it happened: a `false` on every other run would bury the signal
    // the dispatcher's stored response exists to surface (N12).
    ...(push === 'rejected' ? { push_rejected: true } : {}),
    candidates: ranked.map((c) => ({
      rule_id: c.ruleId,
      task_type_id: c.taskTypeId,
      subject_key: c.subjectKey,
      score: c.score,
      valid_until: c.validUntil,
    })),
    // Opt-in only: this is a full dump of the user's garden, and pg_net stores
    // every response the dispatcher gets straight into the database.
    ...(ctx.debug ? { signals: debugSignals(signals, cfg) } : {}),
  };
}

/** What the push step did. 'rejected' is its own outcome, not a flavour of
 * 'skipped': it is the only one that means a live user just went silent. */
type PushOutcome = 'sent' | 'rejected' | 'skipped';

/** Step 8c: at most one push per local day, for the top candidate only. */
async function maybePush(
  userId: string,
  bundle: UserBundle,
  ranked: { ruleId: string; messageKey: string; taskTypeId: string }[],
  topId: string | null,
  signals: Signals,
  ctx: BatchContext,
): Promise<PushOutcome> {
  const { db, deps, cfg, taskTypes, nowUtc } = ctx;
  // push_cap_per_day = 0 is an ops kill-switch: suggestions still emit, the
  // bell goes quiet. The per-day cap itself is structural (one dispatcher run
  // per day + the last_push_date gate below).
  const pushCap = cfg.engine.push_cap_per_day ?? 1;
  if (pushCap < 1 || !topId || !bundle.profile.fcm_token) return 'skipped';

  const ns = bundle.profile.notification_settings;
  const top = ranked[0];
  // R6 = community hints; all others = weather hints opt-in.
  const hintAllowed = top.ruleId === 'R6'
    ? (ns?.community_hints ?? false)
    : (ns?.weather_hints ?? false);
  if (!hintAllowed) return 'skipped';

  const runRes = await db.from('engine_run')
    .select('last_push_date').eq('user_id', userId).maybeSingle();
  const lastPush: string | null = runRes.data?.last_push_date ?? null;
  if (lastPush && lastPush >= signals.localToday) return 'skipped';

  // A push failure must never abort the user's run: the suggestion is already
  // emitted and engine_run must still record the run. projectId() can throw
  // (secret missing) during argument evaluation, so the whole send is wrapped —
  // a throw is our config fault, not a dead device, and must NOT clear the token.
  try {
    const ok = await deps.sendPush({
      fcmToken: bundle.profile.fcm_token,
      projectId: deps.projectId(),
      title: pushTitleFor(top.messageKey, bundle.profile.lang, taskTypes.get(top.taskTypeId)),
      body: pushBody(bundle.profile.lang),
      suggestionId: topId,
    });
    if (ok) return 'sent';
    // The device is gone (UNREGISTERED / foreign sender) — clear the token so we
    // stop sending. A rejected message throws instead and is reported below.
    // Deliberately does NOT bump updated_at: if the client has since registered
    // a fresh token (newer updated_at), bumping here would let this null win the
    // LWW pull and clobber the live token.
    await db.from('profile').update({ fcm_token: null }).eq('user_id', userId);
    // N12: from here on the user is silent, and until this stamp existed nothing
    // said so — not a row, not a line. Decision #9 turns on the rate of this
    // happening, so it has to outlive log retention. The later engine_run upsert
    // does not carry this column, so it cannot overwrite the stamp.
    //
    // Not reportError: a device that was uninstalled is an expected lifecycle
    // event, and filing it under evt="engine_error" would blunt the one filter
    // that is supposed to mean something is broken. A failure to RECORD it is an
    // engine error, and that one is reported.
    const stamp = await db.from('engine_run')
      .upsert({ user_id: userId, push_rejected_at: nowUtc.toISOString() });
    if (stamp.error) reportError('push_rejected_stamp', stamp.error, { userId });
    return 'rejected';
  } catch (e) {
    reportError('fcm_send', e, { userId });
  }
  return 'skipped';
}

/** Supabase errors are plain objects, and String() renders those as
 * "[object Object]" — which is what the dispatcher would store as the reason. */
function errorText(e: unknown): string {
  if (e instanceof Error) return e.message;
  if (e && typeof e === 'object' && 'message' in e) {
    return String((e as { message: unknown }).message);
  }
  return String(e);
}

/** The whole request: auth, validation, batch. [deps] carries everything that
 * needs npm or a clock, so a test drives this with fakes. */
export async function handleRequest(req: Request, deps: EngineDeps): Promise<Response> {
  try {
    if (req.method !== 'POST') return jsonResponse({ error: 'POST required' }, 405);
    const { url: supabaseUrl, serviceKey } = deps.env;
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

    const db = deps.makeDb(supabaseUrl, serviceKey);
    const cfg = await loadAppConfig(db);
    // Server-dark master switch, mirroring the guard both cron functions carry
    // (0007/0009). Without it the flag protects the schedule but not a manual
    // call, and the dispatcher is not the only thing that can reach this.
    if (!cfg.enabled) return jsonResponse({ ok: true, skipped: 'engine disabled' });

    const ctx: BatchContext = {
      db,
      deps,
      cfg,
      taskTypes: await loadTaskTypes(db),
      rules: await loadRules(db), // cached once per invocation (03 §Cevovod 1)
      nowUtc: deps.now(),
      weatherMemo: new Map(),
      // Neighbours in one cell share a slice: the batch pays for it once.
      communityMemo: new Map(),
      debug: new URL(req.url).searchParams.get('debug') === '1',
    };

    const results: unknown[] = [];
    for (const userId of userIds) {
      try {
        results.push(await runUser(userId, ctx));
      } catch (e) {
        // One failing user must not break the batch (04 §4.7).
        reportError('user', e, { userId });
        results.push({ user_id: userId, error: errorText(e) });
      }
    }
    return jsonResponse({ ok: true, results });
  } catch (e) {
    reportError('request', e);
    return jsonResponse({ error: 'internal' }, 500);
  }
}
