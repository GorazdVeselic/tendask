# M11 — predaja seje (**P11 in N12 zaprta**, ostane samo naprava)

> **Datum:** 2026-07-28 · veja `feat/m11-smart-engine` · **nič pushano, produkcija nedotaknjena**
> **Vstopna točka za novo sejo.** `18-` do `24-nadaljevanje-prompt.md` so zastareli.
> Beri tega, nato `19-najdbe-med-izvedbo.md` (pregled na vrhu) in `17-plan-popravkov.md` §P12.

---

## 0 · Kje sva

Delovno drevo je **čisto**. Zadnji commiti na veji (dva sta iz vzporednih sej, nista M11):

| Hash | Kaj |
|---|---|
| `4df0957` | **N12** — zavrnjena dostava pusha pusti žig (`engine_run.push_rejected_at`) |
| `b0ed9d0` | FR-22 poziv za lokacijo (**druga seja**, ni M11) |
| `a1c861b` | predaja za paket 6 |
| `1719415` | **Paket 5** — P11 higiena: O5, mrtva koda, imena kanalov, dispose, Dart↔Deno |
| `adb3928` | geo orodje (**druga seja**, ni M11 — pristalo je vmes) |

Stanje: **1333 Flutter + 176 Deno zelenih**, `flutter analyze` čist, parity testi zeleni.
Migracije **0020/0021/0022 so samo na stagingu**; produkcija jih nima in tako ostane.

**Vsi paketi razen enega so zaprti, in odprtih najdb, ki bi jih bilo pametno rešiti pred
prižigom, ni več.** Ostane **Paket 6 (naprava)** — to je cilj te seje.

## 1 · Kaj je paket 5 naredil

| Postavka | Popravek | Artefakt |
|---|---|---|
| **O5** | `plant_task_rule` ven iz APK, drift in sync. Seed je **preseljen** v `tool/seed/`, ne izbrisan — trije generatorji berejo iz njega. Drift **v17** tabelo odvrže. | Regenerirana `plant_task_rules.sql` in `catalog_fixture.ts` se razlikujeta **samo v vrstici s potjo** — nobeno pravilo se ni premaknilo · `schema_shape_test` (tabele ni) · migracijski test v16→v17 na **polnih** tabelah |
| **P1 korak 5** | Pull `suggestion_log` ustavljen; drift tabela in mapper šla za njim. | `sync_pull_service_test` (»nikoli vprašan«) · `sync_roundtrip_test` (1 vrstica, ne 6) |
| **N30** | Imena Android kanalov iz slovenskih konstant v katalog (`notif_channel.*`, sl/en/de). | `notification_channel_name_test.dart` — na verziji izpred popravka pade **4×/4** |
| mrtva koda | `activeSuggestionsCountProvider` + `watchActiveCount()` · `suggestions.toast.planned` · `distinctUsers7d` ×2 · `FrequencyStats.p50` | grep = 0 bralcev pred izbrisom |
| rast | `community_cache` se pri vsakem pisanju obreže (`kCommunityCacheMaxAge` = 7 dni) | test: stare vrstice ne preživijo pisanja |
| **N2** | `communityWeekly` dobil dva testa (isti lestvici kot krivulja) | `community_fallback_test.dart` |
| `dispose` | `FcmHandler` · `_archiveDio` · `profileRowReadyForWrite` in `waitForProfile` (`.timeout` na `Future` **ne** prekliče `firstWhere` naročnine) | naročnina se drži eksplicitno in prekliče v `finally` |
| Dart↔Deno | retry poenoten na »maks 3« · `kFetchTimeoutMs` z **zapisanim razlogom**, zakaj strežnik sme imeti krajši timeout od telefona | Deno test: 3 poskusi, ne 4 |
| knoba | `wind_treat_kmh` / `wind_transplant_kmh` dobila bralca (`guards.ts` je uporabljal literala 15 in 20) | Deno test: prestavljen knob dejansko premakne stražo |
| podvojeni widgeti | pill ×3 → `StatusPill` (`core/widgets/`) · `_Rows` ×2 + tease ×2 → `TeasedRowCards<T>` | oba vpisana v `docs/ui-katalog.md` |
| plasti | Supabase klient iz `application/` v `data/` (`liveAggFetch`) · `_exactAlarmsAllowedProvider` v `application/` · `communityTimingLabel` privatiziran · slovensko ime testa | `flutter analyze` čist |

Neto **−1988 vrstic**.

## 1b · Kaj je naredil N12 (za paketom 5, lasten commit)

Zavrnjena dostava pusha ni pustila **ničesar** — motor je počistil `profile.fcm_token`, uporabnik je
nehal dobivati obvestila, in nikjer ni nastala vrstica, ki bi to povedala. Odločitveno drevo **#9**
(»telemetrija UNREGISTERED > 10 %/mes → tabela `device`«) je viselo na številki, ki se ni zbirala.

| Kaj | Kje |
|---|---|
| `engine_run.push_rejected_at` — en nullable stolpec, **brez** nove tabele | migracija `0022`, **staging** |
| `maybePush` vrne `'sent' \| 'rejected' \| 'skipped'`; ob zavrnitvi žig + `push_rejected: true` v odgovoru, ki ga dispatcher shrani | `handler.ts` |
| Poizvedba, ki odgovori na #9 (read-only, **varna na prod**) | `supabase/probe/push_rejection_rate.sql` |
| Kontrolna točka mesec po prižigu | `deploy-runbook.md` §»Odprta vprašanja, ki oživijo ob prižigu« |

GRANT ni bil potreben: `0019` je dal `insert, update` na `engine_run` na **ravni tabele**. Preverjeno
na stagingu s `has_column_privilege`, ne po spominu.

## 2 · Odločitve, ki jih ne smeš »popraviti«

- **Nov `channelId` je bil zavrnjen (N30).** Opozorilo, da Android ime kanala ob spremembi ne
  posodobi, **drži** — leno ustvarjanje (`createIfNotExists`) ga res ne. Sklep »torej nov id« pa ne:
  prod nima kanala `suggestions` (flag je `false`), preostala dva pa obstajata samo pri **slovenskih**
  namestitvah, kjer je slovensko ime **pravilno**. Nova namestitev kanal ustvari na novo in z
  lokaliziranim imenom dobi pravo besedilo **brez** menjave id-ja; menjava bi obstoječim pokazala
  **dva enako imenovana kanala** in jim pobrisala lastne nastavitve zvoka. Ceno bi plačali vsi,
  korist ne bi imel nihče. **Zapisana omejitev:** naprava, ki jezik zamenja **po** prvem nastanku
  kanala, obdrži staro ime do ponovne namestitve — na napravi bo videti kot napaka, pa ni.
- **Drift tabela `suggestion_log` je šla, ne samo pull.** Načrt je predpisal »ustavi pull«; ko pull
  odpade, tabela nima ne pisca ne bralca in argument je dobesedno isti kot pri O5, zato je v istem
  v17. Strežnik jo piše in bere naprej — šla je samo klientova kopija.
- **`NotificationService.isReady` in SQL stolpci `refreshed_at`/`unit` ostajajo (N31).** Nista dolg.
- **Žig zavrnitve je per-uporabnik, ne per-sporočilo (N12).** Prag iz #9 sprašuje »koliko
  uporabnikov je utihnilo ta mesec«, in časovni žig ne rabi read-modify-write na vrstici, ki jo
  motor tako ali tako upsertira. Kdor to obrne v števce, naj najprej pove, katero vprašanje s tem
  odgovori — tabela `device` iz #9 **ostaja YAGNI**, dokler sonda dvakrat zapored ne pokaže > 10 %.
- **Zavrnitev se namenoma NE poroča prek `reportError` (N12).** Ta helper piše `evt="engine_error"`,
  kar je edini filter, ki naj pomeni, da je nekaj pokvarjeno. Odstranjena aplikacija je pričakovan
  dogodek. Napaka pri **zapisu** žiga pa je engine error in se poroča.
- **Toleranca za `'infinity'` je bila preusmerjena, ne izbrisana (N29).**
- Iz prejšnjih sej velja naprej: **push nosi naslov, ne telesa** · **zajem generatorja je seznam,
  ne vzorec** · **test markerjev bere surov katalog** · `gendered_wording_test.dart` ima namenoma
  dva dela · **datum nosi piko, predloga je nima** · izbirna poved `[...]` v `fillTemplate` ·
  **O7** lestvica `[1,1,2,4]` · **N5, N6** (staging) · **N10** · **N24** · ostanek **N22**.
  Vse to je **sprejeto**, ne dolg.

## 3 · Poduk, ki naj vpliva na način dela

Paketi 3 in 4 sta pustila pravilo »ne piši preozkega vzorca« (N26, N27). Paket 5 ga je razširil
v dve smeri, obe je vredno nesti naprej:

> **Grep pove, kdo bere. Ne pove, ali sme ven.** (N31)

Seznam mrtve kode v §P11 je nastal iz grepa po bralcih. Dve postavki nista bili mrtvi: pri
`isReady` je cena odstranitve **pokritost** (edini test, ki dokazuje, da `init()` požre `invalid_icon`,
se skrči na »ni vrglo«), pri SQL stolpcih pa **`db push` na produkcijo za nič**. Pred vsakim izbrisom
je torej drugo vprašanje: *kaj ta vrstica stane, če ostane?*

> **Ob izbrisu preveri, kateri testi so na simbolu viseli zaradi udobja.** (N29)

Ustavitev pulla `suggestion_log` bi s seboj vzela edini test tolerance za Postgres `'infinity'` —
ta pa ni lastnost stolpca, ampak **skupnega parserja**: `throw` uide iz `pull()` in zamrzne kurzor
**vseh** tabel. Test je preusmerjen na `profileFromRemote`, ne izbrisan.

> **Kanal za napake je alarm, ne dnevnik.** (N12)

Prva verzija je zavrnjen žeton javila prek `reportError` — s sintetičnim `new Error('UNREGISTERED')`,
katerega stack je kazal v našo kodo in ni pomenil ničesar. Pričakovan dogodek pod `evt="engine_error"`
otopi filter, ki je edini alarm. Durable signal sodi v **vrstico**, ne v log.

**Kar ostaja nepreverjeno:** `kAcceptedWordBreaks` (če se niz spremeni, vnos ostane in tiho dovoli
nov prelom) in anti-steering varovalo (bere `community.*` + `suggestions.community.*`; nov niz s
socialnim dokazom pod tretjim poddrevesom bi šel mimo).

---

## 4 · Delovni nalog: Paket 6 — naprava *(zadnji paket)*

`17-plan-popravkov.md §P12` + ostanek testnega načrta. Brez tega P9 ni dokazan.

**Pripravi:** `kSuggestionsEnabled = true` in `kCommunityEnabled = true` v lokalnem buildu, naprava
prek USB, `adb shell svc power stayon true` kot **prvi** korak.

### 4.1 · Kar je bilo popravljeno in ga na napravi še nihče ni videl

To je jedro paketa — trije paketi popravkov so šli skozi teste, ne skozi oči:

- **Tri stanja »Kje si ti«** (N17): prazna zgodovina · zgodovina, a nesezonska · pretanka soseska.
  Rabiš vse tri, in tretje zahteva kohorto pod pragom.
- **Pripona suhega okna** (O4) na kartici izvornega pravila.
- **Novi naslovi in prislovi iz P10.1** (spol): »Lepo, da si tu« · `standing.band` kot
  `zgodaj/običajno/pozno` · žetev, prednastavitveni list.
- **Imena kanalov (novo, N30):** `Nastavitve → Obvestila → Tendask` v sistemu — **preveri v nemščini**,
  ne le v slovenščini. Tam je edino mesto, kjer se ta popravek vidi.

### 4.2 · Ostalo iz testnega načrta

- Offline stanja iz P8 · »Pretekli predlogi« · stikali obvestil
- `band_max_active` (rabiš **≥4 hkratne** predloge, da se kapica pokaže)
- Polna matrika sl/en/de × 1,0/1,3 po vseh M11 zaslonih — **`N23` je strukturna slepa pega:**
  `layout_matrix_test.dart` riše Domov z `weather: null`, zato realnih vremenskih nizov nikoli ne
  izmeri. Na napravi je to treba pogledati z očmi.

### 4.3 · Pogoji prižiga (kontrolni seznam, ne paket)

| Kaj | Za kaj |
|---|---|
| **R4** — spodnja vrstica pri petih zavihkih se lomi (320 **in** 360 dp, ×1,3) | Okolica |
| **N23** — vremenska kartica na Domov razpade pri de / 320 dp / ×1,3 | Okolica |
| `kDevPlusStub = false` | Okolica |
| **N26 ostanek** — `Auspflanzen` se lomi sredi besede na `suggestions/history` | predlogi |
| sonda `supabase/probe/m11_shape.sql` + diff proti stagingu, `agg_context_invariants.sql` (teče v `rollback`, varna tudi na prod) | pred `db push` na prod |

> **N12 ni na tem seznamu**, ker je zaprt (§1b). Ena past ostane zapisana: `push_rejection_rate.sql`
> pred prižigom vrne same ničle — to **ni** okvara sonde, ampak odsotnost pushov.

### 4.4 · Kdaj je paket 6 končan

Ne »ko sem vse pogledal«, ampak:

- vsaka postavka iz 4.1 ima **posnetek** v `tmp/shots/` z govorečim imenom (ne opis po spominu);
- vsako **odstopanje** je vrstica v `19-najdbe-med-izvedbo.md`, vpisana ob odkritju, s kupom
  (A = pred prižigom / B = po / C = sprejeto);
- tabela 4.3 ima pri vsaki vrstici bodisi ✅ bodisi zapisan razlog, zakaj ostaja odprta;
- `flutter test` + `deno test supabase/functions/` + `flutter analyze` zeleni **po** morebitnih
  popravkih z naprave.

**Vrstni red, ki prihrani ponovne zagone:** najprej jezik + gostota (`wm density 540`, Deutsch,
`font_scale 1.3`) in z njo vse postavitvene stvari naenkrat (4.2 + R4 + N23 + kanali), šele nato
nazaj na privzeto in vsebinske poti iz 4.1. Menjava jezika na napravi je dražja od menjave zaslona.

## 5 · Kar ostane po tem

**P11 ostanki** (kozmetika, nič ne blokira, zapisani v `17-plan-popravkov.md §P11`):
razrez `community_repository.dart` in `suggestion_card.dart` · privatizacija `seasonDensity` /
`bucketPopulation` / `suggestionPayload` (vsem trem je test edini zunanji klicalec — glej N31,
isti razmislek) · dvojno dekodiranje `messageParams` · magične vrednosti (`rules.ts`,
`rules_community.ts`, `pipeline.ts`, `housekeep.ts`; Dart 400 ms, `fontSize: 22`, emoji fallbacki) ·
`kSupplyTaskTypes` proti `task_type.consumes_supplies`.

**Odprte najdbe, ki niso dolg:** N3 (detajl Okolice brez vrstice svežine) · N11 (klimatski normali
brez testa na realnih lokacijah — blokira vprašanje #5) · strežniški backfill cone (po N14 **ni
več nujen**, odločitev ločeno). **Odprtih najdb, ki bi jih bilo pametno rešiti pred prižigom, ni
več** — N12 je bila zadnja.

## 6 · Kako testirati na napravi

```bash
# 1) pragovi / velikost soseske
wsl -e bash -lc "cat .../supabase/seed/staging_test_data.sql | docker exec -i supabase-db psql -v ON_ERROR_STOP=1 -U postgres -d postgres"

# 2) po spremembi podatkov zadošča poteg v aplikaciji (N19 popravljen v 9fb8d69).
#    pm clear rabiš le za onboarding od začetka.
adb shell pm clear app.tendask && adb shell monkey -p app.tendask -c android.intent.category.LAUNCHER 1

# 3) prijava (koda iz Mailpita)
powershell -ExecutionPolicy Bypass -File tool\adb_run.ps1 -Steps tmp\scenarios\otp_request.txt
powershell -ExecutionPolicy Bypass -File tool\adb_run.ps1 -Steps tmp\scenarios\prag_obe_kohorti.txt -Vars OTP=123456,TAG=15_test

# 4) migracije na staging + preverba invariant
wsl -e bash -lc "tendask migrate"
wsl -e bash -lc "cat .../supabase/probe/agg_context_invariants.sql | docker exec -i supabase-db psql -v ON_ERROR_STOP=1 -U postgres -d postgres"

# 5) poljubna sonda po isti poti (npr. N12 / #9)
wsl -e bash -lc "cat /mnt/c/Users/Uporabnik/StudioProjects/tendask/supabase/probe/push_rejection_rate.sql | docker exec -i supabase-db psql -v ON_ERROR_STOP=1 -U postgres -d postgres"
```

Runner: `-Steps <pot>`, `-Vars A=1,B=2` (**z vejico**), korak `shot <ime>` shrani `tmp/shots/<ime>.png`.
Scenariji v `tmp/scenarios/` (gitignore).

### Pasti, ki so stale časa

- **Vnos OTP se pripne** k stari kodi — pred vnosom pobriši polje.
- **Poteg za osvežitev z `y=700` odpre obvestilno vrstico** — začni pri `y=900`.
- **Ročni GPS takoj po dodelitvi dovoljenja tiho ne shrani** — drugi pritisk deluje.
- **Račun `gorazd@spletnakoda.si` je `provider=email`** (OTP dela); `exogenus@gmail.com` je Google.
- **320 dp** = `adb shell wm density 540`, **360 dp** = `480`; nazaj `wm density reset`.
- **`deno fmt` razsuje generirani `catalog_fixture.ts`** — ne poganjaj ga čez `testdata/`.
- **`dart format` na cel `test/`** prelije ~75 datotek, ki jih nisi spreminjal. Formatiraj **samo
  datoteke, ki si jih uredil**, in **potem preveri `flutter analyze`**: razlomljen enovrstični `if`
  sproži `curly_braces_in_flow_control_structures`.
- **Heredoc za commit sporočilo:** v Bash orodju je `-m @'...'@` **PowerShell** sintaksa in ti
  pristane `@` kot naslov commita. Uporabi `git commit -F - <<'MSG'`.

## 7 · Delovni dogovor

En paket = en commit · **pred commitom vprašaj** · po vsakem paketu cel `flutter test` +
`deno test supabase/functions/` + `flutter analyze` · vsako najdbo vpiši v
`19-najdbe-med-izvedbo.md` **takoj ob odkritju**, ne v povzetek · postavko odkljukaj šele, ko obstaja
**artefakt**, ki to dokazuje (test, ki pade brez popravka; sonda; posnetek z naprave) ·
opažanja na napravi opisuj po **ADB screencapu**, ne po spominu.

Za i18n: po spremembi ključev **`dart run slang`** (ločen CLI, `build_runner` ga NE ujame), po
spremembi `suggestions.*.title` ali `push.fallback_*` še `dart run tool/gen_push_i18n.dart`.
Po spremembi drift sheme ali anotacij `dart run build_runner build`.

## 8 · Sklici

`19-najdbe-med-izvedbo.md` (**beri prvi**) · `17-plan-popravkov.md` §P11 (stanje) in §P12 (nalog) ·
`03-pravila-r1-r7.md` · `10-odprta-vprasanja.md` · `docs/ui-katalog.md` · `docs/prelomi-besed.md` ·
`docs/screen-map.md` · `docs/deploy-runbook.md` · `docs/cookbook.md` · `CLAUDE.md`
