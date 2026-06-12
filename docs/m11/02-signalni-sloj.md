# Poglavje 2 — Signalni sloj: točna specifikacija

> Pravila ne berejo surovih virov; berejo **normalizirane signale**. Signalni sloj živi v Edge
> Function `smart-engine` (TypeScript, Deno) kot objekt `Signals`, zgrajen enkrat na uporabnika
> na tek. Imena signalov so camelCase; tu so navedena kot `skupina.ime`.

## A) Vremenski signali (Open-Meteo, strežniško, per H3-celica)

Vir: **en** klic Forecast API na **centroid uporabnikove r7 celice** (`h3-js: cellToLatLng`),
kjer rezultat keširamo v `weather_cache(h3_r7, date)` — uporabniki v isti celici delijo klic.

Klic (točen):
```
GET https://api.open-meteo.com/v1/forecast
  ?latitude={lat}&longitude={lon}
  &hourly=temperature_2m,precipitation,wind_speed_10m,soil_temperature_6cm
  &daily=temperature_2m_min,precipitation_sum
  &past_days=3&forecast_days=3&timezone=auto
```

> `past_days=3` (ne 2): okno `recentRainMm72h` mora biti ob jutranjem teku v celoti pokrito —
> z 2 obstaja le ~55 h zgodovine in dež izpred 56–72 h bi tiho štel 0 (pregled M11.8).

| Signal | Tip / enota | Izračun | Osveževanje | Primer rabe v pravilu |
|---|---|---|---|---|
| `weather.forecastDryHours` | `int`, ure | št. zaporednih ur od `now` z `hourly.precipitation < 0.1 mm` (cap 48) | ob vsakem teku (cache 1 dan po celici) | R1: `forecastDryHours >= 24` |
| `weather.recentRainMm24h` | `double`, mm | vsota `hourly.precipitation` za zadnjih 24 h (iz `past_days`) | isto | R1 guard: `recentRainMm24h < 2.0` |
| `weather.recentRainMm72h` | `double`, mm | vsota za zadnjih 72 h | isto | guard `drought7d` aproksimacija (gl. op. 1) |
| `weather.soilTempC` | `double`, °C | povprečje `soil_temperature_6cm` za naslednjih 24 h | isto | guard `soil_gt_8`: `soilTempC > 8` |
| `weather.windSpeedKmh` | `double`, km/h | max `wind_speed_10m` v dnevnem oknu 08–20 h danes | isto | guard `wind_lt_15`: `windSpeedKmh < 15` |
| `weather.minTempC48h` | `double`, °C | min **hourly** `temperature_2m` naslednjih 48 h (dnevni min bi zajel že mimo jutranjo pozebo + dan+2 do ~72 h — pregled M11.8) | isto | guard `no_frost_forecast_48h`: `minTempC48h > 0` |
| `weather.maxTempCToday` | `double`, °C | max `temperature_2m` danes 08–20 h | isto | guard `temp_lt_30` |

> **Op. 1:** `drought7d` (suša ≥ 7 dni) iz forecast API-ja ni neposredno izračunljiva
> (`past_days` max 92, a tovor raste). MVP aproksimacija: `recentRainMm72h < 2.0` IN
> `forecastDryHours >= 24` (konservativno; kalibracija → `10-odprta-vprasanja.md` #3).
> **Op. 2:** če Open-Meteo odpove (po 3 poskusih z backoffom 1 s/3 s/9 s), se vremenski signali
> postavijo na `null` → vsa pravila z vremenskim SPROŽILCEM (R1) se preskočijo, pravila z
> vremensko STRAŽO pa se preskočijo le, če straža potrebuje manjkajoči signal (fail-closed:
> raje brez predloga kot predlog ob neznanem vremenu). Tek se NE prekine.
> **Op. 3 — uporabnik BREZ lokacije ≠ izpad:** če je `profile.h3_r7 = null`, vreme ni
> »začasno nedosegljivo«, ampak **trajno neznano** — fail-closed bi trajno ugasnil večino
> pravil (skoraj vsa R5 imajo guard). ODLOČITEV: za uporabnika brez lokacije se
> `weather_guard` straže PRESKOČIJO (kot pri zaščitenem subjektu), R1 (vremenski sprožilec)
> se preskoči, frost sidra padejo na `frost_defaults`; engine doda param
> `no_location: true` → predloga sporočila doda »preveri vreme« pripis, klient pa v
> Settings/pas footer pokaže »nastavi lokacijo za natančnejše predloge«
> (`suggestions.no_location_hint`).

## B) Klimatski signali (iz `profile.climate_profile`, izračunan na napravi — gl. `07`)

| Signal | Tip / enota | Izračun | Osveževanje | Primer rabe |
|---|---|---|---|---|
| `climate.lastFrostDate` | `Date` (letošnje leto) | `frost_last_spring_doy` (mediana, gl. 07.3) → datum letos, **+ kFrostSafetyDays (7)** | ob nastavitvi lokacije; re-fetch > 365 dni | R5 frost_offset: `today >= lastFrostDate - 56d` |
| `climate.firstFrostDate` | `Date` (letošnje leto) | `frost_first_autumn_doy` → datum letos, **− kFrostSafetyDays (7)** | isto | `overwinter`: `today >= firstFrostDate - 28d` |
| `climate.bucket` | `string` (npr. `"e1_t5"`) | `profile.climate_bucket` | isto | R5 `climate_bucket_filter`; V2 vedro |
| `climate.lastFrostWeek` / `firstFrostWeek` | `int` ISO teden | iz zgornjih datumov | isto | regionalizacija `month_window` (01 §0) |
| `climate.growingSeasonDays` | `int`, dnevi | `firstFrostDoy − lastFrostDoy` | isto | informativno v sporočilih |

Fallback brez profila (offline ob registraciji, lokacija ni nastavljena):
`kDefaultLastFrostDoy = 110` (20. apr), `kDefaultFirstFrostDoy = 293` (20. okt), bucket `null`
(→ `climate_bucket_filter` pravila z ne-null filtrom se preskočijo). Konstanti v `app_config`
(strežnik) IN `core/config.dart` (klient, za UI namige).

## C) Zgodovinski signali (iz `task` + `task_subject`, strežniško per uporabnik)

Definicija »izvedba«: `task.status='done' AND deleted=false`. Datum = `task.date` v
uporabnikovem lokalnem dnevu (`profile.timezone`).

| Signal | Tip | Izračun | Primer rabe |
|---|---|---|---|
| `history.lastDone(subjectKey, taskTypeId)` | `Date?` | max(date) izvedb tipa za subjekt; za `ar:` subjekt match po `task_subject.area_id`, za `up:` po `user_plant_id` | R2, R3, cooldown straža |
| `history.lastDoneAnySubject(taskTypeId)` | `Date?` | max(date) izvedb tipa ne glede na subjekt | R2 za opravila brez subjekta |
| `history.cadenceDays(subjectKey, taskTypeId)` | `double?` | mediana razmikov (dni) zadnjih **5** izvedb; `null` če < 3 izvedbe → fallback `task_type.default_cadence` (int, dnevi); če tudi ta null → signal null | R3: `daysSince > cadenceDays * 1.25` |
| `history.chainStepDate(subjectKey, stepTypeId)` | `Date?` | datum zadnje izvedbe koraka verige za ta subjekt **v tekoči sezoni** (koledarsko leto) | R7 + `growth_stage` anchor |
| `history.lastDoneYearAgo(subjectKey, taskTypeId)` | `Date?` | izvedba z datumom v [danes−1 leto−7 d, danes−1 leto+7 d] | R2 obletnica |

## D) Zaloge (iz `supply` + `task_supply`) — aktivno šele, ko `kSuppliesEnabled=true`

| Signal | Tip | Izračun | Primer rabe |
|---|---|---|---|
| `inventory.suppliesForTaskType(taskTypeId)` | `List<Supply>` | DISTINCT `supply` vrstice, vezane prek `task_supply` na uporabnikova PRETEKLA done opravila tega tipa (zadnjih 5) | R4: katera sredstva ta uporabnik tipično rabi za ta tip |
| `inventory.hasSupply(supplyId)` | `bool` | `supply.quantity > COALESCE(low_threshold, 0)` AND `deleted=false` | R4: nizka zaloga |

## E) Upravičenost (iz `area`, `user_plant`)

| Signal | Tip | Izračun | Primer rabe |
|---|---|---|---|
| `eligibility.areasByType(type)` | `List<Area>` | `area WHERE type=? AND deleted=false` | trata-pravila: `areasByType('lawn').isNotEmpty` |
| `eligibility.plantsByCategory(category)` | `List<UserPlant>` | `user_plant JOIN plant ON plant_id WHERE plant.category=? AND deleted=false` (custom rastline IZKLJUČENE — ni kanonične kategorije) | kategorijska pravila → subjekti |
| `eligibility.plantsById(plantId)` | `List<UserPlant>` | `user_plant WHERE plant_id=? AND deleted=false` | plant-override pravila → subjekti |
| `eligibility.protectedAreas` | `Set<areaId>` | `area WHERE protected=true` | preskok weather_guard: subjekt `up:` je zaščiten, če `user_plant.area_id ∈ protectedAreas` |

## F) Stanje predlogov (iz `task` waiting + `suggestion_log` + `suggestion`)

| Signal | Tip | Izračun | Primer rabe |
|---|---|---|---|
| `state.planned(subjectKey, taskTypeId, withinDays)` | `bool` | obstaja `task` `status='waiting' AND deleted=false` istega tipa z istim subjektom in `date ∈ [today, today+withinDays]` | dedup straža (withinDays=14) |
| `state.reminderExists(subjectKey, taskTypeId, withinDays)` | `bool` | kot `planned`, a task ima ≥1 `task_reminder` | dedup proti plasti A (vsebovan v `planned` — opomnik visi na tasku; ločen signal za telemetrijo) |
| `state.dismissed(guardKey, subjectKey)` | `bool` | `suggestion_log.dismissed_until > now()` (guard key → `03` §Guard key) | straža Opusti |
| `state.lastSuggestedAt(guardKey, subjectKey)` | `DateTime?` | `suggestion_log.last_suggested_at` | cooldown predloga |
| `state.activeSuggestion(taskTypeId, subjectKey)` | `bool` | obstaja `suggestion` `status='new' AND valid_until >= today` istega TIPA za isti subjekt (ne glede na pravilo) | cross-run dedup (straža 5f) |

## G) Slovar `weather_guard` kod (strojno-berljive straže iz Poglavja 1)

Guard se vrednoti kot **konjunkcija** kod (`"dry24h,wind_lt_15"` = obe). Neznana koda → guard
fail-closed (pravilo se ne sproži) + Sentry opozorilo (tolerantni parser, a viden signal).
Za subjekt v **zaščitenem območju** se CELOTEN guard preskoči (`frost_gate` pa NE — gl.
`pametni-motor.md` §2.2). Enak preskok velja za uporabnika **brez lokacije** (op. 3 zgoraj —
trajno neznano vreme ≠ izpad).

| Koda | Pogoj |
|---|---|
| `dry12h` | `forecastDryHours >= 12` |
| `dry24h` | `forecastDryHours >= 24` |
| `no_rain_forecast_24h` | vsota napovedanih padavin naslednjih 24 h `< 1.0 mm` |
| `no_rain_forecast_48h` | vsota naslednjih 48 h `< 2.0 mm` |
| `no_heavy_rain_24h` | vsota naslednjih 24 h `< 10 mm` |
| `wind_lt_15` / `wind_lt_20` | `windSpeedKmh < 15 / 20` |
| `temp_gt_0` / `temp_gt_5` | `minTempC48h > 0 / 5` |
| `temp_lt_30` | `maxTempCToday < 30` |
| `soil_gt_8` / `soil_gt_10` / `soil_gt_12` | `soilTempC > 8 / 10 / 12` |
| `soil_moist` | `recentRainMm72h >= 5` AND `recentRainMm24h < 15` |
| `no_frost_forecast_48h` | `minTempC48h > 0` |
| `drought7d` | aproksimacija — gl. op. 1 zgoraj |

Pragovi (odločitev ob pregledu M11.8): koda s **številko v imenu** (`dry12h`, `dry24h`,
`wind_lt_15/20`, `temp_gt_0/5`, `temp_lt_30`, `soil_gt_8/10/12`, 15 mm v `soil_moist`) je
**fiksen literal** — ime kode je pogodba, vidna v `plant_task_rule.weather_guard` vrsticah.
Samo pragove brez številke v imenu (`no_rain_forecast_*`, `no_heavy_rain_24h`, `soil_moist`
72-urni mm, `drought7d`) drži `app_config.weather_thresholds` (server-nastavljivo brez deploya).
Dež-vsote so fail-closed: okno, ki ga payload ne pokrije v celoti (null ure, star cache), → signal
`null` → guard pade.
