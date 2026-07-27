# Nadaljevanje M11 — prompt za sejo 3 (po seji 2026-07-25)

Prilepi spodnji blok v novo sejo.

---

Nadaljevanje — dokončaj M11 (pot A) → merge v main (dark). Seja 3 (nadaljevanje 2026-07-25).

Branch `feat/m11-smart-engine`. Pogovor SL, koda EN. Pred vsakim commitom VPRAŠAJ.
Glavni plan seje = `docs/m11/12-dokoncanje-m11.md` (zdaj 16 korakov: K1–K14 + K7b + K8b).

## PRVI KORAK V SEJI (po vrsti, ne preskoči)

1. **Preberi:** `docs/m11/12-dokoncanje-m11.md` (plan), `docs/m11/09-koraki.md` (DoD M11.17–21),
   `docs/m11/08-flutter-arhitektura.md §8.3`, `docs/skupnost-agregacija.md §5.2–5.4, §7.1, §7.4, §7.6, §12`,
   `docs/screen-map.md §1.1, §1.5, §2.2`, `docs/ui-katalog.md`, `CLAUDE.md`,
   memory `tendask-work-status` + `tendask-m11-reconcile-into-main` + `tendask-monetization-planned`.
2. **Naredi EN DOBER CODE REVIEW vsega, kar je nastalo v seji 2** (spisek datotek spodaj): iščeš
   anomalije, nepokrite CTA-je (primerjaj s `screen-map.md` in wireframom `docs/wireframes/community-flow_v3.html`),
   podvojene widgete, mrtvo kodo, prop-drilling, YAGNI, `!` brez opravičila, napačno rabo providerjev,
   neskladja med drift/Supabase shemo in kodo. Merilo: **ali bi tako kodo napisal človeški senior Flutter
   razvijalec**. Poročaj najdbe strnjeno, popravi tisto, kar je nesporno narobe; kjer je odločitev
   oblikovalska, vprašaj.
3. **Šele če je pregled čist:** `flutter analyze` + cel `flutter test` (zadnje stanje: **987 zelenih**),
   nato commit (predlog razdelitve spodaj — VPRAŠAJ pred vsakim).
4. **Nato pripravi nadaljevanje:** korak 8 (detajl opravila) — kaj rabi, česa še ni (spisek »ODPRTE
   VRZELI« spodaj), in predlagaj vrstni red.

## KAJ JE NAREJENO (seja 2)

**Commitano + pushano** na `origin/feat/m11-smart-engine`:
- `516843e` K5 — 5. zavihek ⬡ + `/community` ruta (oboje za `kSuggestionsEnabled`), `community_landing_screen`
  (segment `[Ta teden | Kje si ti]`, feed, cold-start), `TeaseOverlay` (blur + »Na voljo v Tendask +« +
  inerten »Vnesi kodo«), `hasPlusProvider` (stub `kDevPlusStub`), skupni `core/widgets/load_error_hint.dart`,
  7 widget testov + 2 vnosa v layout matriko.
- `fbf8738` K6 — i18n `community.*` + `nav.community` v sl/de (en je prišel s K5), `dart run slang`,
  `test/i18n/community_i18n_test.dart` (popolnost prevodov + anti-steering: brez cene/URL/CTA).

**NEcommitano (delovni imenik)** — to je predmet pregleda v točki 2:
- **K7** — čiste funkcije `lib/features/community/data/community_stats.dart` (`isoWeek` zrcali
  Postgres `extract(week…)`, `buildSeasonCurve` iz zaključenih preteklih sezon + cenzurirani leto-1 način
  §7.6, `seasonCdfForWeek`, `timingBand` tercili, `parseFrequency`), repo metode `seasonCurve` / `frequency` /
  `myFirstThisSeason`, providerji + `SeasonCurve.censored`, `kIsoWeeksPerYear`.
- **Popravki 1. pregleda** — poenotena konvencija za rastlino, tolerantni parser feeda/populacije,
  anti-steering test z mejo besede (prej bi `eur`/`abo`/`$` lovil »eurer«/»about«/slangov `$n`),
  odstranjen `!` v feed vrstici.
- **Odločitev A (obseg = oznaka, ne izbirnik)** zapisana v `screen-map.md §1.5`, `skupnost-agregacija.md §12.1`,
  `08 §8.3` in wireframe (chipi brez `▾`, člen »vsi« odpade, ker cron ne dela globalnega vedra;
  izbirnik = **odložen, ne opuščen**).
- **K8b** dodan v plan (vstopni točki: Domov »V tvoji okolici ⬡« + kartica na detajlu opravila —
  po `§12.1` sta to glavni poti odkritja, prej nista bili v nobenem koraku).
- **K7b — primerjalne skupine (cohorts)**, največja sprememba seje:
  - `supabase/migrations/0017_agg_event_site_cohort.sql` — `agg_event` dobi vejo `plant_id = '@site'`
    (dogodki brez kataloške rastline: trata, gredica, lastne rastline). Tabele/PK/RLS/granti
    nedotaknjeni, `create or replace view` → additivno + idempotentno. **Še NI aplicirana nikjer.**
  - Klient: `cohort` (`kCommunityCohortSite` ali id rastline) v repo metodah in providerjih; iz verige
    je **izginil korak »spusti rastlino«** — skupina se nikoli ne zamenja, širi se samo geografija.
  - Feed bere celo dnevno rezino vedra (en klic, §12.4), zlite `''` vrstice preskoči, vrstica = skupina
    (naslov = opravilo, podnaslov + ikona = rastlina), kapica `kCommunityFeedMaxPerType = 2`.
  - Dokumenti: §7.4 prepisan z datirano uskladitvijo, §7.1 enota vrstice, §5.2 opomba o skupinah,
    `04 §4.5` SQL, `08 §8.3`, screen-map, wireframe, plan (korak 7b), runbook (0017 čaka).

**Zakaj 7b:** stara §7.4 je kot skrajni fallback dovolila zlivanje rastlin — *obrez jablane* in
*obrez maline* sta različna dogodka z različnim koledarjem, zlita krivulja je večvrhna in percentil
meri napačno vprašanje. Ugovor je prišel od uporabnika pri pregledu feeda.

## PREDLAGANA RAZDELITEV COMMITOV (potrdi/spremeni)

1. `feat(community): časovni percentil in frekvenca s fallback hierarhijo` — K7
2. `fix(community): pregled — tolerantni parser feeda in trdnejše anti-steering varovalo`
3. `docs(m11): korak 8b — vstopni točki v Okolico`
4. `docs(community): obseg je oznaka, ne izbirnik (odločitev A)`
5. `feat(community): primerjalne skupine — @site kohorta in konec zlivanja rastlin` (+ migracija 0017)

`docs/m11/13-nadaljevanje-prompt.md` in `14-nadaljevanje-prompt.md` (ta datoteka) se **ne commitata**.

## ODPRTE VRZELI (iz podatkovnega pregleda — vhod za K8/K8b/K10)

- **»🔥 Ta teden« vrstica na detajlu:** podatek je **že v dnevnem cachu** (feed prenese celo rezino
  vedra), a ni metode, ki bi ga vrnila za en tip+skupino. Rez na `kCommunityFeedLimit` je v repo — po
  potrebi ga prestavi v presentation. Obseg te vrstice se lahko razlikuje od obsega krivulje → svoja oznaka.
- **»me« stolpec v frekvenčnem histogramu:** manjka `myCountThisSeason(taskTypeId, cohort)` (imamo le
  prvi datum). Wireframe B3 ima `.bar.me` v obeh grafih.
- **Seznam »Kje si ti«:** rabi (1) moje tipe opravil te sezone iz drift (ni metode) in (2) N krivulj.
  Trenutni per-tip fetch pomeni do `N × 4` zahtev na prvo dnevno odprtje; §12.4 predvideva eno rezino na
  vedro. Rešitev: bulk branje z `in`-filtrom (rabi razširitev `RemoteAggFetch`, ki zna samo `eq`) +
  N cache vrstic iz enega requesta.
- **R6 tease (K10):** ključ `suggestions.community.most_started` ima v vseh treh jezikih `{percent}` in
  `test/i18n/suggestions_i18n_test.dart` to pogodbo uveljavlja. Strežnik v M11 entitlementa ne pozna
  (pride s FR-20) → rabi različico **brez številke** za vse push-e; številka ostane v aplikaciji na
  Plus-gated zaslonu.
- **Kartica na Domov (K8b):** pravilo »najrelevantnejši namig« ni določeno. Predlog: prvi feed element,
  ki obstaja v mojem vrtu, sicer prvi element.
- **`community_cache` nima evikcije** (mrtve vrstice po prestavitvi vrta) — ena `deleteWhere(fetchedAt < now − 30 dni)`.
- **`myFirstThisSeasonProvider` je enkratni Future** → marker »ti« se ne osveži, če med odprtim zaslonom
  zabeležiš opravilo. K8: invalidacija ob zapisu opravila ali drift stream.
- **»Kje si ti« zavihek še ni tease-gated** (zdaj je prazen za vse) — ob polnjenju v K8 ga ovij.

## PLAN (vrstni red)

K1–K6 ✅ · **K7 ✅ (necommitano)** · **K7b ✅ (necommitano)** → **K8** (detajl opravila `community_task_screen`:
percentil krivulja + »ti« marker + frekvenca stolpci + »ta teden«, `kReliab` opisni način, explain sheet
»Kako beremo te podatke«, cel zaslon TeaseOverlay brez Plus) → **K8b** (vstopni točki Domov + detajl
opravila) → K9 (i18n detajl) → K10 (R6 v smart-engine + opt-in push, Deno testi) → K11 (M11.21 docs +
koncept sync + memory) → K12 (predpriprava merge: analyze+test zelen; če se je main premaknil, `git merge main`)
→ K13 👤 merge M11→main (dark) → K14 👤 on-device dimni test.

## STANJE KODE IN OKOLJA

- `flutter analyze` čist, cel `flutter test` **987 zelen** (od tega layout matrika 320/360/411 × sl/en/de × 1.0/1.3).
- M11 UGASNJEN: `kSuggestionsEnabled=false` ovija vse vstopne točke (Domov band, `/suggestions/history`,
  nastavitve, FCM, **5. zavihek ⬡ + `/community`**). Server-dark: `app_config.engine_enabled=false`,
  edge fn ni deployan. Drift `schemaVersion = 16`.
- `kDevPlusStub = true` → v dev je Okolica vidna kot za naročnika; `hasPlusProvider` je edini šiv, ki ga
  FR-20 zamenja s podpisanim tokenom. Tease gumb »Vnesi kodo« je **inerten** (`onPressed: null`).
- Community agregatne tabele obstajajo na PROD (M11.16/0009), **staging jih NIMA** → dev build vedno kaže
  »še premalo vrtnarjev«; to ni bug. Migracija `0017` **ni** aplicirana nikjer.
- **Pretekle zaključene sezone še ne obstajajo** (aplikacija je v produkciji od julija 2026) → percentil
  bo prvo sezono tekel v cenzuriranem načinu §7.6 (»doslej letos«); `SeasonCurve.censored` to podpira.

## OKOLJSKE PASTI

- rtk mangla `git log/status` → git VEDNO prek `rtk proxy git …`. Commit sporočilo v `tmp/commit_msg.txt` + `git commit -F`.
- Okolje NIMA `gh` CLI — PR/push prek `git push` (izpiše URL). Pre-push hook sam požene analyze+test.
- Primarni shell PowerShell (Bash tudi). Freezed 3.x = `abstract class X with _$X`. `Bucket` se zaleti s
  supabase `storage_client` → `import supabase_flutter hide Bucket`. `ErrorHint` je zaseden v Flutter
  foundation → naš widget je `LoadErrorHint`. `plantsMapProvider`/`taskTypesMapProvider` živita v
  `core/database/catalog_provider.dart` (NE v `features/plants/...`).
- slang = `dart run slang` (build_runner ga NE ujame); shema/anotacije → `dart run build_runner build --delete-conflicting-outputs`.
- On-device: `& .\deploy.bat hot` (staging). Pred prod/main buildom `adb uninstall app.tendask`.
  Screencap: `MSYS_NO_PATHCONV=1 adb shell screencap -p /sdcard/x.png` → `adb pull`. Zaslon prižgan:
  `adb shell svc power stayon true`.
- Če `flutter test` obtiči → ubij viseče `flutter_tester`/`dart` procese.
- PRODUKCIJA: nikoli nič ne briši; migracije additive-only + idempotentne. UI: NIKOLI beseda »motor« →
  »Tendask«/»predlogi«.

## ODLOČENO (velja naprej)

- Pot A: dokončaj M11 v celoti → merge M11→main (dark).
- M11.20 (paywall/`in_app_purchase`/trial) ODPADE — FR-20 (zunanja licenca, koda za odkup).
  V aplikaciji NIKOLI cena/URL/CTA k nakupu.
- **Obseg = samodejna oznaka** (odločitev A): razreši ga fallback veriga, izbirnik odložen; »vsi« ne obstaja.
- **Primerjalna skupina** (`cohort` v kodi): rastlinska ali `@site`; nikoli se ne zamenja, širi se le
  geografija; zlita `''` vrstica se nikoli ne bere. Slovensko v dokumentih = »primerjalna skupina«.
- Okolica se gradi za `kSuggestionsEnabled`; pravi Plus-gate prižge FR-20.

## PARKIRANO (ne blokira)

Slovnica `{subject}` (rodilnik) copy-prenova ~61 sporočil × sl/en/de. TENDASK-6 RenderFlex ~9 px.
FR-8 vreme na centroid. Insert-if-missing LWW race. Globalno vedro (rabi spremembo M11.16 crona).
Razrez `@site` skupine po tipu območja (`@lawn`/`@bed`) — V3.
