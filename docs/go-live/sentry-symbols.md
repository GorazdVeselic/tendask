# Sentry debug symbols — analiza (odložena postavka iz M9.1/9.4)

> **Ugotovitev (2026-06-09): z obstoječo arhitekturo (pure-Dart `sentry`) upload debug
> simbolov NI potreben in z njim ni mogoče simbolicirati. Postavko zapri kot N/A za MVP.**

## Zakaj

Tendask namenoma uporablja **pure-Dart paket `sentry`** (NE `sentry_flutter`) — `sentry_flutter`
se ne prevede na svežem Android skladu (glej roadmap 9.1). Posledice za simbolikacijo:

1. **Obfuskacija je IZKLOPLJENA.** Release build se gradi brez `--obfuscate`, zato AOT snapshot
   **ohrani imena funkcij** → stacktrace v Sentryju je že berljiv (imena metod/datotek vidna).
   Brez obfuskacije upload simbolov nič ne doda.
2. **Mehanizem, ki bi simbole povezal z dogodki, manjka.** Simbolikacija obfusciranih Dart
   stacktrace-ov zahteva, da dogodek nosi Dart **debug-id** (build-id). To pripne integracija
   `LoadDartDebugImagesIntegration` / native most, ki **živi v `sentry_flutter`** — pure-Dart
   `sentry` je nima. Torej tudi če bi simbole naložili, jih Sentry ne bi mogel pripeti.
3. **Native (NDK) sesutja se tako ali tako ne zajemajo** — pure-Dart `sentry` nima native
   integracije. Zajemamo le Dart napake (ročno prek `FlutterError.onError` +
   `PlatformDispatcher.onError` + `runZonedGuarded`, glej `main.dart`).

**Zaključek:** trenutni release že daje berljive Dart stacktrace-e. Upload debug simbolov ne
prinese ničesar, dokler ostajamo na pure-Dart `sentry`. **Ne dodajaj `--obfuscate`** (sicer bi
postali stacktrace-i neberljivi BREZ delujoče simbolikacije).

## Če bi kasneje želeli polno simbolikacijo (po MVP)

Pogoj: prehod na **`sentry_flutter`** (ko bo združljiv s skladom — Kotlin 2.3/AGP 9; preveri
changelog). Šele takrat ima upravičenost:

1. Gradi: `flutter build appbundle --release --dart-define-from-file=dart_defines.json --obfuscate --split-debug-info=build/symbols`
2. Naloži (potrebuje `sentry-cli` + `SENTRY_AUTH_TOKEN`, gitignored v `.env`):
   `sentry-cli debug-files upload --org gorazd-veselic --project tendask build/symbols`
3. `sentry_flutter` poskrbi za debug-id na dogodkih → Sentry zmapira.

`sentry-cli` ni nameščen (👤, ob potrebi: `npm i -g @sentry/cli` ali `scoop install sentry-cli`).
Sentry: org `gorazd-veselic`, projekt `tendask`.

## Majhna izboljšava, ki JE smiselna zdaj (opcijsko)

Nastavi `options.release` + `options.dist` v `Sentry.init` (v `main.dart`) na verzijo aplikacije,
da so dogodki grupirani po release (npr. `tendask@1.0.0+1`). Ni nujno za interni test; berljivost
stacktrace-a je že OK.
