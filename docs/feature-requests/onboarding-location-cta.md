# FR-24: Onboarding lokacija — GPS je glavni CTA, preskok je nepoudarjen

- **Status:** implementirano 2026-07-29 (koda, i18n, testi), še neizdano
- **Datum:** 2026-07-29
- **Cilj:** da na zaslonu 16 v onboardingu **nič poudarjenega ne pelje mimo lokacije**
- **Področja:** onboarding (zaslon 16), `location_screen.dart`, i18n (sl/en/de), layout matrika
- **Wireframi:** [`16-location.html`](../wireframes/16-location.html) (stanje A — brez lokacije) in
  [`16e-location-set.html`](../wireframes/16e-location-set.html) (stanje B — nastavljena), oba v
  [`index.html`](../wireframes/index.html), skupina 🚀 Start, drug ob drugem. Način iz nastavitev
  je [`16b-location.html`](../wireframes/16b-location.html) in se ne spreminja.
- **Povezave:** [FR-22](location-adoption.md) (pas na Domov — tam je bil ta poseg izrecno
  odložen, §4 »Izven obsega«), [FR-23](location-nudge.md) (push za obstoječe brez lokacije),
  `docs/prelomi-besed.md` (proračun širine), `docs/screen-map.md` §`/location`

---

## 1. Problem

**52 od 95 profilov nima lokacije vrta** (PROD, 29. 7. 2026; ob meritvi FR-22 dne 28. 7. je bilo
44 od 80). Delež ne pada — z vsako izdajo raste absolutna številka.

Vzrok je na zaslonu in ga je mogoče pokazati z eno vrstico. `location_screen.dart:276`:

```dart
if (!fromSettings) ...[
  SizedBox(width: double.infinity, height: 52,
    child: FilledButton(onPressed: () => context.go('/home'),
                        child: Text(t.location.kContinue))),
]
```

Edini **`FilledButton`** na zaslonu — edina zelena, polna, polnoširinska ploskev — je gumb, ki
lokacijo **preskoči**. Nastavitev lokacije zahteva tipkanje v kartico sredi zaslona ali tap na
belo GPS kartico. Vizualna hierarhija torej pove nasprotno od tega, kar hočemo: teža je na izhodu.

To ni ugibanje o vedenju — je preprosto dejstvo o postavitvi. Poudarjen gumb na dnu je tisto, kar
palec doseže in oko najde; vse ostalo je videti opcijsko.

### Odnos do FR-22 in FR-23

Vsi trije naslavljajo isti podatek z različnih strani in se **ne izključujejo**:

| | Koga doseže | Kje |
|---|---|---|
| **FR-24** (ta) | **nove** uporabnike, ob prvem zagonu | onboarding, zaslon 16 |
| FR-22 | vse brez lokacije, ob vsakem odprtju | pas na vremenski kartici, Domov |
| FR-23 | obstoječih 52, ki Domov morda ne odprejo | push + razlagalni list |

FR-22 §4 je ta poseg izrecno odložil: *»Obrat hierarhije gumbov na zaslonu 16 … vreden svojega
FR-ja, ker se dotakne onboardinga.«* To je ta FR.

## 2. Cilj in merilo

**Cilj:** nov uporabnik konča onboarding z lokacijo, ker je to najlažja poteza — ne zato, ker bi
ga karkoli prisililo. Preskok ostane dosegljiv v enem tapu, brez modalnega vprašanja, brez
ponavljanja.

| Metrika | Izhodišče (29. 7.) | Cilj |
|---|---|---|
| **Primarna:** delež **novih** profilov z `h3_r5` | 25 % (kohorta 20.–28. 7., FR-22) | ≥ 60 % v 30 dneh |
| **Varovalo:** dokončanje onboardinga (profili z `default_garden_seeded`) | ~100 % | ne pade |
| **Varovalo:** delež, ki lokacijo pozneje počisti | ~0 | ostane ~0 |

Merjenje je isto kot pri FR-22 (`tool/geo_user_map.py`, `docs/analitika-geo.md`) — nova analitika
ni pogoj. Ker FR-22 in FR-24 vplivata na isto metriko, ju **ne izdaj v isti izdaji**, sicer učinka
ni mogoče pripisati.

## 3. Rešitev

Spodnji blok zaslona 16 (samo v onboardingu) postane **stalen par**: GPS kartica, pod njo gumb
»naprej«. Med stanjema se spremeni **samo poudarjenost in napis spodnjega gumba** — nič se ne
premakne, nič ne izgine.

| | GPS kartica (zgoraj) | gumb (spodaj) |
|---|---|---|
| **A** · lokacije ni | **poudarjena** (polna zelena, bel tekst) | nepoudarjen bel z obrobo · »Preskoči« |
| **B** · lokacija nastavljena | nepoudarjena (bela z obrobo) | **poudarjen zelen** · »Nadaljuj« |

Načela:
- **Nič poudarjenega ne pelje mimo lokacije.** V stanju A je edina polna zelena ploskev GPS.
- **Postavitev se ne premika.** Enaka elementa, enaka mesta, enake velikosti v obeh stanjih —
  gumb ne skoči pod prstom, ko se stanje spremeni med tapom.
- **Preskok ostane en tap.** Ni dvojnega potrjevanja, ni »ali si prepričan«, ni odloga.
- **Ni modalnega okna in ni sistemskega poziva brez tapa.** GPS dovoljenje se vpraša šele ob tapu
  na kartico — kot doslej.

**Vrstni red ostane nespremenjen.** Kartica »Vpiši kraj« je še vedno zgoraj, GPS pod njo — kot
doslej in kot pravi komentar v `location_screen.dart:244` (*»typing a place name is the most
universally understood action; GPS is the alternative«*). Spremeni se le, **kje** GPS kartica
stoji (na dnu, kjer je palec) in da je **poudarjena**. Poudarek mora nekam, prazna vnosna kartica
pa ga ne more nositi — dokler ni vpisa, nima česa sprožiti.

Zgornji del zaslona (statusni trak, ikona, naslov, opis, kartica »Vpiši kraj«, opomba o
zasebnosti) ostane tak, kot je bil potrjen 2026-06-08 — spremeni se samo blok pod njim.

### 3.1 Kartica, ne gumb

GPS ostane **kartica** (ikonska ploščica + naslov + podnaslov + ševron), samo preseli se z
sredine na dno in dobi poudarjeno varianto. Razlog ni samo videz:

- Podnaslov **»Samodejno z GPS naprave«** pove, da gre za **trenutno** lokacijo (za razliko od
  vpisanega kraja). Brez podnaslova bi to moral nositi naslov — in »Uporabi mojo **trenutno**
  lokacijo« ne gre v noben jezik (§4).
- Ševron napove, da sledi sistemsko dovoljenje, ne takojšnje dejanje.

### 3.2 Potrditev shranjevanja: trak, ne toast

Doslej je vsako shranjevanje (GPS, izbran kraj, izbris) sprožilo `showTopToast` — temno ploščico na
**vrhu** zaslona, torej natanko čez statusni trak, ki pove isto stvar in ostane. Na zaslonu 16b
(iz nastavitev) je to bralo kot okvara: nekaj temnega za dve sekundi prekrije vsebino.

Toast na tem zaslonu odpade. Potrditev nosi statusni trak, ki je za to že tam:

- **prehod se animira** (~320 ms cross-fade + rahel scale) — sprememba, ki se zgodi pred očmi, se
  opazi; tiha zamenjava dveh sličic se ne;
- **po shranjevanju se trak scrolla v vidno polje** (`Scrollable.ensureVisible`), sicer bi ostal nad
  robom, če je uporabnik izbiral kraj iz zadetkov;
- **ime kraja pokaže takoj**: izbran `place.name` se hrani lokalno, dokler ga reverzno
  geokodiranje ne razreši. Mimogrede zapre offline vrzel — brez mreže se ime doslej sploh ni
  pokazalo.

Prednost pred toastom: potrditev je trajna (ne izgine po 2,2 s), stoji ob gumbu »Odstrani« in ničesar
ne prekriva. `showTopToast` ostane v rabi drugod (opravila, podvojene rastline), kjer pokriva prazen
prostor, ne lastne vsebine. Napake se še naprej izpišejo kot rdeče besedilo v vsebini, ne kot toast.

## 4. Besedila in prostor

Izmerjeno na najhujši celici layout matrike — **320 dp × text-scale 1,3**, z bundlanim
Plus Jakarta Sans in resničnimi slogi (`titleMedium` w600 / `bodySmall`), ne na oko.

### 4.1 GPS kartica — stolpec besedila 161 px

V kartici je ovijanje v redu (kartica zraste); breme je **prelom sredi besede**
(`docs/prelomi-besed.md`).

| Niz | Najdaljša beseda | Vrstic | |
|---|---|---|---|
| `Uporabi mojo lokacijo` | 82 px | 2 | ✅ |
| `Use my location` | 83 px | 1 | ✅ |
| `Meinen Standort verwenden` | 114 px | 2 | ✅ |
| `Samodejno z GPS naprave` | 89 px | 2 | ✅ |
| `Automatically via device GPS` | 106 px | 2 | ✅ |
| `Automatisch per Geräte-GPS` | 98 px | 2 | ✅ |
| ~~`Uporabi mojo trenutno lokacijo`~~ | 88 px | 2 | ⚠️ |
| ~~`Meinen aktuellen Standort verwenden`~~ | 114 px | **3** | ❌ |

**Nobena beseda ne preseže 161 px → nikjer preloma sredi besede.** Zato naslovi in podnaslovi
ostanejo **nespremenjeni** (`use_gps`, `gps_sub`). Beseda »trenutno«/`aktuellen` je zavrnjena:
nemški naslov gre v tri vrstice, pomen pa že nosi podnaslov.

### 4.2 Spodnji gumb — proračun 227 px, mora ostati v **eni** vrstici

| Niz | Rabi | |
|---|---|---|
| **`Preskoči`** | 77 px | ✅ 150 px rezerve |
| **`Skip`** | 39 px | ✅ |
| **`Überspringen`** | 120 px | ✅ |
| `Nadaljuj` / `Continue` / `Weiter` | 71 / 81 / 58 px | ✅ |
| ~~`Preskoči za zdaj` / `Skip for now` / `Später festlegen`~~ | 138 / 108 / 147 px | ✅, a daljše brez koristi |
| ~~`Continue without location`~~ | 227 px | ⚠️ **0 px** rezerve |
| ~~`Ohne Standort fortfahren`~~ | 223 px | ⚠️ 4 px |

»Nadaljuj brez lokacije« (184 px) bi v slovenščini šlo, a angleška in nemška sestra sedita na
robu — vsaka sprememba pisave, paddinga ali velikosti gumba ju prelomi.

**Izbrano `Preskoči` / `Skip` / `Überspringen`** — ena beseda, največja rezerva, in **ista beseda,
kot jo onboarding že uporablja** za preskok koraka (`onboarding.skip` = »Preskoči ›«). Uporabnik
je torej ta izraz na tej poti že videl in ve, kaj naredi.

### 4.3 Spremembe i18n (sl/en/de)

| Ključ | Sprememba |
|---|---|
| `location.skip` | **nov** — `Preskoči` · `Skip` · `Überspringen` |
| `location.why` | novo besedilo (brez »(kasneje)«), glej spodaj |
| `location.set_gps`, `location.set_place`, `location.cleared` | **odstranjeni** — bili so besedila toasta (§3.2) |
| `location.use_gps` | nespremenjen (`Uporabi mojo lokacijo` · `Use my location` · `Meinen Standort verwenden`) |
| `location.gps_sub` | nespremenjen, **ostaja v rabi** (podnaslov kartice) |
| `location.continue` | nespremenjen, uporabljen v stanju B |
| `location.place_note` | »Dovolj je **bližnja** vas ali mesto…« (·`A nearby village or town…` · `Ein Dorf oder eine Stadt in der Nähe…`) |

Novo besedilo `why`:

| | |
|---|---|
| sl | Lokacijo potrebujemo za lokalno vremensko napoved in da ti lahko pokažemo, kaj počnejo drugi vrtnarji v tvoji okolici. |
| en | We need your location for the local weather forecast and so we can show you what other gardeners near you are doing. |
| de | Wir brauchen deinen Standort für die lokale Wettervorhersage und um dir zeigen zu können, was andere Gärtner in deiner Umgebung tun. |

**Zakaj brez »(kasneje)«.** Zaslon zdaj **omenja Okolico, dokler je ta še temna** — sprejeto
zavestno: stavek opisuje, čemu lokacija služi, ne obljublja gumba danes. Če se prižig Okolice
zavleče čez ~2 izdaji, se stavek skrajša na vremenski del.

> **Popravek ob izvedbi:** ta razdelek je prvotno predvideval brisanje ključa `why_live` in
> ternarja s `kCommunityEnabled` v `location_screen.dart`. Oboje je obstajalo samo na veji M11 —
> na `main` je bil `t.location.why` že brezpogojen. Spremeni se le besedilo.

## 5. Obseg

**V obsegu:** spodnji blok zaslona 16 v onboarding načinu, premik `GpsCard` na dno + poudarjena
varianta, nov ključ `location.skip`, novo besedilo `why`, potrditev shranjevanja v traku namesto
toasta (§3.2, velja za oba načina), vnosi v layout matriko, widget testi, wireframi 16 + 16b,
`screen-map.md`.

**Izven obsega:**
- Hierarhija gumbov v načinu »iz nastavitev« (16b) — tam ni ne CTA-ja ne preskoka in ostane tako
  (spremeni se le potrditev shranjevanja).
- Pas na Domov (FR-22) in push (FR-23) — ločeni izdaji.
- Blokiranje onboardinga brez lokacije. **Nikoli**: lokacija je prostovoljna.
- Samodejni sistemski poziv za GPS brez tapa uporabnika.

## 6. Vedenje in robni primeri

- **Prehod A → B je takojšen.** Vnos kraja ali GPS shrani takoj (obstoječe vedenje), trak zgoraj
  postane zelen, spodnji par zamenja poudarjenost brez animacije postavitve.
- **B → A** po »Odstrani« (potrditveni dialog obstaja) — poudarjenost se vrne, spodnji gumb spet
  »Preskoči«.
- **GPS zavrnjen:** obstoječe sporočilo o napaki ostane; uporabnik lahko še vedno vpiše kraj ali
  preskoči. Poudarjena kartica se **ne** izklopi — poskus je legitimen.
- **Med nalaganjem** je kartica onemogočena (`loading`), gumb za preskok pa **ostane omogočen** —
  uporabnik ne sme obtičati za počasnim GPS-om.
- **Offline:** GPS deluje, geokodiranje vpisanega kraja ne. Nespremenjeno.
- **Gost** (`kLocalUserId`): enako, celica se piše lokalno.
- **Odprta tipkovnica:** pripeti par bi požrl seznam, v katerem so zadetki iskanja (na 360×640 mu
  ostane manj kot 200 dp), zato se med tipkanjem umakne — GPS možnost se vrne v seznam, gumb za
  preskok počaka. Nihče ne obtiči: tipkovnico zapre izbira zadetka ali tap mimo.

## 7. Implementacijske opombe

- `GpsCard` (`features/auth/presentation/widgets/gps_card.dart`) dobi zastavico za poudarjeno
  varianto (polna `cs.primary`, `cs.onPrimary` tekst, ikonska ploščica `white.withValues(...)`).
  **Ne** ustvarjaj druge kartice — en widget, dve varianti.
- `OrDivider` ostane med vnosno kartico in GPS blokom; preseli se skupaj z njim na dno.
- Po spremembi ključev poženi **`dart run slang`** (build_runner tega ne ujame).
- **Layout matrika:** zaslona v njej doslej ni bilo. Dodana sta **dva** vnosa (`location (unset)` /
  `location (set)`), ker se stanji ne izrišeta enako. Vnos za stanje B rabi dodaten `pump`: ime kraja
  pride mikrotask po prvem `watch`, potem pa se še cross-fade — brez tega se najširša varianta traku
  nikoli ne izmeri.
- Gumb uporablja `minimumSize`, ne `SizedBox(height: 52)` (`ui-katalog.md`): fiksna škatla bi drugo
  vrstico tiho odrezala.
- **Glava je pomanjšana na mere wireframa** (ploščica 92 → 74, ikona 46 → 38, ožji razmiki, tanjši
  padding zasebnostne opombe) — ~40 dp, kolikor je manjkalo, da zasebnostna opomba pri 360×800 ne
  visi pod robom. Preverjeno na napravi: brez scrollanja v sl in de. Pri 320 dp z veliko pisavo se
  zaslon še vedno scrolla, kar je neizogibno.
- `EnterPlaceCard` je dobila `Material` ovoj: zadetki iskanja so `ListTile`-i, katerih ink splash se
  izriše na najbližjem `Material` predniku — pod barvno škatlo je bil neviden (Flutter to javi kot
  assert, ki ga je ujel prvi widget test).
- Testni pripomoček `test/core/location/fake_location_repository.dart` (fake repo + `locationOverrides`)
  si delita layout matrika in widget testi; prava H3 knjižnica se pod `flutter test` ne naloži (FFI).
- Brez nove dependency, brez migracije, brez spremembe sheme, brez sprememb v routerju.

## 8. Odprta vprašanja

1. **Nepoudarjen gumb je lažje tapniti kot tekstovna povezava.** Zavesten kompromis: manj skokov
   za nekoliko dostopnejši preskok. Če se po 30 dneh delež ne premakne dovolj, je naslednji korak
   **zmanjšati** spodnji gumb (nižji, manjša pisava), ne pa ga vračati v povezavo.
2. **Bel z obrobo vs. `btn.secondary`** (svetlo zelena podlaga, zelen tekst — obstaja v
   `ui-katalog.md`). Izbran bel, ker jasneje bere kot drugotni; zelenkast bi tekmoval s poudarjeno
   kartico.
3. **Ali isto hierarhijo prenesti na zaslon dovoljenja za obvestila (21)?** Tam velja isti vzorec
   (poudarjeno = dovoli, nepoudarjeno = pozneje). Ločena odločitev, ni pogoj za ta FR.
