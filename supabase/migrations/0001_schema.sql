-- Tendask — Supabase schema (M5.2). Mirrors drift (lib/core/database/tables/*).
--
-- Rules (CLAUDE.md "Sync, čas in shema"):
--   * Additive-only: add column/table = OK; rename = NEVER; no NOT NULL without a
--     default/backfill in the same migration (old APKs must not crash on pull).
--   * sync_status does NOT exist in the cloud — it is a LOCAL drift column only.
--   * JSON fields (labels/weather/recurrence/items) = jsonb; time = timestamptz (UTC);
--     catalog id = text (slug).
--   * Quantities = double precision (NOT numeric): drift stores REAL (double) and is
--     the source of truth; the server mirrors it, avoiding a client<->server type skew.
--
-- User id/user_id = uuid, generated ON THE DEVICE (uuid pkg) before insert. There is
-- DELIBERATELY no `default gen_random_uuid()`: the id is the upsert identity for sync,
-- so a missing id must fail loudly, never be silently replaced by a server-side id
-- (which would create a duplicate row on the next pull).
--
-- DELIBERATELY no updated_at trigger: the device owns updated_at — it is the LWW key
-- for sync (offline). A server-side trigger overwriting now() on UPDATE would corrupt
-- ordering on pull-upsert. The updated_at default now() is only a safety net for manual
-- inserts; sync always supplies an explicit value (which wins).
--
-- RLS, the user_id -> auth.users FK and ON DELETE CASCADE (GDPR) live in 0002_rls.sql
-- (step 5.3). Do NOT expose the project via the API until 5.3 enables RLS — tables
-- without RLS are readable by anon.

-- ============================================================
-- Catalog (shared, read-only; source = on-device seed, mirrored to the cloud).
-- No updated_at/deleted/sync_status: the catalog is not synced across devices.
-- ============================================================

create table task_type (
  id                text primary key,
  labels            jsonb   not null,         -- {"sl":..,"en":..,"de":..}
  icon              text    not null,
  category          text    not null,
  requires_subject  boolean not null default false,
  weather_sensitive boolean not null default false,
  consumes_supplies boolean not null default false,
  default_cadence   integer                   -- null = no default cadence
);

create table plant (
  id              text  primary key,
  labels          jsonb not null,
  scientific_name text,
  category        text  not null,
  icon            text
);

-- No UNIQUE on (plant_id, lang, text_norm): drift has none, so adding one here would
-- diverge from the source schema. Mirror exactly; dedupe is the seed's responsibility.
create table plant_synonym (
  id        bigint generated always as identity primary key,
  plant_id  text not null references plant(id),
  lang      text not null,
  text_norm text not null                       -- normalized (lowercase, trimmed)
);

create table category_task_type (
  category     text not null,
  task_type_id text not null references task_type(id),
  primary key (category, task_type_id)
);

-- ============================================================
-- User tables (sync-ready: uuid / updated_at / deleted).
-- user_id stays a plain uuid here; the auth.users FK + RLS are added in 5.3.
-- ============================================================

-- profile has no soft-delete (one row per user).
create table profile (
  user_id    uuid primary key,
  h3_r7      text,                              -- H3 cells only, NEVER raw coordinates
  h3_r6      text,
  h3_r5      text,
  lang       text,
  updated_at timestamptz not null default now()
);

create table area (
  id         uuid primary key,
  user_id    uuid not null,
  name       text not null,
  type       text not null default 'other',
  protected  boolean not null default false,    -- greenhouse: excluded from weather guards
  updated_at timestamptz not null default now(),
  deleted    boolean not null default false,
  constraint area_type_check
    check (type in ('lawn','hedge','bed','tree','ornamental','other'))
);

create table user_plant (
  id             uuid primary key,
  user_id        uuid not null,
  area_id        uuid references area(id) on delete cascade,  -- null = potted, no named area
  plant_id       text references plant(id),                   -- null when is_custom
  custom_name    text,
  personal_alias text,
  is_custom      boolean not null default false,
  updated_at     timestamptz not null default now(),
  deleted        boolean not null default false,
  constraint user_plant_subject_check
    check (plant_id is not null or is_custom)    -- curated catalog OR custom entry
);

create table task (
  id           uuid primary key,
  user_id      uuid not null,
  task_type_id text not null references task_type(id),
  date         timestamptz not null,
  status       text not null default 'waiting',
  note         text,
  weather      jsonb,                            -- frozen snapshot on completion
  recurrence   jsonb,                            -- null = one-off
  updated_at   timestamptz not null default now(),
  deleted      boolean not null default false,
  constraint task_status_check check (status in ('waiting','done'))
);

-- M:N task subjects (a plant OR an area); no user_id -> ownership via task.
-- No natural-key UNIQUE (e.g. task_id+user_plant_id) on purpose: with soft-delete +
-- offline concurrent creation, duplicate-looking rows must coexist; a UNIQUE would
-- reject a legitimate sync upsert. The uuid id is the only identity.
create table task_subject (
  id            uuid primary key,
  task_id       uuid not null references task(id) on delete cascade,
  user_plant_id uuid references user_plant(id) on delete cascade,
  area_id       uuid references area(id) on delete cascade,
  updated_at    timestamptz not null default now(),
  deleted       boolean not null default false,
  constraint task_subject_subject_check
    check (user_plant_id is not null or area_id is not null)
);

create table task_reminder (
  id            uuid primary key,
  task_id       uuid not null references task(id) on delete cascade,
  "offset"      integer not null,                -- minutes before task.date; 0 = at event
  reminder_time text,                            -- HH:mm; null = use task time
  updated_at    timestamptz not null default now(),
  deleted       boolean not null default false
);

create table note (
  id            uuid primary key,
  user_id       uuid not null,
  area_id       uuid references area(id) on delete cascade,
  user_plant_id uuid references user_plant(id) on delete cascade,
  date          timestamptz not null,
  "text"        text not null,                   -- note body (drift: content -> 'text')
  weather       jsonb,
  updated_at    timestamptz not null default now(),
  deleted       boolean not null default false
);

create table supply (
  id            uuid primary key,
  user_id       uuid not null,
  name          text not null,
  unit          text,
  quantity      double precision not null default 0,
  low_threshold double precision,                -- null = no threshold
  updated_at    timestamptz not null default now(),
  deleted       boolean not null default false,
  constraint supply_quantity_check check (quantity >= 0)
);

create table recipe (
  id         uuid primary key,
  user_id    uuid not null,
  name       text not null,
  equipment  text,
  items      jsonb,                              -- [{supply_id, amount, unit}]
  updated_at timestamptz not null default now(),
  deleted    boolean not null default false
);

-- Supply consumption per task; no user_id -> ownership via task.
create table task_supply (
  id         uuid primary key,
  task_id    uuid not null references task(id) on delete cascade,
  supply_id  uuid not null references supply(id) on delete cascade,
  amount     double precision not null,
  applied    boolean not null default false,     -- whether booked into supply.quantity yet
  updated_at timestamptz not null default now(),
  deleted    boolean not null default false,
  constraint task_supply_amount_check check (amount >= 0)
);

-- ============================================================
-- Indexes.
--  (a) Incremental pull: where user_id = auth.uid() and updated_at > last_pulled_at
--      -> composite (user_id, updated_at). Child tables (no user_id) by updated_at.
--  (b) FK columns: Postgres does NOT index them automatically — needed for cascade on
--      account deletion (5.3) and for RLS EXISTS via the parent. "Index every FK."
-- ============================================================

-- (a) sync pull
create index area_user_updated_idx       on area (user_id, updated_at);
create index user_plant_user_updated_idx on user_plant (user_id, updated_at);
create index task_user_updated_idx       on task (user_id, updated_at);
create index note_user_updated_idx       on note (user_id, updated_at);
create index supply_user_updated_idx     on supply (user_id, updated_at);
create index recipe_user_updated_idx     on recipe (user_id, updated_at);
create index profile_updated_idx         on profile (updated_at);
create index task_subject_updated_idx    on task_subject (updated_at);
create index task_reminder_updated_idx   on task_reminder (updated_at);
create index task_supply_updated_idx     on task_supply (updated_at);

-- (b) foreign keys (cascade + join/RLS)
create index user_plant_area_idx     on user_plant (area_id);
create index task_subject_task_idx   on task_subject (task_id);
create index task_subject_plant_idx  on task_subject (user_plant_id);
create index task_subject_area_idx   on task_subject (area_id);
create index task_reminder_task_idx  on task_reminder (task_id);
create index note_area_idx           on note (area_id);
create index note_plant_idx          on note (user_plant_id);
create index task_supply_task_idx    on task_supply (task_id);
create index task_supply_supply_idx  on task_supply (supply_id);
