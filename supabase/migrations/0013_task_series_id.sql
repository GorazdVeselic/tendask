-- Tendask — FR-5 recurrence: task.series_id groups instances of one series.
-- Mirrors drift task.series_id (lib/core/database/tables/user_tables.dart) and
-- schema v11 (lib/core/database/app_database.dart).
--
-- Why: a recurring task materializes its next instance on completion. series_id
-- (a device-generated UUID, inherited by every child) ties those instances
-- together — enabling future "edit/delete whole series" and deterministic
-- reconciliation with the smart engine (M11). MVP behavior does not depend on
-- it; this only captures the grouping so past instances stay reconstructable.
--
-- Additive-only (runbook §2): nullable, no default, no backfill. Old APKs treat
-- it as an unknown column (tolerant parser ignores it on pull; push omits it,
-- leaving the value untouched). RLS unchanged — the task owner policy (0002)
-- covers all columns. No new grant — column-level grants are not used; the
-- table grant from 0001/0002 already covers every column.

alter table task
  add column if not exists series_id text;
