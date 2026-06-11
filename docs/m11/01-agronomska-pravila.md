# Poglavje 1 — Agronomska pravila: popolna vsebina `plant_task_rule`

> To je **kurirana vsebina** (seed) tabele `plant_task_rule` (shema → `04-supabase-shema.md` §4.2).
> Vsako pravilo ima `source_ref` (revizijska sled). Kjer vir ni 100 % potrjen, je označen
> **(verify)** — pred seedom korak M11.4 vsak (verify) vir odpre in potrdi/zamenja; pravila brez
> potrjenega vira se NE seedajo (`pametni-motor.md` §2.4).

## 0. Regionalizacija oken (velja za vsa pravila)

- Tedni so **ISO tedni** in veljajo za **privzeti klimatski koš** (Cfb nižina srednje Evrope):
  zadnja spomladanska pozeba ≈ **teden 16** (~20. apr), prva jesenska ≈ **teden 43** (~20. okt).
- Motor `month_window` regionalizira s premikom:
  - okna s `start_week ≤ 26` (pomladanska) premakne za `Δ = userLastFrostWeek − 16` tednov,
  - okna s `start_week ≥ 27` (jesenska) premakne za `Δ = userFirstFrostWeek − 43` tednov,
  - `Δ` se obreže na razpon **[−4, +4]** tednov (varovalo pred ekstremnimi koši).
  - Pozimska okna obreza (start_week ≤ 6) se NE premikajo (mirovanje ni frost-občutljivo).
    Tehnično: `window.regionalize: 'spring' | 'autumn' | 'none'` (privzeto izpeljano iz
    start_week po zgornjih mejah; eksplicitno polje override-a).
- `frost_offset` in `growth_stage` pravila se regionalizirajo sama (sidro je lokalen podatek).
- `climate_bucket_filter` (seznam košev ali `null` = vsi) MVP pušča `null` povsod; predviden je
  za kasnejše izjeme (npr. sredozemski koš).
- `window` JSON sheme po anchorju (dokončno):
  ```json
  // month_window
  {"start_week": 6, "end_week": 12, "climate_bucket_filter": null, "regionalize": "none"}
  // frost_offset (dnevi; negativno = PRED sidrom)
  {"anchor": "last_frost", "offset_min_days": -56, "offset_max_days": -42}
  // growth_stage (dnevi PO zadnjem opravljenem koraku after_event)
  {"after_event": "start_seedlings", "offset_min_days": 14, "offset_max_days": 21}
  // cadence_only (+ neobvezna sezonska omejitev v ISO tednih)
  {"min_days_since_last": 5, "max_days_since_last": 10,
   "season_start_week": 12, "season_end_week": 46}
  ```
- `cadence` je opisno besedilo (EN) za UI/revizijo; strojna logika bere SAMO `window`.
- `rule_id` (PK) = `<ref_id>.<task_type_id>[.<qualifier>]` — stabilen slug, add-only (kot katalog).
- `weather_guard` je strojno-berljiv niz iz nabora straž v `02-signalni-sloj.md` §G (npr.
  `"dry24h,no_rain_forecast_24h"`), tu zapisan opisno + s kodo.

Kategorije (= `plant.category` v `catalog_seed.dart`): `lawn`, `fruit_tree`, `berries`,
`vegetable`, `herbs`, `perennial`, `shrub`, `climber`, `bulb`, `conifer`, `hedge`, `houseplant`.
MVP pokrije kategorije spodaj; `perennial`/`climber`/`bulb` pridejo v kasnejši kuracijski rundi
(zavestno izpuščene — premalo zanesljivih splošnih pravil na nivoju kategorije).

---

## A) Pravila po KATEGORIJI

### A.1 Trata (`lawn`)

```
rule_id: lawn.mow
scope: category | ref_id: lawn | task_type_id: mow
timing_anchor: cadence_only
window: {"min_days_since_last": 5, "max_days_since_last": 10, "season_start_week": 12, "season_end_week": 46}
cadence: weekly in season
frost_gate: false
weather_guard: "dry, grass not wet (dry12h)" → code: dry12h
source_ref: "RHS – Lawns: mowing (rhs.org.uk/lawns/mowing)"
confidence: visoka
message_key: "suggestions.lawn.mow_due"
```

```
rule_id: lawn.fertilize.spring
scope: category | ref_id: lawn | task_type_id: fertilize
timing_anchor: month_window
window: {"start_week": 13, "end_week": 18, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: 1x/year (spring feed, N-rich)
frost_gate: false
weather_guard: "soil > 8 °C, no heavy rain forecast 24h" → code: soil_gt_8,no_heavy_rain_24h
source_ref: "RHS – Lawns: spring and summer care (rhs.org.uk/lawns/spring-summer-care)"
confidence: visoka
message_key: "suggestions.lawn.fertilize_spring"
```

```
rule_id: lawn.fertilize.autumn
scope: category | ref_id: lawn | task_type_id: fertilize
timing_anchor: month_window
window: {"start_week": 36, "end_week": 41, "climate_bucket_filter": null, "regionalize": "autumn"}
cadence: 1x/year (autumn feed, K-rich, low N)
frost_gate: false
weather_guard: "dry application day" → code: dry12h
source_ref: "RHS – Lawns: autumn care (rhs.org.uk/lawns/autumn-care)"
confidence: visoka
message_key: "suggestions.lawn.fertilize_autumn"
```

```
rule_id: lawn.scarify.autumn
scope: category | ref_id: lawn | task_type_id: scarify
timing_anchor: month_window
window: {"start_week": 36, "end_week": 39, "climate_bucket_filter": null, "regionalize": "autumn"}
cadence: 1x/year (primary window)
frost_gate: false
weather_guard: "soil moist, not waterlogged; grass actively growing" → code: dry12h
source_ref: "RHS – Lawns: autumn care (rhs.org.uk/lawns/autumn-care)"
confidence: visoka
message_key: "suggestions.lawn.scarify_autumn"
```

```
rule_id: lawn.scarify.spring
scope: category | ref_id: lawn | task_type_id: scarify
timing_anchor: month_window
window: {"start_week": 14, "end_week": 17, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: optional light pass (only if not done in autumn)
frost_gate: false
weather_guard: "soil moist, lawn growing" → code: dry12h
source_ref: "RHS – Lawns: spring and summer care (rhs.org.uk/lawns/spring-summer-care) (verify spring scarify mention)"
confidence: srednja
message_key: "suggestions.lawn.scarify_spring"
```

```
rule_id: lawn.aerate
scope: category | ref_id: lawn | task_type_id: aerate
timing_anchor: month_window
window: {"start_week": 36, "end_week": 42, "climate_bucket_filter": null, "regionalize": "autumn"}
cadence: 1x/year (compacted lawns 2x)
frost_gate: false
weather_guard: "soil moist, not waterlogged" → code: soil_moist
source_ref: "RHS – Lawns: autumn care (rhs.org.uk/lawns/autumn-care)"
confidence: visoka
message_key: "suggestions.lawn.aerate"
```

```
rule_id: lawn.overseed.spring
scope: category | ref_id: lawn | task_type_id: overseed
timing_anchor: month_window
window: {"start_week": 15, "end_week": 19, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: as needed (bare/thin patches)
frost_gate: false
weather_guard: "soil ≥ 10 °C, moisture available" → code: soil_gt_10
source_ref: "RHS – Lawns: renovation (rhs.org.uk/lawns/renovating) (verify slug)"
confidence: srednja
message_key: "suggestions.lawn.overseed_spring"
```

```
rule_id: lawn.overseed.autumn
scope: category | ref_id: lawn | task_type_id: overseed
timing_anchor: month_window
window: {"start_week": 34, "end_week": 38, "climate_bucket_filter": null, "regionalize": "autumn"}
cadence: 1x/year (primary window — warm soil + autumn moisture)
frost_gate: false
weather_guard: "soil ≥ 10 °C" → code: soil_gt_10
source_ref: "RHS – Lawns: autumn care (rhs.org.uk/lawns/autumn-care)"
confidence: visoka
message_key: "suggestions.lawn.overseed_autumn"
```

```
rule_id: lawn.topdress
scope: category | ref_id: lawn | task_type_id: topdress
timing_anchor: month_window
window: {"start_week": 36, "end_week": 40, "climate_bucket_filter": null, "regionalize": "autumn"}
cadence: 1x/year (after scarifying/aeration)
frost_gate: false
weather_guard: "dry application day" → code: dry12h
source_ref: "RHS – Lawns: autumn care / top dressing (rhs.org.uk/lawns/topdressing) (verify slug)"
confidence: visoka
message_key: "suggestions.lawn.topdress"
```

```
rule_id: lawn.roll
scope: category | ref_id: lawn | task_type_id: roll
timing_anchor: month_window
window: {"start_week": 12, "end_week": 15, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: 1x/year (spring, after frost heave)
frost_gate: false
weather_guard: "soil moist, NOT waterlogged" → code: soil_moist
source_ref: "DE Rasengesellschaft / gartenakademie.rlp.de – Rasen walzen im Frühjahr (verify)"
confidence: srednja
message_key: "suggestions.lawn.roll"
```

```
rule_id: lawn.lime
scope: category | ref_id: lawn | task_type_id: lime
timing_anchor: month_window
window: {"start_week": 44, "end_week": 48, "climate_bucket_filter": null, "regionalize": "autumn"}
cadence: every 2–3 years, only if soil pH < ~5.5 (message says 'check pH first')
frost_gate: false
weather_guard: "dry application day" → code: dry12h
source_ref: "LWK / gartenakademie.rlp.de – Rasen kalken (verify); RHS – Lime and liming (verify)"
confidence: srednja
message_key: "suggestions.lawn.lime"
```

```
rule_id: lawn.lawn_weed_moss.moss
scope: category | ref_id: lawn | task_type_id: lawn_weed_moss
timing_anchor: month_window
window: {"start_week": 12, "end_week": 16, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: 1x/year (moss control before scarifying)
frost_gate: false
weather_guard: "moist lawn, no rain 24h after application" → code: no_rain_forecast_24h
source_ref: "RHS – Moss on lawns (rhs.org.uk/lawns/moss-on-lawns)"
confidence: visoka
message_key: "suggestions.lawn.moss_control"
```

```
rule_id: lawn.lawn_weed_moss.weed
scope: category | ref_id: lawn | task_type_id: lawn_weed_moss
timing_anchor: month_window
window: {"start_week": 18, "end_week": 24, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: 1x/year (weeds in active growth)
frost_gate: false
weather_guard: "dry, windless, no rain 24h" → code: dry24h,no_rain_forecast_24h,wind_lt_15
source_ref: "RHS – Lawn weeds (rhs.org.uk/lawns/weeds) (verify slug)"
confidence: srednja
message_key: "suggestions.lawn.weed_control"
```

```
rule_id: lawn.water
scope: category | ref_id: lawn | task_type_id: water
timing_anchor: cadence_only
window: {"min_days_since_last": 5, "max_days_since_last": 10, "season_start_week": 22, "season_end_week": 35}
cadence: only in summer drought; deep, infrequent
frost_gate: false
weather_guard: "dry spell ≥ 7 days, no rain forecast 48h" → code: drought7d,no_rain_forecast_48h
source_ref: "RHS – Lawns: spring and summer care (rhs.org.uk/lawns/spring-summer-care)"
confidence: srednja
message_key: "suggestions.lawn.water_drought"
```

### A.2 Sadno drevje (`fruit_tree`)

```
rule_id: fruit_tree.prune.winter
scope: category | ref_id: fruit_tree | task_type_id: prune
timing_anchor: month_window
window: {"start_week": 2, "end_week": 11, "climate_bucket_filter": null, "regionalize": "none"}
cadence: 1x/year (dormant; pome fruit default — stone fruit overridden per species)
frost_gate: false
weather_guard: "dry, temp > 0 °C, no severe frost" → code: dry12h,temp_gt_0
source_ref: "RHS – Apples and pears: winter pruning (rhs.org.uk/fruit/apples/winter-pruning) (verify slug); KGZS – navodila za zimsko rez sadnega drevja (verify)"
confidence: visoka
message_key: "suggestions.fruit_tree.prune_winter"
```

```
rule_id: fruit_tree.graft.spring
scope: category | ref_id: fruit_tree | task_type_id: graft
timing_anchor: month_window
window: {"start_week": 10, "end_week": 16, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: seasonal (whip/cleft grafting at bud break)
frost_gate: false
weather_guard: "dry, no severe frost" → code: dry12h,temp_gt_0
source_ref: "RHS – Grafting fruit trees (verify); KGZS – cepljenje sadnih rastlin (verify)"
confidence: srednja
message_key: "suggestions.fruit_tree.graft_spring"
```

```
rule_id: fruit_tree.graft.summer_budding
scope: category | ref_id: fruit_tree | task_type_id: graft
timing_anchor: month_window
window: {"start_week": 30, "end_week": 34, "climate_bucket_filter": null, "regionalize": "none"}
cadence: seasonal (T-/chip-budding)
frost_gate: false
weather_guard: "dry day" → code: dry12h
source_ref: "RHS – Budding of fruit trees (verify); KGZS – okuliranje (verify)"
confidence: srednja
message_key: "suggestions.fruit_tree.graft_budding"
```

```
rule_id: fruit_tree.thin_fruit
scope: category | ref_id: fruit_tree | task_type_id: thin_fruit
timing_anchor: month_window
window: {"start_week": 23, "end_week": 27, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: 1x/season (after June drop)
frost_gate: false
weather_guard: NULL
source_ref: "RHS – Fruit: thinning (rhs.org.uk/fruit/thinning-fruit) (verify slug)"
confidence: visoka
message_key: "suggestions.fruit_tree.thin_fruit"
```

```
rule_id: fruit_tree.treat.dormant
scope: category | ref_id: fruit_tree | task_type_id: treat
timing_anchor: month_window
window: {"start_week": 6, "end_week": 11, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: 1x/year (dormant spray — oil/copper before bud break)
frost_gate: false
weather_guard: "dry, windless, temp > 5 °C, no rain 24h" → code: dry24h,no_rain_forecast_24h,wind_lt_15,temp_gt_5
source_ref: "KGZS / IVR – zimsko (mirovalno) škropljenje sadnega drevja (verify)"
confidence: srednja
message_key: "suggestions.fruit_tree.treat_dormant"
```

```
rule_id: fruit_tree.fertilize
scope: category | ref_id: fruit_tree | task_type_id: fertilize
timing_anchor: month_window
window: {"start_week": 10, "end_week": 14, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: 1x/year (late winter / early spring, before growth)
frost_gate: false
weather_guard: NULL
source_ref: "RHS – Fruit trees: feeding and mulching (verify slug)"
confidence: srednja
message_key: "suggestions.fruit_tree.fertilize_spring"
```

```
rule_id: fruit_tree.mulch
scope: category | ref_id: fruit_tree | task_type_id: mulch
timing_anchor: month_window
window: {"start_week": 12, "end_week": 18, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: 1x/year (moist spring soil)
frost_gate: false
weather_guard: "soil moist" → code: soil_moist
source_ref: "RHS – Mulches and mulching (rhs.org.uk/soil-composts-mulches/mulch) (verify slug)"
confidence: srednja
message_key: "suggestions.fruit_tree.mulch"
```

### A.3 Jagodičevje (`berries`)

```
rule_id: berries.prune.winter
scope: category | ref_id: berries | task_type_id: prune
timing_anchor: month_window
window: {"start_week": 6, "end_week": 12, "climate_bucket_filter": null, "regionalize": "none"}
cadence: 1x/year (dormant; currant/gooseberry default — raspberry/blueberry overridden)
frost_gate: false
weather_guard: "dry, no severe frost" → code: dry12h,temp_gt_0
source_ref: "RHS – Blackcurrants: pruning (verify); RHS – Gooseberries: pruning (verify)"
confidence: srednja
message_key: "suggestions.berries.prune_winter"
```

```
rule_id: berries.fertilize
scope: category | ref_id: berries | task_type_id: fertilize
timing_anchor: month_window
window: {"start_week": 10, "end_week": 14, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: 1x/year (early spring)
frost_gate: false
weather_guard: NULL
source_ref: "RHS – Soft fruit: feeding (verify)"
confidence: srednja
message_key: "suggestions.berries.fertilize_spring"
```

```
rule_id: berries.treat.dormant
scope: category | ref_id: berries | task_type_id: treat
timing_anchor: month_window
window: {"start_week": 6, "end_week": 11, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: 1x/year (dormant spray)
frost_gate: false
weather_guard: "dry, windless, no rain 24h" → code: dry24h,no_rain_forecast_24h,wind_lt_15
source_ref: "KGZS – mirovalno škropljenje jagodičevja (verify)"
confidence: srednja
message_key: "suggestions.berries.treat_dormant"
```

```
rule_id: berries.mulch
scope: category | ref_id: berries | task_type_id: mulch
timing_anchor: month_window
window: {"start_week": 12, "end_week": 18, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: 1x/year
frost_gate: false
weather_guard: "soil moist" → code: soil_moist
source_ref: "RHS – Mulches and mulching (verify slug)"
confidence: srednja
message_key: "suggestions.berries.mulch"
```

### A.4 Zelenjava (`vegetable`)

```
rule_id: vegetable.start_seedlings
scope: category | ref_id: vegetable | task_type_id: start_seedlings
timing_anchor: frost_offset
window: {"anchor": "last_frost", "offset_min_days": -56, "offset_max_days": -28}
cadence: seasonal (indoor sowing of warm-season vegetables)
frost_gate: false
weather_guard: NULL (protected area — guards skipped anyway)
source_ref: "RHS – Sowing seeds indoors (rhs.org.uk/propagation/seed-sowing-indoors) (verify slug)"
confidence: srednja
message_key: "suggestions.vegetable.start_seedlings"
```

```
rule_id: vegetable.prick_out
scope: category | ref_id: vegetable | task_type_id: prick_out
timing_anchor: growth_stage
window: {"after_event": "start_seedlings", "offset_min_days": 14, "offset_max_days": 28}
cadence: per chain (at first true leaves)
frost_gate: false
weather_guard: NULL (protected)
source_ref: "RHS – Pricking out seedlings (verify)"
confidence: visoka
message_key: "suggestions.vegetable.prick_out"
```

```
rule_id: vegetable.harden_off
scope: category | ref_id: vegetable | task_type_id: harden_off
timing_anchor: frost_offset
window: {"anchor": "last_frost", "offset_min_days": -14, "offset_max_days": 0}
cadence: once per chain (1–2 weeks before planting out)
frost_gate: false
weather_guard: "no frost forecast 48h" → code: no_frost_forecast_48h
source_ref: "RHS – Hardening off tender plants (verify)"
confidence: visoka
message_key: "suggestions.vegetable.harden_off"
```

```
rule_id: vegetable.transplant
scope: category | ref_id: vegetable | task_type_id: transplant
timing_anchor: frost_offset
window: {"anchor": "last_frost", "offset_min_days": 0, "offset_max_days": 21}
cadence: once per chain (after last frost)
frost_gate: true
weather_guard: "no frost forecast 48h, wind < 20 km/h" → code: no_frost_forecast_48h,wind_lt_20
source_ref: "RHS – Hardening off / planting out tender vegetables (verify)"
confidence: visoka
message_key: "suggestions.vegetable.transplant"
```

```
rule_id: vegetable.sow.direct
scope: category | ref_id: vegetable | task_type_id: sow
timing_anchor: frost_offset
window: {"anchor": "last_frost", "offset_min_days": -14, "offset_max_days": 35}
cadence: seasonal (hardy direct sowings earlier, tender after frost)
frost_gate: false
weather_guard: "soil ≥ 8 °C" → code: soil_gt_8
source_ref: "RHS – Sowing vegetables outdoors (verify)"
confidence: srednja
message_key: "suggestions.vegetable.sow_direct"
```

```
rule_id: vegetable.plant
scope: category | ref_id: vegetable | task_type_id: plant
timing_anchor: frost_offset
window: {"anchor": "last_frost", "offset_min_days": 0, "offset_max_days": 28}
cadence: seasonal (bought seedlings after last frost)
frost_gate: true
weather_guard: "no frost forecast 48h" → code: no_frost_forecast_48h
source_ref: "RHS – Vegetable seedlings: planting out (verify)"
confidence: visoka
message_key: "suggestions.vegetable.plant_out"
```

```
rule_id: vegetable.fertilize
scope: category | ref_id: vegetable | task_type_id: fertilize
timing_anchor: cadence_only
window: {"min_days_since_last": 21, "max_days_since_last": 35, "season_start_week": 18, "season_end_week": 35}
cadence: every 3–5 weeks in season (hungry crops)
frost_gate: false
weather_guard: NULL
source_ref: "RHS – Vegetables: feeding (verify)"
confidence: srednja
message_key: "suggestions.vegetable.fertilize_season"
```

```
rule_id: vegetable.treat
scope: category | ref_id: vegetable | task_type_id: treat
timing_anchor: cadence_only
window: {"min_days_since_last": 14, "max_days_since_last": 9999, "season_start_week": 20, "season_end_week": 35}
cadence: need-driven (rule only re-opens weather window after past treatments — see R1)
frost_gate: false
weather_guard: "dry, windless, no rain 24h" → code: dry24h,no_rain_forecast_24h,wind_lt_15
source_ref: "FURS/IVR – dobra praksa nanosa FFS: suho in brez vetra (verify)"
confidence: srednja
message_key: "suggestions.vegetable.treat_window"
```

### A.5 Zelišča (`herbs`)

```
rule_id: herbs.start_seedlings
scope: category | ref_id: herbs | task_type_id: start_seedlings
timing_anchor: frost_offset
window: {"anchor": "last_frost", "offset_min_days": -42, "offset_max_days": -21}
cadence: seasonal (indoor sowing: basil & tender herbs)
frost_gate: false
weather_guard: NULL (protected)
source_ref: "RHS – Herbs from seed (verify)"
confidence: srednja
message_key: "suggestions.herbs.start_seedlings"
```

```
rule_id: herbs.sow.direct
scope: category | ref_id: herbs | task_type_id: sow
timing_anchor: frost_offset
window: {"anchor": "last_frost", "offset_min_days": 0, "offset_max_days": 42}
cadence: seasonal (after last frost)
frost_gate: false
weather_guard: "soil ≥ 10 °C" → code: soil_gt_10
source_ref: "RHS – Herbs from seed (verify)"
confidence: srednja
message_key: "suggestions.herbs.sow_direct"
```

```
rule_id: herbs.plant
scope: category | ref_id: herbs | task_type_id: plant
timing_anchor: frost_offset
window: {"anchor": "last_frost", "offset_min_days": 0, "offset_max_days": 56}
cadence: seasonal (bought herb plants after last frost)
frost_gate: true
weather_guard: "no frost forecast 48h" → code: no_frost_forecast_48h
source_ref: "RHS – Planting herbs (verify)"
confidence: srednja
message_key: "suggestions.herbs.plant_out"
```

### A.6 Okrasni grmi (`shrub`)

```
rule_id: shrub.prune.spring
scope: category | ref_id: shrub | task_type_id: prune
timing_anchor: month_window
window: {"start_week": 9, "end_week": 14, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: 1x/year (summer-flowering shrubs — RHS pruning group default; spring bloomers overridden per species when added)
frost_gate: false
weather_guard: "dry, no severe frost" → code: dry12h,temp_gt_0
source_ref: "RHS – Pruning groups (rhs.org.uk/pruning/pruning-groups) (verify slug)"
confidence: srednja
message_key: "suggestions.shrub.prune_spring"
```

```
rule_id: shrub.overwinter
scope: category | ref_id: shrub | task_type_id: overwinter
timing_anchor: frost_offset
window: {"anchor": "first_frost", "offset_min_days": -28, "offset_max_days": -7}
cadence: 1x/year (autumn — wrap/protect tender shrubs)
frost_gate: false
weather_guard: NULL (this IS the frost warning)
source_ref: "RHS – Preventing winter damage / protecting tender plants (verify)"
confidence: visoka
message_key: "suggestions.shrub.overwinter"
```

### A.7 Živa meja (`hedge`) + iglavci (`conifer`)

```
rule_id: hedge.prune.early_summer
scope: category | ref_id: hedge | task_type_id: prune
timing_anchor: month_window
window: {"start_week": 22, "end_week": 26, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: 1st of ~2 trims/year (after spring flush; message warns to check for nesting birds first)
frost_gate: false
weather_guard: "not in scorching heat" → code: temp_lt_30
source_ref: "RHS – Hedges: trimming (rhs.org.uk/hedges/trimming) (verify slug); DE BNatSchG §39 (radikalni rez prepovedan 1.3.–30.9. — samo vzdrževalni rez)"
confidence: visoka
message_key: "suggestions.hedge.prune_early_summer"
```

```
rule_id: hedge.prune.late_summer
scope: category | ref_id: hedge | task_type_id: prune
timing_anchor: month_window
window: {"start_week": 33, "end_week": 36, "climate_bucket_filter": null, "regionalize": "autumn"}
cadence: 2nd trim/year (regrowth hardens before winter)
frost_gate: false
weather_guard: "not in scorching heat" → code: temp_lt_30
source_ref: "RHS – Hedges: trimming (verify slug)"
confidence: visoka
message_key: "suggestions.hedge.prune_late_summer"
```

```
rule_id: conifer.prune
scope: category | ref_id: conifer | task_type_id: prune
timing_anchor: month_window
window: {"start_week": 23, "end_week": 26, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: 1x/year (message warns: never cut into old/bare wood — conifers do not regrow from it)
frost_gate: false
weather_guard: "overcast, not in scorching heat" → code: temp_lt_30
source_ref: "RHS – Conifers: pruning (verify)"
confidence: srednja
message_key: "suggestions.conifer.prune"
```

### A.8 Lončnice / sobne / balkonske (`houseplant`)

```
rule_id: houseplant.repot
scope: category | ref_id: houseplant | task_type_id: repot
timing_anchor: month_window
window: {"start_week": 9, "end_week": 18, "climate_bucket_filter": null, "regionalize": "none"}
cadence: every 1–2 years (spring, at start of growth)
frost_gate: false
weather_guard: NULL (indoor)
source_ref: "RHS – Houseplants: repotting (verify)"
confidence: visoka
message_key: "suggestions.houseplant.repot"
```

```
rule_id: houseplant.overwinter
scope: category | ref_id: houseplant | task_type_id: overwinter
timing_anchor: frost_offset
window: {"anchor": "first_frost", "offset_min_days": -28, "offset_max_days": -7}
cadence: 1x/year (move balcony/patio pots inside before first frost)
frost_gate: false
weather_guard: NULL (this IS the frost warning; boosted by no_frost_forecast violation — see R5)
source_ref: "RHS – Overwintering tender plants (verify)"
confidence: visoka
message_key: "suggestions.houseplant.overwinter"
```

```
rule_id: houseplant.fertilize
scope: category | ref_id: houseplant | task_type_id: fertilize
timing_anchor: cadence_only
window: {"min_days_since_last": 14, "max_days_since_last": 28, "season_start_week": 12, "season_end_week": 40}
cadence: every 2–4 weeks in growing season; none in winter
frost_gate: false
weather_guard: NULL (indoor)
source_ref: "RHS – Houseplants: feeding (verify)"
confidence: srednja
message_key: "suggestions.houseplant.fertilize_season"
```

---

## B) Pravila po VRSTI (override kategorije)

> Motor najprej išče `scope='plant'` pravila za (plant_id, task_type_id); če obstaja ≥1, kategorijska
> pravila za isti `task_type_id` za to rastlino NE veljajo (override po task-tipu, ne po vrstici).

### B.1 Malina (`raspberry`) — obrez ni zimski kategorijski

```
rule_id: raspberry.prune.summer_fruiting
scope: plant | ref_id: raspberry | task_type_id: prune
timing_anchor: growth_stage
window: {"after_event": "harvest", "offset_min_days": 0, "offset_max_days": 42}
cadence: 1x/year (summer-fruiting/floricane: cut fruited canes right after harvest)
frost_gate: false
weather_guard: NULL
source_ref: "RHS – Raspberries: pruning and training (rhs.org.uk/fruit/raspberries/pruning-and-training)"
confidence: visoka
message_key: "suggestions.raspberry.prune_after_harvest"
```

```
rule_id: raspberry.prune.autumn_fruiting
scope: plant | ref_id: raspberry | task_type_id: prune
timing_anchor: month_window
window: {"start_week": 6, "end_week": 10, "climate_bucket_filter": null, "regionalize": "none"}
cadence: 1x/year (autumn-fruiting/primocane: cut ALL canes to ground in late winter)
frost_gate: false
weather_guard: "dry, no severe frost" → code: dry12h,temp_gt_0
source_ref: "RHS – Raspberries: pruning and training (rhs.org.uk/fruit/raspberries/pruning-and-training)"
confidence: visoka
message_key: "suggestions.raspberry.prune_late_winter"
```
> Obe pravili se izpišeta s pojasnilom tipa maline (sporočilo: »poletna sorta → po obiranju /
> jesenska sorta → konec zime«). Aplikacija tipa sorte ne pozna → predlog je opisni, nikoli ukaz.
> Pravili se NE prožita obe hkrati (različna sprožilna okna).

### B.2 Breskev (`peach`) — NE zimski obrez (rak, kodravost)

```
rule_id: peach.prune
scope: plant | ref_id: peach | task_type_id: prune
timing_anchor: month_window
window: {"start_week": 14, "end_week": 20, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: 1x/year (spring at bud burst/flowering — NEVER in winter dormancy: silver leaf/canker risk)
frost_gate: false
weather_guard: "dry day" → code: dry24h
source_ref: "RHS – Peaches and nectarines: pruning (verify); KGZS – rez koščičarjev spomladi (verify)"
confidence: visoka
message_key: "suggestions.peach.prune_spring"
```

### B.3 Paradižnik (`tomato`) — celotna veriga vzgoje

```
rule_id: tomato.start_seedlings
scope: plant | ref_id: tomato | task_type_id: start_seedlings
timing_anchor: frost_offset
window: {"anchor": "last_frost", "offset_min_days": -56, "offset_max_days": -42}
cadence: seasonal (6–8 weeks before last frost, indoors)
frost_gate: false
weather_guard: NULL (protected)
source_ref: "RHS – How to grow tomatoes (rhs.org.uk/vegetables/tomatoes/grow-your-own)"
confidence: visoka
message_key: "suggestions.tomato.start_seedlings"
```

```
rule_id: tomato.prick_out
scope: plant | ref_id: tomato | task_type_id: prick_out
timing_anchor: growth_stage
window: {"after_event": "start_seedlings", "offset_min_days": 14, "offset_max_days": 21}
cadence: per chain (first true leaves)
frost_gate: false
weather_guard: NULL (protected)
source_ref: "RHS – How to grow tomatoes (rhs.org.uk/vegetables/tomatoes/grow-your-own)"
confidence: visoka
message_key: "suggestions.tomato.prick_out"
```

```
rule_id: tomato.harden_off
scope: plant | ref_id: tomato | task_type_id: harden_off
timing_anchor: frost_offset
window: {"anchor": "last_frost", "offset_min_days": -14, "offset_max_days": -7}
cadence: once per chain (1–2 weeks before planting out)
frost_gate: false
weather_guard: "no frost forecast 48h" → code: no_frost_forecast_48h
source_ref: "RHS – How to grow tomatoes; RHS – Hardening off (verify)"
confidence: visoka
message_key: "suggestions.tomato.harden_off"
```

```
rule_id: tomato.transplant
scope: plant | ref_id: tomato | task_type_id: transplant
timing_anchor: growth_stage
window: {"after_event": "harden_off", "offset_min_days": 7, "offset_max_days": 14}
cadence: once per chain (after hardening off AND past last frost)
frost_gate: true
weather_guard: "no frost forecast 48h, wind < 20 km/h" → code: no_frost_forecast_48h,wind_lt_20
source_ref: "RHS – How to grow tomatoes (rhs.org.uk/vegetables/tomatoes/grow-your-own)"
confidence: visoka
message_key: "suggestions.tomato.transplant"
```

```
rule_id: tomato.stake
scope: plant | ref_id: tomato | task_type_id: stake
timing_anchor: growth_stage
window: {"after_event": "transplant", "offset_min_days": 14, "offset_max_days": 28}
cadence: once per season (cordon varieties)
frost_gate: false
weather_guard: NULL
source_ref: "RHS – How to grow tomatoes (rhs.org.uk/vegetables/tomatoes/grow-your-own)"
confidence: srednja
message_key: "suggestions.tomato.stake"
```

### B.4 Bučke (`zucchini`) in kumare (`cucumber`) — direktna setev, brez verige

```
rule_id: zucchini.sow
scope: plant | ref_id: zucchini | task_type_id: sow
timing_anchor: frost_offset
window: {"anchor": "last_frost", "offset_min_days": 0, "offset_max_days": 28}
cadence: seasonal (direct sow after last frost, soil ≥ 12 °C)
frost_gate: true
weather_guard: "soil ≥ 12 °C, no frost forecast 48h" → code: soil_gt_12,no_frost_forecast_48h
source_ref: "RHS – How to grow courgettes (verify slug)"
confidence: visoka
message_key: "suggestions.zucchini.sow_direct"
```

```
rule_id: cucumber.sow
scope: plant | ref_id: cucumber | task_type_id: sow
timing_anchor: frost_offset
window: {"anchor": "last_frost", "offset_min_days": 7, "offset_max_days": 28}
cadence: seasonal (outdoor ridge cucumbers: direct sow ~1 week after last frost, warm soil)
frost_gate: true
weather_guard: "soil ≥ 12 °C, no frost forecast 48h" → code: soil_gt_12,no_frost_forecast_48h
source_ref: "RHS – How to grow cucumbers (verify slug)"
confidence: visoka
message_key: "suggestions.cucumber.sow_direct"
```

### B.5 Lovorikovec (`cherry_laurel`) — pozna pomlad + konec poletja

```
rule_id: cherry_laurel.prune.late_spring
scope: plant | ref_id: cherry_laurel | task_type_id: prune
timing_anchor: month_window
window: {"start_week": 21, "end_week": 24, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: 1st of ~2 trims/year (after spring flush; secateurs preferred over hedge trimmer — big leaves)
frost_gate: false
weather_guard: "overcast, not in scorching sun" → code: temp_lt_30
source_ref: "Gartenakademie / LWG Bayern – Kirschlorbeer schneiden (verify); RHS – Prunus laurocerasus (verify)"
confidence: srednja
message_key: "suggestions.cherry_laurel.prune_late_spring"
```

```
rule_id: cherry_laurel.prune.late_summer
scope: plant | ref_id: cherry_laurel | task_type_id: prune
timing_anchor: month_window
window: {"start_week": 33, "end_week": 35, "climate_bucket_filter": null, "regionalize": "autumn"}
cadence: 2nd trim/year (light tidy; regrowth must harden before frost)
frost_gate: false
weather_guard: "overcast, not in scorching sun" → code: temp_lt_30
source_ref: "Gartenakademie / LWG Bayern – Kirschlorbeer schneiden (verify)"
confidence: srednja
message_key: "suggestions.cherry_laurel.prune_late_summer"
```

### B.6 Vrtnica (`rose`) — pomladni obrez + jesensko zagrinjanje

```
rule_id: rose.prune
scope: plant | ref_id: rose | task_type_id: prune
timing_anchor: month_window
window: {"start_week": 10, "end_week": 14, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: 1x/year (late winter/early spring — 'when forsythia blooms')
frost_gate: false
weather_guard: "no severe frost forecast" → code: temp_gt_0,no_frost_forecast_48h
source_ref: "RHS – Rose pruning: general tips (verify slug)"
confidence: visoka
message_key: "suggestions.rose.prune_spring"
```

```
rule_id: rose.overwinter
scope: plant | ref_id: rose | task_type_id: overwinter
timing_anchor: frost_offset
window: {"anchor": "first_frost", "offset_min_days": -28, "offset_max_days": 0}
cadence: 1x/year (hill up / mound base before hard frost)
frost_gate: false
weather_guard: NULL
source_ref: "ADR / Gartenakademie – Rosen anhäufeln im Herbst (verify)"
confidence: srednja
message_key: "suggestions.rose.overwinter"
```

### B.7 Borovnica (`blueberry`) — zgodnje-pomladni obrez

```
rule_id: blueberry.prune
scope: plant | ref_id: blueberry | task_type_id: prune
timing_anchor: month_window
window: {"start_week": 9, "end_week": 13, "climate_bucket_filter": null, "regionalize": "none"}
cadence: 1x/year (late winter/early spring — buds visible, remove old wood)
frost_gate: false
weather_guard: "dry, no severe frost" → code: dry12h,temp_gt_0
source_ref: "RHS – How to grow blueberries (rhs.org.uk/fruit/blueberries/grow-your-own) (verify slug)"
confidence: visoka
message_key: "suggestions.blueberry.prune"
```

### B.8 Hortenzija (`hydrangea`) — dve pravili, ker se skupini razlikujeta

```
rule_id: hydrangea.prune.old_wood
scope: plant | ref_id: hydrangea | task_type_id: prune
timing_anchor: month_window
window: {"start_week": 12, "end_week": 16, "climate_bucket_filter": null, "regionalize": "spring"}
cadence: 1x/year (H. macrophylla/serrata — old wood: ONLY deadhead to first strong buds; hard prune kills bloom)
frost_gate: false
weather_guard: "past severe frosts" → code: no_frost_forecast_48h
source_ref: "RHS – Hydrangea: pruning (rhs.org.uk/plants/hydrangea/pruning) (verify slug)"
confidence: visoka
message_key: "suggestions.hydrangea.prune_old_wood"
```

```
rule_id: hydrangea.prune.new_wood
scope: plant | ref_id: hydrangea | task_type_id: prune
timing_anchor: month_window
window: {"start_week": 8, "end_week": 13, "climate_bucket_filter": null, "regionalize": "none"}
cadence: 1x/year (H. paniculata/arborescens — new wood: hard prune to framework in late winter)
frost_gate: false
weather_guard: "dry, no severe frost" → code: dry12h,temp_gt_0
source_ref: "RHS – Hydrangea: pruning (rhs.org.uk/plants/hydrangea/pruning) (verify slug)"
confidence: visoka
message_key: "suggestions.hydrangea.prune_new_wood"
```
> Aplikacija ne pozna podvrste hortenzije → obe pravili se sprožita v svojih oknih in vsako
> sporočilo razloži, za KATERO skupino velja (»če imaš metlasto/drevesasto → zdaj ostro;
> če vrtno (macrophylla) → samo odcveteli del aprila«). Okni se PREKRIVATA (tedna 12–13) —
> da ne prideta obe kartici hkrati, skrbita straža 5f (aktivni predlog po **(tip, subjekt)**,
> cross-run) in dedup koraka 6 (znotraj teka) — gl. `03` §Cevovod. Cooldown/mute sta sicer
> per guard key (`03` §Guard key), zato dismiss enega pravila NE utiša drugega trajno.

---

## C) Povzetek obsega seeda

| Sklop | Št. pravil |
|---|---|
| lawn | 14 |
| fruit_tree | 7 |
| berries | 4 |
| vegetable | 8 |
| herbs | 3 |
| shrub | 2 |
| hedge + conifer | 3 |
| houseplant | 3 |
| **kategorije skupaj** | **44** |
| plant overrides (raspberry 2, peach 1, tomato 5, zucchini 1, cucumber 1, cherry_laurel 2, rose 2, blueberry 1, hydrangea 2) | **17** |
| **SKUPAJ seed M11** | **61** |

Vsa `message_key` predloga zahtevajo i18n vnos v `i18n/*.i18n.json` pod `suggestions.*` z
naslovom (`.title`) in telesom (`.body`) ter parametri (gl. `03-pravila-r1-r7.md` §Sporočila).

---

## D) Viri in vzdrževanje pravil (od kod, kako dopolnjujemo)

**Hierarhija sprejemljivih virov** (pravilo brez vira iz te lestvice se NE seeda):
1. **Nacionalne svetovalne službe in stroka:** RHS (primarni — strukturiran, prosto dostopen),
   KGZS + FURS/IVR (SL specifika, FFS praksa), nemške Gartenakademie / LWG Bayern /
   Landwirtschaftskammer (DE trg), univerzitetne publikacije.
2. **Faktografski podatki:** semenske vrečke (čas setve relativno na pozebo, globina —
   dejstva, ne avtorsko delo; kuriraj iz več vrečk) in javni fenološki podatki (npr. ARSO
   fenološka opazovanja) — naravna hrana za `frost_offset` pravila.
3. **Skupnostna kalibracija (post-V2):** `activity_season` krivulje so meritev, *kdaj
   uporabniki v posameznem košu opravilo dejansko delajo*. To NI agronomska avtoriteta, JE pa
   kalibracija robov oken. Cevovod: nočni agregat (obstaja) → periodičen **kuratorski
   pregled** pravilo↔krivulja po koših → ročen popravek pravila s
   `source_ref: "community-calibrated (n=…, bucket=…, base=<prvotni vir>)"` in po potrebi
   novo vrednostjo `confidence: 'community'` (additive razširitev CHECK-a ob prvi uporabi).
   Pravila NIKOLI ne posodablja avtomat.

**Izrecno IZVEN motorja:**
- **Regijski setveni koledarji** (avtorsko zaščiteni) — nadomešča jih frost-anchor (§0).
- **LLM** ne piše pravil. Dovoljen kvečjemu kot *pomočnik kuratorja*: grupiranje pogostih
  custom imen (kandidati za katalog/sinonime), osnutek pravila iz danega vira — človek
  potrdi in podpiše `source_ref` (skladno s koncept odločitvijo »AI nikoli za agronomski
  nasvet«).
- **Lunin/biodinamični koledar** — brez znanstvene podlage → ne sme v `plant_task_rule` niti
  v oceno predlogov (spodkopal bi `source_ref` kredibilnost). Če kdaj (povpraševanje SL/DE
  publike obstaja): **V3 ločen, izrecno označen prikazni widget** (»biodinamična tradicija
  pravi …«), opt-in, čisto astronomski izračun, nič vpliva na motor. → backlog, ne M11.

**Dopolnjevanje obsega:** nova pravila so add-only (`rule_id` se nikoli ne reciklira);
kategorije `perennial`/`climber`/`bulb` + nove vrste pridejo v kasnejših kuracijskih rundah
po istem postopku (vir → `(verify)` → potrditev → seed).
