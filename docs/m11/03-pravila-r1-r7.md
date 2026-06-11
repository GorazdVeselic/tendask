# Poglavje 3 — Formalna specifikacija pravil R1–R7

> Vsako pravilo emitira **kandidate** `{ruleId, plantTaskRuleId?, taskTypeId, subjectKey,
> userPlantId?, areaId?, messageKey, messageParams, score, suggestedDate, validUntil}`.
> Skupni cevovod (straže → rangiranje → emit) je definiran na koncu (§Cevovod).

## Skupne konstante (strežnik: `app_config.engine`; klient zrcali informativne v `core/config.dart`)

```jsonc
{
  "score_weather_window": 2.0,
  "score_season_window": 1.0,
  "score_anniversary": 1.0,
  "score_window_closing": 0.5,   // zadnja 1/4 okna
  "score_low_supply": 0.5,
  "score_chain_ready": 2.0,
  "score_overdue_per_day": 0.1,  // R3, cap 2.0
  "emit_threshold": 2.0,         // kandidat pod tem se zavrže
  "push_cap_per_day": 1,         // frekvenčna kapica (best-of)
  "band_max_active": 3,          // pas Domov kaže max 3 hkrati
  "dedup_planned_within_days": 14,
  "frost_safety_days": 7
}
```

## Sporočila (i18n pogodba)

Vsak `message_key` ima v slang `suggestions.*` tri pod-ključe: `.title`, `.body`, `.cta_hint`
(neobvezen). Parametri so **vedno** posredovani v `suggestion.message_params` (jsonb) — klient
NE računa ničesar, samo vstavi v predlogo. Standardni parametri:
`{subject_label_key, days_overdue, days_since, last_year_date, window_end_date, supply_name,
suggested_date, frost_date, percent}` — pravilo navede, katere pošlje. `subject_label_key` je
**katalog ID** (klient prevede prek `catalogLabel()`; custom rastlina → `personal alias/custom_name`,
ki ga engine pošlje kot `subject_label_raw`).

---

## R1 — Vremensko okno za vremensko občutljiva opravila

**Namen:** »jutri/danes je suho okno — primeren čas za škropljenje/gnojenje/košnjo.«
R1 NE uvaja sezone — vremensko okno samo OJAČA že obstoječo potrebo (cadence/sezona).

```
SPROŽILEC (psevdokoda):
  for taskType in taskTypes where weather_sensitive = true:
    for subject in eligibleSubjects(taskType):           // §Cevovod, upravičenost
      needsDoing =
        (ruleFor(subject, taskType, anchor='cadence_only') is in window)   // R3 logika
        OR (seasonWindowOpen(subject, taskType))                           // R5 logika
      if not needsDoing: continue
      if weather.forecastDryHours == null: continue       // vreme nedosegljivo → preskoči
      if weather.forecastDryHours >= 24
         and weather.recentRainMm24h < 2.0
         and (taskType != 'treat' or weather.windSpeedKmh < 15):
        emit candidate
```
**KONTEKST:** `weather.forecastDryHours`, `recentRainMm24h`, `windSpeedKmh`, R3/R5 stanje.
**STRAŽE (poleg skupnih):** subjekt v `protected` območju → R1 zanj NE velja (vremensko okno je
brezpredmetno). `treat` dodatno `no_rain_forecast_24h` (odpornost nanosa).
**OCENA:** `score_weather_window (2.0) + (R3 zamuda ? min(days_overdue*0.1, 2.0) : 0)
+ (R5 okno odprto ? 1.0 : 0)`.
**SPOROČILO:** `suggestions.weather.window_open` — params `{subject_label_key, task_type_id,
dry_hours}`; če izvira iz R3/R5, engine uporabi specifičnejši `message_key` IZVORNEGA pravila in
doda param `dry_window: true` (predloga doda »jutri kaže suho«).
**AKCIJA ob Načrtuj:** task `{task_type_id, subjects: [subject], date: tomorrow 09:00 local,
status: waiting}`.
**COOLDOWN:** 3 dni po emitu (per rule+subjekt). **DISMISS:** 7 dni.
**validUntil:** `today + 2 dni` (vremensko okno hitro zastara).

## R2 — Osebna obletnica (»lani tačas si …«)

```
SPROŽILEC:
  for (subjectKey, taskTypeId) in distinct done pairs of user history:
    lastYear = history.lastDoneYearAgo(subjectKey, taskTypeId)   // ±7 dni okno
    if lastYear == null: continue
    if history.lastDone(subjectKey, taskTypeId) >= startOfSeason(today): continue
       // letos že opravljeno → ni smiselno
    emit candidate
```
**KONTEKST:** `history.lastDoneYearAgo`, `history.lastDone`.
**STRAŽE:** skupne + `task_type.seasonal = true` (ne-sezonskih ne obletničimo);
za `weather_sensitive` tip še `weather_guard` tipa iz `plant_task_rule` (če pravilo zanj obstaja).
**OCENA:** `score_anniversary (1.0) + (R1 suho okno hkrati ? 2.0 : 0)` →
sama obletnica (1.0) NE preseže `emit_threshold` (2.0) — emitira se šele v kombinaciji z
vremenskim oknom ALI sezonskim oknom (+1.0 → 2.0). Namerno: obletnica je šibek signal.
**SPOROČILO:** `suggestions.history.anniversary` — params `{subject_label_key, task_type_id,
last_year_date}` (»Lani si {last_year_date} {task}. Letos še nisi.«).
**AKCIJA ob Načrtuj:** task na `max(today+1, lastYearDate letos)` 09:00.
**COOLDOWN:** 30 dni (efektivno 1× na sezono — naslednje leto je nov sprožilec).
**DISMISS:** 60 dni (preskoči letošnjo obletnico). **validUntil:** `today + 7`.

## R3 — Zamuda po ritmu (cadence)

```
SPROŽILEC:
  for (subjectKey, taskTypeId) in pairs with >= 1 done task:
    cad = history.cadenceDays(subjectKey, taskTypeId)    // mediana ali default_cadence
    if cad == null: continue
    days = today - history.lastDone(subjectKey, taskTypeId)
    rule = plantTaskRule(subject, taskType)              // za sezonsko omejitev cadence_only
    if rule has season window and today not in it: continue
    if days > cad * 1.25: emit candidate (days_overdue = days - cad)
```
**KONTEKST:** `history.cadenceDays`, `history.lastDone`, sezonska omejitev iz `cadence_only` pravila.
**STRAŽE:** skupne + za `weather_sensitive` tip `weather_guard` ustreznega pravila (dež → ne kosi).
**OCENA:** `min(days_overdue * 0.1, 2.0) + (R1 suho okno ? 2.0 : 0)`; emit šele, ko vsota ≥ 2.0 —
tj. brez vremenskega okna šele pri ≥ 20 dneh čiste zamude, z odprtim vremenskim oknom takoj.
Izjema: `mow` z `days_overdue >= 4` dobi `+1.0` (trata je core persona; vrednost iz
`app_config.engine.score_mow_boost`).
**SPOROČILO:** `suggestions.cadence.overdue` — params `{subject_label_key, task_type_id,
days_overdue, cadence_days}` (»Košnja zamuja {days_overdue} dni (ritem ~{cadence_days}).«).
**AKCIJA ob Načrtuj:** task na `tomorrow 09:00`.
**COOLDOWN:** 5 dni. **DISMISS:** 10 dni. **validUntil:** `today + 5`.

## R4 — Nizka zaloga ob predlogu (piggyback; aktivno šele ob `kSuppliesEnabled=true`)

R4 NIKOLI ne emitira samostojnega predloga — samo obogati kandidata drugega pravila.

```
SPROŽILEC: za vsakega KONČNEGA kandidata (po stražah, pred emitom), če
  taskType ∈ {fertilize, treat, lawn_weed_moss, lime, overseed, topdress}:
    supplies = inventory.suppliesForTaskType(taskTypeId)
    low = supplies.where(s => !inventory.hasSupply(s.id))
    if low.isNotEmpty:
      candidate.score += 0.5
      candidate.messageParams.supply_name = low.first.name
      candidate.messageParams.low_supply = true
```
**SPOROČILO:** ni svoj ključ — predloge ciljnih pravil imajo neobvezen odsek
`{low_supply ? ' (zaloga {supply_name} je nizka)' : ''}` (slang rich param).
**AKCIJA/COOLDOWN/DISMISS:** podeduje od nosilnega kandidata.

## R5 — Sezonsko okno (`plant_task_rule`: month_window + frost_offset)

```
SPROŽILEC:
  for rule in plantTaskRules where timing_anchor in ('month_window','frost_offset'):
    subjects = (rule.scope == 'plant')
        ? eligibility.plantsById(rule.ref_id)
        : (rule.ref_id == 'lawn'
            ? eligibility.areasByType('lawn')                       // trata: subjekt = območje
            : eligibility.plantsByCategory(rule.ref_id))
    if rule.scope == 'category' and plantOverrideExists(plant, rule.task_type_id):
        skip that plant                                              // override semantika (01 §B)
    for subject in subjects:
      window = resolveWindow(rule, climate)    // regionalizacija 01 §0; frost_offset → datuma
      if rule.frost_gate: window.start = max(window.start, climate.lastFrostDate)
      if today not in window: continue
      if history.lastDone(subjectKey, rule.task_type_id) in currentWindowOrSeason: continue
         // letos v tem oknu že opravljeno → cooldown po izvedbi
      emit candidate
```
**KONTEKST:** `climate.*`, `history.lastDone`, `plant_task_rule`.
**STRAŽE:** skupne + `rule.weather_guard` (preskočen za zaščiten subjekt) + `frost_gate`
(NI preskočen nikoli) + `climate_bucket_filter` (če ni null in bucket ni v njem → preskoči).
**OCENA:** `score_season_window (1.0) + (today v zadnji četrtini okna ? 0.5 : 0)
+ (R1 suho okno hkrati in tip weather_sensitive ? 2.0 : 0) + (R2 obletnica hkrati ? 1.0 : 0)`.
Posebnost `overwinter`/`first_frost` pravila: `+2.0` namesto `+1.0` (zamuda = mrtva rastlina;
`app_config.engine.score_frost_protect_boost`) → emitira tudi brez vremenskega okna.
**SPOROČILO:** `message_key` iz pravila (gl. 01) — params `{subject_label_key, window_end_date,
frost_date?}`.
**AKCIJA ob Načrtuj:** task na `max(tomorrow, window.start) 09:00`.
**COOLDOWN:** 10 dni (okno traja tedne → max ~2 predloga na okno: ob odprtju + proti koncu).
**DISMISS:** do `window.end` (dismissed_until = konec okna) — »letos ne« in mir.
**validUntil:** `min(today + 7, window.end)`.

## R7 — Veriga vzgoje sadik (growth_stage, event-driven)

```
SPROŽILEC:
  for rule in plantTaskRules where timing_anchor == 'growth_stage':
    for subject in subjectsFor(rule):                       // kot R5
      prev = history.chainStepDate(subjectKey, rule.window.after_event)   // tekoča sezona!
      if prev == null: continue                             // koraka ni → verige ni
      if history.lastDone(subjectKey, rule.task_type_id) >= prev: continue
         // naslednji korak že opravljen po prejšnjem → veriga je dlje
      start = prev + offset_min_days; end = prev + offset_max_days
      if rule.frost_gate: start = max(start, climate.lastFrostDate)
      if today < start: continue
      emit candidate (tudi če today > end — veriga ne zastara, sporočilo dobi late=true)
```
**KONTEKST:** `history.chainStepDate`, `climate.lastFrostDate`.
**STRAŽE:** skupne + `weather_guard` (zaščiten subjekt → preskok; `harden_off`/`transplant`
imata frost guard, ki se NE preskoči, ker je `no_frost_forecast_48h` del frost-gate semantike —
tehnično: koda `no_frost_forecast_48h` se vrednoti tudi za zaščitene subjekte, kadar
`rule.frost_gate = true`).
**OCENA:** `score_chain_ready (2.0) + (today > end ? 0.5 : 0)` → vedno nad pragom (veriga je
najmočnejši signal — uporabnik je investiral v sadike).
**SPOROČILO:** `message_key` iz pravila — params `{subject_label_key, days_since, late}`
(»Pred {days_since} dnevi si sejal {subject} — čas za pikiranje.«).
**AKCIJA ob Načrtuj:** task na `tomorrow 09:00` (oz. `max(tomorrow, start)`).
**COOLDOWN:** 5 dni. **DISMISS:** 14 dni. **validUntil:** `today + 7`.

## R6 — Percentil okolice (V2; aktivira se z M11.17+)

```
SPROŽILEC (teče v istem dnevnem teku, šele ko obstajajo agregati):
  for taskType in seasonal taskTypes where user is eligible subject owner:
    cdf = activitySeasonCdf(userBuckets, taskType)     // fallback hierarhija 7→6→5→climate→global
    if cdf == null or cdf.pooledTotal < K_reliab: continue
    F = cdf.valueAt(currentIsoWeek)
    if F >= 0.5 and history.lastDone(any subject, taskType) not in currentSeason:
      emit candidate (percent = round10(F*100))
```
**STRAŽE:** skupne + `notification_settings.community_hints = true` (za push) + `K_privacy`/
`K_reliab` (server-side, že v agregatih) + uporabnik je Tendask+ (pas/push z odstotkom je
premium — gl. `08` §8.3; ne-naročnik dobi tease različico brez številke).
**OCENA:** `1.0 + (F >= 0.68 ? 0.5 : 0)`. **SPOROČILO:** `suggestions.community.most_started` —
params `{task_type_id, percent}` (ubeseditev iz CDF, `skupnost-agregacija.md` §7.8).
**COOLDOWN:** 14 dni. **DISMISS:** do konca sezone. **validUntil:** `today + 7`.

---

## Cevovod (skupni tek — natančen vrstni red)

```
runForUser(userId):
 1. load: profile (timezone, climate, notification_settings, fcm_token),
          areas, user_plants(+plant join), tasks (done zadnjih 24 mes + waiting),
          task_reminders, supplies+task_supplies (če enabled), suggestion_log,
          suggestions (status != 'new' spremembe od zadnjega teka), plant_task_rule (cache).
 2. housekeeping:
    a. suggestions s status='dismissed' brez log vnosa → upsert suggestion_log:
       - dismiss_scope='season'  → dismissed_until = updated_at + dismissDays(rule)
                                   (R5: konec regionaliziranega okna),
       - dismiss_scope='forever' → dismissed_until = 'infinity' (trajen mute za
         (rule, subjekt); straža 5b ga pokrije brez posebne logike).
    b. suggestions s status='logged' → nič v suggestion_log: klient je ustvaril done
       opravilo → straža 5d (cooldown po izvedbi) + history signali utišajo sami.
    c. suggestions s status='new' in valid_until < today → status='expired'.
    d. suggestions s status='new', katerih subjekt je medtem deleted (rastlina/območje
       odstranjena) → status='expired' (upravičenost pobije tudi vse prihodnje).
    e. retencija zgodovine: terminalne vrstice (status != 'new'), starejše od
       app_config.engine.suggestion_retention_days (365), → deleted=true (soft delete,
       sync jih počisti tudi lokalno). Eno leto pokrije »lani tačas« kontekst in zaslon
       Pretekli predlogi; tabela ostane drobna.
 3. signals = buildSignals(...)          // Poglavje 2 (weather_cache po celici!)
 4. candidates = R5() + R7() + R3() + R2() + R1()       // R1 zadnji (bere R3/R5 stanje)
    → R4 obogatitev.
 5. STRAŽE za vsak kandidat (vrstni red, fail-fast):
    a. upravičenost (subjekt obstaja, ni deleted)        — vgrajeno v emit
    b. state.dismissed(ruleId, subjectKey)               → drop
    c. cooldown: now - state.lastSuggestedAt < cooldown  → drop
    d. cooldown po izvedbi: history.lastDone(subject, taskType) > today - cooldownDone
       (cooldownDone = max(3 dni, cadence/2) za cadence tipe; za R5 'v tem oknu/sezoni')
    e. dedup: state.planned(subjectKey, taskTypeId, 14)  → drop
    f. dedup: state.activeSuggestion(ruleId, subjectKey) → drop (že na pasu)
    g. weather_guard (preskočen za protected subjekt; frost_gate vedno velja)
    h. score < emit_threshold                            → drop
 6. dedup med kandidati: po (taskTypeId, subjectKey) obdrži najvišjo oceno.
 7. rank desc by score; vzemi top band_max_active (3) NOVIH (ki še niso na pasu).
 8. emit:
    a. INSERT v suggestion (status='new') za vse iz 7.
    b. upsert suggestion_log.last_suggested_at za vsakega.
    c. push: če notification_settings dovoljuje vrsto (weather_hints za R1–R5/R7,
       community_hints za R6) in danes še ni bil poslan push (frequency cap, engine_run
       tabela) → FCM za KANDIDATA #1 (najvišja ocena). Sicer nič — pas počaka uporabnika.
 9. update engine_run(user_id, last_run_date = local today, pushed = bool).
```

Determinizem: pri enakih vhodih je izhod identičen (sortiranje sekundarno po `rule_id`,
`subject_key` — stabilen vrstni red). To je pogoj za unit teste (M11.16).

---

## Akcije na kartici (pogodba klient ↔ strežnik)

Tri resnice »ne kaži mi tega« → tri ločene poti (+ Načrtuj). Vidna gumba sta DVA
(Načrtuj/Opusti); redkejše akcije pod **⋯** (action sheet, vzorec wireframe 14):

| Akcija | Kje | Klient zapiše | Strežniški učinek |
|---|---|---|---|
| **Načrtuj** | gumb | `status='planned'`, `planned_task_id` (+ ustvari waiting task) | dedup straža 5e prevzame |
| **Opusti** (»letos ne«) | gumb | `status='dismissed'`, `dismiss_scope='season'` | housekeeping 2a → `dismissed_until` do konca okna/`dismissDays` |
| **✓ Že opravljeno** | ⋯ | mini-sheet danes/včeraj/izberi datum → ustvari **done** task (z `agg_context`!) → `status='logged'`, `planned_task_id` | history + cooldown po izvedbi utišata; dnevnik in V2 agregat dobita dogodek |
| **Ne predlagaj več tega** (»not interested«) | ⋯ | `status='dismissed'`, `dismiss_scope='forever'` | housekeeping 2a → `dismissed_until='infinity'` za (rule, subjekt) |
| **Te rastline/območja nimam več** | ⋯ | confirm dialog → soft-delete `user_plant`/`area` (obstoječi repo) + `status='dismissed'` | upravičenost pobije VSA prihodnja pravila za subjekt; housekeeping 2d počisti morebitne ostale aktivne |

Trajen mute je per **(rule_id, subject_key)** — »ne predlagaj obreza te jablane« ne utiša
gnojenja iste jablane niti obreza druge. Razveljavitev trajnega muta v MVP ni v UI
(zavestno; če bo potreba → Settings seznam mutov, backlog).
