# FR-19 — prompt za naslednjo sejo (živ dokument)

> Ob koncu vsakega koraka sejo zaključi tako, da posodobiš ta dokument na NASLEDNJI korak
> (+ status v `plan-implementacije-fr19-fr20.md`). Uporabnik blok spodaj prilepi v novo sejo.

---

Gradiva FR-19 Lunin koledar po planu `docs/plan-implementacije-fr19-fr20.md` — **korak po koraku,
vsak korak v svoji seji**: en korak = en branch = en commit, vse temno (za flagom), merge v `main`.

**Kaj je narejeno (vse v main, 1233 testov):**
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
- **T3.8 testi ✅ (1. 8.) — T3 s tem ZAKLJUČEN:** widget testi
  (`test/features/moon/moon_calendar_screen_test.dart`, `moon_settings_screen_test.dart`): tap
  celica IN agenda vrstica odpre sheet · 🌌 podstikalo skrije »Kaj se dogaja« · ⚙️ odpre
  `/moon-settings` (mini-router, ker je flag temen) · preklop sistema + vsa stikala persistirajo
  (en controller vodi vse); + kontroler testi novih setterjev. **Layout matrika:** moon/month ·
  moon/week · moon/day-sheet (tap '15' v `after`) · moon-settings = 72 kombinacij; moon rabi samo
  `_dbOverrides` + `gardenElementsProvider.overrideWithValue` (★). **Popravljena oba 320 px/×1.3
  preloma** iz najdbe T3.7: vrstica mesečne celice (številka+★+mena) in `element_short` (celica +
  agenda stolpec) → `FittedBox.scaleDown` namesto odreza; vizualno preverjeno pri 320 px (PNG).
  Suite **1141 testov**.
- **T4.1 čip na Domov ✅ (1. 8., + code-review popravki isti dan):**
  `lib/features/home/presentation/widgets/home_moon_chip.dart` (board 1) — **gate
  `HomeMoonChip`** (flag ali izklopljeno opt-in stikalo → `SizedBox.shrink`; Domov nespremenjen)
  **+ javna kartica `HomeMoonChipCard`** (testabilna/izrisljiva brez prižiganja flaga — ta vzorec
  uporabi tudi za T4.2–T4.4 widgete!). Vsebina: `MoonPhaseIcon` + »Lunin koledar« + ime mene
  (free del) · desni CTA »dan za X ›« (element OZNAKE dneva — `moonMonthDayFor`, polnočna
  redukcija; `dayFor`/`moonMonthDayFor` sama normalizirata na polnoč, `DateTime.now()` je varen) →
  `context.push('/moon-calendar')`. Kartica in `MoonCalendarScreen` ob **resume** osvežita
  »danes« (`WidgetsBindingObserver` — aplikacija čez noč v ozadju ne sme kazati včerajšnjega
  dne). Zaklenjeno stanje (✦ Tendask+) pride s T6. Brez novih i18n ključev. Testi in matrika
  `home/moon-chip` so narejeni ŽE TU (gate-off → nič; tap → `/moon-calendar`). Iz reviewa še:
  error veja `/moon-settings` (`moon.settings.load_error` en+sl+de) + test ·
  `kMoonWhatsHappeningKey` (astro blok, namesto emoji finderja) · testa ‹ › navigacije meseca in
  sheet CTA »+ opravilo« → `/task-new?date=…` · matrika week z `expect(MoonWeekView)` · plan T6
  dobil pogoj »T4.4 pred prižigom« (sicer mrtvo stikalo Dnevnika). Suite **1164 testov**.
- **T4.2 when-step oznaka ✅ (1. 8.):** `MoonDayBadge`
  (`lib/features/moon/presentation/widgets/moon_day_badge.dart`) v `when_step.dart` pod
  Datum/Ura + privzeto opombo; `WhenStepBody` podpis NEDOTAKNJEN. Trislojno: **StatelessWidget
  gate s flag preverbo PRED vsakim ref** (⚠️ testi when-koraka pumpajo BREZ ProviderScope —
  dark badge ne sme zahtevati scope-a; test to zaklene; ob T7 prižigu bodo ti testi rabili
  scope!) → `_MoonDayBadgeGate` (opt-in stikalo) → javna `MoonDayBadgeRow` (za teste/matriko/
  predoglede brez flaga). Besedilo: »{emoji} dan za X · do HH:MM« (element oznake dneva prek
  `moonMonthDayFor`; rep samo, ko celica ohrani prehod — polnočna redukcija ga požre). Nov ključ
  `moon.badge.until` en+sl+de. Wireframe board B kaže starejšo varianto z »— ugodno za …« repom;
  plan (2026-07-30) jo je nadomestil s prehodno uro — ob priložnosti uskladi wireframe. Matrika
  `entry/when-badge` (18 komb., prehodni dan = najdaljši tekst) + testa (dark gate brez scope-a ·
  vsebina vrstice). Pogled: `tmp/moon_day_badge_preview_test.dart` → `tmp/moon_day_badge.png`.
  Suite **1184 testov**.
- **T4.3 task-detail sekcija ✅ (1. 8.):** `MoonTaskSection`
  (`lib/features/moon/presentation/widgets/moon_task_section.dart`, board A) v
  `task_detail_screen.dart` takoj za vremensko sekcijo, vhod `task.date.toLocal()` —
  **re-izpeljano ob vsakem buildu, ne zamrznjeno** (kontrast z vremenom, spec §6.1.2). Trislojni
  vzorec T4.2: StatelessWidget flag gate (skrije TUDI `SectionLabel`) → opt-in gate → javna
  `MoonTaskSectionCard` (emoji 26 + »Dan za X« + `until_then` rep ob prehodu + pripis
  `moon.task_section.footnote` en+sl+de). Brez trigon/»ogenj« dela z boarda A — MVP po planu.
  `sentenceCase` ekstrahiran v `moon/presentation/moon_text.dart` (3. pojavitev; sheet in
  week_view zdaj uporabljata skupnega). Matrika `task/moon-section` + testa (dark gate · vsebina).
  Pogled: `tmp/moon_task_section_preview_test.dart` → `tmp/moon_task_section.png`. Suite
  **1204 testov**.
- **Uskladitev wireframe ↔ plan (31. 7., lastnik) ✅:** A2=C **v v1** (Dnevnik: 🌙 AppBar vstop +
  barvna plast → T4.4) · ★ + »poudari po mojem vrtu« v v1 (**T5.1 mapping se izvede PRED T3.3**) ·
  dan podrobno = sheet z drsenjem (+ »Priporočeno za …« s »＋ opravilo«) · lunino obvestilo
  »jutri dober dan« v v1 kot **T4b** (tihe ure + kapica tam; 🔔 vrstica v nastavitvah šele takrat) ·
  T3.6 podstikala (poudari/Dnevnik/ozvezdja) + ⚙️ vstop iz koledarja · `/moon-calendar` = dom.

- **T4.4 Dnevnik-plast ✅ (1. 8.):** `journal_moon.dart` (`moon/presentation/widgets/`) —
  trislojni **🌙 gumb** `JournalMoonButton` v AppBar `/journal` (flag gate brez ref → opt-in gate
  → javna `JournalMoonIconButton` → push `/moon-calendar`; podstikalo velja za PLAST, ne za
  gumb) + **`journalMoonDays(ref, mesec)`** (null, dokler flag + opt-in + `showInJournal` niso
  vsi vklopljeni → mreža piksel-identična današnji). `DayCell` dobi opcijski `moonDay`
  (`MoonMonthDay`): soft element ozadje (izbran/danes ostaneta na obrobi, board C) + mena-marker
  ob številki (`FittedBox.scaleDown`); pike/tap nespremenjeni (tap dan OSTANE dnevniški).
  Brez novih i18n ključev (tooltip = `moon.calendar.title`). **Mimogrede popravljena latentna
  tesnoba `DayCell`:** številka + pike pri 320 px × 1.3 prekipita za 1,3 px (matrika Dnevnika
  je ne ujame, ker tekoči mesec v fixture nima pik) → vrstica pik v `Flexible` +
  `FittedBox.scaleDown`. Matrika `journal/moon-layer` (javno jedro `DayCell`+`moonDay`,
  avg 2026 = markerji na dvomestnih dnevih) + testi (dark gumb brez scope-a · tap → ruta ·
  `journalMoonDays` dark → null brez dotika providerja · celica z/brez plasti). Pogled prek
  `tmp/journal_moon_preview_test.dart` → `tmp/journal_moon_{light,dark,320}.png`; ob prvem
  zagonu na napravi preveri plast + 🌙 gumb. Suite **1227 testov**.

- **T4.5 pregled testov + de ✅ (1. 8.) — T4 s tem ZAKLJUČEN:** testi in matrike so prišli že z
  vsakim korakom, zato je bil ta korak pregled + zapolnitev vrzeli. Tri najdbe: **(1) de prelom v
  čipu na Domov** — pri 320 px × 1.3 je CTA vzel naravno širino in izstradal naslovni stolpec, zato
  sta se »Mondkalender« in »abnehmender Mond« lomila SREDI BESEDE (layout matrika tega ne ujame:
  prosto-ovijajoč tekst se nikoli ne odreže, gl. pravilo v CLAUDE.md) → CTA `Flexible(flex: 2)` +
  `FittedBox.scaleDown`, stolpec `Expanded(flex: 3)`, naslov `FittedBox.scaleDown` + `maxLines: 1`;
  360 × 1.0 nespremenjen, sl/en brez sprememb. **(2) srednja plast vrat (opt-in stikalo) ni bila
  testirana pri NOBENI od štirih točk** (temni flag jo prekrije) → pravili ekstrahirani v
  `moonSurfaceOn()` / `journalMoonLayerOn()` (`moon/presentation/moon_gate.dart`, 4 klicalci) +
  `moon_gate_test.dart`. **(3) priklop na gostitelja** lovi test le pri when-koraku (`WhenStepBody`
  je brez Riverpoda → poceni); ostali trije rabijo cel svet providerjev, zato je preverba dodana v
  **T7 korak 3**. Pogled: `tmp/moon_t4_de_preview_test.dart` → `tmp/moon_t4_*.png`. Suite **1233**.

- **T4b korak 1 ✅ (1. 8.) — B1 ODLOČEN, tihe ure + kapica oživele:** **B1 (lastnik, 1. 8.):**
  dostava **device-local** (razporeja naprava, nič FCM/crona/oblačne sheme — motor je čista funkcija
  datuma) · **opt-in 🔔 gre v `NotificationSettings`** (profile JSON, **sinhroniziran**, sledi
  uporabniku med napravami; tolerantni parser → **brez migracije**) · **kapica velja samo za namige**
  (lunin namig + dnevniški nudge si ne delita dneva; eksplicitni opomnik opravila dneva ne zasede).
  Pravili živita v `core/notifications/hint_rules.dart`: `inQuietHours(local)` (okno 22–07 čez
  polnoč) in `hintFireTime({desiredLocal, settings, otherHintDays})` → tihe ure namig **prestavijo**
  na 07:00 (nikoli ne izbrišejo), kapica vrne `null`, če je dan že zaseden, **presoja pa teče na
  prestavljenem dnevu** (test to zaklene). Priklopljen `JournalNudgeCoordinator` — dokazano brez
  spremembe vedenja (17:00 ni v oknu; nudge nima sotekmecev, ker se bo **lunin namig umikal njemu**,
  ne obratno) + regresijski test. Posodobljena zastarela komentarja (`notification_settings.dart`
  »inert«, `config.dart` »display only« + napačna trditev, da so tihe ure device-local).
  Suite **1244**.

**Naloga TE seje: T4b korak 2 — izračun + razpored luninega namiga** (branch
`feat/fr19-t4b-2-scheduler`; koraka 3 in 4 sta svoji seji):

- **Kaj:** device-local razporejevalnik namiga »jutri je dan za X« — po vzorcu
  `JournalNudgeCoordinator` (re-arm ob zagonu/resume/spremembi nastavitev, rezervirani negativni
  id-ji v `config.dart`, `scheduleNudge` = inexact kanal, brez exact-alarm dovoljenja).
- **Skozi `hintFireTime`** (korak 1): želeni čas → tihe ure/kapica; `otherHintDays` = dnevi, ki jih
  že zaseda dnevniški nudge (lunin namig se umakne njemu). Ura namiga = nova konstanta v `config.dart`.
- **Vhod za vsebino:** `dayFor(jutri, system)` prek `MoonSettingsController` (en `system` vodi vse).
- **Pasti (plan T4b):** obvestilo ob prikazu dan **re-izpelje** (ne zamrzne ob razporeditvi) ·
  spoštuje preklop sistema · UI nikjer ne reče »motor« · `Clock` namesto `DateTime.now()` (testi
  rabijo FakeClock) · dokler stikala ni (korak 3), se **nič ne razporeja** — flag + privzeto off.
- **Vrstica 🔔 v `/moon-settings` pride šele s korakom 3** — brez mrtvih stikal.

**Pred delom preberi:** plan **T4b** (`docs/plan-implementacije-fr19-fr20.md`) · spec §6.3.9 ·
`core/notifications/hint_rules.dart` (korak 1) · `journal_nudge_coordinator.dart` (vzorec) ·
`notification_settings.dart` (kam gre nova opt-in vrednost).

**Pravila:** naredi natanko ta korak in nič več. Pred merge: `flutter analyze` čist + cel
`flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu označi T4b korak 1, posodobi ta
dokument na naslednji korak in predlagaj commit.

**Stanje odločitev:** A1=C ✅ · A2=C ✅ (v v1) · A3=A ✅ · A4=A ✅ (fiksne semantične + kontrastna
omejitev) · **A5 razrešen: A — emoji** (fallback po pogoju, 31. 7.) · A6=A ✅ (privzeto vklopljeno) ·
**B1 ✅ ODLOČEN (1. 8.): dostava device-local, opt-in 🔔 sinhroniziran (profile JSON), kapica samo za
namige.** Odprtih odločitev FR-19 ni več.
