# FR-19 — Biodinamični koledar (koren / list / cvet / plod)

> **Status:** spec (feature request) · 2026-07-21 · neimplementirano
> **Vir zahteve:** `docs/povratne-informacije.md` → Runda 2, **T10** (lunina mena / setveni koledar).
> **Ime izdelka:** »**Tendask biodinamični lunin koledar**« (lastna kompilacija, nevtralno poimenovanje).
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

### 4.5 Bogatejši sloji (za še boljši približek — kandidati, ne nujno MVP)
- **Dvigajoča / spuščajoča Luna** (deklinacijski ~27,3-dnevni ciklus) — **ločena os** od element-dneva;
  Thun jo posebej objavlja (setev vs. presajanje/rez).
- **Neugodni časi:** bližina **vozlov** (mrki), **perigej/apogej**, mrki. Thun te dni odsvetuje;
  označitev bistveno približa videz pravega koledarja.

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

| Kasneje **Free** (kavelj, navada) | Kasneje **Premium »Tendask+«** (dobre/želene akcije) |
|---|---|
| Današnji element + faza (Domov) | Večdnevni/mesečni planer (§6.2 zaslon) |
| Nalepka element-dneva na opravilu (§6.1) | »Naslednji dober dan za X« (§6.3.7) |
| Osnovni pogled koledarja | Pol-avto opravilo iz koledarja (§6.3.6) |
| | Personalizacija po vrtu (§6.3.8) |
| | Dvigajoča/spuščajoča + neugodni dnevi |
| | Obvestila (§6.3.9) |

Načelo: izračun je poceni → **adut ni algoritem, ampak UX + integracija + planiranje**. Premium
entitlement se cachea v drift (offline-first, plačnik dela brez signala — `tendask-monetization-planned`).
Etapno: **najprej jedro free** (izračun + večdnevni zaslon + oznaka na opravilu), šele nato premium sloj.

### 6.3 Nadzor
- **Opt-in stikalo** v Nastavitvah (`settings`): »Prikaži biodinamični koledar« (privzeto **off** ali
  ob-onboardingu vprašano — odločitev §8). Vzorec obstaja (`kSuppliesEnabled` feature-flag / nastavitve).
  Ko je off, se oznake nikjer ne kažejo → uporabnik, ki ne dela po luni, ni obremenjen s šumom.
- Kasneje morebitna **izbira koledarskega sistema** (§8) živi tu.

## 7. i18n / brand

- Vsi nizi prek `t.*` (sl/en/de), `base_locale: en`. Ključi npr. `moon.element_root/leaf/flower/fruit`,
  `moon.today`, `moon.transition_at`, `moon.calendar_title`, `settings.moon_calendar_toggle`.
- Barve/ikone iz `theme/` (brez hardcode heksov). Predlog ikon: Koren 🥕 / List 🌿 / Cvet 🌸 / Plod 🍅
  ali monokromatske vektorske ikone iz teme; barvna kodiranost **vedno** podprta z ikono+oznako.

## 8. Odprta vprašanja (za odločitev ob implementaciji)

1. **Meje ozvezdij:** IAU realne (priporočeno) vs. siderični enakih-30°. → vpliva na vernost.
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
