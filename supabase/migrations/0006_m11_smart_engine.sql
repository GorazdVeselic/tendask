-- ============================================================
-- 0006_m11_smart_engine.sql — smart suggestion engine (M11).
-- Additive-only. Spec: docs/m11/04-supabase-shema.md §4.1–4.3.
-- ============================================================

-- profile: IANA timezone (server-side local-day logic), public coarse climate
-- bucket, owner-only rich climate profile, FCM token (MVP: last device wins).
-- Idempotent (add column if not exists): 0006–0010 live out-of-band on prod
-- (already applied, absent from the CLI ledger). When the ledger reconcile runs
-- `supabase db push`, these re-apply against existing objects and must not error.
alter table profile
  add column if not exists timezone              text,
  add column if not exists climate_bucket        text,
  add column if not exists climate_profile       jsonb,
  add column if not exists fcm_token             text,
  add column if not exists fcm_token_updated_at  timestamptz;

-- task: frozen aggregation buckets snapshot, stamped by the client on 'done'
-- ({h3_r7, h3_r6, h3_r5, climate_bucket}) — skupnost-agregacija.md §4.2.
alter table task
  add column if not exists agg_context jsonb;

-- task_type: seasonal flag — time-percentile only for seasonal types (§4.3).
alter table task_type
  add column if not exists seasonal boolean not null default true;

-- Non-seasonal types (everything else stays true):
update task_type set seasonal = false where id in ('water', 'weed', 'stake', 'repot');

-- Curated agronomy rules (catalog-like: public read, written only via seed
-- applied with the service role — clients never write).
create table if not exists plant_task_rule (
  id            text primary key,            -- '<ref_id>.<task>.<qualifier>' slug, add-only
  scope         text not null check (scope in ('plant', 'category')),
  ref_id        text not null,               -- plant.id or plant category slug
  task_type_id  text not null references task_type(id),
  timing_anchor text not null check (timing_anchor in
                  ('month_window', 'frost_offset', 'growth_stage', 'cadence_only')),
  -- "window" is a reserved word in Postgres — must stay quoted in raw SQL.
  "window"      jsonb not null,              -- shape per anchor, see docs/m11/01 §0
  cadence       text,                        -- human-readable; machine logic reads window
  frost_gate    boolean not null default false,
  weather_guard text,                        -- comma-joined guard codes (docs/m11/02 §G); null = none
  source_ref    text not null,               -- citation — mandatory audit trail
  confidence    text not null check (confidence in ('high', 'medium')),
  message_key   text not null                -- i18n key under suggestions.*
);

create index if not exists plant_task_rule_ref_idx  on plant_task_rule (scope, ref_id);
create index if not exists plant_task_rule_task_idx on plant_task_rule (task_type_id);

alter table plant_task_rule enable row level security;
-- drop-then-create so a re-apply against the out-of-band prod policy is idempotent
-- (Postgres has no CREATE POLICY IF NOT EXISTS).
drop policy if exists plant_task_rule_read on plant_task_rule;
create policy plant_task_rule_read on plant_task_rule
  for select to anon, authenticated using (true);
-- No insert/update/delete policies: only the service role (seed script) writes.

-- Suggestions surfaced to the user. WRITTEN BY THE ENGINE (service role);
-- the client only ever updates status (+updated_at) via normal sync push.
-- NOTE: any server-side UPDATE must set updated_at = now() explicitly
-- (default only fires on INSERT) or incremental pull never picks it up.
create table if not exists suggestion (
  id              uuid primary key,
  -- FK to auth.users is MANDATORY: delete_account() (0004) deletes auth.users
  -- and relies solely on ON DELETE CASCADE (GDPR) — without it rows orphan.
  user_id         uuid not null references auth.users(id) on delete cascade,
  rule_id         text not null,              -- 'R1'..'R7' engine rule
  plant_task_rule_id text references plant_task_rule(id),  -- null for R1–R4
  task_type_id    text not null references task_type(id),
  user_plant_id   uuid references user_plant(id) on delete cascade,
  area_id         uuid references area(id) on delete cascade,
  subject_key     text not null,              -- 'up:<id>' | 'ar:<id>' | 'cat:<slug>'
  message_key     text not null,
  message_params  jsonb not null default '{}'::jsonb,
  score           real not null,
  status          text not null default 'new'
                  check (status in ('new', 'planned', 'dismissed', 'logged', 'expired')),
                  -- 'logged' = user tapped 'Already done' (client also created a done task)
  dismiss_scope   text not null default 'season'
                  check (dismiss_scope in ('season', 'forever')),
                  -- on status='dismissed': 'season' → mute until window/season end,
                  -- 'forever' → permanent mute for (task_type, subject) ("Not interested")
  planned_task_id uuid references task(id),   -- set by client on 'Plan' AND on 'Already done'
  valid_until     date not null,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  deleted         boolean not null default false
);

create index if not exists suggestion_user_updated_idx on suggestion (user_id, updated_at);
create index if not exists suggestion_user_status_idx  on suggestion (user_id, status) where deleted = false;

alter table suggestion enable row level security;
drop policy if exists suggestion_select on suggestion;
create policy suggestion_select on suggestion
  for select to authenticated using (user_id = auth.uid());
-- Client sync-push is an upsert → needs insert+update, both fenced to own rows.
drop policy if exists suggestion_insert on suggestion;
create policy suggestion_insert on suggestion
  for insert to authenticated with check (user_id = auth.uid());
drop policy if exists suggestion_update on suggestion;
create policy suggestion_update on suggestion
  for update to authenticated using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Engine guard state (cooldown / dismissed_until). SERVER-ONLY writer; the
-- client pulls a read-only mirror (no insert/update policies on purpose).
-- guard_key is FINE-GRAINED (docs/m11/03 §Guard key): plant_task_rule.id for
-- R5/R7, '<R>:<task_type_id>' for R1-R3/R6 — NOT the bare 'R5' (a bare engine
-- rule id would make "Don't suggest pruning" also mute fertilizing).
create table if not exists suggestion_log (
  user_id           uuid not null references auth.users(id) on delete cascade,
  guard_key         text not null,
  subject_key       text not null,
  last_suggested_at timestamptz,
  dismissed_until   timestamptz,
  updated_at        timestamptz not null default now(),
  primary key (user_id, guard_key, subject_key)
);

create index if not exists suggestion_log_user_updated_idx on suggestion_log (user_id, updated_at);

alter table suggestion_log enable row level security;
drop policy if exists suggestion_log_select on suggestion_log;
create policy suggestion_log_select on suggestion_log
  for select to authenticated using (user_id = auth.uid());

-- Engine bookkeeping: one row per user, server-only (no client policies).
create table if not exists engine_run (
  user_id       uuid primary key references auth.users(id) on delete cascade,
  last_run_date date,                          -- user-local date of last engine run
  last_push_date date                          -- frequency cap: max 1 push per local day
);
alter table engine_run enable row level security;

-- Per-cell daily weather cache: users in the same r7 cell share one
-- Open-Meteo call. Server-only. Cleared by the nightly cron (older than 3 days).
create table if not exists weather_cache (
  h3_r7      text not null,
  date       date not null,
  payload    jsonb not null,
  fetched_at timestamptz not null default now(),
  primary key (h3_r7, date)
);
alter table weather_cache enable row level security;

-- Server-tunable knobs (K thresholds, weights, endpoints). Server-only.
create table if not exists app_config (
  key   text primary key,
  value jsonb not null
);
alter table app_config enable row level security;

-- on conflict do nothing: keeps any value already tuned on the live DB (these
-- rows exist out-of-band on prod) and stays idempotent on a ledger re-apply.
insert into app_config (key, value) values
  -- Server-dark master switch (mirror of the client kSuggestionsEnabled): both
  -- cron functions (engine_dispatch, agg_refresh_all) early-return while false.
  -- Flip to true at launch, together with deploying the smart-engine edge fn.
  ('engine_enabled',    'false'),
  ('k_privacy',         '5'),
  ('k_reliab',          '30'),
  ('eligibility',       '{"min_account_days": 14, "min_done_tasks": 10, "min_active_days": 5}'),
  ('engine',            '{"score_weather_window": 2.0, "score_season_window": 1.0,
                          "score_anniversary": 1.0, "score_window_closing": 0.5,
                          "score_low_supply": 0.5, "score_chain_ready": 2.0,
                          "score_overdue_per_day": 0.1, "score_mow_boost": 1.0,
                          "score_frost_protect_boost": 2.0, "emit_threshold": 2.0,
                          "push_cap_per_day": 1, "band_max_active": 3,
                          "dedup_planned_within_days": 14, "frost_safety_days": 7,
                          "suggestion_retention_days": 365}'),
  ('weather_thresholds','{"dry_hours_min": 24, "recent_rain_wet_mm": 2.0,
                          "rain_24h_mm": 1.0, "rain_48h_mm": 2.0, "heavy_rain_24h_mm": 10,
                          "wind_treat_kmh": 15, "wind_transplant_kmh": 20,
                          "soil_moist_min_mm_72h": 5}'),
  ('frost_defaults',    '{"last_frost_doy": 110, "first_frost_doy": 293}'),
  ('engine_endpoint',   '{"url": "https://jlmkkeijmmnwkizutvkg.functions.supabase.co/smart-engine"}')
on conflict (key) do nothing;

-- Helper for RLS gates on V2 aggregate tables (0007).
create or replace function k_privacy() returns int
language sql stable security definer set search_path = public as
$$ select (value)::int from app_config where key = 'k_privacy' $$;
