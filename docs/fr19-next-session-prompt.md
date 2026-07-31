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

**T2.4 ✅ (31. 7., A4=A odločena isti dan):** `MoonColors` ThemeExtension
(`lib/app/theme/moon_colors.dart`, vzorec `SwipeColors`): 4 elementi × (poudarek + soft) ×
light/dark, eni globalni instanci `moonColorsLight`/`moonColorsDark` za vseh 6 palet,
registrirani v `app_theme.dart` `extensions:`; svetle iz wireframa v2, temne po vzorcu terakote
(fino nastavljanje ob prvem pogledu v T3). Test: vsaka paleta izpostavi MoonColors.

**T2.5 ✅ (31. 7.):** ruta `/moon-calendar` (top-level [full], `moon-calendar`) s placeholder
zaslonom (`lib/features/moon/presentation/moon_calendar_screen.dart`, T3 ga zamenja) in
**varovalom na ruti sami**: `moonCalendarRedirect` (`app_router.dart`) ob `!kMoonCalendarEnabled`
preusmeri na `/home`. `route_collision_test` ima guard test (uporablja pravi redirect + flag, zato
ob prižigu T7 ostane zelen); `screen-map.md` §4 ima stanje rut.

**Naloga TE seje: korak T2.6 — i18n skelet `moon`** (branch `feat/fr19-t2-6-i18n-skeleton`):

- Namespace `moon` v `en` + `sl` (`i18n/*.i18n.json`): 4 elementi kot »dan za …«, 12
  ozvezdij/znamenj, beseda ozvezdje/znamenje kot varianti (siderično/tropsko), mena.
- **de ŠELE po vizualni potrditvi zaslonov** (pravilo »poglej, preden vlagaš«) — ne dodajaj je.
- `dart run slang` (ločen CLI, build_runner ga NE ujame) + **commit generiranega** (CI gotcha:
  CI regenerira pred analyze, lokalni pre-push hook ne).
- Ključi še brez porabnika → nič vidnega.

**Pred delom preberi:** plan T2 (`docs/plan-implementacije-fr19-fr20.md`) · spec §11
(poimenovanja, »dan za plod/list/cvet/korenino«, ozvezdje vs znamenje) · obstoječa
`i18n/en.i18n.json`/`sl.i18n.json` struktura.

**Pravila:** naredi natanko ta korak in nič več (T2 je s tem zaključen — ne začenjaj T3). Pred
merge: `flutter analyze` čist + cel `flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu
označi T2.6, posodobi ta dokument na naslednji korak (T3.1 mena CustomPainter,
`feat/fr19-t3-1-phase-painter` — ⚠️ najprej pogled na napravi, A5 ikone blokira T3.2) in
predlagaj commit.

**Stanje odločitev:** A1=C ✅ · A3=A ✅ · A4=A ✅ (fiksne semantične barve) · A6=A ✅ (privzeto
vklopljeno) · A5 (ikone) še odprta — blokira T3.1–T3.2; T2.6 ne blokira nobena.
