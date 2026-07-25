-- ============================================================
-- 0017_agg_event_site_cohort.sql — comparison cohorts for the community
-- aggregates (docs/skupnost-agregacija.md §5.2–5.4, §7.4 uskladitev 2026-07-25).
--
-- Problem: the `plant_id = ''` row is the SUPERSET of every event of a task
-- type, so comparing against it pools acts that are agronomically different —
-- pruning an apple tree, a raspberry cane and a rose bush land in one curve,
-- and the resulting percentile answers a question nobody asked.
--
-- Fix: every comparison runs inside ONE coherent cohort, decided by the
-- event's subject and never swapped (only the geography widens):
--   plant_id = '<plant>'  → events on that catalog plant
--   plant_id = '@site'    → events with NO catalog plant subject (lawn, bed,
--                           soil work, and tasks on private custom plants)
--   plant_id = ''         → kept for completeness, but NEVER used for a
--                           comparison (it is the contaminated superset).
--
-- Additive + idempotent: `create or replace view` only. The aggregate tables,
-- their primary keys and the RLS/grants are untouched — '@site' is an ordinary
-- text value in the existing `plant_id` column, and agg_refresh_all() already
-- groups by it, so the three aggregates pick the new cohort up unchanged.
--
-- Safe to apply now: the nightly cron is still server-dark (app_config
-- engine_enabled = false, guard added in the M11 reconcile), so nothing has
-- been materialized yet and no released client reads these tables.
-- ============================================================

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
