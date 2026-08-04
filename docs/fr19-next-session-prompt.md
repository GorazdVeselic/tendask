# FR-19 — prompt za naslednjo sejo (živ dokument)

> Ob koncu vsakega koraka sejo zaključi tako, da posodobiš ta dokument na NASLEDNJI korak
> (+ status v `plan-implementacije-fr19-fr20.md`). Uporabnik blok spodaj prilepi v novo sejo.

---

Gradiva FR-19 Lunin koledar po planu `docs/plan-implementacije-fr19-fr20.md` — **korak po koraku,
vsak korak v svoji seji**: en korak = en branch = en commit, vse temno (za flagom), merge v `main`.

**Kaj je narejeno (vse v main, 1537 testov — veji `feat/fr20-t6-1-schema` in
`feat/prod-analytics-tooling` sta zmergani):**
- **T1 motor ✅** (`lib/core/biodynamic/`): vse 4 plasti (zodiak s kalibriranimi mejami + IAU
  rezerva, mena, ascending, neugodni dnevi — kalibrirano na tiskani Thun 2024), fixture jul+avg
  2026 (62 dni × 2 sistema), pokritost 99,5 %. ⚠️ CI `Test` korak ima `TZ: Europe/Ljubljana`
  (fixture/Thun ure so CET/CEST) — ne odstranjuj.
- **T2 ogrodje ✅ (cel):** `kMoonCalendarEnabled = false` (`core/config.dart`, edino stikalo do
  T6) · `local_prefs` ključa (`moon_calendar_enabled` — **izbrisan v koraku 6b**;
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

- **Pregled kode FR-19 (1. 8.) ✅ — po njem popravljeno vse najdeno:** **(1)** `MoonColors.of(context)`
  (6 kopij `extension<MoonColors>() ?? moonColorsLight`) + `strongOf()` k `softOf()` (prej privatna
  funkcija v mesečnem pogledu) · **(2)** nov `moonSystemProvider` (5 kopij »sistem s sidereal
  fallbackom«; en sam vir za §11.6) · **(3)** `MoonMonthDay` dobil **`transitionAt`** → trije zasloni
  ne sestavljajo več para `(day.transitionAt, cell.secondaryElement)` in **ne kličejo motorja dvakrat**
  (badge in task-sekcija zdaj sploh ne kličeta `dayFor`) · **(4)** tedenska agenda ne more več tiho
  izgubiti vrstice (`_dayOfWeek` izračuna dan, ki ga mesečna mapa ne doseže — prej `if case` preskok) ·
  **(5) B1a odločitev lastnika: mena ostane free za vedno** → plan T6 korak 6 ima zdaj izrecno
  opozorilo, da čip rabi **deljena vrata** (mena vidna vsem, element-dan za zid) · **(6)** wireframe
  board B usklajen z dejansko oznako (»· do 14:20«, medla vrstica brez pike). **21 novih testov**
  (suite **1265**): polnočni drobec v `moonMonthDayFor` (vseh 7 dni 2026), `principalPhaseOn` (avg 2026
  = 4 markerji), pokritost ključev `moonMonth` (−6 … konec meseca, 37) + sledenje sistemu, teden čez
  mejo meseca in leta, `gardenElements` nad pravim katalogom (lastna rastlina/soba/izbris), sistem
  odloča besedilo sheeta (ozvezdje ↔ znamenje).

- **T4b korak 2 ✅ (1. 8.) — razporejevalnik luninega namiga:** **odločitev lastnika o ritmu:** namig
  pride **samo za dneve, ki jih vrt lahko uporabi** (element dneva ∈ `gardenElements`, isto pravilo kot
  ★; prazen vrt = tišina) in **ob 18:00 dan prej**; zavrnjeni »vsak večer« in »samo ob menjavi
  elementa« (zapisano v decisions B1). Čisti izračun `moonHintCandidates()`
  (`moon/application/moon_hint_schedule.dart`, vrne `MoonHint` = fireTime + date + element + isNewMoon;
  eve prek `startOfDay` zaradi DST; pretekli časi odpadejo) → `MoonHintCoordinator`
  (`moon_hint_coordinator.dart`, keepAlive, vzorec `JournalNudgeCoordinator`): re-arm ob
  zagonu (`main.dart`), resume (`app.dart`, poleg nudgea) in spremembi luninih nastavitev / vrta /
  profila (debounce `kReminderDebounce`); `Clock` namesto `DateTime.now()`; horizont **7 dni** =
  `kMoonHintNotificationIds` (−211…−217), `kMoonHintHour = 18`. Vsak kandidat gre skozi `hintFireTime`
  z `otherHintDays` = dnevi dnevniškega nudgea (nov `journalNudgeDays()`; `futureTaskReminderDays()`
  ekstrahiran iz nudge koordinatorja v `reminder_schedule.dart`, da oba računata isto) + že zasedeni
  lunini dnevi; obramba: če bi tihe ure namig prestavile čez polnoč, ga raje spusti (»jutri« mora priti
  dan prej — pri 18:00 nemogoče). **Opt-in `moonHintEnabled`** v `NotificationSettings` (JSON
  `moon_hint`, privzeto **false**, tolerantni parser → brez migracije). Vsebina se **re-izpelje ob
  vsakem arm-u**: naslov nov ključ `moon.hint.title` (en+sl+de) nad `day_for`, telo = obstoječi
  `activity` (mlaj → `activity_new_moon`, isto kot agenda). ⚠️ **Najdba:** orphan sweep opomnikov je
  brisal vse tuje id-je razen nudge — dodan skupni `kHintNotificationIds` (nudge + moon), zdaj sta oba
  varna. Preverba izračuna prek `tmp/moon_hint_scratch_test.dart` (avg 2026, vrt list+koren). Testov ta
  korak namenoma ne dodaja — so korak 4. Suite ostaja **1265**.

- **T4b korak 3 ✅ (1. 8.) — 🔔 stikalo v `/moon-settings`:** `_HintTile` je **prva vrstica kartice
  podstikal** (wireframe board 2b: 🔔 »Namig »jutri dober dan«« + »nežno, spoštuje tihe ure«). Edino
  stikalo tega zaslona, ki **ne** živi v `MoonSettingsController`: bere `notificationSettingsProvider`,
  piše prek `profileRepository.setNotificationSettings` → profile JSON, **sinhronizirano** (B1). Ob
  vklopu `_ensurePermission` (top-level v istem filu): `areNotificationsEnabled` → priming sheet
  (zaslon 21) → `requestPermission`; **brez exact-alarm vrat**, ker namig vozi po **inexact** nudge
  kanalu (`scheduleNudge`) — zavrnitev pusti stikalo izklopljeno, ker vrednost zrcali shranjeno stanje.
  **Re-arma ni bilo treba dodajati:** `MoonHintCoordinator.build()` že posluša
  `tableUpdates(profiles)` → zapis ga sproži prek debouncea. Med nalaganjem in ob napaki je vrstica
  onemogočena (`onChanged: null`), ob napaki podnaslov = `moon.settings.load_error`. Nova ključa
  `moon.settings.hint`/`hint_sub` en+sl+de. Pogled: `tmp/moon_settings_{light,dark}.png` +
  `tmp/moon_de_settings.png` (de pri 320 px ovije naslov na 3 vrstice, brez odreza).
  **⚠️ Najdba za korak 4:** zaslon zdaj drži drift **stream**, zato test, ki sam lastuje
  `ProviderScope` in v teardownu zapre bazo, **obvisi** (`db.close()` čaka na naročnino, nato timeout;
  ob odjavi drift zaplanira še cleanup timer) — uporabi obstoječi vzorec
  `UncontrolledProviderScope` + `container.dispose()` **pred** `db.close()`, kot ga ima
  `moon_settings_screen_test.dart`. Za predoglede v `tmp/` je dovolj
  `notificationSettingsProvider.overrideWith((ref) => Stream.value(const NotificationSettings()))`.

- **T4b korak 4 ✅ (1. 8.) — T4b s tem ZAKLJUČEN:** korak se je začel z ugotovitvijo, da **odločitve ni
  bilo mogoče izvesti v testu**: `_reschedule()` je v eni metodi držal vrata (flag), odločitev (kateri
  dnevi, tihe ure, kapica, rob polnoči, sloti) in izvedbo (branje profila, klic Androida), zato je
  najbolj zunanja plast zaklenila najbolj notranjo. Popravek zasnove (odobril lastnik): odločitev je
  zdaj **čista funkcija `planMoonHints()`** v `moon_hint_schedule.dart`, ki »zdaj« dobi kot argument
  (**`Clock` tam ni potreben — čas je podatek**), koordinator pa je dobil
  **`armHints(nowLocal)`** (`@visibleForTesting`, brez flaga in brez ambientne ure).
  `kMoonCalendarEnabled` živi **samo na vhodu** `_reschedule()`; netestirana ostane natanko ta vrstica,
  ki jo T7 obrne. **+20 testov (suite 1285):** `moon_hint_schedule_test.dart` (12) ·
  `moon_hint_coordinator_test.dart` (7: temen flag ne doseže OS vrste, opt-in počisti rezervirane
  id-je in oboroži po vrsti, opt-out/izklopljen koledar/prazen vrt utihnejo, novoluna zamenja telo,
  besedilo se re-izpelje po preklopu sistema) · 🔔 vrstica v `moon_settings_screen_test.dart`.
  Fake obvestilne službe izločen v `test/support/fake_notification_service.dart` (2 klicalca).
  **Najdba:** pravilo »lunin namig se umakne dnevniškemu nudgeu« je s trenutnimi konstantami
  **nedosegljivo** (predvečer dneva +7 je +6, nudge pride na +7/+28 → trka ni); testirano je na ravni
  `planMoonHints(takenDays:)` in oživi šele, če horizont zraste čez 7 dni.

- **T5 korak 2 ✅ (2. 8., branch `feat/fr19-t5-2-finder-screen`) — iskalnik »Kdaj za …«:**
  `MoonFinderScreen` (`moon/presentation/moon_finder_screen.dart`, wireframe board 4) — polje
  rastline (odpre obstoječi `/plant-picker`, `PlantPick`) → `plantElement()` → kartica z elementom
  (soft ozadje, tekst `onSurface` po A4) → **svežnji primernih dni** (»čet 13. 8. – sob 15. 8.«,
  podnaslov rastoča/upadajoča luna); tap vrstice odpre **dan-sheet**, »+« pelje v
  `/task-new?date=…`. Rastline brez priporočila (sobne, iglavci, živa meja, lasten vnos) dobijo
  mirno vrstico `no_recommendation`, prazen zaslon pa namig. Izračun je čist:
  `moonDayRuns()` + `moonFinderRunsProvider(element, from)` (`moon/application/moon_finder.dart`,
  memoizacija po (element, dan, sistem)); horizont `kMoonFinderHorizonDays = 60`, **scan sledi
  odprtemu svežnju čez horizont** (odrezan razpon bi lagal, da dobri dnevi prej minejo — ujel test).
  Ruta `/moon-finder?plant=` z `moonCalendarRedirect` (route_collision_test pokriva vse tri moon
  rute), vstop **🔎 v AppBar koledarja**. Skupno: `isWaxing()` (`biodynamic_day.dart`, kopija iz
  sheeta odstranjena), `weekdayShort()` (`moon_text.dart`, kopija iz tedenske agende odstranjena).
  i18n `moon.finder.*` **en+sl** (de pride s T5.4). Unit testi izračuna (11), suite **1296**.
  Pogled: `tmp/moon_finder_preview_test.dart` → `tmp/moon_finder_{light,dark,empty}.png`.
  ⚠️ **Past harnessa (ponovno):** predogled, ki gleda **živ drift stream** (katalog), mora
  container `dispose()` **pred** `db.close()` — sicer `pumpAndSettle` visi 10 minut.

- **T5 korak 3 ✅ (2. 8., branch `feat/fr19-t5-3-plant-chip`) — chip »Kdaj za …« na detajlu rastline:**
  `PlantMoonChip` (`moon/presentation/widgets/plant_moon_chip.dart`, wireframe board D) v `_Hero`
  zaslona `plant_detail_screen.dart`. Trislojni vzorec T4.2/T4.3: **StatelessWidget flag gate brez
  ref** (+ lasten vnos brez `plantId` odpade takoj) → `_PlantMoonChipGate` (opt-in stikalo **in**
  `plantElement() == null` → nič: sobne, iglavci, živa meja bi v iskalniku dobili le »ni priporočila«)
  → javna `PlantMoonChipButton(plantId)` za teste/matriko/predoglede. `ActionChip` z
  `Icons.nightlight_outlined` (isti glif kot 🌙 vstop v Dnevniku) + `t.moon.finder.title` —
  **brez novih i18n ključev**; tap → `pushNamed('moon-finder', queryParameters: {'plant': id})`.
  **Postavitev A (izbira lastnika 2. 8.):** čip stoji ob čipu območja v stolpcu imena (`Wrap`,
  spacing 8) — pri 360 px se čipa zložita eden pod drugega; varianta B (vrsta čipov pod avatarjem,
  kot risan wireframe) je bila zavrnjena, ker bi premaknila obstoječi čip območja. Pogled:
  `tmp/plant_moon_chip_preview_test.dart` → `tmp/plant_moon_chip_{360,320}.png` (⚠️ prazni kvadrati
  namesto ikon = manjkajoč MaterialIcons font v golden okolju). Screen-map §4 »Stanje rut«
  posodobljen. Testi in matrika pridejo s T5.4; suite ostaja **1296**.

- **T5 korak 4 ✅ (2. 8., branch `feat/fr19-t5-4-tests`) — T5 s tem ZAKLJUČEN:** **de `moon.finder.*`**
  (»Wann für …« · `${plant} — am besten an einem ${day}.` nad `day_for` (Fruchttag/Wurzeltag/…) ·
  »Nächste passende Tage« · zu-/abnehmender Mond, isto besedišče kot `phase` mapa). Pogled najprej:
  `tmp/moon_t5_de_preview_test.dart` → `tmp/moon_t5_de_{finder,finder_320,chip}.png` — pri 320 px × 1,3
  se callout ovije na dve vrstici, čipa se zložita, nič odrezanega. **8 widget testov:**
  `moon_finder_screen_test.dart` (6: predizpolnjena rastlina pokaže element + svežnje · sobna rastlina
  dobi mirno vrstico brez seznama · prazen zaslon namigne · tap svežnja odpre sheet **prvega** dne ·
  »+« odpre `/task-new?date=` s tem dnem · izbor prek plant-pickerja premakne odgovor) in
  `plant_moon_chip_test.dart` (2: temna vrata brez `ProviderScope` · tap → `/moon-finder?plant=id`).
  Katalog v testih pride kot vrednost (`plantsMapProvider.overrideWith`), ne kot živ drift stream.
  **Matriki:** `moon/finder` (predizpolnjen paradižnik = najbolj besedno stanje) in `plant/moon-chip`
  (čip v hero vrstici ob čipu območja, ne sam — sam ne bi bil nikoli stisnjen) = 36 kombinacij.
  Suite **1340**.

- **Pregled kode + testov T1–T5 ✅ (2. 8., branch `fix/fr19-review`) — vse najdeno popravljeno:**
  **(1) prava napaka:** `moonHintCandidates` je dneve štel s 24-urnimi bloki → ob jesenskem premiku ure
  (25. 10. 2026) dve **enaki** obvestili za isti dan in izgubljen zadnji dan horizonta (privzeto je
  kapica izklopljena, zato je podvojitev prišla do naprave). Nov `addDays()` v `core/date_format.dart`;
  isti vzorec popravljen še v dnevniškem nudgeu, `reminder_schedule`, `postponeOneDay` (»+1 dan«),
  oznakah »jutri/včeraj« in skupinah opravil. Pravilo dodano v `CLAUDE.md`.
  **(2)** vsa vrata čipa rastline → čista `plantMoonChipTarget()` (edino pravilo, ki ga temni flag ni
  pustil testirati) · **(3)** sheet ob polnočnem prehodu pove »**od HH:MM**« in se ne prepira več s
  herojem (nova ključa `in_constellation_since`/`in_sign_since`, en+sl+de; pogled
  `tmp/moon_sliver_{sl,de}.png`) · **(4)** `moonDayLabel()` — čip/oznaka/task-sekcija kličejo motor
  enkrat namesto 2–3× (izmerjeno 515 → 171 µs na build čipa) · **(5)** mrtev `ElementBadge` izbrisan
  (datoteka → `element_glyph.dart`) · **(6)** `isWaxing()` izčrpen, brez dvojnika v `MoonPhaseIcon` ·
  **(7)** `HomeMoonChip` preverja flag pred `ref` kot ostale tri točke · **(8)** a11y: celica meseca je
  en semantični gumb, mena in ★ imata ime · **(9)** `SingleFlight` (`core/single_flight.dart`) — 3.
  pojavitev vzorca `_running/_dirty/debounce`, zdaj ga uporabljajo vsi trije koordinatorji.
  **Testi:** +74 (suite **1411**), pokritost FR-19 **92,6 % → 94,7 %**: DST regresiji, `addDays`,
  `SingleFlight`, vrata čipa, enakost `MoonSettings` po poljih, veje sheeta (novoluna · ⚠/✓ · »od«/»ob«),
  tedenska ‹ ›, 🔎 vstop, resume poti, **parnost i18n ključev en/sl/de** (slang tiho pade na en —
  `moon.finder.*` je bil tako cel korak brez nemščine), matriki `moon/day-sheet (transition|new moon)`.
  Neposkrita ostajajo natanko vrata za temnim flagom (52–78 %) — oživijo pri T7.
  **Mimogrede (naročilo lastnika):** vsi glifi/ikone/barve/animacije v kataloge —
  `core/glyphs.dart`, `core/app_icons.dart`, `app/theme/app_motion.dart`, `AppColors`.

- **T6 korak 1 ✅ (2. 8., branch `feat/fr20-t6-1-schema`) — shema FR-20, staging; prod push čaka
  potrditev:** `supabase/migrations/0017_profile_plus.sql` — `profile` dobi `plus_until timestamptz`,
  `plus_token text`, `plus_kind text` (vsi nullable, additive). Drift zrcalo `schemaVersion 13 → 14`,
  test `migration_v8_to_v9_test.dart` razširjen; suite **1412**. Dve najdbi:
  **(a) vrstica iz speca je bila no-op** — `revoke update (plus_until, plus_token) … from authenticated`
  ne naredi nič, ker se pravice v Postgresu samo seštevajo, `0002` pa je podelil `update` na **celi
  tabeli**; column-level revoke ne more odgrizniti stolpca iz tabelnega granta. Delujoča oblika:
  **revoke tabelno → re-grant po stolpcih** (seznam devetih klient-pisljivih stolpcev je v migraciji
  eksplicitno naštet). **(b)** zaklenjena sta `insert` **in** `update` (upsert nad neobstoječo vrstico je
  INSERT; `delete`+`insert` bi zaobšel samo-UPDATE zaklep), server-lastni pa so **štirje** stolpci:
  `plus_until`, `plus_token`, `plus_kind`, `server_inserted_at` (odločitev lastnika 2. 8.).
  ⚠️ **Nova obveznost:** vsaka prihodnja migracija, ki doda klient-pisljiv stolpec v `profile`, mu mora
  dodati column grant, sicer push pade s `42501`.
  **⚠️ M11 je izven projekta in ga NE upoštevaj** (lastnik, 2. 8.): read-only sonda produkcije
  (`tmp/probe_prod_state.py`) je potrdila ledger `0001`–`0005` + `0011`–`0016`, shemo **identično
  `main`**, nobene M11 tabele ali stolpca. Zato je naslednja prosta številka `0017` (ne `0023`, kot
  sem sprva sklepal iz runbooka). **Dokumenti so v istem commitu popravljeni** — `deploy-runbook.md`
  (+ novo pravilo na vrhu: bazo preberi, ne beri o njej), `m11.md`, `cookbook.md`, `stanje.md`,
  `CLAUDE.md`. Od M11 na produkciji ostaneta le no-op `engine_dispatch()` in dva cron joba
  (`engine_dispatch`, `agg_refresh_all`), ki **od 1. 7. 2026 ne tečeta** — dokazano prek
  `cron.job_run_details` pri `cron.log_run = on` (`tmp/probe_prod_cron.py`).
  Preverjeno na stagingu s sondo `tmp/probe_plus_grants.sql` (transakcija z rollbackom, staging ostal
  prazen): legitimen push (lang) ✅ · samo-podaritev prek update ✗ `42501` · prek upsert ✗ `42501` ·
  prek delete+insert ✗ `42501` · `plus_kind` ✗ `42501` · pull bere ✅. `polar_customer_id` (spec §7)
  **namenoma ni dodan** — ponudnik (§11.3) ni odločen; pred podporo licenčnega modela je treba
  predvideti, kateri ponudniki in da koda vzdrži **vse tri hkrati** (naročilo lastnika 2. 8.).

- **T6 korak 1b ✅ (2. 8.) — shema preverjena na napravi (staging), prod push odložen:** brez branch-a in
  brez commita kode. Tveganje, ki ga je korak lovil: `0017` je `authenticated` odvzela **tabelni**
  `insert`/`update` na `profile` in ga vrnila **po stolpcih**, zato bi manjkajoč stolpec pomenil `42501`
  in **ustavljen sync** (`push()` je fail-fast, profil gre prvi). **Vse zeleno na SM A536B.** Nadgradnja
  čez namestitev z 1. 8. je izvedla drift **v13 → v14** (katalog 141 nedotaknjen, `ENV: staging`
  potrjen ob zagonu). Staging je bil po resetu 29. 7. **brez `auth.users`**, zato je bila prijava hkrati
  najostrejši test — prvi push je bil **INSERT nad neobstoječo vrstico**. Skozi so šle vse tri poti:
  lokacija (`h3_r7/r6/r5`, brez koordinat), jezik (`lang = en`), obvestila (`notification_settings` s
  `frequency_cap: true`); `plus_*` ostali `NULL`, `server_inserted_at` nepremaknjen. V `logcat`
  **nobenega `42501`/`PostgrestException`/`E/flutter`**, drift ves `synced`, `area` pushana (dokaz, da
  veriga za profilom ni tiho padla). **Stari build** iz `b9c69f0` (drift v13, ločen `git worktree`) proti
  stagingu z novimi stolpci deluje: po prijavi naravnost na Domov z lokacijo iz pull-a — `sync_pull_service`
  uporablja `select()` (= `select *`), torej je neznane stolpce res dobil in jih spregledal. Nameščen je
  bil **na čisto**; nadgradnja nazaj čez podatke v14 bi drift pahnila v downgrade, realen scenarij pa je
  uporabnik, ki je ves čas na starem buildu.
  ⚠️ **Postopkovna past:** `deploy.bat hot` se prek `cmd.exe /c` v Git Bashu ne požene (`/c` se pretvori
  v pot), `flutter run` pa v neinteraktivni seji ob EOF ubije aplikacijo → uporabi
  `flutter build apk --debug --dart-define-from-file=dart_defines.staging.json` + `adb install -r`.
  ⚠️ **Gost nima oblačne seje** (`auth_service.dart`), zato profila ne pusha — za device test se je
  treba prijaviti z e-pošto, OTP se prebere iz Mailpita (`curl http://localhost:8025/api/v1/messages`
  v WSL).

- **T6 korak 2 ✅ (3. 8., branch `feat/fr20-t6-2-sync-exclusion`) — sync izjema:** push payload profila
  `plus_*` ne vsebuje, pull jih prinaša. Domneva iz plana je držala — `profileToRemote`
  (`lib/core/sync/remote_mappers.dart`) našteva ključe eksplicitno, torej server-lastnih stolpcev ni
  pošiljal niti prej; korak je to **zaklenil s testom** (vrstica s `plus_until = 2099` in
  `plus_token = 'forged'` da payload brez vsakega ključa `plus_*` in brez `server_inserted_at` — vsi
  štirje server-lastni stolpci `0017`) in dodal doc komentar »nikoli ne dodaj `plus_*` ključa«.
  `profileFromRemote` polni `plusUntil`/`plusToken`/`plusKind` prek novega `_dtOrNull`; **tolerantno** —
  produkcija je pri `0016` in vrstice teh stolpcev nimajo, zato manjkajoče polje da `null`, ne izjeme
  (drugi test). Nič sheme, nič migracije, nič vidnega. Suite **1414**.

- **T6 korak 3 ✅ (3. 8., branch `feat/fr20-t6-3-signature-dep`) — dependency za podpis:** odločitev
  lastnika po primerjavi treh kandidatov = **`dart_jsonwebtoken: ^3.4.1` z EdDSA/Ed25519**. Odločilna
  meritev: paket je **že v drevesu** kot odvisnost `supabase_flutter`/`gotrue` (`>=2.17.0 <4.0.0`), zato
  je cel `pubspec.lock` diff **ena vrstica** — `transitive` → `direct main`, ista verzija, ista `sha256`
  → **0 novih bajtov v APK**. Ostalo: 160/160 točk, izdaja pred ~3 meseci, MIT, čisti Dart (`clock`,
  `convert`, `pointycastle` — vsi že v drevesu), brez platformnih kanalov in brez I/O. Zavrnjena
  `cryptography` 2.9.0 (nov paket + ročna razčlenitev JWT ≈ 50 vrstic lastne kode na varnostno
  občutljivem mestu; ECDSA tam nima čiste Dart izvedbe) in `ed25519_edwards` 0.3.1 (zadnja izdaja pred
  ~4 leti, 13 všečkov). `tech-stack.md §1` dopolnjen z razlogom, zakaj je izven prvotnega seznama.
  **Nič kode** — uporaba pride s korakom 4; suite ostaja **1414**.
  ⚠️ **Dve najdbi za korak 4 (iz branja izvorne kode paketa):** `JWT.verify` vzame `alg` **iz glave
  žetona** (`jwt.dart:55`) — napačen tip ključa sicer vrže `TypeError` (`assert` v release izpade), a
  `plusProvider` mora **eksplicitno zavrniti vse razen `EdDSA`**, ne se zanašati na to. In
  `checkExpiresIn` privzeto bere čas prek internega paketa `clock` → postavi ga na `false` in
  `plus_until` presodi z **našim** `Clock` (sicer poteka ni mogoče testirati).

- **T6 korak 4 ✅ (3. 8., branch `feat/fr20-t6-4-plus-provider`) — `plusProvider`:** **dve odločitvi
  lastnika:** (a) **javni ključ je konstanta v repu** — `kPlusPublicKey` v `core/config.dart`, ker javni
  ključ ni skrivnost in ga tako ni mogoče pozabiti ob build-u; **danes je prazen** (para ključev še ni)
  → vsak profil bere kot ne-Plus = želeno temno stanje. (b) **Merodajen je podpisan žeton, ne stolpec
  `plus_until`** — stolpec je zrcalo za prikaz, predelana vrstica v driftu ne odklene ničesar.
  Struktura: `features/plus/data/plus_repository.dart` (`PlusRecord`, drift ostane v `data/`) ·
  `application/plus_token.dart` = **čista** `verifyPlusToken()` (»zdaj« je argument — vzorec
  `planMoonHints()`) · `application/plus_provider.dart` = `plusProvider`
  (`StreamProvider<PlusStatus>`, sledi `authStateChangesProvider`, re-izračun ob spremembi vrstice).
  Ura in ključ sta overridljiva providerja (`plusClockProvider`, `plusPublicKeyProvider`), zato je
  `kPlusPublicKey` **edina netestirana konstanta**. Vse nepričakovano (manjkajoč ključ, tuj `sub`,
  napačen `alg`, pokvarjen žeton, potek) je **miren `PlusStatus.none()`, nikoli izjema**. Obe najdbi iz
  koraka 3 sta upoštevani: `EdDSA` je pripet **pred** `JWT.verify` (test s `HS256` to zaklene),
  `checkExpiresIn: false` + naš `Clock`; `checkHeaderType: false` (`typ` ob pripetem algoritmu ne doda
  ničesar, izdajatelj brez njega pa bi Plus ugasnil brez vidnega vzroka). **Pogodba žetona** za Edge
  Function: `{sub, plus_until (epoch sekunde), iat}`, `alg=EdDSA`. **18 novih testov, suite 1432.**
  ⏳ Za T7 ostane generiranje para ključev (javni v `kPlusPublicKey`, privatni v Supabase secrets).

- **Predčasni del koraka 8 ✅ (3. 8., naprava SM A536B proti stagingu)** — izmerjeno vse, kar se da,
  preden obstaja zaslon; brez commita kode. V profilno vrstico (`01b9054f-…`, `exogenus@gmail.com`) so
  bili s service role vpisani `plus_until = 2026-09-02 10:19:20Z`, `plus_kind = 'granted'` in žeton,
  podpisan z **enkratnim testnim parom ključev** (`tmp/gen_plus_test_token.dart`, determinističen seed
  `(i*7+13) % 256`, javni ključ `nHq6JH1Lmot5tW6rGCV05fjNlUAomh+JWgaeAFtYs8o=`; produkcijski par pride s
  T7). Izidi: **pull** prinese vse tri stolpce v drift · **podpis** — `verifyPlusToken` nad točnimi
  bajti s telefona da `isActive: true` do 2. 9. 2026, isti žeton pod tujim uid `false`
  (`tmp/verify_device_token.dart`) · **push z napolnjenimi `plus_*`** — dvojna menjava jezika
  (`sl → en → sl`) je obakrat pristala na stagingu, `plus_*` in `server_inserted_at` pa sta ostala
  nedotaknjena, v `logcat` nič `42501`/`PostgrestException`/`E/flutter`. To je bila edina neizmerjena
  pot (korak 2 je bil do tedaj zaklenjen le s testom payloada). **Staging vrstica darilo obdrži**, zato
  bo zaslon koraka 5 imel kaj pokazati; na telefonu stoji debug/staging build iz `main` z **lokalno
  prižganim** luninim flagom (v repu `false`, preverjeno).

- **T6 korak 5 ✅ (3. 8., branch `feat/fr20-t6-5-plus-screen`) — zaslon `/tendask-plus`:**
  `TendaskPlusScreen` bere `plusProvider`, vsebino nosi **javna `PlusScreenBody(status:)`** (izris brez
  baze — vzorec T4.2). Aktivno = tinted kartica ✓ + »Aktiven do 12. 8. 2027«, pri
  `plus_kind == 'lifetime'` (`kPlusKindLifetime`) pa **»Aktiven — doživljenjsko«** (datum bi tam lagal,
  ker je žeton po §6.2 omejen na leto). Neaktivno = mirna vrstica »Ni aktiven« + pripis. **Seznam
  funkcij je EN, isti v obeh stanjih** (🌙 Lunin koledar z opisom · 🪴 Več vrtov in lokacij »Kmalu« ·
  📊 Analitika pridelka »Kmalu«); wireframe ima brez licence bogatejši seznam ugodnosti, a dve ločeni
  listi bi se lahko razšli — **bogatejši opis pride s T8**, ko zaslon dobi vnos kode. Vrstica koledarja
  je tapljiva **samo z licenco** → `/moon-settings`. V Nastavitvah gate `PlusSettingsCard` (flag) →
  javna `PlusEntryCard`, takoj pod profilom. Nov flag **`kTendaskPlusEnabled = false`**, ruta z lastnim
  `tendaskPlusRedirect`. i18n `plus.*` en+sl+de; nič nakupnega jezika (brez cene, URL-ja, namiga o kodi).
  ⚠️ **Odločitev lastnika ob prvem pogledu:** znak »✦« je **Material ikona** (`kIconAutoAwesome`), ne
  besedilni glif — U+2726 v Plus Jakarta Sans ne obstaja (padel je na nadomestne tri črtice) in se je
  zaradi `kPlusLabel = '✦ Tendask+'` risal **dvakrat**. Zdaj `kPlusLabel = 'Tendask+'`, znak **enkrat
  na površino**. Testi: 7 widget + 2 varovalo rute + matrika (`plus/screen (active|inactive)`,
  `settings/plus-card`) = 54 komb. Suite **1495**. Pogled: `tmp/plus_preview_test.dart` →
  `tmp/plus_{active,lifetime,inactive,dark,de_320,card}.png`.

- **T6 korak 6 ✅ (3. 8., branch `feat/fr20-t6-6-gate-swap`) — gate swap:** nov **`plusActiveProvider`**
  je edini bool zaklenjenih površin (loading/napaka = zaklenjeno). `moonSurfaceOn()` ostane **free**
  pravilo (mena), element-dan nosi novi **`moonPlusSurfaceOn(settings, isPlus)`**; `journalMoonLayerOn`
  in `plantMoonChipTarget` sta dobila `isPlus`. **Cele za zid:** when-step oznaka, task-detail sekcija,
  Dnevnik-plast + 🌙 gumb, čip rastline, `/moon-calendar` in `/moon-finder` (deep-link brez licence →
  `/tendask-plus`, ne `/home`). **Čip na Domov = deljena vrata:** mena + naslov vedno, CTA pa »dan za X ›«
  ali **pilula »✦ Tendask+ ›«**; tap kjerkoli po kartici → `/tendask-plus`.
  ⚠️ **Ton pilule = medena `colorScheme.secondary`** (izbira lastnika ob pogledu): wireframe je risal
  rdečo (`--lock`), a rdeča je v aplikaciji destruktivna barva. Predogledi:
  `tmp/plus_gate_preview_test.dart` → `tmp/gate_chip_{locked,unlocked,dark,de320,alt_terracotta}.png`,
  `tmp/gate_settings_{free,plus}.png`.
  ⚠️ **Dve odločitvi lastnika:** (a) ko darilo poteče, se **lunino obvestilo 🔔 utiša samo**
  (`MoonHintCoordinator` bere upravičenost; shranjen opt-in ostane, namig se vrne z novo licenco), brez
  sledi za uporabnika; (b) **vrstica »Lunin koledar« na `/tendask-plus` je tapljiva tudi brez licence**
  → `/moon-settings` ima **lastno varovalo `moonSettingsRedirect`** (samo flag, brez zidu) in brez Plusa
  pokaže **samo glavno stikalo + »Kaj je to?«**. Nov ključ `moon.settings.enable_sub_free` en+sl+de.
  ⚠️ **Najdba (Riverpod 3):** `StreamProvider` sledi streamu **samo dokler ga kdo posluša**;
  `ref.listen`/`ref.watch` iz providerja, ki ga sam nihče ne posluša (koordinator), stream **ne** oživi
  in `.future` v tem stanju nikoli ne dokonča. Zato `main.dart` drži **odprt** (nikoli zaprt!)
  `container.listen(plusProvider, …)` in počaka na prvo vrednost (brez utripa čipa); isti vzorec rabijo
  testi koordinatorja. **+25 testov, suite 1520**; analyze čist. Netestirana ostaja samo veja
  `containerOf(...).read(plusActiveProvider)` v `moonCalendarRedirect` (temen flag) — oživi pri T7.

- **T6 korak 7 ✅ (3. 8.) — anti-steering pregled i18n, brez najdb:** noben niz ni bilo treba popraviti.
  Pregledani `plus.*` (11 ključev) in cel `moon.*` (calendar · settings · finder · hint · badge · sheet ·
  task_section + enum mape) v **en+sl+de**, `kPlusLabel`/`PlusTitle`, pilula `_LockedCta` na čipu Domov,
  `PlusEntryCard` v Nastavitvah in obvestilo luninega namiga; povrhu vzorčni pregled čez vse tri
  `*.i18n.json` na cene, URL-je, nakupne CTA in namige o kodi (vsi zadetki lažni — `$n` v številih,
  `email_login.*` koda iz e-pošte). Trdo kodiranih uporabniških nizov v `features/plus`, `features/moon`
  in `home_moon_chip.dart` ni. `/tendask-plus` brez licence = `plus.tagline` + seznam funkcij z dvema
  »Kmalu«, kar §3.1 izrecno dovoli. Ob strani: `docs/go-live/store-listing.md` Plusa in Lune sploh ne
  omenja — listing je naloga T7.

- **T6 korak 6b ✅ (3. 8., branch `feat/fr20-t6-6b-always-on-phase`) — mena vedno vidna, nastavitve kot
  salon:** **glavno stikalo 🌙 je izbrisano** (`MoonSettings.enabled`, prefs `moon_calendar_enabled`,
  `setEnabled()`) — čip na Domov stoji za samim build flagom, deljeni CTA (»dan za X ›« / pilula
  »✦ Tendask+ ›«) ostane. `moonSurfaceOn`/`moonPlusSurfaceOn` sta zamenjana z
  **`moonElementLabelsOn(settings, isPlus)`** nad novim **petim podstikalom `showElementLabels`**
  (prefs `moon_show_element_labels`, privzeto vklopljeno, glif 🏷️ `kGlyphElementLabels`) — velja za
  when-korak, detajl opravila in čip rastline; Dnevnikova plast ostane na 📅, 🌙 gumb Dnevnika pa gleda
  **samo** `plusActiveProvider`. Namig 🔔 ne bere več `moon.enabled`.
  **`/moon-settings` brez licence = razstavni salon:** `shown = isPlus ? stored : kMoonSettingsDefaults`,
  vseh pet vrstic in segment vidnih, a `onChanged: null` in **privzete** vrednosti (tudi 🔔, ki je sicer
  shranjen `false` — salon slika, kaj licenca prinese); nič se ne zapiše in shranjene nastavitve obisk
  preživijo (zaklenjeno s testom). Pet vrstic gre skozi nov `_MoonSwitch`. Pod segmentom stoji opis
  **izbranega** sistema (`system_help_sidereal`/`_tropical` en+sl+de, z »(siderični/tropski zodiak)«);
  splošni `system_help` izbrisan.
  ⚠️ **Odločitvi ob pogledu:** (i) oznaka v when-koraku je zdaj **pilula v soft barvi elementa**
  (tekst `onSurface`, A4) — v medlem slogu se je brala kot druga vrstica opombe »Privzeto: danes ob
  naslednji polni uri«; (ii) čip rastline nosi nov ključ **`moon.finder.chip`** (»Primerni dnevi« ·
  »Suitable days« · »Passende Tage«); naslov iskalnika ostane »Kdaj za …«. Suite **1537**, analyze čist.
  Pogled: `tmp/step6b_preview_test.dart` → `tmp/t6b_*.png`. Nova matrika `moon-settings (free)`.
  ⏳ Wireframe board 2b še riše glavno stikalo — uskladitev ob priložnosti.

- **Popravki po prvem pogledu na napravi (4. 8., isti sveženj kot 6b):** **(1) `SafeArea`** na
  `/moon-settings`, `/moon-calendar`, `/moon-finder` in `/tendask-plus` — nobeden od štirih novih zaslonov
  ga ni imel, zato je zadnja kartica zlezla pod Androidove navigacijske gumbe (hišni vzorec je
  `body: SafeArea(child: …)`, gl. `settings_screen.dart`). **(2) 🔔 vrstica je zdaj optimistična** —
  edina od petih je čakala na pot »zapis v profil → stream nazaj« (plus platformni klic za dovoljenje),
  kar je na napravi pomenilo ~1 s zamika za prstom; zdaj se premakne takoj in se vrne, če dovoljenje
  odpade. **(3) `when_default_note` izbrisan** (sl/en/de) — napis »Privzeto: danes ob naslednji polni uri«
  je ob 23:xx lagal (privzetek `nextFullHour` se prelije v jutri, segment pokaže »Jutri«), datum in ura pa
  sta itak vidna v poljih nad njim. **(4) nov `SegmentLabel`** (`core/widgets/segment_label.dart`,
  `FittedBox.scaleDown` + `maxLines: 1`) na **vseh** segmentnih gumbih aplikacije (11 mest) — »Tedensko«
  je pri 320 px lomilo zadnji »o« v novo vrstico. Pogled: `tmp/segments_preview_test.dart` →
  `tmp/seg_{sl360,sl320,de320}.png`.
  **(5) Zaštekanje ob 🔔 odpravljeno pri viru:** `MoonHintCoordinator` je ob **vsakem** zapisu v profil —
  torej tudi ob menjavi jezika, uredbi lokacije in ob vsakem sync pullu — naredil 7 preklicev + do 7
  razporeditev, **do 14 klicev prek platformnega kanala**. Zdaj si zapomni, kaj je armiral (id · čas ·
  naslov · telo, primerjava po vrednosti) in ob nespremenjenem planu **ne pokliče OS niti enkrat**;
  preklic gre samo v reže, ki plana ne nosijo več (razporeditev z istim id-jem obstoječo zamenja); nov
  `kMoonHintDebounce = 2 s` (prej `kReminderDebounce` 800 ms) potisne delo z OS izven animacije stikala.
  Naslov in telo živita v zapomnjenem zapisu, zato menjava jezika ali sistema **še vedno** sproži
  ponovno armiranje. +2 testa (nespremenjen plan se OS ne dotakne · preklop sistema armira spremenjene
  reže).
  **(6) Prenova besedil (lastnik, 4. 8.)** — pripisi so brali kot strojni (telegrafski »X, ne Y.«,
  poševnica, razlaga mehanizma bralcu): novi `moon.task_section.footnote`, `moon.settings.about_body` +
  `about_footnote` (kartica zdaj brez podvojenega naštevanja), vse štiri `moon.activity` vrstice,
  `activity_new_moon`, `finder.no_recommendation`, `settings.show_astro_sub` in oba opisa sistema —
  **sl+en+de**. Nedotaknjeni po odločitvi lastnika: `plus.tagline`, `sheet.favorable/unfavorable`,
  `finder.empty_hint`.

- **T6 korak 8 ✅ (4. 8., SM A536B proti stagingu) — T6 s tem ZAKLJUČEN; brez brancha kode, ker se hrošč
  ni pokazal.** Nameščen APK z lokalno prižganimi flagi iz drevesa `de1dac9`. **Odklenjeno:** čip Domov ·
  koledar mesec/teden · dan-sheet (razširjen, nič pod navigacijskimi gumbi) · nastavitve z licenco ·
  korak »Kdaj« (pilula v soft barvi elementa) · detajl opravila · Dnevnik (🌙 gumb + plast) · čip rastline
  »☾ Primerni dnevi« → iskalnik · `/tendask-plus` »Aktiven do 2. 9. 2026« · pot Nastavitve → ✦ Tendask+ →
  »Lunin koledar«. **🏷️ off** pobriše oznako v koraku »Kdaj«, celo sekcijo na opravilu in čip rastline,
  **Domova pa ne** (B3). **Potek licence:** ker je merodajen podpisan žeton, je bil izdan nov žeton s
  `plus_until` v preteklosti (`tmp/gen_plus_test_token.dart … -1`) — samo skrajšanje stolpca ne bi
  dokazalo nič. Po zagonu (pull ob startu; `kSyncInterval` je 15 min, resume sam ne potegne) je vse
  zaklenjeno, čip obdrži meno + medeno pilulo, **lunino obvestilo je utihnilo samo** (alarm 5. 8. 18:00
  izginil iz `dumpsys alarm`, nudge 11. 8./1. 9. in opomnik 14. 8. ostali), **opt-in `moon_hint = true`
  preživel** in se je z vrnjenim žetonom alarm vrnil. **🔔 vrstica** se ob tapu premakne takoj. **Letalski
  način** (z izklopljenim wifi — sam letalski način ga na Samsungu pusti prižganega) + hladen zagon: Plus,
  koledar in vse površine delujejo, vreme mirno pade na zadnji posnetek. `logcat` skozi celo sejo čist.
  Staging vrnjen v izhodiščno stanje; `server_inserted_at` ves čas nepremaknjen (3. 8.).
  ⚠️ **Ena najdba (kozmetična, NE popravljena):** brez licence **segment sistema ne kaže izbire** —
  onemogočen M3 `SegmentedButton` izpusti polnilo izbrane polovice, zato sta »Po ozvezdjih« in
  »Po znamenjih« videti enaka. Pet stikal privzeto vrednost pokaže pravilno (sivo, a v položaju
  »vklopljeno«). Opis pod segmentom še vedno govori o sideričnem zodiaku, torej podatek ni izgubljen.
  **Dolg počiščen:** wireframe `lunar-calendar_overview.html` board 2b usklajen z zaslonom — glavno 🌙
  stikalo odstranjeno, board je zdaj **par** (z licenco / razstavni salon), pet podstikal z 🏷️, opis
  izbranega sistema, novo besedilo »Kaj je to?«, opomba z razlogom B3.

**Naloga NASLEDNJE seje: T7 — prižig z darilom.** Vhod je zdaj izpolnjen: T6 stoji in je izmerjen na
napravi. **Prvo vprašanje za lastnika:** ali gre `supabase db push` na produkcijo (prod je pri `0016`,
migracija `0017` čaka) — po `deploy-runbook.md`, staging najprej, po pushu `tmp/probe_prod_state.py` +
preverba, da ima `authenticated` na `plus_*` in `server_inserted_at` samo `SELECT`. Šele nato koraki T7:
par ključev (javni v `kPlusPublicKey`, privatni v Supabase secrets) · masovni grant · prižig obeh flagov ·
pregled vseh zaslonov na napravi (dolg spodaj: temni odtenki A4 + emoji na pravem fontu) · store listing.
**Stanje repozitorija ob predaji (4. 8.):** `main` = `de1dac9` + necommitana sprememba wireframa in
dokumentov iz tega koraka; nobene odprte veje. APK s prižganimi flagi in nameščen na telefonu je iz
`de1dac9`; v repu so `kMoonCalendarEnabled = false`, `kTendaskPlusEnabled = false`, `kPlusPublicKey` prazen.

🚫 **Produkcije se do konca celote ne dotikamo** (odločitev lastnika 3. 8.): **`supabase db push` na prod
se NE izvede po posameznem koraku T6, ampak šele ko rezina stoji.** Prod ostane pri `0016`; migracije se
do takrat kopičijo v repu in na stagingu. Ko push končno pride: po njem `tmp/probe_prod_state.py` in
preverba, da ima `authenticated` na `plus_*` in `server_inserted_at` samo `SELECT`. Produkcija izmerjena
2. 8.: ledger `0001`–`0005` + `0011`–`0016`, `profile` 10 stolpcev, brez sledi M11.

⏳ **Odprto:** staging ledger nosi **osiroteli vnos `0023`** (prva, preštevilčena različica iste
migracije; datoteke ni več — ob svežem refreshu staginga izgine sam) · **na telefonu stoji debug/staging
build z lokalno prižganimi `kMoonCalendarEnabled` + `kTendaskPlusEnabled` in testnim `kPlusPublicKey`**
(v repu so vsi trije privzeti — `false`/prazen, nikoli commitani) · worktree starega builda je v
`tmp/old-apk` (`git worktree remove tmp/old-apk`).

📱 **Postopek za ogled na napravi** (deloval 3. 8., SM A536B): lokalno postavi
`kMoonCalendarEnabled = true`, `kTendaskPlusEnabled = true` in
`kPlusPublicKey = 'nHq6JH1Lmot5tW6rGCV05fjNlUAomh+JWgaeAFtYs8o='` (testni par, `tmp/gen_plus_test_token.dart`)
→ `flutter build apk --debug --dart-define-from-file=dart_defines.staging.json` → `adb install -r
build/app/outputs/flutter-apk/app-debug.apk` → **vse tri vrednosti takoj nazaj** (s prižganim luninim
flagom `flutter test` pade). Prijava z e-pošto (gost nima oblačne seje), OTP iz Mailpita. Scenarij se
vozi z `tmp/steps.txt` + `& ./tool/adb_run.ps1`; ⚙️ Nastavitve so na Domov pri `tap 1010 165`.
⚠️ Screencap **preusmerjaj v Bash orodju** (`adb exec-out screencap -p > tmp/x.png`) — prek PowerShella
se PNG pokvari.

✅ **T6 korak 5 preverjen na napravi (3. 8.):** kartica v Nastavitvah, `/tendask-plus` z resničnim
podpisanim žetonom (»Aktiven do 2. 9. 2026«, brez omrežja) in **cel scenarij slepe ulice**: 🌙 stikalo
off → čip na Domov izgine → Nastavitve → ✦ Tendask+ → »Lunin koledar« → nastavitve → vklop → čip nazaj.
V `logcat` nič. ⚠️ **Ta scenarij je s korakom 6b odpadel** (glavnega stikala ni več, čip je vedno vidiven);
pot Nastavitve → ✦ Tendask+ → »Lunin koledar« → `/moon-settings` pa mora ostati.

🔁 **Najdba lastnika 2. 8. — ZAPRTO (koraki 5, 6 in 6b):** izklop glavnega 🌙 stikala je bil **enosmeren**
(edini vstop v `/moon-settings` je bil ⚙️ v koledarju, do koledarja pa so vodile samo površine za istim
stikalom). Korak 5 je odprl drugi vstop (`/tendask-plus` → »Lunin koledar«), korak 6 ga je naredil tapljivega
tudi brez licence, **korak 6b pa je vzrok odstranil**: glavnega stikala ni več, čipa mene ni mogoče ugasniti.
**Ne dodajaj lunine vrstice v glavne Nastavitve** — vstop je `/tendask-plus` → »Lunin koledar« (screen-map §4).

✅ **Vrstni red znotraj T6 je izpolnjen:** sync izjema (korak 2) je v `main` **pred** `plusProvider`
(korak 4), zato nobena vmesna izdaja ne more pushati server-lastnih stolpcev.

📱 **Dolg, ki ga T7 ne sme preskočiti:** cel FR-19 je bil potrjen prek golden harnessa, **na napravi
(SM A536B) pa še ni bil pregledan**. Temni odtenki (A4) in emoji na pravem fontu sta edini stvari, ki ju
golden okolje ne pove pošteno — preverba spada v T7 korak 3. **Podlaga je pripravljena:** 2. 8. je bil na
telefon nameščen debug/staging build z lokalno prižganim flagom, a je USB padel pred ogledom, zato zasloni
niso bili videni. Za ponovitev: `kMoonCalendarEnabled = true` (samo lokalno!) →
`flutter build apk --debug --dart-define-from-file=dart_defines.staging.json` → `adb install -r` → **flag
takoj nazaj na `false`** (s prižganim flagom `flutter test` pade — testi namenoma zaklepajo temna vrata).

**Pred delom preberi:** ustrezni task v `docs/plan-implementacije-fr19-fr20.md` · wireframe zaslona ·
`docs/screen-map.md`.

**Pravila:** naredi natanko ta korak in nič več. Pred merge: `flutter analyze` čist + cel
`flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu označi korak, posodobi ta dokument na
naslednji task in predlagaj commit.

**Stanje odločitev:** A1=C ✅ · A2=C ✅ (v v1) · A3=A ✅ · A4=A ✅ (fiksne semantične + kontrastna
omejitev) · **A5 razrešen: A — emoji** (fallback po pogoju, 31. 7.) · A6=A ✅ (privzeto vklopljeno) ·
**B1 ✅ ODLOČEN (1. 8.): dostava device-local, opt-in 🔔 sinhroniziran (profile JSON), kapica samo za
namige.** Odprtih odločitev FR-19 ni več.
