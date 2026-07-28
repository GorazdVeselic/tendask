# M11 — predaja seje (Paket 4 zaključen, **P10 zaprt**)

> **Datum:** 2026-07-28 · veja `feat/m11-smart-engine` · **nič pushano, produkcija nedotaknjena**
> **Vstopna točka za novo sejo.** `18-`, `20-`, `21-`, `22-` in `23-nadaljevanje-prompt.md` so
> zastareli. Beri tega, nato `19-najdbe-med-izvedbo.md` (pregled na vrhu) in `17-plan-popravkov.md` §P11.

---

## 0 · Kje sva

Delovno drevo je **čisto**. Zadnja dva commita sta paketa 3 in 4:

| Hash | Kaj |
|---|---|
| `845e159` | **Paket 3** — besedilo, ki laže: N13, N17, N20, N21, O4, O6, screen-map, N26 |
| `13a8755` | **Paket 4** — P10 ostanek: spol (N28), šesta obljuba (N27), push telesa, #13, doc-dolg |

Stanje: **1329 Flutter + 172 Deno zelenih**, `flutter analyze` čist, parity testi zeleni.
Migracije nedotaknjene (0020/0021 na stagingu, produkcija brez njih).

**P10 je zaprt v celoti.** Ostaneta **Paket 5 (P11 higiena)** in **Paket 6 (naprava)**.

## 1 · Kaj je paket 4 naredil

| Korak | Popravek | Artefakt |
|---|---|---|
| **P10.1** | Devet spolno zaznamovanih nizov nevtraliziranih (ne sedem — gl. N28). `standing.band` → prislovi `zgodaj/običajno/pozno` po vzoru `you_band`. Naslova: »Lepo, da si tu« (uvod) in »Tendask — lepo, da si tu« (prijava, kjer je to edino mesto z imenom izdelka). | `gendered_wording_test.dart` — 9 zadetkov pred, 0 po |
| **N27** | `notif_priming.benefit_nearby` dobi `_live` dvojnika po `kSuggestionsEnabled`; vzorec varovala razširjen na `\(v2\b`. | `launch_wording_test.dart` (nov par) |
| **N26 sled** | Vsak i18n ključ iz kateregakoli testa mora obstajati v vseh treh katalogih. | `test_fixture_keys_test.dart` |
| **P10.2** | Odločitev + zožen zajem generatorja (66 → 64), fallbacka iz trdo zapisanih v `lib/i18n/push.*`, iz vikanja v tikanje. | `push_text_test.ts` (+2), parity test |
| **P10.6** | #13 zaprt v `10-odprta-vprasanja.md` (0020 + sonda), prestavljen iz kupa A. #14 nikjer ni naveden kot odprt. | dokument |
| **P10.7** | »Načrtuj« v `03 §Akcije` in `08 §8.1` · wireframe C brez preizkusa · `ui-katalog.md` +4 komponente · `§12.1` brez izbirnika obsega | dokumenti |

## 2 · Odločitve, ki jih ne smeš »popraviti«

- **Push nosi naslov, ne telesa** (P10.2, `03 §Sporočila`). Od treh možnosti je izbrana tretja:
  generično telo, a v tikanju in v i18n. Razlog ni lenoba — telo nosi `{subject}`, `{frost_date}`,
  `{window_end_date}`, torej katalozne oznake, **uporabnikovo lastno ime rastline** in obliko datuma
  v njegovem jeziku. Strežnik bi moral podvojiti vse troje, sicer se ponovi M11.12 (`{subject}` na
  zaklenjenem zaslonu), poleg tega bi imena rastlin potovala skozi FCM za vrstico, ki jo bralec ob
  dotiku vidi v celoti. **Kdor to obrne, mora najprej rešiti formatiranje datumov in oznak na
  strežniku** — ne obratno.
- **Zajem generatorja je seznam, ne vzorec.** `emittedMessageKeys` = `PlantTaskRulesSeed` + trije
  generični ključi. Vzorec »vsak leaf `title` pod `suggestions`« je pobiral UI dialoge
  (`done_sheet`, `remove`) in bi pobral vsakega naslednjega.
- **Test markerjev bere surov katalog, ne napolnjenega niza.** `pushTitleFor()` požre **vsak**
  marker, zato test nad napolnjenim nizom ne dokaže ničesar — »{subject} je na vrsti« bi tiho odšel
  kot » je na vrsti«. Invarianta je: v push naslovu je `{task}` **edini** dovoljen marker.
- **`gendered_wording_test.dart` ima dva dela z različnim namenom.** Vzorec (druga oseba + `-l`
  deležnik) lovi prihodnje nize; brazgotinski seznam (`dobrodošel`, `pokosil`, `zgoden`, …) lovi
  eliptične primere brez osebnega glagola (»Pokosil, zalil, pognojil?«), ki jih vzorec **ne more**
  videti. Ne združuj ju in ne briši seznama, ker je »videti kot podvajanje«.
- **Naslova sta dva različna niza** (`onboarding.welcome_title` ≠ `auth.title`) namenoma: prijavni
  zaslon ima nad naslovom samo ikono lista, zato je to edino mesto, kjer se pokaže ime izdelka.
- Iz prejšnjih sej velja naprej: **datum nosi piko, predloga je nima** · **izbirna poved `[...]`**
  v `fillTemplate` · `suggestions.dry_window` porabi **oba** parametra · živi nizi so varovani na
  katalogu, ne v widget testu · **O7** lestvica `[1,1,2,4]` · **N5, N6** (staging) · **N10**
  (zabeležena odložitev) · **N24** (po zasnovi) · ostanek **N22** (odločitev o zasebnosti).
  Vse to je **sprejeto**, ne dolg.

## 3 · Dve najdbi iste oblike, ki naj vplivata na način dela

**N27 je N26 en nivo višje.** N26: testni fixture je uporabljal ključ brez pokritja in je tiho nehal
meriti. N27: **varovalo** je iskalo dobesedni `(V2)`, niz pa piše `(V2, neobvezno)` — pet mest je
zaprlo, šesto pa je gledalo naravnost in ga ni videlo. Vzorec:

> *Preveč natančen vzorec ne pade — samo tiho neha loviti.*

Praktična posledica za paket 5: ko pišeš varovalo (grep, regex, seznam ključev), **najprej ga poženi
proti verziji izpred popravka** in preveri, da tam res pade. Obakrat je bilo to razlika med
varovalom in okrasjem. Isto velja za `N28`: seznam sedmih nizov je nastal z branjem zaslonov, pregled
**celotnega kataloga** jih je našel devet.

**Kar ostaja nepreverjeno:** ali je še kje varovalo, ki je preveč specifično. Kandidati so
`kAcceptedWordBreaks` (seznam sprejetih prelomov — če se niz spremeni, vnos ostane in tiho dovoli
nov prelom) in anti-steering varovalo (bere `community.*` + `suggestions.community.*`; nov niz s
socialnim dokazom pod tretjim poddrevesom bi šel mimo).

---

## 4 · Delovni nalog: Paket 5 — P11 higiena *(blokira O5)*

Cel seznam je v `17-plan-popravkov.md §P11`. Spodaj je vrstni red, ki ima smisel, in pasti.

### 5.1 · O5 — `plant_task_rule` s klienta ven (glavna postavka)

Danes ga poznajo `app_database.dart`, `catalog_tables.dart`, `seed_service.dart`,
`catalog_sync_service.dart`, `remote_mappers.dart`, `plant_task_rules_seed.dart` — 1127 vrstic seeda,
catalog-sync pot in migracijski korak. Na napravi **nima bralca**: motor bere pravila iz Supabase.

**Past, ki jo moraš videti pred prvim izbrisom:** iz `lib/data/seed/plant_task_rules_seed.dart`
generirajo **trije** artefakti — `supabase/seed/plant_task_rules.sql` (`tool/gen_rules_sql.dart`),
`testdata/catalog_fixture.ts` (`tool/gen_engine_fixture.dart`) in **odslej tudi**
`supabase/functions/_shared/push_i18n.ts` (`tool/gen_push_i18n.dart`, od P10.2 bere `messageKey`).
Vsi trije imajo parity test. O5 pomeni **»ven iz aplikacije« (APK, drift, sync), ne »zbriši vir
generatorja«** — predlog: seed **preseli** v build-time lokacijo in popravi tri importe, ne enega.

### 5.2 · Mrtva koda, ki nekaj stane

Po vrsti od najdražje: pull `suggestion_log` ob **vsakem** syncu brez bralca
(`sync_pull_service.dart:132–141`) · `community_cache` se nikoli ne počisti (neomejena rast) ·
`activeSuggestionsCountProvider` + `watchActiveCount()` (badge, ki ne obstaja) ·
`suggestions.toast.planned` (toast se ne pokaže — ali ga pokaži, ali niz odstrani) · ostalo v tabeli
§P11. **N2** (`communityWeekly` brez testa) sodi sem kot edina postavka, ki doda pokritost, ne odvzame.

### 5.3 · Kršitve `CLAUDE.md`, ki jih uporabnik vidi

- **Slovenska imena Android kanalov** (»Opomniki opravil«, »Pametni predlogi«, »Nežna povabila k
  dnevniku«) — **vidna v sistemskih nastavitvah telefona**, mimo `t.*`. To ni higiena kode, to je
  besedilo v napačnem jeziku pri nemškem uporabniku. **Pozor:** ime kanala se ob spremembi
  **ne posodobi** za obstoječe namestitve — potreben je nov `channelId`, sicer sprememba nima učinka.
- Podvojeni widgeti (pill ×3, `_Rows` ×2, tease ×2) → `core/widgets/`, vpiši v `ui-katalog.md`
  (ta je zdaj svež, gl. P10.7).
- `dispose()`: `FcmHandler._taps`, `_archiveDio`, `profileRowReadyForWrite` (`.timeout` na `Future`
  **ne** prekliče `firstWhere` naročnine).
- Razhajanja Dart ↔ Deno: retry (4 vs 3, **nobena** stran ne ustreza CLAUDE.md »maks 3, 1s→3s→9s«) ·
  Open-Meteo timeout.

**DoD paketa:** cel `flutter test` + `deno test supabase/functions/` + `flutter analyze` · vsak
odstranjen kos ima grep, ki dokazuje 0 bralcev · vsako varovalo pade na verziji izpred popravka.

---

## 5 · Kar sledi za tem

- **Paket 6 · naprava (P12 + ostanek testnega načrta):** offline stanja iz P8 · polna matrika
  sl/en/de × 1,0/1,3 po vseh M11 zaslonih (**N23**: matrika riše Domov z `weather: null`, zato
  realnih vremenskih nizov ne vidi — strukturna slepa pega) · »Pretekli predlogi« · stikali obvestil ·
  `band_max_active` (rabiš ≥4 hkratne predloge) · **tri nova stanja »Kje si ti«** (N17), **pripona
  suhega okna** (O4) in **novi naslovi/prislovi iz P10.1**, ki jih na napravi še nihče ni videl.
- **Pred prižigom Okolice:** spodnja vrstica pri petih zavihkih (R4) · **N23** · `kDevPlusStub = false`.
- **Pred prižigom predlogov:** `Auspflanzen` na `suggestions/history` (N26).
- **Pred `db push` na prod:** sonda `supabase/probe/m11_shape.sql` + diff proti stagingu, in
  `supabase/probe/agg_context_invariants.sql` (teče v `rollback`, varna tudi na prod).
- **Odprto, ni dolg:** strežniški backfill cone — po popravku N14 **ni več nujen** · **N12**
  (odpovedan push se ne šteje, odločitveno drevo #9 visi na tej številki).

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
  sproži `curly_braces_in_flow_control_structures` (zgodilo se je tudi v tej seji, v
  `tool/gen_push_i18n.dart`).

## 7 · Delovni dogovor

En paket = en commit · **pred commitom vprašaj** · po vsakem paketu cel `flutter test` +
`deno test supabase/functions/` + `flutter analyze` · vsako najdbo vpiši v
`19-najdbe-med-izvedbo.md` **takoj ob odkritju**, ne v povzetek · postavko odkljukaj šele, ko obstaja
**artefakt**, ki to dokazuje (test, ki pade brez popravka; sonda; posnetek z naprave).

Za i18n: po spremembi ključev **`dart run slang`** (ločen CLI, `build_runner` ga NE ujame), po
spremembi `suggestions.*.title` ali `push.fallback_*` še `dart run tool/gen_push_i18n.dart`.

## 8 · Sklici

`19-najdbe-med-izvedbo.md` (**beri prvi**) · `17-plan-popravkov.md` §P11 · `03-pravila-r1-r7.md`
(§Sporočila = push pogodba, §R1 = ojačevalec, §R3 nosi O7) · `10-odprta-vprasanja.md` ·
`docs/ui-katalog.md` · `docs/prelomi-besed.md` · `docs/screen-map.md` · `docs/deploy-runbook.md` ·
`docs/cookbook.md` · `CLAUDE.md`
