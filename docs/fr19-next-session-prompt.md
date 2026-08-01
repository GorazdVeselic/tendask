# FR-19 — prompt za naslednjo sejo (živ dokument)

> Ob koncu vsakega koraka sejo zaključi tako, da posodobiš ta dokument na NASLEDNJI korak
> (+ status v `plan-implementacije-fr19-fr20.md`). Uporabnik blok spodaj prilepi v novo sejo.

---

Gradiva FR-19 Lunin koledar po planu `docs/plan-implementacije-fr19-fr20.md` — **korak po koraku,
vsak korak v svoji seji**: en korak = en branch = en commit, vse temno (za flagom), merge v `main`.

**Kaj je narejeno (vse v main, 1059 testov):**
- **T1 motor ✅** (`lib/core/biodynamic/`): vse 4 plasti (zodiak s kalibriranimi mejami + IAU
  rezerva, mena, ascending, neugodni dnevi — kalibrirano na tiskani Thun 2024), fixture jul+avg
  2026 (62 dni × 2 sistema), pokritost 99,5 %. ⚠️ CI `Test` korak ima `TZ: Europe/Ljubljana`
  (fixture/Thun ure so CET/CEST) — ne odstranjuj.
- **T2 ogrodje ✅ (cel):** `kMoonCalendarEnabled = false` (`core/config.dart`, edino stikalo do
  T6) · `local_prefs` ključa (`moon_calendar_enabled` bool?, null = privzeto VKLOPLJENO po A6;
  `moon_system`, privzeto sidereal) · `MoonSettingsController`
  (`lib/features/moon/application/`, **keepAlive**, ogret v bootstrapu ne-fatalno, en `system`
  vodi vse zaslone §11.6) · `MoonColors` ThemeExtension (hexi v `AppColors`, instanci v
  `moon_colors.dart`, registrirano za vseh 6 palet) · ruta `/moon-calendar` s placeholderjem in
  `moonCalendarRedirect` varovalom na ruti (deep-link) · i18n namespace `moon` en+sl kot slang
  **mape po enum `.name`** (`t.moon.day_for[element.name]`, `sign`, `phase`; `division` =
  ozvezdje/znamenje varianta §11.6); de pade na en, pride kot T3.7.
  **A4 omejitev (izmerjeni kontrasti, decisions doc):** tekst na soft ozadju = `onSurface`
  (svetli cvet 1,8:1 pade!), poudarek samo za ikono/glif; temne odtenke fino nastavi ob prvem
  pogledu. Predogled barv: `tmp/moon_colors_preview.html`.
- **T3.1 mena kot `CustomPainter` ✅ (31. 7.):** `MoonPhaseIcon(phase, illumFraction, size, color?)`
  (`lib/features/moon/presentation/widgets/moon_phase_icon.dart`) — obris diska + osvetljeni del
  z elipso terminatorja; barva privzeto `onSurfaceVariant`. Videz potrjen prek harnessa
  `tmp/moon_phase_preview_test.dart`; testi s pixel-samplingom. Widget še nima klicalca (temno).
- **T3.2 `ElementBadge` ✅ (31. 7.):** vektorski osnutki ob pogledu ZAVRNJENI → **A5 razrešen kot
  emoji fallback** (🍅🥕🌸🌿, isti kot wireframe). `ElementBadge(element)`
  (`lib/features/moon/presentation/widgets/element_badge.dart`): emoji + oznaka
  `t.moon.day_for[...]`, soft ozadje iz `MoonColors`, tekst `onSurface` (A4); **glif živi samo v
  `elementEmoji(element)`** (ista datoteka) — vsaka prihodnja površina (mreža, sheet, čip) bere
  od tam, brez kopij. Predogled `tmp/element_badge_preview.png` (opomba: rumen pas pod emoji je
  artefakt Segoe fonta v golden okolju, na napravi ga ni). Testi
  `test/features/moon/element_badge_test.dart`; popolnost `day_for` mape že krije
  `test/i18n/moon_i18n_test.dart`. Brez klicalca (temno).
- **T5.1 mapping kategorija→element ✅ (31. 7. + revizija 1. 8.):**
  `core/biodynamic/category_element.dart` — `plantElement({category, plantId})` vrne
  `BiodynamicElement?`; vedra fruit_tree/berries→plod, herbs/lawn→list, ornamental→cvet;
  houseplant + conifer + hedge **brez priporočila** (`kCategoryNoElement`, preverba na FINI
  kategoriji pred foldingom). `kPlantElementOverride` po `plant.id` (34 vnosov: 32 vrtnin +
  kamilica/sivka→cvet) po Thun: kapusnice→list z **brokolijem kot edino cvetno izjemo,
  cvetača→LIST** (revizija 1. 8. po navzkrižni preverbi prc-lu.si + nemški viri),
  čebula/česen/zelena→koren (zelena = gomoljna, komentar v kodi), por/kolerabica→list,
  stročnice/koruza→plod. **Katalog NEDOTAKNJEN** (odločitev lastnika 31. 7.: sprememba
  `category` vrednosti v oblaku bi starim APK-jem izpraznila čip Vrtnine) — delitev živi samo
  v kodi; testi popolnosti proti seedu (katalog ima **141 vrst**, ne 128) prisilijo vnos za
  vsako novo vrtnino. Custom rastline → null (brez ★). Brez klicalca (temno).
- **T3.3 Mesec (mreža) ✅ (1. 8.):** `MoonCalendarScreen` (`lib/features/moon/presentation/`) —
  mreža prek `monthCells` (premaknjen v `core/month_cells.dart`) + `MonthNav`/`WeekdayHeader`
  (premaknjena v `core/widgets/month_chrome.dart`; Dnevnik posodobljen). Podatki:
  `moonMonthProvider(month)` (`moon_month_provider.dart`) — memoizacija po (mesec, sistem),
  `MoonMonthDay` = date + element + secondaryElement + principalPhase; `principalPhaseOn()` v
  `core/biodynamic/moon_calendar.dart` (marker samo na dan točnega dogodka mlaj/krajca/ščip).
  **Prehodni dan = deljeno ozadje** zgoraj (pred) / spodaj (po); polnočni drobec: prehod <
  `kMoonMidnightSliverWindow` (1 h, `config.dart`) → cel dan nosi novi element. **★** =
  `gardenElementsProvider` (plantElement nad user_plant × katalog; custom → nič) ×
  `MoonSettings.highlightGarden` — nov prefs ključ `moon_highlight_garden` (null = vklopljeno),
  setter v controllerju pripravljen za T3.6; **★ gleda element OZNAKE dneva** (ne sekundarnega).
  Legenda: 4 barve + 4 mene + ★. i18n: `moon.calendar.{title,legend_star}`, `element(map)`,
  `element_short(map)` en+sl. Naprave ni bilo → videz potrjen prek
  `tmp/moon_month_preview_test.dart` → `tmp/moon_month_{light,dark}.png` (⚠️ zelena kvadrata
  namesto ‹ › = manjkajoč MaterialIcons font v golden okolju, na napravi OK). Testi/layout
  matrika pride s T3.8; ob prvem zagonu na napravi preveri temne odtenke (A4 opomba).
- **T3.4 Teden (agenda) ✅ (1. 8.):** `/moon-calendar` = **Segmented [Mesec | Teden]** nad enim
  skupnim sidrom (`_anchor` v `MoonCalendarScreen`) — preklop pogledov ostane na istem obdobju;
  če je danes v vidnem obdobju, preklop pristane na tekočem tednu/mesecu. Zaslon razdeljen:
  `moon_month_view.dart` (mreža+legenda, izločeno iz screen) + `moon_week_view.dart` (agenda) +
  `moon_calendar_screen.dart` (scaffold+segment+sidro). **Agenda vrstica** = datum (dan +
  `weekday_short` mapa) · emoji + `element_short` · naslov »Dan za X« (+ `MoonPhaseIcon` in ime
  mene na dan dogodka, + »· danes«, + ★ po vrtu) · **opis dejavnosti na element** (LASTNA
  besedila, `moon.activity(map)`; mlaj → `activity_new_moon` override po wireframu). Današnja
  vrstica = `primaryContainer` α0,35 ozadje; kratka element-oznaka `onSurfaceVariant` (A4 —
  brez element-barve na tekstu). Podatki: **brez novega providerja** — mreža meseca zadnjega dne
  tedna nosi 6 vodilnih dni, torej pokrije vsak teden (`moonMonthProvider(mesec konca tedna)`).
  `principalIllumFraction()` premaknjen v `moon_phase_icon.dart` (skupno obema pogledoma). i18n:
  `moon.calendar.{month_view,week_view,today_marker,weekday_short(map)}`, `activity(map)`,
  `activity_new_moon` en+sl; `moon_i18n_test.dart` razširjen na popolnost VSEH map (tudi
  element/element_short iz T3.3, ki nista bili pokriti). Naprave ni bilo → videz potrjen prek
  `tmp/moon_week_preview_test.dart` → `tmp/moon_week_{light,dark}.png`; ob prvem zagonu na
  napravi preveri teden + preklop segmentov.
- **T3.5 Dan podrobno (sheet) ✅ (1. 8.):** tap na dan (mesečna celica IN agenda vrstica) odpre
  `showMoonDaySheet(context, date)` (`moon_day_sheet.dart`) — `showModalBottomSheet` +
  `DraggableScrollableSheet` (0,4/0,65/0,95) + `SheetHandle`. Naslov = `formatFullDate`; hero =
  element **oznake** dneva (ista polnočna redukcija kot celica — `moonMonthDayFor`) + »do HH:MM,
  nato …« ob prehodu. **»Kaj se dogaja«** = slot-filled predloge `moon.sheet.*` (**rich**, poudarki
  bold; ozvezdje/znamenje = dve predlogi ene povedi §11.6): pozicija + ura prehoda (naslednje
  znamenje = naslednje v ekliptičnem vrstnem redu, Luna je prograde) · mena (`MoonPhaseIcon` z
  dejansko `illumFraction`) + pomen rastoča/upadajoča · dvigajoča/spuščajoča ↗↘ · ugodnost ✓/⚠.
  **»Priporočeno za <dan>«** = vrstica na element (primarni + sekundarni; mlaj →
  `activity_new_moon` namesto element vrstic), CTA »+ opravilo« → `/task-new?date=ISO` (sheet
  ostane odprt pod obrazcem). `MoonColors.softOf(element)` nova skupna metoda (3 klicalci,
  lokalne kopije odstranjene). ⚠️ fullwidth »＋« zamenjan z ASCII »+« (fallback font ga riše
  narobe). Naprave ni bilo → videz potrjen prek `tmp/moon_day_sheet_preview_test.dart` →
  `tmp/moon_day_sheet_{light,dark,unfavorable}.png`; ob prvem zagonu na napravi preveri sheet
  (revizija sheet↔zaslon po odločitvi 31. 7.).
- **T3.6 `/moon-settings` ✅ (1. 8.):** `MoonSettingsScreen`
  (`lib/features/moon/presentation/moon_settings_screen.dart`, wireframe board 2b) — glavno
  stikalo 🌙 · **sistem segmented** (dvovrstična segmenta »Po ozvezdjih/biodinamični« ·
  »Po znamenjih/astrološki« + vrstica razlage §13) · podstikala 🪴 poudari po vrtu / 📅 prikaži v
  Dnevniku / 🌌 ozvezdja in meno · tinted kartica »Kaj je to?« (rich bold + pripis
  tradicija-ne-nasvet); 🔔 vrstice NI (pride s T4b). Nova prefs ključa `moon_show_in_journal` +
  `moon_show_astro_details` (null = vklopljeno) + setterja; `MoonSettings` razširjen
  (`showInJournal`, `showAstroDetails`). **Potrošnik »ozvezdja in meno« ožičen:** dan-sheet ob
  izklopu skrije blok »Kaj se dogaja« (Dnevnik-potrošnik pride s T4.4). Vstop: **⚙️ v AppBar
  koledarja** → `pushNamed('moon-settings')`; ruta z `moonCalendarRedirect`;
  `route_collision_test` zdaj preverja varovalo na OBEH moon rutah; screen-map §4 »Stanje rut«
  posodobljen. i18n `moon.settings.*` en+sl. Naprave ni bilo → videz potrjen prek
  `tmp/moon_settings_preview_test.dart` → `tmp/moon_settings_{light,dark}.png`; ob prvem zagonu
  na napravi preveri zaslon (tudi segmenta pri širokem de tekstu, ko pride T3.7).
- **T3.7 de prevodi ✅ (1. 8.):** cel `moon` namespace v `de.i18n.json` (calendar · settings ·
  day_for · activity · element/element_short · division · sign · phase · sheet z rich predlogami,
  nemški besedni red preverjen na sheetu). Terminologija po mehanizmu (§13): Sternbild/Zeichen,
  nikjer Thun/Aussaattage. **`element_short` de = `Fru.`/`Wur.`** — polna `Frucht`/`Wurzel` se v
  mesečni celici odrežeta (vzorec sl `koren.`); `Blüte`/`Blatt` cela. Pogledi prek
  `tmp/moon_de_preview_test.dart` → `tmp/moon_de_{month,week,settings,sheet}.png`.
  **⚠️ Najdba za T3.8:** zgornja vrstica mesečne celice (številka + ★ + mena-ikona) prekipi
  ~4 px pri **320 px** viewportu, ne glede na jezik — layout matrika jo MORA pokriti (fix v T3.8).
- **Uskladitev wireframe ↔ plan (31. 7., lastnik) ✅:** A2=C **v v1** (Dnevnik: 🌙 AppBar vstop +
  barvna plast → T4.4) · ★ + »poudari po mojem vrtu« v v1 (**T5.1 mapping se izvede PRED T3.3**) ·
  dan podrobno = sheet z drsenjem (+ »Priporočeno za …« s »＋ opravilo«) · lunino obvestilo
  »jutri dober dan« v v1 kot **T4b** (tihe ure + kapica tam; 🔔 vrstica v nastavitvah šele takrat) ·
  T3.6 podstikala (poudari/Dnevnik/ozvezdja) + ⚙️ vstop iz koledarja · `/moon-calendar` = dom.

**Naloga TE seje: korak T3.8 — testi** (branch `feat/fr19-t3-8-tests`):

- **Widget testi ključnih interakcij:** preklop sistema posodobi vse (nastavitve → koledar/sheet
  berejo isti `MoonSettings.system`) · tap na dan (celica IN agenda vrstica) odpre sheet ·
  podstikalo 🌌 skrije »Kaj se dogaja« v sheetu · ⚙️ odpre `/moon-settings`. Rich nizi: `find.text`
  jih NE najde — `toPlainText()`/`find.textContaining`.
- **Layout matrika:** `layoutMatrix('moon-calendar', …)` (+ teden, + `/moon-settings`, + sheet če
  izvedljivo) — 18 kombinacij/zaslon (320/360/411 × sl/en/de × 1.0/1.3). Moon zasloni ne rabijo
  provider overridov (čista funkcija datuma) razen `MoonSettings`; DB override po vzorcu
  `tmp/moon_*_preview_test.dart`.
- **⚠️ Znana najdba (iz T3.7):** zgornja vrstica mesečne celice (številka + ★ + mena-ikona)
  prekipi ~4 px pri **320 px** — matrika jo bo ujela; popravi (npr. manjši razmik/ikona ali
  `FittedBox`) v tem koraku.
- Past iz CLAUDE.md: `container.read(streamProvider.future)` brez poslušalca ne dokonča;
  H3/FFI se pod `flutter test` ne naloži (tu ni relevanten, moon je čista funkcija).

**Pred delom preberi:** plan T3 korak 8 (`docs/plan-implementacije-fr19-fr20.md`) ·
`test/layout/layout_harness.dart` + `layout_matrix_test.dart` (vzorec `layoutMatrix`) ·
`tmp/moon_de_preview_test.dart` (DB/locale setup) · `moon_month_view.dart` `_MoonDayCell`
(mesto 320 px prekipenja).

**Pravila:** naredi natanko ta korak in nič več (T3 s tem koncem zaključen; naslednji task je T4.1
čip na Domov). Pred merge: `flutter analyze` čist + cel `flutter test` zelen. Pred commitom
vprašaj. Ob koncu: v planu označi T3.8, posodobi ta dokument na naslednji korak (T4.1 home chip;
branch `feat/fr19-t4-1-home-chip`) in predlagaj commit.

**Stanje odločitev:** A1=C ✅ · A2=C ✅ (v v1) · A3=A ✅ · A4=A ✅ (fiksne semantične + kontrastna
omejitev) · **A5 razrešen: A — emoji** (fallback po pogoju, 31. 7.) · A6=A ✅ (privzeto vklopljeno) ·
**B1 (device-local vs sync za lunina obvestila) še ODPRTA — odloči se na začetku T4b.**
