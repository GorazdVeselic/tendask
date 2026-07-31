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

### P0.1 · Zavarovanje prototipov in referenčnih podatkov ⬜

**Problem:** validirani prototipi (`tmp/moon_thun_test.py` 233 vrstic, `tmp/moon_calibrate.py` 389 vrstic
z vgrajeno tabelo `THUN2024` — 50 referenčnih vstopov, `tmp/moon_descending.py`) živijo **samo v
gitignorirani `tmp/`**. En `git clean`/menjava stroja = kalibracije ni več mogoče ponoviti brez fotografij knjige.

- **Vhod:** obstoječe `tmp/moon_*.py` (preverjeno 2026-07-30, so še tam).
- **Izhod:** varna kopija; T1 iz nje vzame Meeus koeficiente in referenčne vrednosti za validacijo.
- **Koraki:**
  1. ✅ **Backup izven repa** — `N:\development\tendask\moon-prototipi-2026-07-30.zip` (30. 7. 2026).
  2. 🅿️ **Odloči lastnik:** ali skripte (ki vsebujejo Thunove ure) smejo v repo. Opciji:
     (a) ostanejo samo zasebno (repo čist, validacija T1 teče lokalno);
     (b) v repo gre **očiščena** verzija brez `THUN2024` tabele (Meeus del je javna astronomija).
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

### P0.3 · Odločitve A1–A6 🅿️ (lastnik; blokirajo T1-obseg in T3–T4)

Po vrsti iz [`biodynamic-calendar-decisions.md`](feature-requests/biodynamic-calendar-decisions.md);
plan spodaj privzame **predloge** (označeno), kjer odločitev spremeni obseg, je to zapisano pri tasku:

| # | Odločitev | Predlog (privzet v planu) | Vpliva na |
|---|---|---|---|
| A1 | obseg slojev | ✅ **ODLOČENO (2026-07-30): C — vse 4 plasti**; T1.9 (neugodni) je zadnji korak motorja z izrecno možnostjo zavestnega izpusta ob koncu T1 | T1.8 + T1.9, T3 |
| A2 | en/dva koledarja | **C z odlogom**: namenski zaslon zdaj, Dnevnik-plast V2 | T3 (Dnevnik izpade iz v1) |
| A3 | motor | ✅ **ODLOČENO (2026-07-30): A — lasten Meeus izračun** (validiran, brez odvisnosti) | T1 |
| A4 | barve | ✅ **ODLOČENO (2026-07-31): A — fiksne semantične**, `MoonColors` ThemeExtension (ena light/dark instanca za vseh 6 palet; vrednosti v `moon_colors.dart`) | T2.4 |
| A5 | ikone | **B**: 4 lastne monokromatske vektorske (emoji 🌸🌿 trčita s katalogom); mena = CustomPainter | T3.1–T3.2 |
| A6 | privzeto stikalo | ✅ **ODLOČENO (2026-07-31): A — vklopljeno** (odkritje prek čipa; argument prek darila) | T2.2 |

### P0.4 · Odločitve darila 🅿️ (lastnik; blokirata šele T7)

- Dolžina darila (delovni predlog 6 mesecev; izbira glede na sezono ob prižigu) — FR-20 §11.10.
- Gost brez računa: lokalno darilo vs. vezava na prijavo — FR-20 §11.9.

---

## T1 · Motor (`lib/core/biodynamic/`) — čista logika, brez UI

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

## T2 · Ogrodje (flag, nastavitve, barve, ruta, i18n skelet)

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

## T3 · Zasloni Luninega koledarja (jedro UI)

- **Vhod:** T1 (podatki), T2 (flag/barve/ruta/prefs), A5 (ikone), wireframe
  `lunar-calendar_overview.html`, screen-map §4.
- **Izhod:** delujoč `/moon-calendar` (+ `/moon-settings`), dosegljiv samo z ročno vklopljenim flagom;
  potrošnik za T6 gate.
- **Koraki (vsak vidni gradnik: najprej videz → pogled na napravi/wireframe → šele nato testi/prevodi):**
  1. ⬜ Mena kot `CustomPainter` (krivulja terminatorja iz osvetljenosti, §11.7) — samostojen widget,
     rabijo ga koledar, čip in dan-sheet. **Pogled na napravi** (8 faz).
  2. ⬜ Element-ikone (A5): 4 vektorske (ali začasno emoji, če A5=A) — en skupen widget
     `ElementBadge` (ikona+oznaka, nikoli samo barva — dostopnost).
  3. ⬜ `/moon-calendar` — **Mesec**: mreža (element-barva ozadja + mena + oznaka), ‹ › navigacija,
     legenda. **Dnevna oznaka celice = element ob začetku dneva** (konvencija tiskanih koledarjev,
     spec §12.6) + prikazno pravilo za polnočni drobec (prehod v prvi uri dneva → dan nosi novi
     element). Podatki: `List<BiodynamicDay>` iz providerja (memoizacija na (mesec, sistem) — meritev
     T1.11 je pokazala ~16 ms/mrežo → potrebna). **Pogled na napravi.**
  4. ⬜ `/moon-calendar` — **Teden**: agenda z opisi dejavnosti na element (lastna besedila —
     slot-filled predloge §11.6, i18n na element, ne per-dan proza). **Pogled.**
  5. ⬜ Dan podrobno — **sheet** (ne ruta; screen-map §5): »Kaj se dogaja« (ozvezdje/znamenje, ura
     prehoda, mena, dvigajoča/spuščajoča), CTA »＋ opravilo« → `/task-new?date=…` (obstoječi param).
     **Pogled.**
  6. ⬜ `/moon-settings`: stikalo (opt-in), sistem toggle (»Po ozvezdjih (biodinamični)« / »Po znamenjih
     (astrološki)«, ena vrstica razlage, §13), »Kaj je to« mini razlaga. Do T6 dosegljiv **samo prek
     rute z varovalom** (nobene povezave iz vidnih zaslonov); **končna umestitev pod Tendask+ zaslon
     pride s T6** (screen-map).
  7. ⬜ Po vizualni potrditvi vseh zaslonov: **de prevodi** + `dart run slang` + pregled dolgih nemških
     besed (Blütentag …).
  8. ⬜ Testi: widget testi ključnih interakcij (preklop sistema posodobi vse; tap dan odpre sheet) +
     `layoutMatrix('moon-calendar', …)` (+ teden, + sheet če izvedljivo) — 18 kombinacij/zaslon.
     Lunin zaslon ne rabi provider overridov (čista funkcija datuma) razen `MoonSettings`.
- **Branchi:** `feat/fr19-t3-1-phase-painter` · `feat/fr19-t3-2-element-icons` ·
  `feat/fr19-t3-3-month-view` · `feat/fr19-t3-4-week-agenda` · `feat/fr19-t3-5-day-sheet` ·
  `feat/fr19-t3-6-moon-settings` · `feat/fr19-t3-7-i18n-de` · `feat/fr19-t3-8-tests`.
- **Varnost na `main`:** vsi zasloni dosegljivi izključno prek flag-varovane rute → z izklopljenim
  flagom se ne izriše niti en piksel; nič sheme, nič mreže.
- **Pasti:** rich/plural nizi — `find.text` ne najde rich besedila (uporabi `toPlainText()`/
  `find.textContaining`) · barve samo prek `MoonColors`/teme · sheet vedno s `SheetHandle` ·
  prehodni dnevi (~44 %) morajo biti vizualno rešeni že v koraku 3 (dvobarvna celica ali oznaka), ne
  naknadno.

## T4 · Kontekstne oznake (vstopne točke)

- **Vhod:** T1 + T2; T3 za cilje navigacije. Mesta potrjena v kodi (pregled 2026-07-30):
  čip → `home_screen.dart` takoj za `HomeWeatherSection` · when-step → pod Datum/Ura vrstico ·
  task-detail → za sekcijo vremenskega posnetka.
- **Izhod:** vse vstopne točke iz screen-map §1–§3, za flagom.
- **Koraki:**
  1. ⬜ **Čip na Domov** (vzorec `HomeWeatherSection`: samostojen ConsumerWidget, ki sam bere providerje
     in sam odloči, ali se izriše): mena (free del) + desni CTA → `/moon-calendar`. Stanje
     »zaklenjeno → ✦ Tendask+« pride s T6 (do takrat samo odklenjeno stanje za flagom). **Pogled.**
  2. ⬜ **When-step oznaka**: **ločen ConsumerWidget otrok** (ne parameter `WhenStepBody` — ta je
     namenoma brez Riverpoda in ima 36 layout testov, ki jih ne podirava): medla vrstica
     »🌱 dan za list · do 14:20« iz izbranega datuma. **Pogled.**
  3. ⬜ **Task-detail sekcija**: element-dan iz `task.date` — **re-izpeljan, ne zamrznjen** (če uporabnik
     datum spremeni, se posodobi; kontrast z vremenom, ki JE zamrznjeno — spec §6.1.2). Info, brez tapa (MVP).
  4. ⬜ Widget/layout testi za vse tri + de prevodi po pogledu.
- **Branchi:** `feat/fr19-t4-1-home-chip` · `feat/fr19-t4-2-when-step` · `feat/fr19-t4-3-task-detail` ·
  `feat/fr19-t4-4-tests`.
- **Varnost na `main`:** vsak od treh widgetov ob izklopljenem flagu (ali izklopljenem opt-in stikalu)
  vrne prazno (`SizedBox.shrink` na nivoju vstopnega widgeta je tu legitimen — ni požiranje napake,
  ampak izklopljena funkcija) → obstoječi zasloni vizualno nespremenjeni; layout matrika obstoječih
  zaslonov mora ostati zelena brez sprememb.
- **Pasti:** vse tri oznake spoštujejo **opt-in stikalo** (off → nič nikjer) IN flag · čip bere ogrete
  prefs (T2.3), sicer utripanje · Dnevnik-plast (board C) **namerno ni v v1** (A2).

## T5 · Iskalnik »Kdaj za X« (`/moon-finder`) ⬜ — priporočen za v1, sme v v1.1

- **Vhod:** T3 (koledar, sheet), `coarsePlantCategory` (7 veder — obstaja), mapping element→kategorija
  (nova majhna tabela v motorju ali ob njem), plant-picker (obstaja).
- **Izhod:** obratni iskalnik + chip »🌙 Kdaj za …« na plant-detail (`?plant=:id` predizpolnjen) →
  seznam prihajajočih primernih dni → »＋« → `/task-new?date=…`.
- **Koraki:** 1. ⬜ mapping kategorija→element (konstanta + test) · 2. ⬜ zaslon (izbor rastline →
  dnevi) · 3. ⬜ plant-detail chip · 4. ⬜ pogled → testi/prevodi.
- **Branchi:** `feat/fr19-t5-1-category-map` · `feat/fr19-t5-2-finder-screen` ·
  `feat/fr19-t5-3-plant-chip` · `feat/fr19-t5-4-tests`.
- **Varnost na `main`:** kot T3/T4 — ruta z varovalom, chip za flagom.
- **Pasti:** pre-fill tipa/subjekta v `/task-new` je odprto (screen-map §5) — v1 samo `?date=` (obstaja);
  ne širi obsega brez odločitve.

## T6 · FR-20 minimalna rezina upravičenosti (edini task s shemo!)

- **Vhod:** T3+T4 obstajata (potrošnik gate-a) · **odločitev §11.4** (dependency za preverjanje podpisa
  tokena — izven `tech-stack §1` → **najprej vprašaj**) · FR-20 §6 (token model) · deploy runbook
  (staging → prod, migracija + granti v istem koraku).
- **Izhod:** zid obstaja, nič ne zaklepa (flag še off): shema `plus_until`/`plus_token`, `plusProvider`,
  osnovni `/tendask-plus` zaslon, gate ožičen na vstopne točke. Porabnik: T7.
- **Koraki:**
  1. ⬜ **Shema (additive, FR-20 §7):** Supabase migracija — `profile` dobi **tri nullable stolpce**:
     `plus_until timestamptz`, `plus_token text`, `plus_kind text` (samo za prikaz »Doživljenjska« vs
     »velja do …«; **upravičenost se bere VEDNO samo iz `plus_until`**) + **column-level `revoke update`
     za `plus_until`/`plus_token`** (server-lastna) + granti v isti migraciji. **`license*` tabele v
     rezino NE gredo** — pridejo s T8; masovni grant v T7 je pot FR-20 §6.6-C (`plus_until` naravnost
     na profile, brez kod). Drift zrcalo + `schemaVersion` dvig + `build_runner`.
  2. ⬜ **Sync izjeme (kritično, FR-20 §6):** pull stolpca prinaša, **push ju IZPUŠČA** iz payloada —
     sicer si predelan klient prek LWW podari Plus. + **test**, da push payload stolpcev ne vsebuje.
  3. ⬜ Dependency za podpis (po odobritvi): pin + `tech-stack.md §1` posodobitev.
  4. ⬜ `plusProvider`: bere drift, preveri podpis (bundlan javni ključ), čas prek `Clock`
     (konstruktor-injektiran — ne `static const` vzorec koordinatorjev); **gost brez profila → mirno
     ni-Plus** (brez izjem). Unit testi: veljaven/pretečen/predelan token, gost.
  5. ⬜ `/tendask-plus` zaslon (osnovni): stanje darila/veljavnost (»Doživljenjska« vs »velja do …« —
     FR-20 §6, `plus_kind` samo za prikaz), seznam funkcij (»Lunin koledar« → `/moon-settings`;
     prihodnje = »Kmalu«), **brez vnosa kode** (pride s T8) in **brez kančka nakupnega jezika**.
     Kartica »✦ Tendask+« v Nastavitvah pod profilom, za flagom **`kTendaskPlusEnabled`** (ime iz
     screen-map §2.1); ruta `/tendask-plus` z istim varovalom. **Pogled → prevodi → layout matrika.**
  6. ⬜ **Gate swap:** na vseh vstopnih točkah `kMoonCalendarEnabled` → `plusProvider` (+ master flag za
     prižig); čip dobi zaklenjeno stanje (rdeči »✦ Tendask+ ›« → `/tendask-plus`).
  7. ⬜ **Anti-steering i18n pregled** vseh novih nizov (FR-20 §3.1): brez cene, brez URL-ja, brez
     »kje dobiti kodo« — rdeča črta, ki lahko stane odstranitev aplikacije.
  8. ⬜ Staging preizkus: migracija na staging + ročno nastavljen `plus_until` → Plus se odklene/zaklene
     na napravi; offline (letalski način) Plus dela.
- **Branchi:** `feat/fr20-t6-1-schema` · `feat/fr20-t6-2-sync-exclusion` · `feat/fr20-t6-3-signature-dep` ·
  `feat/fr20-t6-4-plus-provider` · `feat/fr20-t6-5-plus-screen` · `feat/fr20-t6-6-gate-swap`
  (koraka 7–8 — i18n pregled in staging preizkus — sta kontrolna, brez lastnih branchev).
- **Varnost na `main`:** migracija additive + nullable (stari APK-ji ob pull ne crashajo, tolerantni
  parser ignorira neznano); najprej **staging**, prod `db push` po runbooku; gate je privzeto zaklenjen,
  a oba flaga off → nič vidnega; push izjema pokrita s testom PRED merge-om provider koraka.
- **Pasti (predpreverjene):** granti v isti migraciji (pravilo iz spomina) · pred prod buildom
  `supabase db push` pending migracij (pravilo iz spomina) · shemo premika SAMO ta task
  (serializacija §2 rollout plana) · vrstni red korakov je zavezujoč: sync izjema (2) se merga
  **pred** providerjem (4), da nobena vmesna izdaja ne pusha server-lastnih stolpcev.

## T7 · Prižig z darilom (en dogodek, majhen)

- **Vhod:** T6 na produkciji (temen) · P0.4 odločeni (dolžina, gost) · release APK z vsem zgoraj ·
  zgodba za objavo.
- **Izhod:** Lunin koledar živ za vse (podarjen Plus); mena free.
- **Koraki:**
  1. ⬜ Masovni grant: enkratna strežniška operacija — vsem obstoječim profilom `plus_until = prižig + X`
     + podpisani tokeni (mehanizem FR-20 §6.6); po odločitvi P0.4 tudi rešitev za goste.
  2. ⬜ Oba flaga on (`kMoonCalendarEnabled`, `kTendaskPlusEnabled`) — branch `feat/fr20-t7-ignite`,
     en drobcen commit — + release build (versionCode disciplina — nalaganje porabi kodo) + `db push` check.
  3. ⬜ Preverba na napravi (SM A536B): odklenjen tok, potek/zaklenjen tok (ročno skrajšan `plus_until`
     na stagingu), offline.
  4. ⬜ Objavljena zgodba (»X mesecev v zahvalo«) + Play listing/posnetki po potrebi (SL/EN/DE).
  5. ⬜ Zabeleži datum poteka prvih daril = **trdi rok za T8**.
- **Varnost:** to je edini korak, ki **namerno** spremeni vedenje v produkciji — zato je zadnji in
  najmanjši (en flag-flip commit + strežniška operacija); vse ostalo je bilo do takrat že tedne v
  produkciji temno in pretestirano.
- **Pasti:** Play `App access` še NI potreben (vnos kode ne obstaja do T8; pre-launch report Plus zaslonov
  tako ali tako ne pokrije).

## T8 · Trgovina (komercialni del FR-20) — rok: pred potekom prvih daril

Podrobni koraki so **FR-20 §12** (ne podvajam): odločitve cene + Polar/Paddle → Polar izdelka + webhook
Edge Function + RPC `redeem_license` + migracija `license` tabele → spletna stran `/plus` (3 jeziki,
popravek `t.hero.free`) → vnos kode na `/tendask-plus` → Play Console `App access` + `review` koda →
DoD sandbox matrika (nakup/unovčitev/offline/podaljšanje/vračilo/predelava/preklic).

- **Vhod:** T7 živ · FR-20 §11.2 (cene) in §11.3 (ponudnik) odločena.
- **Izhod:** kupljiv Tendask+ pred potekom daril.
- **Branchi:** določijo se ob razrezu taska (konvencija `feat/fr20-t8-N-slug`); `license*` shema je
  spet edini shemo-dotikajoč korak → serijsko, staging prej.

---

## Namerno zunaj v1 (da se obseg med delom ne razleze)

- **Lunina obvestila (spec §6.3.9)** — tihe ure in frekvenčna kapica sta v kodi danes »persisted but
  inert« (samo stikali); obvestilo brez njiju bi kršilo obljubo speca. Pride kot ločen task po prižigu
  (kandidat za širitev Plus paketa), skupaj z dejansko implementacijo tihih ur/kapice.
- **Personalizacija po vrtu (§6.3.8)** — poceni, a smiselna šele nad iskalnikom (T5); po prižigu.
- **Dnevnik-plast (board C, §8.9)** — A2 predlog: V2; `DayCell` je layout-kritičen pri 320 px × 1.3.
- **Retrospektivni vpogled (§6.3.11)** — dolgoročno.
- **Vnos licenčne kode, `license*` tabele, Play `App access`** — T8, ne prej.

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
