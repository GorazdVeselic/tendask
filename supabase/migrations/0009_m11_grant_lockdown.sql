-- ============================================================
-- 0009_m11_grant_lockdown.sql — finish what 0007 intended.
--
-- 0007 GRANTed minimal privileges but never REVOKEd the Supabase default ALL
-- grant on these three tables, so anon/authenticated still carried
-- INSERT/UPDATE/DELETE/TRUNCATE at the grant level. RLS neutralises them (the
-- policies are read-only or owner-fenced), but the posture contradicts 0007's
-- "deterministic grants" comment and the project's grant discipline.
--
-- Revoke, then re-grant exactly what the client uses — additive-safe: the client
-- only ever SELECTs plant_task_rule, pushes suggestion via SELECT/INSERT/UPDATE
-- as the authenticated role (anonymous sign-in is ALSO 'authenticated', never
-- 'anon'), and reads suggestion_log. Mirrors the revoke-then-grant that the
-- community tables already got in 0008. Idempotent (revoke/grant are no-ops on
-- repeat).
-- ============================================================

revoke all on plant_task_rule, suggestion, suggestion_log from anon, authenticated;

-- Catalog: public read-only (client pulls via catalog sync).
grant select on plant_task_rule to anon, authenticated;

-- suggestion: client pulls + pushes status via upsert (insert+update). No delete
-- (the client soft-deletes via update). authenticated only — anon never owns rows.
grant select, insert, update on suggestion to authenticated;

-- suggestion_log: read-only mirror of engine guard state (server is sole writer).
grant select on suggestion_log to authenticated;
