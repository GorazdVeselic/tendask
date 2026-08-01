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
- **Uskladitev wireframe ↔ plan (31. 7., lastnik) ✅:** A2=C **v v1** (Dnevnik: 🌙 AppBar vstop +
  barvna plast → T4.4) · ★ + »poudari po mojem vrtu« v v1 (**T5.1 mapping se izvede PRED T3.3**) ·
  dan podrobno = sheet z drsenjem (+ »Priporočeno za …« s »＋ opravilo«) · lunino obvestilo
  »jutri dober dan« v v1 kot **T4b** (tihe ure + kapica tam; 🔔 vrstica v nastavitvah šele takrat) ·
  T3.6 podstikala (poudari/Dnevnik/ozvezdja) + ⚙️ vstop iz koledarja · `/moon-calendar` = dom.

**Naloga TE seje: korak T3.6 — `/moon-settings`** (branch `feat/fr19-t3-6-moon-settings`):

- Zaslon nastavitev Luninega koledarja (wireframe board 2b): **glavno stikalo** (opt-in po A6) ·
  **sistem toggle** »Po ozvezdjih (biodinamični)« / »Po znamenjih (astrološki)« z eno vrstico
  razlage (spec §13) · **podstikala (31. 7.):** »Poudari po mojem vrtu« (★ — ključ
  `moon_highlight_garden` + setter že obstajata iz T3.3) · »Prikaži v Dnevniku« (plast, potrošnik
  pride s T4.4) · »Prikaži ozvezdja in meno« (podrobnosti v dan-sheetu — potrošnika ožiči po
  planu/wireframu). Vrstica »Namig 'jutri dober dan'« pride šele s **T4b** — brez mrtvih stikal.
  »Kaj je to« mini razlaga.
- Nova prefs ključa za podstikali Dnevnik/ozvezdja po vzorcu `moon_highlight_garden` (null =
  privzeto vklopljeno) + setterja v `MoonSettingsController`.
- Vstop: **⚙️ v AppBar `/moon-calendar`** (ožiči ta korak; koledar je sam za flagom) + ruta
  `/moon-settings` z `moonCalendarRedirect` varovalom; posodobi `route_collision_test` in
  `screen-map.md` (pravilo: isti commit). Umestitev pod Tendask+ zaslon pride s T6.
- **Najprej videz → pogled na napravi → šele nato testi/prevodi**; de pride s T3.7, testi s T3.8.

**Pred delom preberi:** plan T3 korak 6 (`docs/plan-implementacije-fr19-fr20.md`) · wireframe
`docs/wireframes/lunar-calendar_overview.html` board 2b · spec §13
(`docs/feature-requests/biodynamic-calendar.md`) · `MoonSettingsController` + `local_prefs`
(`lib/features/moon/application/`, `lib/core/`) · ruta + varovalo (`app/router/app_router.dart`) ·
`moon_day_sheet.dart` (kandidat potrošnik »Prikaži ozvezdja in meno«).

**Pravila:** naredi natanko ta korak in nič več (ne začenjaj T3.7). Pred merge: `flutter analyze`
čist + cel `flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu označi T3.6, posodobi ta
dokument na naslednji korak (T3.7 de prevodi; branch `feat/fr19-t3-7-i18n-de`) in predlagaj
commit.

**Stanje odločitev:** A1=C ✅ · A2=C ✅ (v v1) · A3=A ✅ · A4=A ✅ (fiksne semantične + kontrastna
omejitev) · **A5 razrešen: A — emoji** (fallback po pogoju, 31. 7.) · A6=A ✅ (privzeto vklopljeno) ·
**B1 (device-local vs sync za lunina obvestila) še ODPRTA — odloči se na začetku T4b.**
