# Handoff prompt — realizacija sistema tem (6 palet + način)

> **✅ ZAKLJUČENO (2026-06-24).** Faza #1 (način) + faza #2 (6 palet) realizirani in commitani skupaj (`feat(theme): barvne teme …`). On-device potrjeno. Spodnji prompt je ohranjen kot zgodovinski zapis naloge.

## Realizirano stanje

- **Katalog** `lib/app/theme/theme_palette.dart`: `ThemeRoles` (vse M3 vloge + `hint` + `SwipeColors`, robni toni `surfaceContainerHighest`/`inverseSurface` nullable) + `ThemePalette` + 6 palet. `green` gradi iz `AppColors` (ThemeData **byte-identičen** — potrjeno s field-by-field pregledom); 5 novih = literali iz `themes-gallery.html` prek `ThemeRoles.derived` (swipe izpeljan po wireframe mapiranju). `paletteForId(id)` → fallback na green.
- **`AppTheme.light/dark(palette)`** gradita iz palete (`_scheme` + `copyWith(null)` pusti M3 default za neuporabljene green-dark vloge).
- **`ThemePaletteController`** (zrcali mode) + `themePalette()/setThemePalette()` v `local_prefs` (ključ `theme_palette`, device-local, **ne sinhronizira**). Warmup obeh v `main.dart` pred `runApp` (brez flasha).
- **`AppearanceScreen`** (route `/appearance`): način (segment + status »sledi telefonu«) + mreža 6 kartic z mini-predogledom + živ predogled. `settings_screen` → `ListTile` »Tema in barve« (settings ostal <300 vrstic).
- **Audit:** `reminder_sound_banner`/`notification_preview`/`splash` = fiksni semantični/brand toni (ostanejo); `home_screen` + `location_screen` bannerji → `colorScheme` (palet-gnani). **Green dark namerni odmik:** ta bannerja zdaj uporabljata pravi temni container namesto svetle pilule (neizogibno za palet-podporo; green light byte-identičen).
- **WCAG:** vseh 6 × svetlo/temno pregnano; edini odmik od wireframa = ocean/nebo svetla `secondary` `#E5774E`→**`#DE6E45`** (belo besedilo 2.97→3.27, AA 3:1 floor). Ostali pari ≥3.0.
- **i18n** sekcija `appearance` (en/sl/de). **Testi:** `theme_palette_controller_test` ✅; analyze čist; 238/238 zeleno. Korektnostni + varnostni neodvisni pregled: čista.

---

## Naloga: implementiraj barvne teme (6 palet) + zaslon Videz v Nastavitvah

Kontekst: Tendask (Flutter + Riverpod + drift). Govoriva slovensko, koda v angleščini. Pred commitom VEDNO vprašaj. Pred pushom poženi cel `flutter test`. i18n prek slang (`dart run slang`), shema prek `build_runner`.

### Kaj je ŽE narejeno (faza #1 — NE ponavljaj; je v DELOVNI KOPIJI, NEcommitano)
> ⚠️ Faza #1 NI commitana — vse spodnje je nestaged/staged v working tree (zadnji commit = `c6df016` vc6 bump). **Commitaj fazo #1 (+ wireframe) PRVO** (vprašaj uporabnika), nato gradi #2. Datoteke: `lib/app/theme/theme_mode_controller.dart(.g.dart)`, `lib/core/local_prefs/local_prefs.dart`, `lib/app/app.dart`, `lib/main.dart`, `lib/features/settings/presentation/settings_screen.dart`, i18n (3 json + 4 g.dart), `test/app/theme_mode_controller_test.dart`.

Izbira **načina** Sistemsko/Svetlo/Temno je implementirana in deluje:
- `lib/app/theme/theme_mode_controller.dart` — `@riverpod` async `ThemeModeController` (build bere `localPrefs.themeMode()`, `set(ThemeMode)`), `reminderAudioProvider`-slog; `_parse` fallback na `system`.
- `lib/core/local_prefs/local_prefs.dart` — `themeMode()` / `setThemeMode(String)` nad `local_flags` (ključ `theme_mode`), device-local.
- `lib/app/app.dart` — `themeMode: ref.watch(themeModeControllerProvider).value ?? ThemeMode.system`.
- `lib/main.dart` — `await container.read(themeModeControllerProvider.future)` PRED `runApp` (brez flash-a).
- `lib/features/settings/presentation/settings_screen.dart` — sekcija »Videz« s `SegmentedButton<ThemeMode>`.
- i18n: `settings.section_appearance/theme_system/theme_light/theme_dark` (en/sl/de).
- test: `test/app/theme_mode_controller_test.dart`.

### Cilj faze #2 (TA naloga): barvne palete
Dodaj **6 barvnih palet** (uporabnik izbere v Nastavitvah; **privzeto = Zelena**). Vsaka paleta ima svetlo + temno varianto. Način (sistemsko/svetlo/temno) ostane ločena, že obstoječa odločitev.

**6 palet:** `green` (Zelena – trenutna, privzeta), `lavender` (Sivka), `ocean` (Ocean), `clay` (Terakota), `berry` (Borovnica), `nebo` (Nebo).

### Vir resnice za barve (OBVEZNO preberi)
Točne hex vrednosti vseh 6 palet (svetlo + temno, polni nabor M3 vlog vključno z `errorContainer`/`onErrorContainer`/`inverseSurface`/`onInverse`) so v **`docs/wireframes/themes-gallery.html`** (CSS bloki `[data-theme=…][data-mode=…]`). Postavitev zaslona Nastavitev je v **`docs/wireframes/12b-appearance.html`**. Barve so bile vizualno potrjene — **prepiši jih iz wireframa, NE generiraj prek `fromSeed`** (fromSeed ne bi reproduciral potrjenih surface/secondary tonov).

`green` paleta = obstoječe vrednosti v `lib/app/theme/app_theme.dart` + `app_colors.dart` (se ujemajo z wireframom).

### Načela (uporabnikovo navodilo)
- **Vse barve iz enega vira, konstantne in nastavljive.** Definiraj `ThemePalette` model (ali strukturiran katalog) z vsemi vlogami za light+dark; `AppColors` ostane vir surovih konstant.
- **Semantična `warn` paleta je FIKSNA čez vse teme** (`AppColors.warn`/`warnSoft` — uporablja jih `ReminderSoundBanner` + notification preview). `error` je **per-paleta** (npr. clay `#A3303C`).
- Brez hardcode hex v widgetih; vse prek teme/`colorScheme`.

### Koraki (DoD)
1. **`ThemePalette` model + katalog 6 palet** (npr. `lib/app/theme/theme_palette.dart`): vsaka z light+dark vlogami (primary, onPrimary, primaryContainer, onPrimaryContainer, secondary, onSecondary, surface, onSurface, surfaceContainerHighest, onSurfaceVariant, outline, error, onError, errorContainer, onErrorContainer, inverseSurface, onInverseSurface) + SwipeColors (complete=primary, postpone=secondary, neutral=onSurfaceVariant, delete=error). Vrednosti iz wireframa. Vključi `id` + i18n ključ imena.
2. **Refaktor `AppTheme`**: `light(ThemePalette)` / `dark(ThemePalette)` gradita `ColorScheme` + `SwipeColors` + input/chip teme iz palete (ohrani font, fixne dele). Brand `green` mora dati IDENTIČEN rezultat kot zdaj (regresija!).
3. **`ThemePaletteController`** (zrcali `ThemeModeController`): `@riverpod` async, build bere `localPrefs.themePalette()` (nov ključ `theme_palette`, default `green`), `set(id)`. Dodaj `themePalette()`/`setThemePalette(String)` v `local_prefs.dart`. `_parse` fallback na `green`.
4. **`main.dart`**: `await container.read(themePaletteControllerProvider.future)` pred `runApp` (kot za mode).
5. **`app.dart`**: `theme: AppTheme.light(palette)`, `darkTheme: AppTheme.dark(palette)`, `themeMode: …` (mode že obstaja). Beri palette provider.
6. **Nastavitve → Videz** (`settings_screen.dart`): razširi obstoječo sekcijo po `docs/wireframes/12b-appearance.html`:
   - obstoječi `SegmentedButton<ThemeMode>` (način) na vrhu + pomožno besedilo + status »sledi telefonu« pri Sistemsko (resolved prek `MediaQuery.platformBrightnessOf`),
   - **mreža 6 kartic** (2 stolpca), vsaka z mini-predogledom palete + ime; Zelena z značko »Privzeto«; izbrana ima kotno kljukico; »Ponastavi na privzeto« ko ni green,
   - **živ predogled** spodaj (app bar, kartica, gumb, čip, stikalo, swipe) — neobvezno, a priporočeno (gl. wireframe),
   - opomba »uveljavi se takoj · velja za to napravo«. Brez gumba Shrani (instant apply).
   - Razmisli o ekstrakciji v ločen zaslon `AppearanceScreen` (route), če sekcija preraste ~Nastavitve (CLAUDE.md: >~300 vrstic = razdeli).
7. **i18n** (en/sl/de): imena palet (`Zelena/Sivka/Ocean/Terakota/Borovnica/Nebo` — lastna imena; razmisli, ali prevajati ali pustiti endonime kot jezike), `Privzeto`, `Ponastavi na privzeto`, naslovi sekcij, pomožna besedila, »uveljavi se takoj«.
8. **Audit 5 datotek z direktnim `AppColors`** (`notification_preview_screen`, `reminder_sound_banner`, `home_screen`, `location_screen`, `splash_screen`): potrdi, da uporabljajo le FIKSNE semantične tone (warn) ali da preidejo na `colorScheme`/paleto, kjer barva mora slediti temi.
9. **WCAG kontrast**: preveri primary/onPrimary, onSurface na surface, onSurfaceVariant — v VSEH 6 paletah × light+dark. Uglasi sporne vrednosti (zabeleži spremembo proti wireframu).
10. **Testi**: `theme_palette_controller_test` (default green, set persistira, neznan id → green). Po želji widget test za izbiro v Nastavitvah. Posodobi obstoječ `settings_widget_test`, če se sekcija premakne/spremeni.
11. **Verifikacija**: `dart run slang` + `dart run build_runner build` + `flutter analyze` (čist) + `flutter test` (vse zeleno). **On-device** (SM A536B prek `deploy.bat hot`): preklopi vseh 6 tem × svetlo/temno/sistemsko, preveri preživetje ponovnega zagona + da je brand green nespremenjen.

### Commiti (vprašaj pred vsakim)
Predlog: (a) `feat(theme): ThemePalette katalog + palet-gnan AppTheme (6 palet)`; (b) `feat(settings): izbira barvne teme v zaslonu Videz`. Plus commit wireframov, če še niso: `docs(wireframes): galerija tem + zaslon Videz (6 tem)`.

### Najprej preberi
`docs/wireframes/themes-gallery.html` (vir barv) · `docs/wireframes/12b-appearance.html` (postavitev) · `lib/app/theme/app_theme.dart` + `app_colors.dart` · `lib/app/theme/theme_mode_controller.dart` · `lib/core/local_prefs/local_prefs.dart` · `lib/features/settings/presentation/settings_screen.dart` · `lib/core/widgets/swipe_actions.dart` (SwipeColors). Spomin: [[tendask-work-status]].

### Odprto / opomba
- **PRVO `git status`**: faza #1 (mode), oba wireframa in ta handoff so v delovni kopiji NECOMMITANI. Commitaj jih (vprašaj), preden začneš #2 — da imaš čisto bazo.
- Faza #1 (mode) je implementirana v working tree; gradi na njej, ne podvajaj.
