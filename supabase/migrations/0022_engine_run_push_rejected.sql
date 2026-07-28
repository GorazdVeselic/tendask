-- N12: a rejected push delivery left no trace anywhere.
--
-- handler.ts clears profile.fcm_token when FCM answers UNREGISTERED (the device
-- is gone), and that is correct — but nothing recorded that it happened. The
-- user simply stops getting notifications, and decision tree #9 ("telemetrija
-- UNREGISTERED > 10 %/mes → tabela device") hangs on a number nobody collects.
--
-- One nullable column rather than the device table #9 imagines: the trigger for
-- that table is this measurement, so building it first would be answering a
-- question we cannot yet ask. Per-user rather than per-message on purpose —
-- "how many users went dark this month" is the shape of the #9 threshold, and a
-- timestamp needs no read-modify-write on a row the engine already upserts.
--
-- No GRANT needed: 0019 granted insert/update on engine_run to service_role at
-- table level, so a new column is covered. engine_run stays server-only (0018
-- revoked it from anon/authenticated) — this is ops telemetry, not user data.
alter table engine_run
  add column if not exists push_rejected_at timestamptz;

comment on column engine_run.push_rejected_at is
  'Last time FCM rejected this user''s token (UNREGISTERED / foreign sender) '
  'and the engine cleared profile.fcm_token. Ops signal for decision #9; '
  'see supabase/probe/push_rejection_rate.sql.';
