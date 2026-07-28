# M11 — najdbe med izvedbo in testiranjem

> **Tekoč dnevnik, ne poročilo.** Vsaka najdba se vpiše **takoj ob odkritju**, ne ob koncu seje —
> sicer preživi samo do naslednjega `/clear`.
> Zapiši: **kaj** (opazljivo dejstvo), **dokaz** (izmerjeno, ne ocenjeno), **kam spada**, **status**.
> Ko je popravljeno, vrstica ostane in dobi hash — dnevnik je zgodovina, ne seznam opravil.
>
> Plan popravkov po pregledu je `17-plan-popravkov.md` (paketi P1–P12). Ta dokument lovi tisto,
> kar se pokaže **med** izvajanjem tega plana in v pregledu ni obstajalo.

---

## Odprto

| # | Najdba | Dokaz | Kam | Zakaj ni kozmetika |
|---|---|---|---|---|
| N1 | **`profile.timezone` je prazen** pri uporabnikih, ki so vrt nastavili pred to funkcijo. Klient ga piše **samo** v `saveGardenLocation`. | Oba staging profila `timezone = NULL` (2026-07-28) | **P11** | `engine_dispatch()` izbira po `(now() at time zone coalesce(p.timezone,'UTC'))::time between 07:00 and 12:00` → tak uporabnik dobi okno **09:00–14:00 po svojem času** (poleti). `agg_event` po istem `coalesce` binira v **lokalni dan** → opravilo po 22:00 pade v napačen dan in napačen ISO teden sezonske krivulje. Strežniški backfill ni mogoč (cone ne ve); popravek je na napravi. |
| N2 | **`communityWeekly` nima testa.** | `flutter test --coverage`: vrstice 112–121 `community_providers.dart` nepokrite | **P11** | Ni scaffolding — je zanka širjenja obsega (r7→r6→r5→climate), enaka tisti, ki jo `communitySeasonCurve` ima pokrito. |
| N3 | **Detajlni zaslon Okolice nima vrstice svežine.** P8 jo je dobil samo pas na Domov. | `CommunityFeed.fetchedAt` obstaja; `SeasonCurve`/`FrequencyStats`/`CommunityWeekly` ne | lasten paket | Tri kartice pridejo iz treh ločenih rezin; uporabnik vidi številke, ne pa, iz katerega dne so. Odloženo zavestno: zahteva polje na treh modelih in predelavo `community_stats_test.dart`. |
| N4 | **`dry_window` parameter pošilja motor, bere ga nihče.** | `candidate.ts:91` ga žigosa; `grep dry_window lib/` = 0 zadetkov, `grep` po i18n = 0 | **P10 / O4** | »Jutri je suho okno« je nosilna zgodba v `00-pregled-za-laika.md`, a do uporabnika **ne pride po nobeni poti**: mrtvi ključ `suggestions.weather.window_open` ni nikoli emitiran, pripone pa ni. Vpliva samo tiho na rangiranje. |
| N5 | **Cron na samohostanem stagingu ne more teči.** | Izvedba: `WARNING: missing engine_endpoint or engine_service_key`; nato bi ustavil še stražar izvora `^https://[a-z0-9]+\.functions\.supabase\.co/` (`0007`) | zapisano v runbooku | Ne pove ničesar: cron se vrti, `engine_run` ostane prazen, pas prazen. Za testiranje kličemo funkcijo neposredno. Če bo cron kdaj potreben na stagingu, naj dovoljeni izvor postane **podatek**, ne vzorec v kodi. |
| N6 | **Na stagingu je funkcija praktično odprta.** `isServiceRole` žeton dekodira, podpisa **ne preveri**; naslanja se na platformo. | `docker inspect supabase-edge-functions` → `VERIFY_JWT=false` | zapisano v runbooku | Sprejemljivo za lastna vrata, **ampak noben test avtorizacije na stagingu ni dokaz za produkcijo** (tam `verify_jwt = true`). |
| N7 | **`18-nadaljevanje-prompt.md` je zastarel** — trdi, da ostajajo P8–P12. | P8 `fec0761`, P9 `7d06944` | ob naslednji predaji | Vstopna točka za novo sejo; zastarela vstopna točka je slabša od nobene. |

## Razrešeno v tej seji

| # | Najdba | Kako | Hash |
|---|---|---|---|
| R1 | **`service_role` ne obide GRANT-ov, samo RLS.** `0008` trdi nasprotno; beseda `service_role` se v M11 migracijah pojavi **ničkrat**. Na okolju brez privzetih privilegijev motor umre na prvem branju in ne izdela **nobenega** predloga. | `0019_m11_engine_service_grants.sql` | `91482c3` |
| R2 | **`0006` zaseeda produkcijski `engine_endpoint`** v vsako novo okolje. | Popravljeno na stagingu + postopek v runbook; `10-odprta-vprasanja.md` #14 zaprt | `e658a2c` |
| R3 | **Layout matrika ni videla prelomov sredi besede.** 44 nizov na 11 zaslonih, 7 od njih se lomi že pri **privzeti** velikosti pisave. | Pravilo + izhodiščni seznam; breme v `docs/prelomi-besed.md` | `f79a4ea` |
| R4 | **Peti zavihek prelomi spodnjo vrstico** (de `Startseite`/`Aufgaben`/`Tagebuch`/`Umgebung`, sl `Opravila`) pri text×1,3 na 320 **in 360** dp. | Pogoj prižiga Okolice, zapisan v runbooku | `f79a4ea` |
| R5 | **En flag je prižgal brezplačne predloge in plačljivo Okolico hkrati**, ob `kDevPlusStub = true` pa jo podaril vsem. | Ločen `kCommunityEnabled`, oba iz okolja | `7d06944`, `e658a2c` |
| R6 | **`activity_recent` ostane prazen brez opravil v zadnjih 7 dneh** — sezonska zgodovina ne zadošča. | Seed dobil sveža opravila; zapisano v runbooku | (seed) |

## Procesna najdba

**V `17-plan-popravkov.md` je bil korak P7.5 (»layout matrika: `MainShell` s petimi zavihki«)
označen kot narejen, ne da bi bil.** Prav ta bi bil ujel R4. Odkljukana postavka, ki ni izvedena,
je slabša od neodkljukane — naslednji bralec je ne pogleda več.

**Posledica za način dela:** postavka se odkljuka šele, ko obstaja **artefakt**, ki to dokazuje
(test, ki pade brez popravka; vrstica v matriki; commit hash).
