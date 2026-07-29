# FR-22: Kontekstualni poziv za lokacijo na Domov

- **Status:** predlog, neimplementirano
- **Datum:** 2026-07-28 · **rešitev spremenjena 2026-07-29** (§3: brez lokacije vremena ne kažemo)
- **Cilj:** povečati delež uporabnikov z nastavljeno lokacijo vrta (`profile.h3_r5`)
- **Področja:** Domov (vremenska kartica), podrobnosti opravila, vreme, pametni motor
- **Povezave:** `docs/analitika-geo.md` (od kod številke),
  [`wireframes/01d-weather-states.html`](../wireframes/01d-weather-states.html) (vsa stanja + besedila),
  `docs/wireframes/` 16,
  `lib/features/home/presentation/widgets/home_weather_section.dart`,
  `lib/features/auth/presentation/location_screen.dart`

---

## 1. Problem

**55 % uporabnikov nima nastavljene lokacije vrta** (44 od 80 profilov, PROD, 28. 7. 2026).

Kar to *ni*: niso mrtvi profili in ni tehnična napaka. Vseh 44 ima
`default_garden_seeded = true` in vsaj eno območje — onboarding je pri vseh tekel do
konca, 13 jih je že opravilo kakšno opravilo. Nobeden nima nobene od treh H3
resolucij, torej ni delnega zapisa; lokacija preprosto nikoli ni bila nastavljena.

Časovnica pove, kaj se je zgodilo:

| Obdobje | Profilov | Brez lokacije |
|---|---|---|
| junij (zaprta beta) | 23 | **4 %** |
| od Play izdaje 20. 7. | 55 | **75 %** |
| zadnjih 7 dni (22.–28. 7.) | 8 | **100 %** |

Beta testerji so bili vodeni in motivirani. Pravi uporabniki preskočijo — in
preskok je najlažja poteza na zaslonu, ker je `location_screen.dart:276`:

```dart
FilledButton(onPressed: () => context.go('/home'), child: Text(t.location.kContinue))
```

Edini gumb na dnu je **primarni** in brezpogojno pelje naprej; nastavitev lokacije
zahteva tipkanje v kartico sredi zaslona. Kdor enkrat tapne, ni nikoli več pozvan —
do zaslona vodita samo onboarding in Nastavitve → Lokacija.

### Zakaj to ni le vrzel v statistiki

`gardenLocation` (`location_repository.dart:226`) ob manjkajoči celici vrne
`kDefaultLatitude/kDefaultLongitude` = **Ljubljana**. Posledice, po resnosti:

1. **Aplikacija tiho kaže napačno vreme.** Uporabnik v Murski Soboti dobi ljubljansko
   napoved, predstavljeno kot vreme svojega vrta — brez oznake kraja, brez opozorila.
   Na tej podlagi se odloča, ali bo zalival.
2. **Pametni motor računa na napačni lokaciji** — sezona, slana, dež so lokalni.
   Predlog »zalij« za 55 % uporabnikov izhaja iz tujega vremena.
3. **Okolica (skupnost) je zanje strukturno prazna** — kohorta se veže na H3 celico.
4. Šele nato: agregatna slika trga je pristranska (`docs/analitika-geo.md`).

Točka 1 pomeni, da je to **popravek poštenosti**, ne rastna taktika. Poziv, ki ga
predlagava, je posledica: če kartica pove resnico, je ponudba nastavitve naravna.

## 2. Cilj in merila

**Cilj:** uporabnik ve, ali vreme velja za njegov vrt, in ima ponudbo nastavitve
tam, kjer mu manjka — ne v onboardingu, kjer še ne ve, čemu služi.

| Metrika | Izhodišče (28. 7.) | Cilj |
|---|---|---|
| **Primarna:** delež novih profilov z `h3_r5` | 25 % (14 od 55, kohorta 20.–28. 7.) | ≥ 60 % v 30 dneh po izdaji |
| **Sekundarna:** delež obstoječih 44, ki lokacijo nastavi | — | ≥ 30 % v 30 dneh |
| **Varovalo:** delež profilov, ki lokacijo *počisti* (`clearGardenLocation`) | ~0 | ostane ~0 |
| **Varovalo:** aktivnost (profili z ≥1 opravilom v 7 dneh) | izmeri ob izdaji | ne pade |

Merjenje ne potrebuje novega instrumentiranja — FR-14 (analitika) ni pogoj.
Kohortna poizvedba po dnevu registracije je že v `tool/geo_user_map.py` oz.
`docs/analitika-geo.md`; pred izdajo zamrzni izhodišče, po 30 dneh ponovi.

**Cilj ni 100 %.** Kdor lokacije noče dati, je to legitimno; naloga je, da ve, kaj s
tem izgubi, in da ga stanje ne zavaja.

## 3. Rešitev

**Brez nastavljene lokacije vremena ne prikazujemo.** Na mestu vremenske kartice
stoji povabilo z eno potjo naprej. Privzetek Ljubljana odpade — ne le z zaslona,
ampak iz cevovoda (§6).

| Stanje | Danes | Odločeno |
|---|---|---|
| lokacija nastavljena | vreme + ime kraja | nespremenjeno |
| **ni lokacije** | **vreme za Ljubljano, brez oznake** | **ni vremena** — povabilo + CTA »Nastavi kraj« |
| offline brez posnetka | tiha »ni na voljo« kartica | nespremenjeno (možno le, ko je lokacija znana) |
| **opravilo čaka, ni lokacije** | obljubi posnetek, ki bo ljubljanski | pojasnilo + CTA |
| **opravilo opravljeno brez posnetka** | »zajet brez povezave« (tudi ko je vzrok drug) | nevtralno »ni na voljo«, brez trditve o vzroku in brez CTA |

**Zakaj za zaključeno opravilo ni razlage:** aplikacija ne ve, zakaj posnetka ni — task tega ne shrani,
poznamo le trenutno stanje. Kdor zaključi brez lokacije in jo pozneje nastavi, bi dobil »zajet brez
povezave«; kdor zaključi brez povezave in pozneje lokacijo odstrani, bi dobil obratno. Trenutno stanje
sme opisovati **prihodnost** (opravilo, ki čaka — posnetek še bo, zato tam vzrok in CTA), ne pa
**preteklosti**.

Zakaj ta varianta in ne pas pod ljubljanskim vremenom (prvotni predlog):

1. **Popravek je namen FR-ja** (§1): dokler vreme ostane na zaslonu, ga uporabnik
   bere kot svojega — opomba pod podatkom je šibkejša od podatka nad njo.
2. **Poziv postane edina vsebina na tem mestu** in ga ni mogoče spregledati; to je
   tudi razlog, da pričakujeva večji premik metrike kot od pasu.
3. **Cena je znana in sprejeta:** Domov je ob prvem odprtju brez lokacije bolj
   prazen. Kdor lokacije noče dati, ostane brez vremena — legitimna izbira, ki jo
   povabilo pošteno pove.

Načela (nespremenjena):
- **Ne modalno, ne push, ne blokira.** Kartica je del zaslona, ne prekine poti.
- **Miren ton, ne alarm.** Ni rdeče, ni klicaja — to ni napaka uporabnika.
- **Ena poteza do rešitve:** CTA pelje na obstoječi `/location` (push, z back).
- **Ne izginja in se ne vrača.** Dokler lokacije ni, je povabilo tam; ni odštevanja,
  ni »ne prikaži več«.

### Besedilo in grafika

Celoten predlog besedil (sl/en/de) in grafike je v
[`wireframes/01d-weather-states.html`](../wireframes/01d-weather-states.html) — tam so
narisana vsa stanja in vsi CTA. Povzetek ključev (vsi pod `weather.*`, kjer že živita
`home_unavailable` in `home_retry`):

| Ključ | sl |
|---|---|
| `no_location_title` | Kje vrtnariš? |
| `no_location_body` | Z lokacijo ti lahko pokažemo vremensko napoved za tvoj vrt. |
| `no_location_cta` | Nastavi lokacijo |
| `no_location_privacy` | Shranimo samo približno lokacijo. |
| `detail_no_location` | Vreme zabeležimo, ko nastaviš lokacijo. |

Nemški prevod je predlog za pregled ob implementaciji (slang, `dart run slang`).
Naslov je isto vprašanje kot na zaslonu 16 — poziv in cilj se berta kot ena poteza;
telo pove korist in namenoma **ne ponovi gumba**, ki stoji tik pod njim.

**Izrazje (dosledno z obstoječim):** `lokacija / location / Standort` = nastavitev
(»Lokacija vrta«, »Lokacija je nastavljena«, »Uporabi mojo lokacijo«);
`kraj / place / Ort` = konkretna vas ali mesto v iskalnem polju (»Vpiši kraj«).
Ta besedila govorijo o nastavitvi → povsod **lokacija**.

**Tri obstoječa besedila gredo v isto spremembo** (celotne različice sl/en/de v wireframu):

| Ključ | Danes | Po tem FR |
|---|---|---|
| `location.clear_confirm_body` | »Vreme bo prikazano za privzeto območje, dokler ne nastaviš nove lokacije.« | »Brez lokacije ti vremena ne bomo mogli pokazati.« — privzetega območja ni več |
| `weather.detail_none` | »Vremenski posnetek ni na voljo **(zajet brez povezave)**.« | brez oklepaja — trdi vzrok, ki ga ne poznamo (glej §3 zgoraj) |
| `location.privacy` | »Shranimo samo približno **okolico** (širše območje nekaj km)…« | »…približno **lokacijo** (na nekaj kilometrov natančno)…« — okolice ni mogoče shraniti; shranimo H3 celico |

Zadnji dve nista posledici tega FR — napačni sta že danes; popravita se tu, ker se ju FR tako ali tako dotakne.

Grafika: zeleni pin (isti motiv kot ilustracija na zaslonu 16) v zaobljenem kvadratu
44 dp, isti zeleni preliv kot vremenska kartica, `FilledButton` polne širine,
zasebnostna vrstica z 🔒 pod gumbom. Vse barve prek teme — brez rdeče, brez klicaja.
Nič novega v `assets/`.

## 4. Obseg

**V obsegu:**
- povabilo namesto vremenske kartice na Domov (+ CTA na `/location`),
- `gardenLocation` brez celice vrne `null` in posledice v `currentWeather` ter
  `weatherCapture` (§6),
- dve novi stanji v podrobnostih opravila (čaka / opravljeno brez lokacije),
- novi i18n ključi + popravki `location.clear_confirm_body`, `weather.detail_none`, `location.privacy`,
- unit + widget testi, vnos v `test/layout/` matriko.

**Izven obsega** (ločene odločitve, ne pogoj za to):
- Obrat hierarhije gumbov na zaslonu 16. Najmanjši poseg z največjim učinkom na *nove*
  uporabnike; vreden svojega FR-ja, ker se dotakne onboardinga. → **Zdaj
  [FR-24](onboarding-location-cta.md)** (2026-07-29). Izvedba ni `TextButton`, kot je
  slutila ta alineja, ampak poudarjena GPS kartica + nepoudarjen gumb za preskok.
  **Ne izdaj v isti izdaji kot ta FR** — oba premikata isto metriko.
- Poziv ob prvi rastlini/zalivanju.
- Sprememba privzetka iz Ljubljane v »brez vremena« (glej §7).

## 5. Vedenje in robni primeri

- **Gost** (`kLocalUserId`): deluje enako — celica se piše lokalno, brez računa.
- **Offline:** vnos kraja potrebuje geocoding (mreža), GPS ne. Zaslon 16 to že
  obravnava; povabilo ob odsotnosti mreže ostane, CTA pa vodi na isti zaslon, ki
  napako pokaže sam. Ne dupliciraj obravnave napak.
- **Takoj po nastavitvi** povabilo zamenja vreme brez osvežitve — `gardenCell` je
  `Stream`, kartica ga gleda (`ref.watch`), prehod je reaktiven.
- **Po `clearGardenLocation`** se povabilo vrne. To je pravilno in ni nadlegovanje:
  uporabnik je pravkar sam izbral stanje »brez lokacije«.
- **Stanje »offline« se brez lokacije ne more pojaviti** — brez celice ni klica, torej
  ni česa ne dobiti. Dve tihi kartici se ne moreta prekrivati.
- **Opravila, zaključena brez lokacije, ostanejo brez posnetka za vedno.** Vremena za nazaj
  ne dopolnjujemo; zato tam ni CTA, ki bi obljubljal popravek.
- **Domov + podrobnosti opravila, nič drugam.** Ne dodajaj poziva v Okolico, nastavitve
  ali seznam opravil.
- **Layout:** dolga nemščina + text-scale 1.3 → povabilo mora ovijati, ne rezati.
  Dodaj vnos v `test/layout/` matriko.

## 6. Implementacijske opombe

Odločitev seže dlje od enega widgeta — privzetek odpade tudi tam, kjer ga ni videti:

| Mesto | Danes | Po tem FR |
|---|---|---|
| `gardenLocation` | brez celice vrne Ljubljano | vrne `null`; `kDefaultLatitude/Longitude` ostane samo kot razvojni `--dart-define` override |
| `currentWeather` | klic na Open-Meteo za privzeto točko | brez celice ni klica |
| `weatherCapture` (`tasks_providers.dart:22`) | zamrzne **ljubljanski** posnetek v dnevnik, za vedno in nevidno | brez celice posnetka ni; opravilo se shrani normalno |
| podroben list (01c) | odprt tudi brez lokacije | nedosegljiv — ni kartice, ki bi jo tapnil |

Vrstica `weatherCapture` je pravzaprav resnejša od kartice: napačno vreme na Domov se
naslednjo uro osveži, napačen posnetek v dnevniku pa ostane in ga uporabnik nikoli ne
vidi označenega kot tujega.

- `HomeWeatherSection` naj gleda **`gardenLocationProvider`** (po tem FR `GardenCoords?`) in ob
  `null` izriše povabilo, ne da bi sploh gledal `currentWeatherProvider`. **Ne `gardenCellProvider`**
  (prvotna navodba, popravljena 29. 7.): `cellCentroid()` lahko vrne null tudi ob shranjeni celici, in
  tak uporabnik bi videl »vreme ni na voljo« brez poti naprej — z `gardenLocation` dobi povabilo, ki ga
  pelje na zaslon 16.
- Povabilo je **svoj widget** (`WeatherNoLocationCard`), ne stanje `CurrentWeatherCard` —
  ta prikazuje vreme, povabilo ni vreme. Isti preliv, ista zaobljenost.
- CTA: `context.push('/location')`. Zaslon že zna »iz nastavitev« način
  (`fromSettings = context.canPop()`) — z `push` dobi back puščico in nima gumba
  »Nadaljuj«. **Nič novega v routerju.**
- `TaskWeatherSection` potrebuje tretjo in četrto vejo: `waiting` + brez celice →
  pojasnilo s CTA; `done` + brez posnetka + brez celice → pojasnilo brez CTA. Da veja ne
  postane gnezdo `if`-ov, modeliraj z `enum`/`sealed` (CLAUDE.md: >3 pogoji → imenovan tip).
- Brez nove dependency, brez migracije, brez spremembe sheme.

## 7. Odprta vprašanja

1. ~~**Ali Ljubljano sploh obdržati kot privzetek?**~~ **Odločeno 29. 7. 2026: ne.**
   Brez lokacije ni vremena, ampak povabilo (§3). Cena — bolj prazen Domov ob prvem
   odprtju — je sprejeta zavestno, ker je poziv s tem edina vsebina na tem mestu.
2. **Ali isto povedati v Okolici**, ko se prižge? Tam brez celice ni kohorte, torej
   ni vsebine — a to je drug zaslon in druga odločitev.
3. **Ali obstoječih 52 doseči tudi drugače** (push, razlagalni list)? Da — to je
   [FR-23](location-nudge.md), ločena izdaja.
4. **Ali `kDefaultLatitude/Longitude` sploh obdržati?** Predlog: obdrži kot razvojni
   `--dart-define` override za testiranje drugih regij, a nikoli kot tiho zasilno
   vrednost v produkciji. Alternativa je konstanti odstraniti in regije testirati z
   dejansko nastavljeno lokacijo.
