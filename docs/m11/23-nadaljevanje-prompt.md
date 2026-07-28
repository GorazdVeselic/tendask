# M11 — predaja seje (Paket 3 dokončan, **nekomitan**)

> **Datum:** 2026-07-28 · veja `feat/m11-smart-engine` · **nič pushano, produkcija nedotaknjena**
> **Vstopna točka za novo sejo.** `18-`, `20-`, `21-` in `22-nadaljevanje-prompt.md` so zastareli.
> Beri tega, nato `19-najdbe-med-izvedbo.md` (pregled na vrhu) in `17-plan-popravkov.md` §3.

---

## 0 · Prva stvar, ki jo narediš

**Paket 3 leži nekomitan v delovnem drevesu.** Prejšnja seja je vprašala za commit in dobila
namesto odgovora zahtevo za to predajo. Torej: `git status`, preglej diff, in commitaj —
**preden** se lotiš česarkoli novega.

Predlagano sporočilo (kratko, po dogovoru):

```
fix(m11): besedilo, ki laže — pet obljub, tri stanja, dve piki

N13, N17, N20, N21, O4, O6 + screen-map. Layout matrika je pas
merila z neobstoječim ključem (N26).
```

Stanje ob predaji: **1323 Flutter + 170 Deno zelenih**, `flutter analyze` čist.
34 datotek, +681/−276. Migracije nedotaknjene (nobene nove).

## 1 · Kaj je v tem nekomitanem paketu

| Najdba | Popravek | Artefakt, ki dokazuje |
|---|---|---|
| **N13** | Štiri mesta dobijo `*_live` dvojnika, izbranega po flagu (uvod + lokacija po `kCommunityEnabled`, obe stikali obvestil po `kSuggestionsEnabled`). Značka `soon_badge` se ob prižgani Okolici ne izriše. | `test/i18n/launch_wording_test.dart` |
| **N17** | `communityStandings` vrne `(rows, gap)` z `enum StandingsGap`; zaslon izbere niz po vzroku. | 3 provider testi + 2 widget testa |
| **N20 (1)** | `peak_weeks` izgubi končno piko v vseh treh jezikih. | `community_timing_card_test.dart` (3 jeziki) |
| **N20 (2)** | `fillTemplate` zna izbirno poved `[...]`, ki izpade cela; 5 frost teles × 3 jeziki. | 4 enotski testi + i18n test čez seed |
| **N21** | `freq_single` (`$count×`), ko sta zaokroženi kvartili enaki. | `community_frequency_card_test.dart` |
| **O4** | `suggestions.weather.window_open` ven (i18n + `push_i18n.ts`); kartica dobi pripono `suggestions.dry_window` z **obema** parametroma (`dry_window` + `dry_hours`). | 2 widget testa + i18n test |
| **O6** | Anti-steering varovalo bere tudi `suggestions.community.*`; ločen test, da brezplačni pas ne izpiše deleža. | `community_i18n_test.dart` |
| **N26** (nova) | Matrika je pas hranila z **neobstoječim** `message_key`-em. | gl. §3 |

Dokumenti v istem paketu: `03 §R1` (R1 = ojačevalec, brez lastnega ključa/cooldowna/dismissa),
`00-pregled-za-laika.md §0.2`, `08 §i18n`, `12`, `screen-map.md`, `prelomi-besed.md`,
`19-najdbe-med-izvedbo.md`, status blok v `17-plan-popravkov.md §P10`.

## 2 · Odločitve, ki jih ne smeš »popraviti«

- **Datum nosi piko, predloga je nima.** `formatDm` vrne `1. 6.` (slovenska konvencija); zato je
  `peak_weeks` **brez** končne pike. `by_date_percent` ima datum sredi stavka in piko obdrži.
  Kdor vrne piko v predlogo, vrne `1. 6..` — test pade, in prav je tako.
- **Izbirna poved v `[...]`** je namenoma v `fillTemplate`, ne v petih parih novih ključev.
  Motor `frost_date` pošlje samo pri `frost_gate && lastFrostDate != null`; alternativa bi
  pomenila 15 novih nizov, spremembo `rules_agro.ts` in premik golden koledarja. Oklepaji se
  razrešijo **pred** substitucijo, zato `[` v uporabnikovem imenu rastline ne more požreti stavka
  (test to trdi).
- **`suggestions.dry_window` porabi `dry_hours`, ne samo `dry_window`.** N4 je omenjal en
  parameter, motor pošilja dva; pripona bere oba, sicer bi ostal drugi mrtev.
- **Živi nizi so varovani na katalogu, ne v widget testu.** Flaga sta `const bool.fromEnvironment`,
  zato widget test lahko izriše samo eno stran veje. To ni lenoba — je meja jezika.
- Iz prejšnjih sej velja naprej: **O7** lestvica `[1,1,2,4]` in sezonski obseg niza · **N5, N6**
  (staging) · **N10** (zabeležena odložitev) · **N24** (po zasnovi) · ostanek **N22**
  (odločitev o zasebnosti). Vse to je **sprejeto**, ne dolg.

## 3 · N26 — zakaj je pomembna dlje od te vrstice

`layout_matrix_test.dart` je pasu predlogov podajal `message_key`
`suggestions.season.window_open`. Tega ključa **ni** — poddrevo `suggestions` ima 33 otrok in
`season` ni med njimi. `suggestionMessage()` je vrnil `null`, kartica je izrisala fallback
(ime tipa opravila, prazno telo), matrika pa je bila zelena. Ista datoteka je pas oglašala kot
»the params that make the sentences their longest«.

To je **druga** najdba te oblike (prva je N23: matrika riše Domov z `weather: null`). Vzorec:
*testni fixture, ki uporablja ključ brez pokritja, ne pade — samo tiho neha meriti.*

Popravek na resničen ključ (`suggestions.vegetable.plant_out`, s `frost_date` in `dry_window`) je
**takoj** našel prelom sredi besede: de `Auspflanzen`, `suggestions/history`, 320 dp, ×1,3, 4×.
Zaslon je flag-dark, zato je zapisan kot **pogoj prižiga** v `docs/prelomi-besed.md` §3/§4
in v `kAcceptedWordBreaks`, ne kot breme.

**Odprto vprašanje, ki ga ta seja ni odprla:** ali obstaja tretji tak fixture. Poceni preverba —
za vsak `message_key`/i18n ključ, ki ga navaja katerikoli test, trdi, da obstaja. Brez tega je
zelena matrika obljuba brez kritja.

---

## 4 · Delovni nalog: Paket 4 — P10 ostanek (jezik in besedila)

P10 je **na pol** narejen. Koraki 3, 4, 5 so v paketu 3; ostanejo **1, 2, 6, 7**. Vse spodnje je
preverjeno v kodi 2026-07-28.

### P10.1 · Spolno zaznamovana slovenščina (pravilo iz `02f2c76`, kršeno takoj)

| Ključ | Danes (sl) | Kje se vidi |
|---|---|---|
| `suggestions.past_intro` | »Kaj ti je Tendask predlagal in kako si se **odzval**.« | zaslon Pretekli predlogi, uvodna vrstica |
| `settings.suggestions_history_sub` | »Kaj je bilo predlagano in kako si se **odzval**« | Nastavitve, podnapis |
| `community.standing.band` | `zgoden` / `običajen` / `pozen` | vsaka vrstica »Kje si ti« |
| `onboarding.welcome_title`, `auth.title` | »**Dobrodošel** v Tendask« | **prvi zaslon ob namestitvi** |
| `onboarding.log_body` | »**Pokosil, zalil, pognojil?**« | drugi zaslon uvoda |

Sosednji `community.detail.you_band` je **že** nevtraliziran (»Med zgodnejšimi« / »Približno ob
običajnem času« / »Med poznejšimi«) — `standing.band` naj sledi isti rešitvi (prislovi
`zgodaj`/`običajno`/`pozno` ali ista oblika kot `you_band`). Prva dva zaslona sta pred-obstoječa,
a sta **prvo, kar uporabnik prebere**, zato sodita sem.

**DoD:** test, ki za ta seznam ključev zavrne moško obliko (npr. `odzval`, `Dobrodošel`,
`Pokosil`), tako da naslednji nov niz pade takoj — po vzoru `launch_wording_test.dart`.

### P10.2 · Push telesa: v i18n in v pravi register

`tool/gen_push_i18n.dart:60–70` ima **trdo zapisane** fallback nize v **vikanju**:
`sl: 'Vaš vrt čaka na vas'` / `'Tapnite za predlog dneva'`, `de: 'Ihr Garten braucht
Aufmerksamkeit'` / `'Tippen für den heutigen Vorschlag'`. Aplikacija je povsod tikanje/»du«.

Hujše od registra: **`pushBody(lang)` sploh ne sprejme `messageKey`** — vedno vrne fallback.
Torej ima **vsak** push generično telo, in ker nizi niso v `lib/i18n/*.i18n.json`, jih ne ujame
noben i18n test. (Naslovi so v redu: `pushTitle()` bere iz kataloga, `push_text.ts` napolni
`{task}`.)

Ob tem: generator pobira **vsak** leaf `title` pod `suggestions`, zato sta v
`push_i18n.ts` tudi `suggestions.done_sheet` (»Kdaj je bilo opravljeno?«) in
`suggestions.remove` (»Odstranim?«) — UI ključa, ki nikoli nista `message_key`. 66 vnosov na
jezik, dva odveč. Zoži zajem (npr. samo poddrevesa, ki jih pozna `PlantTaskRulesSeed` +
generični ključi), sicer bo vsak nov UI dialog s `title` pristal v strežniškem paketu.

**Pozor pri telesih:** telesa vsebujejo `{markers}`, ki jih **klient** polni iz `message_params`.
Strežnik ima `push_text.ts` samo za `{task}`. Če telo v push nese markerje, ki jih strežnik ne
zna napolniti, bo na zaklenjenem zaslonu pisalo dobesedno `{subject}` — natanko napaka, ki je
bila že enkrat popravljena za naslove (`12-dokoncanje-m11.md`, M11.12). Odloči **zavestno**:
ali strežnik napolni več markerjev, ali gredo v push samo telesa brez njih, ali ostane
generično telo — a takrat v tikanju in **v i18n**, ne trdo zapisano v generatorju.

**DoD:** parity test za `push_i18n.ts` še vedno zelen · nov test, da noben niz v `push_i18n.ts`
ne vsebuje nezapolnjenega `{marker}` po `push_text.ts` obdelavi · fallbacki v `lib/i18n/`.

### P10.6 · Odprti vprašanji, ki sta sprožilca dosegli

- **#13** (`agg_context` write-once samo app-level) je **dejansko zaprt** z migracijo
  `0020_task_agg_context_write_once.sql` (N9), a `10-odprta-vprasanja.md` tega ne ve — razdelek
  se še konča s triažo »triggerja ni«. Dopiši razrešitev s hashem in sondo
  (`supabase/probe/agg_context_invariants.sql`), sicer bo nekdo trigger pisal drugič.
- **#14** (`engine_endpoint`) je **že razrešen** (postopkovno, `e658a2c`) — samo preveri, da ni
  kje drugje naveden kot odprt.

### P10.7 · Manjši doc-dolg

`03 §Akcije` in `08 §8.1` še opisujeta stari »Načrtuj« (koda odpre predizpolnjen obrazec,
`b9e5b3f`) · `community-flow_v3.html` še oglašuje »Preizkusi 14 dni« (po FR-20 prepovedano; koda
je pravilna) · `ui-katalog.md` ne našteva `LoadErrorHint`, `DayHeader`, `TopToast`,
`DashboardHint` · `skupnost-agregacija.md §12.1` še omenja izbirnik obsega, ki je z odločitvijo A
odpadel.

**DoD paketa:** i18n testi zeleni v treh jezikih · vsak popravek ima test, ki bi napako ujel ·
`flutter analyze` + cel `flutter test` + `deno test supabase/functions/`.

---

## 5 · Kar sledi za tem

- **Paket 5 · P11 higiena.** **O5** — `plant_task_rule` s klienta ven (danes ga poznajo
  `app_database.dart`, `catalog_tables.dart`, `seed_service.dart`, `catalog_sync_service.dart`,
  `remote_mappers.dart`, `plant_task_rules_seed.dart`). **Pozor:** `tool/gen_rules_sql.dart` in
  `tool/gen_engine_fixture.dart` bereta `lib/data/seed/plant_task_rules_seed.dart`, iz njega sta
  generirana `supabase/seed/plant_task_rules.sql` in `testdata/catalog_fixture.ts`, oba s parity
  testom. O5 pomeni »ven iz aplikacije« (APK, drift, sync), **ne** »zbriši vir generatorja« —
  predlog: seed **preseli** iz `lib/` v build-time lokacijo. Poleg tega: **N2**
  (`communityWeekly` brez testa) · ustavi pull `suggestion_log` (`sync_pull_service.dart:132–141`,
  nima bralca) · `activeSuggestionsCountProvider` + `watchActiveCount()` (badge, ki ne obstaja) ·
  `suggestions.toast.planned` (toast se ne pokaže) · podvojeni widgeti (pill ×3, `_Rows` ×2,
  tease ×2) · `dispose()` (`FcmHandler._taps`, `_archiveDio`, `profileRowReadyForWrite`) ·
  slovenska imena Android kanalov (**vidna uporabniku** v sistemskih nastavitvah).
- **Paket 6 · naprava (P12 + ostanek testnega načrta):** offline stanja iz P8 · polna matrika
  sl/en/de × 1,0/1,3 po vseh M11 zaslonih (**N23**: matrika riše Domov z `weather: null`, zato
  realnih vremenskih nizov ne vidi — strukturna slepa pega) · »Pretekli predlogi« · stikali
  obvestil · `band_max_active` (rabiš ≥4 hkratne predloge) · **tri nova stanja »Kje si ti«**
  (N17) in **pripona suhega okna** (O4), ki ju na napravi še nihče ni videl.
- **Pred prižigom Okolice:** spodnja vrstica pri petih zavihkih (R4) · **N23** ·
  `kDevPlusStub = false`.
- **Pred prižigom predlogov:** `Auspflanzen` na `suggestions/history` (N26).
- **Pred `db push` na prod:** sonda `supabase/probe/m11_shape.sql` + diff proti stagingu, in
  `supabase/probe/agg_context_invariants.sql` (teče v `rollback`, varna tudi na prod).
- **Odprto, ni dolg:** strežniški backfill cone. Po popravku N14 **ni več nujen** — prvi zagon
  popravljenega builda cono napolni sam.

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

Runner: `-Steps <pot>`, `-Vars A=1,B=2` (**z vejico**), korak `shot <ime>` shrani
`tmp/shots/<ime>.png`. Scenariji v `tmp/scenarios/` (gitignore).

### Pasti, ki so stale časa

- **Vnos OTP se pripne** k stari kodi — pred vnosom pobriši polje.
- **Poteg za osvežitev z `y=700` odpre obvestilno vrstico** — začni pri `y=900`.
- **Ročni GPS takoj po dodelitvi dovoljenja tiho ne shrani** — drugi pritisk deluje.
- **Račun `gorazd@spletnakoda.si` je `provider=email`** (OTP dela); `exogenus@gmail.com` je
  Google — OTP prijava nanj bi tvegala drugo identiteto.
- **320 dp** = `adb shell wm density 540`, **360 dp** = `480`; nazaj `wm density reset`.
- **`deno fmt` razsuje generirani `catalog_fixture.ts`** (in prepiše EOL v datotekah, ki jih nisi
  spreminjal). CI ga ne poganja — ne poganjaj ga čez `testdata/`.
- **`dart format` na cel `test/`** prelije ~75 datotek, ki jih nisi spreminjal (drift verzije
  formatterja). Formatiraj **samo datoteke, ki si jih uredil**. (Stalo eno uro v tej seji.)
- **Po `dart format`** preveri `flutter analyze`: razlomljen enovrstični `if` sproži
  `curly_braces_in_flow_control_structures`.

## 7 · Delovni dogovor

En paket = en commit · **pred commitom vprašaj** · po vsakem paketu cel `flutter test` +
`deno test supabase/functions/` + `flutter analyze` · vsako najdbo vpiši v
`19-najdbe-med-izvedbo.md` **takoj ob odkritju**, ne v povzetek · postavko odkljukaj šele, ko
obstaja **artefakt**, ki to dokazuje (test, ki pade brez popravka; sonda; posnetek z naprave).

Za i18n: po spremembi ključev **`dart run slang`** (ločen CLI, `build_runner` ga NE ujame), po
spremembi `suggestions.*.title` še `dart run tool/gen_push_i18n.dart`.

## 8 · Sklici

`19-najdbe-med-izvedbo.md` (**beri prvi**) · `17-plan-popravkov.md` §3 (P10 status blok, P11) ·
`03-pravila-r1-r7.md` (§R1 = ojačevalec, §R3 nosi O7) · `docs/prelomi-besed.md` ·
`docs/screen-map.md` · `docs/deploy-runbook.md` · `docs/cookbook.md` · `CLAUDE.md`
