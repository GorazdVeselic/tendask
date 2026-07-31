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
- **T3.1 mena kot `CustomPainter` ✅ (31. 7.):** `MoonPhaseIcon(phase, illumFraction, size, color?)`
  (`lib/features/moon/presentation/widgets/moon_phase_icon.dart`) — obris diska + osvetljeni del
  z elipso terminatorja (polos `r·|2f−1|`), rastoča osvetljena desno, pojemajoča zrcalna; barva
  privzeto `onSurfaceVariant` (v svetli temi »ink« konvencija: osvetljeno = polnilo). Videz
  potrjen prek harnessa `tmp/moon_phase_preview_test.dart` (`flutter test --update-goldens` →
  `tmp/moon_phase_preview.png`); testi s pixel-samplingom v
  `test/features/moon/moon_phase_icon_test.dart`. Widget še nima klicalca (temno).

- **Uskladitev wireframe ↔ plan (31. 7. popoldne, lastnik) ✅:** A2=C **v v1** (Dnevnik: 🌙 AppBar
  vstop + barvna plast → novi korak T4.4) · A5=B (lastne vektorske, **pogojno na vizualno potrditev
  osnutkov**; fallback emoji) · ★ + »poudari po mojem vrtu« v v1 (T5.1 mapping se izvede PRED T3.3) ·
  dan podrobno = sheet z drsenjem (+ seznam »Priporočeno za …« s »＋ opravilo«) · lunino obvestilo
  »jutri dober dan« v v1 kot nov task **T4b** (tihe ure + kapica zaživita tam; 🔔 vrstica v
  nastavitvah šele takrat) · T3.6 dobi podstikala (poudari/Dnevnik/ozvezdja) + ⚙️ vstop iz koledarja ·
  navigacija: `/moon-calendar` = dom. Plan, screen-map in decisions doc so usklajeni (isti dan).

**Naloga TE seje: korak T3.2 — `ElementBadge`** (branch `feat/fr19-t3-2-element-icons`):

- **Začni z osnutki 4 monokromatskih vektorskih ikon** (plod/korenina/cvet/list) — A5=B velja
  pogojno: lastnik potrdi videz osnutkov, sicer fallback emoji (API `ElementBadge` skrije vir).
- En skupen widget `ElementBadge` (ikona + oznaka, **nikoli samo barva** — dostopnost),
  `lib/features/moon/presentation/widgets/`. Barve prek `MoonColors` teme (A4 omejitev: tekst na
  soft ozadju = `onSurface`, poudarek samo ikona/glif).
- **Najprej videz:** ikone + widget + pogled vseh 4 elementov (naprava ali harness kot pri T3.1 —
  `flutter test --update-goldens tmp/...`) — šele po potrditvi videza testi/dokumentacija.
- Nič vidnega v aplikaciji brez flaga; barve prek teme, ne hardcode.

**Pred delom preberi:** plan T3 (`docs/plan-implementacije-fr19-fr20.md`) · A4/A5 v decisions doc ·
wireframe `lunar-calendar_overview.html` (legenda elementov) · `MoonColors`
(`lib/app/theme/moon_colors.dart`) · `BiodynamicElement` (`core/biodynamic/biodynamic_day.dart`).

**Pravila:** naredi natanko ta korak in nič več (ne začenjaj T3.3). Pred merge: `flutter analyze`
čist + cel `flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu označi T3.2, posodobi ta
dokument na naslednji korak (T5.1 mapping kategorija→element — PRED T3.3 mrežo, odločitev 31. 7.;
branch `feat/fr19-t5-1-category-map`) in predlagaj commit.

**Stanje odločitev:** A1=C ✅ · A2=C ✅ (v v1) · A3=A ✅ · A4=A ✅ (fiksne semantične + kontrastna
omejitev) · A5=B ✅ (pogojno na vizualno potrditev osnutkov) · A6=A ✅ (privzeto vklopljeno) ·
**B1 (device-local vs sync za lunina obvestila) še ODPRTA — odloči se na začetku T4b.**
