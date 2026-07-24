# Deploy & DB runbook (staging / prod)

Edina operativna referenca za **kako apliciramo migracije in deployamo app** — da ne ugibamo
vsakič znova. Env podrobnosti (ključi, tunel, Mailpit) so v [`docs/staging-env.md`](staging-env.md);
shema/pravila v [`supabase/README.md`](../supabase/README.md) in [`CLAUDE.md`](../CLAUDE.md).

---

## 0. Hitra orientacija (kaj gre kam)

| Sprememba | Staging | Produkcija |
|---|---|---|
| **DB migracija** | WSL skripta (cilja lokalni container `supabase-db`) | ta repo: `supabase db push` |
| **Katalog (rastline, opravila)** | `catalog.sql` prek `docker exec … psql` (gl. §1d) | `python supabase/seed/apply_catalog.py` |
| **App build** | `deploy.bat hot` (debug + staging) | `deploy.bat` (release + prod) → AAB → Play |
| **Postgres dosegljiv?** | lokalni container na strežniku (`127.0.0.1:5433`, ni v tunelu); WSL skripta bere migracije **direktno iz repa** (`/mnt/c`), commit ni potreben | prek povezanega projekta (CLI) |

⚠️ **App repo je linkan na PRODUKCIJO** (`supabase/config.toml`, ref `jlmkkeijmmnwkizutvkg`).
Zato **`supabase db push` / `supabase db reset` BREZ `--db-url` gre na PROD.** Nikoli »za test«.

---

## 1. DB migracija — celoten tok

```
1. napiši  supabase/migrations/00XX_*.sql   (additive-only, idempotentno)
2. STAGING: na strežniku v WSL →  tendask migrate
3. test na stagingu (deploy.bat hot)
4. potrditev
5. PROD:  supabase db push        (iz tega repa; gre na prod, ker je linkan)
6. verifikacija ledgerja + sheme
```

### 1a. Staging (WSL skripta — agent jo lahko poganja)
- Staging Postgres je lokalni container (`127.0.0.1:5433`, ni v tunelu), a **WSL skripta bere
  migracije direktno iz app repa** (`/mnt/c/...`), zato **commit/push ni potreben** — nova
  `00XX_*.sql` se uveljavi takoj.
- Skripta zažene stack (Docker + Cloudflare tunel), počaka na healthy containerje in **aplicira
  samo še-neaplicirane migracije** na lokalni `supabase-db` (NIKOLI prod). Izpiše `+ 00XX ... Newly applied: N`.
- Ukaz za zagon iz tega okolja (Windows → WSL, brez interaktivnega TUI):
  ```bash
  wsl -e bash -lc "tendask migrate"
  ```
  Skripta živi v `~/.local/bin/tendask` (WSL), stack v `~/tendask-supabase`.
- Sorodno: `tendask start/stop/status`, `tendask psql`, `tendask backup/restore`, `tendask logs`.
  Staging je **on-demand** — če je dol, API ne dela.
- **Gesla za staging bazo ne rabiš:** `tendask psql` je `docker exec -it supabase-db psql -U postgres`,
  torej superuser prek containerja. (`127.0.0.1:5433` je z Windows strani sicer dosegljiv — WSL2
  prepošlje localhost — a poverilnic za to pot v repu ni; container je enostavnejša pot.)

### 1d. Katalog (rastline / vrste opravil)

Katalog ni migracija: je **seed podatkov**, ki se (re)materializira iz `lib/data/seed/catalog_seed.dart`.
Postopek dodajanja rastline je v [`how-to-add-plant.md`](how-to-add-plant.md); tu je samo aplikacija.

```bash
dart run tool/gen_catalog_sql.dart      # 1. regeneriraj supabase/seed/catalog.sql (sicer pade parity test)

# 2a. STAGING (stack mora teči)
wsl -e bash -lc "cat /mnt/c/Users/Uporabnik/StudioProjects/tendask/supabase/seed/catalog.sql \
  | docker exec -i supabase-db psql -v ON_ERROR_STOP=1 -U postgres -d postgres"

# 2b. PRODUKCIJA
python supabase/seed/apply_catalog.py   # izpiše števce; ref+pooler trdo zapisana, geslo iz .env
```

- Upsert je **idempotenten in aditiven** (`on conflict do update`) — skladno s pravilom, da na produkciji
  ničesar ne brišemo. Varno ga je pognati večkrat.
- `INSERT 0 0` na koncu ni napaka: `category_task_type` gre skozi `on conflict do nothing`.
- **Nove izdaje aplikacije ni treba** — naprave poberejo katalog ob naslednjem zagonu (poln pull), tudi
  na starejšem buildu in tudi kot gost.

### 1b. Produkcija (iz tega repa, po potrditvi staginga)
```bash
supabase db push          # uveljavi pending migracije (ki niso v remote ledgerju) na PROD
```
- Ali ročno: **Supabase Studio → SQL Editor**, prilepi migracijo in poženi (fallback brez CLI).

### 1c. Verifikacija (vedno po push)
```bash
supabase migration list --linked     # primerja local vs remote ledger
```
- Za dejansko shemo (ne le ledger): probe skripta v `tmp/` (vzorec `tmp/verify_*.py` / `probe_*.py`).
- Pravilo iz spomina: **preveri stanje, ne ugibaj iz spomina.**

---

## 2. Številčenje migracij — POMEMBNO (past)

Stanje (junij 2026): **CLI ledger žive baze kaže samo 0001–0005**, vendar je vzporedna veja
`feat/m11-smart-engine` migracije **0006–0010 aplicirala na živo bazo mimo CLI ledgerja**
(prek service-role / skript). Datoteke 0006–0010 živijo samo na M11 veji, ne na `main`.

**Posledica / pravilo:**
- Nove migracije oštevilči **nad najvišjo M11 datoteko** (trenutno → **0011, 0012, …**).
- **Nikoli ne uporabi 0006–0010** za novo vsebino: CLI bi videl version »0006« v M11 stanju
  in push preskočil (ali bi vezal isto številko na dve različni vsebini).
- `supabase db push` z `main` (datoteke 0001–0005 + 00XX) uveljavi samo `00XX` (manjkajoč v
  ledgerju); M11 objektov se ne dotakne. Vrzel 0006–0010 v ledgerju je obstoječa, je ne slabšamo.
- Ob merge-u M11 ↔ main bo treba ledger uskladiti; do takrat hold to pravilo.

**Vsaka migracija mora biti additive-only + idempotentna** (`add column if not exists`, backfill,
`set default`/`set not null`), da je varno aplicirati prek CLI ali skripte, in da stari APK-ji
(vc1–vc5) ob pull-u ne crashajo.

**Na produkciji ničesar ne brišemo** — ne vrstic, ne tabel, ne stolpcev, tudi »testnih« ne.
Skripte proti prod so privzeto **read-only sonde** (`tmp/probe_*.py`). Izbris je edina nepovratna
operacija; kar je odveč, ostane.

### Stanje ledgerja na PROD (preverjeno 2026-07-14)

`0001`–`0005`, `0011`, `0012`, `0013`, **`0014`, `0015`, `0016`** (vrzel `0006`–`0010` = M11 veja, glej zgoraj).

| Migracija | Vsebina | Rabi jo |
|---|---|---|
| `0014` | `task.yield_amount` + `yield_unit` | T11 zajem pridelka (vc14+) |
| `0015` | `supply.category` (NOT NULL default `other` + CHECK) | sredstva (vc14+) |
| `0016` | drop `supply_quantity_check` | **negativna zaloga** — brez tega `23514` na `supply` **zaklene cel sync** (supply se pusha pred task) |

**Pravilo (potrjeno v praksi):** vsak nov prod build najprej `supabase db push`, šele nato upload.
Pred vc14 je bil prod pri `0013`, medtem ko je koda že pisala `yield_amount`/`category` — živi vc13 je
bil rešen le zato, ker je bil zgrajen **pred** temi funkcijami. Ne zanašaj se na to; preveri.

### Uskladitev M11↔main + ledger vrzel (2026-07-24)

`feat/m11-smart-engine` je bil usklajen z `main` (`main`→M11, flag-dark). M11 veja ima zdaj **cel
nabor `0006`–`0016`**; datoteke `0006`–`0010` se prvič srečajo z `0011`–`0016` na eni veji. Preverjeno
stanje (read-only sonde, 2026-07-24):

| Okolje | Ledger | M11 objekti (`suggestion`, `app_config`, `engine_run`, `activity_*`, …) |
|---|---|---|
| **PROD** | `0001`–`0005`, `0011`–`0016` (vrzel `0006`–`0010`) | **obstajajo** (out-of-band) |
| **STAGING** (WSL) | `0001`–`0005`, `0011`–`0016` (vrzel `0006`–`0010`) | **NE obstajajo** |

Nabora sta **red-neodvisna** (M11 = climate/suggestion/engine/agg; main = default_garden/series/
yield/supply — **nič prekrivanja objektov**), zato je vrstni red aplikacije nepomemben.

**Idempotenca (2026-07-24):** `0006` in `0009` so retrofitani na `create table/index/materialized view
if not exists`, `drop policy if exists` + create, `insert … on conflict do nothing`. Razlog: ob
**ledger uskladitvi** (`db push` z M11-merged veje) bo CLI poskušal `0006`–`0010` (vrzel); na **prod**-u
ti objekti **že obstajajo** → brez idempotence bi crashnil (»already exists«). Na **staging**-u jih
ustvari na novo. `0007`/`0008`/`0010` so bili že idempotentni (funkcije `create or replace`, le granti).

**Server-dark flag `app_config.engine_enabled` (2026-07-24):** dodan (seed `false`) + guard na vrhu
**obeh** cron funkcij (`engine_dispatch()` 0007, `agg_refresh_all()` 0009): dokler je `false`, se croni
vrtijo a takoj no-op (server-mirror klientskega `kSuggestionsEnabled`). **Ob PRIŽIGU** (skupaj z
deploy edge fn + `kSuggestionsEnabled=true`): `update app_config set value='true' where key='engine_enabled';`.
Opomba: `engine_endpoint` je seedan na real edge fn, zato server-dark drži **flag**, ne odsotnost endpointa.

---

## 3. App deploy — `deploy.bat` matrika

| Ukaz | Build | Env (backend) | Namen |
|---|---|---|---|
| `deploy.bat hot` (= `dev.bat`) | debug + hot reload | **staging** | razvoj (privzeto) |
| `deploy.bat hot prod` | debug | **prod** | debug proti živi bazi |
| `deploy.bat staging` | release | staging | release proti stagingu (GLASNO opozori; **NI za Play**) |
| `deploy.bat` (brez arg.) | release | **prod** | Play build |

- Env se izbere prek `--dart-define-from-file`: staging → `dart_defines.staging.json`,
  prod → `dart_defines.json` (oba **gitignored**; v repo le `*.example.json`).
- Ob zagonu se izpiše `ENV: … — SUPABASE_URL=…` (preverba cilja).
- Telefon prek USB (razvijalske možnosti + USB debugging). Več naprav → Flutter vpraša katero.

### Play release (prod)
1. bump `version:` v `pubspec.yaml` (`1.0.0+N`).
2. `flutter build appbundle` z prod defines (oz. release build prek `deploy.bat` poti) → AAB.
3. upload v Play Console → ustrezen track (interni/zaprti test → prod).
4. SDK36 / 16KB / Play App Signing — že urejeno (`docs/go-live/`).

---

## 4. Kdaj migracija rabi nov app deploy?

- **Additive migracija (nov nullable/default stolpec, razširjen CHECK)** → **NE** rabi deploya.
  Stari APK-ji: tolerantni parser ignorira neznana polja (pull), server default napolni
  manjkajoče (push). Podatki tečejo takoj.
- **Deploy rabiš**, ko mora **app brati/pisati** novo polje (npr. device-side `created_at`),
  ali za novo app-logiko (npr. analytics eventi). Drift mora takrat **zrcaliti** shemo
  (`build_runner`), nato nov vc → upload.

---

## 5. Varnostna pravila (povzetek)

- **Linked = PROD.** Brez `--db-url` gre vse na prod. Za staging samo `tendask migrate` (strežnik).
- **Nikoli `supabase db reset`** na linkanem (= prod) projektu.
- **Additive-only**; rename/drop NIKOLI brez expand→contract (stari APK-ji ne smejo crashati).
- **Migracije najprej staging → test → prod.**
- **Ključi se ne commitajo** (`dart_defines*.json`, key.properties, keystore — vsi gitignored).
- **Release proti stagingu NI za Play** (deploy.bat to glasno opozori).
- Po vsaki DB spremembi: `supabase migration list` + probe sheme.
