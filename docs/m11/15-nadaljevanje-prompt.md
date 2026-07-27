# Nadaljevanje — seja 4 (po 2026-07-25)

> Prilepi spodnji blok kot prvo sporočilo nove seje.

---

Nadaljevanje — dokončaj M11 (pot A) → merge v main (dark). Seja 4 (nadaljevanje 2026-07-25).

Branch feat/m11-smart-engine. Pogovor SL, koda EN. Pred vsakim commitom VPRAŠAJ.
Glavni plan seje = docs/m11/12-dokoncanje-m11.md (zdaj 17 korakov: K1–K14 + K7b + K8b + K8c).

PRVI KORAK V SEJI (po vrsti, ne preskoči)

1. Preberi: docs/m11/12-dokoncanje-m11.md (plan), docs/m11/09-koraki.md (DoD M11.17–21),
   docs/m11/08-flutter-arhitektura.md §8.3, docs/skupnost-agregacija.md §7.1/§7.2/§7.4/§7.6/§12,
   docs/screen-map.md §1.1, §1.5, §2.2 (+ opomba pod tabelo §2), docs/ui-katalog.md, CLAUDE.md,
   memory tendask-work-status + tendask-m11-reconcile-into-main + tendask-monetization-planned.
2. Naredi EN DOBER CODE REVIEW vsega, kar je nastalo v seji 3 (commit `941b5bd` = korak 8):
   iščeš anomalije, nepokrite CTA-je (primerjaj s screen-map.md in wireframom
   docs/wireframes/community-flow_v3.html), podvojene widgete, mrtvo kodo, prop-drilling, YAGNI,
   `!` brez opravičila, napačno rabo providerjev, neskladja med docs in kodo. Merilo: ali bi tako
   kodo napisal človeški senior Flutter razvijalec. Poročaj strnjeno, popravi nesporno narobe;
   kjer je odločitev oblikovalska, vprašaj (opiši problem, možnosti, priporočilo + zakaj druge ne).
3. Šele če je pregled čist: flutter analyze + cel flutter test (zadnje stanje: 1044 zelenih).
4. Nato K8b (vstopni točki v Okolico) — spisek »ODPRTE VRZELI« spodaj je vhod.

KAJ JE NAREJENO (seja 3) — 5 commitov, NIČ pushano

- `5058ad0` feat(community): primerjalne skupine, časovni percentil in frekvenca — K7 + K7b skupaj
  (ločitev ni bila poštena: 7b je prepisal API iz 7, preden je bil 7 kdaj commitan). Vsebuje
  migracijo `0017` (`@site` veja v `agg_event`), čiste funkcije `community_stats.dart`, repo metode
  s `cohort`, providerje s fallback verigo, kohortni del docs.
- `13aab48` fix(community): trdnejše anti-steering varovalo v i18n testu — meja besede je še vedno
  lovila »about« in nemški »eurer« (`\b` se prime tudi na začetku daljše besede).
- `ce5a764` docs(m11): korak 8b — vstopni točki v Okolico.
- `970f955` docs(community): obseg je oznaka, ne izbirnik (odločitev A).
- `941b5bd` feat(community): detajl opravila — percentil, frekvenca in ta teden = **korak 8**.

Korak 8 podrobno:
- Ruta `/community/task/:taskTypeId?plant=` — **gnezdena pod `/community`** (ostane v zavihku, svoj
  back stack), ime `community-task`. `?plant=` **odsoten = prostorska skupina** (`@site` ne gre v URL).
- `community_task_screen.dart` + 4 widgeti: `community_bars.dart` (**EN** graf za oba prikaza —
  sezonski in frekvenčni), `community_timing_card.dart`, `community_frequency_card.dart`,
  `community_explain_sheet.dart` (ℹ️ v AppBar).
- Podatkovne vrzeli zaprte: `recentActivity({bucket, taskTypeId, cohort})` bere »ta teden« iz **iste
  dnevne rezine**, ki jo je feed že predpomnil (test dokazuje 0 dodatnih zahtev);
  `watchMySeason(taskTypeId, {cohort})` → `MySeason(first, count)` z eno poizvedbo.
- Čiste funkcije: `seasonDensity`, `seasonWindow`, `seasonPercent`, `seasonPeakWeeks`,
  `mondayOfIsoWeek` — unit-testirane (moj teden zunaj sezone, teden 1, tanek vzorec).
- Vrstice feeda se odpirajo v predlogo (TODO odstranjen).
- i18n `community.detail.*` v **vseh treh jezikih** + `dart run slang`.
- Testi: +9 widget detajla, +3 repo, +9 stats, +36 layout matrika (`community/task` + tease).

Popravki iz pregleda seje 2 (v commitih 1–2): napaka kataloga na landingu je dala večni spinner →
`LoadErrorHint`; cache ključ je bil podvojen podatek → izpeljan iz tabele+filtra (5 → 2 parametra);
feed se ni razširil, če je rezina imela samo zlite/pokvarjene vrstice.

ODLOČITVE SEJE 3 (velja naprej)

- **K8c dodan** (zavihek »Kje si ti«): K5 ga je pustil prazen s TODO, noben korak ga ni napolnil.
- **Graf percentila = gostota v sezonskem oknu** (po wireframu B3), ne CDF krivulja in ne vseh 53
  tednov: okno od `kCommunitySeasonWindowLowCdf` do `...HighCdf`, min. `...MinWeeks` (13), vedno
  vključno s tvojim tednom. Vseh 53 = ~4 dp/stolpec na 320 dp; mesečni koši zabrišejo prav razliko
  zgoden/pozen (teden 12 in 15 sta oba »april«).
- **Os grafov = datumi (`formatDm` ponedeljka tedna), ne imena mesecev.** `intl` ni direktna
  dependency, imena mesecev bi pomenila 36 novih prevodov za manj natančnosti. Zapisano v screen-map.
- **K9 prepisan iz »piši prevode« v »preberi prevode«** — nizi so nastali v K8, ker test popolnosti
  iz K6 zahteva sl/de za vsak `en` ključ in bi samo-EN commit pustil suite rdeč.
- **`myFirstThisSeason` ne obstaja več** → `watchMySeason`. `communityBuckets` je zdaj **keepAlive
  Stream** nad profilom (sprememba lokacije takoj prescopa; kot autoDispose Future ga je scheduler
  podrl sredi čakanja). `08 §8.3` je usklajen.

ODPRTE VRZELI (vhod za K8b / K8c / K9 / K10)

- **K8b:** skupino iz opravila (`task_subject → user_plant.plant_id`, brez kataloške rastline →
  `kCommunityCohortSite`) je treba izpeljati, a logika je zaprta v privatnem `_catalogPlantsByTask`
  → rabi eno javno metodo na `CommunityRepository`. Pravilo »najrelevantnejši namig« za kartico na
  Domov še ni določeno; predlog iz prejšnje seje: prvi element feeda, ki obstaja v mojem vrtu, sicer
  prvi element. Oboje za `kSuggestionsEnabled`, tease enako kot landing.
- **K8c:** rabi (1) »moji tipi opravil te sezone« iz drift (metode ni) in (2) N krivulj naenkrat —
  `RemoteAggFetch` zna samo `eq`, rabi `in`, sicer je prvo dnevno odprtje N×4 zahtev namesto ene
  rezine (§12.4). Zavihek še ni tease-gated (zdaj prazen za vse).
- **K10:** ključ `suggestions.community.most_started` ima v vseh treh jezikih `{percent}` in
  `test/i18n/suggestions_i18n_test.dart` to pogodbo uveljavlja. Strežnik v M11 entitlementa ne pozna
  (pride s FR-20) → rabi različico brez številke za vse push-e; številka ostane v aplikaciji na
  Plus-gated zaslonu.
- `community_cache` nima evikcije — ena `deleteWhere(fetchedAt < now − 30 dni)`.
- `DateTime.now()` v `community_task_screen` `_Body.build` je edina nečista točka detajla (kartica
  sama je čista in dobi `today` kot parameter). Če bo motilo, gre v provider.
- Wireframe B3 ima v feedu rastlino zapečeno v naslov (»Sajenje paradižnika«), koda pa naslov =
  opravilo, podnaslov = rastlina (po screen-map §1.5). Koda je po dokumentu; HTML se lahko uskladi.
- Migracija **0017 ni aplicirana nikjer** — mora na PROD **pred prižigom** nočnega agregata, sicer
  bi cron polnil `activity_*` brez `@site` vrstic (zapisano v `docs/deploy-runbook.md`).

PLAN (vrstni red)

K1–K6 ✅ · K7 ✅ · K7b ✅ · K8 ✅ → **K8b** (Domov sekcija »V tvoji okolici ⬡« nad DANES + kartica na
detajlu opravila, oboje → `/community/task/:taskTypeId`; widget test obeh vstopov) → K8c (zavihek
»Kje si ti« + bulk branje + tease) → K9 (pregled prevodov) → K10 (R6 v smart-engine + opt-in push,
Deno testi) → K11 (M11.21 docs + koncept sync + memory) → K12 (predpriprava merge: analyze+test
zelen; če se je main premaknil, `git merge main`) → K13 👤 merge M11→main (dark) → K14 👤 on-device
dimni test.

STANJE KODE IN OKOLJA

- `flutter analyze` čist, cel `flutter test` **1044 zelenih** (layout matrika 320/360/411 × sl/en/de
  × 1.0/1.3, zdaj tudi `community/task` + tease).
- M11 UGASNJEN: `kSuggestionsEnabled=false` ovija vse vstopne točke (Domov band,
  `/suggestions/history`, nastavitve, FCM, 5. zavihek ⬡ + `/community` **in nova gnezdena
  `/community/task/...`**). Server-dark: `app_config.engine_enabled=false`, edge fn ni deployan.
  Drift schemaVersion = 16.
- `kDevPlusStub = true` → v dev je Okolica vidna kot za naročnika; `hasPlusProvider` je edini šiv,
  ki ga FR-20 zamenja s podpisanim tokenom. Gumb »Vnesi kodo« je inerten (`onPressed: null`).
- Community agregatne tabele obstajajo na PROD (M11.16/0009), staging jih NIMA → dev build vedno
  kaže »še premalo vrtnarjev«; to ni bug.
- Pretekle zaključene sezone še ne obstajajo → percentil bo prvo sezono tekel v cenzuriranem načinu
  §7.6 (»doslej letos«); `SeasonCurve.censored` + `detail.censored_note` to pokrivata.
- `docs/m11/13-`, `14-`, `15-nadaljevanje-prompt.md` se NE commitajo.

OKOLJSKE PASTI

- rtk mangla git log/status → git VEDNO prek `rtk proxy git …`. Commit sporočilo v
  `tmp/commit_msg.txt` + `git commit -F`. **`git add docs` pobere tudi nadaljevanje-prompt datoteke
  → `git restore --staged` ju pred commitom.**
- Okolje NIMA gh CLI — PR/push prek `git push` (izpiše URL). Pre-push hook sam požene analyze+test.
- **Riverpod 3 past:** autoDispose provider, prebran prek `.future`, ga scheduler podre sredi
  `await` → ali `@Riverpod(keepAlive: true)`, ali ga beri naročenega (`readAlive` helper v
  `test/features/community/community_fallback_test.dart`). Tip `Refreshable` pride iz
  `package:flutter_riverpod/misc.dart`, ne iz glavnega exporta.
- Primarni shell PowerShell (Bash tudi). Freezed 3.x = `abstract class X with _$X`. `Bucket` se
  zaleti s supabase storage_client → `import supabase_flutter hide Bucket`. `ErrorHint` je zaseden v
  Flutter foundation → naš widget je `LoadErrorHint`. `plantsMapProvider`/`taskTypesMapProvider`
  živita v `core/database/catalog_provider.dart`.
- Drift `TaskType` konstruktor zahteva `requiresSubject`, `weatherSensitive`, `consumesSupplies` —
  testni fixture brez njih ne prevede.
- `intl` NI direktna dependency → imen mesecev ni; datumi za prikaz prek `core/date_format.dart`.
- Generiranje Dart kode prek python heredoc: pazi na apostrofe v Dart nizih (`screen's` razbije
  enojno narekovano vrstico) — raje piši datoteko z Write orodjem.
- slang = `dart run slang` (build_runner ga NE ujame); shema/anotacije →
  `dart run build_runner build --delete-conflicting-outputs`.
- On-device: `& .\deploy.bat hot` (staging). Pred prod/main buildom `adb uninstall app.tendask`.
  Screencap: `MSYS_NO_PATHCONV=1 adb shell screencap -p /sdcard/x.png` → `adb pull`. Zaslon prižgan:
  `adb shell svc power stayon true`.
- Če `flutter test` obtiči → ubij viseče `flutter_tester`/`dart` procese.
- PRODUKCIJA: nikoli nič ne briši; migracije additive-only + idempotentne. UI: NIKOLI beseda
  »motor« → »Tendask«/»predlogi«.

ODLOČENO (velja naprej)

- Pot A: dokončaj M11 v celoti → merge M11→main (dark).
- M11.20 (paywall/`in_app_purchase`/trial) ODPADE — FR-20 (zunanja licenca, koda za odkup).
  V aplikaciji NIKOLI cena/URL/CTA k nakupu.
- Obseg = samodejna oznaka (odločitev A): razreši ga fallback veriga, izbirnik odložen; »vsi« ne obstaja.
- Primerjalna skupina (`cohort` v kodi): rastlinska ali `@site`; nikoli se ne zamenja, širi se le
  geografija; zlita `''` vrstica se nikoli ne bere. Slovensko v dokumentih = »primerjalna skupina«.
- Okolica se gradi za `kSuggestionsEnabled`; pravi Plus-gate prižge FR-20.
- % samo nad `kCommunityReliabilityMin` (30), zaokrožen na 10; pod tem opisni tercilni pas.

PARKIRANO (ne blokira)

Slovnica `{subject}` (rodilnik) copy-prenova ~61 sporočil × sl/en/de. TENDASK-6 RenderFlex ~9 px.
FR-8 vreme na centroid. Insert-if-missing LWW race. Globalno vedro (rabi spremembo M11.16 crona).
Razrez `@site` skupine po tipu območja (`@lawn`/`@bed`) — V3. Izbirnik obsega (odložen, ne opuščen).
