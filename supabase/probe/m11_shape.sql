-- Read-only fingerprint of every M11 object, ordered so two environments can be
-- compared with a plain diff.
--
-- Why this exists: 0006/0009 use `create table if not exists`, which SILENTLY
-- skips a table that already exists in a different shape. On prod the M11
-- objects were created out-of-band, so a re-apply "succeeds", the ledger says
-- applied, and any drift stays invisible forever (docs/m11/17-plan-popravkov.md
-- §5, probe S3). Staging built the same objects purely from the migrations, so
-- it is the canonical shape to diff against.
--
--   staging: docker exec -i supabase-db psql -U postgres -d postgres -qAtf - < this
--   prod:    psql "$PROD_URL" -qAtf this
--
-- SELECT only — safe against production.

\pset pager off

with objects(name) as (
  values ('plant_task_rule'), ('suggestion'), ('suggestion_log'), ('engine_run'),
         ('weather_cache'), ('app_config'), ('activity_recent'), ('activity_season'),
         ('activity_frequency'), ('bucket_population')
)
select 'COLUMN|' || c.table_name || '|' || c.column_name || '|' || c.data_type ||
       '|null=' || c.is_nullable || '|default=' || coalesce(c.column_default, '-')
  from information_schema.columns c
  join objects o on o.name = c.table_name
 where c.table_schema = 'public'
 order by c.table_name, c.column_name;

select 'INDEX|' || tablename || '|' || indexname || '|' || indexdef
  from pg_indexes
 where schemaname = 'public'
   and tablename in ('plant_task_rule','suggestion','suggestion_log','engine_run',
                     'weather_cache','app_config','activity_recent','activity_season',
                     'activity_frequency','bucket_population','eligible_user')
 order by tablename, indexname;

select 'POLICY|' || tablename || '|' || policyname || '|' || cmd ||
       '|roles=' || array_to_string(roles, ',') ||
       '|using=' || coalesce(qual, '-') ||
       '|check=' || coalesce(with_check, '-')
  from pg_policies
 where schemaname = 'public'
 order by tablename, policyname;

select 'RLS|' || relname || '|enabled=' || relrowsecurity || '|forced=' || relforcerowsecurity
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
 where n.nspname = 'public' and c.relkind = 'r'
   and relname in ('plant_task_rule','suggestion','suggestion_log','engine_run',
                   'weather_cache','app_config','activity_recent','activity_season',
                   'activity_frequency','bucket_population')
 order by relname;

-- Function bodies change with every migration; the identity + ACL is what a
-- grant regression shows up in (P5 / migration 0018).
select 'FUNCTION|' || p.proname || '(' || pg_get_function_identity_arguments(p.oid) || ')' ||
       '|security_definer=' || p.prosecdef ||
       '|acl=' || coalesce(array_to_string(p.proacl::text[], ' '), 'default')
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
 where n.nspname = 'public'
   and p.proname in ('engine_dispatch','agg_refresh_all','k_privacy','k_reliab','delete_account')
 order by p.proname;

-- Definitions are compared by hash: whitespace differs between a CREATE and a
-- pg_get_*def round-trip, the meaning does not.
select 'VIEW|' || viewname || '|md5=' || md5(pg_get_viewdef(('public.' || viewname)::regclass))
  from pg_views where schemaname = 'public' and viewname in ('agg_event')
 order by viewname;

select 'MATVIEW|' || matviewname || '|md5=' || md5(pg_get_viewdef(('public.' || matviewname)::regclass))
  from pg_matviews where schemaname = 'public' and matviewname in ('eligible_user')
 order by matviewname;

select 'CRON|' || jobname || '|' || schedule || '|active=' || active
  from cron.job order by jobname;

-- Config VALUES are environment-specific (engine_endpoint, engine_enabled), so
-- only the key set is compared — a missing key is a real difference.
select 'CONFIG_KEY|' || key from public.app_config order by key;
