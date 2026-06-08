# Vrtnarska evidenčna aplikacija — koncept

> **Status:** ŽIV DOKUMENT · pred-implementacijska faza
> **Zadnja sprememba:** 2026-06-01
> **Opomba:** Pred kakršnokoli implementacijo večkrat pregledamo celotno aplikacijo,
> user flow in UI/UX. Ta dokument se sproti nadgrajuje in popravlja. Nič hitenja.

---

## 1. Ideja v enem stavku

Preprosta **osebna evidenca opravil** na celotni posesti (vrt, trata, živa meja,
gredice, zasaditve), ki uporabniku vrača vrednost prek **vremenskega konteksta**,
**opomnikov** in **lastne zgodovine** ("lani tačas ste...").

## 2. ✨ Vodilno načelo: PREPROSTOST

UI/UX mora biti **zelo preprost in intuitiven**. Glavni primer rabe je hiter vnos:
*"pokosil travo"*, *"zalil travo"* — **kaj + kdaj**, v par dotikih. Enako preprosto
za dodajanje opomnika. Vse ostalo je sekundarno; **če vnos ni hiter, aplikacija ne
deluje.**

## 3. Ciljni uporabnik

- Lastnik hiše/vrta — hobi vrtnar, **ne** profesionalec.
- Želi pregled in učenje iz lastnih preteklih sezon.
- **Evropski / večjezični trg** (vključno SLO) — namensko **brez** ZDA-specifik
  (USDA cone, °F, ameriške trave/izdelki).

### Močna podpersona: ⭐ intenzivni skrbnik trate (lawn-care)
- Vzor: FB-skupine tipa "Popolna trava" — člani stremijo k brezhibni zelenici (boj proti
  kostrebi, *Poa annua*, detelji, mahu).
- Vedno znova sprašujejo **"kdaj in v kakšnem vrstnem redu"**: spomladanski zagon,
  dosejevanje, gnojenje (katero/kdaj), aeriranje, vertikutiranje, valjanje, peskanje
  (top-dressing), zalivanje — in čez celo leto.
- Diagnostika: rjavi fleki (pasji urin / suša / ogrci pod rušo), plesen…
- **Zakaj odlična persona:** eno glavno območje + veliko **ponavljajočih** opravil +
  želja po **zgodovini in primerjavi** → idealen "logger". Aplikacija jih opremi za
  beleženje + lastno učenje; *kdaj* jim najbolje odgovori **percentil okolice** (§8),
  ne predpisni nasvet. Mejo do svetovanja/diagnostike glej 6.7 in 7 (zaenkrat zunaj).

## 4. Zakaj sploh? (tržna vrzel)

Trg ni prazen, je pa razdeljen na ločene segmente:
- **Nega rastlin / dnevnik:** Gardenize, GrowNotes, Planta, PlantIn, Planter...
- **Nega trate (večinoma ZDA):** Yard Mastery, Lawn Care Journal, My Lawn (Scotts)...
- **Splošna vzdrževalna opravila:** Home & Garden Task Tracker...
- **Hiperlokalna skupnost (prej):** GrowIt! (1M+ uporabnikov) — a fokus na
  *odkrivanje rastlin*, ne evidenco; danes ni več vodilni.
- **Vreme:** Weather Channel Home & Garden Forecast — a ZDA/USDA, brez zgodovine/skupnosti.

**Naša ločnica = sinteza, ki je nihče ne dela:** osebni dnevnik opravil + vreme +
osebna zgodovina (+ kasneje hiperlokalna H3-skupnost), z **evropsko/globalno**
pokritostjo in za **celotno posest** (trata + meja + gredice + zasaditve).

## 5. Arhitektura v dveh plasteh (cold-start strategija)

Skupnostne funkcije zahtevajo gostoto uporabnikov → na začetku bi bile prazne.

| Plast | Vrednost | Odvisnost |
|------|----------|-----------|
| **1. Solo (v1)** | Osebni dnevnik + opomniki + vreme + lastna zgodovina | ❌ deluje že za 1 uporabnika |
| **2. Skupnost (v2)** | H3-agregirani signali sosedov, primerjave | ✅ potrebuje gostoto |

**Odločitev:** zaženemo s plastjo 1; plast 2 se "prižge", ko zraste gostota.

---

## 6. v1 (solo) — obseg

### 6.1 Podatkovno jedro
> 📋 **Privzeti tipi opravil + kurirani katalog rastlin** (in matrika, katere rastline
> se tičejo katerih opravil): ločena datoteka **[`opravila-in-rastline.md`](opravila-in-rastline.md)**.

- **Vnos opravila** = **kaj (tip opravila) + kdaj (datum)** + območje +
  *(neobvezna opomba, npr. "100g uree na 16l")* + samodejni vremenski posnetek.
- **Opomnik / todo** = **kaj + kdaj** + *(neobvezna opomba)* + push obvestila.
- **Opombe / prosto besedilo** — dnevniški zapisi poleg strukturiranih opravil.
- **Zaloge sredstev** — kaj imam doma (urea, alge, gnojila...).
- Foto izpuščeno v v1.

Območja so temelj (trata, meja, gredice...), na katera se vežejo vreme, zgodovina
in kasneje H3-skupnost.

### 6.2 Pogledi (isti podatki, dve plati)
- 📅 **Koledar / časovnica** (privzeti vstop) — "kaj sem počel in kdaj", letni vzorci.
- 🗺️ **Po območjih** — zgodovina posameznega kosa posesti.

### 6.3 Ključni zasloni (osnutek — UI/UX dorečemo kasneje)
1. 📅 Koledar / časovnica (privzeti)
2. 🗺️ Pogled po območjih
3. ➕ Hiter vnos opravila — **maksimalno preprost** (kaj + kdaj, par dotikov)
4. 🔔 Opomniki / todo (kaj + kdaj + opomba + obvestila)
5. 🌦️ Domov / kontekst (vreme + pametni opomniki)
6. 📦 Zaloge sredstev (urea, alge, gnojila...)
7. 📝 Opombe / dnevnik
8. ⚙️ Upravljanje območij (ime, tip, rastline znotraj — **brez lokacije**)
9. 🔐 Prijava · 👤 Nastavitve/profil (ena lokacija, jezik) · 📅 Mesečni pregled

### 6.4 Opomniki
**Tipi:**
- Ob določenem **času v dnevu** (npr. jutri 6:00).
- **Sezonsko / datumsko** (npr. vsako pomlad).
- **Ponavljajoče** (npr. obrez meje 2×/leto).
- *(kasneje)* **"ko bo vreme primerno"** — vezano na vremensko okno.

**Push obvestila na telefon — OBVEZNO za v1** (po vzoru Google Koledarja):
- Nastavljiv **zamik** pred dogodkom (npr. 1 dan prej, 2 uri prej, ob dogodku).
- Nastavljiva **ura** obvestila (npr. 1 dan prej ob 18:00).
- Možnost **več obvestil** na en opomnik.
- Tehnično: push servis + dovoljenja na napravi + lokalno razporejanje
  → upoštevati pri izbiri tehnologije.

### 6.5 Pametna plast (ločnica)
- **Vremenski kontekst:** lokalna napoved + preprost nasvet ("nocoj dež → odloži gnojenje").
- **Osebni zgodovinski opomnik:** "Lani 18. maja ste gnojili trato. Mešanica: X."
- **Ponavljajoča opravila** z opomniki.

### 6.6 ✅ V1 vključuje
Evidenca opravil (kaj+kdaj+kje) · območja · 2 pogleda (koledar + območja) ·
lokalno vreme · osebni zgodovinski opomniki · opomniki/todo (kaj+kdaj+opomba) ·
**push obvestila (nastavljiv zamik + ura, kot Google Koledar)** ·
prosto besedilo / opombe · beleženje zalog sredstev · ponavljajoči opomniki.

### 6.7 ❌ V1 namenoma NE vključuje (→ kasneje)
- **Foto** (izpuščeno zaenkrat).
- **AI svetovalec** za odločanje ("ni nujno, izpustimo v tem koraku").
- **Avtomatski kalkulator mešanic** — v1 le ročna opomba v polju
  (npr. "100g uree na 16l"); avtomatski izračun kasneje.
- Skupnost / H3 sosedje, primerjave, izmenjava med uporabniki.
- AI prepoznava rastlin, baza rastlin, priporočilni motor.
- Profesionalne / B2B funkcije.

---

## 7. Wishlist / kasneje (zbiramo sproti)

> Ključni vpogled: aplikacija ni le **pasiven dnevnik**, ampak tudi **pomočnik pri
> odločanju**, ki ustvari *zabeležen* todo:
> **vreme + rastlina + sredstvo → nasvet → todo z opomnikom → log.**

### Referenčni scenarij (user story)
> "Danes dežuje, jutri sonce, nato spet dež. Ali in kdaj naj folirano poškropim
> lovorikovce in trato z ureo + morskimi algami? Kakšno mešanico naj pripravim
> za 16 l škropilnico? In naredim si todo/opomnik s časovnim oknom."
> → Sklep: jutri zjutraj oboje.

### Funkcije za kasneje
- **Pomočnik pri odločanju (ali/kdaj)** za vremensko-občutljiva opravila.
- **Agronomski nasvet** vezan na rastlino + sredstvo.
- **Kalkulator mešanice/odmerka** glede na opremo (npr. 16 l škropilnica).
- **Profili opreme** (škropilnice in volumni) za personalizirane izračune.
- **Profili sredstev** (povezano z zalogami in "katero mešanico sem uporabil lani").
- **Foto-zgodovina** (rast, bolezni skozi čas).

### ⚠️ Tveganja (za kasneje)
- **Točnost agronomskih nasvetov:** napačen odmerek lahko poškoduje rastline →
  nasveti morajo temeljiti na **zanesljivih virih/etiketah**, ne na halucinacijah AI;
  jasen disclaimer.
- **Push obvestila:** odvisnost od dovoljenj/zanesljivosti na napravah.

---

## 7.7 Arhitekturne odločitve (2026-06-01, 2. krog)

### Območja — model (max 2 nivoja)
```
OBMOČJE (vsebnik: ime · tip)        ← BREZ lastne lokacije!
   └─ RASTLINE/OBJEKTI znotraj (jablana, paradižnik, lovorikovec...)
```
Opravilo se veže na rastlino *znotraj* območja (npr. obrez → jablana v Sadovnjaku).
Pri trati subjekta ni (območje = subjekt). Brez globljega gnezdenja.

**POPRAVEK (prej napačno):** območja NIMAJO svoje lokacije/vremena. Vsa so na isti
posesti, le nekaj metrov narazen (živa meja spredaj, jablana zadaj) — razlika v
vremenu zanemarljiva. Lokacija je lastnost **profila** (glej spodaj).

**Dimenzija izpostavljenosti — `protected` (10. krog):** območje ima neobvezno zastavico
**`protected`** (zaščiteno) in nova tipa **Rastlinjak** in **Notranji prostor** (okenska
polica, klet z lučjo); privzeto `protected=true`. To NE podre zgornjega (lokacija ostane
ena, profilna — rastlinjak je na isti posesti, isti pozebni datumi za *načrtovanje*).
Doda le **pravokotno dimenzijo izpostavljenosti**: zaščitena območja motor **izvzame iz
vremenskih straž** (dež/pozeba ne dosežejo sadik v hiši), **frost-anchor pa ostane** (bistvo
predsetve je priti pred pozebo). Zastavica (ne le tip) omogoča tudi delno zaščito (topla
greda, folija). Omogoči **vzgojo sadik** (predsetev → … → presaditev na prosto) — glej
`opravila-in-rastline.md` A.3 in `pametni-motor.md` §2.

### Lokacija & profil
- **Ena sama lokacija = lastnost uporabnikovega profila.** Iz nje izhajata lokalno
  vreme in (V2) **H3-celica**. Vsa območja podedujejo to lokacijo.
- v1: shranimo uporabnikovo lokacijo (za vreme). H3 izpeljemo kasneje.
- V2 H3-resolucija (popravljeno 8. krog): **res-7** (~5 km², vas/soseska) je
  **najfinejša prikazana** raven. **res-8** (~0,7 km²) je **preveč granularno /
  identificirajoče → opuščeno** (prej napačno zapisano kot "adaptivno navzdol na res-8").
  Točko lahko hranimo natančno (zasebno, na napravi), a navzven nikoli pod res-7.
  Za iskanje sosedov/opravil v širši okolici **agregiramo NAVZGOR** na starševski
  **res-6** (~36 km²) in **res-5** (~252 km²), ko je gostota pri res-7 premajhna
  → cold-start rešujemo z roll-upom v grobejše celice, ne s prefino delitvijo.

### Prijava / avtentikacija
- **Primarno:** Apple + Google (en dotik, oblačna sinhronizacija, brez gesla;
  Apple obvezen na iOS, če je social login).
- **Sekundarno:** e-pošta + **potrditvena koda (OTP, brez gesla)**.
- **"Preizkusi brez računa":** lokalno, z opozorilom "podatki le na napravi" +
  **brezšivna nadgradnja** v račun (ob prijavi se lokalni podatki naložijo).
- Vrednost = večletna zgodovina → uporabnika spodbudimo k računu zgodaj, a ne blokiramo.
- GDPR: minimalni podatki, izvoz/izbris.

### Zaloge ↔ opravila
- Pri gnojenju/tretiranju/škropljenju neobvezen razdelek **Sredstva** (izdelek + količina).
- **Shranjene mešanice (recepti)** vezane na opremo (npr. "100g urea + 50ml alge / 16l").
- Ob shranjevanju → **odpis iz zaloge** + opozorilo "malo".
- v1 = ročna izbira / recept + preprost odpis. Avtomatski preračun volumna → v2.
- **Status (2026-06-08):** Sredstva/zaloge so **začasno skrite** pred MVP releasom prek konstante
  `kSuppliesEnabled=false` (`core/config.dart`) — preskočen korak »Sredstva« v čarovniku (§7.16) in
  skrita sekcija v Nastavitvah; koda ostane za kasnejšo vključitev (flip na `true`).

### Večjezičnost — ⭐ KANONIČNI ID + i18n (od dne 1)
- Opravila in rastline shranjeni kot **kanonični ID-ji** z oznakami {sl, de, en, ...},
  NE kot prosto besedilo. UI prikaže v uporabnikovem jeziku; podatki jezikovno nevtralni.
- Proste opombe ostanejo nepreverjene.
- **Zakaj:** omogoča V2 čezmejno primerjavo (MOW = Mähen; paradižnik = Tomate),
  npr. ob meji z Avstrijo. Brez tega geolokacijska primerjava pade.
- Ob zagonu jeziki: **SL + EN + DE**; dodatni = nova prevodna datoteka.

### Katalog vrst rastlin — hibrid v plasteh + NADZOR (governance)
> 📋 Konkreten osnutek kataloga (vrste + tipi opravil + i18n): [`opravila-in-rastline.md`](opravila-in-rastline.md).
- **v1:** kurirana lokalna baza ~100–200 pogostih srednjeevropskih vrst (kanonični
  ID + SL/EN/DE) + **"+ po meri"** (prosto, uporabnikova vrsta).
- **kasneje:** AI pomoč (preslikava prostega imena → kanonično, foto-prepoznava, predlogi).
- NE AI v v1 (halucinacije/strošek), NE zunanji plant-API ob zagonu (latenca/licence);
  bazo lahko seedamo iz Wikidata/GBIF z atribucijo.
- Pri vnosu: ponudi najprej rastline izbranega območja → iskanje po bazi → "+ po meri".

**Nadzor proti nenadzorovanemu dodajanju vrst (svetovne baze ne moremo imeti):**
1. Kurirana baza je **privzeta** pot (iskanje med tipkanjem).
2. "Po meri" je dovoljeno, a **drugorazredno**: shrani se kot **zasebna uporabnikova
   vrsta** (brez kanoničnega ID), **NE sodeluje v H3/skupnosti** (lastni izrazi se ne
   morejo ujemati med uporabniki/jeziki) — jasno označeno.
3. **Najprej predlog iz baze** ("Ali ste mislili: paradižnik?") prepreči podvojitve.
4. **Rast baze pod nadzorom:** pogosti lastni izrazi → naš pregled → dodamo v kurirano
   bazo s kanoničnim ID + prevodi (surovi nizi ne gredo v skupne podatke).
5. Vsak lastni vnos zahteva **kategorijo** (sadno drevje / zelenjava / ...).

**Življenjski cikel lastnega izraza (zajem → skupni ID):**
- **Nianса:** večina "po meri" izrazov NI nova vrsta, ampak **drug zapis/sinonim**
  obstoječe ("paradajz" → Paradižnik). Baza ima zato **sloj aliasov/sinonimov po
  jezikih**, ki kažejo na kanonični ID. Promocija = večinoma "dodaj alias".
- **Tok:**
  1. **Zajem** → zasebno (lokalni ID, surovi tekst, jezik, kategorija).
  2. **Sinhronizacija** (če račun) → na strežnik, **anonimizirano** (brez identitete v katalogu).
  3. **Agregacija/rang** → normalizacija (male črke, brez šumnikov, trim) + mehko
     ujemanje (Levenshtein, sinonimi); štejemo različne uporabnike.
  4. **Pregled (mi + AI-predlog):** obstoječa vrsta → dodaj **alias**; nova vrsta →
     nov **kanonični ID** (znanstveno ime + i18n); smeti → zavrzi.
  5. **Objava** → katalog delta v aplikacije.
  6. **Povratna vezava ⭐** → obstoječi zasebni vnosi se nadgradijo na kanonični ID
     (retroaktivno vstopijo v skupni prostor / V2). UX: "'paradajz' je zdaj
     prepoznan kot Paradižnik 🌍."
- **Proti šumu:** predlog iz baze že ob vnosu ("Ali ste mislili: …?") + mehko
  ujemanje + tabela sinonimov + (kasneje) AI.
- **Zasebnost:** agregiramo le niz + števce, nikoli vezano na osebo; razkrito v
  politiki zasebnosti.
- **Kuracijska vrsta = interno zaledno orodje** (ni del MVP aplikacije, ni wireframa).

**Osebni alias — uporabnik obdrži svoje ime ⭐:**
- Dva ločena nivoja aliasa:
  - **osebni alias** — vidi le ta uporabnik (npr. "paradajz", narečno ime); ostane;
  - **globalni sinonim** — v katalogu, izboljša ujemanje za vse.
- Model: rastlina pri uporabniku = `{ kanonični ID, osebni alias (neobvezno) }`.
  - **Prikaz** = osebni alias (če obstaja), sicer kanonična oznaka v uporabnikovem jeziku.
  - **Skupnost/V2** vedno uporablja kanonični ID.
- Ob promociji se nič ne "popravi pred nosom": uporabnik vidi svoj izraz, z diskretno
  oznako 🌍 (prepoznan/povezan, šteje v okolico). Spoštujemo narečna/osebna imena,
  ohranimo ujemanje v ozadju.

### Vreme — vir in beleženje
- **Vir: Open-Meteo** (brezplačen, brez ključa, EU; napoved + zgodovina + temp/vlaga tal
  + ET0 + urne padavine). Kasneje opcijsko ARSO za SLO.
- **Vremenski posnetek ob opravilu** (strukturiran, ne le trenutek):
  - ob opravilu: temp, padavine danes, vlaga, veter, stanje;
  - nazaj 24–48 h: koliko dežja (relevantno za škropljenje);
  - napoved 24–72 h: dež/temp naprej (npr. "2 dni dež → granularni počasi-spr. NPK");
  - opcijsko: temp tal, ET0.
- Bogat posnetek za opravila s sredstvi; lažji za ostala.

### Splash / brand
- Logo: **list znotraj šesterokotnika (H3-celica)** — poveže znamko z bodočo skupnostjo.
  Wireframe: `docs/wireframes/00-splash.html`. Ime na splashu: **Tendask**.
- **Brand POTRJEN (2026-06-01) → [`docs/brand/brand.md`](brand/brand.md)** (+ predoglede `docs/brand/`):
  smer D (uravnotežena). Logo = organski **list v šesterokotniku BREZ kljukice** (kljukica je
  tekmovala z listom + slabšala drobno berljivost; žila ostane subtilna). Paleta = obstoječa zelena
  `#2e7d32` + globoka `#205A28` + svetla `#3a9a57` + **medena `#E0A82E`** (redek topel poudarek).
  Tipografija = **Plus Jakarta Sans** (en sklad, 400–800; SL/DE znaki). Asseti = SVG v `docs/brand/assets/`
  (logomark color/mono/white + app-icon + adaptive foreground); PNG ikone prek `flutter_launcher_icons`.

---

## 7.8 Model opravil/opomnikov, akcije, regije (4. krog)

### Opravilo/opomnik se veže na RASTLINO (ne le območje)
```
Opravilo = { tip · DATUM · status · sredstva · vreme · opomba · SUBJEKTI[] }
SUBJEKT  = rastlina ALI območje   (M:N — POPRAVEK 2026-06-03, glej §7.15)
```
- Vsak **tip opravila** ima zastavico `zahtevaSubjekt`: obrez/tretiranje/pobiranje/
  sajenje/okopavanje → **da** (pokaže izbirnik rastline); košnja/zalivanje trate → ne.
- **Zakaj:** maline in jablana sta v istem območju, a ju obrezuješ ob različnem času →
  "obrez malin" in "obrez jablane" morata biti ločena zapisa. Tako se baza pravilno
  poveže + smiselna zgodovina + V2 ujemanje po vrsti.

### Status opomnika + akcije
- Status: `načrtovano → opravljeno / preloženo / preklicano`.
- "Opravljeno" lahko samodejno ustvari **zapis v dnevnik** (s sredstvi/vremenom).
- Prikaz statusa v seznamu: jutri/ura, **zamuja** (rdeče), ponavljajoče.

### Vzorec akcij/urejanja — POVSOD enak
- **Povleci levo** = 2 najpogostejši (✓ Opravljeno, ⏰ +1 dan).
- **⋯ / dolg pritisk** = akcijska plošča (Opravljeno+v dnevnik, +1 dan, Premakni na
  datum, Uredi, Podvoji, Izbriši).
- Enako za: opomnike, vnose v dnevnik, območja, zaloge. Wireframe: `14-actions.html`.

### Setveni koledar po regijah (po-MVP)
- Sezonska okna so odvisna od **klime**, ne države.
- Iz profilne lokacije izpeljemo **klimatski koš** (polobla + Köppen cona / širinski
  pas + datum zadnje/prve pozebe iz Open-Meteo normalov). Predlogi kurirani po košu.
- **Polobla obrne koledar** (j. polobla +6 mesecev).
- Podatki **ključeni po regiji** od začetka te funkcije. Za MVP le označen placeholder.

### Lokacija — poljudno + zasebno
- **res-7** (~5 km²) = najfinejša prikazana raven (res-8 prefina/opuščena); pri redki
  gostoti **agregiramo navzgor** na res-6/res-5 (glej 7.7, 8. krog). V UI **brez žargona H3**.
- Besedilo: "Lokacijo uporabljamo le za približno določitev tvoje okolice; tvoja
  točna lokacija ni nikoli razkrita."
- Ob dovoljenju **dve poti**: GPS **ali** ročni vnos kraja (vas/mesto/naslov,
  neobvezno) → geokodiramo v okolico. Wireframe: `16-location.html`.
- **Prenova (2026-06-08, wireframe `16b-location.html`):** zaslon ima **dva vstopa** — iz Nastavitev
  (back gumb, izbira se **samodejno shrani** + toast, brez spodnjega gumba) in iz onboarding/prijave
  (brez back, gumb »Nadaljuj« → Domov). Zgoraj **statusni pas** pokaže, ali je lokacija že nastavljena.
  Gumb **»Odstrani lokacijo«** (le ko je nastavljena) s potrditvijo počisti koordinate (device-local) +
  H3 celice v profilu → vreme pade na privzeto območje (`clearGardenLocation`).

### Onboarding
- 3–4 drsniki (Dobrodošel · Hitro beleženje · Opomniki+vreme · (V2) Okolica) z
  možnostjo **Preskoči vse**. Wireframe: `15-onboarding.html`.

---

## 7.9 Poenotenje: OPRAVILO je ena entiteta (5. krog) ⭐

Pomembna poenostavitev: ne ločujemo "opravilo" vs "opomnik". Obstaja **ena entiteta**:
```
OPRAVILO = { tip · SUBJEKTI[] (rastlina ALI območje, M:N — §7.15) · DATUM (preteklost/prihodnost) ·
             STATUS (čaka / opravljeno) · sredstva · vreme · opomba ·
             OPOMNIK = obvestila (NEOBVEZNO) · ponavljanje? }
```
- Beležim *kar sem naredil* → datum danes/preteklost, status **opravljeno** (dnevnik).
- Načrtujem → datum v prihodnost, status **čaka**, po želji dodam **opomnik** (obvestilo).
- **Opomnik je le neobvezen dodatek** (opozorilo za prihajajoča/zapadla opravila).

**IA posledica:**
- Zavihek **"Opomniki" → preimenovan v "Opravila"** (☑️): prihajajoča + zapadla
  opravila, ki čakajo; 🔔 = ima opomnik.
- **Dnevnik** (📅) = kaj sem naredil (preteklost). **Opravila** (☑️) = kaj me čaka.
- Vstop = **en horizontalni stepper** (§7.16), ki nadomesti nekdanja 02 Hiter vnos
  in 07 Novo opravilo (status + subjekti + opomnik + sredstva v enem flowu).
- **Vrstni red zavihkov (2026-06-03):** Domov · **Opravila** · Dnevnik · Vrt —
  Opravila (dnevna akcija) naprej, Dnevnik (zgodovina) za njim, Vrt (struktura) na
  koncu. **FAB ＋ (vnos) le na Domov + Opravila** — Dnevnik je bralni zgodovinski
  pogled (brez ＋); Opravila izgubi ＋ v AppBar (nadomesti ga FAB).
- **Bottom nav = vedno root (2026-06-04):** tap na zavihek vedno odpre njegov osnovni
  zaslon (reset sklada, `goBranch(initialLocation: true)`) — odprt detajl/entiteta se
  ob preklopu med zavihki ne ohrani.

**Mesečni koledar (2026-06-04):** tap na dan **izbere dan** in spodaj izlista njegova
opravila + ponudi »Dodaj na ta dan« (prej tap = takoj nov vnos).

**Domov (2026-06-08):** opravila na Domov kažejo **rastlino-subjekt** (🪴, enako kot zaslon
Opravila). **Zamujena** (pretečena, nedokončana) opravila so v **strnjenem rdečem pasu**, ki se ob
kliku razširi v seznam na mestu (prej se zamujena na Domov sploh niso prikazala). Wireframa
`01b-home-overdue-collapsed.html` + `01b-home-overdue-expanded.html`.

---

## 7.10 Detajl opravila + opombe = vrtni dnevnik (8. krog)

### Detajl opravila = BRALNI pogled ⭐
- Tap na opravilo (v Dnevniku/Opravilih) → **bralni** detajl; urejanje = gumb
  **Uredi → 07** (ena oblika obrazca, brez podvajanja). ⋯ v glavi = univerzalna
  akcijska plošča (14).
- **Bogat vremenski posnetek v 3 pasovih** (osrednja ločnica):
  1. **ob izvedbi** (temp, veter, vlaga, padavine, temp. tal, ET₀),
  2. **24–48 h nazaj** (poudarjen dež — ključno za škropljenje),
  3. **napoved 24–72 h naprej** (mini-dnevi + agronomska poanta).
- **Dve stanji** (isti zaslon se prilagodi):
  - **čaka** (`17-task-detail.html`): pas 1 = *napoved*; akcije ✓ Opravljeno · +1 dan ·
    Uredi · Podvoji · Izbriši.
  - **opravljeno** (`17b-task-detail-done.html`): pas 1 = **zamrznjen DEJANSKI posnetek**,
    zajet ob izvedbi (Open-Meteo) in trajno shranjen; akcije Uredi · Podvoji · Premakni ·
    ↩ Na čaka · Izbriši.
- Vključen **zgodovinski namig** ("Lani … si …") — lastna zgodovina.

### Opombe = en združen "vrtni dnevnik"
- Odločitev: prosto besedilo nastane **na dva načina**, oboje pristane v **istem dnevniku**:
  1. *opomba na opravilu* (polje v 02/07/17),
  2. *samostojna opomba* — entiteta `{ datum · besedilo · območje? · rastlina? · vreme }`;
     samodejni vremenski posnetek (koristno ob opažanjih bolezni/rasti).
- **Dnevnik (03) = vrtni dnevnik**: opravljena opravila + opombe pomešano po datumu;
  opombe imajo ✍️ ikono; filter **Vse / Opravila / Opombe**.
- Vstop za samostojno opombo: iz **Hitrega vnosa** (✍️ kartica) ali tap v dnevniku → 18.
  Pravilo **FAB ＋ = Hiter vnos** (opomba je veja, ne 5. zavihek). FAB je na **Domov + Dnevnik**
  (Območja in Opravila imata lastne akcije za dodajanje; FAB bi prekrival vsebino/akcijske liste —
  popravek iz ročne preverbe M3.7).
- Wireframe: `18-note-edit.html`. Če opombo navežeš na rastlino, se pokaže v njeni zgodovini.

### Skupni pregled flowa — popravki neskladij (8. krog)
- Poenoteno **tikanje** (prej dva pametna namiga vikala: 01, 05).
- Klikabilna kartica Opombe (Domov → 18); 05 ⋯ → 14; 12 Spremeni → 16.
- Usklajena **sredstva + območja** opravila med 06 ↔ 07/17 (urea+mospilan+galica · Živa meja + trata).
- **Vremenska kontinuiteta**: ista vremenska zgodba (danes/tor dež + nocoj → jutri/sre
  suho → čet/pet rahel dež) povsod (Domov 01, Opravila 06, Detajl 17/17b).
- Vse interne povezave preverjene (veljavne); ostankov vikanja ni.

### Manjše točke (zavestno odprto)
- 07 naslov "Novo opravilo" ostane tudi pri urejanju (17→07) — lahko kontekstno "Uredi opravilo".
- 04: klikabilna le ena območna kartica (vzorec); 05 prikazuje "~120 m²", a 09 nima polja za velikost.
- 10 (izbirnik) se v wireframu vedno vrne na 09 (ni zgodovine).

---

## 7.11 Tehnološka izbira (POTRJENO — 2026-06-01)

> 📋 **Polni implementacijski dokument: [`tech-stack.md`](tech-stack.md)** (paketi, struktura projekta,
> offline-sync arhitektura, vrstni red postavitve, konvencije za AI agenta). To poglavje = povzetek.
>
> **Vodilo izbire:** kodo piše **AI agent (Claude Code)**, uporabnik je Flutter-noob → izberemo
> **najbolj mainstream/dokumentirane** tehnologije (AI ima največ primerov → najmanj napak).
> **+ 0 € dodatnih stroškov v razvoju in MVP.**

- **Flutter** (iOS + Android, en codebase). **State management = Riverpod** (s code-gen; najbolj
  razširjen, tip-varen, dolgoročno najboljši). Routing = `go_router` (deep-link za obvestila).
- **Lokalna baza = drift (SQLite)** kot offline vir resnice. **Sync = ročni push/pull** (BREZ
  zunanje storitve → 0 €; PowerSync/Electric IZLOČENA zaradi stroška). MVP enouporabniški →
  preprost LWW po `updated_at`, brez razreševanja konfliktov.
- **Supabase = edino zaledje:** Postgres (relacijski model), **Auth** (Apple/Google/e-pošta OTP/
  anonimno + linkanje — "brez računa → nadgradnja"), **RLS** za zasebnost, izvoz/izbris (GDPR).
- **Firebase = SAMO FCM, ODLOŽENO** (šele plast B/po MVP → prvi MVP brez Firebase). Crash = **Sentry**.
- **Open-Meteo** klientsko, brez ključa (0 € backenda za vreme). HTTP = `dio`. i18n = `slang` (sl/en/de).
- **H3 na napravi** (`h3_flutter`): celico (res-7) izračunamo lokalno, shranimo **samo celico, nikoli
  surovih koordinat** → zasebnost vgrajena. Roll-up res-7→6→5 server-side (navaden `GROUP BY`).
- **Stroški MVP = 0 €** (Supabase/Open-Meteo/Sentry/GitHub free); ob objavi ~25 $/mes Supabase Pro +
  Apple 99 $/leto + Google 25 $ enkratno. Percentili (V2) = paketna agregacija (cron) → poceni.

## 7.12 Obvestila — taksonomija + vodenje ⚠️ (zasloni manjkajo)

**Vrzel (REŠENO — zasloni dodani 19–22):** prej so wireframi imeli le *nastavitve* (07, 12).
Dodano: **19** izbirnik "Dodaj obvestilo" (zamik + ura), **20** videz obvestil (3 vrste na
zaklenjenem zaslonu), **21** prošnja za dovoljenje (priming po vrednosti), **22** nastavitve
obvestil (vrste · privzeti zamik · tihe ure · frekvenčna kapica). Povezave: 07 → 19, 12 → 22.
Odprto ostaja le **in-app nabiralnik (da/ne)**.

### Tri vrste obvestil
1. **Opomniki opravil** — *lokalna* obvestila (deterministična, delujejo offline), nastavljiv
   zamik (ob dogodku / 2 h prej / 1 dan prej / po meri) + ura, več na opravilo.
   Tehnično: `flutter_local_notifications`. Tap → Detajl opravila (17).
2. **Pametni namigi (vreme)** — *strežniški* (FCM), opt-in: "jutri suho — primeren čas".
   Zdaj kot pas na Domov (01) + stikalo v 12.
3. **Namigi okolice / skupnosti (V2)** — *strežniški* (FCM), opt-in, vezani na percentile §8:
   npr. **"X % v tvoji okolici je ta teden gnojilo z algami"**, "sosedje sadijo paradižnik".

### Vodenje proti motečnosti (da ne odvrne uporabe)
- **Granularni opt-in po vrsti** (opomniki / vreme / okolica ločeno).
- **Tihe ure** + **frekvenčna kapica** (npr. max 1 ne-opomnik na dan, sicer skupni "digest").
- Skupnostni/vremenski namigi privzeto **zmerni**; uporabnik lahko poostri ali ugasne.
- Vsako obvestilo **globoko poveže** na ustrezni zaslon (deep link).

### In-app nabiralnik? → REŠENO: pas na Domov
- Pametni predlogi (plast B) živijo na **pasu na Domov (01)** z gumboma Načrtuj/Opusti.
  Poseben center obvestil zato (zaenkrat) ne rabimo; push je le opozorilo, dom je Domov.

---

## 7.13 Pametni predlogi = sistemska obvestila (plast B) — PRAVILNI MOTOR

> 📋 **Implementacijski načrt (koraki + inventar podatkov po virih + sloj agronomskih pravil
> rastlin): [`pametni-motor.md`](pametni-motor.md).** To poglavje = koncept; ta datoteka = roadmap.

> **Dve ločeni plasti obvestil** (da ne mešamo):
> - **A) Opomniki** — *uporabnik* jih nastavi na opravilu (zasloni 19–22). Lokalni, deterministični.
> - **B) Pametni predlogi** — *sistem* jih sam ustvari ("jutri suho → škropi"). Strežniški. ← to poglavje.

### Kako zaganjati (izvedba)
- **Dnevni paketni pregled na strežniku** (cron, npr. 6:00 po uporabnikovem času):
  1. potegni območja/rastline + zgodovino opravil, 2. vreme za H3-celico (Open-Meteo),
  3. ovrednoti pravila, 4. filtriraj + rangiraj, 5. pošlji top 1 prek **FCM** (ali dnevni digest).
- Poceni (paketno, periodično). **Brez AI — kurirana pravila** iz zanesljivih virov (skladno z odločitvijo "brez AI").

### Anatomija pravila
`SPROŽILEC (kdaj) + KONTEKST (vreme/zgodovina/sezona) + STRAŽE (kdaj NE) + sporočilo + akcija + ocena`
Primer "jutri suho + lani 18. maja gnojil" = **dva signala združena** (vremensko okno + osebna obletnica) → predlog z akcijo "Načrtuj".

### Vodenje — proti podvajanju in gnjavljenju (bistvo)
| Skrb | Pravilo |
|---|---|
| "Včeraj sem že gnojil" | **Cooldown po (območje+rastlina+tip)** — utišaj, če opravljeno v zadnjih N dneh / še ni spet na vrsti |
| "3 dni dežuje → ne pošlji kosit" | **Vremenske pred- IN proti-pogoji** — košnja zahteva suho+rast; utišaj ob dežju/mokri travi/napovedanem dežju |
| Podvajanje | **`zadnjič_predlagano` po (pravilo+subjekt)** — isti predlog max 1× na X dni |
| "To že imam načrtovano" | **Dedup proti obstoječim opravilom** |
| Spoštuj "Opusti" | **Spomin na zavrnitev** — Opusti = daljša utišitev; "ne predlagaj tega" = ugasni pravilo |
| Zasipavanje | **Frekvenčna kapica + digest** (max 1/dan), rangiraj po oceni (stikalo v 22) |
| Nesmiselno | **Upravičenost** — le za območja/rastline, ki jih ima (košnja le, če ima Trato) |

### Kje živi + povratna zanka
- **Push (FCM)** ob pomembnem/pravočasnem; **pas na Domov (01)** = dom predlogov, gumba **Načrtuj** (ustvari načrtovano opravilo) / **Opusti** (utiša). Povratna informacija uravnava utišanja.

### Obseg (da ne razneseva MVP)
- **MVP: 3–4 visoko-vredna pravila** — (1) vremensko okno za škropljenje/foliarno, (2) "lani tačas si…",
  (3) zapadlo opravilo, (4) *(neobvezno)* sezonsko okno iz klimatskega koša.
- **V2: skupnostni/percentilni predlogi** ("68 % v okolici je gnojilo") — rabijo gostoto (§8).

---

## 7.14 Podatkovni model (osnutek za Supabase)

> Klasičen relacijski model, **nizka–srednja kompleksnost**. Posebnosti reši Postgres
> (JSONB, NULL-able FK + CHECK, pomožne tabele, cron-agregat). Vir za seed = `opravila-in-rastline.md`.

**Pomembno:** `opravila-in-rastline.md` **ni živa povezava** z bazo — je **vir za seed**
(`seed.sql`: tipi opravil + matrika + vzorčne rastline; večji nabor rastlin iz Wikidata/GBIF).

### Tabele (osnutek)
- **Katalog (skupno, samo-branje):**
  `task_type(id PK, labels jsonb{sl,en,de}, icon, category, requires_subject bool, weather_sensitive bool, seasonal bool, default_cadence)` ·
  `plant(id PK, labels jsonb, scientific_name, category, icon)` ·
  `plant_synonym(id, plant_id FK, lang, text_norm)` · `category_task_type(category, task_type_id)`.
- **Uporabnik (RLS `user_id = auth.uid()`):**
  `profile(user_id PK, h3_r7, h3_r6, h3_r5, climate_bucket NULL, climate_profile jsonb NULL, timezone NULL, lang)` —
  celice + **grob javni** `climate_bucket` (NE koordinat/višine); `climate_profile` = bogat **owner-only** klimatski nabor (frost-anchor ipd., nikoli v javni agregat); `timezone` (IANA) za strežniško lokalno-časovno logiko ·
  `area(id, user_id, name, type)` — brez lokacije ·
  `user_plant(id, user_id, area_id FK NULL, plant_id FK NULL, custom_name NULL, personal_alias NULL, is_custom)` ·
  `task(id, user_id, task_type_id FK, date, status, note, weather jsonb, recurrence jsonb, agg_context jsonb NULL)` — OPRAVILO (subjekti v `task_subject`); `agg_context` = zamrznjen posnetek veder ob `done` (h3 r7/6/5 + climate_bucket) za skupnostni agregat ·
  `task_subject(id, task_id FK, user_plant_id FK NULL, area_id FK NULL, CHECK ≥1)` — M:N subjekti opravila (§7.15) ·
  `task_reminder(id, task_id FK, offset, time)` — plast A ·
  `note(id, user_id, area_id NULL, user_plant_id NULL, date, text, weather jsonb)` ·
  `supply` · `recipe` · `task_supply(task_id, supply_id, amount)` — zaloge/odpis ·
  `suggestion_log(user_id, rule_id, subject_key, last_suggested_at, dismissed_until)` — plast B.
- **V2 agregat (cron → tabele, javno-bralne — samo cron piše; podroben model v
  [`skupnost-agregacija.md`](skupnost-agregacija.md)):** tri metrike, vse `bucket_key` = H3 celica
  (res-7/6/5) **ali** `climate_bucket`:
  - `activity_recent(resolution, bucket_key, task_type_id, plant_id NULL, distinct_users_7d, refreshed_at)` — feed (drseče 7-dnevno okno);
  - `activity_season(resolution, bucket_key, task_type_id, plant_id NULL, year, iso_week, first_user_count, publishable)` — časovni percentil (CDF prvih izvedb);
  - `activity_frequency(resolution, bucket_key, task_type_id, plant_id NULL, season_year, n_users, per_user_p25/p50/p75, unit)` — frekvenca (mediana+IQR).
  RLS: `grant select to anon, authenticated` + k-anonimnost (`K_privacy=5`); prikaz številke ob `K_reliab=30`. Anti-junk:
  `distinct_users` (ne opravil), `is_custom` izločen, zrelostni filter. Glej §8 + `skupnost-agregacija.md`.

### Posebnosti → rešitev (kompleksnost)
| Posebnost | Rešitev | Kompl. |
|---|---|---|
| Kanonični ID + i18n | `labels jsonb`; app bere `labels[lang]` | 🟢 |
| `zahtevaSubjekt` | bool + `user_plant_id` NULL + pogojni UI | 🟢 |
| Kuriran vs lasten (zaseben) | FK na katalog **ali** `is_custom`+ime; CHECK | 🟢 |
| Osebni alias + sinonimi | `personal_alias` + `plant_synonym`; prikaz = alias ?? label | 🟡 |
| Vremenski posnetek | `weather jsonb` na task/note | 🟢 |
| Opomniki (A) vs predlogi (B) | ločeni tabeli; B z `suggestion_log` (cooldown/dedup) | 🟢 |
| Zaloge ↔ opravila (odpis) | `task_supply` + transakcija ob shranjevanju | 🟡 |
| Percentili (V2) | `GROUP BY h3_cell, week, task_type` → `activity_agg` | 🟡 |
| Promocija lasten→kanonični | batch posodobi `user_plant.plant_id` — **V2, zaledno, odložljivo** | 🟠 |
| H3 | **računaj na napravi**, shrani r7/r6/r5 → navaden `GROUP BY` (brez `h3-pg`) | 🟢 |

### Dve opozorili
1. **Rebind (promocija)** = edina prava logika, a **V2/zaledno** → odložimo.
2. **H3 v bazi:** Supabase ima PostGIS, a `h3-pg` morda ne. **De-risk:** celico računaj **na napravi**
   (h3 knjižnica), shrani r7/r6/r5 kot tekst → roll-up je navaden `GROUP BY`; brez DB-razširitve +
   koordinate ne zapustijo naprave (zasebnost).

**RLS/GDPR:** uporabniške tabele `user_id = auth.uid()`; katalog javno-bralni; izbris računa = `ON DELETE CASCADE`.

---

## 7.15 Prefokus na rastlino: SUBJEKT (rastlina ALI območje), M:N (2026-06-03) ⭐

> 📋 **Vir resnice te revizije: [`fokus-rastlina.md`](fokus-rastlina.md)** (diagnoza + wireframe _v2).
> To poglavje **popravlja** §7.7/7.8/7.9/7.14 tam, kjer je bila aplikacija območje-centrična.

**Povod:** opravila so bila vezana na **območje (obvezno)**, rastlina je bila drugorazredna
(`user_plant_id` NULL, skrita pod "Več"); ni bilo detajla rastline ne vstopa zanjo. To ruši
bistvo — uporabnik dela opravila **zaradi rastlin** (jagode→tretiram, trava→zalijem).

**Ključni vpogled — dva tipa subjekta:**
1. **Homogeno območje = subjekt** (trata) — rastline ni, območje *je* subjekt (obstoječe, pravilno).
2. **Rastlina = subjekt** (jablana, paradižnik) — območje je le **kraj, kjer stoji**.

**Model (popravek):**
- Opravilo se veže na **SUBJEKT = rastlina ALI območje**; ne na območje kot hrbtenico.
- Vez je **many-to-many**: eno opravilo → **N subjektov** (z algami folirano gnojim solato +
  paradižnik + trato = en dogodek). Nova tabela **`task_subject`** (`task.area_id`/`user_plant_id`
  **odstranjena**). V Dnevniku **ena vrstica**; prikaže se v zgodovini vsakega subjekta;
  **sredstva in vreme skupna** (en odpis, en posnetek).
- **Subjekt = instanca, ne vrsta.** `user_plant` = vrsta × območje; ista vrsta na več območjih
  (jablana–vrt, jablana–sadovnjak) = več instanc → ob izbiri vrste **odkljukaš območja**.
- `user_plant.area_id` → **nullable** (lončnica brez imenovanega območja). Take rastline (npr.
  dodane v hitrem vnosu brez izbire območja) se na zavihku **Vrt** prikažejo v sekciji
  **»Brez območja«** na vrhu — ne smejo tiho izpasti iz seznama.

**IA / UX (popravek):**
- Zavihek **"Območja" → "Vrt"** (rastline grupirane po območjih + trate). **Nov zaslon
  Detajl rastline** (zgodovina ene rastline) in **Dodaj/uredi rastlino** (vrsta + osebno ime +
  **izbira lokacij = multi-select območij** + kategorija + izbris).
- **Vnos: Kaj → Za kaj (subjekt, multi-select) → Kdaj**; izbirnik subjektov ima **inline dodajanje**
  iz kataloga vseh vrst. Domov/seznami **vodijo s subjektom** (opomnik: "obreži lovorikovce", ne
  "opravilo na živi meji"). Detajl opravila (17/17b) **našteje vse subjekte**.
- Pametni motor (§7.13): primarni ključ cooldowna/predlogov = **rastlina+tip**, območje le filter.

**Kar OSTANE:** trata = območje-subjekt (brez umetne "rastline trava"); pojem območja
(grupiranje + lokacija); vreme/sync/obvestila/katalog/dvojnost Dnevnik+Opravila. To je
prefokus IA+UX + poseg v shemo, **ne predelava**.

**Wireframe _v2:** `01/02/04→Vrt/07/10/17/17b` + nova `plant-detail`/`plant-edit`
(`docs/wireframes/*_v2.html`, galerija označena).

**Popravek v4 (2026-06-07, implementiran):** dodajanje rastline **rastlino-prvi** =
**en zaslon z instant-add** (tap = takoj shranjeno, večkratno), iskanje skrito za 🔍,
območje **postransko** (na dnu, neobvezno). Subjekt = **instanca z enim `area_id`**
(nullable) — »premik« je single-select prek `area_pick_sheet`; multi-area ob ustvarjanju
opuščen. Vrt FAB→rastline (brez routerja), tih »Novo območje«; swipe Premakni/Odstrani.
Brisanje območja **reparenta rastline v »Brez območja«** (ne osiroti). Brez spremembe
sheme. Wireframi `docs/wireframes/*_v4.html`; plan `docs/vrt-v4-implementacijski-plan.md`.

**Popravek v5 (2026-06-08, implementiran):** **obrnjena hierarhija prikaza** — območje je zdaj
**naslov skupine** (ikona + ime + zadnje opravilo, tap → detajl), rastline pa **kartice pod njim**.
Prej je bilo območje kartica z **večjim** zamikom kot njegove rastline (hierarhija je brala obrnjeno).
Brez spremembe sheme/logike — le presentation. Wireframe `docs/wireframes/vrt_v5.html`.

---

## 7.16 Vnos = en horizontalni stepper (2026-06-03)

> Združi **02 Hiter vnos + 07 Novo opravilo** v EN flow (odpravi podvajanje iz `ia-pregled.md`).
> Wireframe: `docs/wireframes/entry-step*_v3.html`.

Namesto enega gostega navpičnega obrazca (in ločenega »naprednega«) je vnos **horizontalni
stepper** — en korak na zaslon, »Nadaljuj«, na koncu **pregled** s »Shrani« in »Popravi«
(tap na vrstico skoči na korak, predizpolnjeno).

**Koraki (pogojni — kratki za preprosto, polni za kompleksno):**
1. **Tip** (tap = samodejno naprej)
2. **Rastlina / območje** — rastline (čipi, + dodaj iz kataloga); **območja rastlin so kontekstni
   tekst, NE enakovreden subjekt**; območje kot subjekt le ob namenski izbiri (trata, cela greda)
3. **Kdaj** — hitri preset Danes/Jutri/Datum **zgoraj**, pod njim eksplicitna polja **datum + ura**
   (preset posodobi datum; privzeto Danes ob **naslednji polni uri**) · **status** (Čaka/Opravljeno,
   privzeto iz datuma) · **ponavljanje** (le ko Čaka)
4. **Opomnik** — *pogojno: le ko Čaka* (prihodnost); Google-stil zamik (ob dogodku · X prej · po meri)
   + ura, več na opravilo. **Terminologija:** na opravilu je »**opomnik**«, ne »obvestilo«
   (obvestilo = sistemski kanal dostave, §7.12). Wireframe urejanja: `reminder-add_v3.html`.
5. **Sredstva** — *pogojno: tipi, ki jih rabijo* (gnojenje/tretiranje). **⚠️ Začasno skrito
   (2026-06-08)** prek `kSuppliesEnabled=false` — korak se preskoči in ne šteje med korake; koda ostane.
6. **Pregled** — vse izbire + opomba; Shrani / tap = Popravi

**Posledice:** košnja danes = koraki 1–3 + pregled (4–5 odpadeta) → hitrost ohranjena;
tretiranje dobi vseh 5 vodeno. Implementacija: refaktor `quick_log` + `task_form` → en stepper.

---

## 8. v2 vizija — H3 hiperlokalna skupnost

Agregirani (anonimizirani, GDPR-skladni) signali sosedov po območjih + primerjave.
Primer: "Sosedje v tvoji okolici so na gredicah že posadili paradižnik."

> **Podroben statistični + podatkovni model:** [`skupnost-agregacija.md`](skupnost-agregacija.md)
> (natančne definicije, agregacijski cevovod, princip prikaza, statistične pasti). Spodaj je povzetek.

### ⭐ Časovni percentili opravil v okolici (V2 ključni diferenciator)
- **Ideja:** namesto da bi AI *svetoval* "gnoji 15. marca" (tvegano, agronomska
  odgovornost), pokažemo **dejstvo o množici**: histogram po **tednu v letu** za vsak
  tip opravila × klimatski koš. Npr. *"V tvoji okolici je v zadnjih 2 tednih 68 %
  uporabnikov že prvič pognojilo trato"* ali *"večina sadi korenje med 12.–15. tednom."*
- **Opisno, ne predpisno** → elegantno obide odgovornost za nasvet in hkrati odgovori na
  najpogostejše vprašanje skrbnikov trate **"kdaj začeti?"**. Boljši odgovor kot AI, ker
  je lokalen, sezonski in se vsako leto sam izboljša z rastjo baze.
- **Tehnično že podprto z odločitvami:** kanonični ID-ji (košnja=MOW=Mähen…) za čezmejno
  združevanje; res-7 → **roll-up na res-6/res-5** reši cold-start (premalo ljudi v ožji
  okolici → razširi krog). Marker "kje si ti" glede na množico.
- Velja za vse tipe (setev korenja, gnojenje trate, aeriranje…), ne le trato.

### Dorečen dizajn (2026-06-08) — agregacija, anti-junk, cold-start, faznost

**Kdo šteje v agregat.** Anonimni gostje so v oblaku **že izključeni po arhitekturi**
(delajo lokalno kot `user_id='local'`, nikoli ne sinhronizirajo) → agregat bere **samo
registrirane** uporabnike. Proti testnemu/smetnemu vnosu velja **zrelostni filter**:
opravilo šteje le, če uporabnik izpolnjuje minimalne pogoje zrelosti (račun ≥ X dni IN
≥ N opravil IN aktivnost razpršena čez ≥ M dni). Parametri (X/N/M) server-side, nastavljivi.

**Anti-junk paket (poceni, server-side v cronu).**
- Agregiramo **`distinct_users`, ne število opravil** → en hrupen uporabnik (npr. 100
  lažnih vnosov ene vrste) ostane 1 in ne premakne percentila.
- **k-anonimnost:** celica/koš se prikaže šele ob `distinct_users ≥ K` (**K=5** začetno,
  server-nastavljiv) — hkrati zasebnostna in anti-junk varovalka.
- **Drseče okno:** agregiramo le tekočo sezono / zadnje tedne → stari testni podatki naravno odpadejo.
- **Soft-delete spoštovan** (`deleted=true` ne šteje); **lastni vnos izločen**
  (`is_custom=true` user_plant ne gre v skupnost, §7.9) — agregira se le kanonični
  `plant_id`/`task_type_id`.

**Klimatski koš = primarni fallback za cold-start + mikroklima.** Geografski roll-up
(res-7→6→5) sam ne reši praznih pogledov pri redki gostoti. Zato dodamo
**`profile.climate_bucket`**: grob koš **višinski pas × temperaturni/Köppen pas**,
izračunan **na napravi** (višina iz Open-Meteo `elevation`, ki ga vremenski klic že vrača;
temp. pas iz klimatskih normalov) — shranimo **le grob pas, nikoli višine/koordinat**.
Daje smiselno primerjavo "ljudje v podobni klimi kot ti" tudi ko je celica prazna, in
popravi mikroklimo (800 m n.v. vs dolina). Fallback hierarhija prikaza:

`res-7 → res-6 → res-5 → climate_bucket → globalno` (dokler obseg ne doseže K); UI jasno
pove obseg ("v tvoji okolici" / "v podobni klimi" / "med vsemi vrtnarji").

**Kaj uporabnik vidi (tri metrike — podroben model: [`skupnost-agregacija.md`](skupnost-agregacija.md)).**
1. **Feed "kaj se ta teden dogaja"** — pogosta opravila v okolici/klimi (drseče 7-dnevno okno —
   reši delni-teden problem; v ponedeljek ne kaže prazno).
2. **Časovni percentil / histogram** — "do tvojega datuma je ~X % že opravilo Y" + marker "kje si ti";
   krivulja iz **preteklih celih sezon** (tekoče leto je le marker — izognemo se cenzuri delne sezone).
3. **Frekvenca** — "kosijo tipično 2–4× mesečno" (mediana + IQR med izvajalci).

Vse opisno, nikoli predpisno.

**Faznost: "kopiči zgodaj, odkleni pozno".** Temelj (`profile.climate_bucket` +
on-device izpeljava + sync; `activity_agg` + `pg_cron` + javno-bralna RLS izjema) lahko
teče **tiho od začetka** in kopiči zgodovino, **pogled** pa se uporabniku odklene šele ob
zadostni gostoti. Podatkov, ki jih danes ne zbiramo, kasneje ni mogoče rekonstruirati.

**Free plan ni ogrožen.** `activity_agg` je drobcen (tisoči majhnih vrstic), `pg_cron`
teče znotraj baze (nočno, inkrementalno), branje = majhne filtrirane rezine. Pravi
dolgoročni porabnik 500 MB so surove vrstice opravil (sync tako ali tako, neodvisno od te funkcije).

**RLS — nova kategorija dostopa.** `activity_agg` je **prva javno-bralna agregatna tabela**
(vse ostale user-tabele so owner-only). Piše jo **samo cron** (service-role / SECURITY
DEFINER); `grant select to anon, authenticated` z RLS `using (distinct_users ≥ K)`, da
neanonimne vrstice sploh niso berljive.

**Ocena primernosti opravila (uporabnikov "vote")** — odložena na V2.5+ in odsvetovana kot
eksplicitne zvezdice (manipulabilno, oslabi "opisno ne predpisno"); raje implicitni signal
(ali je uporabnik opravilo ponovil naslednje leto).

### Odprta tehnična vprašanja
- **H3 resolucija (določeno, 8. krog):** **res-7 najfinejša prikazana**; pri redki
  gostoti **adaptivno NAVZGOR** (res-6/res-5), **ne** navzdol na res-8. Pretanka =
  identificira posameznika; preširoka = ni "lokalno" → rešitev je roll-up po potrebi.
- **Mikroklima (rešeno 2026-06-08):** rešeno s `climate_bucket` (višina × temp. pas) kot
  fallback — glej "Dorečen dizajn" zgoraj.
- **Zasebnost / GDPR:** vedno **agregirano** (k-anonimnost K≥5), nikoli "Janez na hiši 5".
- **Cold-start (rešeno 2026-06-08):** roll-up res-7→6→5→climate_bucket→globalno +
  zrelostni filter; temelj kopiči zgodaj, pogled odklene ob gostoti — glej "Dorečen dizajn" zgoraj.
- **Odprto:** točen vir temperaturnega pasa za `climate_bucket` (Open-Meteo
  historical/normals vs statičen Köppen lookup) — potrdi ob izvedbi.

---

## 9. Ime in domena

- **IZBRANO: „Tendask"** (2026-06-01). *tend* (negovati/skrbeti) + *task* (opravilo) —
  natanko bistvo aplikacije. Bere se enako v SL/EN/DE, ena jasna izgovorjava, brez
  negativne asociacije. **Domeni `tendask.com` + `tendask.app` KUPLJENI** (Namecheap,
  ~21 € 1. leto; priporočen auto-renew, ker cena ob podaljšanju skoči). `.app` prisilno
  zahteva HTTPS (HSTS preload) — SSL dobimo brezplačno prek hosta/Cloudflare.
- **✅ ZNAMKA PREVERJENA — ČISTO (2026-06-01):** TMview (`tmdn.org/tmview/`, razreda
  9/35/42, pokriva EUIPO + SIPO + DPMA + IP Australia + ~75 uradov) vrne **nič** za
  „Tendask" in variante (Tendask*, Tendisk, Tendax). Nobene registrirane/vložene znamke
  v EU/SI/DE/AU. Žive aplikacije „Tendask" v App Store/Play tudi ni. → **Ime je prosto za rabo.**
- **Najdeno, a brez ovire:** obstajal je ugasel avstralski projekt **Tendask Co Ltd**
  (Melbourne, on-demand task/freelancer marketplace) — bil lastnik `tendask.com`, ki ga je
  opustil (od tod prosta domena). Imel je le **neregistrirano** rabo, tuj + v drugi jurisdikciji
  → zanemarljivo tveganje za EU/SI trg.
- **Priložnost (neobvezno):** ker je polje prazno, smiselno **sami registrirati znamko** —
  SIPO (samo SI, ~100–150 €) ali EUTM prek EUIPO (~850 €/1 razred, vsa EU); priporočen
  razred 9 (+ opcijsko 42). Lahko počaka do bližje launchu.
- **Zavrnjene alternative:** „Horty" ODSVETOVAN — registrirana EU-znamka (EUIPO) TKI
  Hrastnik, d.d. v razredu 1 (gnojila „Horty"); identičen znak + vrtnarska panoga = realno
  tveganje spora. „TendNote" (delovni kandidat) opuščen. „Outask" zavrnjen — `outask.com`
  zaseden/parkiran + dvoumna izgovorjava (out-ask vs oo-task, blizu „outcast").
  Družina „-jot" (PlantJot…) — „jot" zveni nenavadno → opuščeno.

---

## 10. Odprto / naslednji koraki

- [x] **Wireframi MVP** — HTML predloge v `docs/wireframes/` (odpri `index.html`,
      lokalni strežnik: `python3 -m http.server 8000` v tej mapi → http://localhost:8000).
      ~27 zaslonov, grupiranih (Start · Domov · Opravila · Opombe · Območja · Zaloge/Profil · Obvestila):
      00 Splash · 01 Domov · 02 Hiter vnos ⭐ · 03 Dnevnik(=vrtni dnevnik) · 04 Območja · 05 Območje-detajl ·
      06 Opravila (status+akcije) · 07 Novo opravilo (rastlina+sredstva+opomnik) ·
      17 Detajl opravila (čaka) · 17b Detajl opravila (opravljeno) · 18 Opomba · 08 Zaloge ·
      09 Dodaj območje · 10 Izbirnik rastlin · 11 Mesečni/setveni · 12 Nastavitve/profil ·
      13 Prijava · 14 Akcije/urejanje (predlog) · 15+15b–d Onboarding (4) · 16 Lokacija ·
      19 Dodaj obvestilo · 20 Videz obvestil · 21 Prošnja za dovoljenje · 22 Nastavitve obvestil.
- [x] Poliranje Start (brand logo, ikone, pin, disclaimerji) + poenotena navigacija
      (FAB ＋ = Hiter vnos povsod; 2 zavihka Dnevnik/Opravila; 02→07 prek "Napredno").

### Še NAREDITI (naslednja seja)
- [x] **Detajl / urejanje obstoječega opravila** — `17` (čaka) + `17b` (opravljeno),
      bogat 3-pasovni vremenski posnetek + akcije (8. krog).
- [x] **Zaslon Opombe** — `18`; Dnevnik (03) = združen vrtni dnevnik (8. krog).
- [x] Skupni pregled celotnega user-flowa — opravljen 8. krog (popravki neskladij).
- [x] **Potrjeno:** Open-Meteo · jeziki SL/EN/DE · **H3 res-7 najfinejša, adaptivno NAVZGOR
      (res-6/res-5)** — res-8 opuščen (8. krog).
- [x] **Ime IZBRANO = „Tendask"**; domeni `.com` + `.app` kupljeni + znamka preverjena (2026-06-01).
- [x] **Tehnološki sklad POTRJEN** (7.11 + [`tech-stack.md`](tech-stack.md)): Flutter + Riverpod +
      drift (offline) + ročni sync + Supabase + Sentry; FCM odložen; 0 € v razvoju/MVP.
- [x] **Tipi opravil + katalog rastlin** — osnutek v ločeni datoteki
      **[`opravila-in-rastline.md`](opravila-in-rastline.md)** (jedro + trata-specifični tipi,
      `zahtevaSubjekt`, vreme-občutljivost; kurirani katalog rastlin SL/EN/DE + kategorije +
      matrika kategorija↔opravila). Preostane: preverba prevodov, razširitev na ~100–200 vrst, ikone.
- [x] Tehnološka izbira (osnutek, glej 7.11): **Flutter + Supabase (DB/RLS/Auth) +
      Firebase FCM (push) + lokalna obvestila + Open-Meteo + H3 na napravi.**
- [x] **Obvestila — zasloni dodani** (19–22, glej 7.12): izbirnik "Dodaj obvestilo",
      videz po vrstah, prošnja za dovoljenje (priming), nastavitve (tihe ure + frekvenčna
      kapica + granularni opt-in). Povezave 07→19, 12→22.
- [x] **In-app nabiralnik = ni potreben** — pametni predlogi živijo na pasu Domov (01).
- [x] **Pametni predlogi (plast B) — motor specificiran** (§7.13): dnevni paketni pregled +
      FCM, kurirana pravila (brez AI), vodenje proti podvajanju/gnjavljenju (cooldown,
      vremenske straže, dedup, spomin na Opusti, frekvenčna kapica). MVP = 3–4 pravila.
- [ ] **Implementacija pametnih pravil** (kasneje, ob razvoju): definirati konkretnih 3–4 MVP pravil + parametre (N dni cooldown, vremenski pragovi).
- [x] **Monetizacija — smer določena:** **free za osnovno uporabo; plačljivost dodamo
      šele ob uvedbi premium funkcij** (vpogledi/percentili). **Brez oglasov** (kolizija z
      zasebnostjo + UX). Prioriteta = gostota skupnosti; nikoli ne zaračunamo *beleženja*.
      Dolgoročni vzvod = agregirana anonimizirana baza (B2B, GDPR-čisto). Cene/Pro paket = kasneje.
- [x] **Dokončno ime = „Tendask"** (domeni kupljeni). [ ] Preostane: preverba znamke (EUIPO/SIPO, razreda 9/42 + App Store/Play).

---

## 11. Dnevnik odločitev

- **2026-06-03 (vrstni red zavihkov + FAB — §7.9):** Spodnja navigacija preurejena v
  **Domov · Opravila · Dnevnik · Vrt** (prej Domov · Dnevnik · Vrt · Opravila). Razlog:
  Opravila so dnevni akcijski pogled (»kaj me čaka«) in sodijo naprej; Dnevnik je zgodovina
  za branje. **FAB ＋ (vnos) preseljen z Dnevnika na Opravila** (+ ostane na Domov); Opravila
  izgubi podvojeni ＋ v AppBar. Dnevnik je odslej čisto bralni zgodovinski pogled.
- **2026-06-03 (vnos = horizontalni stepper — §7.16):** 02 Hiter vnos + 07 Novo opravilo se
  združita v en horizontalni flow s pogojnimi koraki (tip · rastlina/območje · kdaj+ura+status+
  ponavljanje · opomnik [če čaka] · sredstva [če tip] · pregled s Shrani/Popravi). Območja rastlin
  so kontekst, ne subjekt. Dodan `_v3` wireframe; sledi implementacija (refaktor v en stepper).
- **2026-06-03 (prefokus na rastlino — glej §7.15 + [`fokus-rastlina.md`](fokus-rastlina.md)):**
  Ugotovljeno, da je bila aplikacija območje-centrična na vseh plasteh (task.area_id obvezen,
  rastlina drugorazredna; ni detajla/vstopa rastline) — kar ruši bistvo. **Popravek:** opravilo
  se veže na **SUBJEKT = rastlina ALI območje**, vez **M:N** prek nove tabele `task_subject`
  (eno opravilo → več subjektov; sredstva/vreme skupna; `task.area_id`/`user_plant_id` odstranjena;
  `user_plant.area_id` nullable). IA: zavihek **Območja → Vrt**, nova zaslona **Detajl rastline**
  in **Dodaj/uredi rastlino** (multi-select lokacij); vnos **Kaj → Za kaj (multi-select) → Kdaj**
  z inline dodajanjem iz kataloga; detajl opravila našteje vse subjekte. Trata ostane
  območje-subjekt. Wireframe `_v2` izdelani; sledi shema + repo + UI.

- **2026-06-01 (ime — ZAKLJUČENO):** Izbrano ime **„Tendask"** (tend+task); domeni
  `tendask.com` + `tendask.app` kupljeni. **Znamka preverjena v TMview (razreda 9/35/42) =
  ČISTO**, nobene kolizije v EU/SI/DE/AU. Najden ugasel AU projekt Tendask Co Ltd (le
  neregistrirana raba, brez ovire). „Horty"/„TendNote"/„Outask" zavrnjeni (glej §9).
  Opcijsko še: lastna registracija znamke (SIPO/EUTM, razred 9) — neobvezno, do launcha.
- **2026-06-01 (brand):** Vizualna identiteta potrjena ([`docs/brand/brand.md`](brand/brand.md)) — smer D.
  Uporabnik izbral paleto+tipografijo iz D, **logo iz A brez kljukice**. Paleta: zelena `#2e7d32`(+900/400) +
  medena `#E0A82E`; pisava Plus Jakarta Sans; SVG asseti v `docs/brand/assets/`. Splash wireframe usklajen.
  Primerjava 4 smeri arhivirana v `docs/brand/directions.html`.
- **2026-06-01:** "Horty" odsvetovan (znamka TKI Hrastnik). MVP = solo prvo,
  skupnost (H3) kasneje. Podatkovno jedro po območjih, primarni pogled koledar
  + preklop na območja. Brez hitenja z implementacijo.
- **2026-06-01 (dopolnitev):** Vodilno načelo = **PREPROSTOST** (hiter vnos
  kaj+kdaj). V v1 dodani: opomniki/todo z opombo, prosto besedilo, beleženje zalog.
  Izpuščeni (zaenkrat): foto, AI svetovalec, avtomatski kalkulator mešanic
  (v1 le ročna opomba). Vnos opravila in opomnika = kaj + kdaj (+ neobvezna opomba).
- **2026-06-01 (dopolnitev):** **Push obvestila na telefon obvezna v v1**
  (nastavljiv zamik + ura, po vzoru Google Koledarja, možnost več obvestil).
- **2026-06-01 (wireframi):** Izdelane HTML wireframe predloge MVP v
  `docs/wireframes/`. IA = 4 zavihki (Domov · Dnevnik · Območja · Opomniki) + FAB
  za hiter vnos. Hiter vnos zasnovan kot kaj→kdaj→kje s privzetki (Danes, zadnje
  območje) za 2–3 dotike.
- **2026-06-01 (2. krog odločitev — glej 7.7):** Območja max 2 nivoja
  (območje → rastline). Zaloge↔opravila prek izdelka/recepta + odpis. Večjezičnost
  = kanonični ID + i18n od dne 1 (SL/EN/DE), nujno za V2 čezmejno primerjavo.
  Katalog vrst = kurirana baza + "po meri", AI kasneje. Vreme = Open-Meteo, beleži
  bogat posnetek (ob/nazaj 24-48h/napoved 24-72h). Splash narejen (list v H3-celici).
- **2026-06-01 (3. krog — popravki):** Območja NIMAJO lokacije (vsa na isti posesti);
  lokacija+vreme+H3 = lastnost profila (res-7→8 adaptivno, V2). Prijava: Apple/Google
  + e-pošta OTP + "brez računa" z nadgradnjo. Sredstva (poraba) na opomniku/opravilu.
  Nadzor katalog vrst: lastni vnos zaseben, ne v skupnost. Dodani wireframi 09–13
  + splash (00). Skupaj 14 zaslonov.
- **2026-06-01 (4. krog — glej 7.8):** Opravilo/opomnik se veže na RASTLINO (ne le
  območje; `zahtevaSubjekt`). Status opomnika + akcije (povleci + plošča, enako povsod).
  Setveni koledar po klimatskih regijah (polobla-aware, po-MVP). Lokacija res-7,
  poljudno+zasebno, GPS ali ročni kraj. Onboarding (preskočljiv). Dodani wireframi
  14–16. Skupaj 17 zaslonov.
- **2026-06-01 (5. krog — glej 7.9):** ⭐ Poenotenje: **OPRAVILO = ena entiteta**
  (datum preteklost/prihodnost, status čaka/opravljeno); **opomnik = neobvezen dodatek**.
  Zavihek **Opomniki → Opravila** (☑️). Mesečni koledar: tap na dan = dodaj opravilo.
  Wireframi grupирani v index po skupinah (Start · Domov · Opravila · Območja · Zaloge/Profil).
  Pregled neskladij opravljen (naslovi, povezave, gumbi usklajeni).
- **2026-06-01 (6. krog):** Zavihek preimenovan **"Opravila"** (prej Načrtovano).
  Dostop do **Zalog** dodan v Nastavitve (poleg bližnjice na Domov). Dodan **izbris
  računa in vseh podatkov** (GDPR). Onboarding razširjen na **4 drsnike** (15, 15b–d).
  **Navigacijski tok vklopljen:** Splash→Onboarding→Prijava→Lokacija→Domov; v Hiter
  vnos (02) dodan **"Napredno ›" → 07 Novo opravilo** + povezave izbirnikov. Koledar:
  tap na dan → 07. Opomba: 02 (hitro) in 07 (polno) sta vstopni točki iste entitete.
- **2026-06-01 (7. krog — poliranje):** Start: enak brand logo (list v H3-celici) na
  Splash/Onboarding-1/Prijava; klasičen pin za lokacijo; custom ikone onboarding 2–4
  (enako velike); disclaimer (brez računa = izguba ob odstranitvi/menjavi naprave);
  lokacija "natančna le na napravi, mi hranimo okvirno". Onboarding 4 drsniki.
  **IA opravil = 2 ločena zavihka** (izbira uporabnika): 📅 Dnevnik (kaj sem naredil)
  + 📋 Opravila (kaj me čaka); ikona 📋. **Vstop poenoten: FAB ＋ = vedno Hiter vnos (02)**,
  iz 02 "Napredno ›" → 07; tap na dan v koledarju → 07. 02 preimenovan v "Hiter vnos"
  (loči od 07 "Novo opravilo").
- **2026-06-01 (8. krog — glej 7.10):** Dodana **Detajl opravila** v dveh stanjih:
  `17` (čaka, vremenska *napoved* + akcije ✓/+1 dan/Uredi/Podvoji/Izbriši) in `17b`
  (opravljeno, **zamrznjen dejanski posnetek** + Uredi/Podvoji/Premakni/↩Na čaka/Izbriši);
  bralni pogled, urejanje prek 07 (odločitev: bralni pogled, ne urejevalni zaslon).
  Bogat **3-pasovni vremenski posnetek** (ob izvedbi · 24–48 h nazaj · napoved 24–72 h).
  Dodan zaslon **Opombe** (`18`); **Dnevnik = združen vrtni dnevnik** (opravila + opombe
  pomešano, filter Vse/Opravila/Opombe) — odločitev "oboje" (samostojna opomba +
  opomba na opravilu). Skupni pregled flowa: poenoteno tikanje, popravljene povezave
  (Opombe/05⋯/12 Spremeni), usklajena sredstva 06↔07/17, vremenska kontinuiteta povsod.
  **Potrjeno:** Open-Meteo · SL/EN/DE. **H3 popravek:** res-7 = najfinejša prikazana
  raven, **res-8 opuščen** (preveč granularno); adaptivnost gre **NAVZGOR** na res-6/res-5
  (roll-up za redko gostoto / širšo okolico), ne navzdol. Skupaj ~23 zaslonov.
- **2026-06-01 (use case — lawn-care):** Dodana močna podpersona **intenzivni skrbnik
  trate** (§3, vzor FB "Popolna trava"). Potrjeno: MVP pokrije **beleženje** vseh
  trata-opravil + zgodovino + vreme + opomnike; **vodeni program in diagnostika ostajata
  zunaj** (agronomska odgovornost). Tvojo idejo "kaj počnejo drugi" zapisana kot V2
  ključni diferenciator: **časovni percentili opravil v okolici** (§8) — histogram
  teden-v-letu × klimatski koš, **opisno ne predpisno**, sloni na kanoničnih ID + roll-up
  res-7→6→5. V TODO dodani trata-specifični tipi opravil.
- **2026-06-01 (potrjeno — brez AI):** Zaenkrat gremo **brez AI** (v skladu s 6.7).
  Na "kdaj?" odgovori **percentil okolice (§8)**, ne algoritem. Če bi vodeni
  program/diagnostika kdaj prišla, le kot **kurirana vsebina** iz preverjenih virov —
  **nikoli AI-halucinacije**. AI prepoznava/preslikava ostaja oddaljena opcija (post-V2).
- **2026-06-01 (tech FINALIZIRAN):** Sklad potrjen (7.11 + [`tech-stack.md`](tech-stack.md)).
  Vodilo: **kodo piše AI agent + uporabnik je Flutter-noob → najbolj mainstream tehnologije**
  (AI ima največ primerov) **+ 0 € v razvoju/MVP**. Dokončano: **State mgmt = Riverpod**;
  **lokalna baza = drift (SQLite), sync = ročni push/pull BREZ zunanje storitve** (PowerSync
  izločen zaradi stroška; MVP enouporabniški → LWW); **FCM ODLOŽEN** (prvi MVP brez Firebase);
  crash = **Sentry**; i18n = `slang`; routing = `go_router`; HTTP = `dio`; H3 = `h3_flutter`.
- **2026-06-01 (tech + obvestila — osnutek):** Tehnološki osnutek (7.11): **Flutter + Supabase
  (Postgres/RLS/Auth, PostGIS+h3 za V2) + Firebase SAMO FCM + lokalna obvestila +
  Open-Meteo klientsko + H3 na napravi** (shranimo le celico, ne koordinat). Free plani
  zadoščajo za razvoj (~25 $/mes Supabase Pro ob objavi). **Ugotovljena vrzel:** wireframi
  nimajo obvestil (le nastavitve) → novo poglavje 7.12 (3 vrste: opomniki=lokalni ·
  vreme=FCM · okolica/percentili=FCM, npr. "X % je gnojilo z algami") + vodenje proti
  motečnosti (tihe ure, frekvenčna kapica, granularni opt-in) + manjkajoči zasloni v TODO.
  Monetizacija dodana kot odprt osnutek v TODO (free jedro + Pro, brez oglasov, B2B-agregat).
- **2026-06-01 (monetizacija — smer):** Potrjeno: **free za osnovno uporabo; plačljivost
  šele ob uvedbi premium funkcij** (vpogledi/percentili). Brez oglasov. Prioriteta gostota
  (nikoli ne zaračunamo beleženja). Konkretne cene/Pro paket = kasneje.
- **2026-06-01 (zasloni obvestil):** Zapolnjena vrzel — dodani **19** Dodaj obvestilo
  (zamik+ura), **20** Videz obvestil (3 vrste: opomnik/vreme/okolica na zaklenjenem zaslonu),
  **21** Prošnja za dovoljenje (priming — prikazan po vrednosti, ne ob zagonu; sistemsko okno
  sledi), **22** Nastavitve obvestil (vrste · privzeti zamik · tihe ure · frekvenčna kapica ·
  granularni opt-in). Povezave 07→19, 12→22. Skupaj ~27 zaslonov. Odprto: in-app nabiralnik (da/ne).
- **2026-06-01 (dve plasti obvestil + pametni motor):** Razjasnjeno: **A) Opomniki** =
  uporabnik nastavi na opravilu (19–22, lokalni) · **B) Pametni predlogi** = sistem sam
  (strežniški). Plast B specificirana (§7.13): **dnevni paketni pregled + FCM, kurirana
  pravila brez AI**; vodenje proti podvajanju/gnjavljenju (cooldown po območje+rastlina+tip,
  vremenske pred/proti-pogoji, dedup proti načrtovanim, spomin na "Opusti", frekvenčna
  kapica/digest, upravičenost). Dom predlogov = **pas na Domov (01)** → in-app nabiralnik
  ni potreben. MVP = 3–4 pravila (vremensko okno · "lani tačas" · zapadlo · sezonsko okno);
  skupnostni/percentilni predlogi = V2.
- **2026-06-01 (katalog opravil + rastlin):** Ustvarjena ločena datoteka
  **`opravila-in-rastline.md`** (referenca iz §6.1, §7.7, §10): privzeti tipi opravil
  (jedro + trata-specifični, `zahtevaSubjekt`, vreme-občutljivost), kurirani katalog rastlin
  (~35, SL/EN/DE + znanstveno + kategorije) in matrika kategorija↔opravila. Osnutek —
  preostane preverba prevodov, razširitev na ~100–200 vrst, ikone, sloj sinonimov.
- **2026-06-01 (obseg rastlin — odločeno):** ~35 vrst ostane **le vzorec za potrditev
  strukture**; **celoten katalog (širša taksonomija + 100–200+ vrst) = implementacijska
  faza, v enem koraku** (seed iz Wikidata/GBIF + kuracija). Ročno vnaprej NE širimo
  (obseg ne vpliva na zaslone/flow; podvojeno delo). Kategorije niso dokončne.
- **2026-06-01 (podatkovni model — osnutek):** Dodan §7.14 — preslikava kataloga + jedra
  v Supabase Postgres (tabele katalog/uporabnik/V2-agregat). Ocena **nizka–srednja
  kompleksnost**: posebnosti reši JSONB (i18n/vreme), NULL-able FK + CHECK (opcijski
  subjekt/lasten), pomožne tabele (sinonimi, suggestion_log), cron-agregat (percentili).
  Edini zoprni: rebind (V2, odložljivo) + H3 (de-risk = računaj na napravi, shrani r7/r6/r5,
  brez `h3-pg`). `opravila-in-rastline.md` = vir za seed, ne živa povezava.
- **2026-06-01 (pametni motor — roadmap):** Ustvarjen **`pametni-motor.md`** (referenca iz §7.13):
  implementacijski načrt plasti B. Razčlenjeni **viri po težavnosti/fazah** (B=lastna zgodovina, lahek,
  z obstoječimi podatki → MVP · A=sezonska okna prek **frost-anchor**, agronomski sloj → faza 2 ·
  C=skupnostni percentili → V2). "Združevanje" = **rangiranje + straže, ne fuzija**. Nov **sloj
  agronomskih pravil rastlin** `plant_task_rule` (dvonivojski: privzetek po kategoriji + izjema po vrsti;
  anchorji `month_window`/`frost_offset`/`growth_stage`; opisno + `source_ref`, brez AI). Frost-anchor =
  ena tabela + pozebni normali iz Open-Meteo → auto-regionalizacija (brez zajemanja regijskih koledarjev).
- **2026-06-01 (10. krog — vzgoja sadik):** Dodana dejavnost **priprava/vzgoja sadik** (v hiši, rastlinjaku).
  Območje dobi zastavico **`protected`** + nova tipa **Rastlinjak / Notranji prostor** (§7.7) — ohrani eno
  profilno lokacijo, doda pravokotno dimenzijo izpostavljenosti; motor zaščitena območja **izvzame iz
  vremenskih straž**, frost-anchor ostane. Modelirana **polna veriga (MVP)**: predsetev → pikiranje →
  utrjevanje → presaditev na prosto (`opravila-in-rastline.md` A.3) kot **event-driven veriga** (vsak
  opravljen korak sproži predlog naslednjega; presaditev dodatno **frost-gated**). Showcase frost-anchor
  motorja za zelenjavnega vrtnarja. Dodan tudi tip opravila **`graft` (cepljenje)** — sadno drevje
  (tudi vinska trta/vrtnice), dve sezonski okni (mirovanje + poletno okuliranje).
- **2026-06-01 (10. krog — dodatna nega):** Dodana skupina opravil **A.4** (`opravila-in-rastline.md`):
  **privezovanje/opora** (`stake`), **redčenje plodov** (`thin_fruit`, `growth_stage` po cvetenju),
  **presaditev lončnic** (`repot`), **prezimovanje/zaščita pred zmrzaljo** (`overwinter`). Prezimovanje =
  **zrcalo presaditve** (`frost_offset` na `first_frost`) → pametni predlog "prva pozeba se bliža →
  zaščiti/premakni lončnice". Dodana matrična vrstica **Lončnice/balkonske/sobne**.
