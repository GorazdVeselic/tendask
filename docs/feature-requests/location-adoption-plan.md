# FR-22 — implementacijski plan

- **Spec:** [`location-adoption.md`](location-adoption.md) · **Wireframe:** [`01d-weather-states.html`](../wireframes/01d-weather-states.html)
- **Datum:** 2026-07-29 · **Stanje:** ✅ izveden 30. 7. 2026 (zgodovinski dokument — kartica je bila
  po izvedbi prenovljena, glej [`location-adoption.md`](location-adoption.md) in
  [`../narejeno.md`](../narejeno.md))
- **Predpogoj izdaje:** FR-24 je narejen, a neizdan — FR-22 **ne sme v isto izdajo** (ista metrika).

Plan je napisan tako, da ga je mogoče izvesti od zgoraj navzdol. §2 so trki, ki so se pokazali med
načrtovanjem in **spremenijo spec** — preberi jih pred §3.

---

## 1. Kaj se spremeni, na eni strani

| Plast | Datoteka | Sprememba |
|---|---|---|
| config | `core/config.dart` | `kDefaultLatitude/Longitude` → `kDevLatitude/kDevLongitude` (nullable, samo `--dart-define`) |
| core | `core/location/location_repository.dart` | `gardenLocation` vrne `GardenCoords?` |
| weather | `features/weather/application/weather_service.dart` | `currentWeather`, `weatherDetail` → null brez lokacije, **brez klica** |
| weather | `features/weather/presentation/weather_no_location_card.dart` | **nov** widget (povabilo) |
| home | `features/home/presentation/widgets/home_weather_section.dart` | veja za »ni lokacije« |
| tasks | `features/tasks/application/tasks_providers.dart` | `weatherCapture` → null brez lokacije |
| tasks | `features/tasks/presentation/widgets/task_weather_section.dart` | `StatelessWidget` → `ConsumerWidget`, 3 veje |
| i18n | `i18n/{sl,en,de}.i18n.json` | 5 novih ključev + 2 popravka |

**Brez:** migracije, spremembe sheme, nove dependency, spremembe routerja, spremembe synca.

---

## 2. Trki, ugotovljeni med načrtovanjem

### T1 · `currentWeather == null` ne pove, ali gre za »ni lokacije« ali »offline«

Oba stanja dasta isto vrednost (`weather_service.dart:128`), UI pa ju mora izrisati različno —
povabilo proti tihi »ni na voljo« kartici. Iz `AsyncValue<WeatherSnapshot?>` tega ni mogoče ločiti.

**Rešitev:** `HomeWeatherSection` **najprej** prebere lokacijo in šele v veji »lokacija je« sploh
`ref.watch(currentWeatherProvider)`. Pogojni `watch` je v Riverpodu legalen; ob prehodu se
`currentWeather` (autoDispose) počisti in ob vrnitvi znova zgradi.

**Zavrnjeno:** `sealed` stanje `WeatherState { noLocation, offline, data }` iz enega providerja —
lepše na papirju, a doda plast nad dvema providerjema, ki ju UI itak bere. Pod prag ≥3 klicalcev.

### T2 · Spec pravi »gledaj `gardenCellProvider`«, pravilno je `gardenLocationProvider`

`location-adoption.md §6` je bil napisan, ko je `gardenLocation` vračal privzetek in torej ni ločil
»ni lokacije« od »Ljubljana«. Ko postane nullable, je boljši vir — ker pokrije tudi primer
**neveljavne celice**: `cellCentroid()` lahko vrne null tudi ob shranjeni celici
(`location_repository.dart:127`).

Če bi UI gledal celico, bi ob pokvarjeni celici pokazal »vreme ni na voljo« (celica obstaja →
ni povabila; centroid null → ni vremena) — slepa ulica brez poti naprej. Z `gardenLocation` dobi
uporabnik povabilo, ki ga pelje na zaslon 16, kjer lokacijo nastavi znova.

**→ Popravi `location-adoption.md §6`.**

### T3 · Za opravljeno opravilo **ne vemo**, ali je bila lokacija nastavljena takrat

Wireframe (telefon 4) obljublja besedilo »Vreme ni zabeleženo — lokacija takrat ni bila nastavljena«.
Task tega podatka **ne nosi**; vemo le trenutno stanje. Iz tega sledita dve laži:

| Zaporedje | Kaj bi pisalo | Resnica |
|---|---|---|
| zaključi brez lokacije → pozneje jo nastavi | »zajet brez povezave« | lokacije takrat ni bilo |
| zaključi z lokacijo, a offline → pozneje odstrani lokacijo | »lokacija takrat ni bila nastavljena« | povezave takrat ni bilo |

Isti očitek zadene **obstoječe** besedilo `weather.detail_none` (»zajet brez povezave«) — tudi to
trdi vzrok, ki ga ne poznamo.

**Rešitev:** trenutno stanje uporabi **samo tam, kjer opisuje prihodnost**:

- `waiting` → posnetek še bo; trenutna lokacija odloča → sme povedati vzrok in ponuditi CTA.
- `done` → posnetka ne bo nikoli; vzroka ne poznamo → **nevtralno besedilo brez vzroka**.

Zato: `detail_none` se skrajša na »Vremenski posnetek ni na voljo.«, `detail_none_no_location` iz
wireframa **odpade** (en ključ manj), telefon 4 v wireframu dobi popravljeno besedilo.

**Zavrnjeno:** nov stolpec `task.weather_skip_reason` — shema + migracija + sync za en pojasnjevalni
stavek pri že zaključenem opravilu. Ne plača se.

### T4 · `config.dart` ne sme poznati `GardenCoords`

Skušnjava je v config dati `kDevLocationOverride` kot record — a `GardenCoords` živi v
`location_repository.dart`, ki `config.dart` **importa**. Record v configu = krožni import.

**Rešitev:** config hrani dve ločeni nullable vrednosti; record sestavi `location_repository`.

### T5 · Home ni v `test/layout/` matriki

FR-22 §5 zahteva vnos v matriko, a `HomeScreen` v njej ni — zahteval bi cel svet providerjev
(tasks, areas, plants, catalog, weather). Matrika sprejme poljuben widget, ne le zaslon.

**Rešitev:** v matriko gre **kartica**, ne zaslon. Zato mora biti `WeatherNoLocationCard` čist
widget brez `ref` — vso odvisnost dobi kot `onSetLocation` callback. To je tudi skladno s pravilom,
da presentation widget ne bere providerjev.

---

## 3. Koraki

### Korak 1 — config (`core/config.dart`)

```
- final kDefaultLatitude  = _latEnv.isEmpty ? 46.0569 : double.parse(_latEnv);
- final kDefaultLongitude = _lonEnv.isEmpty ? 14.5058 : double.parse(_lonEnv);
+ /// Dev-only override for testing other regions (--dart-define=WEATHER_LAT/LON).
+ /// Null in every shipped build: without a set location the app shows no weather.
+ final kDevLatitude  = _latEnv.isEmpty ? null : double.parse(_latEnv);
+ final kDevLongitude = _lonEnv.isEmpty ? null : double.parse(_lonEnv);
```

Doc komentar nad njima je treba prepisati — trenutni trdi »Default = Ljubljana«, kar po tem koraku
ne drži več.

### Korak 2 — `gardenLocation` postane nullable

`core/location/location_repository.dart:119-130`:

```
Stream<GardenCoords?> gardenLocation(Ref ref) {
  final h3 = ref.watch(h3Provider);
  final devLat = kDevLatitude, devLon = kDevLongitude;
  final dev = (devLat == null || devLon == null)
      ? null
      : (latitude: devLat, longitude: devLon);
  return ref.watch(locationRepositoryProvider).watchGardenCell()
      .map((cell) => cellCentroid(h3, cell) ?? dev);
}
```

Doc komentar (vrstici 119-121) prepiši: »…or null until one is set«.

Po tem: **`dart run build_runner build --delete-conflicting-outputs`** — `gardenLocation` je
generiran provider in tip v `.g.dart` se spremeni.

### Korak 3 — trije klicalci `gardenLocation`

| Datoteka | Danes | Po |
|---|---|---|
| `weather_service.dart:129` | `captureCached(lat: loc.latitude, …)` | `if (loc == null) return null;` pred klicem |
| `weather_service.dart:143` | isto za `captureCachedFull` | isto |
| `tasks_providers.dart:22` | `weather.capture(lat: loc.latitude, …)` | `if (loc == null) return null;` |

V `tasks_providers` s tem **odpade klic na Open-Meteo** ob zaključku opravila brez lokacije.
`TasksRepository._captureWeather` (`tasks_repository.dart:553`) že pravilno obravnava null
(`if (json == null) return;`) — **tam ni sprememb**.

### Korak 4 — novi widget `WeatherNoLocationCard`

`features/weather/presentation/weather_no_location_card.dart` — čist `StatelessWidget`:

```
class WeatherNoLocationCard extends StatelessWidget {
  const WeatherNoLocationCard({super.key, required this.onSetLocation});
  final VoidCallback onSetLocation;
```

Vsebina po wireframu: `Icons.place` v 44 dp `primaryContainer` kvadratu · naslov `titleSmall`
`no_location_title` · telo `bodySmall` `onSurfaceVariant` `no_location_body` · `FilledButton`
polne širine 48 dp `no_location_cta` · vrstica `Icons.lock_outline` 12 dp +
`no_location_privacy` v `labelSmall`.

Cela kartica je `InkWell(onTap: onSetLocation)`, gumb kliče **isti** callback.

**Ne** stanje `CurrentWeatherCard` — ta prikazuje vreme, povabilo ni vreme (spec §6).

### Korak 5 — `HomeWeatherSection`

```
final location = ref.watch(gardenLocationProvider);
if (location.isLoading) return const _WeatherLoadingCard();   // glej T6
if (location.value == null) {
  return WeatherNoLocationCard(onSetLocation: () => context.push('/location'));
}
// od tu naprej nespremenjeno: currentWeatherProvider, placeLabel, sheet
```

`HomeWeatherSection` je že `ConsumerWidget` — brez strukturne spremembe.

### Korak 6 — `TaskWeatherSection` → `ConsumerWidget`

`StatelessWidget` → `ConsumerWidget` (`build(context, ref)`); klicalec
`task_detail_screen.dart:137` se **ne spremeni**.

Tri veje za manjkajoč posnetek, po T3:

```
final hasLocation = ref.watch(gardenLocationProvider).value != null;
final (hint, cta) = switch ((task.status, hasLocation)) {
  (TaskStatus.waiting, true)  => (t.weather.detail_waiting, false),
  (TaskStatus.waiting, false) => (t.weather.detail_no_location, true),
  (_, _)                      => (t.weather.detail_none, false),
};
```

Ob `cta == true` pod besedilom `TextButton` `no_location_cta` → `context.push('/location')`.

### Korak 7 — i18n

Novi ključi pod `weather.*` (sl/en/de v [wireframu](../wireframes/01d-weather-states.html)):
`no_location_title`, `no_location_body`, `no_location_cta`, `no_location_privacy`,
`detail_no_location`.

Popravki obstoječih:

| Ključ | Danes (sl) | Po |
|---|---|---|
| `weather.detail_none` | Vremenski posnetek ni na voljo (zajet brez povezave). | Vremenski posnetek ni na voljo. |
| `location.clear_confirm_body` | Vreme bo prikazano za privzeto območje, dokler ne nastaviš nove lokacije. | Brez lokacije ti vremena ne bomo mogli pokazati. |
| `location.privacy` | Natančne lokacije nikoli ne shranjujemo. Shranimo samo približno **okolico** (širše območje nekaj km), ki je nikoli ne razkrijemo drugim. | …približno **lokacijo** (na nekaj kilometrov natančno), ki je nikoli ne razkrijemo drugim. |

Vse tri v sl/en/de; nemške in angleške različice so v
[wireframu](../wireframes/01d-weather-states.html), sekcija »Obstoječa besedila, ki gredo v isto
spremembo«.

Nato **`dart run slang`** — slang je ločen CLI, `build_runner` ga ne ujame.

---

## 4. Testi

### Padli bodo

| Test | Zakaj | Popravek |
|---|---|---|
| `location_repository_test.dart:183` »emits the default region when no location is set« | pričakuje `kDefaultLatitude` | `expect(coords, isNull)`, preimenuj v »emits null…« |

`FakeLocationRepository` (`test/core/location/fake_location_repository.dart`) se **ne spremeni** —
podpis `watchGardenCell()` ostane (posledica odločitve A2 pri BUG-005).

Ostalih padcev ne pričakujem: `weather_service_test.dart` testira `WeatherService` neposredno s
koordinatami, ne prek providerja.

### Novi

1. **`weather_service_test`** — `currentWeather` in `weatherDetail` ob `gardenLocation == null`
   vrneta null in **ne kličeta** clienta (fake client s števcem klicev).
2. **`tasks_providers`** — zaključek opravila brez lokacije: task ima `weather == null`, client ni
   klican.
3. **Widget: `HomeWeatherSection`** — trije primeri: brez lokacije → `WeatherNoLocationCard`;
   z lokacijo + snapshot → `CurrentWeatherCard`; z lokacijo brez snapshota → tiha kartica.
4. **Widget: tap CTA** → `push('/location')` (router observer ali fake `GoRouter`).
5. **Widget: `TaskWeatherSection`** — tri veje iz koraka 6.
6. **Layout matrika** — `layoutMatrix('weather/no-location', build: () => WeatherNoLocationCard(onSetLocation: () {}))`.
   Nemščina + text-scale 1,3 je najožji primer.

---

## 5. Vrstni red commitov

1. `refactor(location): gardenLocation vrne null brez nastavljene lokacije` — koraki 1–3 + popravek
   obstoječega testa + nova unit testa. **Po tem commitu vreme brez lokacije nikjer ne teče**, UI pa
   še kaže tiho »ni na voljo« kartico — vmesno stanje je konsistentno.
2. `feat(fr-22): povabilo za lokacijo namesto vremena na Domov` — koraki 4–5 + i18n + widget testi +
   layout matrika.
3. `feat(fr-22): pojasnilo o manjkajoči lokaciji v podrobnostih opravila` — korak 6 + testi.
4. `fix(i18n): besedili o privzetem območju ne držita več` — popravka `clear_confirm_body`,
   `detail_none` (+ `privacy`, če Q3 potrjen).

Vsak commit pusti `flutter analyze` čist in `flutter test` zelen.

---

## 6. Verifikacija na napravi

`tmp/steps.txt` + `adb_run.ps1`, po vrsti:

1. Sveža namestitev, onboarding, **preskoči** lokacijo → Domov pokaže povabilo, ne vremena.
2. Tap na kartico (ne na gumb) → odpre se zaslon 16 s puščico nazaj, brez »Nadaljuj«.
3. Nastavi lokacijo → **brez ročne osvežitve** se povabilo zamenja z vremenom (stream je reaktiven).
4. Nastavitve → Lokacija → Odstrani → potrditveni dialog kaže novo besedilo; po odstranitvi se
   povabilo vrne.
5. Brez lokacije zaključi opravilo → v podrobnostih »Vremenski posnetek ni na voljo.«, task nima
   vremena; letalski način ni potreben.
6. Z lokacijo + letalski način → tiha »ni na voljo« kartica z »Tapni za ponovni poskus«, **ne** povabilo.
7. Nemščina + največja pisava na 320 dp → povabilo ovija, gumb ni odrezan.

---

## 7. Odločeno 2026-07-29 (bilo odprto)

1. **T3 — da:** zaključeno opravilo brez posnetka dobi nevtralno »Vremenski posnetek ni na voljo.«
   Ključ `detail_none_no_location` **odpade**; wireframe (telefon 4) popravljen.
2. **T3b — da:** obstoječi `detail_none` izgubi »(zajet brez povezave)« iz istega razloga.
3. **`location.privacy` — noter:** »približno okolico« → »približno lokacijo«, v vseh treh jezikih.
4. **T2 — da:** `gardenLocationProvider`; spec §6 popravljen.

Novih odprtih vprašanj ni — plan je izvedljiv, kot je zapisan.
