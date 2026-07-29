# Bugreport

Zbir odprtih bugov za reševanje v prihodnjih sejah. Najnovejši na vrhu.

---

## BUG-005 — gostov profil ob prijavi brezpogojno prepiše oblačnega (tiha izguba novejše nastavitve)

- **Status:** odprt, popravek **NE implementiran**. Izbrana smer: **zlij profil po stolpcih** (spodaj).
- **Najden:** 2026-07-29 (pregled kode ob zasnovi FR-22, ne iz Sentryja)
- **Resnost:** nizka–srednja — scenarij je redek (dve napravi + gost, ki se dolgo ne prijavi), a gre za
  **tiho izgubo podatka** brez sledi; uporabnik ne izve, da mu je novejša nastavitev izginila.

### Opis

`profile` je edina tabela, kjer se to lahko zgodi: vse ostale imajo `id` (UUID, generiran na napravi),
zato gostove vrstice ob prijavi postanejo **nove** vrstice v oblaku in ne trčijo z ničimer. Profil ima
`user_id` kot primarni ključ → vedno trči z obstoječim.

Potek, ki izgubi podatek:

| Kdaj | Kaj |
|---|---|
| 1. junij | Na napravi B **gost** nastavi lokacijo (*Maribor*). Vrstica ostane lokalna, `updated_at` = 1. jun. |
| 1. julij | Na napravi A je isti človek prijavljen in nastavi lokacijo (*Šentjur*) → v oblak, `updated_at` = 1. jul. |
| 29. julij | Na napravi B se prijavi v ta račun. |

Ob prijavi: `claimLocalRows` (`local_row_claim.dart:24`) preimenuje gostovo vrstico na pravi `user_id` in
jo označi `pending`, **`updated_at` pa namenoma pusti pri miru** (prevzem lastništva ni vsebinska
sprememba). Push je nato navaden `client.from(table).upsert(rows)`
(`sync_push_service.dart:182`) — **brez primerjave `updated_at`**. Junijski Maribor tako povozi julijski
Šentjur, pull pa nato ne prinese nič, ker je v oblaku že Maribor.

Pravilo »novejši zmaga« (LWW), na katerem sync stoji, se tu torej ne uveljavi. Velja za **vse** stolpce
profila — lokacijo, jezik, `notification_settings`, `default_garden_seeded`.

### Zakaj ne trigger na strani baze

Preučena in **zavrnjena** alternativa: `before update` trigger, ki zavrne zapis s starejšim `updated_at`.
Za vsebinske tabele (`task`, `area`) bi bil pravi, za profil pa naredi novo škodo — gostova sveže
nastavljena lokacija ima star `updated_at`, zato bi trigger zavrnil **celo vrstico**, če je oblačni profil
novejši iz čisto drugega razloga (npr. včerajšnja menjava jezika). Profil ni atomarna vsebina, ampak več
neodvisnih nastavitev v eni vrstici — LWW na ravni vrstice ga ne opiše.

### Smer popravka (izbrana 2026-07-29)

Zlij profil **po stolpcih** ob prijavi, po vzorcu, ki že obstaja za privzeti vrt
(`reconcile_default_garden.dart`):

1. `claimLocalRows` **izpusti `profiles`** (gostova vrstica ostane `local`, push je ne pošlje).
2. Po pull-u steče zlivanje: za vsak stolpec vzemi gostovo vrednost **samo tam, kjer je oblačna prazna**,
   sicer obdrži oblačno; nato gostovo vrstico pobriši.
3. Idempotentno in crash-safe (isto pravilo kot reconcile: delni tek ne sme ničesar izgubiti).

Ocena: ~30–40 vrstic + unit testi (`Clock` je že injektabilen).

### Sorodno: zakleni invarianto »ena vrstica profila«

Odkrito ob istem pregledu, **ni bug** — nezaklenjena predpostavka. `watchGardenCell()`
(`location_repository.dart:99`) ne bere po `user_id`, ampak »najnovejšo vrstico po `updated_at`, limit 1«.
Danes je to pravilno, ker dve vrstici hkrati ne moreta obstajati (odjava briše `profiles`
`app_database.dart:67`, claim preimenuje, pull upserta po istem ključu) — a predpostavko vzdržujejo tri
ločena mesta in nikjer ni preverjena. Komentar v kodi jo sam relativizira (*»even if a stray duplicate
were ever present«*).

FR-22 stoji točno na tej poizvedbi: od nje je odvisno, ali se poziv za lokacijo pokaže. Zato **test**, ki
prehode (gost → prijava → odjava → prijava) prehodi in po vsakem preveri `count(*) from profile <= 1`.
Branja po `user_id` **namenoma ne uvajamo**: `user_id` se ob prijavi spremeni takoj, claim pa vrstico
preimenuje šele v naslednjem sync ciklu — vmes bi poizvedba vrnila nič in povabilo bi za trenutek
utripnilo, čeprav je lokacija nastavljena.

### Verifikacija po popravku

- Unit testi zlivanja: gost ima lokacijo + oblak nima → obdrži gostovo; oba imata → obdrži oblačno;
  gost ima lokacijo, oblak jezik → obdrži oba.
- Test invariante (zgoraj), `flutter test` v celoti.
- Ročno na napravi: gost nastavi lokacijo → prijava v račun z drugo lokacijo → preveri, katera ostane.

---

## BUG-004 — Navigator `keyReservation` assertion (podvojen shell page key) ob tapu opravila iz zaslona nad shell-om

- **Status:** ✅ razrešen na `main` 2026-06-18 — portan M11 vzorec: dodana top-level sestra `/task/:id` (`task-view`) v `app_router.dart`; `plant_detail_screen.dart` (`_HistoryRow.onTap`) zdaj potiska `task-view` namesto `task-detail`. Regresijski test `test/app/task_view_route_test.dart` (task-view se odpre nad shell-om brez podvojenega ključa); 222/222, analyze čist. Klicalci znotraj shell-a (home/journal/tasks) ostajajo na `task-detail`. (Prej: delno razrešen na `feat/m11-smart-engine` commit `b9e5b3f`.)
- **Najden:** 2026-06-15 (Sentry, environment `development`, M11 e2e preverba)
- **Resnost:** srednja — v **debug** buildu rdeč zaslon (crash); v **release** se assertion odstrani (`assert`-only), a podvojen page key vodi v napačno/neuspešno navigacijo. Testerji na release APK tega ne vidijo kot crash.
- **Sentry issue:** `7dd1ff282b4a4463903016b5056885a5` (2026-06-15 19:35:10 UTC)

### Napaka

```
AssertionError: 'package:flutter/src/widgets/navigator.dart': Failed assertion:
line 4068 pos 18: '!keyReservation.contains(key)': is not true.
  navigator.dart:4068  NavigatorState._debugCheckDuplicatedPageKeys.<fn>
  navigator.dart:4134  NavigatorState._updatePages.<fn>
  ...
```

`_debugCheckDuplicatedPageKeys` se izvaja samo znotraj `assert(...)` → **debug/profile-only crash** (zato `environment=development`).

### Vzrok

Zasloni, ki živijo **NAD** `StatefulShellRoute` (top-level rute: `/plant/:id`, M11 suggestion-history),
so potiskali **shell-gnezdeno** ruto `/tasks/:id` (`task-detail`) prek `pushNamed('task-detail', …)`.
Push gnezdene rute znova zgradi že priklopljeno shell stran → **dva `Page`-a z istim page keyem** v
Navigatorju → `keyReservation` assertion.

Originalni Sentry dogodek je bil sprožen prek M11 »Pretekli predlogi« (ni na `main`), a **isti vzorec
živi na `main`** prek zgodovine opravil v podrobnostih rastline:

- `lib/features/plants/presentation/plant_detail_screen.dart:216` — `_HistoryRow.onTap` → `context.pushNamed('task-detail', …)`
- `/plant/:id` je top-level ruta (nad shell-om; `lib/app/router/app_router.dart:131`)
- **Ponovitev na `main`:** odpri rastlino → tapni opravilo v njeni zgodovini → crash (debug).

### Smer popravka (vzorec že potrjen na M11 branchu)

Port commita `b9e5b3f` na `main` (ali počakaj na merge M11). Konkretno:

- V `app_router.dart` dodaj top-level sestro `/task/:id` (`name: 'task-view'`), ki renderira isti
  `TaskDetailScreen` full-screen (brez bottom nav).
- Klicalci **nad shell-om** (`plant_detail_screen.dart`, M11 suggestion-history) → `pushNamed('task-view', …)`.
- Klicalci **znotraj shell-a** (`tasks_screen` ipd.) ostanejo na `task-detail` (bottom nav ostane viden).

### Verifikacija po popravku

- `flutter analyze` čist; obstoječi widget testi (plant-detail / suggestion-history) na `task-view`.
- Ročno na napravi (debug build): rastlina z zgodovino opravil → tapni opravilo → odpre se brez rdečega zaslona.

---

## BUG-003 — gost ima »Odjava« + logout tiho izbriše nesinhronizirane podatke

- **Status:** razrešen (2026-06-10) — »Odjava« skrita za gosta (`email != null`); »Izbriši« za gosta dobi besedilo »Izbriši vse podatke v tej napravi«. Prijavljeni je bil že zaščiten (flush pred `clearUserData`, prekine če offline).
- **Najden:** 2026-06-10 (med internim testom iz Play, Samsung A53 / SM-A536B)
- **Resnost:** visoka — možna **izguba podatkov** (blokator pred zaprtim testom)

### Opis

Med testom (ko Google prijava še ni delala zaradi SHA-1) je uporabnik ostal **gost**, a je
UI vseeno ponujal **»Odjava«**. Ob odjavi je `clearUserData()` pobrisal lokalno drift bazo —
ker gostovi podatki nikoli ne gredo v oblak, so se **nepovratno izgubili**.

### Zahtevano obnašanje (od uporabnika)

1. **Gost nima »Odjava«** — gumb skrit/onemogočen (gost nima seje, nima česa odjaviti).
2. **Logout nikoli ne sme tiho izbrisati nesinhroniziranih podatkov** — vsaj opozorilo
   (»imaš nesinhronizirane podatke« → flush ali potrditev), sicer izguba.

### Vzrok (za preveriti)

Stanje je verjetno postalo zmedeno, ker je Google prijava tiho spodletela (SHA-1 ni bil
registriran) → UI je mislil, da je uporabnik prijavljen → pokazal »Odjava«. **SHA-1 je zdaj
urejen (Google login dela)**, zato je treba preveriti, ali se bug še pojavi v normalnem toku.
Ne glede na to sta zahtevi 1 in 2 veljavni obrambni popravek.

### Smer popravka (predlog, NE implementirano)

- V `settings` profil/logout: gate na `AuthService.email == null` (gost) → »Odjava« skrita.
- Pred `clearUserData()` ob odjavi: `flushPush()` (vzorec že obstaja za e-poštno prijavo,
  glej [[tendask-work-status]] »BUG REŠEN logout→login«) ali potrditveni dialog, če je flush neuspešen (offline).

---

## BUG-002 — po prijavi (in logout→login) vedno vpraša za lokacijo, čeprav je že nastavljena

- **Status:** razrešen (2026-06-10) — nov helper `goToLocationOrHome` (`features/auth/presentation/post_sign_in_navigation.dart`): po prijavi/gostu gre na `/home`, če `gardenCoordinates()` obstaja (device-local), sicer na `/location`. Uporabljen na vseh 3 mestih (Google, e-pošta, gost). Po logoutu koordinate po zasnovi izginejo → takrat gre na `/location`, ki pa ima preskočni gumb »Nadaljuj« (ni prisilen).
- **Najden:** 2026-06-10 (interni test iz Play, Samsung A53 / SM-A536B)
- **Resnost:** srednja — odvečen korak, slaba izkušnja; ni izgube podatkov

### Opis

Po `logout` → `login` (Google) aplikacija znova zahteva **izbiro lokacije**, čeprav ima profil
lokacijo verjetno že shranjeno.

### Vzrok

Po **vsaki** prijavi koda **brezpogojno** navigira na `/location`, brez preverbe, ali je lokacija
že nastavljena:

- `lib/features/auth/presentation/login_screen.dart:48` — po Google prijavi `context.go('/location')`
- `lib/features/auth/presentation/email_login_screen.dart:86` — po e-poštni prijavi `context.go('/location')`
- `lib/features/auth/presentation/login_screen.dart:35` — gost: `context.go('/location')`

Dodatna nianса: lokacija se hrani kot **surove koordinate v `device_location`** (lokalna-only
tabela, se **NE** sinhronizira, ob logoutu jo `clearUserData()` pobriše). V oblak gre samo **H3
celica** (`profile.h3_r7/r6/r5`). Zato tudi state-aware preverba na `device_location` ne bi pomagala
po logout→login — koordinate se po zasnovi ne vrnejo (zasebnost). Preverba mora upoštevati
**`profile.h3` (sinhronizirano)** ali pa naj bo korak preskočljiv.

### Smer popravka (predlog, NE implementirano)

Po prijavi **preveri, ali je lokacija že nastavljena** (npr. `profile.h3_r7 != null` — sinhronizirano,
ali `device_location` obstaja) → če je, pojdi naravnost na `/home`, sicer na `/location`. Ker surove
koordinate po logoutu po zasnovi izginejo, razmisli: ali korak preskočiš (vreme pade na zadnje znano/
privzeto, dokler uporabnik sam ne nastavi) ali ga pokažeš kot **neobvezen** (»Preskoči«), ne prisilen.

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
