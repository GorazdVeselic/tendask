# Naslednja seja — M11.11 (R1 + R4 + rangiranje/kapica + housekeeping)

Branch `feat/m11-smart-engine`. M11.10 (R5+R7) **commitan** (`fb20d26`). Engine je
**deployan** na živ projekt z M11.10 kodo. Ta seja: implementiraj M11.11, nato (kot
vedno) code review pred commitom + DoD, **šele nato commit** (vprašaj prej).

## Stanje (kaj je narejeno)

- **M11.1–M11.10 ✅.** Zadnji commit `fb20d26` (R5/R7). 80/80 Deno testov, `deno check` čist.
- **Cevovod zdaj (`index.ts`):** `loadRules` (cache, **`.order('id')`** za determinizem) →
  `r5 → r7 → r3 → r2` → `applyGuards` → `dedupAndRank` → `emit` + `engine_run` upsert.
- **R1 dry-window bonus je ŽE vgrajen inline** v R2/R3/R5 prek `candidate.ts isDryWindow`
  (+`score_weather_window` 2.0 za `weather_sensitive` & `!protected`). Torej R1 NI več cel
  »od nule« — gl. obseg spodaj, kaj DEJANSKO ostane.
- **R3 trenutno NE upošteva sezonske omejitve `cadence_only` pravil** (`season_start_week`/
  `season_end_week`) niti njihovega `weather_guard` — `rules.ts r3` bere samo kadenco iz
  zgodovine. To je glavni manjkajoči kos (gl. M11.11 obseg #3).
- **`weatherGuard` je `null`** na vseh R2/R3 kandidatih (M11.11 ga zaplete za cadence_only).

## M11.11 — obseg (vir resnice: `03` §R1, §R4, §Cevovod 2+6+7+8; `01` §0 cadence_only shema)

1. **R1 — vremensko okno (`03` §R1).** R1 NE uvaja sezone; ojača obstoječo potrebo
   (`needsDoing = R3 cadence v oknu OR R5 sezona odprta`) za `weather_sensitive` tipe ob suhem
   oknu. **Pomembno:** ker R2/R3/R5 že dodajo dry-bonus inline, premisli, ali R1 sploh emitira
   ločene kandidate ALI le doda specifiko, ki je inline koda NE pokrije:
   - `treat` poseben: `wind_lt_15` + `no_rain_forecast_24h` (odpornost nanosa) — inline
     `isDryWindow` tega NE preverja.
   - kadar kandidat izvira iz R3/R5: uporabi **specifičnejši `message_key` izvornega pravila** +
     param `dry_window: true` (ne svojega `suggestions.weather.window_open`).
   - score `2.0 + (R3 zamuda?min(d*0.1,2.0)) + (R5 okno?1.0)`; cooldown 3, dismiss 7,
     **validUntil today+2** (vremensko okno hitro zastara).
2. **R4 — nizka zaloga (piggyback; `03` §R4).** NIKOLI samostojen. Za vsak KONČEN kandidat
   (po stražah, PRED emitom), če `taskType ∈ {fertilize, treat, lawn_weed_moss, lime, overseed,
   topdress}` in `inventory.suppliesForTaskType` ima nizko zalogo → `score += 0.5`,
   `messageParams.supply_name + low_supply=true`. **Aktivno šele ob `kSuppliesEnabled`** (klient
   flag; na strežniku predvidi vklop/izklop — preveri, kako engine ve za to; verjetno vedno
   računa, klient skrije). Signali `inventory.*` že obstajajo (`signals.ts`).
3. **R3 sezonska omejitev + weather_guard (`03` §R3, `01` §0 cadence_only).** Za vsak (subjekt,
   taskType) poišči pripadajoče `cadence_only` `plant_task_rule`; če ima `season_start_week`/
   `season_end_week` in danes ni v (regionaliziranem!) oknu → preskoči. Prenesi `rule.weather_guard`
   na kandidat (zdaj `null`). Pozor na override semantiko (kot R5) in regionalizacijo tednov
   (helper `resolveWindow`/`deriveReg` v `rules_agro.ts` — morda ekstrahiraj skupni del).
4. **Rangiranje/kapica (`03` §Cevovod 6+7).** `dedupAndRank` (po `taskType+subjekt`, top
   `band_max_active=3`) že obstaja in je deterministično. Preveri korak 7 »top N **NOVIH** (ki
   še niso na pasu)« — `state.activeSuggestion` guard f to že pokriva; potrdi.
5. **Housekeeping (`03` §Cevovod 2a–2e).** Pred signali: dismissed→`suggestion_log`
   (2a, guard key, `dismissed_until` po scope), logged→nič (2b), `new`+`valid_until<today`→
   `expired` (2c), `new` z deleted subjektom→`expired` (2d), retencija terminalnih starejših od
   `suggestion_retention_days`→soft delete (2e). Te `suggestion` statuse piše klient (faza D, še
   ni), a housekeeping mora obstajati za pravilen tek. Preveri shemo `04` §4.3.

**DoD (`09`):** Deno testi celega cevovoda — 3 scenariji iz `03` §Cevovod (dež → R1 nič;
suho+zamuda → en emit z **4.0**; 5 kandidatov → top 3) + determinizem (isti vhod 2× → identičen
izhod). Po unit testih: deploy + live invoke (recept spodaj) + cleanup.
**Commit:** `feat(engine): R1 vremensko okno, R4 zaloga, rangiranje in frekvenčna kapica`.

## Recepti (naučeno, KRITIČNO)

- **`.env` DB geslo STALE** — pooler `password authentication failed`; psycopg pooler skripte v
  `tmp/` mrtve. Delaj prek **PostgREST + service_role** (REST + invoke).
- **Service-role token** (legacy JWT; `sb_secret_*` so MASKIRANI=neuporabni):
  ```bash
  export SR_KEY=$(supabase projects api-keys --project-ref jlmkkeijmmnwkizutvkg -o env 2>/dev/null \
    | grep '^SUPABASE_SERVICE_ROLE_KEY=' | cut -d= -f2- | tr -d '"\r\n')
  ```
  OBVEZNO stripaj `"` in `\r`. Uporabi kot `apikey`+`Bearer` za `/rest/v1/*` IN
  `/functions/v1/smart-engine`.
- **Live invoke skripte:** `tmp/m119_e2e.py` (R3) in `tmp/m1110_e2e.py` (R7 veriga) —
  `check|seed|invoke|cleanup`, plain insert (svež UUID); cleanup tombstona suggestion +
  hard-delete suggestion_log. Za M11.11 naredi `tmp/m1111_e2e.py` po istem vzorcu (npr. seed
  cadence-overdue + suho vreme za R1, ali low-supply za R4).
- **Deploy (ČE spremeniš kodo):** `supabase functions deploy smart-engine --project-ref
  jlmkkeijmmnwkizutvkg` (Docker NI potreben; `verify_jwt=true` v config.toml — NIKOLI
  `--no-verify-jwt`; `_test.ts` se ne naložijo). Cron `engine_dispatch` lahko teče → neškodljivo
  (prod vc4 iz main NIMA M11 klienta).
- **Dev user:** `c85fd203-c3ca-4ade-89e5-e41b77e7b2b8` (exogenus@gmail.com); tomato up
  `d743757d-1bd4-429e-8669-9c6dd862daaa`; klima `e1_t6` (frost 2026-04-06 / 2026-11-07ish), tz
  Europe/Ljubljana. Ima tudi lawn/pepper/carrot/peony/apple/pear (gl. eligibility v invoke
  izhodu). Supabase ref `jlmkkeijmmnwkizutvkg`.
- **fmt:** nove datoteke piši LF + `deno fmt`-clean (lineWidth 100); M11.8 datoteke (CRLF,
  pre-existing) NE reformatiraj v feat commitu (vzorec M11.9/M11.10).
- **Determinizem:** če bereš novo iz baze in lahko pride do izenačene ocene → `.order('id')`
  (vzorec iz M11.10 loadRules).

## Dogovor

Pogovor SL, koda EN (tudi Deno/TS). Začasni outputi v `tmp/`. **Pred commitom VEDNO vprašaj.**
Nove dependency izven `tech-stack.md §1` → najprej vprašaj. **Živa baza ni sandbox —
additive-only, ne podri app iz main** (RLS ne oži, tolerantni parser, expand→contract).
En korak roadmapa = en commit; odkljukaj korak v `09-koraki.md`.

## Po M11.11

M11.12 (dispatch cron + FCM pošiljanje; rabi `tool/gen_push_i18n.dart` — nov mini tool, Vault
secret 👤). Parkirano: `docs/roadmap.md` FR-8 (centroid h3_r7 za vreme/post-sign-in),
insert-if-missing LWW race, Sentry TENDASK-6, »dvojni tap« opomnik, 👤 Play upload vc4 +
vabila testerjem.
