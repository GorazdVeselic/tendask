-- Decision #9 (docs/m11/10-odprta-vprasanja.md): "telemetrija UNREGISTERED
-- > 10 %/mes → tabela device". This is that telemetry. Read-only, safe on prod.
--
-- The denominator is users the engine could push to at all — a user who never
-- allowed notifications is not evidence about delivery. The numerator is users
-- whose token FCM rejected in the window, which is also the moment the engine
-- cleared profile.fcm_token, so they have dropped OUT of the denominator: the
-- count is over engine_run, not over live tokens.
--
-- Reading it: over ~10 % for a month is the #9 trigger. A single spike is
-- usually one tester reinstalling; two consecutive months is a pattern.

\echo '--- push rejection rate, last 30 days ---'
select
  count(*) filter (
    where r.push_rejected_at > now() - interval '30 days'
  )                                                     as rejected_30d,
  count(*) filter (where p.fcm_token is not null)       as pushable_now,
  count(*)                                              as users_with_a_run,
  round(
    100.0 * count(*) filter (where r.push_rejected_at > now() - interval '30 days')
      / nullif(
          count(*) filter (where p.fcm_token is not null)
            + count(*) filter (where r.push_rejected_at > now() - interval '30 days'),
          0
        ),
    1
  )                                                     as rejected_pct
from engine_run r
join profile p on p.user_id = r.user_id;

\echo '--- who, and when (for chasing a single bad device) ---'
select r.user_id, r.push_rejected_at, r.last_push_date, p.fcm_token is not null as has_token_again
from engine_run r
join profile p on p.user_id = r.user_id
where r.push_rejected_at is not null
order by r.push_rejected_at desc
limit 20;
