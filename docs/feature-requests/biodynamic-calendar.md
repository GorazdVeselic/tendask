# FR-19 — Biodinamični koledar (koren / list / cvet / plod)

> **Status:** spec (feature request) · 2026-07-21, v2 2026-07-22, **kalibracija + konkurenca 2026-07-22
> (§12, §15)** · neimplementirano
> **Vir zahteve:** `docs/povratne-informacije.md` → Runda 2, **T10** (lunina mena / setveni koledar).
> **Wireframe:** `docs/wireframes/lunar-calendar_overview.html` (v2 — stanja z/brez Tendask+, mena free,
> agenda z opisi, semantika »dan za X«). Zaženi prek localhost (glej memory reference-wireframe-localhost).
> **Ime izdelka (in-app):** »**Lunin koledar**«; polna oblika »**Tendask biodinamični lunin koledar**«
> (lastna kompilacija, nevtralno poimenovanje). **Premium (Tendask+)** kasneje; zdaj vse free.
> **Obseg (potrjeno z lastnikom):** pristop **A = izračunan približek** z **najboljšim možnim
> približkom originalnega koledarja**, a brez kopiranja Thuninega izdelka. Ta dokument je spec, ne koda.
> **Faznost:** aplikacija je **že v produkciji** (Play, od 2026-07-20) — to NI launch-gating; »kasneje«
> pomeni **prioritizacijo** (stabilizacija + drugi FR-ji imajo prednost pred tem večjim feature-om).
> **Povezave:** `docs/koncept.md` §7.10 (vremenski posnetek ob opravilu — vzporeden vzorec), roadmap FR-19.

---

## 0. Povzetek dogovorjenega (2026-07-21)

- **Pristop A + lasten izračun.** Sami izračunamo siderični položaj Lune → element → del rastline; nič
  kopiranja Thuninega izdelka. Pravno smo v isti poziciji kot »Lunine bukve« (§3, §3.1).
- **Ime (odločeno) = »Lunin koledar«** (in-app); polna oblika »Tendask biodinamični lunin koledar«
  (listing/onboarding). Kandidati/utemeljitev v §3.2.
- **Jedro = uveljavljena, transparentno izračunana načela.** Znamka Tendask živi v **UX/planiranju/
  integraciji**, ne v izmišljenih pravilih (§3, meja lastnega algoritma).
- **Večdnevni pogled naprej = JEDRO**, ne dodatek (planiranje »kdaj je naslednji dober dan«) — §6.2.
- **Akcijske integracije** (glavni razlog »v aplikaciji, ne v knjigi«): pol-avto opravilo iz koledarja,
  obratni iskalnik »naslednji dober dan za X«, personalizacija po vrtu, opt-in obvestila, kratka
  razlaga, kasneje retrospektivni vpogled (§6.3).
- **Nič sheme / synca / mreže / lokacije** — element je čista funkcija datuma (§2, §5).
- **Zdaj VSE FREE** (nabiranje uporabnikov; billing še ne obstaja). Premium meja = **zapis namere za
  takrat, ko pride plačilna infrastruktura**; plačljive postanejo »dobre/želene akcije« (§6.5).
- **Ni launch-gating** — aplikacija je v produkciji; »kasneje« = prioritizacija (stabilizacija + drugi
  FR-ji prej).

### Dodatno dogovorjeno (iteracija v2, 2026-07-22) — podrobno v §11

- **Semantika:** uveljavljena fraza **»dan za plod / list / cvet / korenino«** (NE »plodov dan«).
- **Mena Lune = FREE za vse**; **element-dan + koledar/planer = premium (Tendask+)**.
- **Aktivacija = licenčna koda (zunanji nakup)**; aplikacija **ne kaže/povezuje na nakupno stran**
  (anti-steering) — samo vnos kode + opis ugodnosti.
- **Vstopne točke:** čip na Domov (mena + CTA) · Dnevnik segment · Domov ⚙️ → Tendask+ · 🔎 v koledarju
  → obratni iskalnik.
- **Opisi dejavnosti = lastna besedila** (i18n, na element, ne per-dan proza; tuji dnevni teksti NE).
- **Astronomija validirana + siderično KALIBRIRANO proti tiskani knjigi** (§12, 2026-07-22): motor
  pravilen (Meeus 0,003°, mlaji/ščipi 1–3 min). **Prelom:** dobili smo fotografije **tiskanega Setvenega
  priročnika Marije Thun 2024** (avtorizirana siderična izdaja) z **uro vstopa** Lune v ozvezdje →
  **50 referenčnih vstopov iz 4 mesecev** (jan/feb/avg/dec, oba časovna pasova). Rezultat: **siderični-IAU
  model se ujema na ~2 h (čist) oz. ~25 min (kalibriran); siderični enakih-30° NE deluje.** Navzkrižno
  potrjeno (obe smeri kalibracije), stabilno čez leto in v 2026 (Ajda Thun).
- **Toggle tropski/siderični** (§13): poimenovanje po mehanizmu (»Po ozvezdjih (biodinamični)« /
  »Po znamenjih«), **brez »Thun«** (znamka); **privzeto = siderični-IAU** (obrat po kalibraciji —
  ujame tiskani SI trg Thun/Ajda/Miler), tropski ostane za tiste, ki primerjajo splet.

---

## 1. Cilj in vrednost

Marsikateri (posebej slovenski) vrtnar dela »po luni«. Tendask naj ob datumu opravila pokaže
**biodinamični del rastline za tisti dan** — **koren / list / cvet / plod** — in ponudi mesečni
pregled, da uporabnik lahko **načrtuje setev/saditev na ustrezen dan**.

To je **koledarski/kulturni sloj**, NE agronomsko-vremenska pravila. Namenoma **ločen od M11
(pametni motor)** — drugačen miselni model (koledar vs. frost-anchor pravila). Motor ne sme
generirati predlogov iz lune in luna ne sme siliti v motor.

**Pozicioniranje (pomembno):** predstavi kot **tradicijo/preferenco** (»za tiste, ki delajo po
luni«), **ne** kot agronomski nasvet. Znanost učinkov večinoma ne potrjuje; za produkt to ni ovira,
dokler je jasno komunicirano in **opt-in**.

## 2. Načela (CLAUDE.md) — zakaj se lepo prilega

- **Offline-first, brez podatkov, brez mreže:** element dneva je **čista determinística funkcija
  datuma** (astronomija). Za razliko od vremena **NE rabi mreže** in ga ni treba shranjevati.
- **Nič sheme, nič synca:** ker je re-izpeljljiv iz datuma, **ne dodajamo stolpcev** na `task`/`note`,
  **ne** spreminjamo drift/Supabase, **ne** sinhroniziramo ničesar. (Kontrast: T11 yield in vreme sta
  rabila nova polja; luna ne.)
- **Zasebnost:** nič novih osebnih podatkov; lokacija ne igra vloge (glej §5).
- **Čas = UTC v izračunu, lokalno za prikaz;** injiciran `Clock` (nikoli gol `DateTime.now()` v
  logiki — CLAUDE.md »Sync, čas in shema«), da so testi »kaj je element na dan X« deterministični.

## 3. Pravni okvir (zakaj A, ne kopija)

- **Prosto:** astronomska dejstva (položaj Lune, kdaj vstopi v ozvezdje) + **tradicionalni mapping
  element→del rastline** (starodaven, ni Thunina iznajdba) + **ideja** koren/list/cvet/plod dni.
- **Zaščiteno (NE uporabljamo):** Thunin objavljen koledar *Aussaattage* kot zbirka — njene
  **specifične meje ozvezdij**, empirični popravki, izbor neugodnih dni; blagovni znamki »Maria Thun«
  / »Aussaattage«.
- **Posledica za poimenovanje:** v aplikaciji **nevtralno** — »**Tendask biodinamični lunin koledar**«,
  oznake dni »Koren/List/Cvet/Plod«. **Nikjer** imena Thun/Aussaattage in nič, kar bi namigovalo na
  uradno potrditev.
- **Meja »lastnega algoritma« (pomembno):** znamka Tendask živi v **UX-u, planiranju in integraciji**,
  **NE** v izmišljenih astronomskih pravilih. **Jedro = uveljavljena, transparentno izračunana načela**
  (element-dnevi, dvigajoča/spuščajoča, vozli/perigej) → obranljivo in prepoznavno tistemu, ki pozna
  biodinamiko. Izmišljati lastna »skrivna« pravila in jih tržiti kot biodinamiko = tveganje za
  neverljivost; ne delamo tega.

### 3.1 Precedens na slovenskem trgu (kako je objava legalna)

Trg to že počne po treh ločenih poteh — potrjuje, da je pristop A uveljavljen:

- **Razlaga metode = prosto** (npr. `prc-lu.si` pojasni Thunin sistem, navede vir). Citiranje, ne kopija.
- **Uradni Thunin izdelek = licenca** (slov. »Setveni priročnik Marije Thun«, avtorizirana izdaja pod
  okriljem družine Thun). Pot za tistega, ki hoče znamko Thun.
- **Lasten izdelek = lastna avtorska pravica** (Založba Kmečki glas, »Lunine bukve«, avtor Miša Pušenjak
  idr. — sami izračunajo/sestavijo, poimenujejo po svoje, prodajajo). **Tendask je v tej tretji poziciji.**

Alternativa za kasneje (če postane premium adut): **licenca/partnerstvo** z obstoječim slov. koledarjem
ali »uradna Thun aplikacija« — točnost + znamka brez lastne verifikacije, a strošek + odvisnost od
zunanjih podatkov (trči ob offline-first). Za zdaj: **lasten izračun**.

### 3.2 Poimenovanje — kandidati (delovni naslov je predolg)

Ločimo **kratek in-app label** (naslov zaslona, nav postavka, čip) od **polne/marketinške oblike**.
Kandidati (od kratkega k opisnemu):

| Ime | Dolžina | Za / proti |
|---|---|---|
| **Lunin koledar** | kratek | ✅ jasno, slovensko, širše kot »setev« (pokrije vsa opravila). **Priporočen in-app label.** |
| **Setveni koledar** | kratek | domač, uveljavljen SI izraz + SEO (»setveni koledar« išče veliko ljudi); a namiguje samo na setev |
| **Lunin setveni koledar** | srednji | ujame se s trgom (npr. »Lunine bukve«); 3 besede |
| **Koledar po luni** | srednji | pogovorno, prijazno |
| **Tendask Luna** | kratek | brand-forward, za marketing/gumb; manj opisen |
| **Tendask biodinamični lunin koledar** | dolg | polna/opisna oblika za store listing / prvo predstavitev; predolg za UI |

**Odločeno (2026-07-21): in-app ime = »Lunin koledar«.** Polna oblika (listing, onboarding razlaga) =
»Tendask biodinamični lunin koledar«; »Setveni koledar« hrani kot SEO/marketinško frazo.

## 4. Kako do »najboljšega približka« (astronomija)

Cilj: čim bližje pravemu sideričnemu koledarju, a vse izračunano sami.

### 4.1 Položaj Lune
Geocentrična navidezna **ekliptična dolžina** (in za višjo vernost tudi **širina**) Lune prek
skrajšane serije (**Meeus / ELP2000-82B**). Za dnevno ločljivost zadošča **~1 kotna minuta** →
nekaj deset členov. Luna se premakne ~13°/dan, torej groba efemerida ne zadošča za točen dan prehoda.

### 4.2 Meje ozvezdij — glavni vzvod vernosti
Thun uporablja **dejanska (neenaka) ozvezdja**, ne enakih 30° znamenj. Naša najbolj verna **legalno
čista** izbira:

- **Priporočeno: realne astronomske (IAU) meje ozvezdij** na ekliptiki (kjer jih Luna prečka).
  Ker Thun prav tako izhaja iz realnih ozvezdij, je to **astronomsko najbližje** njej, brez kopiranja
  njenih tabel. Meje IAU so **javno dejstvo**.
- **Enostavnejša alternativa (manj verna):** siderični enakih-30° znamenj z ayanamso. Hitrejše, a
  ker Thun uporablja neenaka ozvezdja, se pogosteje razide → **ne** priporočeno pri zahtevi »najboljši
  približek«.

**Odprto (§8): Kačenosec (Ophiuchus).** Ekliptika ga prečka; biodinamika ga tipično zloži v prehod
Škorpijon/Strelec. Odloči 12 vs. 13 ozvezdij; za približek Thunu ga obravnavaj kot prehod, ne kot
samostojen element.

### 4.3 Element → del rastline (tradicionalni, prosti mapping)

| Element | Ozvezdja | Del rastline | Tip vrtnarjenja |
|---|---|---|---|
| **Ogenj / toplota** | Oven, Lev, Strelec | **Plod** | plodovke, sadje, semena |
| **Zemlja** | Bik, Devica, Kozorog | **Koren** | korenovke |
| **Zrak / svetloba** | Dvojčka, Tehtnica, Vodnar | **Cvet** | cvetlice, cvetače |
| **Voda** | Rak, Škorpijon, Ribi | **List** | listnata zelenjava |

### 4.4 Prehodi sredi dneva
Ker Luna zamenja ozvezdje sredi dneva, dan ni vedno en sam element. Izračunaj **uro prehoda** in
prikaži npr. »**Koren do 14:20, nato List**«. To je del vernosti (Thunin koledar to označuje).

### 4.5 Bogatejši sloji (za še boljši približek)
- **Dvigajoča / spuščajoča Luna** (deklinacijski ~27,3-dnevni ciklus) — **ločena os** od element-dneva
  (element = *kaj* sejati; dvigajoča/spuščajoča = *katero opravilo*: spuščajoča → presajanje in delo v
  tleh, dvigajoča → setev nadzemnih, rez, spravilo). **POTRJENO (2026-07-22):** izračun deklinacije
  (Meeus širina + naklon) se ujema s Thunovim »časom za presajanje« **96 % (jan) / 100 % (feb) 2024** —
  edini »miss« je dan, kjer Thun sam navaja »konec presajanja ob 7h«. Prav tako čista, prosta astronomija.
- **Neugodni časi:** bližina **vozlov** (mrki), **perigej/apogej**, mrki. Thun te dni odsvetuje;
  označitev bistveno približa videz pravega koledarja. Vse čista astronomija (izračunljivo, prosto).
- **NE prevzemamo (Thun-specifično):** njegove kratice pripomb (vih/pmt/ptr…), planetarni aspekti pred
  ozvezdji (♆♀☿), dnevne »posebej ugodno ob X« ocene — avtorski/empirični izbor (§3, pravno). Namesto
  tega **naša** povezava element→rastlina (že imamo `categoryMatrix`).

### 4.6 Izvedba
- **Paket vs. lasten izračun:** Meeus lunarna dolžina = obvladljiva pura-Dart funkcija (nekaj deset
  členov). Astronomski paket bi bil **izven `tech-stack.md §1`** → **najprej vprašaj + pin + uskladi
  §1**. Privzeto priporočilo: **lasten izračun** (majhen, brez odvisnosti, testabilen), razen če se
  najde zrel, majhen, čist paket.
- **Struktura:** čista funkcija v `core/` (npr. `core/biodynamic/moon_calendar.dart`):
  `BiodynamicDay dayFor(DateTime date)` → `{primaryElement, transitionAt?, secondaryElement?,
  ascending, unfavorable}`. Brez Riverpod stanja; brez I/O. Unit-testabilno proti znanim datumom.

## 5. Vpliv področja (Slovenija / Francija) — zanemarljiv

Siderični položaj Lune je **globalen**; oba sta v **CET**, zato tudi prehodi padejo na isti dan.
Razlika bi nastala šele čez časovni pas (dan zamika) ali na južni polobli (sezona, ne luna). **Zato
biodinamični koledar NE rabi lokacije** — kar je še dodaten offline/zasebnostni plus. (Klimo/sezono
Tendask itak že rešuje prek H3 + vremena + frost-anchor drugje.)

## 6. Umestitev v aplikacijo (kje je najbolj smiselno)

Ker je element dneva poceni re-izpeljljiv, ga pokažemo na več mestih brez stroška shrambe.

> **Korekcija prioritete (lastnik):** **večdnevni pogled naprej je JEDRO, ne dodatek.** Vrednost
> koledarja je *planiranje vnaprej* (»kdaj je naslednji dober dan«), ne le retrospektivna nalepka.
> Zato je namenski mesečni/tedenski zaslon (§6.2) del jedra, ne odloženi »V2-b«.

### 6.1 Kontekstne oznake (ponovna uporaba obstoječih zaslonov)

1. **Korak »Kdaj« v vnosu opravila** (`tasks/presentation/entry/…`, `when` korak) — **najvišja
   vrednost.** Kdor dela po luni, izbere datum **zato ker** je pravi element. Ob izbranem datumu
   pokaži medlo oznako (npr. »🌱 List« / »Koren do 14:20, nato List«). To dejansko **podpira
   načrtovanje**, ne le retrospektive.
2. **Detajl opravila** (`tasks/presentation/task_detail_screen.dart`) — oznaka element-dneva ob
   datumu, **vzporedno z vremenskim posnetkom** (§7.10). Naravno mesto: »to opravilo je bilo na
   plodov dan«. Nizek trud, dober kontekst. **Opozorilo:** element **NE zamrzujemo** kot vreme —
   re-izpeljemo iz datuma opravila (če uporabnik datum spremeni, se posodobi).
3. **Domov — današnji element** (`home/presentation/home_screen.dart`) — kompakten čip ob vremenski
   sekciji: »Danes: Koren«. Pomaga pri odločitvi »kaj danes«. Nizek trud. (Ni `EmptyState`; inline
   dashboard hint — CLAUDE.md komponentni katalog.)

### 6.2 Večdnevni koledar — JEDRO (namenski zaslon)

4. **Namenski zaslon »Tendask lunin koledar«** (nov, npr. `features/moon/` → `/moon-calendar`) —
   **tedenski trak + mesečni pregled** naprej: element vsak dan (+ faza, opcijsko dvigajoča/spuščajoča
   in neugodni dnevi) + legenda. To je »dom« funkcije in glavno mesto za planiranje. Vstopna točka iz
   Domov (čip »Danes: Koren« → tap) in/ali Dnevnika/Nastavitev. Pazi na barvno dostopnost (ikona+oznaka,
   ne samo barva) in layout matriko (nemške oznake so daljše).
5. **Pika/ikona elementa v obstoječem mesečnem koledarju Dnevnika**
   (`journal/presentation/month_calendar_view.dart`) — nenavsiljiv indikator ob dnevih, da se koledarja
   ne podvaja. (Če se prekriva z namenskim zaslonom, izberi eno primarno mesto — glej §8.)

### 6.3 Akcijske integracije (glavni razlog, da je to v aplikaciji, ne v knjigi)

6. **Pol-avtomatsko opravilo iz koledarja** — tap na dan → **predizpolnjeno opravilo** na ta datum
   (»Setev« na plodov dan). **Vedno »pol« (uporabnik potrdi), nikoli auto-create** (usklajeno z M11:
   predlogi, ne samodejna opravila). Ponovna uporaba `categoryMatrix` + `coarsePlantCategory` (že
   obstajata): plodov dan → predlagaj plodovke, koren dan → korenovke.
7. **»Kdaj je naslednji dober dan za X« (obratni iskalnik)** — izbereš rastlino/opravilo → koledar
   označi prihajajoče primerne dni. Najbolj akcijska poteza za planiranje; nadgradnja točke 6.
8. **Personalizacija po vrtu** — z `user_plant` kategorijami poudari dneve, relevantne za to, kar
   uporabnik **dejansko goji** (korenovke → poudari koren-dneve). Skoraj brez stroška (podatek imamo).
9. **Nežno obvestilo »jutri je dober list-dan«** — **opt-in**, spoštuje tihe ure/frekvenčno kapico;
   ponovna uporaba infrastrukture FR-16 (nudge). Brez tega hitro postane nadležno.
10. **Kratka razlaga »kaj je to«** — mini pojasnilo sistema (kot `prc-lu.si`) dvigne uporabo pri
    tistih, ki biodinamike ne poznajo. Poceni, na namenskem zaslonu.
11. **Retrospektivni vpogled (pozneje):** ker že zamrzujemo vreme (§7.10) + T11 pridelek, dolgoročno
    »tvoj najboljši pridelek je bil sejan na plodov dan«. **Previdno — opažanje, ne znanstvena trditev.**

### 6.4 Nadzor
- **Opt-in stikalo** v Nastavitvah (`settings`): »Prikaži biodinamični koledar« (privzeto **off** ali
  ob-onboardingu vprašano — odločitev §8). Vzorec obstaja (`kSuppliesEnabled` feature-flag / nastavitve).
  Ko je off, se oznake nikjer ne kažejo → uporabnik, ki ne dela po luni, ni obremenjen s šumom.
- Kasneje morebitna **izbira koledarskega sistema** (§8) živi tu.

## 6.5 Faznost in monetizacija

**Zdaj (nabiranje uporabnikov) = VSE FREE.** Billing/IAP še ne obstaja (`tendask-monetization-planned`,
»slej ko prej«), zato je vse brezplačno tako ali tako. Spodnja meja je **zapis namere za takrat, ko
pride plačilna infrastruktura**, ne stikalo, ki bi ga vklopili zdaj. To NI vezano na launch (aplikacija
je že v produkciji) — je stvar prioritizacije in kasnejše monetizacije.

**Meja (odločeno v2, 2026-07-22): mena free, element-dan premium.**

| **Free** (za vse — kavelj, navada) | **Premium »Tendask+«** (dobre/želene akcije) |
|---|---|
| **Mena Lune (faza)** — čip na Domov + ikona | **Element-dan** (dan za plod/list/…) na opravilu + koledarju |
| Razlaga »kaj je to« | Večdnevni/mesečni **planer** (§6.2) |
| | »Naslednji dober dan za X« (§6.3.7) |
| | Pol-avto opravilo iz koledarja (§6.3.6) |
| | Personalizacija po vrtu (§6.3.8) |
| | Dvigajoča/spuščajoča + neugodni dnevi |
| | Obvestila (§6.3.9) |

Načelo: izračun je poceni → **adut ni algoritem, ampak UX + integracija + planiranje**. Premium
entitlement se cachea v drift (offline-first, plačnik dela brez signala — `tendask-monetization-planned`).
Etapno: **najprej vse free** (mena + element-dan + planer), premium meja se prižge šele z monetizacijo.

## 7. i18n / brand

- Vsi nizi prek `t.*` (sl/en/de), `base_locale: en`. Ključi npr. `moon.element_root/leaf/flower/fruit`,
  `moon.today`, `moon.transition_at`, `moon.calendar_title`, `settings.moon_calendar_toggle`.
- Barve/ikone iz `theme/` (brez hardcode heksov). Predlog ikon: Koren 🥕 / List 🌿 / Cvet 🌸 / Plod 🍅
  ali monokromatske vektorske ikone iz teme; barvna kodiranost **vedno** podprta z ikono+oznako.

## 8. Odprta vprašanja (za odločitev ob implementaciji)

1. ~~**Meje ozvezdij** (znotraj sideričnega): IAU vs. enakih-30°; fino umerjanje rabi ~10 datumov.~~
   **RAZREŠENO (2026-07-22, §12):** dobili tiskani Thun 2024 (50 vstopov z uro) → **IAU realne meje so
   pravi model** (enakih-30° dokazano ne deluje). Čiste IAU = ~2 h; nevtralna kalibracija 3 mej
   (Tehtnica/Škorpijon/Strelec po svetlih zvezdah, **ne** po Thunovih številkah) → ~25 min. Privzeto
   siderični-IAU (§13).
2. **Kačenosec (Ophiuchus):** 12 vs. 13; obravnava kot prehod.
3. **Paket vs. lasten Meeus izračun** (odvisnost izven `tech-stack §1` → najprej vprašaj).
4. **Obseg jedra:** samo element-dan, ali takoj tudi faza lune (T10 »poceni raven« — enostavno,
   morda skupaj) in dvigajoča/spuščajoča?
5. **Neugodni dnevi** (vozli/perigej/mrki): MVP ali kasneje?
6. **Privzeto stanje stikala** (off vs. onboarding-vprašanje) in ali vprašati o sistemu.
7. **Izbira med koledarji** (T10 lastnikova ideja): če kdaj več sistemov, vsak ima svoje meje —
   ločen podspec; za zdaj **en** (izračunan siderični).
8. ~~Dokončno ime~~ — **odločeno: »Lunin koledar«** (in-app) + »Tendask biodinamični lunin koledar«
   (polna oblika). Glej §3.2.
9. **Primarno mesto večdnevnega pogleda:** namenski zaslon (§6.2.4) vs. indikator v obstoječem
   dnevniškem koledarju (§6.2.5) — da se koledarja ne podvaja.

## 9. Testiranje

- **Unit (obvezno):** `dayFor(date)` proti **znanim referenčnim datumom** (element + ura prehoda),
  z injiciranim časom; robni primeri (prehod tik čez polnoč, prestop leta). Ker ni mreže/sheme, je
  vse čisto in CI-prijazno.
- **Widget:** oznaka na detajlu/domov/when-koraku se izriše; off-stikalo skrije.
- **Layout matrika:** nov zaslon (§6.2.5) doda `layoutMatrix(...)` klic (sl/en/de × text-scale) —
  nemške oznake (»Blütentag« ipd.) so daljše.

## 10. Kaj je NAMERNO zunaj obsega

- Kopiranje/izpeljava iz Thuninega izdelka (pravno).
- Vključitev lune v M11 motor (predlogi).
- Shranjevanje/sync element-dneva (re-izpeljljiv iz datuma).
- Lokacijska prilagoditev (globalno; §5).
- Znanstvene trditve o učinku (pozicioniranje = tradicija/preferenca).

## 11. Odločitve iteracije v2 (2026-07-22) — usklajeno z wireframom

Vir: `docs/wireframes/lunar-calendar_overview.html` (v2). Te odločitve nadgrajujejo §0.

### 11.1 Semantika besedil (poenoteno)
Uveljavljena slovenska fraza je **»dan za plod / list / cvet / korenino«** (NE »plodov dan« — sliši se
narobe). Singular »dan za plod«, plural/splošno »dnevi za plod«. Kratka oznaka v celici = del rastline
(`plod` / `list` / `cvet` / `korenina`). Vir potrjuje raba na slov. setvenih koledarjih (Delo in dom,
vsezamojdan.si). i18n ključi naj sledijo tej frazi (`moon.day_for_fruit/leaf/flower/root`).

### 11.2 Free vs premium meja (v ponovnem premisleku — glej §15)
> **Opomba (2026-07-22):** konkurent posadi.si daje setveni koledar **zastonj** (§15) → »element-dan =
> premium« je šibka prodajna točka. Meja je znova odprta: verjetno **element-dan tudi free** (kavelj),
> premium = **napredni sloji** (planer, obratni iskalnik, dvižna/padna, neugodni, obvestila). Odločitev
> pending; spodnje je prvotni v2 predlog.
- **Mena Lune (faza) = FREE za vse** — ikona (dinamični SVG) + faza na čipu Domov. Nedvoumna, poceni,
  gradi navado.
- **Element-dan (dan za plod/list/…) + koledar/planer + akcije = premium (Tendask+).**
- Čip na Domov je viden **v obeh stanjih** (prodajna površina): z T+ desno »dan za list ›« → koledar;
  brez T+ desno rdeče »✦ Tendask+ ›« → zaslon Tendask+.

### 11.3 Aktivacijski model = licenčna koda (zunanji nakup)
> **Avtoritativni vir za licenciranje/plačila = FR-20** (`docs/feature-requests/tendask-plus-licensing.md`).
> Tu povzemamo le vpliv na Lunin koledar; podrobnosti (MoR, podpisan offline token, unovčitev, Play App
> access) so v FR-20.
- **Odločeno:** Tendask+ se aktivira z **licenčno kodo**. Google dovoli prodajo digitalnih licenc
  **izven IAP**, a **aplikacija ne sme kazati/povezovati na stran, kjer se nakup opravi** (anti-steering).
- Zato zaslon Tendask+ (brez licence) vsebuje **samo vnos kode + »Aktiviraj« + opis ugodnosti** —
  **NOBENEGA** gumba »Kupi«/URL-ja do nakupa. Kodo uporabnik pridobi drugje in jo prilepi.
- Z licenco: prikaz **veljavnosti (datum do)** + skupina T+ funkcij (prva »Lunin koledar« → nastavitve).
- Veljavnost cachana v drift (offline). **Pred vklopom še enkrat preveri aktualno Play politiko.**

### 11.4 Vstopne točke / CTA
- **Primarni:** čip na Domov (mena + CTA glede na naročnino).
- **Sekundarni:** segment/vstop v **Dnevniku** (koledar je soroden dnevniku).
- **Tendask+ zaslon:** Domov **⚙️ → Tendask+** (in iz rdečega CTA čipa).
- **Obratni iskalnik** (»Kdaj za …«): **🔎 v vrhu koledarja** + iz **detajla rastline**.
- **Lunin koledar nastavitve:** znotraj **Tendask+ → Lunin koledar** (dvonivojski opt-in).

### 11.5 Opisi dejavnosti na koledarju
- Mesečna mreža je pretesna za tekst → **»Teden« = agenda seznam** z opisom dejavnosti na vsak dan.
- **Besedila so NAŠA lastna** (splošna povezava element→dejavnost je prosta tradicija; **objavljenih
  dnevnih tekstov iz »Luninih bukev« NE prepisujemo** — pravno). Predlog: **fiksen nabor kratkih opisov
  na element** (4 osnovni + variacije setev/presaditev/spravilo) v i18n, **ne** per-dan proza.

### 11.6 Dan podrobno — več informacij
Blok »Kaj se dogaja«: v katerem **ozvezdju/elementu** je Luna (+ slov. imena Strelec/Kozorog…), **ura
prehoda** v naslednji element, pomen **mene** in **dvigajoče/spuščajoče**, oznaka **ugodnosti** (vozel/mrk).

**Besedila NE pišemo dvakrat (tropsko vs siderično).** »Kaj se dogaja« je **predloga s sloti**, ki jih
napolni izračun glede na izbrani sistem — ne ločeni kompleti proze:
- **Sistem-odvisni sloti (samodejno iz izračuna):** ime ozvezdja/znamenja, element-dan, ura prehoda.
- **Sistem-neodvisno (isto v obeh):** mena, dvigajoča/spuščajoča, neugodni dnevi (vse čista astronomija),
  in **opisi dejavnosti** (vezani na **element**, ne na datum) ter mapping ogenj→plod itd.
- **Edina besedna niansa:** siderično = »**ozvezdje**« (Sternbild), tropsko = »**znamenje**« (Sternzeichen)
  → dve i18n varianti ene besede. Vse ostalo isto.
- **Nizek strošek avtorstva:** enkrat (sl/en/de) napišeš imena 12–13 ozvezdij/znamenj, 4 element-besede,
  predloge »kaj se dogaja«, opise dejavnosti na element, + variantno besedo ozvezdje/znamenje.
- **Invarianta:** **en `system` vodi VSE zaslone hkrati** (mreža, čip, dan podrobno, opisi) — nikoli mešano;
  ob preklopu se posodobi cel koledar. Zato `dayFor(date, system)` in isti `system` skozi vse.
- Neobvezno: majhna značka **»po ozvezdjih« / »po znamenjih«** v dnevu (transparentnost).

### 11.7 Mena kot dinamični SVG
Meno rišemo iz deleža osvetljenosti (0–100 %) kot krivuljo terminatorja — čist SVG, brez slik, offline;
enako v koledarske celice in čip.

## 12. Validacija astronomije (2026-07-22) — prototip `tmp/moon_thun_test.py`

Preizkusili smo, ali izračun lege Lune drži in kako se ujema z objavljenimi koledarji.

### 12.1 Motor je dokazano pravilen (5 neodvisnih testov)
| Test | Obdobje | Rezultat |
|---|---|---|
| Meeus primer 47.a (zlati standard lege Lune) | 1992 | napaka **0,003° (11,8″)** |
| Mlaji/ščipi vs avtoritativna astronomija | 2026 | **1–3 min** |
| rhythmofnature (biodinamični koledar) | jul 2026 | tropsko **9/9** |
| hermetikon (znamenja Lune) | jul 2026 | **31/31** |
| hermetikon (drug mesec+leto) | mar 2027 | **31/31** |

Sklep: izračun Lune/Sonca/faze je pravilen do kotne sekunde/minute, potrjeno čez 1992/2026/2027.
**Napaka v računanju NI vir odstopanj.**

### 12.2 Splet je tropski, tiskana Thun je siderična
- Naivni tropski model vs realna ozvezdja: **12,6 %** ujemanja (precesija ~24°).
- **Vsi preizkušeni spletni koledarji** (rhythmofnature, hermetikon, celo garteln.com, ki se oglašuje kot
  »siderični po Mariji Thun«) izpisujejo **tropske** podatke → naš tropski model se z njimi ujame 9/9…31/31.
- **Prava tiskana _Setveni priročnik Marije Thun_ je siderična.** Spletno je siderični per-dan vir
  nedobavljiv (»siderični« kloni so v resnici tropski) — zato je bila **tiskana knjiga edini pot** do
  siderične kalibracije.

### 12.3 KALIBRACIJA proti tiskani Thun 2024 (2026-07-22) — `tmp/moon_calibrate.py`
Iz fotografij tiskanega priročnika (stolpec »Luna pred ozvezdjem« = ozvezdje + **ura vstopa**) smo
prebrali **50 vstopov Lune v ozvezdje iz 4 mesecev 2024** (jan, feb, avg, dec — oba časovna pasova,
CET+CEST; DST upoštevan). Za vsak vstop primerjamo Thunovo uro z izračunano.

**Rezultat — siderični-IAU je pravi model, siderični enakih-30° NE:**

| Model mej | jan+feb (kalibracija) | avg+dec (neodvisna validacija) |
|---|---|---|
| Siderični **enakih-30°** (Lahiri/fit ayanamsa) | MAE 6,6 h, ponekod 18–23 h ✗ | — (strukturno napačen) |
| **IAU realne meje — čiste** | 8/12 mej < 1,5 h | **2,36 h**, 18/25 < 2 h |
| **IAU realne meje — kalibrirane (3 meje)** | **0,18 h**, 25/25 | **0,41 h (25 min), 25/25** |

- **Enakih-30° dokazano ne deluje** (Thun uporablja realna **neenaka** ozvezdja) — to zapre dilemo §4.2.
- **Čiste IAU meje** (javno astronomsko dejstvo) že dajo ~2 h → dnevni element se ujame ~90 %+.
- **Nevtralna kalibracija 3 mej** (Tehtnica/Škorpijon/Strelec — območje Kačenosca, kjer IAU odstopa
  za 2–4°) potisne napako na **~25 min**. Kalibrira se po **svetlih zvezdah**, ne po Thunovih številkah (§3).

**Navzkrižna validacija (obe smeri kalibracije):** nastavi na jan+feb → test avg+dec = 0,41 h; **obrni**
(nastavi na avg+dec → test jan+feb) = **0,37 h** — simetrično. Meje, izpeljane iz zime, se ujemajo z
mejami iz poletja na **~0,3°** (par minut). → model **ni prilagojen določenim mesecem** (ni overfit) in
je **časovno stabilen** (precesija ~1,5 min/leto, že vključena).

### 12.4 Sosednje osi in 2026
- **Dvigajoča/spuščajoča** (§4.5) potrjena proti Thunovemu »času za presajanje«: **96 % / 100 %** (jan/feb 2024).
- **Vizualna primerjava dec 2026** (kalibrirani model) vs **Ajda Thun 2026** (siderični tiskani koledar):
  dan-za-dnem ujemanje → model drži tudi za leto, ko app teče.

### 12.5 Kje pride do odstopanja in kako ga obvladamo
- **Glavni vzvod = EN parameter:** tropsko ↔ siderični-IAU. Trivialno nastavljivo (`system`).
- Znotraj sideričnega: realne neenake meje + **prehodni dnevi** (~44 % dni ima prehod znotraj dneva —
  označi »do 14:20 …, nato …«) + enkratna nevtralna kalibracija 3 mej. **Dodatnih virov ne rabimo** —
  4 meseci × obe smeri × 2026 = dovolj.

## 13. Toggle sistema: tropski / siderični (odločeno 2026-07-22)

Ker je trg razdeljen (splet ≈ tropski, tiskana biodinamika = siderični), ponudimo **preklop sistema**.
To ni kompromis — uporabnika ujame s koledarjem, ki mu sledi.

- **Poimenovanje po MEHANIZMU, ne po znamki** (licence): npr. **»Po ozvezdjih (biodinamični)«** (siderični)
  in **»Po znamenjih (astrološki/klasični)«** (tropski). **NIKJER »Thun«/»Aussaattage«** (znamka).
  »Biodinamični« je generičen opis metode (OK).
- **Umestitev:** v naprednem delu nastavitev Luninega koledarja (ne spredaj) + **ena vrstica razlage**;
  večina uporabnikov razlike ne pozna.
- **Privzeto = siderični-IAU** (obrat glede na prvotni osnutek, **po kalibraciji §12.3**). Razlog:
  ciljni SI trg primerja z **tiskanimi** koledarji (Thun / Ajda / Miler), ki so **siderični** — to je
  authentic-biodynamic pozicioniranje in kalibrirano na ~25 min. **Tropski** ostane preklop za tiste,
  ki primerjajo splet (spletni ekosistem je tropski). *(Prej je bil predlog »privzeto tropski, umeri
  pred vklopom« — umerjanje je zdaj opravljeno, zato je siderični varno privzeti.)*
- Implementacija: en global param v isti čisti funkciji `dayFor(date, system)`; siderični-IAU = realne
  meje + nevtralno kalibrirane 3 meje (§14.5); tropski = `floor(λ/30)`.

## 14. Algoritem (validirani prototip)

Referenca za Dart implementacijo. Prototip (Python) je bil validiran (§12): Meeus primer 47.a **0,003°**,
mlaji/ščipi **1–3 min**, tropska znamenja **9/9…31/31**. Vse je **čista funkcija datuma**, brez mreže.
Ob implementaciji: **paket vs lasten Meeus izračun** je odprto (odvisnost izven `tech-stack §1` → vprašaj);
spodaj je lasten izračun, ki je bil preizkušen.

### 14.1 Osnove časa
- `T = (JD − 2451545.0) / 36525.0` (julijanska stoletja od J2000).
- JD iz koledarskega datuma: standardni Fliegel/Meeus algoritem. **Čas v UTC**, prek `Clock` (testabilno);
  za prikaz `.toLocal()`.

### 14.2 Ekliptična dolžina Lune (Meeus, pogl. 47 — skrajšano)
Srednji elementi (stopinje; standardne javne formule):
```
L' = 218.3164477 + 481267.88123421·T − 0.0015786·T² + T³/538841 − T⁴/65194000   (srednja dolžina)
D  = 297.8501921 + 445267.1114034·T  − 0.0018819·T² + T³/545868 − T⁴/113065000  (elongacija)
M  = 357.5291092 + 35999.0502909·T   − 0.0001536·T² + T³/24490000               (Sonce, srednja anom.)
M' = 134.9633964 + 477198.8675055·T  + 0.0087414·T² + T³/69699  − T⁴/14712000   (Luna, srednja anom.)
F  =  93.2720950 + 483202.0175233·T  − 0.0036539·T² − T³/3526000 + T⁴/863310000 (argument širine)
E  = 1 − 0.002516·T − 0.0000074·T²
```
Dolžina `λ = L' + (Σ l)/10⁶` stopinj, kjer je `Σ l = Σ cᵢ · E^|Mkoef| · sin(dᵢ·D + mᵢ·M + m'ᵢ·M' + fᵢ·F)`
čez **~36 največjih periodičnih členov** iz Meeus tabele 47.A (koeficienti so astronomsko dejstvo iz
ELP2000; **ne prepisuj tabele v spec — vzemi jo iz vira/knjižnice**). Faktor `E` velja za člene z `M≠0`
(potenca = |koef. M|). Nutacijo lahko izpustimo (~17″, zanemarljivo za določitev dneva). Preizkušeno:
`λ(JD=2448724.5) = 133.159°` vs Meeus 133.163° → napaka 0,003°.

### 14.3 Ekliptična dolžina Sonca (Meeus, pogl. 25 — nizka natančnost)
```
L0 = 280.46646 + 36000.76983·T + 0.0003032·T²
M  = 357.52911 + 35999.05029·T − 0.0001537·T²
C  = (1.914602 − 0.004817·T − 0.000014·T²)·sinM + (0.019993 − 0.000101·T)·sin2M + 0.000289·sin3M
λ☉ = (L0 + C) mod 360
```
Rabi se za meje IAU (§14.5) in za mene/faze (§14.6).

### 14.4 Element in zodiak
Element po ozvezdju/znamenju (klasični, prosti mapping):
```
ogenj → plod   (Oven, Lev, Strelec)
zemlja → korenina (Bik, Devica, Kozorog)
zrak → cvet    (Dvojčka, Tehtnica, Vodnar)
voda → list    (Rak, Škorpijon, Ribi)
```
Zaporedje znamenj od 0°: [plod, korenina, cvet, list] × 3.

### 14.5 Razmejitev (izbira = `system`; kalibrirano §12.3)
- **Siderični-IAU (PRIVZETO):** `λ` primerjaj s pragovi realnih **neenakih** ozvezdij. Baza = pragovi iz
  datumov vstopa Sonca (epoha 2000 + precesija `0.01397°/leto`). **Nevtralno kalibrirane 3 meje** (območje
  Kačenosca). **Empirični pragovi (°), izpeljani iz tiskanega Thun 2024** (Lunina λ ob dokumentiranih
  urah vstopa — referenca, ne za dobesedni prepis):
  `Ari 29.6 · Tau 54.0 · Gem 90.2 · Cnc 118.1 · Leo 139.1 · Vir 174.0 · Lib 219.9 · Sco 238.2 · Sgr 269.2 ·
  Cap 299.4 · Aqr 327.1 · Psc 352.3`. **8/12 mej je znotraj ±0,7° od surovih IAU**; odstopajo le Tehtnica
  (+2,2°), Škorpijon (−3,7°), Strelec (+3,0°) → te tri **kalibriraj po svetlih zvezdah** (ne po zgornjih
  Thunovih številkah — pravni §3), ostale pusti IAU.
- **Tropski (preklop):** `sign = floor(λ / 30) mod 12`. Za primerjavo s spletom.
- **Siderični enakih-30° — ZAVRNJEN** (§12.3): `floor((λ−ayanamsa)/30)`; dokazano se s tiskanim Thunom NE
  ujame (napaka do 18–23 h, ker Thun uporablja neenaka ozvezdja). Ne uporabljamo.
- **Kačenosec (Oph):** 12 vs 13 (§8) — obravnavaj kot prehod / združi s sosedom.
- **⚠️ Časovni pas / DST:** Thunove ure so **lokalne** (CET pozimi, **CEST poleti**). Izračun je v UTC;
  za primerjavo/prikaz upoštevaj poletni čas (sicer sistematičen 1 h zamik). V aplikaciji: `.toLocal()`.

### 14.6 Mena / faza (sistem-neodvisno)
- Elongacija `e = (λLuna − λ☉) mod 360`.
- Osvetljenost `illum = (1 − cos e)/2` (0 = mlaj, 1 = ščip).
- Mlaj/ščip = kjer `e` preide skozi `0` / `180`; poišči z vzorčenjem + bisekcijo. Preizkušeno na 1–3 min.
- Ta sloj je **enak v obeh sistemih** (astronomija, ne zodiak).

### 14.7 Prehodni dnevi
Dan ni vedno en element (43,8 % dni ima prehod). Izračunaj element ob **začetku in koncu lokalnega dneva**;
če se razlikujeta, poišči **uro prehoda** (bisekcija na meji) → prikaži »do HH:MM …, nato …«.

### 14.8 Podpis in izhod
```
BiodynamicDay dayFor(DateTime date, CalendarSystem system)
  → { constellation/sign,   // ime + je-ozvezdje/znamenje (za besedno varianto §11.6)
      element,              // plod/list/cvet/korenina
      transitionAt?, secondaryElement?,   // če prehod znotraj dneva
      phase, illumFraction, // mena (sistem-neodvisno)
      ascending?,           // dvigajoča/spuščajoča (deklinacija; sistem-neodvisno) — opcijsko
      unfavorable? }        // vozel/mrk/perigej — opcijsko
```
Čista funkcija v `core/` (npr. `core/biodynamic/moon_calendar.dart`), brez I/O, unit-testabilna proti
znanim datumom (Meeus primer + mene 2026). **`system`** je edini vzvod med tropskim in sideričnim.

### 14.9 Kaj je še odprto ob implementaciji
Paket vs lasten Meeus · Kačenosec 12/13 · ~~kalibracija sideričnih mej~~ (**razrešeno §12.3**) · nevtralni
vir za 3 kalibrirane meje (svetle zvezde) · dvigajoča/spuščajoča in neugodni dnevi (MVP ali kasneje).

## 15. Konkurenca — posadi.si (benchmark, 2026-07-22)

Glavni direktni konkurent na SI trgu. Skoraj enak nabor kot Tendask + setveni koledar »po Mariji Thun«.

**Kaj je (posneto na napravi + splet):**
- **>100.000 prenosov, 4,5/5**, slovenski razvijalec (Tehnološki park LJ), EN/DE/IT.
- **Setveni koledar »po Mariji Thun«** (koren/list/cvet/plod + **dvižna/padna pot Lune** + neugodni dnevi) —
  **potrjuje, da je naš nabor slojev (§4) pravi** in da je lasten izračun brez licence uveljavljen (pravni
  precedens #4 k §3.1: komercialna app, nikjer navedene licence Thun).
- Vreme, 60+ rastlin, opomniki, izmenjava semen, dobri/slabi sosedje, načrtovalec vrta, AI »Asistent«.
- **Zavihek »Znanje«** = strukturirane razlage rastlin (Pridelava/Lokacija/Količina/Čas sajenja, Wikipedia
  slike) — njihova prednost, naša vrzel → **FR-21** (`plant-knowledge-catalog.md`).

**Monetizacija:** freemium — **partnerski/native oglasi** (zadruge, drevesnice, vrtni centri, šole — NE
Google AdMob, direktni deali) + **PRO ~24 €/leto** + **promo kode** + skupinske/šolske licence.

**Diferenciatorji Tendaska** (pozicioniranje listinga/onboardinga — »mirno, zasebno, brez oglasov«, ne
»več funkcij«):
- **Brez oglasov** (posadi.si ima banner na vsakem zaslonu; Tendask Ads=No v Play).
- **Offline-first** (dela na vrtu brez signala) + **zasebnost** (H3 celica, nikoli surovih koordinat).
- **Razumljivost:** razloži sistem v naravnem jeziku + progresivno razkrivanje (posadi.si sistema ne razloži,
  niti tropsko/siderično) + **toggle sistema** (§13).
- **Cenovno sidro FR-20:** njihovih 24 €/leto (»ni visoka«) je referenca za letno Tendask+; doživljenjska ~2–3×.

**Free/premium posledica (vhod v FR-19 §6.5 in FR-20):** konkurent daje **koledar zastonj** (z oglasi) →
element-dan kot čisti premium je šibka prodajna točka; premium naj bo **napredno** (planer, obratni iskalnik,
dvižna/padna, neugodni, obvestila, personalizacija), ne osnovni kavelj. *(Meja ostaja odprta — glej §6.5.)*
