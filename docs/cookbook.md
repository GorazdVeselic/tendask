# Cookbook — kanonične poti za pogosta opravila

**Pravilo: če je opravilo tu, uporabi točno ta ukaz.** Ne izumljaj variante, ne "poskusi drugače",
ne sestavljaj svojega psql/adb/python klica. Improvizacija je bila glavni vir raztresenosti
(dokaz: `.claude/settings.local.json` ima ~576 vrstic allowlista, večinoma enkratne variante istih ukazov).

Vzdrževanje:
- Recept pride sem **šele, ko je enkrat dejansko delal**. Ne "kar bi moralo delati".
- Ko se recept pokvari, **popravi vrstico** — nikoli ne dodaj druge variante zraven.
  Dve poti za isto opravilo = spet ugibanje.
- Podrobnosti, ozadje in razlogi so v `docs/deploy-runbook.md`, `tool/smoke.md`, `docs/staging-env.md`.
  Tu je samo **ukaz + past**.

Shell: ukazi so pisani za **Bash tool** (Git Bash), razen kjer piše PowerShell. `wsl -e bash -lc "…"`
je edina pot do staging stacka.

---

## 1. Preverbe pred commitom

| Opravilo | Ukaz | Past |
|---|---|---|
| Statična analiza | `flutter analyze` | ne ujame drift enum/part napak — te ujame šele `flutter test` |
| Testi (**vedno cel nabor**) | `flutter test` | ne poganjaj samo prizadete datoteke; layout matrika pade drugje |
| Format | `dart format lib test` | |
| Edge funkcije | `deno test supabase/functions/` | `deno` ni na privzetem PATH-u v PowerShell; v Bash toolu je |
| Po spremembi anotacij (drift/freezed/riverpod) | `dart run build_runner build --delete-conflicting-outputs` | |
| Po spremembi i18n ključev | `dart run slang` | build_runner tega **NE** ujame — ločen CLI |

`flutter test` traja nekaj minut. Če se v prejšnji seji zatakne `flutter_tester.exe`:
`taskkill //F //IM flutter_tester.exe`.

---

## 2. Build in namestitev na napravo

| Cilj | Ukaz |
|---|---|
| razvoj (debug + **staging**) | `cmd //c "deploy.bat hot"` |
| debug proti **prod** | `cmd //c "deploy.bat hot prod"` |
| release proti stagingu (**NI za Play**) | `cmd //c "deploy.bat staging"` |
| Play build (release + prod) | `cmd //c "deploy.bat"` |

Env se izbere prek `--dart-define-from-file`; ob zagonu se izpiše `ENV: … — SUPABASE_URL=…` — **preberi to vrstico**, je edina potrditev cilja.

**USB pade sredi `deploy.bat` ("Lost connection to device") — pogosto.** `flutter run` izstopi, a nov build **ni nameščen**. Robustna pot:

```bash
flutter build apk --debug --dart-define-from-file=dart_defines.staging.json
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Po `flutter run` je `app-debug.apk` **star** — `flutter run` ga ne prepiše. Preverba, kaj je res nameščeno:
`adb shell dumpsys package app.tendask | grep lastUpdateTime`.

---

## 3. Vodenje naprave (on-device test)

Prvi korak vsake seje z napravo:

```bash
adb shell svc power stayon true
```

Scenarij: koraki v `tmp/steps.txt` (prepiši datoteko), nato **vedno isti** ukaz (PowerShell):

```
& ./tool/adb_run.ps1
```

- Koraki: `taptext <napis>` (prednostno), `tap x y`, `text …`, `key 67`, `swipe`, `wait n`, `dump`, `echo`.
- **NIKOLI `adb_ui.ps1 -Tap …` z različnimi argumenti** — vsak drug niz je nov ukaz → poziv za dovoljenje pri vsakem tapu.
- `adb input text` ne tipka šumnikov.
- Scenariji A/B/C in koordinate elementov brez napisa: `tool/smoke.md`.

Zajem zaslona: `adb exec-out screencap -p > tmp/screen.png`, nato Read.

---

## 4. Staging DB (WSL, self-hosted)

Staging je **on-demand** — če je stack dol, API ne dela.

| Opravilo | Ukaz |
|---|---|
| aplikacija migracij | `wsl -e bash -lc "tendask migrate"` |
| stanje / zagon / ustavitev | `wsl -e bash -lc "tendask status"` (`start`, `stop`, `logs`) |
| poizvedba | `wsl -e bash -lc "docker exec -i supabase-db psql -U postgres -d postgres -c \"<SQL>\""` |
| SQL iz datoteke | `wsl -e bash -lc "cat /mnt/c/Users/Uporabnik/StudioProjects/tendask/<pot.sql> \| docker exec -i supabase-db psql -v ON_ERROR_STOP=1 -U postgres -d postgres"` |
| ledger | `… psql … -tAc "select version from supabase_migrations.schema_migrations order by version;"` |

- **Gesla ne rabiš** — `docker exec` je superuser prek containerja. Ne išči poverilnic za `127.0.0.1:5433`.
- Skripta bere migracije **direktno iz repa** (`/mnt/c/…`) → commit ni potreben.
- **Citiranje je glavna past.** Za SQL z apostrofi (`type='garden'`) uporabi **`-tAc` in dvojne narekovaje zunaj**, ali raje zapiši SQL v `tmp/q.sql` in ga pošlji prek `cat … | docker exec -i …`. Ne gradi verig ubežnih apostrofov — tam se je zapravilo največ poskusov.

---

## 5. Produkcija (⚠️ repo je linkan na PROD)

`supabase db push` / `db reset` **brez `--db-url` gre na PROD.** Nikoli "za test".

| Opravilo | Ukaz |
|---|---|
| aplikacija pending migracij | `supabase db push` |
| verifikacija ledgerja | `supabase migration list --linked` |
| dejanska shema (ne le ledger) | read-only Python sonda v `tmp/probe_*.py` (psycopg, geslo iz `.env`) |
| kje so uporabniki (H3 → zemljevid) | `python tool/geo_user_map.py` → `tmp/geo/map.html`; pravila: `docs/analitika-geo.md` |

- **Na produkciji ničesar ne brišemo** — niti kot predlog. Skripte proti prod so **read-only sonde**.
- Vrstni red: napiši migracijo → staging (`tendask migrate`) → test → potrditev → `db push` → verifikacija.
- **Vsak nov prod build najprej `supabase db push`, šele nato upload.**
- Nove migracije oštevilči nad najvišjo obstoječo; **nikoli 0006–0010** (ledger vrzel, glej runbook §2).

---

## 6. Katalog (rastline, vrste opravil)

```bash
dart run tool/gen_catalog_sql.dart      # 1. regeneriraj (sicer pade parity test)

# 2a. staging
wsl -e bash -lc "cat /mnt/c/Users/Uporabnik/StudioProjects/tendask/supabase/seed/catalog.sql | docker exec -i supabase-db psql -v ON_ERROR_STOP=1 -U postgres -d postgres"

# 2b. produkcija
python supabase/seed/apply_catalog.py
```

Upsert je idempotenten — varno večkrat. `INSERT 0 0` na koncu **ni napaka**. Nova izdaja aplikacije ni potrebna.
Isti vzorec za pravila: `tool/gen_rules_sql.dart` → `supabase/seed/apply_rules.py`.

---

## 7. Motor (smart-engine) na stagingu

```bash
wsl -e bash -lc "/mnt/c/Users/Uporabnik/StudioProjects/tendask/tool/staging_deploy_engine.sh"
```

Poženi **po vsaki spremembi motorja** (prepiše gola imena uvozov v `npm:` — self-hosted router nima import mape).

Klic (cron na stagingu **ne** dispatcha — namerno; kliči neposredno):

```bash
wsl -e bash -lc 'KEY=$(docker inspect supabase-edge-functions --format "{{range .Config.Env}}{{println .}}{{end}}" | grep "^SUPABASE_SERVICE_ROLE_KEY=" | cut -d= -f2-); curl -s -X POST https://api-staging.tendask.app/functions/v1/smart-engine -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -d "{\"user_ids\":[\"<uuid>\"]}"'
```

Testni podatki (40 sintetičnih sosedov, celica se prebere iz **tvojega** profila):
`supabase/seed/staging_test_data.sql` → isti `cat … | docker exec -i …` vzorec, nato
`docker exec supabase-db psql -U postgres -d postgres -c "select public.agg_refresh_all()"`.

---

## 8. Git

| Opravilo | Ukaz |
|---|---|
| stanje | `git status` |
| diff proti main | `git --no-pager diff main...HEAD --stat` |
| commit | `git commit` (naslov + 0–2 vrstici telesa, brez epskih opisov) |
| PR | `git push` → izpiše povezavo (**`gh` CLI v tem okolju NI**) |

Pred commitom **vedno vprašaj** ("naj to označim kot zaključeno in commitam?"). Nikoli `--no-verify`, nikoli force push na `main`.

---

## 9. Začasne datoteke

Vse scratch stvari (SQL poizvedbe, sonde, dumpi, `steps.txt`, screenshoti) gredo v **`tmp/`** v korenu repa —
je v `.gitignore`. Ne razmetavaj po repu, ne uporabljaj sistemskega temp-a za stvari, ki se navezujejo na repo.
