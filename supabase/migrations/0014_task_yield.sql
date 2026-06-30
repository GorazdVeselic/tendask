-- 0014 — T11: record harvest yield (amount + unit) on a task.
--
-- Additive + nullable: old APKs ignore the columns, and the client's tolerant
-- parser drops them when absent. yield is a property of a harvest task, not of
-- supply (task_supply models consumption). The table-level grant on `task`
-- already covers new columns, and RLS is row-level (parent ownership) — no grant
-- or policy change needed.

alter table task
  add column if not exists yield_amount double precision,
  add column if not exists yield_unit   text;

-- A recorded amount is positive, and amount/unit are both-or-neither (the app
-- normalizes this; this is the DB-level safety net). Existing rows are all NULL,
-- so both constraints validate immediately.
alter table task
  add constraint task_yield_amount_check
    check (yield_amount is null or yield_amount > 0);

alter table task
  add constraint task_yield_pair_check
    check ((yield_amount is null) = (yield_unit is null));
