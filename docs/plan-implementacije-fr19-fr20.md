# Plan implementacije — FR-19 Lunin koledar + FR-20 minimalna rezina

> **Status:** delovni plan (2026-07-30) · izvedba še ni začeta · statusi se vzdržujejo tukaj
> (⬜ odprto · 🔨 v izdelavi · ✅ končano · 🅿️ čaka odločitev).
>
> **Nadrejeni dokumenti:** [`tendask-plus-rollout-plan.md`](tendask-plus-rollout-plan.md) (vrstni red faz),
> [`feature-requests/biodynamic-calendar.md`](feature-requests/biodynamic-calendar.md) (FR-19 spec, algoritem §14),
> [`feature-requests/biodynamic-calendar-decisions.md`](feature-requests/biodynamic-calendar-decisions.md) (odločitve A1–A6),
> [`feature-requests/tendask-plus-licensing.md`](feature-requests/tendask-plus-licensing.md) (FR-20),
> [`screen-map.md`](screen-map.md) §4 (rute in vstopi). Ta plan jih **ne podvaja** — jih razreže na taske in korake.
>
> **Kako brati:** vsak task ima **Vhod** (kaj mora obstajati, preden se začne), **Izhod** (kaj nastane in
> kdo to porabi), **Branche** (ime brancha za vsak korak), **Varnost na `main`** (zakaj merge ničesar ne
> pokvari) in **Pasti** (predpreverbe, da se sredi taska ne zatakneva). En korak ≈ en commit.
>
> **Način dela (korak po koraku):** vsak korak ima svoj **kratkoživ branch** po konvenciji
> `feat/fr19-tX-N-slug` oz. `feat/fr20-tX-N-slug` (naveden pri tasku). Tok: branch iz **svežega**
> `main` → korak (en commit) → kontrolni seznam spodaj → merge v `main` → izbris brancha. `main` je
> tako **vedno zelen in vedno varen za produkcijo** — vse je za flagom, temno; vmes lahko kadarkoli
> izide bugfix ali drug FR. Docs-only spremembe (P0, statusi tega plana) gredo direktno na `main`.
>
> **Kontrolni seznam pred vsakim merge-om v `main`:**
> 1. `flutter analyze` čist + **cel** `flutter test` zelen; generirani fajli (`slang`, `build_runner`)
>    regenerirani in commitani (CI gotcha — lokalni hook jih ne ujame).
> 2. **Nič vidnega brez flaga:** nova površina dosegljiva samo prek flaga; rute imajo varovalo (redirect).
> 3. **Nič sheme** — edina izjema je T6.1, ki gre po deploy runbooku (staging prej, migracija + granti skupaj).
> 4. `screen-map.md`/spec posodobljena **v istem commitu**, če se je spremenila ruta ali zaslon.

---

## Graf odvisnosti (kaj čaka na kaj)

```
P0.1 zavarovanje prototipov ─┐
P0.2 nevtralne meje ─────────┼──► T1 motor ──► T3 zasloni ──► T4 oznake ──► (T5 iskalnik)
P0.3 odločitve A1–A6 ────────┘        │                          │
                                      └──── T2 ogrodje ──────────┘
                                                                 ▼
P0.4 darilo (dolžina, gost) ─────────────► T6 FR-20 rezina ──► T7 PRIŽIG ──► T8 trgovina
                                              ▲                                 (rok = potek daril)
                (T3+T4 = potrošnik gate-a) ───┘
```

- **T1 in T2 lahko tečeta vzporedno** (motor ne rabi UI ogrodja in obratno).
- **T3 rabi oba** (motor za podatke, ogrodje za flag/barve/ruto).
- **T6 se začne šele, ko UI obstaja** (gate rabi potrošnika; shema se oblikuje ob realni rabi).
- **P0.4 ne blokira gradnje** — samo prižig (T7).
- Vmes je kadarkoli prostor za bugfixe/druge FR-je — `main` nikoli ne zamrzne.

---

## P0 · Predpriprava (pred prvim commitom kode)

### P0.1 · Zavarovanje prototipov in referenčnih podatkov ✅ ZAKLJUČENO (2026-07-30)

**Problem:** validirani prototipi (`tmp/moon_thun_test.py` 233 vrstic, `tmp/moon_calibrate.py` 389 vrstic
z vgrajeno tabelo `THUN2024` — 50 referenčnih vstopov, `tmp/moon_descending.py`) živijo **samo v
gitignorirani `tmp/`**. En `git clean`/menjava stroja = kalibracije ni več mogoče ponoviti brez fotografij knjige.

- **Vhod:** obstoječe `tmp/moon_*.py` (preverjeno 2026-07-30, so še tam).
- **Izhod:** varna kopija; T1 iz nje vzame Meeus koeficiente in referenčne vrednosti za validacijo.
- **Koraki:**
  1. ✅ **Backup izven repa** — `N:\development\tendask\moon-prototipi-2026-07-30.zip` (30. 7. 2026).
  2. ✅ **Obveljal privzetek (a)** — skripte s Thunovimi urami ostajajo **zasebne** (v `tmp/` + backup);
     v repo ni šlo nič. Motor je bil validiran lokalno, referenčne vrednosti živijo v fixture testih
     (lastni izračuni, ne prepis). Če bi kdaj hotel (b) — očiščeno verzijo brez `THUN2024` — je to nova
     odločitev, ne odprta točka tega plana.
- **Pasti:** Thunove ure so prepis iz avtorsko zaščitene knjige — **ne commitaj jih**, dokler lastnik ne
  odloči; privzeto (a).

### P0.2 · Meje ozvezdij ✅ ZAKLJUČENO (2026-07-30) — z drugačnim izidom od načrtovanega

**Izvedeno:** zvezdna izpeljava preizkušena (`tmp/moon_star_bounds.py`, arhivirano na NAS) in **izmerjena
kot slepa ulica** (najboljše rezultatsko-neodvisno pravilo: 1,8 h / 92 % — ne konvergira k tradiciji).
Ob tem odkrita prava dnevna konvencija (oznaka dneva = **element ob začetku dneva**), s katero je pošteno
ujemanje: čiste IAU 93 %, kalibrirane 97 %.

**Odločitev (lastnik, 2026-07-30): kalibrirane meje — vseh 12** (ura vstopa MAE 0,26 h, dnevna oznaka
97 %), z dokumentiranim izvorom in pravnim zagovorom v
[`biodynamic-calendar-boundaries.md`](feature-requests/biodynamic-calendar-boundaries.md) (vrednosti §1,
kronologija §2, zagovor §3). **Rezerva = čiste IAU** kot druga tabela konstant v motorju (izhod v sili,
zamenjava brez API spremembe). Spec posodobljen: §12.6 + §14.5.

### P0.3 · Odločitve A1–A6 ✅ ZAKLJUČENO (vseh šest odločenih do 2026-07-31)

Po vrsti iz [`biodynamic-calendar-decisions.md`](feature-requests/biodynamic-calendar-decisions.md);
plan spodaj privzame **predloge** (označeno), kjer odločitev spremeni obseg, je to zapisano pri tasku:

| # | Odločitev | Predlog (privzet v planu) | Vpliva na |
|---|---|---|---|
| A1 | obseg slojev | ✅ **ODLOČENO (2026-07-30): C — vse 4 plasti**; T1.9 (neugodni) je zadnji korak motorja z izrecno možnostjo zavestnega izpusta ob koncu T1 | T1.8 + T1.9, T3 |
| A2 | en/dva koledarja | ✅ **ODLOČENO (2026-07-31): C — oboje v v1** (Dnevnik: 🌙 AppBar vstop + barvna plast, T4.4) | T4 |
| A3 | motor | ✅ **ODLOČENO (2026-07-30): A — lasten Meeus izračun** (validiran, brez odvisnosti) | T1 |
| A4 | barve | ✅ **ODLOČENO (2026-07-31): A — fiksne semantične**, `MoonColors` ThemeExtension (ena light/dark instanca za vseh 6 palet; vrednosti v `moon_colors.dart`) | T2.4 |
| A5 | ikone | ✅ **RAZREŠENO (2026-07-31): A — emoji** (vektorski osnutki ob pogledu T3.2 zavrnjeni → dogovorjeni fallback; glif = `elementEmoji()`); mena = CustomPainter (✅ T3.1) | T3.2 |
| A6 | privzeto stikalo | ✅ **ODLOČENO (2026-07-31): A — vklopljeno** (odkritje prek čipa; argument prek darila) | T2.2 |

### P0.4 · Odločitve darila 🅿️ (lastnik; blokirata šele T7)

- Dolžina darila (delovni predlog 6 mesecev; izbira glede na sezono ob prižigu) — FR-20 §11.10.
- Gost brez računa: lokalno darilo vs. vezava na prijavo — FR-20 §11.9.

---

## T1 · Motor (`lib/core/biodynamic/`) — čista logika, brez UI ✅ ZAKLJUČEN (2026-07-31)

- **Vhod:** P0.1 (koeficienti iz prototipa), P0.2 (3 meje ali IAU fallback), A1 (ali gre deklinacija zraven), A3=A.
- **Izhod:** čisti Dart modul brez odvisnosti in brez I/O:
  `BiodynamicDay dayFor(DateTime localDate, CalendarSystem system)` →
  `{constellation/sign + isConstellation, element, transitionAt?, secondaryElement?, phase, illumFraction, ascending?, unfavorable? (le če A1=C)}` (spec §14.8).
  Porabniki: T3 (zasloni), T4 (oznake), T5 (iskalnik). **Brez Riverpoda, brez Clocka** — Clock rabi šele
  UI za »danes«.
- **Koraki:**
  1. ✅ **API najprej** (2026-07-30): definiraj `CalendarSystem` enum, `BiodynamicDay` model (navaden immutable razred
     ali freezed) in podpis `dayFor` + prazno implementacijo. *Zakaj prvi: T2/T3 lahko od tu dalje
     razvijata proti stabilni pogodbi.* Pogodba časa: klicalec poda **lokalni koledarski dan**
     (`DateTime(y,m,d)` v lokalni coni); interno vse v UTC; meji dneva = lokalna polnoč→polnoč.
  2. ✅ Časovna osnova (2026-07-30): JD/T iz UTC (Fliegel/Meeus) + testi (znani JD datumi).
  3. ✅ Sončeva ekliptična dolžina (2026-07-30): Meeus 25, ~10 vrstic + test.
  4. ✅ Lunina ekliptična dolžina (2026-07-30): Meeus 47, srednji elementi + 36 členov iz prototipa; **test proti
     Meeus primeru 47.a** ✅ (0,0033°; Dart = Python prototip na 13 decimalk) — vratar prestal.
  5. ✅ Zodiak (2026-07-30): tropski (`floor(λ/30)`), siderični s **12 kalibriranimi pragovi** (boundaries doc §1,
     epoha 2024.0 + precesija `0.013972°/leto`; Kačenosec zajet v meji Sco→Sgr) + **rezervna tabela
     čistih IAU** (izhod v sili; epoha 2000, iz prototipa) + mapping element→del rastline (§14.4). Obe
     tabeli = konstante v `zodiac.dart` (zamenjava = preusmeritev `_activeStarts`, brez API spremembe).
     Komentar brez imen (boundaries §3) ✅.
  6. ✅ Mena (2026-07-30): elongacija, osvetljenost, 8-stopenjska mena, mlaj/ščip z vzorčenjem+bisekcijo;
     **testi proti javnim menam 2026** (14. 7. mlaj, 29. 7. ščip, 12. 8. mlaj — ±5 min) ✅. *(Odkrit
     hrošč v prototipovem IZPISU datuma — JD→datum brez gregorijanske korekcije, 13 dni zamika; JD-ji
     in ure so bili pravilni, motor v Dartu ni prizadet. **Revizija kontaminacije (2026-07-30):**
     `moon_calibrate.py` — vir kalibriranih mej — ima obe inverzni pretvorbi pravilni → kalibracija
     in verifikacija 0,26 h/97 % NISTA prizadeti; hrošč samo v `moon_thun_test.py::jd_to_hhmm`,
     popravljen v arhivu na NAS, original ohranjen kot `…-original.zip`. **Sweep verifikacija porta
     (2026-07-30):** dnevna λ Lune/Sonca Dart ↔ Python za 2024–2027 (1461 točk) — max razlika
     3·10⁻¹¹°/2·10⁻¹²° → vseh 36 koeficientov potrjenih čez celotno domeno, ne le v točki 47.a.)*
  7. ✅ Prehod znotraj dneva (2026-07-31): `dayFor` napolnjen za sloje T1.5/T1.6 — element ob lokalni
     polnoči in koncu dneva, bisekcija ure prehoda (§14.7); JD→DateTime prek epoch aritmetike z
     round-trip testom na ms (past iz T1.6 pokrita); mena/osvetljenost vzorčeni na sredini lokalnega
     dneva. Testi: DST dneva (23/25 h), polnočni drobec (§12.6 — oznaka = element začetka dneva),
     kontinuiteta elementov med sosednjimi dnevi, ~44 % dni s prehodom. `ascending`/`unfavorable`
     ostajata null do T1.8/T1.9.
  8. ✅ Deklinacija → dvigajoča/spuščajoča (2026-07-31): β (Meeus 47.B, 13 členov iz prototipa,
     vratar 47.a −3.229126° na 0,002°), ε linearno, δ = f(λ, β, ε); `ascending` = δ(konec dneva) ≥
     δ(začetek), metoda iz prototipa (`tmp/moon_descending.py`, 96/100 % proti Thun presajanju
     jan/feb 2024 — test tega tudi replicira). Testi: fizikalni pas β/δ, ~27,3-dnevni ciklus
     maksimumov, ~27 obratov smeri v letu. **Review-verifikacija (2026-07-31, `tmp/engine_check.py`
     + `tmp/thun_vs_dart.py`):** Dart ↔ Python sweep 2024–2027 vseh plasti = 0 neujemanj (prehodi
     ≤ 0,5 ms, β ≤ 7·10⁻¹⁰°); Dart direktno proti tiskanim 50 vstopom Thun 2024 = MAE 0,26 h,
     oznake 58/60 (oba zgrešena = dokumentirani polnočni drobec §12.6).
  9. ✅ Neugodni dnevi (2026-07-31; varovalka A1: lastnik potrdil vključitev): `moon_distance.dart`
     (Meeus 47.A cos stolpec, vseh 46 neničelnih členov iz knjige — prototip razdalje ne pokriva;
     vratar 47.a: 368409,7 km na 0,1 km) + v `moon_calendar.dart` vozel (β skozi 0, bisekcija),
     perigej (minimum razdalje prek predznaka naklona) in mrk (sizigija z |β| < 1,6°; vsi 4 mrki
     2024 ujeti). **Kalibracija proti tiskanemu Thun 2024** (fotografije jan/feb/dec strani, rešene
     iz transkriptov prejšnjih sej): vozel **[−5 h, +4 h]**, perigej **±13 h**, apogej v tisku NI
     neugoden → namenoma ni modeliran. Ure motorja ↔ tisk na minute (vozel 15:03 ↔ tisk 10–19;
     perigej 19:54 ↔ tisk 7–9). Day-level test jan+feb+dec: vseh 14 modelabilnih tiskanih dni
     zadetih; 4 dodatni = polnočni repki oken (tisk jih enkrat izpiše, drugič ne — konservativno
     obdržani); tiskane planetarne oznake (☿/♀ vozli, konjunkcije ♄/♆) namenoma izven obsega
     (spec §4.5). *(Stranska najdba + POPRAVLJENO isti dan: `moon_longitude.dart` je imel iz
     prototipa podedovana **zamenjana člena (0,1,∓2,0)** — potrjeno z dvema neodvisnima viroma
     (astropy, frink), popravljeno po knjigi; vpliv ~0,001° ≈ 7 s. Ponovna verifikacija direktno
     proti tiskanemu Thun 2024: 50/50 vstopov, MAE 0,26 h, oznake 58/60 — nespremenjeno. Sweep
     proti Python prototipu za ta člena ni več referenca (prototip nosi isto napako; opomba v
     glavi datoteke).)*
  10. ✅ Referenčni testni nabor (2026-07-31): **lastno izračunani** datumi julij+avgust 2026 (62 dni ×
      2 sistema: znamenje, ura prehoda, mena, osvetljenost, ascending, unfavorable), commitani kot
      fixture (`test/core/biodynamic/biodynamic_fixture_test.dart` — naši izračuni, pravno čisti).
      Ročna sidra ob nastanku: mlaj 14. 7. (0,000) / ščip 29. 7. (1,000) / mlaj 12. 8. = popolni
      sončev mrk / ščip 28. 8. = delni lunin mrk (oba `unfavorable`). Zasebna navzkrižna preverba
      (`tmp/`, ni v repu): sweep vseh plasti Dart ↔ Python 2024–2027 = 0 neujemanj (max razlika
      prehodov 8,1 s = dokumentirana napaka členov v prototipu); vozli iz neodvisne β serije = 7/7
      dni; perigejska dneva v razmiku ~28,6 d (anomalistični cikel). Ure prehodov v fixture so
      CET/CEST → CI `TZ: Europe/Ljubljana` ostaja obvezen.
  11. ✅ Mikro-meritev (2026-07-31): `dayFor` mreža meseca (42 celic × 2 sistema = 84 klicev) =
      **~16 ms** (~0,19 ms/klic, JIT test VM; `moon_calendar_benchmark_test.dart`, ohlapna meja
      < 100 ms proti CI flake). Ni »< nekaj ms« → **memoizacija na (mesec, sistem) gre v T3
      provider** (T3.3 jo že predvideva), motor ostane brez nje.
- **Branchi:** `feat/fr19-t1-1-api` · `feat/fr19-t1-2-timebase` · `feat/fr19-t1-3-sun` ·
  `feat/fr19-t1-4-moon-longitude` · `feat/fr19-t1-5-zodiac` · `feat/fr19-t1-6-phase` ·
  `feat/fr19-t1-7-transitions` · `feat/fr19-t1-8-declination` · (`feat/fr19-t1-9-unfavorable`) ·
  `feat/fr19-t1-10-fixtures` (koraka 10+11).
- **Varnost na `main`:** samo nove datoteke v `core/biodynamic/` + testi; **nič v aplikaciji jih še ne
  kliče**, nič sheme, nič odvisnosti → APK je vedenjsko identičen; vsak vmesni korak sme v produkcijo.
- **Pasti (predpreverjene):** koeficienti obstajajo v prototipu (P0.1) ✅ · brez nove odvisnosti ✅ ·
  DST pokrit s testi (7) · natančnost zavarovana z vratarjem (4) · API brez drift/Riverpod tipov —
  motor je uporaben tudi, če se UI odločitve spremenijo.

## T2 · Ogrodje (flag, nastavitve, barve, ruta, i18n skelet) ✅ ZAKLJUČEN (2026-07-31)

Neodvisen od T1 (lahko vzporedno). Vse temno — nič od tega ni vidno brez flaga.

- **Vhod:** A4 (barve), A6 (privzeto stikalo), obstoječi vzorci: `local_prefs`,
  `theme_palette_controller`, `SwipeColors` ThemeExtension, `app_router`.
- **Izhod:** infra, ki jo T3/T4 samo porabljata. Nič vidnega.
- **Koraki:**
  1. ✅ (2026-07-31) `kMoonCalendarEnabled = false` v `core/config.dart` (compile-time dark flag; vzorec
     `kSuppliesEnabled`). To je **edino stikalo do T6** — ob T6 ga na vstopnih točkah dopolni
     `plusProvider` gate, zraven pa pride še `kTendaskPlusEnabled` za Tendask+ kartico/zaslon
     (ime že rezervirano v `screen-map.md` §2.1).
  2. ✅ (2026-07-31) `local_prefs`: ključa `moonCalendarEnabled` (privzeto po A6) in `moonSystem`
     (privzeto siderični) + metode po obstoječem vzorcu (eksplicitne, ne generične). **Device-local**
     (odločitev B1) — nič synca, nič sheme.
  3. ✅ (2026-07-31) `MoonSettingsController` (`@riverpod`, vzorec `theme_palette_controller.dart`) + **ogretje v
     `main.dart` bootstrapu** (kot paleta) — da čip na Domov ob zagonu ne utripne.
     **Invarianta iz §11.6:** en `system` iz tega controllerja vodi VSE zaslone hkrati.
  4. ✅ (2026-07-31) `MoonColors` ThemeExtension (vzorec `SwipeColors`): 4 element-barve × light/dark, **ena globalna
     instanca za vseh 6 palet** (A4-A brez 12 kombinacij); registracija v `app_theme.dart`
     `extensions:`. Nikoli hardcode hex v widgetih.
  5. ✅ (2026-07-31) Ruta `/moon-calendar` (+ kasneje `/moon-settings`, `/moon-finder` ob svojih taskih) v
     `app_router.dart` — top-level [full], **mimo shell `:id` kolizij**, in z **varovalom na ruti
     sami**: ob `!kMoonCalendarEnabled` `redirect` na `/home`. Ruta je namreč dosegljiva tudi prek
     deep-linka, ne le prek CTA-jev — flag samo na gumbih ne zadošča. Posodobi `route_collision_test`
     in `screen-map.md` (pravilo: v istem commitu).
  6. ✅ (2026-07-31) i18n skelet: namespace `moon` v `en` + `sl` (4 elementi kot »dan za …«, 12 ozvezdij/znamenj,
     beseda ozvezdje/znamenje kot varianti, mena) — **de šele po vizualni potrditvi zaslonov**
     (pravilo »poglej, preden vlagaš«); `dart run slang` + commit generiranega (CI gotcha).
- **Branchi:** `feat/fr19-t2-1-flag` · `feat/fr19-t2-2-prefs` · `feat/fr19-t2-3-settings-controller` ·
  `feat/fr19-t2-4-moon-colors` · `feat/fr19-t2-5-route` · `feat/fr19-t2-6-i18n-skeleton`.
- **Varnost na `main`:** flag = false; ruta ima redirect varovalo; prefs ključi brez bralca; barve in
  i18n ključi neuporabljeni → nič vidnega, nič sheme.
- **Pasti:** slang regeneracija (CI rdeč brez commitanih `*.g.dart`) · flag mora biti preverjen na
  **vseh** vstopnih točkah, ne le na ruti (čip, oznake) — sicer temna izdaja pokaže drobec.

## T3 · Zasloni Luninega koledarja (jedro UI) ✅ ZAKLJUČEN (2026-08-01)

- **Vhod:** T1 (podatki), T2 (flag/barve/ruta/prefs), A5 (ikone), **T5.1 (mapping kategorija→element —
  izvede se pred korakom 3, vhod za ★)**, wireframe `lunar-calendar_overview.html`, screen-map §4.
- **Izhod:** delujoč `/moon-calendar` (+ `/moon-settings`), dosegljiv samo z ročno vklopljenim flagom;
  potrošnik za T6 gate.
- **Koraki (vsak vidni gradnik: najprej videz → pogled na napravi/wireframe → šele nato testi/prevodi):**
  1. ✅ Mena kot `CustomPainter` (krivulja terminatorja iz osvetljenosti, §11.7) — samostojen widget,
     rabijo ga koledar, čip in dan-sheet. **Pogled na napravi** (8 faz). (2026-07-31:
     `MoonPhaseIcon`, videz potrjen prek harnessa `tmp/moon_phase_preview_test.dart` → PNG.)
  2. ✅ Element-ikone (A5): vektorski osnutki ob pogledu zavrnjeni (2026-07-31) → dogovorjeni
     fallback **emoji** (🍅🥕🌸🌿, isti kot wireframe) — en skupen widget `ElementBadge`
     (emoji+oznaka, nikoli samo barva — dostopnost); glif živi samo v `elementEmoji()`
     (`element_badge.dart`). Predogled: `tmp/element_badge_preview.png`.
  3. ✅ `/moon-calendar` — **Mesec**: mreža (element-barva ozadja + mena-marker na dneve mlaja/krajcev/
     ščipa + oznaka), ‹ › navigacija, legenda. **Dnevna oznaka celice = element ob začetku dneva**
     (konvencija tiskanih koledarjev, spec §12.6) + prikazno pravilo za polnočni drobec (prehod v prvi
     uri dneva → dan nosi novi element). **★ »priporočen« na dnevih, katerih element ustreza rastlinam
     vrta** (T5.1 mapping + kategorije `user_plant`; prazen vrt → brez ★; pogojeno s stikalom »Poudari
     po mojem vrtu«, privzeto vklopljeno — odločitev 2026-07-31). Podatki: `List<BiodynamicDay>` iz
     providerja (memoizacija na (mesec, sistem) — meritev T1.11 je pokazala ~16 ms/mrežo → potrebna).
     **Pogled na napravi.** (2026-08-01: `MoonCalendarScreen` + `moonMonthProvider` +
     `gardenElementsProvider`; prehodni dan = deljeno ozadje zgoraj/spodaj; drobec <
     `kMoonMidnightSliverWindow` (1 h) → nov element; `principalPhaseOn()` v motorju; naprave ni
     bilo → pogled prek `tmp/moon_month_preview_test.dart` → PNG.)
  4. ✅ `/moon-calendar` — **Teden**: agenda z opisi dejavnosti na element (lastna besedila —
     slot-filled predloge §11.6, i18n na element, ne per-dan proza). **Pogled.** (2026-08-01:
     segmented Mesec/Teden nad skupnim sidrom; zaslon razdeljen na `moon_month_view.dart` +
     `moon_week_view.dart`; podatki iz `moonMonthProvider` meseca zadnjega dne tedna (vodilni
     dnevi pokrijejo teden čez mejo meseca); `moon.activity(map)` + `activity_new_moon` en+sl;
     naprave ni bilo → pogled prek `tmp/moon_week_preview_test.dart` → PNG.)
  5. ✅ Dan podrobno — **sheet z drsenjem** (odločeno 2026-07-31; revizija sheet↔zaslon ob prvem
     pogledu na napravi): »Kaj se dogaja« (ozvezdje/znamenje, ura prehoda, mena, dvigajoča/spuščajoča,
     ugodnost) + **seznam »Priporočeno za <dan>«** (vrstici na element iz i18n T3.4, vsaka s CTA
     »＋ opravilo«) → `/task-new?date=…` (obstoječi param). **Pogled.** (2026-08-01:
     `showMoonDaySheet` v `moon_day_sheet.dart` — `DraggableScrollableSheet` + `SheetHandle`; tap v
     mesečni celici in agenda vrstici; hero z oznako dneva (ista polnočna redukcija kot celica) +
     prehodni rep; slot-filled `moon.sheet.*` predloge (rich poudarki, ozvezdje/znamenje = dve
     predlogi ene povedi); `MoonColors.softOf()` skupna metoda; naprave ni bilo → pogled prek
     `tmp/moon_day_sheet_preview_test.dart` → PNG.)
  6. ✅ `/moon-settings`: stikalo (opt-in), sistem toggle (»Po ozvezdjih (biodinamični)« / »Po znamenjih
     (astrološki)«, ena vrstica razlage, §13), **podstikala (2026-07-31):** »Poudari po mojem vrtu«
     (★, T3.3) · »Prikaži v Dnevniku« (plast, T4.4) · »Prikaži ozvezdja in meno« (podrobnosti v
     dan-sheetu); vrstica »Namig 'jutri dober dan'« pride šele s **T4b** (brez mrtvih stikal). »Kaj je
     to« mini razlaga. Dosegljiv prek **⚙️ v AppBar `/moon-calendar`** (ta korak jo ožiči; koledar je
     sam za flagom) in prek rute z varovalom; **umestitev tudi pod Tendask+ zaslon pride s T6** (screen-map).
     (2026-08-01: `MoonSettingsScreen` + prefs ključa `moon_show_in_journal`/`moon_show_astro_details`
     (null = vklopljeno) + setterja v `MoonSettingsController`; potrošnik »ozvezdja in meno« ožičen —
     dan-sheet skrije blok »Kaj se dogaja«; ruta z `moonCalendarRedirect` + route_collision_test +
     screen-map; naprave ni bilo → pogled prek `tmp/moon_settings_preview_test.dart` → PNG.)
  7. ✅ Po vizualni potrditvi vseh zaslonov: **de prevodi** + `dart run slang` + pregled dolgih nemških
     besed (Blütentag …). (2026-08-01: cel `moon` namespace v de (Sternbild/Zeichen po §13, brez
     znamk); `element_short` de = `Fru.`/`Wur.` (polni `Frucht`/`Wurzel` se v mesečni celici
     odrežeta); pogledi prek `tmp/moon_de_preview_test.dart` → PNG (mesec, teden, nastavitve,
     sheet). ⚠️ Najdba za T3.8: zgornja vrstica mesečne celice (številka + ★ + mena-ikona)
     prekipi ~4 px pri 320 px viewportu — ne glede na jezik.)
  8. ✅ Testi: widget testi ključnih interakcij (preklop sistema posodobi vse; tap dan odpre sheet) +
     `layoutMatrix('moon-calendar', …)` (+ teden, + sheet če izvedljivo) — 18 kombinacij/zaslon.
     Lunin zaslon ne rabi provider overridov (čista funkcija datuma) razen `MoonSettings`.
     (2026-08-01: widget testi — tap celica/agenda vrstica odpre sheet, 🌌 podstikalo skrije »Kaj
     se dogaja«, ⚙️ odpre `/moon-settings`, preklop sistema + vsa stikala persistirajo; kontroler
     testi za nova setterja. Matrika: moon/month · moon/week · moon/day-sheet · moon-settings =
     72 kombinacij. Popravljena oba 320 px/×1.3 preloma: vrstica celice (številka+★+mena) in
     `element_short` v celici ter agenda stolpcu → `FittedBox.scaleDown` namesto odreza. Suite
     1141 testov.)
- **Branchi:** `feat/fr19-t3-1-phase-painter` · `feat/fr19-t3-2-element-icons` ·
  `feat/fr19-t3-3-month-view` · `feat/fr19-t3-4-week-agenda` · `feat/fr19-t3-5-day-sheet` ·
  `feat/fr19-t3-6-moon-settings` · `feat/fr19-t3-7-i18n-de` · `feat/fr19-t3-8-tests`.
- **Varnost na `main`:** vsi zasloni dosegljivi izključno prek flag-varovane rute → z izklopljenim
  flagom se ne izriše niti en piksel; nič sheme, nič mreže.
- **Pasti:** rich/plural nizi — `find.text` ne najde rich besedila (uporabi `toPlainText()`/
  `find.textContaining`) · barve samo prek `MoonColors`/teme · sheet vedno s `SheetHandle` ·
  prehodni dnevi (~44 %) morajo biti vizualno rešeni že v koraku 3 (dvobarvna celica ali oznaka), ne
  naknadno.

## T4 · Kontekstne oznake (vstopne točke) ✅ ZAKLJUČEN (2026-08-01)

- **Vhod:** T1 + T2; T3 za cilje navigacije. Mesta potrjena v kodi (pregled 2026-07-30):
  čip → `home_screen.dart` takoj za `HomeWeatherSection` · when-step → pod Datum/Ura vrstico ·
  task-detail → za sekcijo vremenskega posnetka.
- **Izhod:** vse vstopne točke iz screen-map §1–§3, za flagom.
- **Koraki:**
  1. ✅ **Čip na Domov** (vzorec `HomeWeatherSection`: samostojen ConsumerWidget, ki sam bere providerje
     in sam odloči, ali se izriše): mena (free del) + desni CTA → `/moon-calendar`. Stanje
     »zaklenjeno → ✦ Tendask+« pride s T6 (do takrat samo odklenjeno stanje za flagom). **Pogled.**
     (2026-08-01: `HomeMoonChip` (`home/presentation/widgets/`), na Domov takoj za vremensko
     sekcijo; flag ali izklopljen opt-in → `SizedBox.shrink`. Vsebina: `MoonPhaseIcon` + naslov +
     ime mene (free) · CTA »dan za X ›« (element oznake dneva prek `moonMonthDayFor`) → push
     `/moon-calendar`. Brez novih i18n ključev. Naprave ni bilo → pogled prek
     `tmp/home_moon_chip_preview_test.dart` → PNG. Po code-review istega dne: razdeljen na
     **gate (`HomeMoonChip`) + javno kartico (`HomeMoonChipCard`)**, da so testi/matrika/predogledi
     možni brez prižiganja flaga; kartica in koledar ob resume osvežita »danes«
     (`WidgetsBindingObserver`); testi gate-off + tap→ruta + matrika `home/moon-chip` že tu
     (ne šele T4.5). Dodatno iz reviewa: error veja `/moon-settings` (`load_error` en+sl+de) +
     test, `kMoonWhatsHappeningKey` namesto emoji finderja, test ‹ › navigacije in test CTA
     »+ opravilo« → `/task-new?date=…`. Suite 1164 testov.)
  2. ✅ **When-step oznaka**: **ločen ConsumerWidget otrok** (ne parameter `WhenStepBody` — ta je
     namenoma brez Riverpoda in ima 36 layout testov, ki jih ne podirava): medla vrstica
     »🌱 dan za list · do 14:20« iz izbranega datuma. **Pogled.**
     (2026-08-01: `MoonDayBadge` (`moon/presentation/widgets/moon_day_badge.dart`) pod
     Datum/Ura + privzeto opombo; gate je **StatelessWidget s flag preverbo PRED ref** (testi
     when-koraka pumpajo brez ProviderScope — dark ne sme zahtevati scope-a; test to zaklene) +
     `_MoonDayBadgeGate` (opt-in) + javna `MoonDayBadgeRow`. Besedilo po planu (»dan za X · do
     HH:MM«, `moonMonthDayFor` redukcija; rep samo, ko celica ohrani prehod) — wireframe board B
     kaže varianto z »— ugodno za …« repom, plan jo je nadomestil. Nov ključ `moon.badge.until`
     en+sl+de. Matrika `entry/when-badge` + testa gate/vsebina že tu. Pogled prek
     `tmp/moon_day_badge_preview_test.dart` → PNG. Suite 1184.)
  3. ✅ **Task-detail sekcija**: element-dan iz `task.date` — **re-izpeljan, ne zamrznjen** (če uporabnik
     datum spremeni, se posodobi; kontrast z vremenom, ki JE zamrznjeno — spec §6.1.2). Info, brez tapa (MVP).
     (2026-08-01: `MoonTaskSection` (`moon/presentation/widgets/moon_task_section.dart`) v
     task-detail za vremenskim posnetkom, `task.date.toLocal()`; trislojni vzorec T4.2 (gate
     skrije tudi `SectionLabel`); kartica board A: emoji + »Dan za X« + `until_then` rep +
     pripis »Tradicija, ne nasvet …« (`moon.task_section.footnote` en+sl+de; brez trigona —
     MVP po planu). `sentenceCase` ekstrahiran v `moon_text.dart` (3. pojavitev). Matrika
     `task/moon-section` + testa. Pogled prek `tmp/moon_task_section_preview_test.dart` → PNG.
     Suite 1204.)
  4. ✅ **Dnevnik (A2=C, 2026-07-31):** 🌙 gumb v AppBar `/journal` → `/moon-calendar` + **barvna plast**
     v mesečni mreži Dnevnika (element-barva + mena celic; tap dan ostane dnevniški dan), za stikalom
     »Prikaži v Dnevniku« (T3.6). ⚠️ `DayCell` je layout-kritičen (320 px × 1.3) — layout matrika
     Dnevnika mora ostati zelena. **Pogled.**
     (2026-08-01: `journal_moon.dart` (`moon/presentation/widgets/`) — trislojni gumb
     `JournalMoonButton` (flag gate brez ref → opt-in gate → javna `JournalMoonIconButton`;
     podstikalo velja za PLAST, ne za gumb — screen-map §1.3) + `journalMoonDays()` (null,
     dokler flag/opt-in/`showInJournal` niso vsi vklopljeni → mreža piksel-identična). `DayCell`
     dobi opcijski `moonDay`: soft element ozadje (izbran/danes ostaneta na obrobi, board C) +
     mena-marker ob številki v `FittedBox.scaleDown`. Brez novih i18n ključev (tooltip =
     `moon.calendar.title`). Mimogrede popravljena latentna tesnoba: številka + pike pri
     320 px × 1.3 prekipita za 1,3 px (obstoječa matrika je ne ujame, ker tekoči mesec nima pik)
     → vrstica pik v `Flexible` + `FittedBox.scaleDown`. Matrika `journal/moon-layer` (javno
     jedro, avg 2026) + testi (dark gumb brez scope-a · tap → ruta · `journalMoonDays` dark →
     null brez providerja · celica z/brez plasti). Pogled prek
     `tmp/journal_moon_preview_test.dart` → PNG (svetla/temna/320×1.3). Suite 1227.)
  5. ✅ Widget/layout testi za vse štiri + de prevodi po pogledu.
     (2026-08-01: testi in matrike so prišli že z vsakim korakom, zato je bil ta korak **pregled +
     zapolnitev vrzeli**. Najdbe: **(1) de prelom v čipu na Domov** — pri 320 px × 1.3 je CTA vzel
     naravno širino in izstradal naslovni stolpec, zato sta se »Mondkalender« in »abnehmender Mond«
     lomila **sredi besede** (matrika tega ne ujame: prosto-ovijajoč tekst se nikoli ne odreže) →
     CTA zdaj `Flexible(flex: 2)` + `FittedBox.scaleDown`, naslovni stolpec `Expanded(flex: 3)`,
     naslov `FittedBox.scaleDown` + `maxLines: 1`; pri 360 × 1.0 videz nespremenjen (PNG).
     sl/en brez sprememb. **(2) srednja plast vrat (opt-in stikalo) ni bila testirana pri NOBENI
     od štirih točk** — temni flag jo prekrije → pravili ekstrahirani v imenovana predikata
     `moonSurfaceOn()` / `journalMoonLayerOn()` (`moon/presentation/moon_gate.dart`, 4 klicalci)
     + `moon_gate_test.dart`: pokvarjene nastavitve = izklopljeno, 🌙 gumb ne gleda podstikala,
     plast rabi oboje. **(3) priklop na gostitelja** (mount) lovi test le pri when-koraku
     (`WhenStepBody` je brez Riverpoda, zato poceni) — ostali trije rabijo cel svet providerjev,
     zato gre preverba v T7 korak 3. de pogled: `tmp/moon_t4_de_preview_test.dart` →
     `tmp/moon_t4_{de,sl,en}_320x1.3.png` + `moon_t4_de_360x1.0.png`. Suite **1233**.)
- **Branchi:** `feat/fr19-t4-1-home-chip` · `feat/fr19-t4-2-when-step` · `feat/fr19-t4-3-task-detail` ·
  `feat/fr19-t4-4-journal-layer` · `feat/fr19-t4-5-tests`.
- **Varnost na `main`:** vsak od treh widgetov ob izklopljenem flagu (ali izklopljenem opt-in stikalu)
  vrne prazno (`SizedBox.shrink` na nivoju vstopnega widgeta je tu legitimen — ni požiranje napake,
  ampak izklopljena funkcija) → obstoječi zasloni vizualno nespremenjeni; layout matrika obstoječih
  zaslonov mora ostati zelena brez sprememb.
- **Pasti:** vse oznake spoštujejo **opt-in stikalo** (off → nič nikjer) IN flag · čip bere ogrete
  prefs (T2.3), sicer utripanje · Dnevnik-plast dodatno spoštuje svoje podstikalo »Prikaži v Dnevniku«.

## T4b · Lunino obvestilo — namig »jutri dober dan« ✅ ZAKLJUČEN (2026-08-01)

- **Vhod:** T1 (motor), T2.3 (prefs), T3.6 (zaslon nastavitev — vrstica 🔔 pride šele s tem taskom);
  **odločitev B1** ✅ (2026-08-01): dostava device-local, opt-in 🔔 sinhroniziran v profile JSON.
- **Izhod:** opt-in lokalno obvestilo »jutri je dan za X« (privzeto izklopljeno, wireframe board 2b),
  ki spoštuje tihe ure in frekvenčno kapico — **ti dve morata s tem taskom zaživeti** (danes
  »persisted but inert«; obvestilo brez njiju bi kršilo obljubo speca §6.3.9).
- **Koraki:** 1. ✅ B1 + oživitev tihih ur/frekvenčne kapice v obvestilnem sloju (2026-08-01:
  **B1 odločen** — dostava **device-local** (nič FCM/crona/sheme), opt-in 🔔 v `NotificationSettings`
  (profile JSON, sinhroniziran, brez migracije), **kapica velja samo za namige**; pravili živita v
  `core/notifications/hint_rules.dart` — `inQuietHours()` + `hintFireTime()`: tihe ure namig
  **prestavijo** na konec okna (nikoli ne izbrišejo), kapica ga na že zasedenem dnevu vrne kot `null`,
  presoja pa se na **prestavljenem** dnevu. Priklopljen dnevniški nudge (dokazano brez spremembe
  vedenja — 17:00 ni v oknu, kapica brez sotekmecev; moon namig se bo umikal njemu, ne obratno).
  Posodobljena zastarela komentarja v `notification_settings.dart` in `config.dart`. 11 novih testov,
  suite **1244**.) · 2. ✅ izračun +
  razpored (lokalno, prek `Clock`) (2026-08-01: **odločitev lastnika o ritmu** — namig pride **samo za
  dneve, ki jih vrt lahko uporabi** (element dneva ∈ `gardenElements`, isto pravilo kot ★; prazen vrt =
  brez namigov) in **ob 18:00 dan prej**. Čisti izračun `moonHintCandidates()`
  (`moon/application/moon_hint_schedule.dart`) → `MoonHintCoordinator` (`moon_hint_coordinator.dart`,
  keepAlive, vzorec `JournalNudgeCoordinator`): re-arm ob zagonu/resume/spremembi luninih nastavitev,
  vrta ali profila (debounce), `Clock` namesto `DateTime.now()`, `scheduleNudge` = inexact kanal,
  horizont **7 dni** = 7 rezerviranih id-jev `kMoonHintNotificationIds` (−211…−217). Vsak kandidat gre
  skozi `hintFireTime` z `otherHintDays` = dnevi dnevniškega nudgea (`journalNudgeDays()`, nov skupni
  helper) — lunin namig se umakne njemu; opomnik opravila dneva ne zasede (B1), vpliva le na to, kam
  nudge pade (`futureTaskReminderDays()` ekstrahiran iz nudge koordinatorja, da oba računata enako).
  **Opt-in `moonHintEnabled`** v `NotificationSettings` (JSON `moon_hint`, privzeto **false**, tolerantni
  parser → brez migracije). Vsebina se **re-izpelje ob vsakem arm-u** (ne zamrzne): naslov
  `moon.hint.title` en+sl+de nad `day_for`, telo = obstoječi `activity` (mlaj → `activity_new_moon`, isto
  kot agenda). `kHintNotificationIds` = nudge + moon; **orphan sweep opomnikov jih zdaj oba preskoči**
  (prej bi pobrisal lunine). Dokler stikala ni (korak 3), flag + privzeti `false` ne razporedita nič.) ·
  3. ✅ 🔔 vrstica v `/moon-settings` (2026-08-01: `_HintTile` kot **prva vrstica kartice podstikal**
  (wireframe board 2b) — edino stikalo zaslona, ki NE živi v `MoonSettingsController`: bere
  `notificationSettingsProvider`, piše prek `profileRepository.setNotificationSettings` (profile JSON,
  sinhronizirano). Ob vklopu `_ensurePermission`: priming (zaslon 21) + `requestPermission`, **brez
  exact-alarm vrat** — namig vozi po inexact nudge kanalu; zavrnitev pusti stikalo izklopljeno.
  Re-arm ni ročen: `MoonHintCoordinator` že posluša `tableUpdates(profiles)`. Med nalaganjem in ob
  napaki je vrstica onemogočena (podnaslov = `load_error`). Ključa `moon.settings.hint`/`hint_sub`
  en+sl+de. Pogled: `tmp/moon_settings_{light,dark}.png` + `tmp/moon_de_settings.png` — de pri 320 px
  ovije naslov na 3 vrstice, brez odreza. **Past za korak 4:** zaslon zdaj drži drift *stream*, zato
  test, ki sam lastuje `ProviderScope` in v teardownu zapre bazo, obvisi — uporabi obstoječi vzorec
  `UncontrolledProviderScope` + `container.dispose()` PRED `db.close()`.) · 4. ✅ testi (2026-08-01:
  **najprej popravek zasnove, ker se odločitve ni dalo izvesti v testu** — v `_reschedule()` so bila
  zlepljena vrata (flag), odločitev (kateri dnevi, tihe ure, kapica, polnoč, sloti) in izvedba (branje
  profila, klic Androida), zato je najbolj zunanja plast zaklenila najbolj notranjo. Odločitev je zdaj
  čista funkcija `planMoonHints()` (`moon_hint_schedule.dart`), ki »zdaj« dobi kot **argument** —
  `Clock` tam ni potreben, ker je čas podatek; koordinator je dobil `armHints(nowLocal)`
  (`@visibleForTesting`, brez flaga in brez ambientne ure), `kMoonCalendarEnabled` pa je ostal **samo
  na vhodu** `_reschedule()`. Netestirana ostane natanko ta ena vrstica, ki jo T7 obrne.
  **20 novih testov, suite 1285:** `moon_hint_schedule_test.dart` (12 — vrt filtrira dneve, 18:00 na
  predvečer, novoluna zastavljena, horizont, arm po 18:00 spusti nocojšnji termin, sistem odloča dneve;
  plan = kandidati brez pravil, `maxHints`, kapica spusti zaseden dan, tihe ure prestavijo 03:00 na
  07:00, namig čez polnoč **odpade** namesto pozne dostave) · `moon_hint_coordinator_test.dart` (7 —
  temen flag ne doseže OS vrste, opt-in počisti rezervirane id-je in oboroži po vrsti, opt-out in
  izklopljen koledar utihneta, prazen vrt utihne, novoluna zamenja telo, **besedilo se re-izpelje po
  preklopu sistema**) · 🔔 vrstica v `moon_settings_screen_test.dart` (privzeto izklopljena in
  aktivna; vklop zapiše `moon_hint: true` v profil). Fake obvestilne službe izločen v
  `test/support/fake_notification_service.dart` (2 klicalca). **Najdba:** pravilo »lunin namig se
  umakne dnevniškemu nudgeu« je s trenutnimi konstantami **nedosegljivo** — predvečer dneva +7 je +6,
  nudge pa pride šele na +7/+28, zato trka ne more biti; pravilo je testirano na ravni `planMoonHints`
  (`takenDays`) in postane živo, če horizont zraste čez 7 dni.)
- **Branchi:** `feat/fr19-t4b-1-quiet-hours` · `feat/fr19-t4b-2-scheduler` · `feat/fr19-t4b-3-toggle` ·
  `feat/fr19-t4b-4-tests`.
- **Varnost na `main`:** privzeto izklopljeno + za flagom; dokler stikala ni (korak 3 zadnji pred testi),
  se nič ne razporeja.
- **Pasti:** obvestilo ob prikazu dan **re-izpelje** (ne zamrzne ob razporeditvi) · spoštuje preklop
  sistema (en `system` vodi vse) · UI brez besede »motor«.

## T5 · Iskalnik »Kdaj za X« (`/moon-finder`) ✅ (2026-08-02) — v v1

- **Vhod:** T3 (koledar, sheet), `coarsePlantCategory` (7 veder — obstaja), mapping element→kategorija
  (nova majhna tabela v motorju ali ob njem), plant-picker (obstaja).
- **Izhod:** obratni iskalnik + chip »🌙 Kdaj za …« na plant-detail (`?plant=:id` predizpolnjen) →
  seznam prihajajočih primernih dni → »＋« → `/task-new?date=…`.
- **Koraki:** 1. ✅ mapping kategorija→element (konstanta + test) — **izvede se PRED T3.3** (vhod za ★
  v mreži, odločitev 2026-07-31). (2026-08-01: `core/biodynamic/category_element.dart` —
  `plantElement()`; vedra: fruit_tree/berries→plod, herbs/lawn→list, ornamental→cvet;
  houseplant + conifer + hedge **brez priporočila**; `kPlantElementOverride` po `plant.id`
  (34 vnosov: 32 vrtnin + kamilica/sivka→cvet) po Thun klasifikaciji, navzkrižno preverjeno
  proti prc-lu.si/nemškim virom — **cvetača→list, brokoli edina cvetna kapusnica**;
  **katalog nedotaknjen** (sprememba `category` vrednosti bi starim APK-jem izpraznila čip
  Vrtnine); testi popolnosti proti seedu.) · 2. ✅ zaslon (izbor rastline → dnevi)
  (2026-08-01: `MoonFinderScreen` + `moonDayRuns()`/`moonFinderRunsProvider`; vstop 🔎 v AppBar
  koledarja, ruta `/moon-finder?plant=` z varovalom; unit testi izračuna, en+sl) ·
  3. ✅ plant-detail chip (2026-08-02: `PlantMoonChip` v hero `plant_detail_screen`, trislojni vzorec
  T4.2/T4.3; postavitev **A po izbiri lastnika** — čip stoji ob čipu območja v stolpcu imena (`Wrap`),
  pri 360 px se čipa zložita; brez novih i18n ključev (`moon.finder.title`); rastline brez priporočila
  in lasten vnos chipa nimajo) · 4. ✅ pogled → widget testi/matrika/de (2026-08-02: de `moon.finder.*`
  — »Wann für …«, `am besten an einem ${day}`; pogled `tmp/moon_t5_de_preview_test.dart` potrdil, da
  se pri 320 px × 1,3 nič ne lomi; 6 testov iskalnika (`moon_finder_screen_test.dart`: predizpolnjena
  rastlina, brez priporočila, prazen zaslon, tap svežnja → sheet, »+« → `/task-new?date=`, izbor prek
  picker-ja) + 2 testa chipa (`plant_moon_chip_test.dart`: temna vrata brez scope-a, tap →
  `/moon-finder?plant=`) + matriki `moon/finder` in `plant/moon-chip` (36 komb.); suite **1340**).
- **Branchi:** `feat/fr19-t5-1-category-map` · `feat/fr19-t5-2-finder-screen` ·
  `feat/fr19-t5-3-plant-chip` · `feat/fr19-t5-4-tests`.
- **Varnost na `main`:** kot T3/T4 — ruta z varovalom, chip za flagom.
- **Pasti:** pre-fill tipa/subjekta v `/task-new` je odprto (screen-map §5) — v1 samo `?date=` (obstaja);
  ne širi obsega brez odločitve.

## T6 · FR-20 minimalna rezina upravičenosti (edini task s shemo!)

- **Vhod:** T3+T4 obstajata (potrošnik gate-a) · **odločitev §11.4** (dependency za preverjanje podpisa
  tokena — izven `tech-stack §1` → **najprej vprašaj**) · FR-20 §6 (token model) · deploy runbook
  (staging → prod, migracija + granti v istem koraku). ⚠️ **Pogoj:** T4.4 (Dnevnik-plast) mora biti
  narejen pred prižigom — stikalo »Prikaži v Dnevniku« (T3.6) je sicer brez potrošnika (mrtvo stikalo).
- **Izhod:** zid obstaja, nič ne zaklepa (flag še off): shema `plus_until`/`plus_token`, `plusProvider`,
  osnovni `/tendask-plus` zaslon, gate ožičen na vstopne točke. Porabnik: T7.
- **Koraki:**
  1. ✅ **Shema (additive, FR-20 §7)** — `0017_profile_plus.sql`, **staging 2. 8.; prod `db push` čaka
     potrditev.** Drift `schemaVersion 13 → 14` (v14 = trije stolpci), suite **1412**. Dve najdbi, ki
     veljata naprej: **(a)** vrstica iz speca `revoke update (plus_until, plus_token) … from
     authenticated` je **no-op** — pravice se v Postgresu samo seštevajo, `0002` pa je podelil `update`
     na celi tabeli, zato column-level revoke ne odgrizne stolpca; edina delujoča oblika je *revoke
     tabelno → re-grant po stolpcih*. **(b)** Zaklenjena sta `insert` **in** `update` (upsert nad
     neobstoječo vrstico je INSERT, `delete`+`insert` pa bi zaobšel samo-UPDATE ključavnico);
     server-lastni so **štirje** stolpci — `plus_until`, `plus_token`, `plus_kind` in `server_inserted_at`
     (`0011` ga razglasi za strežniškega, a je ostal pisljiv). ⚠️ **Posledica:** vsaka prihodnja
     migracija, ki doda klient-pisljiv stolpec v `profile`, mu mora dodati tudi column grant, sicer
     push pade s `42501`. Preverjeno na stagingu s sondo (`tmp/probe_plus_grants.sql`, transakcija z
     rollbackom): legitimen push ✅, samo-podaritev prek update/upsert/delete+insert ✗ `42501`,
     pull bere ✅. **Številčenje `0017`:** read-only sonda produkcije (2. 8., `tmp/probe_prod_state.py`)
     kaže ledger `0001`–`0005` + `0011`–`0016`, shemo identično `main` in **nobenega sledu M11** —
     ni tabel, ni M11 stolpcev. Vrzel `0006`–`0010` je torej prazna. Runbook §2 je trdil nasprotno —
     **popravljen v istem commitu**, skupaj z `m11.md`, `cookbook.md`, `stanje.md` in `CLAUDE.md`
     (novo pravilo: pred posegom v bazo read-only sonda na prod in staging). Od M11 na produkciji
     ostaneta le no-op `engine_dispatch()` in dva cron joba, ki **od 1. 7. 2026 ne tečeta**.
     Vsebina koraka: `profile` dobi **tri nullable stolpce** —
     `plus_until timestamptz`, `plus_token text`, `plus_kind text` (samo za prikaz »Doživljenjska« vs
     »velja do …«; **upravičenost se bere VEDNO samo iz `plus_until`**) + **column-level zaklep pisanja**
     (server-lastni stolpci, oblika po najdbi (a)) + granti v isti migraciji. **`license*` tabele v
     rezino NE gredo** — pridejo s T8; masovni grant v T7 je pot FR-20 §6.6-C (`plus_until` naravnost
     na profile, brez kod). Drift zrcalo + `schemaVersion` dvig + `build_runner`.
  1b. ✅ **Preverba sheme na napravi (staging), 2. 8.** — vrinjen korak (lastnik, 2. 8.: »pred prod pushem
     stg push in podroben device test«), **pogoj za prod `db push`**; brez branch-a in brez commita kode.
     Lovljeno tveganje: column-level granti so odvzeli tabelni `insert`/`update` na `profile`, zato
     manjkajoč stolpec na seznamu pomeni `42501` in **ustavljen sync** (`push()` je fail-fast, profil gre
     prvi). SQL-sonda je to pokrivala na ravni baze, **skozi PostgREST z napravo pa ni bilo preverjeno**.
     **Izid: vse zeleno na SM A536B.** Nadgradnja čez namestitev z 1. 8. je izvedla drift **v13 → v14**
     (katalog 141 nedotaknjen). Staging je bil po resetu 29. 7. brez `auth.users`, zato je bila prijava
     hkrati najostrejši test — prvi push je bil **INSERT nad neobstoječo vrstico**, natanko pot, ki jo
     tabelni revoke zapre. Skozi so šle vse tri poti: lokacija (`h3_r7/r6/r5`, brez koordinat), jezik
     (`lang = en`), obvestila (`notification_settings` s `frequency_cap: true`). `plus_until`/`plus_token`/
     `plus_kind` so ostali `NULL`, `server_inserted_at` se ni premaknil. V `logcat` **nobenega `42501`,
     `PostgrestException` ali `E/flutter`**; drift ves `synced`, nič `pending`; da veriga ni tiho padla za
     profilom, dokazuje `area` (gostov lokalni vrt prevzet na nov uid in pushan).
     **Stari build** (zgrajen iz `b9c69f0`, drift v13, ločen `git worktree`) je proti stagingu z novimi
     stolpci deloval normalno: po prijavi naravnost na Domov z lokacijo iz pull-a — `sync_pull_service`
     uporablja `select()` (= `select *`), torej je tri neznane stolpce res dobil in jih spregledal.
     Nameščen je bil **na čisto**, ker bi nadgradnja nazaj čez podatke v14 pahnila drift v downgrade;
     realen scenarij je uporabnik, ki je ves čas na starem buildu.
     ⚠️ **Opomba o postopku:** `deploy.bat hot` se prek `cmd.exe /c` v Git Bashu ne požene (`/c` se
     pretvori v pot), `flutter run` pa v neinteraktivni seji ob EOF ubije aplikacijo — uporabi
     `flutter build apk --debug --dart-define-from-file=dart_defines.staging.json` + `adb install -r`
     (isti defines, ista nadgradnja na mestu; to pot priporoča tudi `tool/smoke.md` zaradi padcev USB).
     Popravek bi šel v novo migracijo `0018`, nikoli v urejanje že aplicirane `0017`.
     ⏳ **Prod `db push` odložen do konca celote** (odločitev lastnika 2. 8., potrjena 3. 8.: »db push na
     produkcijo ne delava, dokler vse skupaj ni končano«) — torej **ne** po posameznem koraku T6, ampak ko
     rezina stoji. Do takrat produkcija ostane pri `0016`; migracije se kopičijo v repu in na stagingu.
     Produkcija izmerjena 2. 8.: ledger `0001`–`0005` + `0011`–`0016`, `profile` 10 stolpcev, brez sledi M11.
  2. ✅ **Sync izjeme (kritično, FR-20 §6)** — 2026-08-03, branch `feat/fr20-t6-2-sync-exclusion`:
     pull stolpce prinaša, **push jih izpušča**. `profileToRemote` payload sestavlja eksplicitno, zato
     `plus_*` že prej ni pošiljal — vsebina koraka je bila **zaklep tega z testom** (payload iz vrstice s
     `plus_until = 2099` + `plus_token = 'forged'` nima nobenega ključa `plus_*` niti
     `server_inserted_at` — vsi štirje server-lastni stolpci iz `0017`) + doc komentar »nikoli ne dodaj
     `plus_*` ključa« nad funkcijo. `profileFromRemote` zdaj polni `plusUntil`/`plusToken`/`plusKind`
     (nov `_dtOrNull`); **tolerantno**: produkcija je pri `0016`, torej vrne vrstice brez teh stolpcev —
     manjkajoča polja dajo `null`, ne izjeme (drugi test to zaklene). Brez sheme, brez migracije;
     `plus_*` v driftu ostanejo `null`, dokler jih strežnik ne pošlje. Suite **1414**.
  3. ✅ **Dependency za podpis** — 2026-08-03, branch `feat/fr20-t6-3-signature-dep`: **`dart_jsonwebtoken:
     ^3.4.1` z EdDSA/Ed25519** (odločitev lastnika po primerjavi treh kandidatov). Odločilna meritev:
     paket je **že v drevesu** kot odvisnost `supabase_flutter`/`gotrue` (`>=2.17.0 <4.0.0`), zato je
     celoten `pubspec.lock` diff **ena vrstica** — `transitive` → `direct main`, ista verzija, ista
     `sha256`, torej **0 novih bajtov v APK** in nobene nove verige vzdrževanja. Ostalo: 160/160 točk,
     izdaja pred ~3 meseci, MIT, čisti Dart (`clock`, `convert`, `pointycastle` — vsi že v drevesu),
     brez platformnih kanalov in brez I/O. Zavrnjena **`cryptography` 2.9.0** (nov paket; JWT bi moral
     ročno razčleniti — ~50 vrstic lastne kode na varnostno občutljivem mestu; ECDSA tam nima čiste
     Dart izvedbe) in **`ed25519_edwards` 0.3.1** (zadnja izdaja pred ~4 leti, 13 všečkov, ista ročna
     razčlenitev). **Nič kode** — uporaba pride s korakom 4. `tech-stack.md §1` dopolnjen z razlogom,
     zakaj je izven prvotnega seznama (monetizacija ob pisanju sklada ni obstajala).
  4. ✅ **`plusProvider`** — 2026-08-03, branch `feat/fr20-t6-4-plus-provider`. **Dve odločitvi lastnika
     na začetku koraka:** (a) **javni ključ je konstanta v repu** — `kPlusPublicKey` v `core/config.dart`,
     ker javni ključ ni skrivnost in ga tako ni mogoče pozabiti ob build-u (`--dart-define` bi pomenil
     tiho izdajo brez Plusa); **danes je prazen**, ker para ključev še ni → vsak profil bere kot ne-Plus,
     kar je natanko želeno temno stanje. (b) **Merodajen je podpisan žeton, ne stolpec `plus_until`** —
     stolpec je zrcalo za prikaz, zato predelana vrstica v driftu ne odklene ničesar.
     Struktura: `features/plus/data/plus_repository.dart` (`PlusRecord` = tipiziran model, drift ostane v
     `data/`) · `application/plus_token.dart` = **čista funkcija** `verifyPlusToken()` (brez Riverpoda,
     brez ure iz okolja — »zdaj« je argument, isti vzorec kot `planMoonHints()` v T4b) ·
     `application/plus_provider.dart` = `plusProvider` (`StreamProvider<PlusStatus>`, sledi
     `authStateChangesProvider`, re-izračun ob vsaki spremembi vrstice). Ura in ključ sta **overridljiva
     providerja** (`plusClockProvider`, `plusPublicKeyProvider`), zato je `kPlusPublicKey` edina
     netestirana konstanta. Vsaka nepričakovanost (manjkajoč ključ, tuj `sub`, napačen `alg`, pokvarjen
     žeton, potekel datum) je **miren `PlusStatus.none()`, nikoli izjema** — gost offline ne sme videti
     napake. **Dve najdbi iz branja izvorne kode paketa (korak 3), obe upoštevani:** `JWT.verify` vzame
     `alg` **iz glave žetona** (`jwt.dart:55`), zato je `EdDSA` pripet **pred** klicem verify (test z
     `HS256` žetonom to zaklene); `checkExpiresIn` bi bral čas prek internega paketa `clock`, zato je
     `false` in `plus_until` presodi naš `Clock`. `checkHeaderType` je prav tako `false` — `typ` ob
     pripetem algoritmu ne doda ničesar, izdajatelj brez njega pa bi Plus ugasnil brez vidnega vzroka.
     **Pogodba žetona** (za Edge Function ob T7/T8): `{sub, plus_until (epoch sekunde), iat}`, `alg=EdDSA`.
     **18 novih testov, suite 1432:** čisti (veljaven · potekel · rob poteka · predelano telo · tuj ključ ·
     tuj `sub` · `HS256` · smeti/null · manjkajoča trditev · prazen ali pokvarjen javni ključ) in
     providerski nad in-memory driftom (gost brez vrstice · pull odklene · **raztegnjen stolpec brez
     žetona ne odklene** · stolpec ne more preživeti trditve · ura odloča potek · tuj `sub` · odvzem
     žetona Plus ugasne · prazen `kPlusPublicKey` = današnje temno stanje).
     ⏳ **Ostaja za T7:** generiranje para ključev (javni v `kPlusPublicKey`, privatni v Supabase secrets)
     in izdaja žetonov ob masovnem grantu.
  5. ✅ `/tendask-plus` zaslon (osnovni) — 2026-08-03, branch `feat/fr20-t6-5-plus-screen`.
     `TendaskPlusScreen` (`features/plus/presentation/`) bere `plusProvider`; **javna
     `PlusScreenBody(status:)`** nosi vsebino, da jo predogledi, testi in matrika izrišejo brez baze
     (vzorec T4.2). Aktivno = tinted kartica ✓ + »Aktiven do 12. 8. 2027«, oziroma
     **»Aktiven — doživljenjsko«** pri `plus_kind == 'lifetime'` (`kPlusKindLifetime`; datum bi tam
     lagal, ker je žeton po §6.2 omejen na leto). Neaktivno = mirna vrstica »Ni aktiven« + pripis
     `plus.tagline`. **Seznam funkcij je EN, isti v obeh stanjih** (🌙 Lunin koledar z opisom ·
     🪴 Več vrtov in lokacij »Kmalu« · 📊 Analitika pridelka »Kmalu«) — dve ločeni listi (wireframe
     ima brez licence bogatejši seznam ugodnosti) bi se lahko razšli; bogatejši opis pride s **T8**,
     ko zaslon dobi vnos kode. Vrstica koledarja je **tapljiva samo z licenco** → `/moon-settings`.
     Kartica »✦ Tendask+« v Nastavitvah pod profilom: gate `PlusSettingsCard` (flag) → javna
     `PlusEntryCard`. Nov flag **`kTendaskPlusEnabled = false`** + ruta `/tendask-plus` z lastnim
     `tendaskPlusRedirect` (route_collision_test pokriva oboje). i18n `plus.*` **en+sl+de**.
     ⚠️ **Odločitev lastnika ob prvem pogledu:** znak »✦« je **Material ikona**
     (`kIconAutoAwesome`), ne besedilni glif — U+2726 v Plus Jakarta Sans ne obstaja in je padel na
     nadomestek, poleg tega se je zaradi `kPlusLabel = '✦ Tendask+'` risal **dvakrat** (ikona vrstice
     + ime). Zdaj: `kPlusLabel = 'Tendask+'`, znak enkrat na površino.
     **Testi:** 7 widget (veljavnost · doživljenjsko brez datuma · vrstica koledarja odpre nastavitve ·
     brez Plusa je opis, ne vhod · zaslon bere `plusProvider` · kartica za temnim flagom · kartica
     odpre zaslon) + 2 varovalo rute + **matrika** `plus/screen (active|inactive)` in
     `settings/plus-card` = 54 kombinacij. Suite **1495**. Pogled:
     `tmp/plus_preview_test.dart` → `tmp/plus_{active,lifetime,inactive,dark,de_320,card}.png`.
     ⚠️ **Ta korak zapre slepo ulico, ki obstaja danes** (opažanje lastnika 2. 8., potrjeno v kodi z
     lokalno prižganim flagom): edini vstop v `/moon-settings` je **⚙️ v AppBar koledarja**
     (`moon_calendar_screen.dart`), do koledarja pa vodijo samo površine, ki vse gredo skozi
     `moonSurfaceOn()` = `settings.enabled` (`moon_gate.dart`). Izklop glavnega 🌙 stikala je zato
     **enosmeren** — vklopiti ga ni več mogoče (`moonCalendarRedirect` gleda le build flag, torej pomaga
     samo deep-link, ki ga uporabnik nima). Vrstica »Lunin koledar« na tem zaslonu je **drugi vstop, ki
     od stikala ni odvisen** (screen-map §4 ga predvideva od začetka) — zato **ne** dodajaj ločene lunine
     vrstice v glavne Nastavitve: to bi bil podvojen vstop mimo zasnove.
  6. ✅ **Gate swap** — 2026-08-03, branch `feat/fr20-t6-6-gate-swap`. Nov
     **`plusActiveProvider`** (`plus_provider.dart`) je edini bool, ki ga berejo zaklenjene površine
     (loading in napaka = zaklenjeno; odklenjen blisk bi bil laž). Vrata: `moonSurfaceOn()` ostane
     **free** pravilo (mena), novo **`moonPlusSurfaceOn(settings, isPlus)`** pa nosi element-dan;
     `journalMoonLayerOn` in `plantMoonChipTarget` sta dobila `isPlus`. Cele za zid gredo when-step
     oznaka, task-detail sekcija, Dnevnik-plast + 🌙 gumb, čip rastline in — prek varovala rute —
     `/moon-calendar` in `/moon-finder` (deep-link brez licence pristane na `/tendask-plus`, ne na
     `/home`). **Čip na Domov ima deljena vrata** (odločitev 1. 8.): mena + naslov se izrišeta vedno,
     CTA pa je ali »dan za X ›« ali **pilula »✦ Tendask+ ›«**; tap kjerkoli po kartici pelje na
     `/tendask-plus`, ker je koledar zazidan.
     ⚠️ **Ton pilule = medena `colorScheme.secondary`** (izbira lastnika ob pogledu 3. 8.): wireframe
     je risal rdečo (`--lock #e5484d`), a rdeča je v Tendasku destruktivna barva in zaklep bi bral kot
     opozorilo; medena je hkrati brand poudarek »✦ Tendask+« iz wireframa in sledi paleti.
     ⚠️ **Dve odločitvi lastnika na začetku koraka:** (a) ko darilo poteče, se **lunino obvestilo 🔔
     utiša samo** (`MoonHintCoordinator` bere `plusActiveProvider`; shranjen opt-in ostane, zato se
     namig vrne z novo licenco) — brez sledi za uporabnika; (b) **vrstica »Lunin koledar« na
     `/tendask-plus` je tapljiva tudi brez licence**, ker glavno 🌙 stikalo vodi tudi free čip mene in
     mora ostati izklopljivo → `/moon-settings` dobi **lastno varovalo `moonSettingsRedirect`** (samo
     flag, brez zidu), brez Plusa pa pokaže **samo glavno stikalo + »Kaj je to?«** (sistem, 🔔 in tri
     podstikala konfigurirajo površine za zidom). Nov ključ `moon.settings.enable_sub_free` en+sl+de.
     ⚠️ **Najdba (Riverpod 3, velja za vsak `StreamProvider`, ki se BERE namesto watcha):** provider
     sledi svojemu streamu **samo dokler ga kdo posluša** — `ref.listen`/`ref.watch` iz providerja, ki
     ga sam nihče ne posluša (koordinator), stream **ne** oživi, `.future` pa v tem stanju nikoli ne
     dokonča. Zato `main.dart` po bootstrapu drži **odprt** `container.listen(plusProvider, …)`
     (nikoli zaprt — zaprtje zamrzne upravičenost na zagonski vrednosti) in počaka na prvo vrednost,
     da čip ne utripne; isti vzorec je v `_setup` testov koordinatorja.
     **Sprejemno merilo (izklop 🌙 ostane povraten) je zaklenjeno s testi:** vrstica na `/tendask-plus`
     odpre nastavitve brez licence · `/moon-settings` nosi `moonSettingsRedirect` · glavno stikalo
     brez Plusa še vedno piše v prefs. **+25 testov (suite 1520):** vrata (Plus × stikala × sub-switch)
     · čip v obeh stanjih (brez Plusa kaže meno in NE elementa, tap → `/tendask-plus`) · nastavitve brez
     Plusa · namig ob poteku utihne in opt-in preživi · deep-link koledarja · matrika `home/moon-chip
     (locked)`. Pogled: `tmp/plus_gate_preview_test.dart` → `tmp/gate_chip_*`, `tmp/gate_settings_*`.
     ⚠️ **Ostaja netestirano samo za temnim flagom:** veja `containerOf(...).read(plusActiveProvider)`
     v `moonCalendarRedirect` in srednja plast vrat štirih površin — oživijo pri T7.
  6b. ✅ **Nadzor: mena vedno vidna, `/moon-settings` kot razstavni salon** — 2026-08-03, branch
     `feat/fr20-t6-6b-always-on-phase`. Odločitev lastnika (decisions **B3**, spec §6.4) ob pregledu
     koraka 6 na napravi; vrinjena pred korak 8, ker spreminja vrata, ki bi jih device test sicer meril.
     **Izvedeno:** (a) **glavno stikalo 🌙 je odpadlo** — `MoonSettings.enabled`, prefs ključ
     `moon_calendar_enabled` in `setEnabled()` so izbrisani; `HomeMoonChip` je zdaj samo za build flagom
     (deljeni CTA ostane). (b) `moonSurfaceOn()`/`moonPlusSurfaceOn()` sta se zlila v novo
     **`moonElementLabelsOn(settings, isPlus)`** (when-korak · detajl opravila · čip rastline), ki bere
     **peto podstikalo `showElementLabels`** (prefs `moon_show_element_labels`, privzeto vklopljeno,
     glif `kGlyphElementLabels` 🏷️); `journalMoonLayerOn` je izgubil odvisnost od glavnega stikala,
     🌙 gumb v Dnevniku pa gleda **samo `plusActiveProvider`**. Koordinator namiga ne bere več
     `moon.enabled` (opt-in 🔔 + upravičenost sta dovolj). (c) Zaslon brez licence je **razstavni salon**:
     `shown = isPlus ? stored : kMoonSettingsDefaults` — sistem in vseh pet vrstic vidnih, `onChanged`/
     `onSelectionChanged` = `null`, vrednosti privzete (tudi 🔔, ki je sicer shranjen privzeto `false` —
     salon slika, kaj licenca prinese); nič se ne zapiše, shranjene nastavitve obisk preživijo (test).
     Pet vrstic gre skozi nov `_MoonSwitch` (5 klicalcev, brez kopij). (d) Pod segmentom stoji opis
     **izbranega** sistema (`system_help_sidereal`/`_tropical` en+sl+de, z oklepajem »siderični/tropski
     zodiak« na željo lastnika); splošni `system_help` izbrisan.
     ⚠️ **Odločitvi ob pogledu (lastnik, 3. 8.):** (i) oznaka v when-koraku je zdaj **pilula v soft barvi
     elementa** (`MoonColors.softOf`, tekst `onSurface` po A4) — v prejšnjem medlem slogu jo je lastnik na
     napravi bral kot drugo vrstico opombe »Privzeto: danes ob naslednji polni uri«; (ii) čip na detajlu
     rastline nosi nov ključ **`moon.finder.chip`** (»Primerni dnevi« · »Suitable days« · »Passende Tage«),
     ker »Kdaj za …« ob imenu rastline nič ne pove; naslov iskalnika ostane »Kdaj za …«.
     **Testi:** `moon_gate_test` prepisan na nova vrata, showroom (vse vrstice mrtve + privzete + nič
     zapisov) in »opis sledi izbranemu sistemu« v `moon_settings_screen_test`, »noben nastavitveni
     preklop ne skrije mene« v `home_moon_chip_test`, `local_prefs`/controller testi na novi ključ, nova
     matrika **`moon-settings (free)`** (18 komb.). Suite **1537**, analyze čist.
     Pogled: `tmp/step6b_preview_test.dart` → `tmp/t6b_{when_badge_*,settings_*,plant_chip_*}.png`.
     ⏳ **Ostaja:** wireframe `lunar-calendar_*` board 2b še riše glavno stikalo — uskladitev ob priložnosti.
  7. ✅ **Anti-steering i18n pregled** (FR-20 §3.1) — 2026-08-03, kontrolni korak brez brancha in **brez
     najdb: nobenega niza ni bilo treba popraviti.** Pregledani `plus.*` (11 ključev) in cel `moon.*`
     (calendar · settings · finder · hint · badge · sheet · task_section + vse enum mape) v **en+sl+de**,
     `kPlusLabel`/`PlusTitle` (blagovno ime brez besedila o nakupu), pilula `_LockedCta` na čipu Domov,
     `PlusEntryCard` v Nastavitvah in obvestilo luninega namiga. Poleg branja še vzorčni pregled čez vse
     tri `*.i18n.json` na `€`/`$`, `http`, `www.`, `tendask.`, buy/purchase/price/subscribe/store/upgrade,
     kupi/nakup/cena/naročnina/trgovina/splet, kaufen/Preis/Abo/Website, premium/unlock/trial/promo/ponudba
     — vsi zadetki lažni (`$n` v številih, `email_login.*` koda iz e-pošte, `notes.content_hint` »Free
     text«). Trdo kodiranih uporabniških nizov v `features/plus`, `features/moon` in `home_moon_chip.dart`
     ni. Zaslon `/tendask-plus` brez licence pokaže `plus.tagline` + seznam funkcij z dvema »Kmalu« — to je
     oblika, ki jo §3.1 izrecno dovoli (nevtralen opis ugodnosti brez cene in naslova).
     Ob strani izmerjeno: `docs/go-live/store-listing.md` Plusa in Lune **sploh ne omenja** — uskladitev
     listinga je naloga T7, ne tega koraka.
  8. ✅ **Staging preizkus na napravi** — 2026-08-04, SM A536B proti stagingu; **brez brancha kode, ker se
     hrošč ni pokazal** (korak je merilni). Nameščen je bil APK z lokalno prižganimi flagi, zgrajen iz
     drevesa `de1dac9`. **Izmerjeno in zeleno:**
     **(a) odklenjeno stanje** — čip na Domov (»dan za list ›«) · `/moon-calendar` mesec + teden ·
     dan-sheet (razširjen do konca, nič pod navigacijskimi gumbi) · `/moon-settings` z licenco (pet živih
     stikal, opis **izbranega** sistema) · korak »Kdaj« (pilula v soft barvi elementa) · detajl opravila
     (sekcija »Lunin koledar«) · Dnevnik (🌙 gumb + barvna plast, pike in »danes« nedotaknjeni) ·
     čip rastline »☾ Primerni dnevi« → `/moon-finder` (svežnji do 60 dni) · `/tendask-plus`
     »Aktiven do 2. 9. 2026« · pot Nastavitve → ✦ Tendask+ → »Lunin koledar« → `/moon-settings`.
     **(b) peto podstikalo 🏷️** — izklop pobriše oznako v koraku »Kdaj«, celo sekcijo na detajlu opravila
     (skupaj s `SectionLabel`) in čip na rastlini, **čip na Domov pa ostane nespremenjen** (B3).
     **(c) potek licence** — ker je merodajen **podpisan žeton, ne stolpec**, je bil izdan nov žeton s
     `plus_until` v preteklosti (isti testni par, `tmp/gen_plus_test_token.dart … -1`); samo skrajšanje
     stolpca ne bi dokazalo ničesar. Po zagonu (pull ob startu; `kSyncInterval` je 15 min, resume sam ne
     potegne) je **vse zaklenjeno**: čip obdrži meno in dobi medeno pilulo »✦ Tendask+ ›«, `/tendask-plus`
     pravi »Ni aktiven«, 🌙 gumb in plast Dnevnika izgineta, `/moon-settings` je razstavni salon.
     **Lunino obvestilo je utihnilo samo** — armirani alarm 5. 8. ob 18:00 je izginil iz `dumpsys alarm`,
     dnevniški nudge (11. 8., 1. 9. ob 17:00) in opomnik opravila (14. 8. ob 09:00) so ostali; **shranjen
     opt-in `moon_hint = true` je preživel** in ob vrnjenem žetonu se je alarm 5. 8. 18:00 vrnil.
     **(d) 🔔 optimistična vrstica** — posnetek takoj po tapu ujame stikalo že v gibanju; zapis pristane v
     profilu (`updated_at` isto sekundo), brez zatikanja.
     **(e) letalski način** — z izklopljenim wifi (sam letalski način ga na Samsungu pusti prižganega!)
     in **hladnim zagonom** so Plus, koledar in vse površine delovale; vreme je mirno padlo na zadnji
     posnetek. V `logcat` skozi celo sejo **nič** `E/flutter`/`PostgrestException`/`42501`.
     **Staging po koncu vrnjen v izhodiščno stanje** (`plus_until` 2026-09-02, žeton 240 znakov),
     `server_inserted_at` ves čas nepremaknjen (3. 8.) = klient ga res ne piše.
     ⚠️ **Ena najdba (kozmetična, ne popravljena — poročana lastniku):** brez licence **segment sistema ne
     kaže, kateri sistem je izbran** — onemogočen `SegmentedButton` v M3 izpusti polnilo izbrane polovice,
     zato sta »Po ozvezdjih« in »Po znamenjih« videti enaka. Pet stikal privzeto vrednost pokaže pravilno
     (onemogočeno, a v položaju »vklopljeno«); B3 pa za salon predvideva tudi viden privzeti sistem.
     Podatek ni izgubljen — opis pod segmentom govori o sideričnem zodiaku.
     **Ob istem koraku počiščen dolg:** wireframe `lunar-calendar_overview.html` board 2b je usklajen z
     zaslonom — glavno 🌙 stikalo odstranjeno, board je zdaj **par** (z licenco / razstavni salon), pet
     podstikal z 🏷️, opis izbranega sistema in novo besedilo »Kaj je to?«; opomba dobila razlog B3.
     **Delno opravljeno že 2026-08-03 (SM A536B, staging), takoj po koraku 4** — vse, kar se da izmeriti,
     preden obstaja zaslon. Priprava: v profilno vrstico (`01b9054f-…`, `exogenus@gmail.com`) so bili s
     service role vpisani `plus_until = 2026-09-02 10:19:20Z`, `plus_kind = 'granted'` in žeton, podpisan
     z **enkratnim testnim parom ključev** (`tmp/gen_plus_test_token.dart`, determinističen seed
     `(i*7+13) % 256`; produkcijski par pride šele s T7). Izmerjeno:
     **(a) pull** prinese vse tri stolpce skozi PostgREST v drift (`plus_until` 1788344360,
     `plus_kind` granted, žeton 240 znakov) — granti `0017` klienta ne ovirajo pri branju;
     **(b) podpis** — `verifyPlusToken` nad **točnimi bajti s telefona** vrne `isActive: true` do
     2. 9. 2026, isti žeton pod tujim uid pa `false` (`tmp/verify_device_token.dart`);
     **(c) push z napolnjenimi `plus_*`** — dvakratna menjava jezika (`sl → en → sl`) je obakrat
     pristala na stagingu (`updated_at` 10:26:09 in 10:26:37), **`plus_*` in `server_inserted_at` pa so
     ostali nedotaknjeni** in v `logcat` ni bilo nobenega `42501`/`PostgrestException`/`E/flutter`.
     To je bila edina še neizmerjena pot: sync izjema (korak 2) je bila do tedaj zaklenjena samo s
     testom payloada.
     **S tem je T6 zaključen — prod `db push` je od tu naprej odprto vprašanje za lastnika.**
- **Branchi:** `feat/fr20-t6-1-schema` · `feat/fr20-t6-2-sync-exclusion` · `feat/fr20-t6-3-signature-dep` ·
  `feat/fr20-t6-4-plus-provider` · `feat/fr20-t6-5-plus-screen` · `feat/fr20-t6-6-gate-swap` ·
  `feat/fr20-t6-6b-always-on-phase`
  (koraka 7–8 — i18n pregled in staging preizkus — sta kontrolna, brez lastnih branchev).
- **Varnost na `main`:** migracija additive + nullable (stari APK-ji ob pull ne crashajo, tolerantni
  parser ignorira neznano); najprej **staging**, prod `db push` po runbooku **šele ob koncu celote**
  (odločitev lastnika 3. 8. — ne po posameznem koraku); gate je privzeto zaklenjen,
  a oba flaga off → nič vidnega; push izjema pokrita s testom PRED merge-om provider koraka.
- **Pasti (predpreverjene):** granti v isti migraciji (pravilo iz spomina) · pred prod buildom
  `supabase db push` pending migracij (pravilo iz spomina) · shemo premika SAMO ta task
  (serializacija §2 rollout plana) · vrstni red korakov je zavezujoč: sync izjema (2) se merga
  **pred** providerjem (4), da nobena vmesna izdaja ne pusha server-lastnih stolpcev.

## T7 · Prižig z javno darilno kodo

> ⚠️ **Prekrojeno 2026-08-04** (decisions **B4**, FR-20 **§6.8**). Prvotni T7 je bil »tihi masovni
> grant + flag flip«, vnos kode pa je čakal na T8. Zdaj je obratno: **darilo se podeli z eno javno
> kodo, ki jo uporabnik vnese sam**, zato se unovčitev in `license` shema preselita **sem**, v T8 pa
> ostane samo prodaja. T7 s tem ni več »en dogodek, majhen« — je največji task za T6.

- **Vhod:** T6 na produkciji (temen) · odločitve B4 (koda, datum, kapaciteta) · zgodba za objavo ·
  pravna podlaga za mailing (**preveri lastnik**, ne ugibava) in orodje za pošiljanje (Resend, §5.2).
- **Izhod:** Lunin koledar živ; kdor vnese kodo, ima Plus do 31. 12. 2026; mena free za vse.
- **Koraki (predlog razreza, ni še potrjen):**
  1. ⬜ **Shema licenc** (edini shemo-dotikajoč korak → serijsko, staging prej): `license` +
     `license_redemption` (unique `(license_id, user_id)`) + `license_redeem_attempt` z `reason`;
     `max_redemptions`; `provider`/`provider_ref` **že tu** (pravilo §5.2, tudi brez prodaje);
     granti v isti migraciji — `license*` **nima** granta za `authenticated`, dostop samo prek RPC.
  2. ⬜ **Unovčitev + kovanje žetona** (Edge Function; Ed25519 v Postgresu ni): atomarna unovčitev →
     `profile` **upsert** (11 % računov je brez profila!) → podpisan žeton. Enotno sporočilo navzven,
     razlog v `reason`. Rate limit 5/uro (§6.5).
  3. ⬜ **Par ključev za produkcijo**: javni v `kPlusPublicKey`, privatni v Supabase secrets. Testni
     par iz `tmp/gen_plus_test_token.dart` **ne sme** v produkcijo.
  4. ⬜ **Zaslon za vnos kode** na `/tendask-plus` — najprej wireframe, pogled, šele nato koda
     (pravilo »poglej, preden vlagaš«); i18n en+sl+de; normalizacija velikosti črk in vezajev.
  5. ⬜ **Vodenje licenc** (§7.2): `mint_license` / `revoke_license` / `find_licenses` + dva pogleda.
     Brez tega ne moreš odgovoriti na prvo podporno vprašanje.
  6. ⬜ Oba flaga on (`kMoonCalendarEnabled`, `kTendaskPlusEnabled`) — en drobcen commit + release
     build (versionCode disciplina — nalaganje porabi kodo) + `db push` check.
  7. ⬜ **Preverba na napravi** (SM A536B): unovčitev · odklenjen tok · zaklenjen tok · offline ·
     **temna tema** (dolg: cel FR-19 je bil na napravi viden samo v svetli). Vključi vse štiri T4
     vstopne točke — dokler je bil flag temen, je priklop na gostitelja lovil test le pri when-koraku
     (najdba T4.5); ob prižigu bodo ti testi rabili `ProviderScope`.
  8. ⬜ **Spletna stran + mailing**: stran s kodo (brez pogojev prodaje in politike vračil — ni
     prodaje) + razpošiljanje vsem računom.
  9. ⬜ **Play `App access` na »Da«** z dobesednimi navodili in javno kodo · listing (SL/EN/DE;
     `docs/go-live/store-listing.md` Plusa in Lune danes sploh ne omenja).
- **Varnost:** to je edini korak, ki **namerno** spremeni vedenje v produkciji. Vse razen koraka 6 se
  da pripraviti in izmeriti na stagingu.
- **Trdi rok, ki iz tega izhaja:** **1. 1. 2027** vsi hkrati padejo na brezplačni sloj → T8 mora do
  takrat stati.

## T8 · Trgovina (samo prodaja) — rok: 31. 12. 2026

> Prekrojeno 2026-08-04: unovčitev, `license` shema in vnos kode so se preselili v T7, zato tu ostane
> **samo pot denarja**.

Podrobni koraki so **FR-20 §12** (ne podvajam): odločitve cene (§11.2) + Polar/Paddle (§11.3) → Polar
izdelka + **webhook adapter** (Edge Function, ki dogodek prevede v upsert po `provider_ref`) → nakupna
stran `/plus` (3 jeziki, pogoji, politika vračil, popravek `t.hero.free`) → **obnavljanje žetonov**
(§7.1 — obvezno šele z doživljenjsko licenco) → DoD sandbox matrika (nakup/podaljšanje/vračilo/
predelava/preklic).

- **Vhod:** T7 živ · §11.2 in §11.3 odločena.
- **Izhod:** kupljiv Tendask+, preden 31. 12. 2026 poteče lansirna koda.
- **Branchi:** določijo se ob razrezu taska (konvencija `feat/fr20-t8-N-slug`).

---

## Namerno zunaj v1 (da se obseg med delom ne razleze)

> Uskladitev z wireframom (2026-07-31, lastnik) je v v1 prenesla: lunino obvestilo (→ **T4b**),
> personalizacijo po vrtu §6.3.8 (→ **T3.3 ★ + T3.6 stikalo**, mapping T5.1 prej) in Dnevnik-plast
> board C (→ **T4.4**, A2=C). Zunaj v1 ostaja:

- **Retrospektivni vpogled (§6.3.11)** — dolgoročno.
- ~~**Vnos licenčne kode, `license*` tabele, Play `App access`** — T8, ne prej.~~ **Prekrojeno
  2026-08-04 (B4):** vse troje se je preselilo v **T7**, ker se darilo podeli z javno kodo, ki jo
  uporabnik vnese sam. V T8 ostane samo prodaja (Polar, webhooki, nakupna stran, vračila).

---

## Prečna pravila (veljajo za vsak task)

- **Branch:** en korak = en branch (imena pri taskih), iz svežega `main`, merge takoj po kontrolnem
  seznamu, nato izbris; flag drži vse temno. Noben branch ne preživi taska.
- **En korak = en commit** (Conventional Commits, slovenski opis); pred commitom vprašaj.
- **Pred pushem:** `flutter analyze` + **cel** `flutter test` (ne samo analyze).
- **Vidni gradniki:** videz → pogled → šele nato testi/prevodi/dokumentacija.
- **Screen-map + spec:** posodobitev v istem commitu kot sprememba rut/zaslona.
- **Nič v `docs/` kot odločitev brez doreka** — statusi v tem planu se obnavljajo sproti.

## Definicija »ni mrtvih točk« — kje bi se lahko zataknilo in zakaj se ne bo

| Potencialna slepa ulica | Zavarovanje v planu |
|---|---|
| ~~Nevtralne meje se ne dajo izpeljati dovolj natančno~~ (uresničilo se je!) | Razrešeno 2026-07-30: kalibrirane vseh 12 s pravnim zagovorom (boundaries doc); rezerva čiste IAU kot druga tabela konstant (T1.5) |
| Motor ni dovolj natančen | Vratar T1.4 (Meeus 47.a) + T1.6 (mene) — pade takoj, ne sredi UI |
| Izguba kalibracijskih podatkov | P0.1 backup pred vsem |
| UI odločitve se spremenijo med gradnjo | Motor API (T1.1) brez UI predpostavk; barve/ikone izolirane v T2.4/T3.2 |
| Gate ne deluje z gostom | T6.4 eksplicitno: gost → mirno ni-Plus + test |
| Predelan klient si podari Plus | T6.2 push izpušča stolpca + test; podpisan token |
| Temna izdaja pokaže drobec | T2.1 flag na VSEH vstopnih točkah + T2.5 redirect varovalo na rutah (deep-link!) + točka 2 merge kontrolnega seznama |
| Anti-steering kršitev | T6.7 pregled nizov kot izrecen korak z vetom |
| Trgovina zamudi potek daril | T7.5 rok zabeležen ob prižigu; izhod v sili = podaljšanje daril |
| Dolgoživ branch (M11 scenarij) | Prečno pravilo: kratkoživi branchi, merge sproti, vse dark |

---

*Zapisano 2026-07-30. Statusi se vzdržujejo v tem dokumentu; ob zaključku taska se vnos preseli v
`narejeno.md` po običajnem pravilu.*
