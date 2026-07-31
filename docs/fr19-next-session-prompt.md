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
`'sidereal'`) + eksplicitne metode in round-trip testi. Device-local (B1), nič synca, nič sheme,
ključa še brez bralca.

**Naloga TE seje: korak T2.3 — `MoonSettingsController`** (branch `feat/fr19-t2-3-settings-controller`):

- `@riverpod` controller po vzorcu `theme_palette_controller.dart`: bere/piše oba `local_prefs`
  ključa, privzeti vrednosti razreši on (enabled=true po A6, `CalendarSystem.sidereal`).
- **Ogretje v `main.dart` bootstrapu** (kot paleta) — da čip na Domov ob zagonu ne utripne.
- **Invarianta iz §11.6:** en `system` iz tega controllerja vodi VSE zaslone hkrati.
- Riverpod code-gen → `dart run build_runner build --delete-conflicting-outputs` + commit
  generiranega.

**Pred delom preberi:** plan T2 (`docs/plan-implementacije-fr19-fr20.md`) · vzorec
(`theme_palette_controller.dart` + njegovi testi) · `local_prefs` (nova ključa).

**Pravila:** naredi natanko ta korak in nič več (ne začenjaj T2.4). Pred merge: `flutter analyze`
čist + cel `flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu označi T2.3, posodobi ta
dokument na naslednji korak (T2.4 `MoonColors` ThemeExtension, `feat/fr19-t2-4-moon-colors`)
in predlagaj commit.

**Stanje odločitev:** A1=C ✅ · A3=A ✅ · A6=A ✅ (privzeto vklopljeno) · A4/A5 (barve, ikone) še
odprti — A4 blokira T2.4 (barve elementov), A5 blokira T3.1–T3.2 (ikone); T2.3 ne blokira nobena.
