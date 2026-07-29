# Narejeno — kaj, kako in zakaj

> **Edini dokument o zaključenem.** Vsaka vrstica hrani **odločitev z razlogom**, ne poteka dela —
> kako koda izgleda, pove koda; kdaj je nastala, pove `git log`.
>
> Trenutno stanje → [`stanje.md`](stanje.md) · odprto → [`backlog.md`](backlog.md) · karta →
> [`README.md`](README.md). **Zaključeno se sem prestavi in iz `backlog.md` izbriše.**
>
> Polno besedilo pred prestrukturiranjem (dnevnik sej, koraki z DoD): `git show 3ce81df:docs/roadmap.md`.

## Mejniki

M0 temelj · M1 lokalna baza · M2 jedro opravil · M3 območja/rastline/zaloge/opombe · M4 vreme ·
M5 Supabase · M6 sync · M7 auth + H3 · M8 lokalna obvestila · M9 polish + release → **vsi zaključeni**,
aplikacija je v produkciji. **M10 (iOS)** in **M11 (pametni motor)** nista → [`backlog.md`](backlog.md).

---

## Podatki, sync in shema

| Kaj | Kako | Zakaj / poslovna odločitev |
|---|---|---|
| **drift je vir resnice za UI** | UI bere in piše samo lokalno bazo; Supabase se polni v ozadju | Vrt nima signala. Offline ni robni primer, ampak normalno stanje — če bi UI čakal na oblak, aplikacija tam, kjer se uporablja, ne dela. |
| **Sync polja od prvega dne** | Vsaka uporabniška vrstica dobi `id` (UUID z naprave), `updated_at`, `deleted`, lokalni `sync_status` — **že v M1**, čeprav sync pride v M6 | Naknadno dodajanje bi zahtevalo migracijo vseh tabel na napravah, ki so že v obtoku. |
| **LWW izključno po času** | `DoUpdate(where: old.updated_at <= ts)` | Prvotna veja je vsebovala še `| sync_status == synced` — to bi pustilo **starejši** oblak povoziti sinhronizirano vrstico. Ujeto med pisanjem testov. `sync_status` v razsodbo o novosti ne sodi. |
| **Vključujoč kurzor pri pullu** | `updated_at >= since` + idempotenten upsert po `id` | drift hrani `updated_at` v **sekundah** → strogi `>` izgubi robno vrstico. Idempotentnost naredi ponovni pull neškodljiv. |
| **Push je fail-fast po FK vrstnem redu** | `profile → area → supply → recipe → user_plant → task → note → task_subject/reminder/supply`; napaka pri tabeli ustavi ostale, vrstice ostanejo `pending` | Nadaljevanje bi vstavljalo otroke brez staršev. Cena: **ena zavrnjena vrstica zaklene cel sync** — od tod dve produkcijski nesreči spodaj. |
| **Push ob shranjevanju, ne le periodično** | `db.tableUpdates` + 2 s debounce | Odjava je brisala lokalne podatke, ki še niso bili nikoli pushani (push je bil samo periodičen/ob zagonu). Uporabnik je po `logout → login` ostal brez podatkov. Zdaj je pred `clearUserData` obvezen `flushPush()`, offline pa odjavo prekine. |
| **`updated_at` zaščita ob mark-synced** | Vrstica, urejena med branjem in označevanjem, ostane `pending` | Sicer se sprememba, narejena med mrežnim upsertom, tiho izgubi. |
| **Migracije so additive-only** | Add column/table da, rename nikoli (add + dual-write + drop čez 2 izdaji); nov stolpec nullable ali z default | Stari APK-ji ob pullu ne smejo crashati. **Ni tehnično pravilo, ampak poslovno:** ne moreš prisiliti uporabnika, da nadgradi. |
| **Brez `updated_at` triggerja v Postgresu** | `updated_at` postavlja naprava | Naprava je lastnik LWW ključa; strežniški trigger bi ga prepisal in pokvaril vrstni red pulla. |
| **Katalog: oblak je vir resnice, seed ostane** | `catalog_seed.dart` → `gen_catalog_sql.dart` → `catalog.sql`, idempotenten upsert; naprava full-pulla po slugu, `SeedService` ostane kot bundlan fallback | Prvotni načrt »pull-only, umakni seed« je bil **zavržen** — kršil je offline-first: prvi zagon na vrtu brez signala bi dal prazen katalog. Parnost generatorja je **test**, ne disciplina. |
| **Katalog id-ji so add-only** | Nikoli preimenuj ali izbriši id v rabi | `user_plant.plant_id` in `task.task_type_id` kažeta nanje — preimenovanje jih osiroti in zlomi FK pri uporabnikih, ki so rastlino že dodali. |

## Zasebnost in lokacija

| Kaj | Kako | Zakaj / poslovna odločitev |
|---|---|---|
| **Koordinate ne zapustijo naprave** | H3 celica se izračuna na napravi; v oblak gredo samo `h3_r7/r6/r5` | Zasebnost po zasnovi. Push/pull seznama sta **eksplicitna** (ročno naštete tabele), zato nova tabela ni nikoli tiho sinhronizirana. Obstaja test, ki trdi, da se `device_location` **nikoli** ne pusha. |
| **Nato: sploh brez koordinat** (FR-8) | Vreme in usmerjanje bereta centroid celice `cellToGeo(h3_r7)`; `device_location` odstranjena; dovoljenje COARSE-only | Rob celice r7 je ~1,2 km = **pod ločljivostjo Open-Meteo mreže** (1–11 km), torej natančnost ni bila nikoli izkoriščena. Stranski dobiček: lokacijski zaslon po odjavi/prijavi izgine (uporabnikova pritožba). |
| **Sprememba podatkovnega toka = pravni posel** | Ob FR-8 in FR-12 sta šla zraven privacy policy (SL/EN/DE, objavljena na `tendask.com/privacy`) in Play Data Safety | Deklaracije morajo ustrezati dejanskemu vedenju — brez tega se sprememba **ne shipa**. FR-12 je dodal tretjega prejemnika (OSM/Nominatim), kar je terjalo v1.2 obeh dokumentov. |
| **Nominatim, ne Open-Meteo, za ime kraja** | Reverzno geokodiranje centroida, cache po `{celica, jezik}`, klic le ob spremembi celice | Open-Meteo Geocoding gre samo naprej (ime→koordinate). Cache tudi omogoči offline prikaz zadnje znane oznake — a **le za isto celico**, da premaknjen vrt ne kaže napačnega kraja. **Skalirni pomislek (parkiran):** javni Nominatim ima usage policy 1 req/s, brez bulk; ob rasti volumna pot LocationIQ/self-host. |
| **GDPR izvoz + izbris** | Izvoz vseh uporabnikovih tabel v JSON prek share sheeta (**izpusti** `device_location` in `sync_status`); izbris prek `SECURITY DEFINER` RPC, ki briše le `auth.uid()` | RPC namesto admin API, ker klient nima service-role ključa. Cascade iz migracije `0002` počisti oblak. Gost = samo lokalni izbris. |

## Uporabniški račun

| Kaj | Kako | Zakaj / poslovna odločitev |
|---|---|---|
| **Gost je lokalen, brez anonimnega računa** | Drift pod `kLocalUserId`; ob prijavi `claimLocalRows` posvoji vrstice na nov `uid` + push | `signInAnonymously` je ustvarjal račun ob **vsakem** zagonu online, vsaki odjavi in vsakem »Prijava« → kopica sirot v `auth.users` od ljudi, ki se za prijavo sploh niso odločili. Zdaj se oblak vključi šele ob pravi prijavi, kar se ujema z obljubo v UI (»brez računa = podatki lokalni«). |
| **Prijava ohrani podatke (merge, ne reset)** | Claim + push obstoječih gost-vrstic; branje ni filtrirano po `user_id` | Uporabnik, ki je mesec dni beležil kot gost, ob prijavi ne sme ostati brez vsega. Nefiltrirano branje pomeni, da podatki ob prijavi ne utripnejo (claim teče v ozadju). |
| **E-pošta OTP ohrani `user.id`** | Sprva `updateUser(email)` + `verifyOTP(emailChange)`; po odstranitvi anonimnih ostane ena pot `sendEmailOtp`/`verifyEmailOtp` | `signInWithOtp` bi ustvaril **novega** userja = izguba lokalnih podatkov. |
| **Trdota prijave je UX sloj** (FR-11) | Format + did-you-mean domene (Damerau-Levenshtein) + DNS prek DoH; 60 s cooldown | **Fail-OPEN:** blokiraj le ob NXDOMAIN ali NOERROR brez MX/A/AAAA; vse nejasno = spusti. Izpad DoH ne sme nikomur preprečiti prijave. DNS potrdi **domeno, ne nabiralnika** — napačen lokalni del ujame šele OTP. Pošlje se samo domena, ne cel naslov. |
| **Apple prijava odložena na M10** | Gumb na Androidu skrit | Rabi macOS + Apple Developer račun; ni vredno, dokler ni iOS. |

## Obvestila

| Kaj | Kako | Zakaj / poslovna odločitev |
|---|---|---|
| **Opomniki so lokalni in deterministični** | `flutter_local_notifications` + točni alarmi (`exactAllowWhileIdle`) | Delujejo brez strežnika in brez signala. Inexact alarmi so na Samsungu odloženi in nezanesljivi — opomnik, ki pride uro pozneje, je za vrtnarja neuporaben. |
| **Nastavitve v `profile.notification_settings` (jsonb)** | Sinhronizirano prek LWW, ne device-local | Nastavitve naj sledijo uporabniku na novo napravo. |
| **Tihe ure in kapica ne veljajo za eksplicitne opomnike** | Store-only; gejtajo samo sistemske namige | Opomnik, ki ga je uporabnik **sam** nastavil, ni motnja. Utišati bi ga pomenilo prelomiti obljubo. |
| **Re-engagement brez strežnika** (FR-16) | Lokalni dead-man's-switch: fiksna veriga dveh (+7, +28 dni ob 17:00); vsak dotik ju prekliče in zakoliči naprej; ločen kanal + **negativni** notif ID-ji | Doseže tudi **goste in neaktivirane**, ki jih FCM ne, je privacy-first in ne čaka na M11. Ključni vpogled: veriga dveh da decay in kapico **brez stanja v bazi**. Aktiven uporabnik ju nikoli ne vidi. Na lock screenu ni PII. |
| **Opomniki ostajajo trajno brezplačni** | — | So obljuba iz Play listinga in glavna zanka zadrževanja. Monetizira se sme le nov sloj nad njimi (vremensko pogojen opomnik, opomnik po fazi Lune). |

## Vreme

| Kaj | Kako | Zakaj / poslovna odločitev |
|---|---|---|
| **Posnetek se ob »opravljeno« zamrzne** | Zapisan na opravilo, nikoli prepisan | Evidenca mora ostati to, kar je bilo takrat — ne najnovejša napoved. |
| **Brez signala se opravilo vseeno shrani** | Posnetek ostane prazen ali se doda kasneje | Mrežna napaka ni izjema, je pričakovano stanje. Nikoli `throw` v UI. |
| **Stale prag 48 h, ne 2 h** | + tih žig »Osveženo ob X«, ki se pokaže **le** ko je posnetek star | Ob izpadu Open-Meteo (502, odzivi 40 s+ — izmerjeno) je bila kartica prazna. Zdaj jutranje odpiranje pokaže včerajšnji posnetek. Čez 48 h pošteno »ni na voljo« — napovedni pas bi bil sicer večinoma preteklost. |
| **Dashboard uporablja lažji zahtevek** | `fetchCurrent()` brez `hourly` soil/precip in `et0`; polni tripasovni posnetek le na detajlu | Najtežji del payloada se je nalagal za kartico, ki ga ne prikaže. |
| **Star posnetek se med osveževanjem ne skrije** | Bere `weather.value`, spinner le ob **prvem** nalaganju | Prazen zaslon med refreshem izgleda kot okvara. |

## Uporabniški vmesnik

| Kaj | Kako | Zakaj / poslovna odločitev |
|---|---|---|
| **En vnos namesto dveh** | Horizontalni stepper (vrsta → predmet → kdaj → opomnik → sredstva → pregled) | IA pregled je našel dva vira prenatrpanosti: Domov-kot-agregator in dvojni vnos (hiter + poln obrazec). Predlagan je bil progresivni zložen obrazec; **izvedeno je bilo drugače** — stepper. Cilj dosežen, oblika druga. |
| **Subjekt je rastlina ALI območje (M:N)** | `task_subject` | Opravila so bila območje-centrična, a razlog za opravilo je rastlina. |
| **Komponentni katalog** | `SectionLabel`, `FieldLabel`, `EmptyState`, `DestructiveButton`, `SaveBar`, `SheetHandle`, `showConfirmDialog` | Lokalne kopije istega vzorca so se razšle. Verbatim kopija widgeta med zasloni je rdeč alarm že pri dveh klicalcih. |
| **Barve samo prek teme** | `colorScheme.error` za destruktivno, `onSurfaceVariant` za medlo, palete v `theme/` | Brand se spremeni na enem mestu. Barvne palete so vzete **iz wireframa, ne prek `ColorScheme.fromSeed`** (seed jih popači); izbira teme je device-local. |
| **Matrika postavitve namesto pregledovanja** | Vsak zaslon × 3 širine (320/360/411) × 3 jeziki × 2 skali = 234 kombinacij | Nemščina in velika pisava tiho razbijeta postavitev; navadni widget test tega ne ujame. Nov zaslon = en `layoutMatrix(...)` klic. |
| **Koši opravil po koledarskem dnevu, ne 24-urnem oknu** | `taskDayGroup` na enem mestu | »Včeraj ob 22:00« mora biti zjutraj **zamujeno**. Prej sta obstajali dve skoraj enaki pravili z za dan zgrešeno mejo (dashboard je opravilo čez natanko 7 dni štel med prihajajoča, seznam pod »Kasneje«). |
| **Logika iz widgetov v čiste funkcije** | Sedem zaslonov razrezanih; merilo ni število vrstic, ampak **399 → 820 testov** | Pravila, ki knjižijo zalogo in brišejo pridelek, so bila netestirana znotraj `_save()`. Kar je v `build`, ni testabilno. |
| **Sredstva začasno skrita** | `kSuppliesEnabled=false`, koda ostane | Pred-release odločitev: manj površine za prvi javni test. Kasneje ponovno vklopljena s kategorijami in recepti. |

## Katalog rastlin

| Kaj | Kako | Zakaj / poslovna odločitev |
|---|---|---|
| **34 → 128 vrst, 12 kategorij** | Kuracija pogovornih imen SL/EN/DE + **GBIF** preverba znanstvenih imen + **Wikidata** batch SPARQL navzkrižna preverba slovenskih | Katalog je bil pretanek za resen vrt. Avtomatski uvoz brez preverbe bi dal latinske ali napačne domače nazive; edini popravek, ki ga je Wikidata ujela, je bil `hibiscus` → »sirski oslez«. |
| **Rastlina → opravila prek kategorije** | Razširjena `categoryMatrix` (93 vrstic) | 128 × 26 ročnih povezav se ne vzdržuje; kategorija je pravi nivo abstrakcije. |
| **Bundlan seed za prvi zagon** | Offline fallback, on-device potrjeno | Prvi zagon na vrtu brez signala mora dati poln katalog, sicer je aplikacija ob prvem vtisu prazna. |

## Izdaja, jezik in denar

| Kaj | Kako | Zakaj / poslovna odločitev |
|---|---|---|
| **Fallback jezik je angleščina** | `slang.yaml base_locale: en`; app sicer sledi jeziku telefona | Nepodprt jezik je prej padel na **slovenščino** — tujec je dobil SL. Posledica navzven: **privzeti jezik Play listinga je EN**, SL in DE sta prevoda. **sl ostaja jezik ciljnega trga in vir wireframov** (vsebinsko izhodišče, ne tehnični base). |
| **Sentry je čisti Dart paket** | `sentry ^9.x`, ne `sentry_flutter` | `sentry_flutter` 8.x se ne prevede na svežem Android skladu (trdo kodira `compileSdk 34`), 9.x pa poriše `jni` in zlomi `h3_flutter`. Pure Dart nima native modula → se vedno prevede. Gate na DSN: prazen DSN = Sentry izklopljen, app boota normalno. |
| **vc14 namerno zadržan** | AAB zgrajen, a ne naložen | Google je pregledoval prijavo za produkcijski dostop in pregledovalci testirajo prek zaprtega tira. Nova funkcija (sredstva) bi šla pred pregledovalce brez testerskega cikla. **Odločitev o izdaji, ne o kodi.** |
| **Tendask+ prek zunanje licence, ne Play Billing** (FR-20) | Nakup na spletni strani, v aplikaciji samo odkupna koda; podpisan token pride z obstoječim pull syncom, javni ključ bundlan → preverjanje **lokalno** | **0 % provizije Play** (politika izrecno dovoli dostop do vsebine, plačane drugje). Rdeča črta: v aplikaciji ne sme biti poziva k nakupu, cene ali URL-ja — velja tudi za pushe in i18n. |
| **Plačila prek merchant of record (Polar), ne Stripe** | MoR prevzame DDV/OSS, račune, chargebacke | **Normirani s.p. je obdavčen po prihodkih**, zato je pri MoR prihodek neto in provizija dejansko zniža davčno osnovo. Menjava ponudnika je prepis webhooka, ne selitev podatkov. |
| **Mesečna naročnina zavrnjena** | Ponudba = letno + doživljenjsko | Fiksna provizija 0,50 $ vzame **47 %** pri ceni 1,99 €; prelom je pri 7 mesecih. Sidro za ceno so tiskane Lunine bukve (9,90 €). |
| **Plus se gradi iz novega in neizdanega** | Izjema le razširitev zmogljivosti | Nihče ne sme izgubiti, kar že ima. Zato je najmočnejši kandidat za Plus prav **M11 motor** — zgrajen, a nikoli izdan. |

## Zahtevki (FR) — zaključeni

| FR | Kaj | Kako | Zakaj tako |
|---|---|---|---|
| **FR-1** | Grid tipov: razširi/skrij + sort po pogostosti | `COUNT(*) GROUP BY task_type_id` nad obstoječimi opravili | Sortiranje **per user** brez nove sheme. Načrtovana ekstrakcija skupnega `TaskTypeGrid` je odpadla — po stepperju je grid samo še en klicalec. |
| **FR-2** | Ustvari območje/rastlino iz obrazca | Vrne nov id prek `pop` → auto-select; providerji so `StreamProvider` nad `watchAll()` | Prazen vrt ne sme biti dead-end. |
| **FR-3** | Zatikanja | Lazy `SliverList` + snapshot pogostih v `initState` | Vzrok ni bil splošen: katalog 128 vrst se je gradil kot **en `Column`** in se rebuildal ob vsakem toggle. Namenskega profilinga ni bilo — **če se vrne, najprej izmeri.** |
| **FR-4** | Navigacija po dnevih v Dnevniku | ✗ **umaknjeno** | Prototip dnevnega traku je bil zgrajen in **na napravi zavrnjen** — vizualni šum brez vrednosti. Datume že pokrivata časovnica in mesečni pogled. |
| **FR-5** | Ponavljanje opravil | Materializiraj naslednjo instanco ob dokončanju, v isti transakciji; `Recurrence{everyDays, remaining}` + `task.series_id` | Ne RRULE. **Namerno izven obsega:** serijsko urejanje, izjeme, mesečno RRULE — `series_id` to kasneje omogoči. Semantika potrjena z uporabnikom: »ponovitve« = `remaining` neposredno (1 = še ena poleg trenutne). |
| **FR-6** | »Ponovi zadnje« | Predizpolni tip + subjekte + sredstva, skoči na Pregled | Koraka 1 se **ne** predizpolni z zadnjim tipom — to ubije auto-advance. |
| **FR-9** | Privzeto območje »Vrt« | Nov `AreaType.garden`, **prvi** v enumu (vrstni red UI = vrstni red deklaracije); auto-seed v transakciji; flag v lokalnih prefs | »Vrt« = v tla vsajena celota ob hiši, **različen od grede**. Flag **ni** v `profile`, ker bi synced stolpec zahteval migracijo profila na deljenem živem Supabase. Cena: multi-device re-seed edge, pri enouporabniškem MVP sprejemljivo. Ker je flag lokalen in ne »if missing«, **izbris drži**. |
| **FR-12** | Oznaka kraja pri vremenu | Nominatim reverse + cache | Po FR-8 lokacija nima imena, le celico — uporabnik ne vidi, čigavo vreme gleda. |
| **FR-13** | Indikator okolja | Kotni `Banner` prek `MaterialApp.builder`, samo ko `kEnvLabel != 'production'` | Produkcijski build ga ne more pokazati. `Colors.orange/grey` = upravičena dev-only izjema od »barve prek teme«. |
| **FR-17** | Haptični odziv | `AppHaptics` (light/medium/heavy); en chokepoint v `showConfirmDialog` | Sproži se, **ko se dejanje zgodi**, ne ob tapu — zato ne v skupnem `SaveBar`, ki ne ve za uspeh in bi utripnil ob neuspeli validaciji. Brez nove dependency, brez `VIBRATE` dovoljenja. |
| **FR-24** | Onboarding lokacija: poudarek na GPS, ne na preskoku | Poudarjena GPS kartica na dnu + nepoudarjen »Preskoči«; z nastavljeno lokacijo si poudarjenost zamenjata (»Nadaljuj«). Potrditev shranjevanja nosi statusni trak, ne toast | Edina polna zelena ploskev na zaslonu je bila doslej gumb, ki lokacijo **preskoči** — 52 od 95 profilov je brez nje. **Blokade ni:** lokacija ostane prostovoljna, preskok en tap; hierarhija samo pove, kaj je pričakovano. Toast je prekrival prav trak, ki isto pove in ostane. Merilo: 25 % → **≥60 %** novih z `h3_r5` v 30 dneh. **Neizdano — ne sme v isto izdajo kot FR-22.** |
| **T11** | Zajem pridelka ob pobiranju | `task.yield_amount` | Iz tester-feedbacka, runda 2. |
| **T9** | Beleženje slik | ✗ **zavrnjeno** | Dokončno umaknjeno iz backloga. |

---

## Napake, ki so nas nekaj stale

> Vsaka je stala sejo ali produkcijski incident. Pravilo v desnem stolpcu je razlog, zakaj so tu.

| Simptom | Vzrok | Pravilo, ki ostane |
|---|---|---|
| **Release build obtiči na splashu** | Status-bar ikona je bila **vektor**; `flutter_local_notifications` jo razreši prek `getResources().getIdentifier(…,"drawable",…)`, kar pri vektorjih vrne 0 → `invalid_icon`. Izjema je priletela iz `initialPayload()`, ki je bil **`await`-an pred `runApp()`** | Nič, kar lahko vrže, ne sme biti `await`-ano pred `runApp()`. Obvestila niso esencialna za zagon → `try/catch` + poročilo v Sentry. Ikona = PNG v density bucketih v **baznem** `drawable/`. |
| **Cel sync zaklenjen pri prijavljenem uporabniku** | Seedano območje `type='garden'` je padlo na `area_type_check` (23514); push je fail-fast, `area` gre pred vsem ostalim | **Vsaka nova enum vrednost potrebuje Supabase CHECK migracijo, aplicirano PRED katerim koli buildom, ki sinhronizira.** |
| **Isto, druga tabela** | Pre-poraba je dala negativno zalogo → `supply_quantity_check` zavrne push; `supply` se pusha pred `task` | Odločitev: **deficit dovoljen** (CHECK odstranjen), shrani se točno zaradi simetrije ob revertu, UI prikaz clampa na `max(0, qty)`. Poslovno: raje netočna zaloga kot zaklenjen sync. |
| **Uporabnik izgubil podatke ob `logout → login`** | Podatki nikoli pushani (push je bil le periodičen), `clearUserData` jih je izbrisal lokalno prej | `flushPush()` pred vsakim `clearUserData`; offline odjavo **prekine** namesto izbriše. Plus push ob shranjevanju. |
| **Razporejena obvestila se nikoli ne sprožijo** (takojšnja delujejo) | Manjkal `ScheduledNotificationReceiver` v manifestu — **plugin svojih receiverjev ne deklarira sam**; AlarmManager se sproži, a nima kdo prikazati obvestila | Vsi trije receiverji morajo biti v manifestu. Diagnostika, ki je zavajala: `exact:true`, `pending:1`, prava cona, nobene napake. |
| **`exact_alarms_not_permitted` po svežem deployu** | `SCHEDULE_EXACT_ALARM` na Android 14+ ni privzeto odobren in se ob ponovni namestitvi ponastavi | Po vsakem svežem deployu preveri dovoljenje, preden sklepaš, da je bug v kodi. |
| **82 »prelomov postavitve«, od tega 9 pravih** | `getMinIntrinsicWidth` pretirava za prosto-ovijajoč tekst | **Prosto-ovijajoč tekst (`softWrap && maxLines == null`) se nikoli ne odreže** — Flutter razlomi tudi predolgo besedo. Flagaj samo vrstično omejen tekst. |
| **Izbrani čip je izgledal onemogočen** | Tema je nastavila `chipTheme.selectedColor`, M3 pa besedilo izbranega čipa jemlje iz `onSecondaryContainer`, ki ga shema ni imela | Nastavi **par** (`secondaryContainer` + `onSecondaryContainer`) v shemi — popravi vseh 10 mest s čipi naenkrat. |
| **Google prijava ne dela na release buildu** | Upload-key SHA-1 ni bil registriran kot dodaten **Android OAuth client** | En OAuth client = en package + en SHA-1. Debug in release rabita vsak svojega; `serverClientId` (Web client) se ne spremeni. Play App Signing doda še tretjega. |
| **»Ni zvoka obvestil«** | `STREAM_NOTIFICATION` glasnost na 0 (Samsung ima ločen drsnik) | **Ni bug.** Kanal, točni alarm in vibracija so delovali. Od tod `ReminderSoundBanner`, ki to pove vnaprej. |
| **Zeleno lokalno, rdeče na CI** | CI pred `analyze` požene `slang` in `build_runner`, pre-push hook pa ne | Po vsaki spremembi i18n ključev ali anotacij regeneriraj **in commitaj** generirane datoteke. |
| **`Type not found` v generirani kodi, ki je `analyze` ne vidi** | Glavni `app_database.dart` ni importal enuma/konstante, ki jo rabi `part`-generirani `*.g.dart` | `flutter analyze` tega ne ujame, `flutter test` ga. Zato je merilo pred commitom **cel `flutter test`**, ne analyze. |
