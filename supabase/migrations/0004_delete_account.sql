-- Tendask — GDPR account deletion RPC (M9.7).
--
-- Clients hold only the anon/publishable key and never a service-role key, so
-- they cannot delete auth.users directly. This SECURITY DEFINER function lets a
-- signed-in user delete *their own* account: removing the auth.users row
-- cascades (via the ON DELETE CASCADE FKs in 0002) to every user table.
--
-- Safety:
--   * SECURITY DEFINER runs as the function owner (table owner / postgres), which
--     can delete from auth.users; the WHERE clause pins it to auth.uid() so a
--     caller can only ever delete themselves.
--   * search_path is pinned empty to block search-path hijacking.
--   * Execute is granted to authenticated only (never anon).

create or replace function public.delete_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.delete_account() from public, anon;
grant execute on function public.delete_account() to authenticated;
