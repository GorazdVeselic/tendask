# Poglavje 7 — Open-Meteo klimatski profil (`profile.climate_profile` + `climate_bucket`)

> Računa **naprava** (zasebnost: koordinate ne zapustijo naprave; klic gre na **centroid r7
> celice**, ne na surovi GPS). Rezultat: bogat owner-only `climate_profile` (jsonb) + grob javni
> `climate_bucket`.

## 7.1 Točni API klici

**En sam klic** — Historical Weather API (ERA5 reanaliza, brez ključa), 10 polnih let dnevnih
minimumov + povprečij. ERA5 ima ~5-dnevni zamik → `end_date` = 31. dec. lanskega leta
(cele sezone, stabilen rezultat skozi vse leto):

```
GET https://archive-api.open-meteo.com/v1/archive
  ?latitude={lat}&longitude={lon}          // h3 cellToLatLng(profile.h3_r7) centroid!
  &start_date={YYYY}-01-01                 // YYYY = lansko leto - 9 (10 celih let)
  &end_date={YYYY+9}-12-31
  &daily=temperature_2m_min,temperature_2m_mean
  &timezone=auto
```

- Odgovor vsebuje tudi **`elevation`** (m) in **`timezone`** (IANA) → oboje uporabimo
  (timezone → `profile.timezone`; en klic pokrije vse).
- Velikost: 2 polji × ~3650 dni ≈ 60 kB JSON — sprejemljivo (enkraten klic ob nastavitvi
  lokacije, prek obstoječega dio klienta z `kWeatherRetryDelays` backoffom).
- **Climate API (climate-api.open-meteo.com) NE uporabimo:** vrača projekcije klimatskih
  modelov (CMIP6), ne merjenih normalov; frost datumov neposredno ne ponuja noben Open-Meteo
  endpoint → vedno jih izpeljemo iz dnevnega arhiva (odgovor na vprašanje iz
  `skupnost-agregacija.md` §11).

## 7.2 Algoritem `climate_bucket` (grob javni koš)

```
elevationBand(e):  e1: < 300 m · e2: 300–599 · e3: 600–899 · e4: >= 900
tempBand(tAnnualMean):  t1: < 4 °C · t2: 4–5.9 · t3: 6–7.9 · t4: 8–9.9 · t5: 10–11.9 · t6: >= 12
climate_bucket = '<elevationBand>_<tempBand>'      // npr. Ljubljana ≈ 'e1_t5'
```
- `tAnnualMean` = povprečje vseh `temperature_2m_mean` čez 10 let.
- Višinska os ostane kljub korelaciji s temperaturo (mikroklima: mraziščne doline, pobočja) —
  morebitna redundanca se pretehta ob realnih podatkih (gl. 10 #4).
- 4 × 6 = 24 možnih košev; v praksi CE Evropa pade v ~8 → dovolj gostote na koš (V2 fallback).

## 7.3 Algoritem frost datumov

```
za vsako leto y v 10 letih:
  lastFrostDoy(y)  = max DOY v [1. jan, 30. jun] z temperature_2m_min <= 0.0 °C   (null, če ni)
  firstFrostDoy(y) = min DOY v [1. jul, 31. dec] z temperature_2m_min <= 0.0 °C   (null, če ni)

frost_last_spring_doy  = mediana ne-null lastFrostDoy   (null, če > 5 let brez pozebe → frost-free)
frost_first_autumn_doy = mediana ne-null firstFrostDoy  (enako)
growing_season_days    = frost_first_autumn_doy - frost_last_spring_doy   (null, če katerikoli null)
```
- **Mediana, ne povprečje** (odporna na ekstremno leto). Prestopna leta: DOY računamo z dnem
  v ne-prestopnem koledarju (29. feb → DOY 59.5 zaokrožen na 60) — napaka ±1 dan je pod šumom.
- Varnostni rob `kFrostSafetyDays = 7` aplicira MOTOR ob branju (02 §B), ne shramba —
  shranimo surovo mediano (re-kalibracija brez re-fetcha).
- Frost-free lokacije: motor pade na `app_config.frost_defaults` SAMO za `month_window`
  regionalizacijo; `frost_offset` pravila se za frost-free koš preskočijo z izjemo
  `first_frost` pravil (prezimovanje ni potrebno → pravilno je nič).

## 7.4 Oblika `climate_profile` (jsonb, owner-only)

```json
{
  "elevation_m": 295,
  "t_annual_mean_c": 10.8,
  "temp_monthly_normals_c": [-0.1, 1.4, 5.8, 10.4, 15.1, 18.9, 20.8, 20.3, 15.7, 10.6, 5.2, 0.8],
  "frost_last_spring_doy": 108,
  "frost_first_autumn_doy": 295,
  "growing_season_days": 187,
  "precip_annual_mm": null,
  "koppen": null,
  "captured_at": "2026-06-11T08:00:00Z",
  "source": "open-meteo-era5-10y"
}
```
`precip_annual_mm`/`koppen` = rezervirana NULL polja (tolerantni parser; dopolnimo ob potrebi
brez migracije). `temp_monthly_normals_c` = 12 povprečij po mesecih čez 10 let.

## 7.5 Kdaj se kliče

| Trenutek | Kaj |
|---|---|
| **Nastavitev/sprememba lokacije** (onboarding korak ali Settings → Lokacija) | po izračunu H3 celic: fetch → izračun → zapis `climate_profile` + `climate_bucket` + `timezone` v drift profile (sync push standardno) |
| **Zagon aplikacije** (po splashu, fire-and-forget) | če `h3_r7 != null` IN (`climate_profile == null` ALI `captured_at` > 365 dni) → tihi re-fetch (normali se spreminjajo počasi; enkrat letno dovolj) |
| **Odstranitev lokacije** (`clearGardenLocation`) | počisti tudi `climate_profile`, `climate_bucket`, `timezone` (obstoječa metoda se razširi) |

Implementacija: `LocationRepository` (obstoječi) dobi `ClimateService` korak —
`core/location/climate_service.dart`, čista funkcija
`ClimateProfile computeClimateProfile(ArchiveResponse r)` (unit-testabilna, `Clock` ni
potreben — vhod so zgodovinski podatki) + dio fetch z obstoječim retry vzorcem.

## 7.6 Graceful offline fallback

- Fetch ne uspe (vrt brez signala ob onboardingu): lokacija + H3 + timezone (iz
  `flutter_timezone`, deluje offline) se shranijo TAKOJ; `climate_profile`/`climate_bucket`
  ostaneta `null`; ob naslednjem zagonu z mrežo se tiho dopolnita (7.5 vrstica 2).
- Motor brez profila: `frost_defaults` iz `app_config` (teden 16/43 ekvivalent) +
  `climate_bucket_filter` pravila preskočena + regionalizacija Δ=0. Predlogi so torej
  »privzeto-srednjeevropski« — pravilno za ciljni trg, konservativno drugje.
- V2 agregat: `climate_bucket = null` → dogodki uporabnika ne padejo v `climate` vedro
  (r7/r6/r5 vedra delujejo normalno); `COALESCE` v `agg_event` to že pokrije.
- UI nikoli ne kaže surovih frost datumov kot obljubo — vedno »tipično okno« (disclaimer
  na pasu: `suggestions.disclaimer` i18n ključ, viden v footerju pasu).
