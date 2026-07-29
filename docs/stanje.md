# Stanje — kaj je v živo, kaj teče, kaj je naslednje

> **Edini dokument s trenutnim stanjem.** Zadnja posodobitev: **2026-07-29**.
> Kaj je že narejeno in zakaj → [`narejeno.md`](narejeno.md) · kaj je odprto → [`backlog.md`](backlog.md)
> · kako delamo → [`../CLAUDE.md`](../CLAUDE.md) · ukazi → [`cookbook.md`](cookbook.md).
>
> Ta datoteka je **kazalec, ne dnevnik.** Ko vnos zastara, ga zamenjaj — ne dodajaj poleg.

## V produkciji

- **Tendask `1.0.1+16`** na Google Play, javno objavljeno, 40 držav.
- Supabase projekt `jlmkkeijmmnwkizutvkg`; **`linked` = PROD** (`supabase db push` brez `--db-url`
  gre na produkcijo — glej [`deploy-runbook.md`](deploy-runbook.md)).
- Testna naprava: Samsung SM A536B.

## Delovna veja: `main`

**M11 (pametni motor) je 29. 7. 2026 ustavljen — zavrnjen kot preobsežen, ne izbrisan.**
Veja `feat/m11-smart-engine` je v celoti pushana na origin (`c643320`, 60 commitov) kot arhiv in
referenca. Motor se bo začel znova, v majhnih korakih iz `main`. Po M11 **ni** M12.
Kaj je bilo zgrajeno in zakaj je ustavljen → [`m11.md`](m11.md).

**Na `main` je prišlo 29. 7.:** specifikacije FR-22/23/24 (poziv za lokacijo), layout popravki za
320 dp z veliko pisavo (prijava, e-pošta, vremenska kartica), `ui-katalog.md`, `cookbook.md`,
`prelomi-besed.md`, `tool/overflow_scan.py`.

**Ostalo samo na M11 veji** (če bo kdaj potrebno, pobrati posamično): pravilo za prelome besed v
layout matriki (`layoutBreaks` + `kAcceptedWordBreaks`), predelan `notification_priming_sheet`,
strop skale nav pasu, krajši nemški nav napisi, šest M11 skript, migracije `0017`–`0022`.

## Čaka na izdajo

- **FR-24 — onboarding lokacija** je na `main` (`699fe5b`), preverjen na napravi, **še neizdan**.
  ⚠️ **Ne izdaj skupaj s FR-22** — ista metrika, učinka ne bi ločila.
  Zakaj tako: [`narejeno.md`](narejeno.md) · spec:
  [`feature-requests/onboarding-location-cta.md`](feature-requests/onboarding-location-cta.md).

## Staging

**Resetiran na `main` (29. 7.):** `drop schema public cascade` + prazen ledger + re-migracija
0001–0005/0011–0016 (11 migracij) + katalog seed (26 tipov, 141 rastlin, 100 `category_task_type`).
Crona odstranjena, M11 tabele/funkcije izginile, `auth.users` **izpraznjen** (72 test računov).
Backup pred posegom: `~/tendask-supabase/backups/staging_20260729_141730.sql.gz`.

> Telefon z obstoječo staging sejo rabi **odjavo ali ponovno namestitev** — sicer RLS 42501
> (zastarel `user_id`). Podrobnosti: [`staging-env.md`](staging-env.md).

## Odprto in parkirano

| Kaj | Opomba |
|---|---|
| Gost, ki na zaslonu Lokacija zapre app, ob ponovnem zagonu ni več vprašan | opaženo, **ni** naročen popravek |
| »Dvojni tap« pri dodajanju opomnika | opaženo |
| Sentry TENDASK-6: RenderFlex overflow 9 px | brez widget verige |
| Insert-if-missing race v `setLang` / `setNotificationSettings` / `saveGardenLocation` | ni sprožilo napake v produkciji |
| Odprti bugi BUG-001…004 | [`bugreport.md`](bugreport.md) |
| Načrtovano, negrajeno | [`backlog.md`](backlog.md) |
