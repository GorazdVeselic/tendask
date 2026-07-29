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

**Nova, še NE aplicirana:** `0017` (`@site` primerjalna skupina v pogledu `agg_event`, M11 korak 7b,
2026-07-25) — čaka skupaj z M11 vejo. Sama po sebi je neškodljiva (`create or replace view`, tabel in
RLS se ne dotakne) in mora biti na PROD **pred prižigom** nočnega agregata, sicer bi cron polnil
`activity_*` brez `@site` vrstic.

**Nova, še NE aplicirana:** `0018` (granti motorskih funkcij + `k_reliab()` + frekvenčni prag,
2026-07-27, plan popravkov §P5). Pred aplikacijo poženi sondo **S1** (`tmp/probe_p5.sql`), po njej
**S1 + S3b** za potrditev. Vsebina: revoke `engine_dispatch()`/`agg_refresh_all()` za
`anon`/`authenticated` (`revoke … from public` v `0007`/`0009` **ne** odstrani Supabase privzetih
grantov — isti razlog kot `0010` za tabele), nova `k_reliab()` (zrcalo `k_privacy()`), politika
`activity_frequency` dvignjena s `k_privacy` (5) na `k_reliab` (30), revoke na `engine_run`,
`weather_cache`, `app_config`, in **`agg_refresh_all()` znova deklarirana** (telo iz `0009` dobesedno,
razen praga `publishable`, ki gre s `k_privacy` na `k_reliab` — od zdaj je `0018` merodajna kopija).
⚠️ **`k_privacy()` ostane izvršljiv za `anon`/`authenticated`** — kličejo ga RLS politike vseh štirih
agregatnih tabel v kontekstu klicoče vloge; revoke bi zaprl branje Okolice v celoti. Isto zdaj velja
za `k_reliab()`. Po aplikaciji preveri, da branje agregatov z anon ključem še deluje.

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

### Testni vklop M11 na stagingu (2026-07-28)

Aplikacija dobi flaga iz okolja, ne iz ročnega urejanja `config.dart`:
`SUGGESTIONS_ENABLED` / `COMMUNITY_ENABLED` sta v `dart_defines.staging.json` (`"true"`) in
**nista** v `dart_defines.json`. `deploy.bat hot` → M11 prižgan, `deploy.bat` → prod build temen
**po zasnovi**. Ker je `bool.fromEnvironment` compile-time konstanta, se temna koda v prod buildu
še vedno odreže. Straža: `test/core/feature_flags_test.dart`.

**Stanje staginga po `tendask migrate` (7 novih: `0006`–`0010`, `0017`, `0018`):**

| Preverjeno | Ugotovitev |
|---|---|
| `app_config.engine_endpoint` | `0006` ga zaseeda s **produkcijskim** URL-jem — na stagingu **popravljen** na `https://api-staging.tendask.app/functions/v1/smart-engine`. Brez tega bi staging cron POST-al na prod funkcijo. |
| `cron.job` | `agg-nightly` (02:30) in `engine-dispatch` (*/30) sta **aktivna**, a no-op dokler je `engine_enabled=false`. |
| `engine_dispatch()` na stagingu | **ne dispatcha** — glej spodaj. |

**Cron na self-hosted stagingu ne bo tekel, in to je pričakovano.** Preverjeno z izvedbo:

1. `vault.decrypted_secrets` nima `engine_service_key` → funkcija javi
   `WARNING: missing engine_endpoint or engine_service_key — skipping` in se vrne.
2. Tudi po dodanem ključu bi jo ustavil stražar izvora
   `endpoint !~ '^https://[a-z0-9]+\.functions\.supabase\.co/'` (`0007`) — namerna obramba, ki
   samohostanega staginga ne pozna.

Za testiranje zato funkcijo **kličemo neposredno**, ne prek crona: dobiš popoln nadzor nad tem,
kateri uporabniki tečejo in kdaj, brez čakanja na časovno okno 07:00–12:00. Če bi kdaj hotel
cron tudi na stagingu, naj dovoljeni izvor postane **podatek** (`app_config`), ne vzorec v kodi —
prod vedenje ostane isto, ker se privzeta vrednost ne spremeni.

> ⚠️ Zapisano zato, ker ta razred napake **ne pove ničesar**: cron se vrti, `engine_run` ostaja
> prazen, aplikacija kaže prazen pas — brez ene same napake, ki bi kazala na vzrok.

**Deploy funkcije na staging:** `tool/staging_deploy_engine.sh` (poženi po vsaki spremembi motorja).
Kopira `smart-engine/` + `_shared/` v `volumes/functions/` in **prepiše gola imena uvozov** v
`npm:` specifikatorje — samohostani usmerjevalnik spawna delavce z `importMapPath = null`, zato
`deno.json` uvozna mapa tam ne velja. Omejitvi delavca: **150 MB** in **60 s** na zahtevo, kar pri
paketu 25 uporabnikov z vremenskimi klici ni veliko.

```bash
wsl -e bash -lc "/mnt/c/Users/Uporabnik/StudioProjects/tendask/tool/staging_deploy_engine.sh"
# klic (service-role žeton iz containerja, brez izpisa):
KEY=$(docker inspect supabase-edge-functions --format '{{range .Config.Env}}{{println .}}{{end}}' \
      | grep '^SUPABASE_SERVICE_ROLE_KEY=' | cut -d= -f2-)
curl -s -X POST https://api-staging.tendask.app/functions/v1/smart-engine \
     -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' \
     -d '{"user_ids":["<uuid>"]}'
```

> ⚠️ **`service_role` NE obide GRANT-ov** (obide samo RLS). `0008` trdi nasprotno in na tem je
> slonel cel načrt pravic M11. Na gostovanem Supabase je to zakrito s privzetimi privilegiji
> projekta; na stagingu je motor umrl na prvem branju z `42501 permission denied for table
> app_config`. Popravlja **`0019_m11_engine_service_grants.sql`** (aditivna, idempotentna).
> Preverba: sonda `m11_shape.sql` zdaj izpisuje tudi `GRANT|` vrstice.

**Testni podatki:** `supabase/seed/staging_test_data.sql` ustvari **40 sintetičnih sosedov** v
celici, ki jo prebere iz **tvojega** profila (če jih postaviš drugam, aplikacija ne vidi nič).
Zakaj 40 in ne 5: pod `k_privacy` (5) bucket ne vrne **ničesar**, pod `k_reliab` (30) pa vrne
opisne pasove namesto številk — s premalo sosedi ne moreš ločiti delujoče funkcije od pokvarjene.
Vsak sosed je »upravičen« (`eligible_user`: račun >14 dni, ≥10 opravil, ≥5 različnih dni), ima tri
sezone (dve zaključeni, sicer je krivulja `censored`) **in dve opravili v zadnjih 7 dneh**, sicer
`activity_recent` ostane prazen in pas »Ta teden« ne pokaže ničesar.

```bash
# enkrat na stack: marker, brez katerega se skripta odkloni izvesti
insert into app_config(key,value) values ('env','"staging"') on conflict (key) do update set value=excluded.value;

wsl -e bash -lc "cat .../supabase/seed/staging_test_data.sql | docker exec -i supabase-db psql -v ON_ERROR_STOP=1 -U postgres -d postgres"
docker exec supabase-db psql -U postgres -d postgres -c "select public.agg_refresh_all()"
```

Po zagonu (preverjeno 2026-07-28): `bucket_population` 3 · `activity_recent` 63 · `activity_season`
423 · `activity_frequency` 63; skozi RLS kot `anon` pa 3 / 18 / 144 / 9 — **pragovi res režejo**.
`refresh materialized view eligible_user` je del skripte: brez njega je vseh 40 sosedov nevidnih.

**Avtorizacija funkcije na stagingu je slabša kot na produkciji — namerno, a vedeti je treba.**
`isServiceRole` (`handler.ts`) žeton **dekodira, podpisa pa ne preveri**; naslanja se na
platformo, zato ima `supabase/config.toml` `[functions.smart-engine] verify_jwt = true` z
izrecnim opozorilom, da se nikoli ne deploya z `--no-verify-jwt`. Na produkciji to drži.
Samohostani staging teče z **`VERIFY_JWT=false`** (preverjeno v `supabase-edge-functions`), zato
je tam `isServiceRole` edini stražar in sprejme **katerikoli nepodpisan** žeton s
`role: service_role`. Posledici:

- za lastnimi vrati je to sprejemljivo, a **funkcija na stagingu je praktično odprta**;
- **noben test avtorizacije na stagingu ni dokaz**, da avtorizacija na produkciji deluje —
  za to sta merodajna `handler_test.ts` (401/405/400) in `verify_jwt = true` ob deployu.

### Prižig M11 — dva ločena dogodka

Predlogi in Okolica imata **vsak svoj flag** v `lib/core/config.dart` in **različna pogoja
pripravljenosti**. Prižgeta se lahko neodvisno; nikoli ju ne prižgi »zato ker sta oba M11«.

| | Pametni predlogi | Okolica (skupnost) |
|---|---|---|
| Klientski flag | `kSuggestionsEnabled = true` | `kCommunityEnabled = true` |
| Strežnik | deploy `smart-engine` edge fn + `engine_enabled='true'` | nočni `agg_refresh_all()` je tekel vsaj enkrat |
| Migracije | `0017`, `0018` aplicirane | `0017`, `0018` aplicirane |
| Plačljivost | brezplačno | **`kDevPlusStub = false`** ⬅ obvezno |

> ⚠️ **`kDevPlusStub = false` je pogoj prižiga Okolice, ne opcija.** Dokler je `true`, je naprava
> obravnavana kot upravičena in **plačljiva funkcija se podari vsem** — tease se ne pokaže nikoli.
> Tega se ne da vzeti nazaj tiho. FR-20 to konstanto nadomesti s podpisano licenco iz drifta.

> ✅ **Drugi pogoj prižiga Okolice — spodnja vrstica pri petih zavihkih — je izpolnjen** (R4,
> 2026-07-29). Peti zavihek stisne reže na **64 px**; nemške oznake so dobile krajše besede
> (`Start`, `To-dos`, `Journal`, `Garten`, `Umfeld`), slovenska `Opravila` (67,1 px) pa je ostala,
> ker se napisi pasu nehajo večati pri `kNavLabelMaxTextScale = 1,2`. Vnos `'nav (five tabs)'` je
> iz `kAcceptedWordBreaks` **izbrisan**, matrika ga meri v vseh treh jezikih — gl.
> `docs/prelomi-besed.md` §Prioriteta 4.

### Odprta vprašanja, ki oživijo ob prižigu

Iz triaže `docs/m11/10-odprta-vprasanja.md` (2026-07-28), kup B. Vsa imajo delovni privzetek in
**ne** blokirajo prižiga — blokirajo pa jih zamujene meritve, ker se večina ne da izmeriti nazaj.

- [ ] **Zapiši datum prižiga.** #1 in #2 se odločata »po 4–6 tednih«; brez zabeleženega dneva nič
      ne odšteva. Vpiši ga sem, ne v glavo.
- [ ] **#7 — prva poštena meritev upravičenosti.** Takoj po prvem `agg_refresh_all()` nad
      realnimi računi: `select count(*) from bucket_population`. Če je prazen, spusti `N` na 5;
      **K-jev ne nižaj** (`K_privacy` je nepogajalski). Staging številke (`bucket_population = 3`)
      ne pomenijo nič — sintetični sosedje so bili narejeni upravičeni.
- [ ] **#12 → N8 — sezonska simulacija ni zgrajena.** Dokler je ni, letne frekvence pravil ne
      pokriva noben test. Če prižig teče brez nje, to velja za znano vrzel, ne za presenečenje.
- [ ] **#9 → N12 — delež zavrnjenih dostav.** Merjenje **obstaja** (`engine_run.push_rejected_at`,
      migracija `0022`): mesec dni po prižigu poženi `supabase/probe/push_rejection_rate.sql`
      (read-only, varna na prod). Beri **per uporabnik**: nad 10 % **dva meseca zapored** je
      sprožilec za tabelo `device` iz #9; en skok je navadno tester, ki je aplikacijo ponovno
      namestil. Pred prižigom sonda vrne same ničle — to ni okvara.
- [ ] **#1, #2, #6 — po ~4 tednih** poglej statuse `suggestion` (`dismissed` / `expired` /
      `planned` deleže po pravilih) in šele nato premikaj prage. En parameter naenkrat, teden
      opazovanja.

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
