# Poglavje 4 — Supabase spremembe sheme (točen SQL)

> Dve migraciji: **`0005_m11_smart_engine.sql`** (4.1–4.3 + infra motorja) in
> **`0006_m11_community_agg.sql`** (4.4–4.6 V2 agregati). Vse additive-only (CLAUDE.md).
> `confidence` vrednosti v DB so **angleške** (`high`/`medium`) — slovenska poimenovanja
> (visoka/srednja) so samo v docs. Po deployu: `supabase db push` (geslo iz `.env`).

## 4.1 Novi stolpci na obstoječih tabelah (`0005`, prvi del)

```sql
-- ============================================================
-- 0005_m11_smart_engine.sql — smart suggestion engine (M11).
-- ============================================================

-- profile: IANA timezone (server-side local-day logic), public coarse climate
-- bucket, owner-only rich climate profile, FCM token (MVP: last device wins).
alter table profile
  add column timezone              text,
  add column climate_bucket        text,
  add column climate_profile       jsonb,
  add column fcm_token             text,
  add column fcm_token_updated_at  timestamptz;

-- task: frozen aggregation buckets snapshot, stamped by the client on 'done'
-- ({h3_r7, h3_r6, h3_r5, climate_bucket}) — skupnost-agregacija.md §4.2.
alter table task
  add column agg_context jsonb;

-- task_type: seasonal flag — time-percentile only for seasonal types (§4.3).
alter table task_type
  add column seasonal boolean not null default true;

-- Non-seasonal types (everything else stays true):
update task_type set seasonal = false where id in ('water', 'weed', 'stake', 'repot');
```

## 4.2 Nova tabela `plant_task_rule` (`0005`, drugi del)

```sql
-- Curated agronomy rules (catalog-like: public read, written only via seed
-- applied with the service role — clients never write).
create table plant_task_rule (
  id            text primary key,            -- '<ref_id>.<task>.<qualifier>' slug, add-only
  scope         text not null check (scope in ('plant', 'category')),
  ref_id        text not null,               -- plant.id or plant category slug
  task_type_id  text not null references task_type(id),
  timing_anchor text not null check (timing_anchor in
                  ('month_window', 'frost_offset', 'growth_stage', 'cadence_only')),
  -- "window" is a reserved word in Postgres — must stay quoted in raw SQL.
  "window"      jsonb not null,              -- shape per anchor, see docs/m11/01 §0
  cadence       text,                        -- human-readable; machine logic reads window
  frost_gate    boolean not null default false,
  weather_guard text,                        -- comma-joined guard codes (docs/m11/02 §G); null = none
  source_ref    text not null,               -- citation — mandatory audit trail
  confidence    text not null check (confidence in ('high', 'medium')),
  message_key   text not null                -- i18n key under suggestions.*
);

create index plant_task_rule_ref_idx  on plant_task_rule (scope, ref_id);
create index plant_task_rule_task_idx on plant_task_rule (task_type_id);

alter table plant_task_rule enable row level security;
create policy plant_task_rule_read on plant_task_rule
  for select to anon, authenticated using (true);
-- No insert/update/delete policies: only the service role (seed script) writes.
```

Seed vsebine: `tool/gen_rules_sql.dart` (vzorec po `tool/gen_catalog_sql.dart`) bere
`lib/data/seed/plant_task_rules_seed.dart` → `supabase/seed/plant_task_rules.sql`
(idempotenten `insert ... on conflict (id) do update`), apliciran prek
`supabase/seed/apply_catalog.py` vzorca. Vsebina = `01-agronomska-pravila.md`.

## 4.3 Tabeli `suggestion` + `suggestion_log` (`0005`, tretji del)

```sql
-- Suggestions surfaced to the user. WRITTEN BY THE ENGINE (service role);
-- the client only ever updates status (+updated_at) via normal sync push.
create table suggestion (
  id              uuid primary key,
  -- FK na auth.users je OBVEZEN: delete_account() (0004) briše auth.users in se
  -- zanaša izključno na ON DELETE CASCADE (GDPR) — brez FK vrstice osirotijo.
  user_id         uuid not null references auth.users(id) on delete cascade,
  rule_id         text not null,              -- 'R1'..'R7' engine rule
  plant_task_rule_id text references plant_task_rule(id),  -- null for R1–R4
  task_type_id    text not null references task_type(id),
  user_plant_id   uuid references user_plant(id) on delete cascade,
  area_id         uuid references area(id) on delete cascade,
  subject_key     text not null,              -- 'up:<id>' | 'ar:<id>' | 'cat:<slug>'
  message_key     text not null,
  message_params  jsonb not null default '{}'::jsonb,
  score           real not null,
  status          text not null default 'new'
                  check (status in ('new', 'planned', 'dismissed', 'logged', 'expired')),
                  -- 'logged' = user tapped 'Already done' (client also created a done task)
  dismiss_scope   text not null default 'season'
                  check (dismiss_scope in ('season', 'forever')),
                  -- on status='dismissed': 'season' → mute until window/sezona end,
                  -- 'forever' → permanent mute for (task_type, subject) ("Not interested")
  planned_task_id uuid references task(id),   -- set by client on 'Plan' AND on 'Already done'
  valid_until     date not null,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  deleted         boolean not null default false
);

create index suggestion_user_updated_idx on suggestion (user_id, updated_at);
create index suggestion_user_status_idx  on suggestion (user_id, status) where deleted = false;

alter table suggestion enable row level security;
create policy suggestion_select on suggestion
  for select to authenticated using (user_id = auth.uid());
-- Client sync-push is an upsert → needs insert+update, both fenced to own rows.
create policy suggestion_insert on suggestion
  for insert to authenticated with check (user_id = auth.uid());
create policy suggestion_update on suggestion
  for update to authenticated using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Engine guard state (cooldown / dismissed_until). SERVER-ONLY writer; the
-- client pulls a read-only mirror (no insert/update policies on purpose).
-- guard_key is FINE-GRAINED (docs/m11/03 §Guard key): plant_task_rule.id for
-- R5/R7, '<R>:<task_type_id>' for R1-R3/R6 — NOT the bare 'R5' (a bare engine
-- rule id would make "Don't suggest pruning" also mute fertilizing).
create table suggestion_log (
  user_id           uuid not null references auth.users(id) on delete cascade,
  guard_key         text not null,
  subject_key       text not null,
  last_suggested_at timestamptz,
  dismissed_until   timestamptz,
  updated_at        timestamptz not null default now(),
  primary key (user_id, guard_key, subject_key)
);

create index suggestion_log_user_updated_idx on suggestion_log (user_id, updated_at);

alter table suggestion_log enable row level security;
create policy suggestion_log_select on suggestion_log
  for select to authenticated using (user_id = auth.uid());
```

> **⚠️ `updated_at` ob strežniškem UPDATE:** Postgres `default now()` velja SAMO ob INSERT.
> Vsak strežniški UPDATE/UPSERT na `suggestion` (housekeeping: `status='expired'`, retencija
> `deleted=true`) in `suggestion_log` mora **eksplicitno** nastaviti `updated_at = now()`,
> sicer inkrementalni pull (`updated_at > last_pulled_at`) spremembe nikoli ne prinese na
> napravo (potekle kartice bi lokalno ostale žive). Engine to dela v `emit`/`housekeep` kodi.

```sql

-- Engine bookkeeping: one row per user, server-only (no client policies).
create table engine_run (
  user_id       uuid primary key references auth.users(id) on delete cascade,
  last_run_date date,                          -- user-local date of last engine run
  last_push_date date                          -- frequency cap: max 1 push per local day
);
alter table engine_run enable row level security;

-- Per-cell daily weather cache: users in the same r7 cell share one
-- Open-Meteo call. Server-only. Cleared by the nightly cron (older than 3 days).
create table weather_cache (
  h3_r7      text not null,
  date       date not null,
  payload    jsonb not null,
  fetched_at timestamptz not null default now(),
  primary key (h3_r7, date)
);
alter table weather_cache enable row level security;

-- Server-tunable knobs (K thresholds, weights, endpoints). Server-only.
create table app_config (
  key   text primary key,
  value jsonb not null
);
alter table app_config enable row level security;

insert into app_config (key, value) values
  ('k_privacy',         '5'),
  ('k_reliab',          '30'),
  ('eligibility',       '{"min_account_days": 14, "min_done_tasks": 10, "min_active_days": 5}'),
  ('engine',            '{"score_weather_window": 2.0, "score_season_window": 1.0,
                          "score_anniversary": 1.0, "score_window_closing": 0.5,
                          "score_low_supply": 0.5, "score_chain_ready": 2.0,
                          "score_overdue_per_day": 0.1, "score_mow_boost": 1.0,
                          "score_frost_protect_boost": 2.0, "emit_threshold": 2.0,
                          "push_cap_per_day": 1, "band_max_active": 3,
                          "dedup_planned_within_days": 14, "frost_safety_days": 7,
                          "suggestion_retention_days": 365}'),
  ('weather_thresholds','{"dry_hours_min": 24, "recent_rain_wet_mm": 2.0,
                          "rain_24h_mm": 1.0, "rain_48h_mm": 2.0, "heavy_rain_24h_mm": 10,
                          "wind_treat_kmh": 15, "wind_transplant_kmh": 20,
                          "soil_moist_min_mm_72h": 5}'),
  ('frost_defaults',    '{"last_frost_doy": 110, "first_frost_doy": 293}'),
  ('engine_endpoint',   '{"url": "https://<project-ref>.functions.supabase.co/smart-engine"}');

-- Helper for RLS gates on V2 aggregate tables (0006).
create or replace function k_privacy() returns int
language sql stable security definer set search_path = public as
$$ select (value)::int from app_config where key = 'k_privacy' $$;
```

## 4.4 V2 agregatne tabele (`0006_m11_community_agg.sql`, prvi del)

`plant_id` v PK ne sme biti NULL → **sentinel `''`** (prazen niz = agregat čez vse rastline).

```sql
-- ============================================================
-- 0006_m11_community_agg.sql — community aggregates (V2).
-- All four tables: WRITTEN ONLY by the nightly cron (security definer);
-- public-read behind k-anonymity RLS. No user_id is ever stored.
-- ============================================================

create table activity_recent (
  resolution       text not null check (resolution in ('r7','r6','r5','climate')),
  bucket_key       text not null,
  task_type_id     text not null references task_type(id),
  plant_id         text not null default '',   -- '' = across all plants
  distinct_users_7d int  not null,
  refreshed_at     timestamptz not null default now(),
  primary key (resolution, bucket_key, task_type_id, plant_id)
);

create table activity_season (
  resolution       text not null check (resolution in ('r7','r6','r5','climate')),
  bucket_key       text not null,
  task_type_id     text not null references task_type(id),
  plant_id         text not null default '',
  year             int  not null,
  iso_week         int  not null check (iso_week between 1 and 53),
  first_user_count int  not null,
  publishable      boolean not null default false,   -- cron-set gate (decision 6)
  primary key (resolution, bucket_key, task_type_id, plant_id, year, iso_week)
);

create table activity_frequency (
  resolution   text not null check (resolution in ('r7','r6','r5','climate')),
  bucket_key   text not null,
  task_type_id text not null references task_type(id),
  plant_id     text not null default '',
  season_year  int  not null,
  n_users      int  not null,
  per_user_p25 real not null,
  per_user_p50 real not null,
  per_user_p75 real not null,
  unit         text not null default 'per_season',
  hist         jsonb not null default '{}'::jsonb,   -- {"1":4,"2":9,...,"5+":3}
  primary key (resolution, bucket_key, task_type_id, plant_id, season_year)
);

create table bucket_population (
  resolution     text not null check (resolution in ('r7','r6','r5','climate')),
  bucket_key     text not null,
  distinct_users int  not null,
  refreshed_at   timestamptz not null default now(),
  primary key (resolution, bucket_key)
);

-- RLS: public read, k-anonymous (skupnost-agregacija.md §6, §10).
alter table activity_recent    enable row level security;
alter table activity_season    enable row level security;
alter table activity_frequency enable row level security;
alter table bucket_population  enable row level security;

create policy activity_recent_read on activity_recent
  for select to anon, authenticated using (distinct_users_7d >= k_privacy());
create policy activity_season_read on activity_season
  for select to anon, authenticated using (publishable);
create policy activity_frequency_read on activity_frequency
  for select to anon, authenticated using (n_users >= k_privacy());
create policy bucket_population_read on bucket_population
  for select to anon, authenticated using (distinct_users >= k_privacy());
```

## 4.5 Pogled `eligible_user` + skupni dogodkovni pogled (`0006`, drugi del)

```sql
-- Eligible users (anti-junk X/N/M, decision 8). Service-only: the matview is
-- read by the cron and never exposed to clients.
create materialized view eligible_user as
select u.id as user_id
from auth.users u
join task t on t.user_id = u.id and t.deleted = false and t.status = 'done'
group by u.id, u.created_at
having u.created_at <= now() - make_interval(days =>
         (select (value->>'min_account_days')::int from app_config where key = 'eligibility'))
   and count(*) >=
         (select (value->>'min_done_tasks')::int from app_config where key = 'eligibility')
   and count(distinct t.date::date) >=
         (select (value->>'min_active_days')::int from app_config where key = 'eligibility');

create unique index eligible_user_pk on eligible_user (user_id);
revoke all on eligible_user from anon, authenticated;

-- Shared event view for all aggregates: completion events of eligible users,
-- bucketed via COALESCE(task.agg_context, current profile) (decision 1) and
-- binned into the user's LOCAL day (decision 5). One row with plant_id = ''
-- (across plants) plus one row per distinct canonical plant subject.
create or replace view agg_event as
with base as (
  select
    t.id as task_id,
    t.user_id,
    t.task_type_id,
    (t.date at time zone coalesce(p.timezone, 'UTC'))::date as local_day,
    coalesce(t.agg_context->>'h3_r7', p.h3_r7)                   as h3_r7,
    coalesce(t.agg_context->>'h3_r6', p.h3_r6)                   as h3_r6,
    coalesce(t.agg_context->>'h3_r5', p.h3_r5)                   as h3_r5,
    coalesce(t.agg_context->>'climate_bucket', p.climate_bucket) as climate_bucket
  from task t
  join profile p       on p.user_id = t.user_id
  join eligible_user e on e.user_id = t.user_id
  where t.status = 'done' and t.deleted = false
),
plants as (
  select ts.task_id, up.plant_id
  from task_subject ts
  join user_plant up on up.id = ts.user_plant_id
  where ts.deleted = false and up.is_custom = false and up.plant_id is not null
  group by ts.task_id, up.plant_id
)
select b.*, ''::text as plant_id from base b
union all
select b.*, pl.plant_id from base b join plants pl on pl.task_id = b.task_id;

revoke all on agg_event from anon, authenticated;
```

## 4.6 Nočni agregat — funkcija + pg_cron (`0006`, tretji del)

```sql
create extension if not exists pg_cron;

create or replace function agg_refresh_all() returns void
language plpgsql security definer set search_path = public as
$$
declare
  cur_year int := extract(year from current_date)::int;
begin
  refresh materialized view eligible_user;

  -- 1) FEED — sliding 7-day window [today-7, yesterday]; COUNT(DISTINCT) directly
  --    over the raw window (past §8.3 — never a sum of daily counts).
  delete from activity_recent;
  insert into activity_recent
        (resolution, bucket_key, task_type_id, plant_id, distinct_users_7d, refreshed_at)
  select v.resolution, v.bucket_key, e.task_type_id, e.plant_id,
         count(distinct e.user_id), now()
  from agg_event e
  cross join lateral (values
      ('r7', e.h3_r7), ('r6', e.h3_r6), ('r5', e.h3_r5), ('climate', e.climate_bucket)
    ) as v(resolution, bucket_key)
  where v.bucket_key is not null
    and e.local_day between current_date - 7 and current_date - 1
  group by v.resolution, v.bucket_key, e.task_type_id, e.plant_id;

  -- 2) SEASON CURVE — first completions per (user, type, plant, year); current
  --    year recomputed nightly, past years are frozen (never touched again).
  delete from activity_season where year = cur_year;
  insert into activity_season
        (resolution, bucket_key, task_type_id, plant_id, year, iso_week,
         first_user_count, publishable)
  select f.resolution, f.bucket_key, f.task_type_id, f.plant_id, cur_year,
         extract(week from f.first_day)::int, count(*), false
  from (
    select v.resolution, v.bucket_key, e.task_type_id, e.plant_id, e.user_id,
           min(e.local_day) as first_day
    from agg_event e
    cross join lateral (values
        ('r7', e.h3_r7), ('r6', e.h3_r6), ('r5', e.h3_r5), ('climate', e.climate_bucket)
      ) as v(resolution, bucket_key)
    where v.bucket_key is not null
      and extract(year from e.local_day)::int = cur_year
    group by v.resolution, v.bucket_key, e.task_type_id, e.plant_id, e.user_id
  ) f
  group by f.resolution, f.bucket_key, f.task_type_id, f.plant_id,
           extract(week from f.first_day);

  -- Publishable gate (decision 6): pooled total over the whole group ≥ K_privacy.
  update activity_season s
  set publishable = g.ok
  from (
    select resolution, bucket_key, task_type_id, plant_id,
           sum(first_user_count) >= k_privacy() as ok
    from activity_season
    group by resolution, bucket_key, task_type_id, plant_id
  ) g
  where s.resolution = g.resolution and s.bucket_key = g.bucket_key
    and s.task_type_id = g.task_type_id and s.plant_id = g.plant_id
    and s.publishable is distinct from g.ok;

  -- 3) FREQUENCY — median + IQR among performers, current season only (§8.14).
  delete from activity_frequency where season_year = cur_year;
  with per_user as (
    select v.resolution, v.bucket_key, e.task_type_id, e.plant_id, e.user_id,
           count(*) as n_events
    from agg_event e
    cross join lateral (values
        ('r7', e.h3_r7), ('r6', e.h3_r6), ('r5', e.h3_r5), ('climate', e.climate_bucket)
      ) as v(resolution, bucket_key)
    where v.bucket_key is not null
      and extract(year from e.local_day)::int = cur_year
    group by v.resolution, v.bucket_key, e.task_type_id, e.plant_id, e.user_id
  ),
  stats as (
    select resolution, bucket_key, task_type_id, plant_id,
           count(*) as n_users,
           percentile_cont(0.25) within group (order by n_events)::real as p25,
           percentile_cont(0.50) within group (order by n_events)::real as p50,
           percentile_cont(0.75) within group (order by n_events)::real as p75
    from per_user
    group by resolution, bucket_key, task_type_id, plant_id
  ),
  hists as (
    select resolution, bucket_key, task_type_id, plant_id,
           jsonb_object_agg(band, cnt) as hist
    from (
      select resolution, bucket_key, task_type_id, plant_id,
             case when n_events >= 5 then '5+' else n_events::text end as band,
             count(*) as cnt
      from per_user
      group by resolution, bucket_key, task_type_id, plant_id,
               case when n_events >= 5 then '5+' else n_events::text end
    ) b
    group by resolution, bucket_key, task_type_id, plant_id
  )
  insert into activity_frequency
        (resolution, bucket_key, task_type_id, plant_id, season_year,
         n_users, per_user_p25, per_user_p50, per_user_p75, unit, hist)
  select s.resolution, s.bucket_key, s.task_type_id, s.plant_id, cur_year,
         s.n_users, s.p25, s.p50, s.p75, 'per_season', h.hist
  from stats s
  join hists h using (resolution, bucket_key, task_type_id, plant_id);

  -- 4) BUCKET POPULATION — eligible users per bucket, task-independent (§5.5).
  delete from bucket_population;
  insert into bucket_population (resolution, bucket_key, distinct_users, refreshed_at)
  select v.resolution, v.bucket_key, count(distinct p.user_id), now()
  from profile p
  join eligible_user e on e.user_id = p.user_id
  cross join lateral (values
      ('r7', p.h3_r7), ('r6', p.h3_r6), ('r5', p.h3_r5), ('climate', p.climate_bucket)
    ) as v(resolution, bucket_key)
  where v.bucket_key is not null
  group by v.resolution, v.bucket_key;

  -- Housekeeping: drop stale weather cache rows.
  delete from weather_cache where date < current_date - 3;
end;
$$;

select cron.schedule('agg-nightly', '30 2 * * *', $$select public.agg_refresh_all()$$);
```

> **Inkrementalnost:** `activity_recent`/`bucket_population` sta drobni → full replace je
> najpreprostejša idempotentna oblika; `activity_season`/`activity_frequency` preračunata
> SAMO tekoče leto (pretekla zamrznjena) → cena raste z aktivnostjo enega leta, ne vse zgodovine.

## 4.7 Dnevni motor — dispatch (pg_cron + pg_net) + Edge Function

```sql
create extension if not exists pg_net;

-- Dispatcher: every 30 min, pick users whose LOCAL time is past 07:00 (and
-- before noon — catch-up for big batches) and who have not run today; POST a
-- batch of ids to the smart-engine Edge Function. Service JWT from Vault.
create or replace function engine_dispatch() returns void
language plpgsql security definer set search_path = public as
$$
declare
  ids uuid[];
  endpoint text := (select value->>'url' from app_config where key = 'engine_endpoint');
  srv_key  text := (select decrypted_secret from vault.decrypted_secrets
                    where name = 'engine_service_key');
begin
  select array_agg(user_id) into ids from (
    select p.user_id
    from profile p
    left join engine_run r on r.user_id = p.user_id
    where (now() at time zone coalesce(p.timezone, 'UTC'))::time >= time '07:00'
      and (now() at time zone coalesce(p.timezone, 'UTC'))::time <  time '12:00'
      and (r.last_run_date is null
           or r.last_run_date < (now() at time zone coalesce(p.timezone, 'UTC'))::date)
    -- Batch 25 (ne več): worst-case uporabnik = svež weather fetch s 3 retry-ji
    -- (13 s sleep + do 4×10 s timeout ≈ 53 s; per-invocation memo deli en fetch
    -- na celico, tudi neuspelega) → 50 bi lahko prebil Edge Function wall-clock
    -- limit. Dispatcher itak pobere ostanek čez 30 min (engine_run filter).
    limit 25
  ) u;

  if ids is null then return; end if;

  perform net.http_post(
    url     := endpoint,
    headers := jsonb_build_object(
                 'Authorization', 'Bearer ' || srv_key,
                 'Content-Type', 'application/json'),
    body    := jsonb_build_object('user_ids', to_jsonb(ids))
  );
end;
$$;

select cron.schedule('engine-dispatch', '*/30 * * * *', $$select public.engine_dispatch()$$);
```

> Vault setup (enkratno, prek SQL editorja — ne v migracijo, ker vsebuje skrivnost):
> `select vault.create_secret('<service_role_jwt>', 'engine_service_key');`

**Edge Function `supabase/functions/smart-engine/index.ts`** (Deno, TypeScript) — psevdokoda
z vsemi koraki (polna logika = `03-pravila-r1-r7.md` §Cevovod):

```ts
// deno imports: @supabase/supabase-js (service client), h3-js (cellToLatLng), jose (FCM JWT)
Deno.serve(async (req) => {
  assertServiceRole(req);                              // Authorization == service key
  const { user_ids } = await req.json();
  const db = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);
  const cfg = await loadAppConfig(db);                 // engine + weather_thresholds + frost_defaults
  const rules = await db.from('plant_task_rule').select('*');   // cached per invocation

  for (const userId of user_ids) {
    try {
      const u = await loadUserBundle(db, userId);      // §Cevovod korak 1
      housekeepDismissedAndExpired(db, u);             // korak 2
      const weather = await cellWeather(db, u.profile.h3_r7);   // weather_cache ali fetch
      const signals = buildSignals(u, weather, cfg);   // Poglavje 2
      let candidates = [
        ...r5(u, rules, signals, cfg), ...r7(u, rules, signals, cfg),
        ...r3(u, rules, signals, cfg), ...r2(u, signals, cfg), ...r1(u, rules, signals, cfg),
      ];
      candidates = enrichR4(candidates, u, signals, cfg);
      candidates = applyGuards(candidates, u, signals, cfg);    // korak 5 (a–h)
      candidates = dedupAndRank(candidates, cfg);               // koraka 6–7
      await emit(db, u, candidates, cfg);              // korak 8: insert + log + FCM (max 1)
      await db.from('engine_run').upsert({ user_id: userId, last_run_date: u.localToday });
    } catch (e) {
      console.error('engine user failed', userId, e);  // en uporabnik ne podre batcha
    }
  }
  return new Response('ok');
});

async function cellWeather(db, h3r7) {
  if (!h3r7) return null;                              // brez lokacije → brez vremenskih signalov
  // Dan = UPORABNIKOV lokalni dan (coalesce(timezone,'UTC') — isto kot dispatch okno).
  // UTC ključ bi na UTC+8..+11 dvema zaporednima lokalnima jutroma vrnil isti payload
  // (pregled M11.8). Neuspeli fetchi se memo-irajo na invokacijo (en retry ladder/celico).
  const today = userLocalToday(profile.timezone);
  const hit = await db.from('weather_cache').select('payload')
    .eq('h3_r7', h3r7).eq('date', today).maybeSingle();
  if (hit.data) return hit.data.payload;
  const [lat, lon] = cellToLatLng(h3r7);               // CENTROID celice — nikoli koordinate uporabnika
  const payload = await fetchOpenMeteoWithRetry(lat, lon);   // 3 poskusi, backoff 1s/3s/9s; null ob fail
  if (payload) await db.from('weather_cache').upsert({ h3_r7: h3r7, date: today, payload });
  return payload;
}
```

## 4.8 FCM pošiljanje iz Supabase (HTTP v1)

Legacy server key je **ukinjen** (jun. 2024) → uporabimo **FCM HTTP v1 API** s service
accountom:

1. Firebase Console → Project settings → Service accounts → **Generate new private key** →
   prenesi JSON.
2. `supabase secrets set FCM_SERVICE_ACCOUNT_JSON="$(cat service-account.json)"`
   (+ `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` sta v Edge Functions že na voljo).
3. Skupni modul `supabase/functions/_shared/fcm.ts`:

```ts
import { SignJWT, importPKCS8 } from 'jose';

let cachedToken: { token: string; exp: number } | null = null;

async function oauthToken(): Promise<string> {
  if (cachedToken && cachedToken.exp > Date.now() / 1000 + 60) return cachedToken.token;
  const sa = JSON.parse(Deno.env.get('FCM_SERVICE_ACCOUNT_JSON')!);
  const key = await importPKCS8(sa.private_key, 'RS256');
  const jwt = await new SignJWT({ scope: 'https://www.googleapis.com/auth/firebase.messaging' })
    .setProtectedHeader({ alg: 'RS256' })
    .setIssuer(sa.client_email).setAudience(sa.token_uri)
    .setIssuedAt().setExpirationTime('1h').sign(key);
  const res = await fetch(sa.token_uri, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion: jwt,
    }),
  });
  const { access_token, expires_in } = await res.json();
  cachedToken = { token: access_token, exp: Date.now() / 1000 + expires_in };
  return access_token;
}

/// Sends one suggestion push; returns false on UNREGISTERED (caller nulls the token).
export async function sendSuggestionPush(opts: {
  fcmToken: string; projectId: string;
  title: string; body: string; suggestionId: string;
}): Promise<boolean> {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${opts.projectId}/messages:send`,
    {
      method: 'POST',
      headers: { Authorization: `Bearer ${await oauthToken()}`,
                 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message: {
          token: opts.fcmToken,
          notification: { title: opts.title, body: opts.body },
          data: { type: 'suggestion', suggestion_id: opts.suggestionId },
          android: { notification: { channel_id: 'suggestions' } },
        },
      }),
    },
  );
  if (res.status === 404 || res.status === 400) return false;   // UNREGISTERED/invalid token
  if (!res.ok) throw new Error(`FCM ${res.status}: ${await res.text()}`);
  return true;
}
```

4. Push **besedilo** lokalizira strežnik iz `profile.lang` (en/sl/de; null → en) — Edge
   Function ima minimalen slovar push naslovov (`_shared/push_i18n.ts`, ki ga generira
   `tool/gen_push_i18n.dart` iz `i18n/*.i18n.json` rezine `suggestions.*.title` — poženi ob
   vsaki spremembi ključev, korak M11.12); telo v pasu na Domov pa vedno prevede klient
   (poln slang).
5. Ob `false` (UNREGISTERED): `update profile set fcm_token = null where user_id = ...`.

## 4.9 Entitlement (Tendask+, za M11.20)

```sql
-- 0007_entitlement.sql (ob koraku M11.20)
create table entitlement (
  user_id          uuid primary key references auth.users(id) on delete cascade,
  product          text not null default 'tendask_plus',
  status           text not null default 'none'
                   check (status in ('none', 'trial', 'active', 'expired')),
  trial_started_at timestamptz,
  expires_at       timestamptz,
  updated_at       timestamptz not null default now()
);
alter table entitlement enable row level security;
create policy entitlement_select on entitlement
  for select to authenticated using (user_id = auth.uid());
-- Writes: only Edge Functions 'start-trial' (server-validated, once per user)
-- and 'play-rtdn' (Google Play Real-Time Developer Notifications webhook).
```
