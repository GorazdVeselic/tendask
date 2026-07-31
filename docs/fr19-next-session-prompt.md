# FR-19 — prompt za naslednjo sejo (živ dokument)

> Ob koncu vsakega koraka sejo zaključi tako, da posodobiš ta dokument na NASLEDNJI korak
> (+ status v `plan-implementacije-fr19-fr20.md`). Uporabnik blok spodaj prilepi v novo sejo.

---

Gradiva FR-19 Lunin koledar po planu `docs/plan-implementacije-fr19-fr20.md` — **korak po koraku,
vsak korak v svoji seji**: en korak = en branch = en commit, vse temno (za flagom), merge v `main`.

**Kaj je narejeno (motor `lib/core/biodynamic/`, vse v main):** T1.1–T1.11 ✅ — **T1 je zaključen.**
Motor: API + časovna osnova (JD/T), λ Sonca in Lune (Meeus 25/47), zodiak (kalibrirane meje + IAU
rezerva), mena (elongacija, osvetljenost, mlaj/ščip z bisekcijo), `dayFor` (element ob začetku dneva
§12.6, bisekcija ure prehoda), deklinacija (`ascending`), neugodni dnevi (vozel [−5 h, +4 h],
perigej ±13 h, mrk |β| < 1,6°; kalibrirano proti tiskanemu Thun 2024). T1.10 fixture: julij+avgust
2026 (62 dni × 2 sistema, vse plasti) v `biodynamic_fixture_test.dart`, sidran na javne sizigije in
mrka 12. 8./28. 8. 2026, zasebno navzkrižno preverjen (sweep 0 neujemanj, vozli 7/7). T1.11
meritev: mreža meseca (84 klicev `dayFor`) ~16 ms → **memoizacija na (mesec, sistem) gre v T3
provider**, motor ostane brez nje. Motor: 121 testov, cel suite 1021, CI zelen.
**⚠️ Časovna cona:** referenčni in fixture testi so CET/CEST — CI korak `Test` ima pripeto
`TZ: Europe/Ljubljana` (`ci.yml`), ne odstranjuj pripetja.

**T2.1 ✅ (31. 7.):** `kMoonCalendarEnabled = false` v `core/config.dart` (compile-time dark flag,
vzorec `kSuppliesEnabled`) — edino stikalo do T6, ko ga na vstopnih točkah dopolni `plusProvider`
gate + `kTendaskPlusEnabled`.
**T2.2 ✅ (31. 7.):** `local_prefs` ključa `moon_calendar_enabled` (`Future<bool?>`, null =
nikoli spremenjeno → privzeto VKLOPLJENO po A6=A) in `moon_system` (`String?`, privzeto
`'sidereal'`) + eksplicitne metode in round-trip testi. Device-local (B1), nič synca, nič sheme.
**T2.3 ✅ (31. 7.):** `MoonSettingsController` (`lib/features/moon/application/`, vzorec
`theme_palette_controller`): `MoonSettings(enabled, system)`, privzeto enabled=true (A6) +
`CalendarSystem.sidereal` (neznana vrednost → fallback sidereal); `setEnabled`/`setSystem`;
ogret v `main.dart` bootstrapu ob paleti. En `system` vodi vse zaslone (§11.6).

**Naloga TE seje: korak T2.4 — `MoonColors` ThemeExtension** (branch `feat/fr19-t2-4-moon-colors`):

- Vzorec `SwipeColors` ThemeExtension: 4 element-barve × light/dark, **ena globalna instanca za
  vseh 6 palet** (A4-A brez 12 kombinacij); registracija v `app_theme.dart` `extensions:`.
- Nikoli hardcode hex v widgetih; barve zaenkrat brez porabnika → nič vidnega.
- ⚠️ **A4 blokira ta korak** (izbira 4 semantičnih barv, light+dark odtenki) — če konkretne
  vrednosti še niso potrjene, najprej vprašaj lastnika.

**Pred delom preberi:** plan T2 (`docs/plan-implementacije-fr19-fr20.md`) · vzorec (`SwipeColors`
v `theme/`) · odločitev A4 (`biodynamic-calendar-decisions.md`) · [[tendask-theme-palettes]].

**Pravila:** naredi natanko ta korak in nič več (ne začenjaj T2.5). Pred merge: `flutter analyze`
čist + cel `flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu označi T2.4, posodobi ta
dokument na naslednji korak (T2.5 ruta `/moon-calendar` z redirect varovalom,
`feat/fr19-t2-5-route`) in predlagaj commit.

**Stanje odločitev:** A1=C ✅ · A3=A ✅ · A6=A ✅ (privzeto vklopljeno) · A4/A5 (barve, ikone) še
odprti — A4 blokira T2.4 (barve elementov), A5 blokira T3.1–T3.2 (ikone); T2.5 ne blokira nobena.
