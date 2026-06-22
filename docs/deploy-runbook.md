# Deploy & DB runbook (staging / prod)

Edina operativna referenca za **kako apliciramo migracije in deployamo app** — da ne ugibamo
vsakič znova. Env podrobnosti (ključi, tunel, Mailpit) so v [`docs/staging-env.md`](staging-env.md);
shema/pravila v [`supabase/README.md`](../supabase/README.md) in [`CLAUDE.md`](../CLAUDE.md).

---

## 0. Hitra orientacija (kaj gre kam)

| Sprememba | Staging | Produkcija |
|---|---|---|
| **DB migracija** | WSL skripta (cilja lokalni container `supabase-db`) | ta repo: `supabase db push` |
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
- Ukaz za zagon iz tega okolja: **TODO — dopolni točen klic** (npr. `wsl …` / pot do `.sh`).
- Sorodno: `tendask start/stop/status`, `tendask psql`, `tendask backup/restore`, `tendask logs`.
  Staging je **on-demand** — če je dol, API ne dela.

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
