-- Proves the two aggregation invariants that no unit test can reach, because
-- they live in Postgres: N9 (task.agg_context is write-once) and N15 (agg_event
-- bins local_day by the FROZEN timezone). Added with migrations 0020/0021.
--
-- Everything runs inside a transaction that is ROLLED BACK, so it is safe to
-- run against any environment — including production, where it is the only way
-- to check the trigger actually landed. It writes nothing that survives.
--
-- Run (staging):
--   wsl -e bash -lc "cat /mnt/c/.../supabase/probe/agg_context_invariants.sql
--     | docker exec -i supabase-db psql -v ON_ERROR_STOP=1 -U postgres -d postgres"
--
-- Every row must read PASS. The probe picks a real done task, stamps it itself
-- (staging seeds rows without a snapshot) and pins the instant to 20:00 UTC so
-- Ljubljana and Auckland genuinely differ — without that, step 5 would "pass"
-- while proving nothing.
begin;

create temp table probe_result(n int, step text, detail text) on commit drop;

-- A done task belonging to an eligible user with a known profile timezone.
create temp table victim on commit drop as
  select t.id, t.date, p.timezone as profile_tz
  from public.task t
  join public.profile p on p.user_id = t.user_id
  join public.eligible_user e on e.user_id = t.user_id
  where t.status = 'done' and t.deleted = false and t.agg_context is null
    and p.timezone is not null
  limit 1;

-- Pin the instant to late evening UTC so Ljubljana (UTC+2) and Auckland
-- (UTC+12) genuinely fall on DIFFERENT calendar days — otherwise step 5 would
-- "pass" without discriminating between the snapshot and the live profile.
update public.task t set date = timestamptz '2026-06-15 20:00:00+00'
  from victim v where t.id = v.id;
update victim set date = timestamptz '2026-06-15 20:00:00+00';

insert into probe_result select 0, 'victim',
  coalesce((select id::text || ' profile_tz=' || profile_tz from victim), 'NONE');

-- 1) first stamp: null -> value must be allowed, and carries the timezone.
update public.task t
   set agg_context = jsonb_build_object(
         'h3_r7', '871e13904ffffff', 'climate_bucket', 'e1_t6',
         'timezone', 'Pacific/Auckland')
  from victim v where t.id = v.id;
insert into probe_result select 1, 'N9 first stamp (null -> value)',
  case when (select agg_context from public.task where id = (select id from victim))
            is not null
       then 'PASS — allowed' else 'FAIL — blocked' end;

-- 2) overwrite attempt: the snapshot must survive unchanged.
update public.task t
   set agg_context = '{"h3_r7":"8fffffffffffffff","climate_bucket":"zz_zz"}'::jsonb
  from victim v where t.id = v.id;
insert into probe_result select 2, 'N9 overwrite blocked',
  case when (select agg_context->>'h3_r7' from public.task
             where id = (select id from victim)) = '871e13904ffffff'
       then 'PASS — snapshot unchanged'
       else 'FAIL — became ' || (select agg_context::text from public.task
                                 where id = (select id from victim)) end;

-- 3) same-value re-push (what every ordinary LWW sync does) must not warn/fail.
update public.task t
   set agg_context = t.agg_context, note = coalesce(t.note, '')
  from victim v where t.id = v.id;
insert into probe_result select 3, 'N9 idempotent re-push', 'PASS — no error';

-- 4) ops escape hatch.
set local app.agg_context_rewrite = 'on';
update public.task t set agg_context = t.agg_context || '{"h3_r7":"deadbeef"}'::jsonb
  from victim v where t.id = v.id;
insert into probe_result select 4, 'N9 escape hatch',
  case when (select agg_context->>'h3_r7' from public.task
             where id = (select id from victim)) = 'deadbeef'
       then 'PASS — deliberate rewrite allowed' else 'FAIL — flag ignored' end;
set local app.agg_context_rewrite = 'off';

-- 5) N15: agg_event bins by the FROZEN timezone, not the live profile.
--    Pacific/Auckland is deliberately absurd — if local_day follows it, the
--    snapshot won; if it follows the profile, it did not.
insert into probe_result select 5, 'N15 frozen tz wins',
  case when e.local_day = (v.date at time zone 'Pacific/Auckland')::date
       then 'PASS — local_day from the snapshot ('
            || e.local_day::text || ', profile says '
            || (v.date at time zone v.profile_tz)::date::text || ')'
       else 'FAIL — local_day=' || e.local_day::text end
  from victim v join public.agg_event e
    on e.task_id = v.id and e.plant_id = '';

select step, detail from probe_result order by n;
rollback;
