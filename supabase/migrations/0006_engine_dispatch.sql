-- M11.12: dnevni dispatch (engine_dispatch + pg_cron).
-- Vault secret setup (enkratno, prek SQL editorja — ne v migracijo):
--   select vault.create_secret('<service_role_jwt>', 'engine_service_key');

-- pg_cron / pg_net are NOT relocatable: each creates its own fixed schema
-- (cron / net) and we call cron.schedule / net.http_post from there. A
-- `with schema extensions` clause errors or misplaces the objects, so install
-- bare (matches docs/m11/04 §4.6–4.7).
create extension if not exists pg_net;
create extension if not exists pg_cron;

-- In-flight marker: when a user was last handed to the Edge Function. Lets an
-- overlapping cron tick skip users whose run has not finished yet (additive to
-- engine_run from 0005).
alter table engine_run add column if not exists last_dispatched_at timestamptz;

-- Dispatcher: every 30 min, pick users whose LOCAL time is 07:00–12:00 and
-- who have not run today; POST a batch of up to 25 ids to the Edge Function.
-- Service JWT from Vault (see comment above). Batch 25 = worst-case 53 s/user
-- × overhead still under Edge Function wall-clock limit (docs/m11/04 §4.7).
--
-- search_path = '' (not 'public'): this SECURITY DEFINER function reads the
-- service-role key from Vault, so every object is schema-qualified to prevent a
-- planted object in a writable schema from shadowing profile/app_config/engine_run.
create or replace function engine_dispatch() returns void
language plpgsql security definer set search_path = '' as
$$
declare
  ids      uuid[];
  endpoint text := (select value->>'url' from public.app_config where key = 'engine_endpoint');
  srv_key  text := (select decrypted_secret from vault.decrypted_secrets
                    where name = 'engine_service_key');
begin
  -- Fail loud-but-safe on a misconfigured deploy instead of POSTing 'Bearer '.
  if endpoint is null or srv_key is null then
    raise warning 'engine_dispatch: missing engine_endpoint or engine_service_key — skipping';
    return;
  end if;
  -- Defence in depth: the endpoint comes from app_config; never send the
  -- service-role token anywhere but a Supabase Edge Function origin.
  if endpoint !~ '^https://[a-z0-9]+\.functions\.supabase\.co/' then
    raise warning 'engine_dispatch: endpoint % is not an allowed function origin — skipping', endpoint;
    return;
  end if;

  select array_agg(s.user_id) into ids
  from (
    select p.user_id
    from public.profile p
    left join public.engine_run r on r.user_id = p.user_id
    where (now() at time zone coalesce(p.timezone, 'UTC'))::time >= time '07:00'
      and (now() at time zone coalesce(p.timezone, 'UTC'))::time <  time '12:00'
      and (
        r.last_run_date is null
        or r.last_run_date < (now() at time zone coalesce(p.timezone, 'UTC'))::date
      )
      -- Skip users dispatched in the last 40 min (run still in flight) so the
      -- next */30 tick cannot double-send before the engine writes last_run_date;
      -- after 40 min a genuinely failed run becomes eligible again for retry.
      and (r.last_dispatched_at is null or r.last_dispatched_at < now() - interval '40 minutes')
    -- Oldest-served-first, NOT a fixed id order: a static `order by user_id`
    -- starves high-UUID users once the eligible set exceeds daily capacity.
    order by r.last_run_date asc nulls first, p.user_id
    limit 25
  ) s;

  if ids is null then return; end if;

  -- Stamp the dispatch BEFORE the POST so a re-entrant tick won't re-pick these
  -- users mid-run; the engine clears them for the rest of the day via last_run_date.
  insert into public.engine_run (user_id, last_dispatched_at)
  select unnest(ids), now()
  on conflict (user_id) do update set last_dispatched_at = excluded.last_dispatched_at;

  perform net.http_post(
    url     := endpoint,
    headers := jsonb_build_object(
                 'Authorization', 'Bearer ' || srv_key,
                 'Content-Type',  'application/json'),
    body    := jsonb_build_object('user_ids', to_jsonb(ids))
  );
end;
$$;

-- Server-only: the cron job runs as the function owner (has execute regardless).
-- Revoke the default PUBLIC grant so no anon/authenticated user can trigger a
-- dispatch batch via PostgREST RPC (/rest/v1/rpc/engine_dispatch).
revoke execute on function public.engine_dispatch() from public;

-- Idempotent (re)schedule: drop any existing job of this name first so a
-- migration replay against the shared live DB cannot duplicate or error.
select cron.unschedule(jobid) from cron.job where jobname = 'engine-dispatch';

select cron.schedule(
  'engine-dispatch',
  '*/30 * * * *',
  $$select public.engine_dispatch()$$
);
