# M11 — plan popravkov po code reviewu (pred prižigom)

> **Status:** predlog · 2026-07-26 · veja `feat/m11-smart-engine`
> **Podlaga:** trije neodvisni pregledi cele veje (`git diff main...feat/m11-smart-engine`,
> 50 commitov, 186 datotek) — produktni, tehnični in testni.
> **Poročila:** `tmp/review-m11/{pm-review.md, engineer-review.md, tester-review.md}` +
> skupni povzetek `tmp/review-m11/POVZETEK.md`.
> **Ta dokument je delovni tasklist** (kot `09-koraki.md` za gradnjo) — ne ponavlja dokazov,
> samo kaj naredimo, kje, in kdaj je narejeno.

---

## 0 · Izhodišče in kaj to pomeni za merge

Gradnja je zelena: `flutter analyze` čist, **1150 Flutter + 116 Deno testov**, pokritost jedra M11
(community + suggestions) **89,9 %**, i18n 100 % pariteten en/sl/de.

Vse novo leži za **štirimi neodvisnimi varovalkami**: `kSuggestionsEnabled = false`
(`lib/core/config.dart`), `app_config.engine_enabled = false`, ne-deployana edge funkcija,
izklopljen cron. Zato:

- **Veja je merge-able takoj.** Nobena ugotovitev iz pregleda ne doseže uporabnika, dokler flag ne
  gre na `true`.
- **Vsi popravki v tem dokumentu so pogoj za PRIŽIG, ne za merge.**

Odločitev, ali se najprej merga in popravlja na `main`, ali se popravi na veji in merga enkrat, je
odprta (gl. §6).

---

## 1 · Delovni dogovor za te popravke

Velja `CLAUDE.md` + `docs/roadmap.md`, tu samo specifika:

1. **En paket (P*) = en commit.** Conventional Commits, naslov ≤72 znakov, slovenski opis.
2. **Pred vsakim commitom vprašam** (»naj ta korak označim kot zaključen in ga commitam?«).
3. **Po vsakem paketu:** `flutter analyze` + **cel** `flutter test` + `deno test supabase/functions/`.
   Ne samo `analyze` — gl. spomin `feedback-run-flutter-test-before-push`.
4. **Vsak popravek dobi test, ki bi napako ujel.** Če testa ni mogoče napisati (npr. rabi napravo),
   se to zapiše v DoD paketa kot izjema.
5. **Migracije: additive-only, expand→contract**, nove številke od zadnje uporabljene naprej.
   Nikoli rename, nikoli `NOT NULL` brez backfilla. Gl. `feedback-live-db-branch-safety`.
6. **Na produkciji nič ne brišemo** — sonde iz §5 so read-only. Gl. `feedback-prod-never-delete`.
7. **Začasni izpisi v `tmp/`**, nikoli razmetani po repu.
8. **Številke vrstic v tem dokumentu so iz stanja 2026-07-26** in se ob delu premikajo — vedno se
   ravnaj po **imenu simbola**, vrstica je samo pospešek.

---

## 2 · Odločitve, ki blokirajo pakete

Te so produktne, ne tehnične. Dokler niso odgovorjene, se paketi v desnem stolpcu ne začnejo.

| # | Vprašanje | Opcije | Blokira |
|---|---|---|---|
| **O1** | Ubeseditev percentila | (a) nevtralno »~X % jih je začelo pred tabo« (ujame se z obstoječima `by_now_percent`/`by_date_percent`) · (b) dvosmerni niz vezan na `timingBand`: »Med zgodnejšimi ~X %« / »Pozneje kot ~X % vrtnarjev« | **P4** |
| **O2** | `pooledTotal` = uporabnik-sezone | (a) spremeni agregat na distinct uporabnike čez sezone (migracija + rematerializacija) · (b) pusti agregat, prag `K_reliab` veži na `max(first_user_count)` po letu (samo klient+motor) · (c) pusti, dokumentiraj odstopanje | **P4**, delno **P6** |
| **O3** | Flag za Okolico | (a) ločen `kCommunityEnabled` · (b) en flag + `kDevPlusStub = false` kot obvezen korak v `docs/deploy-runbook.md` | **P9** |
| **O4** | R1 | (a) implementiraj kot samostojno pravilo z lastnim `message_key`, cooldownom in `validUntil` po `03 §R1` · (b) popravi `03 §R1` + `00-pregled-za-laika.md` (R1 = ojačevalec) in odstrani mrtvi ključ `suggestions.weather.window_open` iz i18n + generatorja | **P10** |
| **O5** | `plant_task_rule` na klientu | (a) odstrani (seed + catalog-sync pot + drift tabela) · (b) ostane kot priprava na offline motor, z zapisanim zakaj + testom | **P11** |
| **O6** | `suggestions.community.most_started` | (a) prevedi v opisno (»V tvoji okolici je to opravilo v teku.«) in razširi anti-steering varovalo na `suggestions.community.*` · (b) ubeseditev ostane, izjema zapisana v testu | **P10** |

> **Priporočila** (če se ne odločiš drugače): O1=(a), O2=(a) **le če gre pred prvim tekom crona**,
> sicer (b) · O3=(a) · O4=(b) · O5 odvisno od roadmapa offline motorja · O6=(a).

### Sprejeto — vse odločeno (2026-07-28)

| # | Odločitev | Kaj to pomeni v kodi |
|---|---|---|
| **O1** | (a) nevtralno | ✅ P4 |
| **O2** | (b) prag na `max(first_user_count)` | ✅ P4 |
| **O3** | (a) ločen `kCommunityEnabled` | ✅ P9 `7d06944` |
| **O4** | **(b) R1 ostane ojačevalec** | mrtvi ključ `suggestions.weather.window_open` ven; kartica dobi **pripono**, ko je `dry_window` postavljen — motor parameter že pošilja (N4), zdaj dobi bralca. Popravi tudi `03 §R1` in `00-pregled-za-laika.md`. |
| **O5** | **(a) odstrani s klienta** | seed (1127 vrstic) + catalog-sync pot + drift tabela `plant_task_rule` ven. Pravila živijo na strežniku, kjer jih motor bere; ob offline motorju se vrne iz git zgodovine — takrat **z bralcem in testom**. |
| **O7** | **odmik ob ignoriranju** (ne kvota na sezono) | `[1,1,2,4]`× lasten cooldown po `n` zaporednih ignoriranjih, po 4. tiho do konca sezone; vsako dejanje niz prekine. Vir je `suggestion.status = 'expired'` — brez nove tabele, stolpca ali migracije. Kvota na sezono je bila zavrnjena, ker ne loči »kosi vsak teden, opomni ga« od »ne kosi nikoli«. Merjeno: 156→52 kartic, 129→38 pushov, R3 iz 95 na 8 pushov. |
| **O6** | **(a) opisno** | »Večina vrtnarjev v tvoji okolici je to letos že začela.« Brez odstotka; anti-steering varovalo se razširi na `suggestions.community.*`. Razlog: P4 je isto uokvirjanje odstranil s plačljivih kartic, brezplačni pas ga ne sme vrniti skozi zadnja vrata — in v prvi sezoni se delež itak še premika (N24). |

**S tem P10 in P11 nista več blokirana.**

---

## 3 · Paketi

Vrstni red je hkrati priporočen vrstni red dela. Odvisnosti so izrecno navedene.

---

### P1 · Dismiss deluje + tolerantni parser *(kritični par — nikoli ločeno)*

**Zakaj skupaj:** `dismissedUntil()` se kliče **znotraj** pogoja, ki nikoli ni resničen. Bug A1
danes maskira bug A2. Kdor popravi samo dismiss, prvemu uporabniku, ki tapne »Ne zanima me«,
**trajno in tiho zlomi inkrementalni sync**.

**Datoteke**

| Pot | Kaj |
|---|---|
| `supabase/functions/smart-engine/housekeep.ts` | `dismissedUntil()` (~:42), `planHousekeeping()` pogoj `!logKeys.has(...)` (~:84), `kDismissDays` (~:21) |
| `supabase/functions/smart-engine/pipeline.ts` | emit → `suggestion_log` upsert (~:139-149) — **ne spreminjamo**, parcialni upsert je pravilen |
| `lib/core/sync/remote_mappers.dart` | `_dt` (~:184), `_dtOrNull`, `suggestionLogFromRemote` (~:358) |
| `lib/core/sync/sync_pull_service.dart` | pull `suggestionLogs` (~:132-146) |
| `supabase/functions/smart-engine/signals.ts` | `=== 'infinity'` obravnava (~:342) — uskladi s sentinelom |
| `supabase/functions/smart-engine/housekeep_test.ts` | test »a dismissal already in the log is not re-muted« (~:96-102) — **obrniti** |

**Koraki**

1. **Strežnik neha pisati `'infinity'`** — `dismiss_scope === 'forever'` vrne konstanto
   `kMuteForeverDate = '9999-12-31T23:59:59Z'` (v `config.ts`, ne literal).
2. **Klient je vseeno tolerantnen** — `_dt`/`_dtOrNull` prestrežeta `'infinity'`/`'-infinity'` in
   vrneta sentinel oz. `null`. Nujno, ker so stare vrstice lahko že v bazi.
3. **Pogoj mute** naj bo »ni **muta**«, ne »ni **vrstice**«: zapiši mute, kadar je obstoječi
   `dismissed_until` `null` ali starejši od `row.updated_at`. Za to je treba `logKeys: Set<string>`
   zamenjati z `Map<string, SuggestionLogRow>` in podpis `planHousekeeping` prilagoditi.
4. **`signals.ts` straža 5b** prebere sentinel enako kot prej (primerjava datuma), `'infinity'`
   posebna veja postane odvečna → odstrani ali pusti kot fallback za stare vrstice (odloči ob kodi).
5. **Ustavi pull `suggestion_log`** — klient ga nikoli ne bere (gl. P11); s tem odpade cel razred
   napake. **Če P11/O5 še ni odločen, tega koraka NE delaj** — koraki 1–4 stojijo sami.

**DoD**

- `housekeep_test.ts`: dismissan predlog, ki **ima** log vrstico iz emita, **dobi** mute
  (obrnjen obstoječi test).
- `housekeep_test.ts`: dismissan predlog, ki že ima **svež** mute, se ne prepiše.
- `housekeep_test.ts`: `dismiss_scope='forever'` → `dismissed_until === kMuteForeverDate`.
- `pipeline_test.ts`: po zapisanem mute-u straža 5b kandidata **pobije**.
- `remote_mappers_test.dart`: `'infinity'`, `'-infinity'`, `null`, veljaven ISO → brez izjeme.
- `sync_roundtrip_test.dart` (ali nov): pull s poškodovano vrstico **ne** ustavi napredovanja
  kurzorja za ostale tabele.

**Commit:** `fix(engine): dismiss zapiše mute in klient prenese sentinel datum`

**Premislek za zapis (ne nujno v tem paketu):** kurzor je globalen — *katerakoli* parse napaka v
*katerikoli* tabeli trajno zaustavi napredovanje za vse. Per-table kurzor bi to omejil. Če se ne
lotimo zdaj, gre v `10-odprta-vprasanja.md`.

---

### P2 · Agronomska pravilnost motorja

**Datoteke**

| Pot | Simbol |
|---|---|
| `supabase/functions/smart-engine/rules_community.ts` | R6 gate `cdf.shareBy(week) >= kStartedShare` (~:57-60), uteži `kPercentStep`/`kStartedShare`/`kStrongShare` (~:14-17) |
| `supabase/functions/smart-engine/community.ts` | `shareBy` (~:105) |
| `supabase/functions/smart-engine/signals.ts` | `cadenceDays()` (~:192-199) |
| `supabase/functions/smart-engine/rules.ts` | R3 poraba `cadenceDays` (~:96), `kCadenceOverdueFactor` idr. (~:20-22) |
| `supabase/functions/smart-engine/dates.ts` | `msToDay` (~:38-39) |
| `supabase/functions/smart-engine/rules_agro.ts` | `Number(w.offset_min_days)` idr. (~:67, :90-91, :105-106, :242-243) |
| `supabase/functions/smart-engine/housekeep.ts` | `kDismissDays.R6 = 90` (~:21) |
| `supabase/functions/smart-engine/config.ts` | nove nastavljive vrednosti |

**Koraki**

1. **R6 zaključena okna** — takojšnja varovalka `if (share > kClosedShare) continue`
   (`kClosedShare` v `config.ts`, ne literal); pravi popravek je gate na **gostoto** `f(w)` v
   okolici tekočega tedna namesto na kumulativo. Naredi oboje: gostota kot primarni gate,
   `kClosedShare` kot varovalka.
2. **R6 dismiss** — `kDismissDays.R6 = 90` zamenjaj z »do konca okna« (isti mehanizem kot
   `month_window`/`frost_offset` v `dismissedUntil()`).
3. **`cadenceDays == 0`** — `if (cad <= 0) continue` v R3 (in kjerkoli se `cadenceDays` uporabi kot
   delitelj/prag). Mediana vrzeli je lahko 0, če so tri `done` opravila na isti dan.
4. **`NaN` → `RangeError`** — validacija `plant_task_rule.window` ob branju kataloga
   (`bundle.ts` `loadRules`): vrstica z manjkajočim/neštevilskim poljem se **preskoči + poroča**
   prek `reportError`, ne vrže. Danes ena taka vrstica pade pri **vsakem** uporabniku → vsi
   `error` → `last_run_date` se ne zapiše → dispatcher jih čez 40 min ponovi = neskončna zanka.

**DoD**

- `rules_community_test.ts`: teden 45 pri zaključeni krivulji → **0 kandidatov**; teden v odprtem
  oknu → kandidat. Mejno pri `kClosedShare` ±1 korak.
- `rules_community_test.ts`: `isoWeek('2027-01-01') === 53` → `shareBy(53) = 1.0` **ne** sme
  emitirati za noben sezonski tip.
- `signals_test.ts` / `rules_test.ts`: tri `done` opravila isti dan → `cadenceDays == 0` →
  R3 ne emitira (danes emitira večno).
- `rules_agro_test.ts`: pravilo brez `offset_max_days` → funkcija **ne vrže**, vrstica preskočena,
  ostali uporabniki obdelani.
- `housekeep_test.ts`: R6 dismiss traja do konca okna, ne 90 dni.

**Commit:** `fix(engine): R6 zaključena okna, cadence 0 in odporen razpored oken`

---

### P3 · FCM: 400 ni mrtev token + timeouti + pot okrevanja

**Datoteke**

| Pot | Simbol |
|---|---|
| `supabase/functions/_shared/fcm.ts` | `res.status === 404 \|\| res.status === 400` (~:83), `fetch` OAuth (~:31) in send (~:65) |
| `supabase/functions/smart-engine/index.ts` | izničenje `fcm_token` (~:220-228) |
| `lib/features/settings/data/profile_repository.dart` | `updateFcmToken` no-op straža (~:121-140) |
| `lib/features/notifications/application/fcm_token_service.dart` | registracija/refresh |
| `lib/core/database/tables/user_tables.dart` | `fcm_token_updated_at` (obstaja) |

**Koraki**

1. **Loči napake:** `404` **ali** `400` z `error.details[].errorCode === 'UNREGISTERED'` = res mrtev
   token → izniči. Golo `400` (INVALID_ARGUMENT — predolg naslov, neznan `channel_id`, slabo
   oblikovano sporočilo) = **napaka sporočila** → `reportError`, **token pusti pri miru**.
   > Poslabševalec, ki ga to odpravi: 400 je lastnost *sporočila*, ne naprave — ena regresija v
   > naslovu danes pobriše žetone **celemu paketu 25 uporabnikov**, ob vsakem tiku.
2. **`AbortSignal.timeout(...)`** na obeh `fetch` klicih (Open-Meteo ga v `weather.ts:37` pravilno
   ima). Vrednost v `config.ts`. Porabi `res.body` tudi ob uspehu (sicer ostane povezava odprta).
3. **Pot okrevanja:** klient re-asserta token, če je `fcm_token_updated_at` starejši od
   `kFcmTokenReassertDays` (`config.dart`) — obide no-op stražo, ki danes prepreči zapis, ker je
   lokalni drift še vedno enak izbrisani oblačni vrednosti.
   > Alternativi, če se izkažeta za boljši ob kodi: primerjava z oblačno vrednostjo namesto z
   > lokalno, ali bump `updated_at` ob izbrisu (a to odpre LWW clobber, ki ga je avtor zavestno
   > zapiral — komentar v `index.ts:222-225`).

**DoD**

- Nov `fcm_test.ts`: 404 → `false` (izniči) · 400 + `UNREGISTERED` → `false` · golo 400 → **ne**
  izniči, poroča · 500 → ne izniči.
- Nov test v `index` sklopu (gl. P7): `sendSuggestionPush` vrne `false` → payload updata je
  **točno** `{fcm_token: null}`, **brez** `updated_at`.
- `profile_repository_test.dart`: enak token + `fcm_token_updated_at` starejši od praga → **zapiše**;
  enak token + svež → no-op.

**Commit:** `fix(engine): FCM 400 ni mrtev token, timeout in ponovna prijava žetona`

---

### P4 · Statistični sklop Okolice *(blokira O1, O2)*

Štiri napake o istem grafu, skupaj ~40 vrstic kode. Ker je statistika edini razlog, da Okolica
obstaja, in ker je Okolica plačljiva funkcija, je ta paket produktno najbolj občutljiv.

**Datoteke**

| Pot | Simbol |
|---|---|
| `lib/features/community/data/community_stats.dart` | `seasonPercent` (~:134-139), `timingBand` (~:142-146), `buildSeasonCurve` `pooledTotal` (~:49), `seasonDensity` (~:93) |
| `lib/features/community/presentation/community_display.dart` | `communityTimingHeadline` (~:43-46) |
| `lib/features/community/presentation/widgets/community_frequency_card.dart` | `_myIndex` (~:109-115), `_bands` (~:101-105) |
| `lib/features/community/presentation/widgets/community_timing_card.dart` | prikaz `n` (~:85) |
| `lib/i18n/{en,sl,de}.i18n.json` | `community.detail.you_percent` |
| `supabase/functions/smart-engine/community.ts` | `pooledTotal` (~:91) — zrcalna napaka na strežniku |
| `supabase/functions/smart-engine/rules_community.ts` | `n` v `message_params` (~:94) |

**Koraki**

1. **Ubeseditev percentila (O1).** `seasonPercent` vrne kumulativo `F(w)·100`, niz pa obljublja
   »med prvimi«. CDF 0,92 → »med prvimi ~90 %« za nekoga med **zadnjimi 8 %**. Kartica si hkrati
   nasprotuje z `by_date_percent`, ki je pravilen in stoji tik pod naslovom.
2. **Frekvenčni graf (b).** Generiraj **fiksen** niz pasov `1..4, 5+` in beri `hist[band] ?? 0` —
   z eno spremembo odpravi (i) padec na `'5+'`, ko `myCount` ni ključ, in (ii) risanje luknjaste
   porazdelitve kot zvezne. Strežnik prazne pasove izpusti (`0009` `jsonb_object_agg`), zato je
   to napaka klienta, ne podatka.
3. **Tercil (d).** `timingBand` naj uporabi **mid-rank** `F(w−1) + f(w)/2` namesto inkluzivnega
   `F(w)`. Danes: če vsi (tudi ti) prvič opravijo v tednu 20, je `timingBand(1.0) = late` za
   **vsakega** uporabnika.
4. **`pooledTotal` (O2).** Šteje uporabnik-sezone: 3 sezone × 12 istih vrtnarjev → 36 → UI izpiše
   »med ~36 vrtnarji« **in prečka `kCommunityReliabilityMin = 30`**, zato pokaže številko namesto
   opisnega pasu. Popravek po O2; enako na strežniku (`community.ts` → `n` v `message_params`).

**DoD**

- `community_stats_test.dart`: `seasonPercent` pri CDF 0,04 / 0,50 / 0,92 / 0,95 → besedilo, ki je
  **resnično** (test naj trdi izpisan niz, ne števke).
- `community_stats_test.dart`: mid-rank tercil — strnjena sezona (vsi v tednu 20) → **ni** `late`
  za vse.
- Nov test za `_myIndex`: `myCount = 2`, `hist = {'1':4,'3':12,'5+':3}` → označen je pas **2**
  (in pas 2 obstaja z vrednostjo 0), ne `5+`.
- `community_stats_test.dart`: `pooledTotal` pri 3 sezonah istih 12 uporabnikov → prag `K_reliab`
  se **ne** prečka (po O2).
- `community_i18n_test.dart`: novi nizi v vseh treh jezikih, brez spolne zaznamovanosti.
- Obstoječi testi, ki zabetonirajo staro vedenje, se **popravijo**, ne izbrišejo:
  `community_stats_test.dart:188`, `community_task_screen_widget_test.dart:130`,
  `community_entry_points_test.dart:274-282`.

**Commit:** `fix(community): poštena ubeseditev percentila, pasovi frekvence in tercil`

---

### P5 · Grants in k-anonimnost *(rabi sonde iz §5 — najprej sonda, potem migracija)*

**Datoteke:** nova migracija (naslednja prosta številka, gl. `docs/deploy-runbook.md`),
`supabase/migrations/0009_m11_community_agg.sql` (referenca za politike),
`supabase/migrations/0007_engine_dispatch.sql` (referenca).

**Koraki**

1. **Grants funkcij.** `revoke execute … from public` **ne** odstrani Supabase privzetih grantov na
   `anon`/`authenticated` — natanko to je bil razlog za `0010_m11_grant_lockdown.sql`, a tam so
   zaprli tabele, funkcij ne. Nova migracija:
   ```sql
   revoke all on function public.engine_dispatch(), public.agg_refresh_all()
     from public, anon, authenticated;
   ```
   > ⚠️ **`k_privacy()` MORA ostati izvršljiv za `anon`/`authenticated`** — RLS politike
   > (`0009:80,86,89`) ga kličejo v kontekstu klicoče vloge. Revoke bi zaprl branje **vseh štirih**
   > agregatnih tabel. To je najbolj nevaren korak v celem planu.
2. **Vrstična k-anonimnost `activity_season`.** Politika bere `using (publishable)`, `publishable` pa
   je vsota čez **celotno skupino** → objavi se vrstica `first_user_count = 1`. Popravek:
   `using (publishable and first_user_count >= public.k_privacy())`. Ostale tri tabele so že
   pravilno gated na vrstico.
3. **`activity_frequency`.** Pri `n_users = 5` histogram tipa `{"1":1,…,"5+":1}` = točen letni
   števec vsakega posameznika; `percentile_cont` nad petimi vrednostmi vrne dejanski vrednosti dveh
   uporabnikov. Klientski `kCommunityReliabilityMin = 30` je **vljudnost, ne SQL prag**. Dvigni
   SQL prag za histogram/percentile na `k_reliab`.
4. **`revoke` za `engine_run`, `weather_cache`, `app_config`** — danes fail-closed (RLS brez
   politik), a `app_config` vsebuje `engine_endpoint` in ena napačna prihodnja politika ga odpre.

**DoD**

- Migracija je **idempotentna** (`drop policy if exists` + create) in additive-only.
- Zabeležena v `docs/deploy-runbook.md` (ledger PROD/STAGING).
- Ročna potrditev s sondo iz §5 **po** aplikaciji: `proacl` ne vsebuje `anon`/`authenticated` za
  obe funkciji, in **vsebuje** za `k_privacy`.
- Ročna potrditev, da branje agregatov z anon ključem **še vedno deluje** (sicer smo zaprli RLS).

**Commit:** `fix(db): zapri grante motorskih funkcij in vrstična k-anonimnost`

---

### P6 · Odrez podatkov in nesezonski tipi

**Datoteke**

| Pot | Kaj |
|---|---|
| `supabase/config.toml` | `max_rows = 1000` (~:18) — potrjeno |
| `lib/features/community/application/community_providers.dart` | fetcher brez `limit`/`order` (~:20-30) |
| `lib/features/community/data/community_repository.dart` | poizvedbe (~:71, :100, :203) |
| `supabase/functions/smart-engine/community.ts` | poizvedba `activity_season` (~:151-157) |
| `supabase/migrations/0009_m11_community_agg.sql` | `insert into activity_season` (~:189-207) |
| `lib/features/community/application/community_providers.dart` | `communitySeasonCurveProvider` |

**Koraki**

1. **`.limit(n)` + `.order()` + zaznava odreza** na obeh straneh. `activity_season` je ključen po
   `(resolution, bucket_key, task_type_id, plant_id, year, iso_week)` → 53 tednov × N rastlin × M
   let; že pri ~10 rastlinah in 2 letih presega 1000. PostgREST odreže **brez napake in brez
   signala** → CDF na delnih podatkih → percentil je napačen, a videti veljaven. Ob
   `rows.length == n` označi rezino kot nezanesljivo (ne prikaži odstotka).
2. **Nesezonski tipi.** `skupnost-agregacija.md §7.5`: `task_type.seasonal = false` → **brez**
   časovne krivulje. Stolpec obstaja in je napolnjen (`0006` postavi `seasonal = false` za `water`,
   `weed`, `stake`, `repot`), ampak cron ga ne filtrira in klient ga nikjer ne bere.
   → filter v cronu (`join task_type … where seasonal`) **in** varovalka v
   `communitySeasonCurveProvider` (tip ni sezonski → `null`), da stari materializirani podatki ne
   uidejo.
   > **Časovno občutljivo:** cron še ni tekel. Po prvem teku je treba rematerializirati.

**DoD**

- `community_repository_test.dart`: odgovor točno `n` vrstic → rezina označena kot nezanesljiva,
  odstotek se **ne** prikaže.
- Test, da poizvedba pošlje `order` (determinizem odreza).
- `community_stats_test.dart` ali widget test: `taskTypeId = 'water'` → `CommunityTimingCard` se
  **ne** izriše. (Opomba: `layout_matrix_test.dart:381-386` danes testira detajl prav z `'water'` —
  popravi na sezonski tip.)

**Commit:** `fix(community): omeji agregatne poizvedbe in izloči nesezonske tipe`

---

### P7 · Testna pokritost netestiranih poti *(pogoj za zaupanje v P1–P6)*

Vrzeli so **natanko na poteh, kjer so bile najdene napake**. Ta paket lahko teče vzporedno z
zgornjimi — ali celo pred njimi, kot mreža.

**Koraki**

1. **`index.ts` (266 vrstic, 0 testov).** Tu živijo opt-in (`weather_hints` vs `community_hints`),
   frekvenčna kapica (`last_push_date`), kill-switch `push_cap_per_day = 0`, izničenje tokena in
   avtorizacija `isServiceRole`. Za testabilnost izvozi `runForUser(db, …)` (kot `pipeline.ts`),
   ali testiraj prek `Deno.serve` handlerja s fake `db` in fake `fetch`.
   Minimalni nabor:
   - `{weather_hints:false, community_hints:true}` + top kandidat **R3** → 0 pushev,
     `last_push_date` **nespremenjen**; isti bundle + top **R6** → 1 push.
   - `notification_settings == null` → 0 pushev.
   - `last_push_date === localToday` → 0 pushev; `=== localToday − 1` → 1 push.
   - `push_cap_per_day = 0` → 0 pushev, predlog **vseeno emitiran**.
   - `sendSuggestionPush` → `false` → update payload **točno** `{fcm_token: null}`.
   - `fcmProjectId()` vrže → token **NE** pobrisan, `engine_run` se vseeno zapiše.
   - avtorizacija: anon JWT → 401 · poškodovan JWT → 401 · `GET` → 405 · `{"user_ids":[1,2]}` → 400.
   - izolacija napak: en uporabnik vrže → ostali obdelani.
2. **Guard 5d (cooldown po izvedbi)** — `pipeline.ts:63-71`, testirani so a, b, c, e, f, h.
   `cadence=14`, `lastDone=today−7` → **preživi**; `−6` → **pade**. `cadence=4` → `cooldownDone=3`;
   `−3` preživi, `−2` pade. `cadenceDays == null` → guard preskočen.
3. **Migracija drift v13 → v16.** `app_database.dart:195` sam pravi, da je to pot **produkcijske
   naprave**; testirana je le v8→v16. Najceneje: parametriziran loop `from = 8..15`.
4. **K-anonimnost natanko na pragu** — testi uporabljajo 3/4/12/20/40, nikoli **5**
   (`kCommunityPrivacyMin`) ali **30** (`kCommunityReliabilityMin`). Dodaj mejne (prag−1, prag, prag+1).
5. **Layout matrika za `suggestions`** — 0 zadetkov za »Suggestion«. Dodaj `SuggestionBand`,
   `SuggestionCard`, `SuggestionHistoryScreen` in `MainShell` s petimi zavihki (nemški `nav`:
   `Startseite / Aufgaben / Tagebuch / Garten / Umgebung` na 320 dp pri text×1.3).
6. **`fcm_token_service.dart` (0 %), `fcm_handler.dart` (14,8 %)** — poti »dovoljenje zavrnjeno«,
   »token refresh«, »odjava med `await waitForProfile`«, `start()` dvakrat → ena naročnina.
7. **CI:**
   - `deno check supabase/functions/**/*.ts` kot **ločen korak** — `deno test` tipsko preveri le
     module, dosegljive iz testov; `index.ts`, `bundle.ts`, `_shared/fcm.ts` **niso**.
   - parity test za generirani `_shared/push_i18n.ts` (obstaja za `catalog.sql` in
     `plant_task_rules.sql`; `push_i18n.ts` je v zgodovini veje že enkrat zastarel — `52a82a3`).
   - CI naj teče **tudi na tej veji**, ne le ob PR proti `main` (v 50 commitih ni tekel nikoli).
8. **Popravi šibke obstoječe teste:** `migration_v8_to_v9_test.dart` je napačno poimenovan (testira
   `onCreate`, ne nadgradnje) · `climate_service_test.dart` sintetični generator **podvaja**
   produkcijsko DOY formulo · `community_repository_test.dart` trdi točno število omrežnih klicev
   (zrcali implementacijo) · `plant_task_rules_seed_test.dart:95` je strožji od motorja.

**DoD:** vsi novi testi zeleni; CI izvaja `deno check`; pokritost `index.ts` > 0.

**Commit:** lahko dva — `test(engine): pokrij index.ts, guard 5d in migracijske poti` +
`ci: deno check in parity test za push_i18n`

---

### P8 · Offline in svežina Okolice

**Datoteke:** `lib/features/community/data/community_repository.dart` (~:65-87, cache ~:398-449),
`lib/features/community/presentation/community_landing_screen.dart` (~:107),
`lib/features/community/presentation/community_task_screen.dart` (~:149),
`lib/features/community/presentation/widgets/community_feed_row.dart` (`CommunityFeedMeta`),
`lib/i18n/*.i18n.json` (`community.empty_feed`).

**Koraki**

1. **Loči »premalo sosedov« od »ni podatkov«.** `_cachedRows` že zdaj pozna razliko — informacija
   se le ne prenese do UI. Danes uporabniku ob prvem zagonu v vrtu brez signala **trdimo neresnično
   dejstvo o gostoti skupnosti**.
2. **Indikator svežine** — mirna vrstica »podatki od {datum}«, ko `fetchedAt` ni današnji.
   CLAUDE.md § Network & offline: »Zadnji znan state ostane viden … indikator je miren, ne
   alarmanten.« Danes je state viden, indikatorja ni.
3. **`RefreshIndicator`** na obeh zaslonih → invalidira `communityFeedProvider` /
   `communitySeasonCurveProvider`.

**DoD:** widget test za obe stanji (prazna rezina vs. odsotna rezina) · test, da zastarel cache
prikaže datum · layout matrika prenese novo vrstico v vseh treh jezikih.

**Commit:** `fix(community): loči offline od praznih podatkov in pokaži svežino`

---

### P9 · Flagi in navigacija *(blokira O3)*

**Koraki**

1. **Ločitev flagov (O3).** Danes `kSuggestionsEnabled` gate-a **oboje**: brezplačne predloge in
   plačljivo Okolico (`app_router.dart:98`, `main_shell.dart:60`, `home_screen.dart:212`,
   `task_detail_screen.dart:141`). Prižig predlogov torej prižge Okolico — in ker je
   `kDevPlusStub = true`, jo dobijo vsi zastonj, tease se ne pokaže. Doc-komentar na
   `kSuggestionsEnabled` Okolice sploh ne omenja.
2. **Cross-branch navigacijski test.** `community-task` je gnezdena v shell branchu Okolice, kliče
   pa jo `pushNamed` iz Domov (branch 0) in iz detajla opravila (branch 1). Testi uporabljajo
   **plosk router brez `StatefulShellRoute`**, layout matrika riše widgete brez routerja, feature je
   flag-dark → **ta pot ni nikoli tekla**. V isti kodni bazi je tak vzorec že sesul navigator
   (`suggestion_history_screen.dart:229-231`: »pushing the nested route would duplicate the shell
   page key and crash the navigator«). Po `skupnost-agregacija.md §12.1` sta to **glavni poti
   odkritja** Okolice.
   → en widget test z **realnim** `StatefulShellRoute`: Domov → tap → detajl → back → menjava
   zavihka; isto z detajla opravila.
3. **Runbook:** `kDevPlusStub = false` kot obvezen korak prižiga v `docs/deploy-runbook.md`
   (ne glede na izid O3).

**DoD:** test z realnim shell routerjem zelen · flag(i) dokumentirani v `config.dart` in runbooku.

> **Izjema od pravila »vsak popravek dobi test«:** dokazati, da navigator res ne pade, zna samo
> naprava. Test je nujen, a ne zadosten → gl. P12.

**Commit:** `fix(app): loči flag Okolice in pokrij prehode med shell branchi`

---

### P10 · Jezik, besedila in dokumentacija *(blokira O4, O6)*

> **Stanje 2026-07-28 (paket 4): P10 je ZAKLJUČEN.** Paket 3 je opravil korake **3** (O6),
> **4** (O4) in **5** (`screen-map.md`) + najdbe **N13, N17, N20, N21, N26**; paket 4 je zaprl
> še **1, 2, 6, 7** + novi **N27, N28**.
>
> Kar je pri tem odstopalo od naloga: spolno zaznamovanih nizov je bilo **devet, ne sedem**
> (N28 — `harvest.sheet_title`, `notif_priming.why`), in obljuba »(V2)« je imela **šesto** mesto,
> ki ga varovalo iz N13 ni videlo, ker je iskalo dobesedni `(V2)`, niz pa piše `(V2, neobvezno)`
> (N27). Korak 2 je bil **odločitev, ne prevod** — gl. spodaj.

**Koraki**

1. **Spolno nevtralna slovenščina** (pravilo postavljeno v `02f2c76`, dva nova niza sta ga takoj
   prekršila):
   - `suggestions.past_intro` »…kako si se **odzval**« → brezosebno
   - `settings.suggestions_history_sub` — isto
   - `community.standing.band` `zgoden/običajen/pozen` → prislovi `zgodaj/običajno/pozno`
     (sosednji `community.detail.you_band` je že pravilno nevtraliziran)
   - **Pred-obstoječe, a na prvem zaslonu ob namestitvi:** `onboarding.welcome_title` / `auth.title`
     »Dobrodošel v Tendask« · `onboarding.log_body` »Pokosil, zalil, pognojil?«
2. **Push telesa v i18n in v pravi register.** `tool/gen_push_i18n.dart:52-61` ima trdo zapisane
   fallback nize v **vikanju** (»Vaš vrt čaka na vas«, »Tapnite…«; de »Ihr Garten…«), aplikacija je
   povsod tikanje/»du«. `pushBody()` **vedno** vrne ta fallback → vsak push ima generično telo v
   napačnem registru, in ker nizi niso v `lib/i18n/*.i18n.json`, jih ne ujame noben i18n test.
   → prestavi v i18n, generator pobere od tam. Ob tem: generator pobira **vsak** leaf `title` pod
   `suggestions` (tudi UI ključe `done_sheet`, `remove`) — zoži.
3. **Anti-steering (O6).** `community_i18n_test.dart:37` bere samo poddrevo `community`. Edini niz s
   socialnim dokazom je `suggestions.community.most_started.body` — in ta gre, za razliko od vseh
   `community.*`, na **brezplačni pas na Domov**, daleč od pojasnila »Nikoli ti ne pove, kaj naj
   narediš.«
4. **R1 (O4).** Motor sestavi kandidate iz R5/R7/R3/R2/R6; R1 je zgolj `dryWindowBonus`. Posledice:
   `suggestions.weather.window_open` **ni nikoli** emitiran (mrtev ključ v i18n **in** v generiranem
   `push_i18n.ts`), lastni cooldown/`validUntil`/dismiss iz `03 §R1` se ne uveljavijo, in kadar
   `weather_guard` pobije R3/R5 kandidata, suho okno ne more emitirati nič.
   »Jutri je suho okno« je pri tem ena od nosilnih zgodb v `00-pregled-za-laika.md` in
   `docs/pametni-motor.md`. **Ne pusti obojega** — ali pravilo, ali popravljena spec.
5. **`docs/screen-map.md`** — razglašen vir resnice za zaslone, ne pozna treh M11 površin:
   pasu predlogov na Domov, rute `/suggestions/history`, sekcije »PAMETNI PREDLOGI« v Nastavitvah.
   Dodaj tri vnose, označene s flagom.
6. **Odprti vprašanji, ki sta sprožilca že dosegli** (`10-odprta-vprasanja.md`):
   - **#13** write-once `agg_context` trigger — vezan na M11.16, ki je `[x]`; agregati na ta polja
     **že štejejo**, trigger pa ne obstaja (`create trigger` = 0 zadetkov). App-level guard obstaja
     (`tasks_repository.dart:558-582`), DB-level ne — CLAUDE.md izrecno zahteva DB-level invariante.
   - **#14** `engine_endpoint` s **produkcijskim** URL-jem v `0006:179`; staging že obstaja.
     Tveganje je **zamrznjeno** z `engine_enabled` guardom, ne odpravljeno: ob prižigu na stagingu
     bi staging cron POST-al na produkcijsko funkcijo.
7. **Manjši doc-dolg:** `03 §Akcije` in `08 §8.1` še opisujeta stari »Načrtuj« (koda odpre
   predizpolnjen obrazec, `b9e5b3f`) · `community-flow_v3.html` še oglašuje »Preizkusi 14 dni«
   (po FR-20 prepovedano; koda je pravilna) · `ui-katalog.md` ne našteva `LoadErrorHint`,
   `DayHeader`, `TopToast`, `DashboardHint` · `skupnost-agregacija.md §12.1` še omenja izbirnik
   obsega, ki je z odločitvijo A odpadel.

**Kako je bil zaprt korak 2 (odločitev, 2026-07-28).** Od treh možnosti — več markerjev na
strežniku · v push samo telesa brez markerjev · generično telo, a v tikanju in v i18n — je izbrana
**tretja**. Razlog je, kdo zna napolniti marker: telo nosi `{subject}`, `{frost_date}`,
`{window_end_date}`, torej katalozne oznake, **uporabnikovo lastno ime rastline** in obliko datuma
v njegovem jeziku — strežnik bi moral podvojiti vse tri, sicer na zaklenjenem zaslonu piše
dobesedni `{subject}` (M11.12 že enkrat). Naslov specifičnost obdrži (`{task}` napolni strežnik),
telo je generično in `push.fallback_*` živita v `lib/i18n/`. Zapisano v `03 §Sporočila`.
Zajem generatorja je zožen na `message_key`, ki jih motor lahko emitira (`PlantTaskRulesSeed` +
trije generični): 66 → **64** vnosov na jezik, `done_sheet` in `remove` ven.

**DoD — izpolnjen, z artefaktom pri vsaki postavki:**
- i18n testi zeleni v treh jezikih · anti-steering varovalo pokriva `suggestions.community.*`
  (paket 3) · `screen-map.md` in `10-odprta-vprasanja.md` posodobljena
- `gendered_wording_test.dart` — pregleda **cel** `sl.i18n.json`; na verziji izpred popravka
  najde **9** zadetkov, po njem 0
- `launch_wording_test.dart` — par `notif_priming.benefit_nearby(_live)` in vzorec `\(v2\b`
- `test_fixture_keys_test.dart` — vsak i18n ključ iz kateregakoli testa obstaja v vseh treh
  katalogih; na `layout_matrix_test.dart` izpred paketa 3 pade na `suggestions.season.window_open`
- `push_text_test.ts` — edini marker v push naslovu je `{task}` (surov katalog, ne napolnjen niz:
  `pushTitleFor()` požre vsak marker, zato bi test nad napolnjenim nizom ničesar ne dokazal),
  telo brez markerjev, UI ključa nista v paketu · parity test `push_i18n.ts` zelen

**Commit:** ločeno — `fix(i18n): spolno nevtralni novi nizi in push v tikanju` +
`docs(m11): uskladi screen-map, R1 in odprti vprašanji`

---

### P11 · Higiena kode *(blokira O5)*

**Mrtva koda** (vse potrjeno z grepom čez `lib`, `test`, `tool`, `supabase`):

| Kaj | Opomba |
|---|---|
| drift tabela **`plant_task_rule`** | 1127 vrstic seeda + catalog-sync pot + migracijski korak; na napravi **nima bralca** (motor bere iz Supabase) → **O5** |
| drift tabela **`suggestion_log`** | pulla se ob **vsakem** sync-u, **nima bralca**; hkrati vir P1 → ustavi pull |
| `activeSuggestionsCountProvider` + `watchActiveCount()` | badge, ki ne obstaja |
| `NotificationService.isReady` | bere ga le test |
| i18n `suggestions.toast.planned` | `_plan` toasta ne pokaže |
| `FrequencyStats.unit` / `.p50`, `CommunityFeedItem.distinctUsers7d`, `CommunityWeekly.distinctUsers7d` | nastavljeni, nikoli prebrani |
| SQL `activity_recent.refreshed_at`, `bucket_population.refreshed_at`, `activity_frequency.unit`, `plant_task_rule.confidence`/`.cadence` | 0 bralcev |
| TS knob `wind_transplant_kmh` | obstaja, `guards.ts:32` pa uporablja literal `20` |
| `seasonDensity`, `communityTimingLabel`, `CommunityRepository.bucketPopulation`, `NotificationService.suggestionPayload` | public brez zunanjega klicalca → `_` |

**Kršitve `CLAUDE.md`:**

- **Podvojeni widgeti** (»rdeč alarm že pri 2 klicalcih«): `_Rows` ×2 (`community_feed_list`,
  `community_standing_list`), pill ×3 (`_IntensityPill`, `_BandPill`, `_StatusChip`), tease blok ×2
  → `core/widgets/status_pill.dart`, `CommunityRowsCard`, `TeasedList<T>`. Vpiši v
  `docs/ui-katalog.md`.
- **>300 vrstic z več odgovornostmi:** `community_repository.dart` (460, štiri odgovornosti:
  razrešitev bucketov / remote agregati / lokalne drift poizvedbe / cache) · `suggestion_card.dart`
  (393: widget + 6 akcijskih tokov).
- **`dispose()`:** `FcmHandler._taps` + dve naročnini se nikoli ne zaprejo · `_archiveDio` nikoli ·
  `profileRowReadyForWrite` / `waitForProfile` puščata naročnino ob timeoutu (`.timeout` na
  `Future` **ne** prekliče `firstWhere` naročnine).
- **Slovenščina v kodi:** imena Android kanalov (»Opomniki opravil«, »Pametni predlogi«, »Nežna
  povabila k dnevniku«) — **vidna uporabniku v sistemskih nastavitvah**, mimo `t.*` · slovenska
  imena testov (`suggestion_band_widget_test.dart:263+`).
- **`Map<String,dynamic>` v presentation** + **dvojno dekodiranje** istega `messageParams`
  (`suggestion_text.dart:19,21` in `suggestion_card.dart:190`).
- **Supabase query builder v `application/`** (`community_providers.dart:3,19-30`) → v `data/`.
- **`_exactAlarmsAllowedProvider` v `presentation/`** → v `application/`.
- **Magične vrednosti izven `config`** — obe strani: `guards.ts:31-41` (hardcodirane vremenske meje
  kljub obstoju knoba), `rules.ts:20-22`, `rules_community.ts:14-17`, `pipeline.ts:12`,
  `housekeep.ts:21` · Dart: 400 ms animacija, `fontSize: 22`, emoji fallbacki.
- **Razhajanja Dart ↔ Deno:** retry (`weather.ts` 4 poskusi vs `config.dart` 3 — in **nobena** stran
  ne ustreza CLAUDE.md »maks 3, 1s→3s→9s«) · Open-Meteo timeout (10 s skupno vs connect 10 + receive
  20, s komentarjem, da se je 10 s izkazalo za pretesno).
- **`kSupplyTaskTypes` podvaja `task_type.consumes_supplies`** in se z njim **ne ujema**
  (`overseed`, `topdress` nimata zastavice). Katalog je pravi vir.
- **`community_cache` se nikoli ne počisti** (samo `clearAllData`) — rast je neomejena.

**Commit:** dva ali trije — `refactor(community): en pill/rows/tease widget` ·
`chore: odstrani mrtvo kodo M11` · `fix: dispose naročnin in poenoti retry/timeout`

---

### P12 · On-device dimni test *(zadnji korak pred prižigom)*

Po `12-dokoncanje-m11.md` korak 14. Brez tega P9 ni dokazan.

- `kSuggestionsEnabled = true` v lokalnem buildu, naprava prek USB.
- **Prižgi zaslon:** `adb shell svc power stayon true` kot prvi korak seje.
- Koraki v `tmp/steps.txt` + `./tool/adb_run.ps1`, napisi (`taptext`), ne koordinate.
  `adb input text` ne tipka šumnikov.
- **Preveri:** Domov → pas predlogov → »V tvoji okolici ⬡« → detajl → back → menjava zavihka ·
  detajl opravila → kartica Okolice → detajl · Nastavitve → Pretekli predlogi · push tap iz ozadja
  (deep link) · vse troje offline.
- Opažanja opisuj po **ADB screencapu**, ne po spominu.

---

## 4 · Kritična pot in odvisnosti

```
P1 ──┐
P2 ──┤
P3 ──┼──► P7 (testi) ──► P12 (naprava) ──► PRIŽIG
P4 ──┤        ▲
P6 ──┘        │
P5 (rabi sonde §5) ──┘
P8, P9, P10, P11 — vzporedno, brez odvisnosti med sabo
```

- **P1 je prvi.** Največji učinek, nič odločitev, in odpravi napako, ki bi jo drug popravek
  aktiviral.
- **P6 (nesezonski tipi) je časovno občutljiv** — pred prvim tekom crona, sicer rematerializacija.
- **P4 čaka na O1/O2**, in če gre O2 v spremembo agregata, mora tudi ta pred prvi tek crona.
- **P5 čaka na sonde.** Brez `proacl` ne vemo, ali je problem resničen.
- **P7 lahko teče prvi** kot mreža, če se komu ljubi pisati teste pred popravki.
- **P12 je zadnji**, po vsem ostalem.

---

## 5 · Read-only sonde (brez njih trije odgovori ne obstajajo)

> Proti PROD **samo branje**. Gl. `feedback-prod-never-delete`, `feedback-verify-db-state-not-memory`,
> `docs/deploy-runbook.md` (linked = PROD).

```sql
-- S1 · Grants motorskih funkcij (blokira P5)
select proname, proacl
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
 where nspname = 'public'
   and proname in ('engine_dispatch','agg_refresh_all','k_privacy');

-- S2 · Shema pg_net (če je v 'extensions', se net.http_post pod search_path='' ne razreši)
select extname, nspname
  from pg_extension e join pg_namespace n on n.oid = e.extnamespace
 where extname in ('pg_net','pg_cron');

-- S3 · Dejanska oblika prod tabel proti 0006/0009
\d suggestion
\d suggestion_log
\d activity_season
\d activity_frequency
\d plant_task_rule
```

**Zakaj S3:** migracije uporabljajo `create table if not exists`, kar **tiho preskoči** obstoječo
tabelo z drugačno obliko — migracija »uspe«, ledger zapiše »aplicirano«, razlika ostane **nevidna za
vedno**. Komentarji v `0006`/`0009`/`0011` sami priznavajo, da 0006–0010 že živijo izven CLI
ledgerja. `alter table … add column if not exists` je varen, `create table if not exists` ni.

**S4 (za P7/A7):** privzeti TTL `net._http_response` na tem projektu — pg_net shrani odgovore edge
funkcije, ki danes vsebujejo debug dump vrtov 25 uporabnikov.

---

## 6 · Odprto vprašanje procesa

**Merge zdaj ali po popravkih?**

- *Merge zdaj:* veja je zelena in flag-dark, `main` dobi 50 commitov, popravki gredo kot običajni
  `fix:` commiti na `main`. Manj tveganja za razhajanje veje, ki je že enkrat rabila uskladitev
  (`docs/m11/11-poravnava-v-main.md`).
- *Popravi najprej:* `main` nikoli ne vidi znanih blokerjev, zgodovina je čistejša, a veja živi še
  8–10 commitov in tveganje razhajanja raste.

**Predlog:** merge zdaj (funkcija je dark, tveganja ni), popravki kot samostojni `fix:` commiti na
`main`. Odločitev je tvoja.

---

## 7 · Sklici

**Poročila pregleda** (podlaga tega plana, z dokazi in številkami vrstic):
- `tmp/review-m11/POVZETEK.md` — skupni povzetek, po točkah problem/rešitev/opcije/priporočilo
- `tmp/review-m11/pm-review.md` — produktni pregled + matrike pokritosti (pravila, zasloni, obljube)
- `tmp/review-m11/engineer-review.md` — tehnični pregled, mrtva koda, kršitve CLAUDE.md, sonde
- `tmp/review-m11/tester-review.md` — pokritost po datotekah, manjkajoči scenariji, CI

**Specifikacija M11** (vir resnice za *kaj* gradimo):
- `docs/m11/README.md` — kazalo + arhitekturne odločitve
- `docs/m11/03-pravila-r1-r7.md` — R1–R7, straže 5a–5h, guard key, akcije kartice
- `docs/m11/04-supabase-shema.md` — SQL, RLS, pg_cron, edge funkcija
- `docs/m11/05-drift-shema.md` — drift + migracija + kdo bere/piše
- `docs/m11/08-flutter-arhitektura.md` — providerji, repozitoriji, Okolica, tease
- `docs/m11/09-koraki.md` — izvorni tasklist M11.1–M11.21
- `docs/m11/10-odprta-vprasanja.md` — #13, #14 (gl. P10)
- `docs/m11/12-dokoncanje-m11.md` — kontrolni seznam zaključka (koraka 13, 14 nista izvedena)

**Širši kontekst:**
- `docs/skupnost-agregacija.md` — statistični model V2 (§7.2 ubeseditev, §7.5 sezonskost,
  §7.7 imenovalec, §12.1 poti odkritja)
- `docs/pametni-motor.md`, `docs/koncept.md` §7.12–§7.14
- `docs/screen-map.md` — vir resnice za zaslone/rute/CTA (gl. P10)
- `docs/ui-katalog.md` — komponentni katalog (gl. P11)
- `docs/deploy-runbook.md` — ledger PROD/STAGING, koraki prižiga (gl. P5, P9)
- `docs/tendask-plus-rollout-plan.md` — FR-20 (brez cene/URL/CTA v aplikaciji)
- `CLAUDE.md` — izvršljiva pravila kode
