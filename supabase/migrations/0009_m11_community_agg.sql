-- ============================================================
-- 0009_m11_community_agg.sql — community aggregates (V2 / Faza E).
-- docs/m11/04 §4.4–4.6. Additive-only (CLAUDE.md).
--
-- Four public-read aggregate tables (k-anonymous RLS, NO user_id ever stored),
-- the service-only eligible_user matview + agg_event view, and the nightly
-- agg_refresh_all() cron. Every writer is the cron (security definer); clients
-- only ever read, gated by k_privacy() (from 0006).
--
-- Two deliberate deltas from docs/m11/04 (both follow the hardening this project
-- already committed to in 0007/0008, not the doc's verbatim §4.6 SQL):
--   * agg_refresh_all() uses `set search_path = ''` + schema-qualified objects
--     (the doc wrote `public`) so a planted object in a writable schema can't
--     shadow profile/app_config/aggregate tables in a security-definer body.
--   * Explicit GRANT SELECT on the four read tables: RLS gates rows, grants gate
--     table access — PostgREST needs BOTH (0008 §2b convention).
-- The migration filename is 0009 because 0007/0008 are already taken (the doc
-- still calls it "0007_m11_community_agg" — same content, different number).
-- ============================================================

-- ----- 4.4 aggregate tables ------------------------------------------------
-- plant_id '' sentinel = "across all plants" (a NULL can't sit in a PK).

-- Idempotent (if not exists / drop-then-create policy): 0006–0010 live out-of-band
-- on prod; a ledger-reconcile `supabase db push` re-applies them and must not error.
create table if not exists activity_recent (
  resolution        text not null check (resolution in ('r7','r6','r5','climate')),
  bucket_key        text not null,
  task_type_id      text not null references task_type(id),
  plant_id          text not null default '',   -- '' = across all plants
  distinct_users_7d int  not null,
  refreshed_at      timestamptz not null default now(),
  primary key (resolution, bucket_key, task_type_id, plant_id)
);

create table if not exists activity_season (
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

create table if not exists activity_frequency (
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

create table if not exists bucket_population (
  resolution     text not null check (resolution in ('r7','r6','r5','climate')),
  bucket_key     text not null,
  distinct_users int  not null,
  refreshed_at   timestamptz not null default now(),
  primary key (resolution, bucket_key)
);

-- RLS: public read, k-anonymous (skupnost-agregacija.md §6, §10). No user_id is
-- ever stored, so a readable row exposes only a count over ≥ k_privacy() users.
alter table activity_recent    enable row level security;
alter table activity_season    enable row level security;
alter table activity_frequency enable row level security;
alter table bucket_population   enable row level security;

drop policy if exists activity_recent_read on activity_recent;
create policy activity_recent_read on activity_recent
  for select to anon, authenticated using (distinct_users_7d >= public.k_privacy());
drop policy if exists activity_season_read on activity_season;
create policy activity_season_read on activity_season
  for select to anon, authenticated using (publishable);
drop policy if exists activity_frequency_read on activity_frequency;
create policy activity_frequency_read on activity_frequency
  for select to anon, authenticated using (n_users >= public.k_privacy());
drop policy if exists bucket_population_read on bucket_population;
create policy bucket_population_read on bucket_population
  for select to anon, authenticated using (distinct_users >= public.k_privacy());

-- Grants: read-only for clients (the cron writes via the service role, which
-- bypasses grants). Revoke the Supabase default ALL grant first, then grant
-- exactly SELECT — RLS gates rows, grants gate table access, and the new tables
-- must not be writable at the grant level (0008 §2b deterministic-API convention).
revoke all on activity_recent, activity_season, activity_frequency, bucket_population
  from anon, authenticated;
grant select on activity_recent, activity_season, activity_frequency, bucket_population
  to anon, authenticated;

-- ----- 4.5 eligible_user matview + agg_event view --------------------------
-- Eligible users (anti-junk min account age / done count / active days,
-- decision 8). Service-only: read by the cron, never exposed to clients.
create materialized view if not exists eligible_user as
select u.id as user_id
from auth.users u
join public.task t on t.user_id = u.id and t.deleted = false and t.status = 'done'
group by u.id, u.created_at
having u.created_at <= now() - make_interval(days =>
         (select (value->>'min_account_days')::int from public.app_config where key = 'eligibility'))
   and count(*) >=
         (select (value->>'min_done_tasks')::int from public.app_config where key = 'eligibility')
   and count(distinct t.date::date) >=
         (select (value->>'min_active_days')::int from public.app_config where key = 'eligibility');

create unique index if not exists eligible_user_pk on eligible_user (user_id);
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
  from public.task t
  join public.profile p       on p.user_id = t.user_id
  join public.eligible_user e on e.user_id = t.user_id
  where t.status = 'done' and t.deleted = false
),
plants as (
  select ts.task_id, up.plant_id
  from public.task_subject ts
  join public.user_plant up on up.id = ts.user_plant_id
  where ts.deleted = false and up.is_custom = false and up.plant_id is not null
  group by ts.task_id, up.plant_id
)
select b.*, ''::text as plant_id from base b
union all
select b.*, pl.plant_id from base b join plants pl on pl.task_id = b.task_id;

revoke all on agg_event from anon, authenticated;

-- ----- 4.6 nightly aggregate function + pg_cron ----------------------------
create extension if not exists pg_cron;

-- security definer + search_path = '' (hardened, see header): every object is
-- schema-qualified so it resolves with an empty search_path and can't be shadowed.
create or replace function agg_refresh_all() returns void
language plpgsql security definer set search_path = '' as
$$
declare
  cur_year int := extract(year from current_date)::int;
begin
  -- Server-dark master switch (mirror of client kSuggestionsEnabled): skip the
  -- whole nightly refresh while disabled. Flip app_config.engine_enabled at launch.
  if not coalesce(
       (select (value)::boolean from public.app_config where key = 'engine_enabled'),
       false) then
    return;
  end if;

  refresh materialized view public.eligible_user;

  -- 1) FEED — sliding 7-day window [today-7, yesterday]; COUNT(DISTINCT) directly
  --    over the raw window (skupnost §8.3 — never a sum of daily counts).
  delete from public.activity_recent;
  insert into public.activity_recent
        (resolution, bucket_key, task_type_id, plant_id, distinct_users_7d, refreshed_at)
  select v.resolution, v.bucket_key, e.task_type_id, e.plant_id,
         count(distinct e.user_id), now()
  from public.agg_event e
  cross join lateral (values
      ('r7', e.h3_r7), ('r6', e.h3_r6), ('r5', e.h3_r5), ('climate', e.climate_bucket)
    ) as v(resolution, bucket_key)
  where v.bucket_key is not null
    and e.local_day between current_date - 7 and current_date - 1
  group by v.resolution, v.bucket_key, e.task_type_id, e.plant_id;

  -- 2) SEASON CURVE — first completions per (user, type, plant, year); current
  --    year recomputed nightly, past years are frozen (never touched again).
  delete from public.activity_season where year = cur_year;
  insert into public.activity_season
        (resolution, bucket_key, task_type_id, plant_id, year, iso_week,
         first_user_count, publishable)
  select f.resolution, f.bucket_key, f.task_type_id, f.plant_id, cur_year,
         extract(week from f.first_day)::int, count(*), false
  from (
    select v.resolution, v.bucket_key, e.task_type_id, e.plant_id, e.user_id,
           min(e.local_day) as first_day
    from public.agg_event e
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
  update public.activity_season s
  set publishable = g.ok
  from (
    select resolution, bucket_key, task_type_id, plant_id,
           sum(first_user_count) >= public.k_privacy() as ok
    from public.activity_season
    group by resolution, bucket_key, task_type_id, plant_id
  ) g
  where s.resolution = g.resolution and s.bucket_key = g.bucket_key
    and s.task_type_id = g.task_type_id and s.plant_id = g.plant_id
    and s.publishable is distinct from g.ok;

  -- 3) FREQUENCY — median + IQR among performers, current season only (§8.14).
  delete from public.activity_frequency where season_year = cur_year;
  with per_user as (
    select v.resolution, v.bucket_key, e.task_type_id, e.plant_id, e.user_id,
           count(*) as n_events
    from public.agg_event e
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
  insert into public.activity_frequency
        (resolution, bucket_key, task_type_id, plant_id, season_year,
         n_users, per_user_p25, per_user_p50, per_user_p75, unit, hist)
  select s.resolution, s.bucket_key, s.task_type_id, s.plant_id, cur_year,
         s.n_users, s.p25, s.p50, s.p75, 'per_season', h.hist
  from stats s
  join hists h using (resolution, bucket_key, task_type_id, plant_id);

  -- 4) BUCKET POPULATION — eligible users per bucket, task-independent (§5.5).
  delete from public.bucket_population;
  insert into public.bucket_population (resolution, bucket_key, distinct_users, refreshed_at)
  select v.resolution, v.bucket_key, count(distinct p.user_id), now()
  from public.profile p
  join public.eligible_user e on e.user_id = p.user_id
  cross join lateral (values
      ('r7', p.h3_r7), ('r6', p.h3_r6), ('r5', p.h3_r5), ('climate', p.climate_bucket)
    ) as v(resolution, bucket_key)
  where v.bucket_key is not null
  group by v.resolution, v.bucket_key;

  -- Housekeeping: drop stale weather cache rows (older than 3 days).
  delete from public.weather_cache where date < current_date - 3;
end;
$$;

-- Server-only: the cron runs as the function owner. Revoke the default PUBLIC
-- grant so no anon/authenticated user can trigger a full refresh via PostgREST
-- RPC (matches engine_dispatch() in 0007).
revoke execute on function public.agg_refresh_all() from public;

-- Idempotent (re)schedule: drop any existing job of this name first so a replay
-- against the shared live DB cannot duplicate or error (0007 convention).
select cron.unschedule(jobid) from cron.job where jobname = 'agg-nightly';

select cron.schedule('agg-nightly', '30 2 * * *', $$select public.agg_refresh_all()$$);
