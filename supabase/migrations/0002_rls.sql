-- Tendask — Supabase auth binding + RLS (M5.3). Apply right after 0001_schema.sql.
--
-- Three parts:
--   1. Bind user_id -> auth.users with ON DELETE CASCADE (GDPR: deleting the account
--      removes all of the user's rows; child tables follow via their task_id cascade).
--   2. Enable RLS on every table (no policy = deny; tables stay closed by default).
--   3. Policies: catalog = public read; user tables = owner-only; child tables (no
--      user_id) = ownership via the parent task.
--
-- Notes:
--   * auth.uid() is wrapped in (select auth.uid()) so the planner evaluates it once
--     per query (initplan) instead of per row — the recommended RLS perf pattern.
--   * Anonymous sign-in (signInAnonymously, M7) yields a real auth.users row with the
--     'authenticated' role, so `to authenticated` covers anonymous and linked users
--     alike; the 'anon' role is only for requests without a session (catalog read).
--   * Catalog has no write policy: clients can only read it. Seeding runs via the SQL
--     editor / service role, which bypasses RLS.

-- ============================================================
-- 1. Account binding (GDPR cascade root)
-- ============================================================

alter table profile
  add constraint profile_user_fk foreign key (user_id)
  references auth.users(id) on delete cascade;
alter table area
  add constraint area_user_fk foreign key (user_id)
  references auth.users(id) on delete cascade;
alter table user_plant
  add constraint user_plant_user_fk foreign key (user_id)
  references auth.users(id) on delete cascade;
alter table task
  add constraint task_user_fk foreign key (user_id)
  references auth.users(id) on delete cascade;
alter table note
  add constraint note_user_fk foreign key (user_id)
  references auth.users(id) on delete cascade;
alter table supply
  add constraint supply_user_fk foreign key (user_id)
  references auth.users(id) on delete cascade;
alter table recipe
  add constraint recipe_user_fk foreign key (user_id)
  references auth.users(id) on delete cascade;

-- ============================================================
-- 2. Enable RLS everywhere
-- ============================================================

alter table task_type          enable row level security;
alter table plant              enable row level security;
alter table plant_synonym      enable row level security;
alter table category_task_type enable row level security;
alter table profile            enable row level security;
alter table area               enable row level security;
alter table user_plant         enable row level security;
alter table task               enable row level security;
alter table task_subject       enable row level security;
alter table task_reminder      enable row level security;
alter table note               enable row level security;
alter table supply             enable row level security;
alter table recipe             enable row level security;
alter table task_supply        enable row level security;

-- ============================================================
-- 3a. Catalog — public read (anon + authenticated); no writes from clients
-- ============================================================

create policy task_type_read on task_type
  for select to anon, authenticated using (true);
create policy plant_read on plant
  for select to anon, authenticated using (true);
create policy plant_synonym_read on plant_synonym
  for select to anon, authenticated using (true);
create policy category_task_type_read on category_task_type
  for select to anon, authenticated using (true);

-- ============================================================
-- 3b. User tables — owner-only (user_id = auth.uid())
-- ============================================================

create policy profile_owner on profile
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy area_owner on area
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy user_plant_owner on user_plant
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy task_owner on task
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy note_owner on note
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy supply_owner on supply
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy recipe_owner on recipe
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- ============================================================
-- 3c. Child tables (no user_id) — ownership via the parent task
-- ============================================================

create policy task_subject_owner on task_subject
  for all to authenticated
  using (exists (
    select 1 from task
    where task.id = task_subject.task_id
      and task.user_id = (select auth.uid())))
  with check (exists (
    select 1 from task
    where task.id = task_subject.task_id
      and task.user_id = (select auth.uid())));

create policy task_reminder_owner on task_reminder
  for all to authenticated
  using (exists (
    select 1 from task
    where task.id = task_reminder.task_id
      and task.user_id = (select auth.uid())))
  with check (exists (
    select 1 from task
    where task.id = task_reminder.task_id
      and task.user_id = (select auth.uid())));

create policy task_supply_owner on task_supply
  for all to authenticated
  using (exists (
    select 1 from task
    where task.id = task_supply.task_id
      and task.user_id = (select auth.uid())))
  with check (exists (
    select 1 from task
    where task.id = task_supply.task_id
      and task.user_id = (select auth.uid())));
