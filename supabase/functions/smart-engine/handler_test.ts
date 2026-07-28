import { assertEquals, assertStringIncludes } from 'jsr:@std/assert@1';
import { handleRequest, isServiceRole } from './handler.ts';
import { FakeDb, type Row } from './fake_db.ts';

const kUrl = 'https://example.supabase.co';
const kKey = 'service-key';
const kNow = new Date('2026-06-12T12:00:00Z'); // local today 2026-06-12 (CEST)

function profile(overrides: Row = {}): Row {
  return {
    user_id: 'u1',
    h3_r7: null, // no cell → no weather fetch, so a test never touches the network
    h3_r6: null,
    h3_r5: null,
    timezone: 'Europe/Ljubljana',
    lang: 'sl',
    climate_bucket: 'e1_t6',
    climate_profile: null,
    fcm_token: 'tok-1',
    notification_settings: { weather_hints: true, community_hints: true },
    ...overrides,
  };
}

/** A garden with one badly overdue treatment: R3 alone scores 1.0, which the
 * lowered emit_threshold below lets through without needing a weather payload. */
function db(overrides: Record<string, Row[]> = {}): FakeDb {
  const fake = new FakeDb();
  fake.rows = {
    app_config: [
      { key: 'engine_enabled', value: true },
      { key: 'engine', value: { emit_threshold: 0.5 } },
    ],
    task_type: [
      { id: 'treat', default_cadence: 7, weather_sensitive: true, seasonal: true },
    ],
    plant_task_rule: [],
    profile: [profile()],
    area: [],
    user_plant: [{
      id: 'p1',
      area_id: null,
      plant_id: 'tomato',
      custom_name: null,
      personal_alias: null,
      is_custom: false,
      plant: { category: 'vegetable' },
    }],
    task: [{
      id: 't1',
      task_type_id: 'treat',
      date: '2026-05-01T10:00:00Z', // 42 days ago, cadence 7 → overdue
      status: 'done',
      task_subject: [{ user_plant_id: 'p1', area_id: null }],
      task_reminder: [],
      task_supply: [],
    }],
    supply: [],
    suggestion_log: [],
    suggestion: [],
    engine_run: [],
    weather_cache: [],
    ...overrides,
  };
  return fake;
}

interface Sent {
  suggestionId: string;
  title: string;
  body: string;
}

function deps(
  fake: FakeDb,
  opts: { push?: boolean; projectId?: () => string } = {},
) {
  const sent: Sent[] = [];
  return {
    sent,
    deps: {
      env: { url: kUrl, serviceKey: kKey },
      makeDb: () => fake,
      now: () => kNow,
      latLngOf: () => [46.05, 14.5],
      sendPush: (o: Sent) => {
        sent.push(o);
        return Promise.resolve(opts.push ?? true);
      },
      projectId: opts.projectId ?? (() => 'proj'),
    },
  };
}

function request(body: unknown, init: { method?: string; auth?: string; url?: string } = {}) {
  return new Request(init.url ?? 'https://edge/smart-engine', {
    method: init.method ?? 'POST',
    headers: { authorization: `Bearer ${init.auth ?? kKey}` },
    body: init.method === 'GET' ? undefined : JSON.stringify(body),
  });
}

async function run(
  fake: FakeDb,
  opts: Parameters<typeof deps>[1] = {},
  body: unknown = { user_ids: ['u1'] },
  init: Parameters<typeof request>[1] = {},
) {
  const d = deps(fake, opts);
  const res = await handleRequest(request(body, init), d.deps);
  return { res, json: await res.json(), sent: d.sent, writes: fake.writes };
}

function jwt(role: string): string {
  const part = (o: unknown) => btoa(JSON.stringify(o)).replace(/=+$/, '');
  return `${part({ alg: 'HS256' })}.${part({ role })}.sig`;
}

// ---------- authorization ----------

Deno.test('only the service role reaches user data', () => {
  const req = (auth: string) =>
    new Request('https://edge/x', { method: 'POST', headers: { authorization: auth } });
  assertEquals(isServiceRole(req(`Bearer ${kKey}`), kKey), true);
  assertEquals(isServiceRole(req(`Bearer ${jwt('service_role')}`), kKey), true);
  assertEquals(isServiceRole(req(`Bearer ${jwt('anon')}`), kKey), false);
  assertEquals(isServiceRole(req(`Bearer ${jwt('authenticated')}`), kKey), false);
  assertEquals(isServiceRole(req('Bearer not-a-jwt'), kKey), false);
  assertEquals(isServiceRole(req(''), kKey), false);
});

Deno.test('an anon caller is refused before any read', async () => {
  const fake = db();
  const { res } = await run(fake, {}, { user_ids: ['u1'] }, { auth: jwt('anon') });
  assertEquals(res.status, 401);
  assertEquals(fake.writes.length, 0);
});

Deno.test('GET is not an engine run', async () => {
  const { res } = await run(db(), {}, {}, { method: 'GET' });
  assertEquals(res.status, 405);
});

Deno.test('the body must name real users', async () => {
  for (const body of [{}, { user_ids: [] }, { user_ids: [1, 2] }, { user_ids: 'u1' }]) {
    const { res } = await run(db(), {}, body);
    assertEquals(res.status, 400);
  }
});

// ---------- server-dark switch ----------

Deno.test('engine_enabled = false skips the batch entirely', async () => {
  const fake = db({ app_config: [{ key: 'engine_enabled', value: false }] });
  const { json, writes } = await run(fake);

  assertEquals(json.skipped, 'engine disabled');
  assertEquals(writes.length, 0); // nothing emitted, no engine_run stamp
});

Deno.test('a missing engine_enabled row keeps the engine dark', async () => {
  const fake = db({ app_config: [{ key: 'engine', value: { emit_threshold: 0.5 } }] });
  const { json } = await run(fake);
  assertEquals(json.skipped, 'engine disabled');
});

// ---------- emit + engine_run ----------

Deno.test('an overdue task emits and stamps the run', async () => {
  const fake = db();
  const { json, writes } = await run(fake);

  assertEquals(json.results[0].emitted, 1);
  assertEquals(writes.some((w) => w.table === 'suggestion' && w.op === 'insert'), true);
  const runRow = writes.find((w) => w.table === 'engine_run')!.payload;
  assertEquals(runRow.last_run_date, '2026-06-12');
});

Deno.test('a user without a profile is skipped, not failed', async () => {
  const fake = db({ profile: [] });
  const { json, writes } = await run(fake);

  assertEquals(json.results[0].skipped, 'no profile');
  assertEquals(writes.length, 0);
});

Deno.test('one failing user does not break the batch', async () => {
  const fake = db();
  fake.failOn.add('area'); // bundle load throws for every user
  const { json } = await run(fake, {}, { user_ids: ['u1', 'u2'] });

  assertEquals(json.results.length, 2);
  assertStringIncludes(String(json.results[0].error), 'fake failure');
});

// ---------- push opt-in ----------

Deno.test('a weather hint needs the weather opt-in, not the community one', async () => {
  const off = db({
    profile: [profile({ notification_settings: { weather_hints: false, community_hints: true } })],
  });
  const offRun = await run(off);
  assertEquals(offRun.sent.length, 0);
  assertEquals(offRun.json.results[0].emitted, 1); // the card still appears in-app
  assertEquals(offRun.writes.some((w) => w.table === 'engine_run' && w.payload.last_push_date), false);

  const on = db({
    profile: [profile({ notification_settings: { weather_hints: true, community_hints: false } })],
  });
  const onRun = await run(on);
  assertEquals(onRun.sent.length, 1);
  assertEquals(onRun.writes.find((w) => w.table === 'engine_run')!.payload.last_push_date, '2026-06-12');
});

Deno.test('no notification settings at all means no push', async () => {
  const fake = db({ profile: [profile({ notification_settings: null })] });
  const { sent } = await run(fake);
  assertEquals(sent.length, 0);
});

Deno.test('no token means no push, and nothing is cleared', async () => {
  const fake = db({ profile: [profile({ fcm_token: null })] });
  const { sent, writes } = await run(fake);
  assertEquals(sent.length, 0);
  assertEquals(writes.filter((w) => w.table === 'profile').length, 0);
});

// ---------- frequency cap ----------

Deno.test('one push per local day', async () => {
  const today = db({ engine_run: [{ last_push_date: '2026-06-12' }] });
  assertEquals((await run(today)).sent.length, 0);

  const yesterday = db({ engine_run: [{ last_push_date: '2026-06-11' }] });
  assertEquals((await run(yesterday)).sent.length, 1);
});

Deno.test('push_cap_per_day = 0 is a kill switch, not a mute on suggestions', async () => {
  const fake = db({
    app_config: [
      { key: 'engine_enabled', value: true },
      { key: 'engine', value: { emit_threshold: 0.5, push_cap_per_day: 0 } },
    ],
  });
  const { json, sent } = await run(fake);

  assertEquals(sent.length, 0);
  assertEquals(json.results[0].emitted, 1); // the suggestion is still written
});

// ---------- dead token handling ----------

Deno.test('a dead token is cleared with exactly {fcm_token: null}', async () => {
  const fake = db();
  const { writes } = await run(fake, { push: false });

  const update = writes.find((w) => w.table === 'profile' && w.op === 'update')!;
  // updated_at must NOT be bumped: a client that registered a fresh token in the
  // meantime would lose it to this null on the next LWW pull.
  assertEquals(update.payload, { fcm_token: null });
});

Deno.test('a dead token leaves a trace, not just silence (N12)', async () => {
  const fake = db();
  const { writes, json } = await run(fake, { push: false });

  // Without this the user simply stops getting notifications and nothing —
  // no row, no log line — says why. Decision #9 turns on the rate of it.
  const stamp = writes.find(
    (w) => w.table === 'engine_run' && 'push_rejected_at' in (w.payload ?? {}),
  );
  assertEquals(typeof (stamp?.payload as { push_rejected_at?: unknown })?.push_rejected_at, 'string');
  assertEquals(json.results[0].push_rejected, true);
  assertEquals(json.results[0].pushed, false);
});

Deno.test('a delivered push leaves no rejection stamp', async () => {
  const { writes, json } = await run(db());

  assertEquals(json.results[0].pushed, true);
  assertEquals('push_rejected' in json.results[0], false);
  assertEquals(
    writes.some((w) => 'push_rejected_at' in (w.payload ?? {})),
    false,
  );
});

Deno.test('a send that throws is our fault — the token survives', async () => {
  const fake = db();
  const { writes, json } = await run(fake, {
    projectId: () => {
      throw new Error('FCM_SERVICE_ACCOUNT_JSON secret is not set');
    },
  });

  assertEquals(writes.filter((w) => w.table === 'profile').length, 0);
  assertEquals(json.results[0].pushed, false);
  // The run is still recorded, so the dispatcher does not retry this user in 40 min.
  assertEquals(writes.some((w) => w.table === 'engine_run'), true);
});

// ---------- debug payload ----------

Deno.test('the garden dump is opt-in — pg_net stores every response', async () => {
  const plain = await run(db());
  assertEquals('signals' in plain.json.results[0], false);

  const debug = await run(db(), {}, { user_ids: ['u1'] }, {
    url: 'https://edge/smart-engine?debug=1',
  });
  assertEquals('signals' in debug.json.results[0], true);
});
