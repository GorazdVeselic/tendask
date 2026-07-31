# FR-19 — prompt za naslednjo sejo (živ dokument)

> Ob koncu vsakega koraka sejo zaključi tako, da posodobiš ta dokument na NASLEDNJI korak
> (+ status v `plan-implementacije-fr19-fr20.md`). Uporabnik blok spodaj prilepi v novo sejo.

---

Gradiva FR-19 Lunin koledar po planu `docs/plan-implementacije-fr19-fr20.md` — **korak po koraku,
vsak korak v svoji seji**: en korak = en branch = en commit, vse temno (za flagom), merge v `main`.

**Kaj je narejeno (vse v main, 1050 testov):**
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
- **Uskladitev wireframe ↔ plan (31. 7., lastnik) ✅:** A2=C **v v1** (Dnevnik: 🌙 AppBar vstop +
  barvna plast → T4.4) · ★ + »poudari po mojem vrtu« v v1 (**T5.1 mapping se izvede PRED T3.3**) ·
  dan podrobno = sheet z drsenjem (+ »Priporočeno za …« s »＋ opravilo«) · lunino obvestilo
  »jutri dober dan« v v1 kot **T4b** (tihe ure + kapica tam; 🔔 vrstica v nastavitvah šele takrat) ·
  T3.6 podstikala (poudari/Dnevnik/ozvezdja) + ⚙️ vstop iz koledarja · `/moon-calendar` = dom.

**Naloga TE seje: korak T5.1 — mapping kategorija→element** (branch `feat/fr19-t5-1-category-map`),
po odločitvi 31. 7. IZVEDEN PRED T3.3 (vhod za ★ v mreži):

- Konstanta mapping **`coarsePlantCategory` (7 veder — obstaja) → `BiodynamicElement`** + test.
  Plan T5 pravi: »nova majhna tabela v motorju ali ob njem« — umestitev ob motor
  (`core/biodynamic/`), brez UI predpostavk (porabniki: T3.3 ★, T5.2 iskalnik, T4 oznake).
- Preveri obstoječih 7 veder (`coarsePlantCategory`) in za vsako določi element po agronomski
  logiki setvenih koledarjev (plodovke→plod, korenovke→korenina, cvetnice→cvet, listnata→list …);
  robna vedra (npr. začimbnice, okrasne, »drugo«) predlagaj lastniku v potrditev, ne ugibaj tiho.
- Čista logika brez Riverpoda; unit test popolnosti (vsako vedro ima element ali eksplicitno
  nima priporočila).

**Pred delom preberi:** plan T5 + T3.3 (`docs/plan-implementacije-fr19-fr20.md`) ·
`coarsePlantCategory` v kodi (poišči po repu) · `BiodynamicElement`
(`core/biodynamic/biodynamic_day.dart`) · spec §6.3.8 (personalizacija po vrtu), če obstaja.

**Pravila:** naredi natanko ta korak in nič več (ne začenjaj T3.3). Pred merge: `flutter analyze`
čist + cel `flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu označi T5.1, posodobi ta
dokument na naslednji korak (T3.3 mreža meseca; branch `feat/fr19-t3-3-month-view`) in predlagaj
commit.

**Stanje odločitev:** A1=C ✅ · A2=C ✅ (v v1) · A3=A ✅ · A4=A ✅ (fiksne semantične + kontrastna
omejitev) · **A5 razrešen: A — emoji** (fallback po pogoju, 31. 7.) · A6=A ✅ (privzeto vklopljeno) ·
**B1 (device-local vs sync za lunina obvestila) še ODPRTA — odloči se na začetku T4b.**
