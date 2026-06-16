# Staging okolje (app stran)

Referenca za **Flutter app** stran. Staging backend (self-hosted Supabase) teče **ločeno
v WSL2** na strežniku (repo `tendask-supabase`); ta dokument pokriva le, kar potrebuje app
razvijalec/agent. Polni backend transfer: `docs/handoff-flutter-staging.md` v backend repo.

## Kaj je staging

Self-hosted Supabase (uradni docker-compose, **PostgreSQL 17**, rotirane skrivnosti) v WSL2,
iz interneta dosegljiv prek **Cloudflare Tunnel**. Namen: razvoj/test brez poseganja v živo
(produkcijsko) bazo na supabase.com.

> ⚠️ **On-demand — staging NI vedno gor.** Stack (Docker + tunel) je treba na strežniku
> zagnati, sicer je API nedosegljiv. Zagon/ustavitev je **strežniška (WSL) stran** prek
> ukaza `tendask` (glej spodaj) — ne sproža ga Windows app agent.

## Dostopne točke

| Kaj | Naslov | Opomba |
|---|---|---|
| **API** (za app) | `https://api-staging.tendask.app` | javno; ščiti publishable/anon ključ + RLS |
| Studio | `http://localhost:3000` | samo lokalno na strežniku |
| Mailpit (emaili) | `http://localhost:8025` | lokalno na strežniku; tu se berejo OTP kode |
| Postgres | `127.0.0.1:5433` | lokalno na strežniku; NI v tunelu |

## Kako app cilja staging vs. produkcijo

App bere vse prek `--dart-define` (`lib/core/config.dart`): `SUPABASE_URL`,
`SUPABASE_PUBLISHABLE_KEY`, `GOOGLE_SERVER_CLIENT_ID`, `SENTRY_DSN`.

- **dev/debug → STAGING** (privzeto): `dart_defines.staging.json` → `SUPABASE_URL=https://api-staging.tendask.app`
- **release → PRODUKCIJA**: `dart_defines.json`
- Preklop poganja `deploy.bat`:
  - `deploy.bat hot` (oz. `dev.bat`) → debug + **staging**
  - `deploy.bat` (brez arg.) → release + **produkcija**
  - `deploy.bat hot prod` → debug + produkcija; `deploy.bat staging` → release + staging (glasno opozori)
- Ob zagonu se izpiše `ENV: … — SUPABASE_URL=…` (preverba, kam cilja).
- `dart_defines.staging.json` je **gitignored**; v repo gre le `dart_defines.staging.example.json`.
- Staging publishable key je na strežniku: `grep '^SUPABASE_PUBLISHABLE_KEY=' ~/tendask-supabase/.env`.
- `GOOGLE_SERVER_CLIENT_ID` je **isti kot prod** (nativni ID-token tok ne rabi novega clienta).
- `SENTRY_DSN` na stagingu **prazen** (staging napake ne onesnažujejo prod Sentry).

## Avtentikacija na stagingu

- **Email OTP**: `signInWithOtp` → `verifyOTP` (6-mestna koda, NE magic link). Email pristane v
  **Mailpit** (`http://localhost:8025` na strežniku); koda je v mailu. Predloge zrcaljene iz prod (sl).
- **Google**: nativni `signInWithIdToken`; deluje (staging GoTrue sprejema isti prod web client).
- Telefon/SMS: izklopljen.

## Migracije / shema — VARNOSTNO ⚠️

- App repo je **linkan na PRODUKCIJO** (`supabase/config.toml`). Zato: **`supabase db push` /
  `supabase db reset` BREZ `--db-url` gre na PRODUKCIJO.** Nikoli teh ukazov "za test na stagingu".
- **Staging shemo aplicira strežnik** prek `tendask migrate` (psql; varno, nikoli prod).
- **Workflow ob novi migraciji:** napiši `supabase/migrations/000X_*.sql` v app repo → prosi
  lastnika/WSL agenta, da jo aplicira na staging (`tendask migrate`) → testiraj na stagingu →
  šele nato `supabase db push` na produkcijo. Migracije so **additive-only** (`supabase/README.md`).

## Strežniški ukaz `tendask` (teče v WSL na strežniku, NE tu)

- `tendask` → interaktivni nadzorni zaslon; `tendask start`/`stop`/`status`/`info` → celo okolje
- `tendask migrate` → uveljavi app migracije na staging
- `tendask backup` / `tendask restore <file>` → posnetek/obnova staging baze
- `tendask psql` → psql lupina; `tendask logs` → dnevniki

## Kaj app agent (ta repo) DELA / NE DELA

- **DELA:** razvija app, piše migracije v app repo, testira proti stagingu (dev build), bere OTP iz Mailpit.
- **NE DELA:** ne poganja `supabase db push` brez `--db-url` (= prod!), ne commita ključev
  (`dart_defines*.json` so gitignored), ne objavlja staging builda na Play.
