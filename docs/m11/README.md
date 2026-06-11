# M11 — Pametni motor + FCM + skupnostni percentili — IMPLEMENTACIJSKA SPECIFIKACIJA

> **Status:** POTRJENA pred-implementacijska specifikacija · 2026-06-11
> **Vir resnice za izvedbo M11.** Nadgrajuje `docs/pametni-motor.md` (koncept motorja),
> `docs/skupnost-agregacija.md` (statistični model V2), `docs/koncept.md` §7.12/§7.13/§7.14.
> Razvijalec sledi korakom v `09-koraki.md`; vsa vsebinska/tehnična vprašanja so razrešena tukaj
> (odprto ostane SAMO tisto v `10-odprta-vprasanja.md`).

## Kazalo

| Datoteka | Vsebina |
|---|---|
| [`00-pregled-za-laika.md`](00-pregled-za-laika.md) | Kako sistem deluje od konca do konca — brez tehničnih izrazov |
| [`01-agronomska-pravila.md`](01-agronomska-pravila.md) | POPOLNA vsebina tabele `plant_task_rule` (kategorije + vrste, ~60 pravil, z viri) |
| [`02-signalni-sloj.md`](02-signalni-sloj.md) | Vsak signal: vir, tip, osveževanje, primer rabe |
| [`03-pravila-r1-r7.md`](03-pravila-r1-r7.md) | Formalna specifikacija pravil R1–R7 (sprožilec, straže, ocena, cooldown) |
| [`04-supabase-shema.md`](04-supabase-shema.md) | Točen SQL: migraciji 0005 + 0006, RLS, pg_cron, Edge Function |
| [`05-drift-shema.md`](05-drift-shema.md) | Lokalne drift spremembe + migracija + kateri repo bere/piše |
| [`06-fcm.md`](06-fcm.md) | Firebase/FCM setup, token, foreground/background, deep link, opt-in |
| [`07-climate-profile.md`](07-climate-profile.md) | Open-Meteo klimatski profil: API klici, bucket algoritem, frost datumi |
| [`08-flutter-arhitektura.md`](08-flutter-arhitektura.md) | Riverpod providerji, SuggestionRepository, Okolica zavihek, paywall |
| [`09-koraki.md`](09-koraki.md) | **Delovni tasklist** — koraki M11.1–M11.22 z DoD, odvisnostmi, commiti |
| [`10-odprta-vprasanja.md`](10-odprta-vprasanja.md) | Edine odločitve, ki se kalibrirajo po podatkih/testu |

## Ključne arhitekturne odločitve (povzetek, podrobnosti v poglavjih)

1. **Motor teče STREŽNIŠKO** (Supabase Edge Function `smart-engine`), klican prek `pg_cron`
   dispatcherja vsakih 30 min za uporabnike, katerih lokalni čas je v oknu **07:00–07:30**
   (po koncu privzetih tihih ur 22–7). Naprava motorja NE poganja.
2. **Predlogi se sinhronizirajo kot navadna user-tabela `suggestion`** (strežnik piše, klient
   bere prek pull in piše SAMO `status`+`dismiss_scope` prek push) → pas na Domov bere iz
   drift, offline-first ostane nedotaknjen. Kartica ima 5 odgovorov: Načrtuj · Opusti (letos)
   · ⋯ Že opravljeno · ⋯ Ne predlagaj več (trajno) · ⋯ Nimam več (odstrani subjekt) —
   pogodba v `03` §Akcije.
3. **`suggestion_log` (straže) piše izključno strežnik**; klient ga le pull-a (bralna kopija).
   En pisec na tabelo = brez konfliktov.
4. **Vreme za motor se keša per H3-celica per dan** (`weather_cache` strežniško) — uporabniki v
   isti celici delijo en Open-Meteo klic; koordinate so vedno centroid celice, nikoli uporabnikove.
5. **FCM prek HTTP v1 API** (service account JSON v Supabase secrets) — legacy server key je
   ukinjen. Token v `profile.fcm_token` (MVP: zadnja naprava zmaga; multi-device = V2.5).
6. **Klimatski profil računa NAPRAVA** (Open-Meteo archive API na centroid r7 celice) in shrani
   `profile.climate_profile` (owner-only) + grob javni `climate_bucket`.
7. **`task.agg_context` štemplja klient ob `done`** od prvega dne M11 (kopiči zgodovino za V2,
   tudi če pogledi pridejo kasneje).
8. **V2 agregati = nočni `pg_cron`** (SQL funkcije, SECURITY DEFINER), štiri javno-bralne tabele
   z dvema pragoma (`K_privacy=5`, `K_reliab=30`) iz `app_config`.
9. **Okolica = Tendask+** (paywall); `entitlement` tabela + server-validiran 14-dnevni trial.

## Konvencije v tej specifikaciji

- Razlaga slovensko, **vsa koda/identifikatorji/i18n ključi angleško** (CLAUDE.md).
- `subject_key` kanonična oblika: `up:<user_plant_id>` (rastlina) · `ar:<area_id>` (območje) ·
  `cat:<category_id>` (kategorija, ko ni konkretnega subjekta).
- ISO tedni v pravilih veljajo za **privzeti klimatski koš** (Cfb nižina srednje Evrope,
  zadnja pozeba ≈ teden 16, prva ≈ teden 43); motor jih regionalizira (gl. `01` §0 in `07`).
- Vse nastavljive vrednosti živijo v `core/config.dart` (klient) oz. `app_config` (strežnik) —
  nikoli magične številke v pravilih.
