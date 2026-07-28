-- ============================================================
-- 0020_task_agg_context_write_once.sql — DB guard for the frozen aggregation
-- snapshot (finding N9, docs/m11/19-najdbe-med-izvedbo.md).
--
-- Problem: `task.agg_context` is the snapshot of WHERE a task happened, frozen
-- when it is marked done, and `agg_event` counts on it never moving —
-- 0009:129–132 and 0017:35–38 both read
-- `coalesce(t.agg_context->>'h3_r7', p.h3_r7)`. The invariant lived in exactly
-- one place: a `where agg_context is null` clause in ONE client
-- (tasks_repository.dart `_stampAggContext`). Two paths go round it — the sync
-- pull overwrites the column from the cloud with no guard, and RLS lets a user
-- update their own `task` row. Neither crashes; both silently re-count a
-- finished task into a different cell when the gardener moves, which is the
-- exact scenario the snapshot exists to prevent.
--
-- Fix: keep the old value instead of rejecting the statement. `raise exception`
-- was considered and dropped: the client pushes the WHOLE task row (note,
-- status, yield, …), so failing the statement would wedge that row's sync
-- forever over a column the user cannot even see. Coercion protects the
-- aggregate completely — agg_event reads nothing else from this column — and
-- costs the user nothing. The warning is the observability seam: this should
-- never fire, so if it does we want it in the log drain.
--
-- Escape hatch for deliberate ops work (e.g. adding `timezone` to existing
-- snapshots — N15):
--   set local app.agg_context_rewrite = 'on';
-- inside the same transaction as the backfill.
--
-- Additive and idempotent: no column, table, RLS or grant changes, so no
-- released client can notice. A trigger function needs no EXECUTE grant —
-- Postgres checks that at CREATE TRIGGER time, not when the trigger fires.
-- ============================================================

create or replace function public.task_agg_context_write_once()
returns trigger
language plpgsql
as $$
begin
  -- First stamp (null → value) is the normal path.
  if old.agg_context is null then
    return new;
  end if;
  -- Re-pushing the same snapshot is what every ordinary LWW sync does.
  if new.agg_context is not distinct from old.agg_context then
    return new;
  end if;
  if coalesce(current_setting('app.agg_context_rewrite', true), 'off') = 'on' then
    return new;
  end if;
  raise warning 'task_agg_context_write_once: task % kept its frozen snapshot', old.id;
  new.agg_context := old.agg_context;
  return new;
end;
$$;

drop trigger if exists task_agg_context_write_once on public.task;

create trigger task_agg_context_write_once
  before update of agg_context on public.task
  for each row
  execute function public.task_agg_context_write_once();
