# Tendask — povratne informacije testerjev in uporabnikov

> **Status:** živ dokument · prvi vnos 2026-06-23
> **Namen:** zbirka opažanj testerjev/uporabnikov + najina analiza in odločitve. Vsako opažanje
> dobi: (1) kaj je uporabnik opazil, (2) dejansko stanje v kodi (preverjeno, ne ugibano),
> (3) ocena (vredno / hiter korak / velik zalogaj / poruši flow / že planirano), (4) priporočilo
> in odločitev. Nove runde feedbacka se dodajajo spodaj kot nov razdelek z datumom.
>
> Povezano: [`roadmap.md`](roadmap.md) (mejniki + backlog FR-*), [`m11/`](m11/README.md)
> (pametni motor), [`koncept.md`](koncept.md).

---

## Hitra prioritizacija (povzetek prve runde)

| # | Opažanje | Ocena truda | Vrednost | Priporočilo |
|---|----------|:-----------:|:--------:|-------------|
| T6 | Seznam rastlin ni urejen | **hiter** | srednja | ✅ **NAREJENO** (2026-06-25) — abecedno, locale-aware (č/š/ž, ä/ö/ü) |
| T7 | Telefon naj obvesti o opravilu | **hiter** | **visoka** | **Naredi** — privzeti opomnik za *načrtovana* opravila (odločitev: default-on?) |
| T3 | Opravila vezana na entiteto | srednji | visoka | ✅ **NAREJENO** (2026-06-25) — mehki dvig rastlin po izbranem tipu (`category_task_type`), brez blokiranja |
| T4 | Rastline vezane na tip območja | srednji | srednja | ✅ **NAREJENO** (2026-06-26) — mehki dvig rastlin po tipu ciljnega območja, brez blokiranja |
| T1 | Avtomatska opravila + napoved pobiranja | **zelo velik** | visoka | **Že planirano = M11** (pametni motor); pobiranje le kjer obstaja pravilo |
| T2 | Predlog naslednje rastline (kolobarjenje) | velik | srednja | **Že zabeleženo = FR-10** (V2/motor) |
| T5 | Manjka podvrsta/varieta | velik (strukturno) | srednja | Zdaj: prosti `personalAlias`; strukturni katalog = V2+ |
| T9 | Beleženje slik (zgodba rasti) | **zelo velik** | **visoka** | Močan V2 kandidat; rabi Supabase Storage + binarni sync |
| T8 | Smiselno zaporedje opravil (odvisnosti) | velik | nizka | **Verjetno ne** — poruši prosti flow; motor to deloma reši z verigami |

---

## Runda 1 — tester (prijatelj), 2026-06-23

> Vir: e-pošta. Tester je namestil build z `main` (interni test vc2/vc3 — **brez** M11/FCM).
> Pomembno za interpretacijo: tester je dobil MVP, ne motorja.

### T1 — Avtomatsko dodajanje opravil (zalivanje ob solati, napoved pobiranja)

**Opazil:** ko doda solatko, naj app sam upošteva, da bi se naj zalivalo (ima okvirno lokacijo →
vreme nazaj in naprej → priporočila), in naj izračuna, kdaj se pričakuje pobiranje. Sam je opazil,
da za pobiranje »potrebuješ ogromno količino podatkov o vsaki rastlini«.

**Dejansko stanje:** v MVP so vsa opravila ročna (`TasksRepository.create`). Točno to opažanje je
**jedro M11 — pametnega motorja**, ki je že polno specificiran (`docs/m11/`):
- verige opravil (setev → pikiranje → utrjevanje → presaditev), kjer se vsak naslednji korak
  računa od **dejanskega** datuma uporabnika, ne od fiksnega koledarja;
- vremensko pogojeni namigi (zalivanje prek `weather_guard` straž — `dry24h`, `no_rain_forecast_24h`);
- sezonska okna + **pozeba kot sidro** (frost-anchor) → pravila se same regionalizirajo;
- motor **ne ustvarja opravil sam**, ampak **predloge** (pas na Domov + opcijski push), iz katerih
  z gumbom »Načrtuj« nastane načrtovano opravilo. To je namerna odločitev (manj predlogov je boljše
  od napačnega; ohrani uporabnikov nadzor).

**Ocena:** največji posamezen kos; **že planirano** (M11, po MVP/V2). Napoved pobiranja = pravilo
tipa `growth_stage` (N dni po setvi/saditvi). Tester ima prav glede podatkov: motor je **namerno na
nivoju kategorije + kuriranih pravil**, ne na nivoju per-vrsta dataset-a. Polni dataset zrelostnih
dni za vsako od 128 vrst = ogromen vir podatkov z nizkim ROI.

**Priporočilo:** ne uvajaj avtomatskega ustvarjanja opravil (poruši »beležim, kar sem naredil«
model + tveganje šuma). Ostani pri predlog-modelu M11. Pobiranje predlagaj **samo** tam, kjer
obstaja zanesljivo `growth_stage` pravilo; brez per-vrsta zrelostne baze v MVP.

**Odločitev:** _(odprto — potrjeno smer M11; obseg pravil za pobiranje določimo ob M11.9+)_

---

### T2 — Za pobrane rastline predlagaj naslednjo

**Opazil:** ko rastlino pobereš, naj ponudi/predlaga naslednjo rastlino.

**Dejansko stanje:** **že zabeleženo kot FR-10** v roadmapu (kolobarjenje, menjave, premiki —
V2/motor). Odprta podvprašanja so že popisana: kontinuiteta zgodovine subjekta čez sezone, mirovanje
pravil, premik med gredami.

**Ocena:** V2 funkcija motorja. Rabi znanje o kolobarjenju (na nivoju družin) + stabilen subjekt-ključ
čez sezone. Srednje-velik zalogaj.

**Priporočilo:** odloži na V2 (FR-10). Smiselno, a šele ko motor stoji.

**Odločitev:** _(odprto — V2)_

---

### T3 — Dodajanje opravil vezano na entiteto (manj možnih akcij; drevesa/grede ne prezračuješ)

**Opazil:** če bi bila opravila vezana na izbrano entiteto, bi bilo možnih akcij manj in vnos bolj
ciljen (»drevo/gredo ni smiselno prezračevati«).

**Dejansko stanje — KLJUČNO:** matrika `categoryMatrix` (65 vnosov: kategorija rastline → dovoljeni
tipi opravil) **že obstaja** v `lib/data/seed/catalog_seed.dart`, a se v UI **ne uporablja**.
Trenutno (`type_step.dart`) se pokažejo **vsi** tipi opravil, sortirani le po pogostosti uporabe —
ne glede na subjekt. `requiresSubject` se preverja šele ob prehodu na Pregled.
- **Zaplet flowa:** tip opravila se izbere v **koraku 1**, subjekt šele v **koraku 2**. Filtriranje
  tipov po subjektu torej zahteva ali (a) zamenjavo vrstnega reda korakov (subjekt prvi), ali (b)
  filter/dvig relevantnih tipov, ko je subjekt že znan (npr. vnos iz konteksta rastline/območja).

**Ocena:** najbolj akcijska točka — podatek je tu, manjka ožičenje. A pozor: roadmap (FR-1/FR-6)
opozarja, da je korak 1 (tip) občutljiv za auto-advance flow — trdo blokiranje bi ga porušilo. Tudi
offline katalog je lahko nepopoln; preveč tog filter zapre legitimne robne primere.

**Priporočilo:** naredi **mehko**, ne trdo. Ko je subjekt znan (vnos iz rastline/območja ali po
izbiri subjekta), uporabi `categoryMatrix`, da **relevantne tipe dvigneš na vrh / nepovezane
zatreš**, ne pa popolnoma skriješ. Srednji trud, dobra vrednost. Izogni se rigidnemu blokiranju.

**Odločitev (2026-06-25): NAREJENO — mehki dvig, brez spremembe vrstnega reda korakov.**
Mapping subjekt↔tip je dvosmeren: ker je tip izbran v koraku 1, v koraku 2 (subjekt) **rastline
z ujemajočo kategorijo dvignemo na vrh**, ostale pa **zatremo pod medlo oznako »manj verjetno«**
(`SectionLabel`), nikoli ne skrijemo. Vir je drift tabela `category_task_type` (pull iz oblaka +
offline seed) prek novega `taskTypeCategoriesProvider` — ne seed konstanta. Pravilo relevance je
v čisti funkciji `lib/core/catalog_relevance.dart` (`isCategoryRelevant`): prazna matrika (ni tipa
/ tip brez vnosa) → vse relevantno; **neznana kategorija (lastna rastlina / nenaložen katalog) →
ostane relevantna** (neznano ≠ nepovezano — ne zatremo legitimnih robnih primerov). Soft-split se
prikaže le, ko sta obe skupini neprazni. Enako prerazporejeni so zadetki iskanja iz kataloga
(brez ločnice). **Območja namerno izven obsega** — matrika modelira kategorije rastlin, ne tipov
območij (to je bližje T4). Pokrito s 4 unit testi (`catalog_relevance_test.dart`) + obstoječi
widget test toka. analyze čist, 256/256.

---

### T4 — Dodajanje rastlin vezano na tip območja (na gredo ne posadiš drevesa)

**Opazil:** podobno kot T3 — na gredo verjetno ne posadiš drevesa, zato naj bo izbor rastlin vezan
na tip območja.

**Dejansko stanje:** v `garden_plant_add_screen.dart` se rastline filtrirajo **samo po kategoriji
rastline**, ne po tipu območja. `AreaType` ima vrednosti `garden/lawn/hedge/bed/tree/ornamental/other`;
`coarsePlantCategory` mapping obstaja. Povezave »tip območja → smiselne kategorije rastlin« ni.

**Ocena:** sorodno T3. Možna mehka prioritizacija (drevo → fruit_tree/conifer; greda →
vegetable/herbs). Srednji trud. Tveganje: pretoga pravila (drevo v velikem loncu, mešane grede …).

**Priporočilo:** mehka prioritizacija (predizberi/dvigni smiselne kategorije po tipu območja), brez
trdega blokiranja. Nižja prioriteta kot T3 — najprej T3, potem isti vzorec za T4.

**Odločitev (2026-06-26): NAREJENO — mehki dvig, brez blokiranja (isti vzorec kot T3).** Ko se
rastline dodaja na **konkretno ciljno območje** (`garden_plant_add_screen`, npr. odprto iz detajla
območja), se rastline z ujemajočo kategorijo dvignejo na vrh, ostale pa zatrejo pod medlo oznako
»manj verjetno« (`SectionLabel`) — nikoli skrijejo. Pravilo relevance je čista funkcija
`lib/core/area_plant_relevance.dart` (`relevantPlantCategories(AreaType?)`), ki vrne fine seed
kategorije za vsak tip območja: trata→`lawn`; živa meja→`hedge/shrub/conifer`; greda→
`vegetable/herbs/berries/perennial/bulb/climber` (brez dreves); drevo→`fruit_tree/citrus/conifer`;
okrasno→`perennial/shrub/bulb/climber/conifer/hedge`. **`garden`/`other`/brez območja → prazna
množica → vse relevantno (brez ločnice)** — vrt je celovita celota, ne specifična greda. Particija
teče prek istega `isCategoryRelevant` kot T3, zato **neznana (lastna) kategorija ostane relevantna**.
Velja le, ko sta obe skupini neprazni; v subjektnem načinu (vnos opravila) ciljnega območja ni →
brez dviga. Pokrito s 6 unit testi (`area_plant_relevance_test.dart`) + 2 widget testa
(`garden_plant_add_split_test.dart`: drevo dvigne sadno drevje nad ločnico; vrt = brez ločnice).
analyze čist, 268/268.

---

### T5 — Manjka podvrsta / varieta (več sort zelja z različnimi potrebami)

**Opazil:** obstaja več podvrst (npr. zelja) z različnimi potrebami/zahtevami; katalog jih ne loči.

**Dejansko stanje:** `Plant` model nima polja za varieto/podvrsto. Obstajata pa `UserPlant.customName`
in `personalAlias` (prosti tekst) — uporabnik **lahko** že zdaj zapiše sorto kot alias.

**Ocena:** dva nivoja:
- **poceni:** uporabnik vpiše sorto v `personalAlias` (že deluje, le ni vodeno);
- **drago:** strukturni katalog variet + **per-varieta agronomske potrebe** → ogromen vir podatkov +
  shema + neposreden vpliv na pravila motorja (ki so namerno na nivoju kategorije).

Testerjeva prava skrb (različne potrebe per varieta) je v **konfliktu z dizajnom motorja**
(kategorijski nivo) — namerno izven obsega.

**Priporočilo:** za MVP zadošča prosti `personalAlias` za oznako sorte. Strukturne variete = velik
trud, nizek ROI → V2+. Če se pokaže potreba, najprej dodaj zgolj **opisno** polje sorte (brez
agronomskih posledic), šele kasneje per-varieta pravila.

**Odločitev:** _(odprto — zaenkrat alias zadošča)_

---

### T6 — Seznam rastlin ni urejen

**Opazil:** seznam rastlin ni urejen (razen morda po pogostosti).

**Dejansko stanje:** `plantsListProvider` vrača rastline v **seed vrstnem redu** (kot zapisane v
`catalog_seed.dart`). Sekcija »pogosto/nedavno« je sortirana po `updatedAt DESC`. Glavni seznam ni
abecedni.

**Ocena:** **hiter korak.** Sortiraj abecedno po lokaliziranem imenu znotraj kategorijskih skupin,
sekcija »pogosto« ostane na vrhu.

**Priporočilo:** naredi. Pozor na **locale-aware** sortiranje (slovenski č/š/ž, nemški ä/ö/ü) — ne
goli `String.compareTo`, ampak ustrezna kolacija; ime beri prek `catalogLabel()`.

**Odločitev (2026-06-25): NAREJENO.** Nov skupni helper `lib/core/catalog_sort.dart`
(`compareCatalogLabels` + decorate-sort `sortedByLabel`) s kolacijo, kjer slovenski č/š/ž sedijo kot
ločene črke tik za c/s/z, nemški ä/ö/ü/ß pa se zložijo na osnovno črko (DIN 5007-1). Uporabljeno na 4
mestih: `plant_picker_screen`, `garden_plant_add_screen`, `subject_step` (katalog matches + lastne
rastline). Razvrščanje je po **lokaliziranem** imenu (`catalogLabel`/`userPlantLabel`); sekcije
»pogosto/nedavno« ostanejo recency-ordered. 6 unit testov, analyze čist. _Vrstni red kategorijskih
chipov in »znotraj skupin« ni potreben — seznam je ploščat, filtriran z izbranim chipom._

---

### T7 — Obvestila na nivoju telefona (pričakoval, da ga telefon obvesti o opravilu)

**Opazil:** pričakoval je, da ga bo **telefon** obvestil o opravilu.

**Dejansko stanje:** OS-obvestila **obstajajo** (`flutter_local_notifications`, kanal `task_reminders`,
exact alarmi, deep-link). A opomniki se ustvarijo **samo ročno** — uporabnik mora opravilu eksplicitno
dodati opomnik (korak 4 / »+ Dodaj obvestilo«). **Opravilo brez ročno dodanega opomnika nima nobenega
obvestila.** Privzeti zamik `kDefaultReminderOffset = 1440 min` (1 dan) obstaja, a se uporabi le, ko
uporabnik opomnik *doda*. (FCM/pametni push = M11, ni v tem buildu.)

**Ocena:** zmožnost je tu; vrzel je v **privzetku/odkrivljivosti**. Za **načrtovano** (prihodnje)
opravilo bi bilo smiselno samodejno predizpolniti en privzeti opomnik (uporabnik ga lahko odstrani).
Za **opravljena/retrospektivna** opravila opomnik pravilno ne nastane. Majhna koda, a **UX odločitev**
(default-on lahko moti; je v rahli napetosti z »beležim, kar sem naredil« filozofijo).

**Priporočilo:** verjetno **najvišja vrednost med hitrimi popravki** iz tega feedbacka. Predlog: ko
je status načrtovan/prihodnji, predizpolni **en** privzeti opomnik (toggle vklopljen, odstranljiv).
Rabi odločitev: default-on vs. eksplicitno vklopljeno.

**Odločitev (2026-06-23):** privzeti zamik opomnika spremenjen z »1 dan prej« (1440) na **»ob
dogodku« (0)** — `kDefaultReminderOffset = 0`. Ko uporabnik doda opomnik, je »ob dogodku« že
predizbran; vse ostale možnosti (1 h, 1 dan …) ostanejo na voljo. **Samodejnega dodajanja** opomnika
zaenkrat NE — opravilo še vedno dobi opomnik šele ob »+ Dodaj« (ohrani tok dovoljenj + ne moti
opravljenih opravil).

---

### T8 — Smiselno zaporedje opravil (zalivanje pred potrjenim sajenjem)

**Opazil:** imel je zabeleženo saditev na prosto + kasneje zalivanje; ko sta obe zapadli, je lahko
zalival, ne da bi potrdil saditev (ali celo »zalil še ne presajeno«).

**Dejansko stanje:** med ročno vnesenimi opravili **ni logike odvisnosti/zaporedja**. Motor (M11) ima
verige (`growth_stage`), kjer se naslednji korak računa od dejanskega prejšnjega, a to so **predlogi**,
ne validacija/blokada uporabnikovih vnosov.

**Ocena:** prave odvisnosti opravil (A pred B) = precejšnje modeliranje, polno robnih primerov in
zlahka poruši preprosti »beleži karkoli kadarkoli« flow. Scenarij (zalil pred saditvijo) je za dnevnik
večinoma neškodljiv. Pravilno zaporedje že naslavlja veriga predlogov motorja.

**Priporočilo:** **verjetno ne** — eksplicitne odvisnosti bi bile over-engineering in bi porušile
prosti vnos. Verige motorja so pravšnja velikost odgovora. Nizka prioriteta.

**Odločitev:** _(odprto — predlagam: ne implementiramo eksplicitnih odvisnosti)_

---

### T9 — Beleženje slik (zgodba rasti: saditev, mimohod, bolezen, pobiranje)

**Opazil:** slikaš ob saditvi, mimohodu, bolezni, pobiranju → na koncu sestaviš zgodbo, slikovno
dokumentiraš prirastek.

**Dejansko stanje:** **ni podpore za slike** — namerno izpuščeno (`koncept.md` §6.7: »Foto izpuščeno
zaenkrat«; roadmap wishlist: »Zgodovina rasti (foto, bolezni skozi čas)«). Nobena tabela (drift/Supabase)
nima slikovnih polj; sync je vrstično/JSON, ne binarni.

**Ocena:** **visoka uporabniška vrednost** (vizualni dnevnik je zelo privlačen), a **velik zalogaj**:
zajem slike, lokalna shramba, **Supabase Storage**, **binarni sync** (trenutni sync tega ne zna),
offline obravnava, sličice, stroški/zasebnost ob skali. Trči ob omejitve €0 / offline-first / zasebnost.

**Priporočilo:** močan **V2 kandidat**, ne MVP. Ob obravnavi upoštevaj infrastrukturne posledice
(Supabase Storage, binarni sync, strošek ob rasti). Že na wishlistu — predlagam dvig prioritete znotraj
V2, a ne pred zaključkom MVP/launcha.

**Odločitev:** _(odprto — V2)_

---

### Splošna opomba k rundi 1

Tester je dobil **MVP build brez motorja** — zato je velik del njegovih opažanj (T1, deloma T2, T7
v smislu pametnih push namigov) pravzaprav že naslovljen v M11/FCM, ki ga ni mogel videti. Resnično
sveže in akcijske ugotovitve za MVP so: **T3** (matrika že obstaja, le ožičiti), **T6** (abecedno
sortiranje) in **T7** (privzeti opomnik za načrtovana opravila). T8 je edina, ki jo priporočam
zavestno **ne** implementirati.
