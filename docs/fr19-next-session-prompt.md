# FR-19 — prompt za naslednjo sejo (živ dokument)

> Ob koncu vsakega koraka sejo zaključi tako, da posodobiš ta dokument na NASLEDNJI korak
> (+ status v `plan-implementacije-fr19-fr20.md`). Uporabnik blok spodaj prilepi v novo sejo.

---

Gradiva FR-19 Lunin koledar po planu `docs/plan-implementacije-fr19-fr20.md` — **korak po koraku,
vsak korak v svoji seji**: en korak = en branch = en commit, vse temno (za flagom), merge v `main`.

**Kaj je narejeno (vse v main, CI zelen, 1039 testov):**
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
- **Code review T1+T2 (2 rundi, 31. 7.) ✅ popravljeno:** rep sizigije v `findPhaseTime`
  (mrk ob polnoči) · keepAlive + robustna setterja + varen warm-up · testi: popolnost i18n map
  proti enumom, guard na pravem routerju, MoonColors lerp/copyWith, novoletna kontinuiteta.
  **A4 omejitev (izmerjeni kontrasti, decisions doc):** tekst na soft ozadju = `onSurface`
  (svetli cvet 1,8:1 pade!), poudarek samo za ikono/glif; temne odtenke fino nastavi ob prvem
  pogledu. Predogled barv: `tmp/moon_colors_preview.html`.

**Naloga TE seje: korak T3.1 — mena kot `CustomPainter`** (branch `feat/fr19-t3-1-phase-painter`):

- Samostojen widget (krivulja terminatorja iz `illumFraction`, spec §11.7) — rabijo ga koledar,
  čip na Domov in dan-sheet. `lib/features/moon/presentation/widgets/`.
- **Najprej videz:** widget + pogled vseh 8 men (naprava ali harness) — šele po potrditvi videza
  testi/dokumentacija (pravilo »poglej, preden vlagaš«).
- Nič vidnega v aplikaciji brez flaga; barve prek teme, ne hardcode.

**Pred delom preberi:** plan T3 (`docs/plan-implementacije-fr19-fr20.md`) · spec §11.7 ·
wireframe `lunar-calendar_overview.html` (krajci) · `MoonPhase`/`illumFraction`
(`core/biodynamic/biodynamic_day.dart`).

**Pravila:** naredi natanko ta korak in nič več (ne začenjaj T3.2). Pred merge: `flutter analyze`
čist + cel `flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu označi T3.1, posodobi ta
dokument na naslednji korak (T3.2 `ElementBadge` — ⚠️ **blokira A5**,
`feat/fr19-t3-2-element-icons`) in predlagaj commit.

**Stanje odločitev:** A1=C ✅ · A3=A ✅ · A4=A ✅ (fiksne semantične barve + kontrastna omejitev) ·
A6=A ✅ (privzeto vklopljeno) · **A5 (ikone) še ODPRTA — blokira T3.2 in emoji v mreži T3.3**;
T3.1 ne blokira nobena. Če lastnik med sejo odloči A5, jo zabeleži v decisions doc + plan tabelo.
