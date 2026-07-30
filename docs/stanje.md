# Stanje — kaj je v živo, kaj teče, kaj je naslednje

> **Edini dokument s trenutnim stanjem.** Zadnja posodobitev: **2026-07-30**.
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

**Na `main` je prišlo 30. 7.:** FR-22 (implementacija, 7 commitov) in FR-25 v backlog. Brez migracije,
brez nove dependency, brez spremembe sheme.

**Ostalo samo na M11 veji** (če bo kdaj potrebno, pobrati posamično): pravilo za prelome besed v
layout matriki (`layoutBreaks` + `kAcceptedWordBreaks`), predelan `notification_priming_sheet`,
strop skale nav pasu, krajši nemški nav napisi, šest M11 skript, migracije `0017`–`0022`.

## Čaka na izdajo

Oba gresta lahko **v isto izdajo** (odločeno 30. 7.): merilo je delež uporabnikov z lokacijo, in če
zraste, je cilj dosežen — kateri od popravkov je prispeval, ni pomembno. Prejšnja zahteva po ločenih
izdajah zaradi atribucije je umaknjena.

- **FR-24 — onboarding lokacija** (`699fe5b`), preverjen na napravi. Spec:
  [`onboarding-location-cta.md`](feature-requests/onboarding-location-cta.md).
- **FR-22 — brez lokacije ni vremena** (`60448f2`…`e29a0a1`), preverjen na napravi po
  [planu §6](feature-requests/location-adoption-plan.md) + GPS brez omrežja. Spec:
  [`location-adoption.md`](feature-requests/location-adoption.md) ·
  [wireframe](wireframes/01d-weather-states.html).

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
| Vremenski posnetek z žigom iz časa **po** izbrisu podatkov (30. 7., enkrat opaženo) | **Ni ponovljivo** — namenska reprodukcija (lokacija + svež posnetek → Nastavitve »Izbriši vse podatke« → brez povezave → nova GPS lokacija) je dala »Vreme trenutno ni na voljo«, torej `clearUserData` `local_flag` res pobriše. Če se ponovi, prvi sum je pretvorba UTC → lokalni čas v žigu (`_capturedLabel`), ne izbris |
| Odprti bugi BUG-001…004 | [`bugreport.md`](bugreport.md) |
| Načrtovano, negrajeno | [`backlog.md`](backlog.md) |
