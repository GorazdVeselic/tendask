# Supabase Edge Functions

Deno (TypeScript) functions deployed to Supabase. The smart suggestion engine
lives in `smart-engine/`; shared helpers (FCM push, push i18n) in `_shared/`.

Spec: `docs/m11/` — `02-signalni-sloj.md` (signals), `03-pravila-r1-r7.md`
(rules + guards), `04-supabase-shema.md` §4.7–4.8 (dispatch + FCM).

## smart-engine

Daily server-side engine. Per user it: housekeeps stale suggestions → builds
signals (history, climate, weather, eligibility, state) → runs rules R1–R7 →
guards → dedup/rank/cap → emits `suggestion` rows. The dispatcher (`pg_cron`)
then sends one FCM push for the top card.

| Module | Responsibility |
| --- | --- |
| `index.ts` | HTTP entry: service-role auth guard, batch loop, weather fetch, orchestration |
| `bundle.ts` | Loads the per-user bundle (profile, plants, areas, tasks, rules, …) |
| `signals.ts` | Pure signal layer — history, climate, inventory, eligibility, state |
| `weather.ts` | Open-Meteo fetch + cache + derived weather signals (dry hours, rain sums, …) |
| `guards.ts` | Weather-guard evaluator (§G codes); fails closed on unknown/null |
| `rules.ts` | R1 (weather), R2 (anniversary), R3 (cadence) |
| `rules_agro.ts` | R5 (seasonal windows, frost-anchor), R7 (seedling chain) |
| `pipeline.ts` | R4 enrich → guards → dedup → rank → cap → emit |
| `housekeep.ts` | Expire/dismiss→log/retention before signals run |
| `candidate.ts`, `dates.ts`, `config.ts`, `types.ts` | Candidate keys, date helpers, app config, shared types |

## Running tests locally

Requires [Deno](https://deno.com) 2.x (CI uses `v2.x`; dev confirmed on 2.8.3).

```sh
# from repo root — runs every *_test.ts under supabase/functions/
deno test supabase/functions/

# a single suite
deno test supabase/functions/smart-engine/rules_test.ts

# watch mode while iterating
deno test --watch supabase/functions/smart-engine/
```

Tests are pure (synthetic bundles + canned weather JSON) — no network, no
secrets, no permission flags. `deno test` type-checks the test files and their
imports as it runs.

> Note: `deno check supabase/functions/` from the repo root fails on
> `_shared/*` because the npm import map lives in `smart-engine/deno.json`; this
> is a config-discovery quirk, not a type error. Type-checking happens inside
> `deno test`, which is what CI runs.

## Test coverage (rule + guard map)

Every implemented rule and every guard has at least one test:

| Unit | Test file |
| --- | --- |
| R1 weather window | `rules_test.ts` |
| R2 anniversary | `rules_test.ts` |
| R3 cadence overdue | `rules_test.ts`, `signals_test.ts` (cadence median) |
| R4 low-supply enrich | `pipeline_test.ts` |
| R5 seasonal / frost-anchor | `rules_agro_test.ts` |
| R7 seedling chain | `rules_agro_test.ts` |
| Guards a–h + §G codes | `guards_test.ts`, `pipeline_test.ts` |
| Dedup / rank / cap / determinism | `pipeline_test.ts` |
| Housekeeping 2a–2e (expire/dismiss/retention) | `housekeep_test.ts` |
| Signal layer (history/climate/inventory/eligibility/state) | `signals_test.ts` |
| Weather derivation | `weather_test.ts` |

R6 (community percentile) is forward-referenced only; it ships in Phase E.

## Deploy

```sh
supabase functions deploy smart-engine --project-ref jlmkkeijmmnwkizutvkg
```

`config.toml` pins `verify_jwt = true`; only a verified `service_role` JWT
(from the dispatcher via Vault) may invoke the engine. See `index.ts`
`isServiceRole`.
