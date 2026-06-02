# Tendask

Vrtnarska evidenčna aplikacija — beleženje opravil, rastlin in območij z offline-first pristopom.

[![CI](https://github.com/GorazdVeselic/tendask/actions/workflows/ci.yml/badge.svg)](https://github.com/GorazdVeselic/tendask/actions/workflows/ci.yml)

## Zahteve

- Flutter stable ≥ 3.44
- Dart ≥ 3.12
- Android SDK (za USB debug na napravi)

## Zagon

```bash
flutter pub get
dart run slang                              # generira prevode (sl/en/de)
dart run build_runner build                 # generira Riverpod providerje
flutter run                                 # zaženi na priključeni napravi
```

Za USB debug: `flutter devices` pokaže priključene naprave; `flutter run -d <id>` za izbiro naprave.

## Build (Android release)

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=<url> \
  --dart-define=SUPABASE_ANON_KEY=<key>
```

## Struktura projekta

```
lib/
  main.dart               # bootstrap (ProviderScope + TranslationProvider)
  app/                    # MaterialApp, router (go_router), tema, i18n
  core/                   # drift DB, sync servis, Supabase client, config
  i18n/                   # slang prevodi (sl/en/de) — generirano
  features/
    home/                 # Domov (01), Hiter vnos (02)
    tasks/                # Opravila: data · application · presentation
    journal/              # Dnevnik/opombe (03, 18)
    areas/                # Območja (04, 05, 09)
    plants/               # Izbirnik rastlin (10)
    supplies/             # Zaloge (08)
    notifications/        # Opomniki (19–22)
    auth/                 # Prijava/onboarding (13, 15, 16)
  data/
    seed/                 # Seed kataloga (tipi opravil + rastline)
docs/
  roadmap.md              # razvojni plan (M0–M11) + dnevnik napredka
  tech-stack.md           # potrjen tehnološki sklad
  koncept.md              # funkcionalna specifikacija
  brand/                  # vizualna identiteta (barve, tipografija, SVG)
  wireframes/             # zasloni (~27)
```

## Razvoj

- **Code-gen** (po spremembi anotacij/shem): `dart run slang && dart run build_runner build`
- **Analiza**: `flutter analyze`
- **Testi**: `flutter test`
- **Skrivnosti** (Supabase ključi, Sentry DSN): prek `--dart-define`, nikoli v repo

## Sklad

Flutter · Riverpod · go_router · drift (SQLite offline) · Supabase · slang (i18n) · Open-Meteo · Sentry

Podrobnosti: [`docs/tech-stack.md`](docs/tech-stack.md)
