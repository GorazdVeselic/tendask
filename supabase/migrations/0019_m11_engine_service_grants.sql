-- 0019_m11_engine_service_grants.sql — the grants the smart engine actually
-- needs, written down instead of inherited.
--
-- WHY: 0008 states "the engine writes them with the service role, which
-- bypasses grants". That is half true and the half that is false is the one
-- that matters: `service_role` has BYPASSRLS, so it skips row-level policies —
-- it does NOT skip table privileges. Where it appears to work, it is because a
-- hosted Supabase project bootstraps
--   alter default privileges in schema public grant all on tables to service_role;
-- so tables created afterwards pick the grant up silently.
--
-- Measured 2026-07-28 on the self-hosted staging stack, which has no such
-- default: the engine's very first read failed with
--   42501 permission denied for table app_config
-- and no suggestion could ever have been produced. The same would hold on any
-- environment restored, branched or migrated without that default privilege.
--
-- Additive and idempotent: on an environment that already grants these, every
-- statement is a no-op. Nothing is revoked here.
--
-- Mirrors the memory rule "every client-accessible table needs an explicit
-- GRANT in the SAME migration" — the engine is a client too, it just wears the
-- service role.

-- ----- read set -------------------------------------------------------------
-- bundle.ts pulls the whole per-user working set. Four of these never appear in
-- a .from(): plant, task_subject, task_reminder and task_supply arrive as
-- EMBEDDED relations inside a select string, and PostgREST needs their
-- privileges just the same. Enumerating only the .from() tables is how the
-- first attempt at this migration still failed — on `plant`.
grant select on
  app_config, profile, task, task_subject, task_reminder, task_supply,
  user_plant, plant, area, supply, task_type, plant_task_rule, activity_season,
  suggestion, suggestion_log, engine_run, weather_cache
to service_role;

-- ----- write set ------------------------------------------------------------
-- pipeline.ts inserts suggestions and upserts their log rows; housekeep.ts
-- updates status/mute; handler.ts upserts engine_run + weather_cache.
grant insert, update on suggestion, suggestion_log, engine_run, weather_cache
to service_role;

-- handler.ts clears a dead FCM token (profile.fcm_token = null) — the one write
-- the engine makes to a user-owned row.
grant update on profile to service_role;

-- ----- functions ------------------------------------------------------------
-- 0018 revoked engine_dispatch/agg_refresh_all from public, anon and
-- authenticated. pg_cron runs them as the table owner, so nothing else is
-- needed; k_privacy()/k_reliab() are read by RLS policies in the caller's role
-- and keep their existing grants. Stated so the next reader does not "fix" it.
