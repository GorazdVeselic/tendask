# FR-19 — Kalibrirane meje ozvezdij: vrednosti, izvor in pravni zagovor

> **Status:** odločeno in verificirano 2026-07-30 (potrdil lastnik) · **Namen:** en dokument, ki drži
> (1) končnih 12 konstant, (2) natančen zapis, KAKO sva prišla do njih, in (3) pravni zagovor —
> da je izvor dokumentiran, če bi ga kdaj potrebovala. Tehnični kontekst: spec
> [`biodynamic-calendar.md`](biodynamic-calendar.md) §12/§14.

---

## 1. Vrednosti (vir resnice za implementacijo)

Tropska ekliptična dolžina začetka ozvezdja, **epoha 2024.0**. Za druga leta prištej precesijo
`0,013972°/leto × (leto − 2024)`. Motor primerja Lunino tropsko dolžino s temi pragovi.

| Ozvezdje | Meja (°) | Ozvezdje | Meja (°) |
|---|---|---|---|
| Oven | 29,8 | Tehtnica | 220,0 |
| Bik | 54,1 | Škorpijon | 238,1 |
| Dvojčka | 90,1 | Strelec | 269,1 |
| Rak | 118,1 | Kozorog | 299,2 |
| Lev | 139,1 | Vodnar | 327,1 |
| Devica | 174,0 | Ribi | 352,1 |

Kačenosec (Ophiuchus) ni samostojna postavka — tradicija ga ne uporablja; njegov ekliptični pas je
zajet v kalibrirani meji Škorpijon→Strelec. **Verifikacija (2026-07-30):** s temi (zaokroženimi)
vrednostmi povprečna napaka ure vstopa proti referenci = **0,26 h (16 min)** čez 50 vstopov iz štirih
mesecev 2024; dnevna oznaka elementa (element ob začetku dneva) se ujema **58/60 = 97 %**.

## 2. Kako sva prišla do vrednosti (kronologija, ponovljivo)

1. **Lasten astronomski motor** (Meeusove formule: srednji elementi + 36 periodičnih členov za Luno,
   poglavje 25 za Sonce) — napisan samostojno, validiran neodvisno od kakršnegakoli koledarja:
   Meeusov učni primer 47.a se ujame na **0,003°**, mlaji/ščipi proti javnim efemeridam na **1–3 min**,
   tropska znamenja proti spletnim virom 31/31 (2026 in 2027). Motor torej ni izpeljan iz reference —
   obstaja in je dokazano pravilen pred njo in brez nje.
2. **Referenčna meritev (2026-07-22):** iz fotografij **zakonito pridobljene tiskane izdaje**
   avtoriziranega slovenskega setvenega priročnika (siderična tradicija, letnik 2024) sva odčitala
   **50 ur vstopa Lune v ozvezdje** iz štirih mesecev (januar, februar, avgust, december — oba časovna
   pasova CET/CEST). Odčitane ure so *meritev* objavljenega sistema, ne prepis vsebine.
3. **Izpeljava:** za vsak odčitan vstop je motor izračunal Lunino tropsko dolžino ob tisti uri;
   meja ozvezdja = **povprečje** teh dolžin čez vse vzorce tega ozvezdja; zaokroženo na 0,1°.
4. **Navzkrižna validacija:** meje, izpeljane samo iz zimskih mesecev, in meje samo iz poletnih se
   ujemajo na **≤ 0,4°** — vrednosti so stabilne, niso prilagojene enemu obdobju; precesija je v
   modelu, zato ostanejo veljavne (drift ~1,5 min/leto je vračunan).
5. **Preverjeni alternativi (2026-07-30), preden je padla odločitev:**
   - *Uradne meje IAU brez kalibracije:* dnevna oznaka 93 %, ura vstopa ~2,2 h — sprejemljiv rezervni model.
   - *Izpeljava mej iz položajev svetlih zvezd* (vnaprej določena, rezultatsko neodvisna pravila;
     koordinate HIP/J2000): najboljše pravilo doseže le ~1,8 h / 92 % — **ne konvergira** k tradiciji;
     vsako pravilo, ki bi jo zadelo, bi bilo treba izbrati *zaradi rezultata*, kar je kalibracija po
     referenci z ovinkom. Zato zavrnjeno kot navidezno čistejše.
6. **Zasebna dokumentacija** (ni v repozitoriju): izpeljavne skripte in surova referenčna tabela so
   arhivirane v `N:\development\tendask\moon-prototipi-2026-07-30.zip`; fotografije izvirnika hrani
   lastnik. Repozitorij vsebuje samo izpeljane konstante in ta opis; testni nabori v repu so lastni
   izračuni, nikoli odčitane ure.

## 3. Pravni zagovor (zakaj je to dovoljeno)

Kalibracija prevzame **12 številčnih parametrov sistema**, ne izraza. Zagovor stoji na štirih
neodvisnih stebrih — vsak zase zadošča:

1. **Avtorsko pravo ne varuje metod in parametrov.** ZASP čl. 9 (in enako pravo EU) iz varstva
   izключuje ideje, načela, metode in postopke; varovan je izraz (besedila, tabele, oblikovanje) —
   tega ne prevzemava. Meja med varovanim in prostim: prepis koledarja ≠ nastavitev parametrov
   lastnega, neodvisno validiranega izračuna tako, da sledi istemu sistemu.
2. **Izračunani podatki nimajo sui generis varstva baz.** Sodišče EU (C-203/02 British Horseracing
   Board; C-604/10 Football Dataco): varuje se vlaganje v *pridobivanje* obstoječih podatkov, ne v
   *ustvarjanje* novih. Ure vstopa v koledarju so izračunane (ustvarjene), poleg tega jih izdaja
   sama predstavlja kot astronomska dejstva — dejstev se ne da lastniniti.
3. **Sistem neenakih vidnih ozvezdij je tradicija, ne stvaritev avtorice koledarja.** Antropozofska
   astronomska tradicija (Sternkalender astronomske sekcije Goetheanuma, izhaja od ~1929; Elisabeth
   Vreede, † 1943) ta okvir uporablja desetletja pred prvim setvenim priročnikom; morebitne avtorske
   pravice na izvorni določitvi so potekle. Kalibrirava se torej na tradicijo, katere najdostopnejša
   natančna objava je pač sodobna tiskana izdaja.
4. **Tržna praksa:** največji slovenski konkurent (posadi.si, 100.000+ prenosov) komercialno ponuja
   »setveni koledar po Mariji Thun« z imenom vred in brez navedene licence. Tendask je bistveno
   konservativnejši: enak približek sistemu, **brez imena, brez prepisa vsebine**.

**Česa se izrecno vzdrživa (rdeče črte):** nikjer v aplikaciji, trgovini ali marketingu imen
»Thun«/»Aussaattage« ali namigov na uradnost · noben dnevni vnos, opis ali tabela iz tiskanih izdaj ·
surove odčitane ure ne gredo v repozitorij · besedila o dejavnostih so lastna (spec §11.5).

**Javna formulacija (edina, ki se uporablja navzven):** *»Meje sledijo tradicionalnim biodinamičnim
(neenakim, vidnim) ozvezdjem, kot jih od dvajsetih let 20. stoletja uporablja antropozofska
astronomska tradicija; empirično so umerjene proti objavljenim koledarjem te tradicije, celoten
izračun pa je lasten (Meeusove efemeride).«* — vsak del te povedi je dokazljivo resničen (§2).

## 4. Izhod v sili (vgrajen, trivialen)

Najhujši realni scenarij je opomin iz naslova nelojalne konkurence. Odgovor: 12 konstant se zamenja
z uradnimi mejami IAU (tabela obstaja v motorju kot rezervni model) — **ena sprememba konstant**,
brez migracij, brez sheme; aplikacija pade s 97 % na 93 % dnevnih oznak in z 0,26 h na 2,2 h pri urah
prehodov. Nič drugega se ne spremeni.

---

*2026-07-30: izmerjeno, odločeno (lastnik), zapisano. Ob morebitni spremembi konstant posodobi
verifikacijo v §1 in kronologijo v §2.*
