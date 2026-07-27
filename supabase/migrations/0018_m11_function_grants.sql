-- ============================================================
-- 0018_m11_function_grants.sql — close the engine's server-only surface.
--
-- Same gap 0010 closed for tables, now for functions and for the three M11
-- tables 0008/0010 never covered. Supabase's default privileges GRANT EXECUTE
-- on new public functions to anon/authenticated explicitly, so the
-- `revoke execute ... from public` in 0007/0009 left those grants in place: the
-- nightly dispatch and the aggregate refresh were callable with the anon key.
--
-- Also raises the frequency aggregate's row gate from k_privacy to k_reliab. At
-- n_users = 5 the published histogram ({"1":1,"2":1,...}) is one bar per person
-- and percentile_cont returns actual individual counts — a k=1 disclosure
-- dressed as an aggregate. The client already refuses to put numbers on a group
-- that thin (kCommunityReliabilityMin), so nothing readable is lost.
--
-- Idempotent: revoke/grant are no-ops on repeat, the policy is dropped first.
-- ============================================================

-- ----- 1. server-only functions -------------------------------------------
-- Called by pg_cron as the table owner and by nothing else. Service-role calls
-- bypass grants, so revoking costs the engine nothing.
revoke all on function public.engine_dispatch() from public, anon, authenticated;
revoke all on function public.agg_refresh_all() from public, anon, authenticated;

-- ⚠️ public.k_privacy() MUST stay executable by anon/authenticated: the RLS
-- policies on all four aggregate tables call it in the caller's context, so a
-- revoke here would close community reads entirely. Not touched on purpose.

-- ----- 2. threshold helper for the reliability gate ------------------------
-- Mirrors k_privacy() (0008): security definer with a pinned search_path so an
-- empty one still resolves, schema-qualified read.
create or replace function k_reliab() returns int
language sql stable security definer set search_path = '' as
$$ select (value)::int from public.app_config where key = 'k_reliab' $$;

revoke all on function public.k_reliab() from public;
grant execute on function public.k_reliab() to anon, authenticated;

-- ----- 3. frequency rows: reliable groups only -----------------------------
drop policy if exists activity_frequency_read on activity_frequency;
create policy activity_frequency_read on activity_frequency
  for select to anon, authenticated using (n_users >= public.k_reliab());

-- ----- 4. engine-internal tables ------------------------------------------
-- RLS with no policies already fails closed for clients; this makes the grant
-- level agree, so one mistaken future policy cannot open app_config (which
-- carries engine_endpoint) or the cached forecasts.
revoke all on engine_run, weather_cache, app_config from anon, authenticated;

-- ----- 5. season curve: weekly rows only for a reliable group ---------------
-- A weekly row is k-anonymous only through its group: `publishable` gated the
-- GROUP at k_privacy (5), while a single week inside it may carry
-- first_user_count = 1 — "exactly one gardener here first sowed tomatoes in
-- week 12". Filtering such rows out instead would be worse than the disclosure:
-- the client normalises the curve over the rows it receives, so hidden weeks do
-- not leave a gap, they silently re-scale every percentage. So the gate moves to
-- the group: below k_reliab no curve is published at all, and the client widens
-- to the next geography level (§7.4) rather than reading a truncated one.
--
-- The body below is 0009's agg_refresh_all() verbatim except that one gate.
-- Re-declaring the whole function is how Postgres replaces one; keep this copy
-- authoritative from now on.
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

  -- Publishable gate (0018, supersedes decision 6): pooled total over the whole
  -- group ≥ K_reliab. Weekly rows are only k-anonymous as a group, so a group
  -- thin enough to publish a first_user_count = 1 week must not publish at all.
  update public.activity_season s
  set publishable = g.ok
  from (
    select resolution, bucket_key, task_type_id, plant_id,
           sum(first_user_count) >= public.k_reliab() as ok
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

-- Bring existing rows in line at once (no-op while the cron has never run).
update public.activity_season s
set publishable = g.ok
from (
  select resolution, bucket_key, task_type_id, plant_id,
         sum(first_user_count) >= public.k_reliab() as ok
  from public.activity_season
  group by resolution, bucket_key, task_type_id, plant_id
) g
where s.resolution = g.resolution and s.bucket_key = g.bucket_key
  and s.task_type_id = g.task_type_id and s.plant_id = g.plant_id
  and s.publishable is distinct from g.ok;

-- Unchanged from 0009, restated so the season gate reads in one place: the
-- policy trusts `publishable`, which now means "the group cleared k_reliab".
drop policy if exists activity_season_read on activity_season;
create policy activity_season_read on activity_season
  for select to anon, authenticated using (publishable);

-- `create or replace` above resets the function's own grants, so restate the
-- revoke from §1. The pg_cron schedule from 0009 keeps calling the same name.
revoke all on function public.agg_refresh_all() from public, anon, authenticated;
