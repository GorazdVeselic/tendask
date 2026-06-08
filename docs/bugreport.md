# Bugreport

Zbir odprtih bugov za reševanje v prihodnjih sejah. Najnovejši na vrhu.

---

## BUG-001 — `gardenLocationProvider` disposed during loading (StateError)

- **Status:** razrešen (2026-06-08) — `gardenLocation` → `@Riverpod(keepAlive: true)`; čaka on-device verifikacijo
- **Najden:** 2026-06-07 (Sentry, development, Samsung A53 / SM-A536B)
- **Resnost:** nizka — ni viden crash, app teče naprej; Sentry pa ujame kot unhandled error (šum v monitoringu). 1× dogodek.
- **Sentry issue:** `125841585` / event `8e5f5eaace074d20b374064c069963e0`

### Napaka

```
StateError: Bad state: The provider gardenLocationProvider was disposed
during loading state, yet no value could be emitted.
  element.dart:329  ElementWithFuture.dispose            (riverpod)
  stream_provider.dart:163  $StreamProviderElement.dispose (riverpod)
  ...
```

Stack je čista Riverpod dispose veriga (brez app frame-ov) — gre za zavrnjen `.future`
ob dispose-u providerja, ne za logično napako v naši kodi.

### Vzrok

Veriga providerjev:

1. `_WeatherSection` (`lib/features/home/presentation/home_screen.dart:142`) gleda
   `currentWeatherProvider` (autoDispose `Future`).
2. `currentWeather` (`lib/features/weather/application/weather_service.dart:92`) naredi
   `await ref.watch(gardenLocationProvider.future)`.
3. `gardenLocation` (`lib/core/location/location_repository.dart:101`) je **autoDispose
   `StreamProvider`** nad drift `watchSingleOrNull()`. Drift prvo vrstico emitira šele na
   naslednjem ticku → obstaja kratko okno, ko je provider v **loading** stanju.

V tem loading oknu se veriga disposa, preden stream emitira prvo vrednost. Ker je
`currentWeather` edini poslušalec `gardenLocation`, se ob njegovem dispose-u autodisposa
tudi `gardenLocation` — še med loadingom → pending `.future` se zaključi s tem `StateError`.

Najverjetnejši sprožilci:
- pull-to-refresh: `ref.invalidate(currentWeatherProvider)` (`home_screen.dart:106`),
- hiter prehod splash → Domov ali odhod z zaslona med startupom.

Bistvo: **`await .future` na autoDispose `StreamProvider`-ju, ki se lahko disposa, preden
prvič emitira.**

### Rešitev (predlagana)

Najmanjši in pravilen popravek: `gardenLocation` naj bo **keepAlive**, enako kot
`h3Provider` tik nad njim v isti datoteki. Single-row drift watch je poceni, lokacija se
redko spremeni; keepAlive prepreči autodispose med loadingom → `.future` se vedno razreši.

```dart
// lib/core/location/location_repository.dart:101
@Riverpod(keepAlive: true)
Stream<GardenCoords> gardenLocation(Ref ref) => ref
    .watch(locationRepositoryProvider)
    .watchGardenCoordinates()
    .map((c) => c ?? (latitude: kDefaultLatitude, longitude: kDefaultLongitude));
```

Nato:

```
dart run build_runner build --delete-conflicting-outputs
```

(treba zaradi `isAutoDispose` v generirani `location_repository.g.dart`.)

**Alternativa (več dela, najbrž nepotrebno):** za vreme brati enkratni `gardenCoordinates()`
(Future) namesto `.future` na streamu; reaktivni stream pustiti samo za re-fetch trigger.

### Verifikacija po popravku

- `flutter analyze` čist.
- Ročno na napravi: večkrat pull-to-refresh na Domov + hitri prehodi splash → Domov →
  drug zaslon; preveri, da se v Sentry ne pojavi nov dogodek tega issue-a.
