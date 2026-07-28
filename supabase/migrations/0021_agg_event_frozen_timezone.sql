-- ============================================================
-- 0021_agg_event_frozen_timezone.sql — freeze the timezone into the snapshot
-- (finding N15, docs/m11/19-najdbe-med-izvedbo.md).
--
-- Problem: `agg_context` froze WHERE a task happened but not WHEN it counts as
-- having happened. The cells came from the snapshot, `local_day` came from the
-- CURRENT profile — so a gardener who moves (or whose timezone is corrected)
-- silently re-bins the local day of their entire history, and with it the ISO
-- week every season curve is built on. "Where" is a historical fact; "when" was
-- being treated as a live one, even though both feed the same aggregate.
--
-- Decision: the timezone goes INTO the snapshot, exactly like the cells. The
-- fallback chain keeps this additive and keeps the property that makes the
-- N14 fix worth shipping:
--
--   coalesce(agg_context->>'timezone', p.timezone, 'UTC')
--
--   * tasks stamped before this ships carry no `timezone` key, so they still
--     read the live profile — which means once N14 starts filling
--     profile.timezone, the next agg_refresh_all() still heals their local_day
--     retroactively. Freezing them now would instead lock in today's wrong UTC
--     forever;
--   * tasks stamped from now on carry their own timezone and are immune to a
--     later move.
--
-- No new failure mode: a malformed timezone would already break the existing
-- `at time zone coalesce(p.timezone, 'UTC')`, and the value comes from the same
-- place (device IANA id, refined by the Open-Meteo archive).
--
-- Additive + idempotent: `create or replace view` only, same columns, same
-- grants (the view stays revoked from anon/authenticated — the aggregates are
-- read through the published tables, never through this).
-- ============================================================

create or replace view agg_event as
with base as (
  select
    t.id as task_id,
    t.user_id,
    t.task_type_id,
    (t.date at time zone coalesce(t.agg_context->>'timezone', p.timezone, 'UTC'))::date
      as local_day,
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
  -- Canonical (catalog) plant subjects only: a private custom plant must never
  -- reach the aggregate, so such a task counts as site work instead.
  select ts.task_id, up.plant_id
  from public.task_subject ts
  join public.user_plant up on up.id = ts.user_plant_id
  where ts.deleted = false and up.is_custom = false and up.plant_id is not null
  group by ts.task_id, up.plant_id
)
-- 1) legacy superset row (kept; not used for comparisons)
select b.*, ''::text as plant_id from base b
union all
-- 2) one row per catalog plant subject
select b.*, pl.plant_id from base b join plants pl on pl.task_id = b.task_id
union all
-- 3) site cohort: no catalog plant subject at all
select b.*, '@site'::text as plant_id
from base b
where not exists (select 1 from plants pl where pl.task_id = b.task_id);

revoke all on agg_event from anon, authenticated;
