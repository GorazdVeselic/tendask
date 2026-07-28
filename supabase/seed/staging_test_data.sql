-- staging_test_data.sql — synthetic neighbours so the community surfaces have
-- something to say. STAGING ONLY.
--
-- Why it exists: every community read is k-anonymous. Below k_privacy (5) a
-- bucket returns NOTHING, and below k_reliab (30) it returns descriptive bands
-- instead of numbers. A tester with three neighbours therefore sees empty
-- cards and cannot tell a working feature from a broken one. This creates
-- enough of a neighbourhood to cross BOTH thresholds.
--
-- The head count is NOT the number that matters — the COHORT count is (0017):
--   plant_id = '<plant>'  events on that catalog plant
--   plant_id = '@site'    events with no catalog plant subject
--   plant_id = ''         the contaminated superset, NEVER used for comparison
-- and 0018 raised the season/frequency gate from k_privacy (5) to k_reliab (30).
-- So a neighbourhood spread thin across cohorts publishes NOTHING comparable
-- while every counter still reads healthy. An earlier version of this file split
-- 40 neighbours 20/20 and the plant half across five species (4 each): the only
-- group over 30 was the one cohort 0017 forbids, so the whole paid surface was
-- empty and no output said why. Hence the deliberate shape below — two cohorts,
-- each comfortably over k_reliab, and nothing else.
--
-- On top of that the aggregates only count ELIGIBLE users (0009 eligible_user):
-- account older than min_account_days, at least min_done_tasks completions on
-- at least min_active_days distinct days. A neighbour that misses any of the
-- three is invisible — which is exactly the confusing empty state again.
--
--   wsl -e bash -lc "cat .../supabase/seed/staging_test_data.sql \
--     | docker exec -i supabase-db psql -v ON_ERROR_STOP=1 -U postgres -d postgres"
--
-- Idempotent: re-running replaces the synthetic rows, never touches real ones.

\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------------
-- Interlock. The marker is a property of the ENVIRONMENT, not of the command,
-- so no flag, no typo and no copy-pasted shell line can run this on production.
-- Set it once per staging stack:
--   insert into app_config(key, value) values ('env', '"staging"')
--     on conflict (key) do update set value = excluded.value;
-- ---------------------------------------------------------------------------
do $$
begin
  if not exists (
    select 1 from public.app_config where key = 'env' and value = '"staging"'::jsonb
  ) then
    raise exception
      'refusing to seed: app_config.env is not "staging" — this database is not a staging stack';
  end if;
end $$;

do $$
declare
  -- Split so BOTH comparison cohorts clear k_reliab (30) on their own:
  -- 1..n_site have no plant subject at all (the '@site' cohort), the rest all
  -- garden the SAME plant. Spreading the plant half over several species is what
  -- broke this before — five cohorts of four publish nothing.
  n_neighbours constant int := 70;
  n_site       constant int := 35;   -- @site = 35, cohort_plant = 35, both > 30
  cohort_plant constant text := 'apple';
  -- Synthetic ids all share this prefix, which is what makes the re-run safe:
  -- nothing outside it is ever touched.
  id_prefix constant text := '00000000-0000-4000-8000-';
  v_cell_r7   text;
  v_cell_r6   text;
  v_cell_r5   text;
  v_tz        text;
  i         int;
  v_uid       uuid;
  v_plant_id  text;
  v_up_id     uuid;
  v_task_id   uuid;
  v_yr        int;
  k         int;
  v_first_week int;
  d         date;
  -- 'water' is seasonal = false in the catalog, and the client drops the timing
  -- curve for such a type before it ever queries (community_providers.dart:73).
  -- Seeding it gives that path a visible proof: frequency card present, timing
  -- card absent. Without it the screen says "not enough gardeners" instead, and
  -- the two causes are indistinguishable. Five executions per season cover all
  -- four types per user, so every cohort keeps its full head count.
  types     constant text[] := array['prune', 'fertilize', 'mow', 'water'];
begin
  -- The neighbourhood has to be the tester's own, or the app widens past it and
  -- shows nothing. Taken from the real profile rather than pasted in.
  -- The freshest profile breaks the tie: with two test accounts in two cells
  -- every group has count(*) = 1, and picking arbitrarily seeds the OTHER
  -- tester's neighbourhood — 40 neighbours reported, an empty screen on device.
  select p.h3_r7, p.h3_r6, p.h3_r5, coalesce(p.timezone, 'Europe/Ljubljana')
    into v_cell_r7, v_cell_r6, v_cell_r5, v_tz
    from public.profile p
   where p.h3_r7 is not null
     and p.user_id::text not like id_prefix || '%'
   group by p.h3_r7, p.h3_r6, p.h3_r5, p.timezone
   order by count(*) desc, max(p.updated_at) desc
   limit 1;

  if v_cell_r7 is null then
    raise exception
      'no real profile with an h3_r7 cell — set a garden location in the app first, then re-run';
  end if;

  raise notice 'seeding % neighbours into r7=%', n_neighbours, v_cell_r7;

  -- Re-run: drop the previous synthetic set. Children first (FKs), and only
  -- rows under the synthetic prefix.
  delete from public.task_subject where task_id in (
    select id from public.task where user_id::text like id_prefix || '%');
  delete from public.task       where user_id::text like id_prefix || '%';
  delete from public.user_plant where user_id::text like id_prefix || '%';
  delete from public.profile    where user_id::text like id_prefix || '%';
  delete from auth.users        where id::text      like id_prefix || '%';

  for i in 1..n_neighbours loop
    v_uid := (id_prefix || lpad(i::text, 12, '0'))::uuid;

    -- Old enough to be eligible (min_account_days = 14).
    insert into auth.users (id, email, created_at)
    values (v_uid, 'staging-neighbour-' || i || '@test.invalid', now() - interval '400 days');

    insert into public.profile (user_id, h3_r7, h3_r6, h3_r5, timezone, updated_at)
    values (v_uid, v_cell_r7, v_cell_r6, v_cell_r5, v_tz, now());

    -- The first n_site neighbours get NO plant subject, so their events land in
    -- the '@site' cohort; the rest all garden cohort_plant. One plant, not five:
    -- a cohort only publishes once it clears k_reliab on its own.
    v_plant_id := case when i > n_site then cohort_plant end;
    if v_plant_id is not null then
      v_up_id := (id_prefix || lpad((1000 + i)::text, 12, '0'))::uuid;
      insert into public.user_plant (id, user_id, plant_id, is_custom, updated_at)
      values (v_up_id, v_uid, v_plant_id, false, now());
    end if;

    -- Three seasons: two closed ones give the curve its shape, the current one
    -- makes "this week" and the frequency histogram non-empty. With only the
    -- current season the curve is `censored` and the UI says "first season".
    foreach v_yr in array array[extract(year from current_date)::int - 2,
                             extract(year from current_date)::int - 1,
                             extract(year from current_date)::int] loop
      -- Spread first executions across weeks 12..24 so the CDF is a curve and
      -- not a step: percentile wording is only meaningful against a spread.
      v_first_week := 12 + (i % 13);
      for k in 0..4 loop
        d := to_date(v_yr::text || '-01-04', 'YYYY-MM-DD')
             + ((v_first_week - 1) * 7 + k * 9) * interval '1 day';
        if d > current_date then continue; end if;

        v_task_id := gen_random_uuid();
        insert into public.task (id, user_id, task_type_id, date, status, deleted, updated_at)
        values (v_task_id, v_uid, types[1 + (i + k) % array_length(types, 1)],
                d + interval '9 hours', 'done', false, now());

        if v_plant_id is not null then
          insert into public.task_subject (id, task_id, user_plant_id, updated_at)
          values (gen_random_uuid(), v_task_id, v_up_id, now());
        end if;
      end loop;
    end loop;

    -- activity_recent is a SLIDING 7-DAY window. Season history alone leaves it
    -- empty, and then the landing feed — the first screen of the feature — has
    -- nothing to show while every other surface works. Two completions inside
    -- the window fix that; they are never a first execution, so the season
    -- curve is untouched.
    for k in 1..2 loop
      v_task_id := gen_random_uuid();
      insert into public.task (id, user_id, task_type_id, date, status, deleted, updated_at)
      values (v_task_id, v_uid, types[1 + (i + k) % array_length(types, 1)],
              (current_date - ((i + k) % 6) * interval '1 day') + interval '9 hours',
              'done', false, now());

      if v_plant_id is not null then
        insert into public.task_subject (id, task_id, user_plant_id, updated_at)
        values (gen_random_uuid(), v_task_id, v_up_id, now());
      end if;
    end loop;
  end loop;
end $$;

-- The aggregates read eligible_user, which is a MATERIALIZED view: without this
-- refresh every neighbour above is invisible and the app still shows nothing.
refresh materialized view public.eligible_user;

select 'eligible neighbours' as what, count(*) as n from public.eligible_user
union all
select 'done tasks', count(*) from public.task where status = 'done' and deleted = false
union all
select 'agg_event rows', count(*) from public.agg_event;
