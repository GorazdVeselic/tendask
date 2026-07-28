# M11 — predaja seje (staging teče, sledi triaža + test na napravi)

> **Datum:** 2026-07-28 · veja `feat/m11-smart-engine` · **nič pushano, produkcija nedotaknjena**
> **Vstopna točka za novo sejo.** Preberi tega celega, nato `19-najdbe-med-izvedbo.md`
> (dnevnik najdb) in `17-plan-popravkov.md` §3 za pakete, ki še niso narejeni.

---

## 0 · Stanje v eni vrstici

P1–P9 narejeni in commitani · motor **teče na stagingu in izdeluje predloge** · 40 sintetičnih
sosedov posejanih, agregati polni, RLS dokazano reže · ostajajo **P10, P11, P12** + triaža
odprtih vprašanj. `flutter analyze` čist · **1285 Flutter** + **159 Deno** testov zelenih.

## 1 · Commiti te seje (najstarejši najprej)

| Hash | Kaj |
|---|---|
| `79d2906` | ostanka P7 — testi `fcm_token_service`/`fcm_handler`, agregatna poizvedba iz `application/` v `data/` |
| `fec0761` | **P8** — offline ločen od praznih podatkov, svežina rezine, pull-to-refresh |
| `f79a4ea` | detektor prelomov sredi besede + `docs/prelomi-besed.md` |
| `7d06944` | **P9** — ločen `kCommunityEnabled`, cross-branch navigacija z realnim `StatefulShellRoute` |
| `e658a2c` | flaga iz okolja, sonda `supabase/probe/m11_shape.sql`, zaprto vprašanje #14 |
| `91482c3` | **`0019`** pravice `service_role`, `tool/staging_deploy_engine.sh` |
| `bbf2936` | seed testnih podatkov + `19-najdbe-med-izvedbo.md` |

## 2 · Odločitve, sprejete v tej seji

- **O3 = ločen flag** (tvoja izbira). `kSuggestionsEnabled` in `kCommunityEnabled` sta neodvisna
  in oba `bool.fromEnvironment` — `"true"` samo v `dart_defines.staging.json`, zato je **prod
  build temen po zasnovi**, ne po spominu. Straža: `test/core/feature_flags_test.dart`.
- **Testni vklop je na stagingu, ne na produkciji.** Produkcije se v tej seji ni dotaknilo nič.

### Še odprto (blokira pakete)

| # | Vprašanje | Blokira | Priporočilo |
|---|---|---|---|
| **O4** | R1 »suho okno« | P10 | **(c) dokončaj, kar spec že piše** — R1 ostane ojačevalec, mrtvi `suggestions.weather.window_open` ven, kartica izvornega pravila dobi pripono, ko je `dry_window` postavljen. Motor param **že pošilja**, klient ga ne bere (najdba N4). Odgovori **po testu na napravi**, ko boš videl, kaj kartica dejansko pokaže. |
| **O5** | `plant_task_rule` na klientu | P11 | odvisno od roadmapa offline motorja; brez njega ven (1127 vrstic seeda brez bralca) |
| **O6** | `suggestions.community.most_started` | P10 | **(a) opisno** — P4 je isto uokvirjanje namerno odstranil iz plačljivih kartic; brezplačni pas bi ga vrnil skozi zadnja vrata |

## 3 · Staging — preverjeno stanje (2026-07-28)

| Kaj | Stanje |
|---|---|
| Migracije | **`0001`–`0019`** aplicirane (`tendask migrate`) |
| `app_config` | `engine_enabled=true` · `engine_endpoint` → **staging** URL · `env="staging"` (marker za seed) |
| Edge funkcija | `smart-engine` deployana v `volumes/functions/`, `npm:` uvozi razrešeni |
| Motor | **stekel od konca do konca**: R3 / `water` / score 4 → `suggestion`, `engine_run`, `suggestion_log` |
| Sosedje | **40 sintetičnih** + 2 realna računa · 683 opravil · vsi upravičeni |
| Agregati | `bucket_population` 3 · `activity_recent` 63 · `activity_season` 423 · `activity_frequency` 63 |
| Skozi RLS kot `anon` | **3 / 18 / 144 / 9** — pragovi res režejo |

**Ukazi, ki jih boš rabil:**

```bash
# migracije (bere migracije direktno iz repa, commit ni potreben)
wsl -e bash -lc "tendask migrate"

# deploy motorja po vsaki spremembi
wsl -e bash -lc "/mnt/c/Users/Uporabnik/StudioProjects/tendask/tool/staging_deploy_engine.sh"

# ročni tek motorja (cron na stagingu NE dela — gl. §6)
KEY=$(docker inspect supabase-edge-functions --format '{{range .Config.Env}}{{println .}}{{end}}' \
      | grep '^SUPABASE_SERVICE_ROLE_KEY=' | cut -d= -f2-)
curl -s -X POST https://api-staging.tendask.app/functions/v1/smart-engine \
     -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' \
     -d '{"user_ids":["<uuid>"]}'

# testni podatki + agregati
wsl -e bash -lc "cat /mnt/c/.../supabase/seed/staging_test_data.sql | docker exec -i supabase-db psql -v ON_ERROR_STOP=1 -U postgres -d postgres"
docker exec supabase-db psql -U postgres -d postgres -c "select public.agg_refresh_all()"
```

---

## 4 · Naloga A — triaža 14 odprtih vprašanj

`10-odprta-vprasanja.md` ima **15 vprašanj, razrešeno 1** — in to #14, ki sem ga zaprl šele, ko je
**eksplodiral**. Njegovo besedilo je lasten sprožilec napovedalo dobesedno (»preden postaviš
test/staging …«), a seznama ni nihče znova prebral.

**Naredi:** preleti vseh 14 in razvrsti v tri kupe, vsakega z enim stavkom utemeljitve:

1. **Sprožilec je že nastopil** → živa bomba, gre takoj v `19-najdbe-med-izvedbo.md` kot odprta
   vrstica. Sumi na: **#12** (»kako testirati motor brez realnih uporabnikov« — odgovorjeno v
   praksi s seed skripto, dokument tega ne ve), **#9** (multi-device FCM žeton), **#13**
   (`agg_context` write-once samo app-level, medtem ko agregati na to polje že štejejo).
2. **Sprožilec nastopi ob prižigu** → v kontrolni seznam v `docs/deploy-runbook.md`.
3. **Ni aktualno** → ostane, z izrecno zapisanim pogojem, kdaj postane.

Rezultat vpiši **v dokument, ne v povzetek** (gl. spomin `feedback-log-findings-immediately`).

---

## 5 · Naloga B — izčrpen test na napravi proti stagingu

### 5a · Priprava

1. **Odstrani produkcijsko različico** — isti `applicationId` (`app.tendask`), zato se
   staging build ne bo namestil čez njo:
   ```
   adb uninstall app.tendask
   ```
   S tem gre tudi lokalna drift baza — to je **zaželeno**: onboarding se testira od začetka.
2. `adb shell svc power stayon true` kot **prvi** korak seje.
3. `deploy.bat hot` → debug build proti **stagingu**, oba flaga prižgana.
4. Prijava: OTP pride v **Mailpit** (gl. `docs/staging-env.md`).
5. **Nastavi lokacijo vrta** — brez nje profil nima `h3_*` celic, seed nima kam sejati in vsa
   Okolica je prazna. Po nastavitvi **ponovno poženi seed** (celico prebere iz tvojega profila).

### 5b · Kaj je na tem testu edinstveno

Staging bazo smeš polniti in prazniti po mili volji. Zato tu preveri, kar na produkciji **ni
ponovljivo**: **obnašanje na pragovih k-anonimnosti**. To je edini razlog, da Okolica obstaja, in
doslej ni bilo nikoli videno na zaslonu.

```sql
-- 40 sosedov (privzeto po seedu) → odstotki in histogram
-- spusti pod k_reliab (30) → opisni pasovi namesto številk
delete from auth.users where id::text like '00000000-0000-4000-8000-%'
  and (id::text ~ '0*([0-9]+)$');           -- pobriši nekaj, do ~29 profilov
select public.agg_refresh_all();

-- spusti pod k_privacy (5) → NIČ, ne prazna kartica z ničlami
-- nato ponovno poženi seed za vrnitev na 40
```

Po vsaki spremembi: `agg_refresh_all()` **in** v aplikaciji pull-to-refresh (dnevni cache!).

### 5c · Kontrolni seznam — po zaslonih

Ob vsaki točki zapiši **kaj si videl**, po ADB screencapu, ne po spominu.

**Domov (pas predlogov, M11.13)**
- [ ] Predlog se pojavi po sync pullu (**ne** prek pusha) — motor piše v Supabase, klient potegne
- [ ] Akcije: `✓ opravljeno` · `Načrtuj` (odpre predizpolnjen obrazec) · `Ne zanima me` · `Zakaj?`
- [ ] **`Ne zanima me` → ponovno poženi motor → predlog se NE vrne.** To je cel smisel P1;
      preveri tudi vrstico: `select guard_key, dismissed_until from suggestion_log`
- [ ] `Zakaj?` pojasnilo je razumljivo brez predznanja
- [ ] Pas kaže največ 3 hkrati (`band_max_active`)

**Nastavitve**
- [ ] Sekcija »PAMETNI PREDLOGI« je vidna (flag je prižgan)
- [ ] `Pretekli predlogi` → zgodovina se izriše
- [ ] Obvestila: stikali `weather_hints` / `community_hints` sta **aktivni** (prej inertni)

**Okolica — pristajalni zaslon**
- [ ] Peti zavihek ⬡ obstaja · **preveri nemščino pri text×1,3 na 320/360 dp** — znan prelom
      sredi besede (`Startsei/te`), pogoj prižiga
- [ ] »Ta teden«: vrstice z opisno intenziteto, meta vrstica z obsegom in populacijo
- [ ] »Kje si ti«: pasovi po kohortah
- [ ] **Pull-to-refresh na obeh zavihkih** (tudi v praznem stanju — `PullableEmpty`)

**Okolica — detajl (`community-task`)**
- [ ] **Tri vstopne poti**, vsaka posebej: vrstica v pasu · sekcija »V tvoji okolici« na Domov ·
      kartica na detajlu opravila
- [ ] **Cross-branch: iz Domov → detajl → nazaj → menjava zavihka.** Ta pot navigatorja v tej
      kodni bazi že enkrat je sesula; test z realnim shell routerjem je zelen, **naprava je dokaz**
- [ ] `water` (nesezonski tip) → kartica časovnice se **NE** izriše (P6)
- [ ] Sezonski tip (`prune`, `fertilize`, `mow`) → krivulja, »ti« oznaka, frekvenčni histogram
- [ ] Ubeseditev percentila se ujema s pozicijo (P4: mid-rank, ne kumulativa)

**Offline (letalski način)**
- [ ] Zadnja rezina ostane vidna + **vrstica »Podatki od {datum}«**
- [ ] Naprava, ki okolice **še ni prebrala** → »Podatkov o okolici na tej napravi še ni«,
      **ne** »premalo vrtnarjev« (P8)
- [ ] Hiter vnos in izvedba opravila delujeta brez signala; vremenski posnetek se ne zapiše
- [ ] Vrnitev signala → pull-to-refresh napolni

**Jezik in velikost pisave**
- [ ] sl / en / de × privzeta in ×1,3 na vsakem M11 zaslonu
- [ ] Nobenega odrezanega besedila razen znanega seznama v `docs/prelomi-besed.md`

### 5d · Česar na stagingu NE moreš preveriti

- **Push (FCM).** `FCM_SERVICE_ACCOUNT_JSON` v staging containerju **ni nastavljen** (preverjeno),
  zato `sendSuggestionPush` odpove in `pushed:false`. Če hočeš testirati push in globoko povezavo,
  je treba to skrivnost dodati v staging edge-functions okolje; naprava žeton itak registrira v
  **istem** Firebase projektu (`google-services.json` je iz repa).
- **Avtorizacija funkcije.** Staging teče z `VERIFY_JWT=false`, zato je `smart-engine` tam
  praktično odprt. **Noben test avtorizacije na stagingu ni dokaz za produkcijo** (najdba N6).
- **Cron.** Na stagingu ne teče (§6) — motor poganjaj ročno.

---

## 6 · Pasti, ki ti vzamejo uro (vse preverjene v izvedbi)

- **Cron na stagingu ne dispatcha.** Manjka `engine_service_key` v Vaultu, in tudi z njim bi
  ustavil stražar izvora `^https://[a-z0-9]+\.functions\.supabase\.co/` (`0007`). Simptom je
  **tišina**: cron se vrti, `engine_run` prazen, pas prazen, napake nikjer.
- **`service_role` NE obide GRANT-ov, samo RLS.** `0008` trdi nasprotno. Popravlja `0019`. Če se
  motor kdaj spet zaduši z `42501`, je manjkala pravica — najverjetneje za **vgnezdeno relacijo**
  (`plant`, `task_subject`, `task_reminder`, `task_supply`), ki se v `.from()` nikoli ne pojavi.
- **`refresh materialized view eligible_user`** je del seed skripte. Brez njega je vseh 40
  sosedov nevidnih in vse je prazno.
- **`activity_recent` je drseče 7-dnevno okno.** Sezonska zgodovina ga ne napolni — seed zato
  vsakemu sosedu doda dve sveži opravili.
- **Dnevni cache Okolice.** Po spremembi v bazi aplikacija **ne bo** videla novega, dokler ne
  potegneš pull-to-refresh — cache je vezan na lokalni dan.
- **`deno check` teči iz `supabase/functions/smart-engine/`** (import mapa je v njenem
  `deno.json`); `deno test supabase/functions/` pa **iz korena**, kot CI.
- **Ne uporabljaj PowerShell here-stringov v Bash orodju** — `@` pristane v commit sporočilu.
  Za večvrstična sporočila `git commit -F - <<'MSG'`.
- **Na napravi:** koraki v `tmp/steps.txt` + `./tool/adb_run.ps1` (`taptext`, `tap`, `text`, `key`,
  `swipe`, `wait`, `dump`); napisi, ne koordinate. `adb input text` ne tipka šumnikov.

## 7 · Kaj ostane po tem

- **P10** (čaka O4, O6) — jezik, push telesa v tikanju, mrtvi ključ, `screen-map.md`, #13/#14
- **P11** (čaka O5) — higiena; **dodaj N1 `profile.timezone` in N2 `communityWeekly`** iz dnevnika
- **P12** — ta test je P12
- **Po M11, lasten paket:** 44 prelomov sredi besede (`docs/prelomi-besed.md`)
- **Pred prižigom Okolice:** popravek spodnje vrstice pri petih zavihkih + `kDevPlusStub=false`
- **Pred `db push` na prod:** sonda `supabase/probe/m11_shape.sql` in diff proti stagingu —
  osem migracij bo šlo naenkrat na bazo, katere oblike še nisva primerjala

## 8 · Sklici

`19-najdbe-med-izvedbo.md` (dnevnik najdb — **beri prvi**) · `17-plan-popravkov.md` (paketi) ·
`docs/deploy-runbook.md` (staging vklop, prižig, pasti) · `docs/prelomi-besed.md` ·
`docs/staging-env.md` · `10-odprta-vprasanja.md` · `CLAUDE.md`
