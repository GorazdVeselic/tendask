# Poglavje 10 — Odprta vprašanja (edina dovoljena)

> Vse spodaj NI blokada za implementacijo — vsaka točka ima delovni privzetek (že vgrajen v
> poglavja 1–9) in **odločitveno drevo**, kdaj/kako privzetek spremeniti. Vse nastavljivo brez
> deploya (`app_config`).

---

## Triaža sprožilcev (2026-07-28)

> **Zakaj obstaja.** #14 je bil zaprt šele, ko je eksplodiral, čeprav je njegovo lastno besedilo
> sprožilec napovedalo dobesedno (»preden postaviš test/staging …«). Odločitveno drevo, ki ga
> nihče ne prebere znova, ni odločitveno drevo — je opomba. Zato je vsako vprašanje zdaj
> razvrščeno po tem, **ali je njegov sprožilec že nastopil**, in ta razvrstitev se ponovi ob
> vsakem prižigu.

| Kup | # | Sprožilec — stanje v eni vrstici |
|---|---|---|
| **A · že nastopil** | **#5** | DoD se sklicuje na test petih lokacij s posnetimi odgovori, ki **ne obstaja** — pogoja »> 10 dni odstopanja« se ne da izmeriti. |
| | **#8** | Sprožilec je »ob M11.18 UI validaciji« = ta test na napravi; ob tem se je pokazalo, da kartica `unit` iz agregata sploh ne bere. |
| | **#12** | M11.15/16 sta narejena in seed obstaja, a **točka 2 (sezonska simulacija 365 dni)** ni bila nikoli zgrajena — dokument tega ne ve. |
| | ~~**#13**~~ ✅ | Sprožilec je nastopil in vprašanje je **zaprto**: `0020` postavi `before update of agg_context` (ohrani staro vrednost), sonda `agg_context_invariants.sql` to dokaže na stagingu. |
| **B · nastopi ob prižigu** | **#1** | Kalibracija pragov potrebuje 4–6 tednov statusov `suggestion` od realnih uporabnikov — ura se zažene ob prižigu. |
| | **#2** | Vremenski pragovi se popravljajo po dejanskih dismissih R1, ki jih pred prižigom ni. |
| | **#6** | Digest se odloči po poročilih »premalo vidim« oz. deležu `expired` — oboje nastane šele v rabi. |
| | **#7** | `bucket_population = 3` na stagingu ničesar ne pove (sintetični sosedje so bili **narejeni** upravičeni); prva poštena meritev je ob prižigu. |
| | **#9** | Privzetek je robustnejši, kot trdi besedilo (odjava in motor žeton počistita); metrika, na kateri drevo visi, **se zdaj zbira** (`push_rejected_at`, N12) — čaka le prižig, da dobi vrednosti. |
| **C · ni aktualno** | **#3** | Odvisen od izida #2 — dokler kalibracija vremena ni tekla, ni signala, da je 72 h premalo. |
| | **#4** | Potrebuje ≥ ~200 registriranih z lokacijo; realnih uporabnikov z vrtom je danes 2. |
| | **#10** | Potrebuje `activity_season.pooled_total ≥ 30` iz **realnih** dokončanih sezon; sintetika za kalibracijo pravil ne šteje. |
| | **#11** | Reaktiven: čaka poročilo »pomotoma sem utišal« — brez uporabnikov ga ni. |
| | **#15** | Reaktiven: čaka poročilo o izgubljeni nastavitvi ali dejansko multi-device urejanje. |

**Kaj sledi iz katerega kupa:** A → vrstica v `19-najdbe-med-izvedbo.md` (N8–N11, plus N12 iz #9) · B → kontrolni
seznam v `docs/deploy-runbook.md` §»Odprta vprašanja, ki oživijo ob prižigu« · C → ostane tu, s
pogojem, zapisanim pri vprašanju.

## 1. Kalibracija pragov motorja (po prvih realnih podatkih)

**Parametri:** cooldowni (R1:3d, R2:30d, R3:5d, R5:10d, R7:5d), dismiss trajanja, uteži ocen,
`emit_threshold=2.0`, obletnično okno ±7 d, `frost_safety_days=7`.
**Odločitveno drevo:** po 4–6 tednih internih testerjev poglej `suggestion` statuse:
- `dismissed / (planned+dismissed) > 60 %` za pravilo → pravilo prepogosto/prezgodaj →
  cooldown ×2 ALI prag +0.5.
- `expired > 70 %` (nihče ne reagira) → sporočilo/čas slaba → preveri uro pošiljanja in copy.
- `planned > 40 %` → pravilo dela; lahko znižaš prag in opazuješ, ali planned delež pade.
Vsi posegi: `app_config.engine`, brez deploya. Meritev = navaden SQL nad `suggestion`.

**Triaža 2026-07-28 — kup B.** Sprožilec je *pretek 4–6 tednov od prižiga*, ne prižig sam; ob
prižigu si zabeleži datum, sicer se štetje nikoli ne začne.

## 2. Vremenski pragovi (mm dežja, ure suhega, veter)

**Privzetki:** `app_config.weather_thresholds` (02 §G). Negotovo: koliko mm v 24 h res pomeni
»mokro za košnjo« (2.0 mm je konservativen) in ali je `dry_hours_min=24` prestrog za jesen.
**Odločitveno drevo:** dismissi R1 z opombo vremena ali pritožbe testerjev →
primerjaj prage z dejanskim sprejemanjem; popravljaj po enem parametru naenkrat (teden
opazovanja); cilj < 40 % dismiss na R1.

**Triaža 2026-07-28 — kup B.** Brez realnih dismissov ni signala; pred prižigom se pragov ne
tipa, ker bi jih premikal na sintetiki.

## 3. `drought7d` aproksimacija (R/lawn.water)

**Privzetek:** `recentRainMm72h < 2.0 AND forecastDryHours >= 24` (02 op. 1) — 72 h ni 7 dni.
**Odločitveno drevo:** če lawn.water spamlja po kratkem suhem obdobju → razširi weather_cache
payload s `past_days=7` (Open-Meteo forecast API to podpira do 92 dni; +tovor ~2×) in
implementiraj pravo 7-dnevno vsoto. Odločitev ob kalibraciji #2, ne prej (tovor ni zastonj).

**Triaža 2026-07-28 — kup C.** Odvisen od izida #2 — postane aktualen šele, ko kalibracija
vremena pokaže, da 72 h okno lawn.water spamla.

## 4. `climate_bucket` meje pasov + redundanca višinske osi

**Privzetek:** 4 višinski × 6 temperaturnih pasov (07 §7.2).
**Odločitveno drevo:** ob ≥ ~200 registriranih z lokacijo poglej porazdelitev košev
(`select climate_bucket, count(*) from profile group by 1`):
- > 80 % uporabnikov v ≤ 2 koših → pasovi pregrobi za fallback vrednost → drobnejši t-pasovi.
- koši z 1–4 uporabniki sistematično (V2 fallback vedno preskoči climate nivo) → grobji pasovi.
- če se e-os in t-os popolnoma podvajata (vsak e-pas ⊂ en t-pas) → opusti e-os pri NOVIH
  zapisih (stari ostanejo veljavni stringi — bucket je samo ključ).

**Triaža 2026-07-28 — kup C.** Pogoj je ≥ ~200 registriranih z lokacijo; danes sta realna profila
z vrtom **dva**, ostalih 40 je sintetike v eni celici (porazdelitev košev je s tem brez pomena).

## 5. Open-Meteo arhiv: 10 let vs 30 let normali

**Privzetek:** 10 let ERA5 (07 §7.1) — manjši tovor, novejša klima (segrevanje!).
**Odločitveno drevo:** če se frost mediane na testnih lokacijah (Ljubljana, Kranjska Gora,
Koper, Dunaj, München) razlikujejo od uradnih agro-koledarjev za > 10 dni → podaljšaj na
20–30 let ali preklopi na p75/mediano kombinacijo. Preveri v M11.3 DoD (testne lokacije so
del unit testov s posnetimi odgovori).

**Triaža 2026-07-28 — kup A (sprožilec je nastopil, meritve ni).** Stavek zgoraj o M11.3 DoD **ne
drži**: `test/core/location/climate_service_test.dart` ima en sintetičen primer
(»Ljubljana-like input«) in **nobene** od petih imenovanih lokacij, niti posnetega odgovora, niti
primerjave z uradnimi agro-koledarji. Dokler tega testa ni, se pogoja »> 10 dni odstopanja« ne da
niti ovreči niti potrditi — vprašanje je nezaprljivo, kot je napisano. Gl. **N11**.

## 6. Frekvenčna kapica: 1/dan vs digest

**Privzetek:** kapica vedno ON, max 1 push/dan (top score), stikalo `frequency_cap` v UI
skrito (06 §6.5). Digest (en povzetek z N predlogi) NI implementiran.
**Odločitveno drevo:** če testerji javljajo »premalo vidim« (pas spregledan) ALI je
`expired` delež visok kljub dobrim pravilom → implementiraj digest push ob 7:00 (naslov
»3 predlogi za tvoj vrt«) kot alternativo; stikalo 22 takrat oživi (single/digest).

**Triaža 2026-07-28 — kup B.** Oba signala (poročilo »premalo vidim«, delež `expired`) nastaneta
šele v rabi; pred prižigom je `suggestion` prazen povsod razen na stagingu.

## 7. Eligibility X/N/M + K_privacy/K_reliab (V2)

**Privzetki:** X=14 d, N=10 opravil, M=5 dni; K_privacy=5, K_reliab=30 (`app_config`).
**Odločitveno drevo (iz `skupnost-agregacija.md` §0.1/8):** prestroga upravičenost →
`bucket_population` prazen → najprej spusti N na 5; K-jev NE nižaj (K_privacy je
nepogajalski; K_reliab=30 je statistični minimum za ±9 % šum).

**Triaža 2026-07-28 — kup B.** `bucket_population = 3` na stagingu **ni** meritev upravičenosti:
`staging_test_data.sql` sosede zgradi tako, da vsa tri merila (`min_account_days`,
`min_done_tasks`, `min_active_days`) prestanejo po konstrukciji. Prva poštena meritev je prvi
`agg_refresh_all()` nad realnimi računi po prižigu.

## 8. Normalizacija frekvence (`unit`)

**Privzetek:** `per_season` (04 §4.6) — naslov »~2–5× na sezono«.
**Odločitveno drevo:** za visoko-frekvenčna opravila (košnja) je »na sezono« neintuitivno →
ob M11.18 UI validaciji po potrebi dodaj `per_month` izračun (n_events / aktivni meseci
sezone) kot DODATEN stolpec (additive), UI izbere enoto po tipu opravila
(`default_cadence < 30 dni → per_month`).

**Triaža 2026-07-28 — kup A (sprožilec je nastopil).** »M11.18 UI validacija« je ta test na
napravi. Ob pripravi nanj se je pokazalo, da odločitveno drevo ne bi delovalo, tudi če bi
`per_month` obstajal: agregat `unit` **ima** (`0009` stolpec, privzeto `per_season`), klient ga
prebere (`community_stats.dart:239`) in nese skozi model, kartica pa izpiše **fiksen**
`t.community.detail.freq_unit` (»na sezono«) — `community_frequency_card.dart:59`. Dodatni stolpec
bi torej šel v UI, ki ga ne bi upošteval. Gl. **N10**.

## 9. Multi-device FCM token

**Privzetek:** `profile.fcm_token`, zadnja naprava zmaga (06 §6.2).
**Odločitveno drevo:** pritožba »na tablici ne dobim« ali telemetrija UNREGISTERED > 10 %/mes
→ tabela `device(id, user_id, fcm_token, platform, last_seen_at)` (additive migracija),
engine pošlje vsem živim tokenom; do takrat ne (YAGNI).

**Triaža 2026-07-28 — kup B, s popravkom besedila.** Privzetek je **robustnejši**, kot trdi ta
točka: odjava žeton izniči *pred* koncem seje (`settings_screen.dart:56–60`, `updateFcmToken(…,
null)` + `flushPush()`), motor pa ga ob zavrnjeni dostavi izniči strežniško
(`handler.ts:263–268`), namenoma brez dviga `updated_at`, da null ne povozi svežega žetona v LWW.
Tabletne bombe torej ni. **Kar manjka, je druga veja drevesa:** »telemetrija UNREGISTERED
> 10 %/mes« se **nikjer ne meri** — veja `ok === false` žeton tiho počisti in ne zabeleži ničesar
(`reportError` steče samo ob vrženi napaki). Pogoj, ki ga sproži lastno drevo, je torej
neopazljiv. Gl. **N12**; opazljivost postane potrebna šele, ko pushi res tečejo → prižig.

**Dopolnilo 2026-07-28 (N12 zaprt).** Merjenje zdaj obstaja: `engine_run.push_rejected_at`
(migracija `0022`, **staging**) dobi žig v istem trenutku, ko motor počisti žeton, poizvedba pa je
`supabase/probe/push_rejection_rate.sql` (read-only, varna na prod). Vprašanje **ostaja odprto in
ostaja YAGNI** — spremenilo se je le to, da je njegov sprožilec zdaj **merljiv** namesto namišljen.
Prag beri **per uporabnik, ne per sporočilo**: »koliko uporabnikov je utihnilo ta mesec« je oblika
praga iz te točke. Tabelo `device` gradi šele, ko sonda dvakrat zapored pokaže > 10 % — en skok je
navadno en tester, ki je aplikacijo ponovno namestil. **Ni signala pred prižigom:** dokler pushi ne
tečejo, sonda vrne ničle (na stagingu 2026-07-28: `rejected_30d = 0`, `pushable_now = 0`).

## 10. Skupnostna kalibracija pravil (post-V2 ritem)

**Privzetek:** pravila so statična do prvih dokončanih sezon z gostoto; kalibracijski cevovod
(01 §D točka 3) je ročen/kuratorski.
**Odločitveno drevo:** ko ima ≥ 1 koš `activity_season` z `pooled_total ≥ 30` za tip opravila →
enkrat na sezono primerjaj vrh krivulje z oknom pravila; odstopanje > 2 tedna → popravi okno
(`community-calibrated` source_ref). NIKOLI avtomatsko; NIKOLI pod `K_reliab`. Morebitna
LLM pomoč = samo osnutki za kuratorja (01 §D), nikoli direktno pisanje pravil.

**Triaža 2026-07-28 — kup C.** Pogoj je `pooled_total ≥ 30` iz **realnih** dokončanih sezon;
`activity_season = 423` na stagingu je sintetika in za kalibracijo pravil ne šteje niti kot
indic — krivulje so bile generirane iz istih pravil, ki bi jih kalibrirala.

## 11. Razveljavitev trajnega muta (»Ne predlagaj več tega«)

**Privzetek:** MVP brez UI za preklic (dismissed_until='infinity' ostane).
**Odločitveno drevo:** če support/testerji javijo »pomotoma sem utišal« več kot enkrat →
Settings → Obvestila dobi seznam trajnih mutov z gumbom za preklic (bere `suggestion_log`
mirror, preklic = nov klientni kanal — takrat dodaj `suggestion.status='unmuted'` vzorec
ali server endpoint; odločiti ob potrebi, ne prej).

**Triaža 2026-07-28 — kup C.** Reaktiven: čaka poročilo »pomotoma sem utišal«. Brez uporabnikov
poročila ni; ob prižigu ni česa dodati na seznam, ker je edini ukrep odziv na support.

## 12. Kako testirati motor brez realnih uporabnikov

**Plan (ni odprt — zapisan, da se ne izgubi):**
1. **Deterministični Deno testi** (M11.15): sintetičen `UserBundle` + posneti Open-Meteo
   JSON-i; `Clock` ekvivalent = injectan `today` (engine NIKOLI ne kliče `Date.now()`
   direktno v logiki pravil — parameter `runDate`).
2. **Sezonska simulacija:** test, ki `runDate` premika čez 365 dni z fiksno zgodovino in
   preverja, da se vsako pravilo sproži ≤ pričakovano-krat (regresija proti spamu) — izpis
   »koledar predlogov za leto« kot golden file.
3. **Sintetična populacija za V2 (M11.16):** SQL skripta `tmp/seed_synthetic_users.sql`
   (50 uporabnikov, 3 celice, 2 leti zgodovine) → agg funkcije + RLS pragovi preverljivi brez
   ljudi; NE commitati v produkcijski seed.
4. **Dev-only ročni invoke:** `supabase functions invoke smart-engine --body '{"user_ids":[...]}'`
   za tek »zdaj« na lastnem računu (namesto čakanja na 7:00).

**Triaža 2026-07-28 — kup A (sprožilec je nastopil, ena od štirih točk ni zgrajena).** Stanje po
točkah, izmerjeno, ne ocenjeno:

| Točka | Stanje |
|---|---|
| 1 · deterministični Deno testi z injectanim `runDate` | **✅** 10 testnih datotek, 159 testov zelenih |
| 2 · **sezonska simulacija 365 dni / golden »koledar predlogov«** | **❌ NE OBSTAJA** — v vseh 10 `*_test.ts` ni nobenega preleta čez leto; edina zadetka na »calendar« sta komentar v `rules_agro_test.ts:469` in ime testa v `signals_test.ts:201`, oba o čem drugem |
| 3 · sintetična populacija | **✅**, a **ne** tam, kjer piše: `supabase/seed/staging_test_data.sql` (commitano, 40 sosedov), ne `tmp/seed_synthetic_users.sql`. Skrb »NE commitati v produkcijski seed« je rešena bolje kot z necommitanjem — skripta se odkloni izvesti, če `app_config.env <> "staging"` (`raise exception`, vrstica 35) |
| 4 · dev-only ročni invoke | **✅**, prek `curl` na staging endpoint (`supabase` CLI proti self-hosted stacku ne teče) |

Manjka torej **edina regresija proti spamu čez celo leto** — točno tisto, kar bi ujelo pravilo, ki
se sproži 40× na sezono, medtem ko deterministični testi vsakega gledajo na en `runDate`. Gl. **N8**.

## 13. `agg_context` write-once samo app-level (ne DB-vsiljeno)

**Privzetek:** `task.agg_context` je zamrznjen ob `done` na klientu (write-once, ohranjen ob
`↩ Na čaka`), a stolpec je navaden `jsonb` brez CHECK/trigger — invarianta živi samo v
`TasksRepository`. CLAUDE.md sicer želi DB-level invariante.
**Odločitveno drevo:** posnetek konzumira šele V2 agregacija (M11.16, `agg_event`). Ob M11.16,
preden agregati štejejo na ta polja, dodaj `before update` trigger, ki zavrne spremembo
`agg_context`, ko je stara vrednost ne-null (immutable po prvem zapisu) — takrat je tudi
jasno, ali kak migracijski backfill rabi izjemo. Prej ne (en sam pisalec = klient, app-level
guard zadošča za MVP, kjer se posnetek nikamor ne agregira).

**Triaža 2026-07-28 — kup A (sprožilec je nastopil dobesedno).** Pogoj se glasi »ob M11.16,
**preden** agregati štejejo na ta polja«. M11.16 je narejen in agregati **že štejejo**:
`agg_event` bere `coalesce(t.agg_context->>'h3_r7', p.h3_r7)` in enako za `h3_r6`/`h3_r5`/
`climate_bucket` — `0009_m11_community_agg.sql:129–132`, ponovljeno v `0017_agg_event_site_cohort.sql:35–38`.
Triggerja ni: `before update on public.task` da **nič** zadetkov čez vse migracije.

Zadnji stavek (»en sam pisalec = klient«) tudi ne drži več v celoti: `agg_context` piše tudi
**sync pull** (`remote_mappers.dart:272`), ki oblačno vrednost prepiše v drift brez guarda —
guard obstaja samo v `tasks_repository.dart:574` kot `where … and agg_context is null`. Na
Supabase strani ga ne varuje nič: RLS uporabniku dovoli update lastne vrstice, torej lahko star
APK ali napaka v klientu zamrznjeni posnetek prepiše, agregati pa isto opravilo naslednjič
preštejejo v **drugo celico**. Gl. **N9**.

**RAZREŠENO 2026-07-28 z migracijo `0020_task_agg_context_write_once.sql` (`b837c5f`).**
`before update of agg_context on public.task` **ohrani staro vrednost** namesto da bi stavek
zavrnil — `raise exception` je bil zavrnjen zavestno: klient potiska celo vrstico (opomba, status,
pridelek), zato bi padec zataknil sinhronizacijo te vrstice zaradi stolpca, ki ga uporabnik ne
vidi. Koerciranje agregat zaščiti v celoti, ker `agg_event` iz tega stolpca ne bere nič drugega;
`raise warning` ostane opazovalni šiv. Namerni ops poseg ima izhod v sili:
`set local app.agg_context_rewrite = 'on'`.

Zajeta sta **oba** pisalca iz triaže zgoraj: sync pull (`remote_mappers.dart:272`) in vsak
neposreden update prek RLS — trigger je pod obema. Dokaz ni branje migracije, ampak sonda
`supabase/probe/agg_context_invariants.sql` (teče v `rollback`, varna tudi na produkciji):
prvi žig dovoljen · prepis blokiran · ponovni push iste vrednosti brez napake · izhod v sili
deluje. Aplicirano na stagingu, na produkciji **še ne** — gl. kontrolni seznam pred `db push`
v `docs/deploy-runbook.md`.

Sorodno: `0021_agg_event_frozen_timezone.sql` je v isti sapi v posnetek dodal `timezone`
(**N15**), ker je `agg_event` `local_day` prej računal iz **živega** profila — polovica posnetka
je bila zgodovinska, polovica ne. **Triager naj to vrstico prestavi iz kupa A: sprožilec je
nastopil in odgovor je vgrajen v shemo.**

## 14. `engine_endpoint` URL hardcodan v migraciji (okoljsko specifičen)

**Privzetek:** `0005` seed-a `app_config.engine_endpoint` z absolutnim URL-jem produkcijskega
projekta (`https://<ref>.functions.supabase.co/smart-engine`); nočni `engine_dispatch()`
(`0006`) ga prebere in POST-a nanj. Za en živ projekt je pravilen; `app_config` je nastavljiv
brez deploya (`update app_config set value = ...`).
**Zakaj odprto:** project ref je zapečen v migracijo. Ob **drugem okolju (test/staging)** isti
migracije usmerijo cron novega okolja na **produkcijsko** funkcijo — tiho, brez napake.
Občutljivi `engine_service_key` je zato pravilno v Vault (`0006`), URL pa ne — neskladje.
**Odločitveno drevo (sprožilec = prvo ne-produkcijsko okolje):** preden postaviš test/staging,
**odstrani** `engine_endpoint` vrstico iz `0005` seeda in nastavi URL per-okolje — ali kot
Vault secret (ujemi vzorec `engine_service_key`), ali z ročnim `update app_config` ob postavitvi
okolja (kot je za ključ že dokumentirano v `0006`). Tako migracija postane okoljsko-nevtralna.
Prej ne (enoprojektni MVP — hardcodan URL je za edino okolje pravilen).

**RAZREŠENO 2026-07-28 (postopkovno, ne s spremembo migracije).** Sprožilec je nastopil: ob
`tendask migrate` je `0006` na staging vpisal produkcijski URL. Popravljeno z
`update app_config` na staging vrednost; postopek je zdaj korak v `docs/deploy-runbook.md`
(»Testni vklop M11 na stagingu«) skupaj s sondo za preverbo. Migracija ostane nespremenjena,
ker je `on conflict do nothing` in je na prod že aplicirana — ponovno pisanje bi bilo tveganje
brez koristi. **Ob vsakem novem okolju je preverba `engine_endpoint` obvezen korak.**

Izmerjeni doseg, če bi ostalo nepopravljeno: **nič na produkciji** — ustavijo ga tri neodvisne
stvari (manjkajoč `engine_service_key` v staging Vaultu, stražar izvora v `0007`, in
`verify_jwt = true` na prod funkciji). Cena bi bil staging test, ki tiho ne naredi nič.

## 15. Profile pull `<=` tie-break lahko povozi še-ne-pushan `pending` profil

**Privzetek:** inkrementalni pull (`sync_pull_service.dart`) uporablja generično
`onConflict: DoUpdate(where: updated_at <= ts)` za VSE tabele — ob enakem `updated_at`
zmaga oblak (dokumentiran LWW tie-break). drift ima sekundno ločljivost.
**Zakaj odprto:** profil nima per-field LWW (povozi se cela vrstica). Če uporabnik offline
uredi `lang`/`notification_settings` v **isti sekundi**, kot je `updated_at` oblačne vrstice,
ki jo pull prinese, `<=` tiho povozi lokalni `pending` zapis pred pushem → izguba nastavitve.
Verjetnost je ~ničelna (enouporabniški račun; zahteva dve napravi v isti sekundi), realno
clobber-pot (parcialni insert ob prvem pullu) pa že pokriva grace-straža (`profile_write_guard`).
**Odločitveno drevo (sprožilec = poročilo o izgubljeni nastavitvi ali multi-device urejanje):**
če tester/telemetrija pokaže tiho izgubo profilne nastavitve, dodaj per-status izjemo —
za `sync_status = pending` vrstice uporabi strogi `<` (lokalni pending ob izenačenju zmaga),
ALI primerjaj po podsekundah, kjer je na voljo. Ne prej: globalna sprememba `<=`→`<` v stabilni
sync poti za ~nemogoč rob ni vredna blast radiusa; polja so nizko-tvegana in ponovno nastavljiva.

**Triaža 2026-07-28 — kup C.** Reaktiven: čaka poročilo o izgubljeni nastavitvi ali dejansko
urejanje z dveh naprav. Opomba za tistega, ki bo to nekoč odpiral: **`profile.fcm_token` gre po
isti poti** in ga zdaj pišeta dva pisalca (klient ob odjavi, motor ob UNREGISTERED — gl. #9), zato
je `handler.ts:268` namenoma **ne** dvigne `updated_at`. Če se `<=` kdaj spremeni v `<`, je to
mesto treba pogledati skupaj s tem vprašanjem.
