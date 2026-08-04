# FR-19 — odločitve za dorekniti PRED gradnjo (živ dokument)

> **Status:** faza poliranja zasnove · **ni implementacije.** Dobra zasnova zdaj = prihranjeno popravljanje
> kasneje. Ta dokument drži **le prave, še nerazrešene odločitve** — vsako s problemom, opcijami in posledicami.
> Ko katero dorečeva, jo označiva ✅ in vpiševa izbiro (+ v spec `biodynamic-calendar.md`).
>
> **Vir:** presek spec §8 (odprta vprašanja) + wireframe pregled + ikonske/barvne reči. Že razrešeno v §8
> (meje ozvezdij #1, ime #8, izbira sistemov #7) NI tu. Preverjeno 2026-07-23: nobena spodnja ni že odgovorjena.
>
> **Legenda statusa:** ⬜ ODPRTO · ✅ ODLOČENO · 🅿️ nagib (potrdi/spremeni).

---

## A. Prave odločitve (rabijo lastnika)

### A1 · Obseg slojev v prvi različici  ✅ ODLOČENO (2026-07-30): **C — vse 4 plasti**
**Z varovalko:** plast 4 (neugodni dnevi) je v planu implementacije ločen, zadnji korak motorja
(T1.9) — če se med potjo izkaže za predrago, se **zavestno izpusti** in doda kasneje (čista funkcija,
brez sheme — poceni naknadno). Odločitev o izpustu se sprejme ob koncu T1, ne tiho.
**Problem:** lunin koledar ima več neodvisnih »plasti«. Katere gremo delat najprej? Vsaka se da dodati
kasneje poceni (ni sheme/synca).
- **Plast 1 — element dneva** (plod/list/cvet/korenina): jedro, gotovo notri.
- **Plast 2 — mena/faza Lune** (čip Domov): poceni vizualni kavelj, praktično že v jedru.
- **Plast 3 — dvigajoča/spuščajoča Luna:** druga os — pove *katero opravilo* (dvigajoča = setev/nabiranje,
  spuščajoča = presajanje/delo v tleh). Astronomsko potrjena (96–100 %).
- **Plast 4 — neugodni dnevi** (vozli/mrki/perigej): oznake »danes raje počivaj«.

**Opcije in kaj pomenijo:**
- **A) Minimalno** = plast 1+2 → najhitreje na napravo; ostalo kasneje.
- **B) Srednje** = +plast 3 → bližje pravemu biodinamičnemu koledarju (Thun/posadi.si).
- **C) Polno** = +plast 4 → najbolj verodostojno, a največ izračuna, UI in testov.

**Nov argument (2026-07-30):** po ustavitvi M11 Plus **starta enofunkcijski** — lunin paket mora ob
poteku darila sam upravičiti ~10 €/leto (FR-20 §11.1) → govori za B ali C, proti A.

**Predlog:** B. · *(spec §8.4, §8.5)*

### A2 · En koledar ali dva (kje »živi« koledar)  ✅ ODLOČENO (2026-07-31): **C — oboje, Dnevnik-plast že v v1**
**Izvedba:** namenski `/moon-calendar` = dom (planiranje); Dnevnik dobi **🌙 gumb v AppBar** (vstop v
koledar) in **barvno plast** v svoji mesečni mreži (orientacija — tap na dan ostane dnevniški dan, ne
lunin), za stikalom »Prikaži v Dnevniku«. Koledarja se ne kanibalizirata: plast je samo barva+mena.
**Problem:** naredila bova **namenski lunin zaslon**; v **Dnevniku** pa že obstaja mesečni koledar. Ga tudi
obarvava z lunino plastjo, ali pustiva?
**Opcije in kaj pomenijo:**
- **A) Samo namenski zaslon** → čisto, ena lokacija; a v Dnevniku lune ni.
- **B) Samo obarvan Dnevnik** → brez namenskega; izgubiš planerske reči (teden z opisi, iskalnik).
- **C) Oboje** → namenski = »dom« za planiranje, Dnevnik dobi medel indikator (orientacija ob opravilih);
  največ vrednosti, a dve mesti za vzdrževati.

**Predlog je bil:** C z odlogom plasti na V2 — lastnik odločil **C brez odloga** (plast v v1). · *(spec §8.9; wireframe board C)*

### A3 · Motor: lastna koda ali gotov paket  ✅ ODLOČENO (2026-07-30): **A — lasten izračun**
**Problem:** za položaj Lune je treba računati. To je edino mesto z morebitno novo knjižnico — CLAUDE.md
zahteva, da **najprej vprašam**.
**Opcije in kaj pomenijo:**
- **A) Lasten izračun** (Meeusove formule, ~par sto vrstic Darta). Prototip **že validiran** (0,003°) →
  nič novih odvisnosti, offline-varno, sama testirava.
- **B) Gotov astro paket** → manj kode, a nova odvisnost izven `tech-stack §1` (preveriti, pin, tveganje
  mrtve lib-e).

**Pod-točka (tehnična):** Kačenosec (Ophiuchus) — 12 ali 13 ozvezdij; predlog: obravnavaj kot prehod. *(§8.2)*
**Predlog:** A. · *(spec §8.3, §4.6, §14.9)*

### A4 · Barve elementov v temi (dark + 6 palet)  ✅ ODLOČENO (2026-07-31): A — fiksne semantične

Svetle vrednosti iz wireframa v2, temne po vzorcu terakote (svetlejši poudarek + zamolkel temen
container); konkretne vrednosti = `lib/app/theme/moon_colors.dart` (vir resnice). Fino nastavljanje
temnih ob prvem vizualnem pogledu v T3.

**Izmerjeni WCAG kontrasti (2026-07-31, poudarek kot BESEDILO na svojem soft ozadju):** svetla
tema — korenina 4,4:1 (meja), plod 3,0:1, list 3,1:1, **cvet 1,8:1 (pade)**; temna tema OK (cvet
6,2:1). Podedovano iz wireframa. **Omejitev za T3:** poudarek na soft ozadju samo za ikono/glif;
tekstovni napisi na soft ozadju v `onSurface` (skladno z `ElementBadge` pravilom »nikoli samo
barva«) ali pa se ob vizualnem pregledu uvedejo `onXxxSoft` toni po vzorcu `onTerracottaSoft`.
**Problem:** 4 elementi so barvno kodirani. App ima svetlo+temno temo in **6 palet**. Fiksni pasteli iz
wireframa v temni temi ne delujejo dobro.
**Opcije in kaj pomenijo:**
- **A) Fiksne semantične barve** — isti 4 odtenki povsod, s temno varianto (kot terakota za napake) →
  preprosto, element = prepoznaven pomen; a se ne »ubere« z izbrano paleto.
- **B) Palettno-odvisne barve** → lepše integrirano, a 6×2 = 12 kombinacij za uskladiti + tveganje slabe
  berljivosti.

**Predlog:** A. · *(ni v §8; iz wireframe pregleda + [[tendask-theme-palettes]])*

### A5 · Ikone elementov: emoji ali lasten vektor  ✅ RAZREŠENO (2026-07-31): **A — emoji** (fallback po pogoju)
**Izid pogoja (2026-07-31, pogled predogleda T3.2):** vektorski osnutki (jabolko/korenček/rozeta/list
kot `CustomPainter`) lastnika niso prepričali (»niti malo razumljive«) → velja dogovorjeni fallback A
(emoji 🍅🥕🌸🌿, isti kot wireframe). API `ElementBadge` vir skriva; glif živi samo v `elementEmoji()`
(`element_badge.dart`). Prvotni pogoj: T3.2 začne z **osnutki 4 monokromatskih vektorskih ikon**
(pravilo »poglej, preden vlagaš«); če osnutki ne prepričajo, fallback = A brez spremembe API-ja.
**Problem:** za 4 elemente rabiva ikone.
**Opcije in kaj pomenijo:**
- **A) Emoji** 🍅🥕🌸🌿 → zastonj, a **🌸 in 🌿 že označujeta rastline** v katalogu → možna zmeda (element
  vs. rastlina).
- **B) 4 lastne monokromatske vektorske ikone** → čisto, brez trka; treba narisati/najti.

**Predlog:** nagib k B (če je trk moteč); A hitrejši za MVP. · *(spec §7 omenja obe možnosti)*

### A6 · Privzeto stanje stikala + odkritje  ✅ ODLOČENO (2026-07-31): A — privzeto vklopljeno
**Problem:** koledar je opt-in. Privzeto vklopljen ali izklopljen? Če izklopljen, čipa na Domov ni →
uporabnik funkcije ne odkrije.
**Opcije in kaj pomenijo:**
- **A) Privzeto VKLOPLJEN** → čip na Domov je viden, funkcija se odkrije sama; kdor ne dela po luni, jo
  izklopi. (Ob darilnem modelu — B2 — čip kaže free meno + podarjen Plus del; odkritje je hkrati
  predstavitev Plusa, kar govori ZA vklopljeno.)
- **B) Privzeto IZKLOPLJEN** → app čist za tiste brez zanimanja; a nihče je ne odkrije brez brskanja.
- **C) Vprašaj ob onboardingu** → eksplicitno, a doda korak.

**Predlog:** A. · *(spec §8.6; prvotna utemeljitev »ker je zdaj vse brezplačno« je presežena z B2 —
argument zdaj teče prek darila.)*

---

## B. Nagib — potrdi ali spremeni (niso prave dileme)

- **B1 · Nastavitve koledarja lokalno** (device-local, ne sync) — koledar je globalen, ni uporabniški
  podatek. Skladno z »nič synca« (§2). ✅ **Meja za obvestila razrešena (2026-08-01, lastnik, ob T4b):**
  **dostava je device-local** (razporeja naprava prek `flutter_local_notifications`, brez FCM, brez
  crona, brez oblačne sheme — motor je čista funkcija datuma in dela brez signala), **opt-in stikalo 🔔
  pa gre v `NotificationSettings`** (profile JSON, sinhroniziran), da sledi uporabniku med napravami;
  ker je stolpec JSON in je parser tolerantno pisan, nova vrednost **ne rabi migracije**. **Frekvenčna
  kapica velja samo za namige** (lunin namig + dnevniški nudge si ne delita dneva); eksplicitni
  opomnik opravila dneva ne zasede, ker ga je uporabnik nastavil sam (koncept: »max 1 ne-opomnik/dan«).
  ✅ **Ritem namiga razrešen (2026-08-01, lastnik, ob T4b koraku 2):** namig pride **samo za dneve, ki
  jih vrt lahko uporabi** — element dneva mora biti med `gardenElements` (isto pravilo kot ★ v mreži),
  prazen vrt = brez namigov; ura je **18:00 dan prej** (zunaj tihih ur, isto območje kot dnevniški
  nudge ob 17:00). Zavrnjeni varianti: »vsak večer za jutri« (365 obvestil/leto) in »samo ob menjavi
  elementa« (neodvisno od vrta). Posledica izbire: pri nizu 2–3 dni istega elementa pride namig vsak
  večer tega niza.
- **B1a · Mena je free za vedno** ✅ ODLOČENO (2026-08-01, lastnik): ob prižigu Plusa (T6) se čip na
  Domov **ne** zaklene v celoti — mena (ikona + ime faze) ostane vidna vsem, za zid gre samo
  element-dan (CTA »dan za X ›« → »✦ Tendask+ ›«) in vse površine, ki element kažejo (koledar, sheet,
  when-step, task-detail, Dnevnik-plast). Razlog: mena je edini free kavelj (§6.5); dobesedni
  »gate swap« bi jo pobrisal. Zapisano kot izrecno opozorilo v planu T6 korak 6.
- **B2 · Tendask+ zaklep** ✅ ODLOČENO (2026-07-30, nadomešča prvotni nagib »najprej vse free«): lunin
  Plus del **debitira zaklenjen** (gradi se za flagom, dark) — NE izide free. Ob prižigu vsi obstoječi
  profili dobijo **časovno omejeno darilo Tendask+** (predlog 6 mesecev; FR-20 §10.4). Med gradnjo (koraka
  1–2 rollout plana) je gate navaden `const` flag; `plusProvider` + board 2 / zaklenjeni čip / vnos kode
  pridejo z minimalno rezino FR-20 (korak 3) oz. komercialnim delom (korak 5).
- **B3 · Nadzor: mena vedno vidna, nastavitve kot razstavni salon** ✅ ODLOČENO (2026-08-03, lastnik,
  po pregledu koraka 6 na napravi): **glavno stikalo 🌙 »Prikaži Lunin koledar« odpade.** Razlog:
  mena je edini free kavelj in je kot teaser vredna več, kot je vredna možnost, da jo uporabnik
  skrije — zato je **vedno vidna, tudi Plus uporabniku**. Posledice: (a) element-oznake pri opravilih
  in v vrtu (when-korak, detajl opravila, čip rastline) dobijo **svoje, peto podstikalo** ob obstoječih
  štirih (🔔 · 🪴 · 📅 · 🌌) — Domova ne zadeva; (b) brez licence je `/moon-settings` **razstavni
  salon**: sistem + vseh pet stikal vidnih, a onemogočenih, s **privzetimi** vrednostmi (vsa
  vklopljena, sistem »Po ozvezdjih«), »Kaj je to?« pa vidna vedno; (c) pod segmentom sistema stoji
  opis **izbranega** sistema namesto ene splošne razlage (dva nova niza × 3 jeziki).
  S tem odpade tudi vprašanje, ali kartica »Kaj je to?« brez licence obljublja element-dan — stoji nad
  vidnimi (sivimi) stikali, ki ga prinesejo. Zapisano v spec §6.4; izvedba = plan T6 korak 6b.
- **B4 · Prižig gre z javno darilno kodo, ne s tihim masovnim grantom** ✅ ODLOČENO (2026-08-04,
  lastnik): namesto strežniške operacije, ki bi vsem profilom tiho vpisala `plus_until` (prvotni
  §6.6-C), se izda **ena sama javna koda**, razposlana po e-pošti vsem uporabnikom in objavljena na
  spletni strani. **Uporabnik jo mora vnesti sam.** Parametri: **absolutni datum 31. 12. 2026** (ne
  trajanje od unovčitve), **kapaciteta 2000 unovčitev** (dvig je `update` stolpca, ne migracija),
  **prodaja ostane ločena v T8**.
  **Zakaj:** (a) tiho darilo ni dogodek — kar uporabnik dobi, ne da bi opazil, ne šteje kot vrednost;
  (b) **nauči obreda pred plačilom** — ko koda 1. 1. 2027 poteče, je pot »Tendask+ → vnesi kodo« že
  znana in ni nova ovira ob prvem nakupu; (c) **delež unovčitev je edini pošten signal o
  povpraševanju**, ki ga dobiš, preden postaviš ceno (danes je cena v FR-20 §11.2 ugibanje na podlagi
  sidra Luninih bukev).
  **Kar s tem odpade:** masovni grant čez vse profile in množično kovanje žetonov · `review` koda kot
  poseben režim (§6.6: kapica ~20, rotacija, vklop ob oddaji, preklic po odobritvi) — recenzent dobi
  isto javno kodo, ker ni česa varovati · vprašanje gosta (§11.9) — sonda produkcije 4. 8. 2026 je
  pokazala **0 anonimnih računov**, vsi obstoječi uporabniki so prijavljeni.
  **Kar s tem nastane:** vnos kode se preseli iz T8 v **T7** · shema rabi **ločeno tabelo unovčitev**
  (`license_redemption`), ker današnji `license.redeemed_by`/`redeemed_at` predvidevata enkratno
  unovčitev · **kovanje žetonov postane obvezno** (doslej ročno; Ed25519 zna Edge Function, Postgres
  ne) · Play `App access` postane potreben že ob prižigu, a je lažji — navodilo je javna koda.
  ⚠️ **Sporočilo ob neuspehu ostane enotno** (»navedena koda/licenca ni veljavna«, FR-20 §6.5) tudi
  ob izčrpani kapaciteti — razlikovanje je bilo predlagano in **zavrnjeno** (lastnik: v bazo bo šel
  pogledat tako ali tako). Posledica: **strežnik mora razlog zapisati**, čeprav ga ne pove —
  `license_redeem_attempt` dobi stolpec `reason`, sicer je podpora ugibanje.
  ⚠️ **Unovčitev mora vrstico v `profile` ustvariti, če je ni.** Sonda 4. 8. 2026: 122 računov proti
  109 profilom = **13 računov (11 %) brez profila**; brez upserta bi vsakemu devetemu unovčitev padla.
  Vzrok teh 13 ni raziskan.

---

## C. Že dorečeno (referenca — NE odpirava znova)
Ime »Lunin koledar« · semantika »dan za plod/list/cvet/korenino« · pristop A (lasten izračun, brez Thuna) ·
**privzeto siderični** + toggle po mehanizmu (»Po ozvezdjih« / »Po znamenjih«) · brez sheme/synca/mreže/
lokacije · element se re-izpelje (ne zamrzuje) · vstopne točke (čip, Dnevnik, ⚙️→✦ Tendask+, 🔎) · aktivacija
= licenčna koda ([[tendask-lunar-calendar-fr19]], FR-20) · »✦ Tendask+« (ikona spredaj) + prihodnje = »Kmalu« ·
board C = prekrivna plast (ne nov koledar) · vrstni red board-ov · kalibracija sideričnih mej (§12.3) ·
**free/premium meja (2026-07-30):** mena free, element-dan + planer + akcije = Plus, debitira zaklenjen z
lansirnim darilom (spec §11.2, FR-20 §10.4) · **zaporedje gradnje (2026-07-30):** motor → UI dark → FR-20
minimalna rezina → prižig z darilom → trgovina (rollout plan) · **meje ozvezdij (2026-07-30):** kalibrirane
vseh 12 (0,26 h / 97 %), rezerva čiste IAU; izvor + pravni zagovor v `biodynamic-calendar-boundaries.md` ·
**Kačenosec:** zajet v meji Sco→Sgr · **dnevna oznaka = element ob začetku dneva** (spec §12.6) ·
**uskladitev z wireframom (2026-07-31, lastnik):** personalizacija »poudari po mojem vrtu« + ★ v mreži
**v v1** (mapping kategorija→element = T5.1, izvede se pred mrežo T3.3) · dan podrobno = **sheet z
drsenjem** (revizija sheet↔zaslon ob prvem pogledu na napravi) · sheet vsebuje seznam »Priporočeno
za …« s »＋ opravilo« vrsticami · lunino obvestilo »jutri dober dan« **v v1 kot lasten task** (tihe ure +
frekvenčna kapica morata z njim zaživeti; B1 meja device-local/sync se odloči tam; do takrat vrstice v
nastavitvah NI — brez mrtvih stikal) · navigacija: `/moon-calendar` = dom; ⚙️ v njegovem AppBar →
`/moon-settings`; Dnevnik = 🌙 AppBar gumb + plast (A2); when-step/task-detail oznaki info-only v v1.

## D. Delo, ne odločitev (opraviti ob gradnji)
- Napisati **lastne opise dejavnosti** (i18n sl/en/de, na element) — pravno ne prepis Luninih bukev.
- ✅ ~~Pridobiti nevtralne vrednosti 3 kalibriranih mej (po svetlih zvezdah).~~ **Opravljeno drugače
  (2026-07-30):** zvezdna izpeljava izmerjena kot slepa ulica; odločeno = **kalibrirane vseh 12 mej**
  (0,26 h / 97 %) s pravnim zagovorom — [`biodynamic-calendar-boundaries.md`](biodynamic-calendar-boundaries.md).
- Zgraditi **meno kot CustomPainter** (8 faz iz osvetljenosti).

---

*Poliranje: dorekniva po vrsti (predlog A1 → A2 → A3, nato A4/A5), vsako doreknjeno označiva ✅ + prenesva v
spec. Karta zaslonov: [[reference-screen-map]] · spec: `biodynamic-calendar.md` · wireframa: `docs/wireframes/lunar-calendar_*.html`.*
