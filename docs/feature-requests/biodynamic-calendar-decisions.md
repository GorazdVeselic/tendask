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

### A1 · Obseg slojev v prvi različici  ⬜ ODPRTO
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

**Predlog:** B. · *(spec §8.4, §8.5)*

### A2 · En koledar ali dva (kje »živi« koledar)  ⬜ ODPRTO
**Problem:** naredila bova **namenski lunin zaslon**; v **Dnevniku** pa že obstaja mesečni koledar. Ga tudi
obarvava z lunino plastjo, ali pustiva?
**Opcije in kaj pomenijo:**
- **A) Samo namenski zaslon** → čisto, ena lokacija; a v Dnevniku lune ni.
- **B) Samo obarvan Dnevnik** → brez namenskega; izgubiš planerske reči (teden z opisi, iskalnik).
- **C) Oboje** → namenski = »dom« za planiranje, Dnevnik dobi medel indikator (orientacija ob opravilih);
  največ vrednosti, a dve mesti za vzdrževati.

**Predlog:** C, a Dnevnik-plast **zadnja / za V2** (najprej namenski zaslon). · *(spec §8.9; wireframe board C)*

### A3 · Motor: lastna koda ali gotov paket  ⬜ ODPRTO
**Problem:** za položaj Lune je treba računati. To je edino mesto z morebitno novo knjižnico — CLAUDE.md
zahteva, da **najprej vprašam**.
**Opcije in kaj pomenijo:**
- **A) Lasten izračun** (Meeusove formule, ~par sto vrstic Darta). Prototip **že validiran** (0,003°) →
  nič novih odvisnosti, offline-varno, sama testirava.
- **B) Gotov astro paket** → manj kode, a nova odvisnost izven `tech-stack §1` (preveriti, pin, tveganje
  mrtve lib-e).

**Pod-točka (tehnična):** Kačenosec (Ophiuchus) — 12 ali 13 ozvezdij; predlog: obravnavaj kot prehod. *(§8.2)*
**Predlog:** A. · *(spec §8.3, §4.6, §14.9)*

### A4 · Barve elementov v temi (dark + 6 palet)  ⬜ ODPRTO
**Problem:** 4 elementi so barvno kodirani. App ima svetlo+temno temo in **6 palet**. Fiksni pasteli iz
wireframa v temni temi ne delujejo dobro.
**Opcije in kaj pomenijo:**
- **A) Fiksne semantične barve** — isti 4 odtenki povsod, s temno varianto (kot terakota za napake) →
  preprosto, element = prepoznaven pomen; a se ne »ubere« z izbrano paleto.
- **B) Palettno-odvisne barve** → lepše integrirano, a 6×2 = 12 kombinacij za uskladiti + tveganje slabe
  berljivosti.

**Predlog:** A. · *(ni v §8; iz wireframe pregleda + [[tendask-theme-palettes]])*

### A5 · Ikone elementov: emoji ali lasten vektor  ⬜ ODPRTO
**Problem:** za 4 elemente rabiva ikone.
**Opcije in kaj pomenijo:**
- **A) Emoji** 🍅🥕🌸🌿 → zastonj, a **🌸 in 🌿 že označujeta rastline** v katalogu → možna zmeda (element
  vs. rastlina).
- **B) 4 lastne monokromatske vektorske ikone** → čisto, brez trka; treba narisati/najti.

**Predlog:** nagib k B (če je trk moteč); A hitrejši za MVP. · *(spec §7 omenja obe možnosti)*

### A6 · Privzeto stanje stikala + odkritje  ⬜ ODPRTO (manjše)
**Problem:** koledar je opt-in. Privzeto vklopljen ali izklopljen? Če izklopljen, čipa na Domov ni →
uporabnik funkcije ne odkrije.
**Opcije in kaj pomenijo:**
- **A) Privzeto VKLOPLJEN** → čip na Domov je viden, funkcija se odkrije sama; kdor ne dela po luni, jo
  izklopi. (Smiselno, ker je zdaj vse brezplačno.)
- **B) Privzeto IZKLOPLJEN** → app čist za tiste brez zanimanja; a nihče je ne odkrije brez brskanja.
- **C) Vprašaj ob onboardingu** → eksplicitno, a doda korak.

**Predlog:** A. · *(spec §8.6)*

---

## B. Nagib — potrdi ali spremeni (niso prave dileme)

- **B1 · Nastavitve koledarja lokalno** (device-local, ne sync) — koledar je globalen, ni uporabniški
  podatek. Skladno z »nič synca« (§2). 🅿️
- **B2 · ✦ Tendask+ zaklep se NE gradi zdaj** — roadmap »najprej vse free, gating zadnji«. Koledar v prvi
  različici dostopen vsem; board 2 / zaklenjeni čip / vnos kode šele s FR-20. 🅿️

---

## C. Že dorečeno (referenca — NE odpirava znova)
Ime »Lunin koledar« · semantika »dan za plod/list/cvet/korenino« · pristop A (lasten izračun, brez Thuna) ·
**privzeto siderični** + toggle po mehanizmu (»Po ozvezdjih« / »Po znamenjih«) · brez sheme/synca/mreže/
lokacije · element se re-izpelje (ne zamrzuje) · vstopne točke (čip, Dnevnik, ⚙️→✦ Tendask+, 🔎) · aktivacija
= licenčna koda ([[tendask-lunar-calendar-fr19]], FR-20) · »✦ Tendask+« (ikona spredaj) + prihodnje = »Kmalu« ·
board C = prekrivna plast (ne nov koledar) · vrstni red board-ov · kalibracija sideričnih mej (§12.3).

## D. Delo, ne odločitev (opraviti ob gradnji)
- Napisati **lastne opise dejavnosti** (i18n sl/en/de, na element) — pravno ne prepis Luninih bukev.
- Pridobiti **nevtralne vrednosti 3 kalibriranih mej** (po svetlih zvezdah, ne Thun številke).
- Zgraditi **meno kot CustomPainter** (8 faz iz osvetljenosti).

---

*Poliranje: dorekniva po vrsti (predlog A1 → A2 → A3, nato A4/A5), vsako doreknjeno označiva ✅ + prenesva v
spec. Karta zaslonov: [[reference-screen-map]] · spec: `biodynamic-calendar.md` · wireframa: `docs/wireframes/lunar-calendar_*.html`.*
