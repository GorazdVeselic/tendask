# Poglavje 9 — Roadmap M11: koraki z DoD (delovni tasklist)

> En korak = en commit (delovni dogovor). Pred vsakim commitom vprašaj. Kompleksnost:
> S (< pol dneva) · M (dan) · L (2–3 dni) · XL (teden). Vrstni red = odvisnostni vrstni red;
> 🤖 = agent sam · 👤 = potreben uporabnik (konzole, skrivnosti, naprava).

## Faza A — temelj (shema + klima + seed)

### M11.1 — Supabase migracija 0005 (smart engine shema) `[x]`
SQL iz `04` §4.1–4.3: novi stolpci (profile/task/task_type), `plant_task_rule`, `suggestion`,
`suggestion_log`, `engine_run`, `weather_cache`, `app_config` (+seed vrednosti), `k_privacy()`.
- **DoD:** `supabase db push` uspe; RLS preverjena ročno (anon bere `plant_task_rule`, ne bere
  `suggestion_log` tujega; authenticated bere/piše samo svoje `suggestion`); **GDPR cascade
  preverjen** (testni uporabnik s `suggestion`/`suggestion_log`/`engine_run` vrsticami →
  `delete_account()` → vse izginejo); obstoječi APK (vc2) ob pull-u NE crasha (tolerantni
  parser — nova polja ignorira).
- **Odvisnosti:** — · **Kompleksnost:** M
- **Commit:** `feat(db): M11 shema motorja — plant_task_rule, suggestion, app_config`

### M11.2 — drift migracija (zrcalo) + agg_context štemplanje `[x]`
`05` §5.1–5.3 + 5.5: profile +5 stolpcev, task.aggContext, task_type.seasonal, tabeli
suggestion/suggestion_log, schemaVersion bump, sync registracija (pull+push po 05), mappers.
TasksRepository ob `done` štemplja `agg_context` (write-once kot weather; ohrani ob
`↩ Na čaka`). **GDPR izvoz:** `exportUserData()` razširi s `suggestion` + nova profile polja
(05 §5.3).
- **DoD:** `flutter test` zelen (migracijski test od stare sheme); ✓ na opravilu zapiše
  `agg_context` z vrednostmi iz profila (drift inspekcija); sync round-trip (push+pull) za
  suggestion vrstico deluje proti dev Supabase; izvozni JSON vsebuje suggestion vrstice +
  climate polja.
- **Odvisnosti:** M11.1 · **Kompleksnost:** L
- **Commit:** `feat(db): drift zrcalo M11 sheme + agg_context posnetek ob opravljeno`

### M11.3 — Climate profile fetch (naprava) `[x]`
`07` v celoti: `ClimateService` (archive API klic na centroid r7, bucket algoritem, frost
mediane), vključitev v LocationRepository (set/clear/letni re-fetch), zapis v profile.
- **DoD:** unit testi `computeClimateProfile` (sintetični 10-letni vhod → pričakovani bucket,
  frost DOY mediani, frost-free primer); na napravi: nastavitev lokacije napolni
  `climate_profile`+`climate_bucket`+`timezone` (vidno v Supabase po syncu); offline
  nastavitev lokacije NE blokira (profil ostane null, dopolni ob naslednjem zagonu z mrežo).
- **Odvisnosti:** M11.2 · **Kompleksnost:** L
- **Commit:** `feat(weather): klimatski profil + koš + frost datumi iz Open-Meteo arhiva`

### M11.4 — plant_task_rule seed (61 pravil) `[x]`
Preveri vse `(verify)` vire iz `01` (WebFetch/ročno; nepotrjene vire zamenjaj ali pravilo
izpusti). `lib/data/seed/plant_task_rules_seed.dart` + drift tabela (05 §5.4) + seed_service +
catalog_sync pull + `tool/gen_rules_sql.dart` → `supabase/seed/plant_task_rules.sql` → apply.
- **DoD:** vsa seedana pravila imajo potrjen source_ref (brez `(verify)` v seedu); count v
  Supabase == count v bundlu; JSON `window` validiran proti shemi anchorja (test);
  `flutter analyze` čist.
- **Odvisnosti:** M11.1, M11.2 · **Kompleksnost:** L
- **Commit:** `feat(catalog): seed agronomskih pravil plant_task_rule (61 pravil z viri)`

## Faza B — FCM

### M11.5 — Firebase projekt + flutter integracija 👤🤖 `[x]`
`06` §6.1: Firebase projekt (👤 konzola), google-services.json, gradle plugin, pubspec
(`firebase_core`, `firebase_messaging` — potrjena v tech-stack §1 za M11), kanal `suggestions`.
- **DoD:** app se zbuilda + zažene z inicializiranim Firebase; `flutter analyze`/test zelena;
  brez regresij obstoječih lokalnih obvestil (ročna preverba na napravi).
- **Odvisnosti:** — (vzporedno s fazo A) · **Kompleksnost:** M
- **Commit:** `feat(notifications): Firebase FCM integracija (projekt, gradle, kanal)`

### M11.6 — FCM token + opt-in UI `[x]`
`06` §6.2 + 6.5: FcmTokenService, profile.fcm_token pisanje/sync, signOut čiščenje; zaslon 22
stikali weather/community hints oživi (notification_settings ključa že obstajata).
- **DoD:** po prijavi + dovoljenju je token viden v Supabase profile; onTokenRefresh prepiše;
  signOut ga ponulli PRED odjavo; stikali pišeta notification_settings (sync round-trip).
- **Odvisnosti:** M11.2, M11.5 · **Kompleksnost:** M
- **Commit:** `feat(notifications): FCM token v profilu + granularen opt-in (zaslon 22)`

### M11.7 — FCM handlerji + deep link `[x]`
`06` §6.3 + 6.4: onMessage/onMessageOpenedApp/getInitialMessage, route `/?suggestion=<id>`,
highlight na pasu (placeholder do M11.13 — navigacija na Domov).
- **DoD:** testni push (Firebase konzola → token) v foreground pokaže lokalno notifikacijo,
  v background sistemsko; tap odpre Domov (ročno na napravi).
- **Odvisnosti:** M11.5 · **Kompleksnost:** M
- **Commit:** `feat(notifications): FCM foreground/background handling + deep link na Domov`

## Faza C — motor (strežnik)

### M11.8 — Edge Function skeleton + signalni sloj `[x]`
`supabase/functions/smart-engine/`: auth guard, batch loop, loadUserBundle, weather_cache +
Open-Meteo fetch (h3-js centroid), buildSignals (VSI signali iz `02`), guard evaluator (§G).
Brez pravil — funkcija vrne izračunane signale v debug odgovoru (za test).
- **DoD:** Deno unit testi signalov (sintetični bundle + vremenski JSON → pričakovane
  vrednosti vseh signalov + guard kod); `supabase functions deploy smart-engine`;
  ročni invoke z dev uporabnikom vrne signale; weather_cache vrstica nastane (1 klic / celica / dan).
- **Odvisnosti:** M11.1, M11.3 (klima v profilu) · **Kompleksnost:** XL
- **Commit:** `feat(engine): smart-engine edge function — signalni sloj + weather cache`

### M11.9 — Pravila R3 + R2 (zgodovina) `[x]`
`03`: R3 (cadence zamuda; mediana zadnjih 5 + default_cadence fallback) in R2 (obletnica) +
skupne straže (cooldown, dismissed, dedup planned, cooldown-po-izvedbi) + ocena + emit v
`suggestion` + suggestion_log update. (R3/R2 prva: ne rabita plant_task_rule.)
- **DoD:** Deno testi: sintetična zgodovina → determinističen izhod (zamuda 10 dni brez
  vremena → ni emita; +suho okno → emit; dismissed → nič; planned → nič); ročni tek na dev
  uporabniku ustvari suggestion vrstice.
- **Odvisnosti:** M11.8 · **Kompleksnost:** L
- **Commit:** `feat(engine): pravili R3 (zamuda ritma) in R2 (obletnica) s stražami`

### M11.10 — Pravili R5 + R7 (agronomski sloj) `[x]`
`03`: R5 (month_window regionalizacija + frost_offset + frost_gate + bucket filter +
override semantika) in R7 (veriga growth_stage). R1 ojačitve (+score) za oba.
- **DoD:** Deno testi: (koš, frost datuma, pravilo) → pričakovano okno (vzorci: jablana
  teden 2–11; paradižnik setev −56..−42; presaditev po harden_off+frost_gate; hortenzija dve
  pravili ne hkrati); polobla/Δ-clamp test; veriga: done korak K → predlog K+1, K+1 done → nič.
- **Odvisnosti:** M11.8, M11.4 · **Kompleksnost:** XL
- **Commit:** `feat(engine): pravili R5 (sezonska okna, frost-anchor) in R7 (veriga sadik)`

### M11.11 — Pravilo R1 + R4 + rangiranje/kapica `[x]`
`03`: R1 (vremensko okno nad R3/R5 potrebo), R4 obogatitev (za kSuppliesEnabled flip),
dedup med kandidati, rank, band_max_active, housekeeping (expired, dismissed→log).
- **DoD:** Deno testi celega cevovoda (3 scenariji iz `03` §Cevovod: dež → R1 nič; suho+zamuda
  → en emit z 4.0; 5 kandidatov → top 3); determinizem (isti vhod 2× → identičen izhod).
- **Odvisnosti:** M11.9, M11.10 · **Kompleksnost:** L
- **Commit:** `feat(engine): R1 vremensko okno, R4 zaloga, rangiranje in frekvenčna kapica`

### M11.12 — Dispatch cron + FCM pošiljanje `[x]`
`04` §4.7 (engine_dispatch + pg_cron + Vault secret 👤) + §4.8 (_shared/fcm.ts;
`tool/gen_push_i18n.dart` generira `_shared/push_i18n.ts` iz slang JSON-ov — nov mini tool;
UNREGISTERED handling, quiet-hours/cap check, engine_run.last_push_date).
- **DoD:** na dev: pg_cron sproži batch ob lokalni 07:00+ (simulacija: ročni
  `select engine_dispatch()`); push prispe na fizično napravo z naslovom v jeziku profila;
  drugi tek isti dan NE pošlje (kapica); opt-out uporabnik ne dobi pusha, suggestion vrstica
  pa nastane.
- **Odvisnosti:** M11.8–M11.11, M11.6 · **Kompleksnost:** L
- **Commit:** `feat(engine): dnevni dispatch (pg_cron) + FCM pošiljanje top predloga`

## Faza D — UI predlogov

### M11.13 — Pas predlogov na Domov (Načrtuj/Opusti/⋯) `[x]`
`08` §8.1–8.2 + `03` §Akcije: SuggestionRepository, providerji, SuggestionBand + kartica,
plan/dismiss flow, **⋯ action sheet (»Že opravljeno« z mini-sheetom datuma + done task;
»Ne predlagaj več tega« = dismiss forever; »Te rastline nimam več« = confirm + soft-delete
subjekta)**, deep-link highlight, i18n `suggestions.*` (en/sl/de — vseh 61 message_key +
akcije + disclaimer; **ločen pod-korak, ~400+ nizov — gl. 08 §8.4**), `dart run slang`.
- **DoD:** widget testi (Plan ustvari waiting task in skrije kartico; Dismiss skrije;
  »Že opravljeno« ustvari DONE task z izbranim datumom + `agg_context` in skrije;
  »Ne predlagaj več« zapiše `dismiss_scope='forever'`; »Nimam več« soft-deleta subjekt
  in kartica izgine prek stream filtra); na napravi: predlog iz dev motorja viden na pasu,
  statusi se sinhronizirajo v Supabase; izbrisan subjekt nikoli ne pusti žive kartice;
  prazen pas ne pušča luknje na Domov.
- **Odvisnosti:** M11.2, vsebinsko M11.9+ · **Kompleksnost:** XL
- **Commit:** `feat(home): pas pametnih predlogov z Načrtuj/Opusti`

### M11.13b — Zaslon Pretekli predlogi `[x]`
**Wireframe NE obstaja** — pred kodo skiciraj `docs/wireframes/` (CLAUDE.md pravilo: wireframe
pred zaslonom) ali zapiši zavestno izjemo v koncept §7.12.
`08` §8.1 (suggestion_history_screen) + `03` §Cevovod 2e (retencija 365 d v housekeeping):
`watchHistory()`, bralna časovnica s status čipi, vstopa (⋯ na pasu + Nastavitve), tap na
`Planned` odpre nastalo opravilo; i18n `suggestions.history_status.*`.
- **DoD:** widget test (zgodovina prikaže vse terminalne statuse, `new` izključen; tap
  planned → detajl opravila); housekeeping test retencije (vrstica > 365 dni → deleted);
  koncept §7.12 dopolnjen (zgodovina ≠ center obvestil).
- **Odvisnosti:** M11.13 · **Kompleksnost:** M
- **Commit:** `feat(suggestions): zaslon preteklih predlogov z odzivi uporabnika`

### M11.14 — E2E preverba motorja na napravi + poliranje `[ ]`
Cel krog na fizični napravi: vnos zgodovine → ročni engine invoke → push → tap → highlight →
Plan → task → naslednji tek ne podvoji. Uglasitev besedil, Sentry za engine napake
(console.error → Sentry stub ali log drain), disclaimer copy.
- **DoD:** scenarij iz `00-pregled-za-laika.md` §0.1 (paradižnik → pikiranje) izveden
  v živo na napravi brez ročnih popravkov; dnevnik napredka v roadmap.md dopolnjen.
- **Odvisnosti:** M11.12, M11.13 · **Kompleksnost:** M
- **Commit:** `feat(engine): e2e veriga paradižnika potrjena na napravi + poliranje sporočil`

### M11.15 — Unit testi motorja (regression suite) `[ ]`
Konsolidacija: Deno test suite (signali, vsa pravila, cevovod, regionalizacija) v CI
(GitHub Actions job `deno test supabase/functions/`); Flutter testi (repo, band, climate).
- **DoD:** CI zelen z novim jobom; pokritost pravil: vsak R + vsaka straža ima vsaj en test;
  README v functions mapi dokumentira lokalni zagon.
- **Odvisnosti:** M11.11, M11.13 · **Kompleksnost:** M
- **Commit:** `test(engine): celovita test suite motorja v CI`

## Faza E — V2 skupnost

### M11.16 — Supabase migracija 0006 (V2 agregati) + nočni cron `[ ]`
`04` §4.4–4.6: štiri tabele, eligible_user, agg_event, agg_refresh_all(), pg_cron, RLS.
- **DoD:** `db push` uspe; ročni `select agg_refresh_all()` na dev podatkih (sintetičnih ≥ 6
  uporabnikov) napolni vse štiri tabele; anon vidi SAMO vrstice ≥ K_privacy (ročna RLS
  preverba pod/nad pragom); idempotentnost (2× zapored → identično stanje).
- **Odvisnosti:** M11.1 (agg_context teče že od M11.2 — zgodovina se kopiči!) · **Kompleksnost:** L
- **Commit:** `feat(db): V2 agregatne tabele + nočni cron (feed, percentil, frekvenca)`

### M11.17 — Okolica: data + landing (feed »Ta teden«) `[ ]`
**Wireframe:** preveri, ali `community-flow_v3.html` pokriva landing IN detajl (M11.18) —
sicer pred kodo dopolni wireframe.
`08` §8.3: CommunityRepository (feed + population + cache tabela 05 §5.6), 5. zavihek ⬡,
landing »This week« (kvalitativen feed), obseg label, empty/cold-start stanja.
- **DoD:** widget test landing (feed iz mock repo); na napravi z dev agregati: feed se
  prikaže, offline odprtje bere včerajšnji cache; pod pragom → »še premalo vrtnarjev«.
- **Odvisnosti:** M11.16 · **Kompleksnost:** XL
- **Commit:** `feat(community): zavihek Okolica — feed Ta teden z dnevnim cache`

### M11.18 — Okolica: percentil + frekvenca (detajl opravila) `[ ]`
`08` §8.3: seasonCurve/frequency, CDF na napravi, fallback hierarhija, »Kje si ti« pregled,
detajl predloga (krivulja + »ti« marker + stolpci frekvence), K_reliab opisni način,
leto-1 omejeni način (§7.6).
- **DoD:** unit test CDF + fallback (sintetične rezine: r7 prazen → r6; rastlina → spust);
  widget test detajla; ubeseditve skladne s `skupnost-agregacija.md` §7 (brez % pod K_reliab,
  zaokrožanje na 10, n viden).
- **Odvisnosti:** M11.17 · **Kompleksnost:** XL
- **Commit:** `feat(community): časovni percentil in frekvenca s fallback hierarhijo`

### M11.19 — R6 (percentil okolice) v motorju + opt-in push okolice `[ ]`
`03` R6: engine bere agregate (fallback server-side), tease različica za ne-naročnike,
community_hints opt-in že iz M11.6.
- **DoD:** Deno test R6 (CDF nad/pod K_reliab; cooldown); push z odstotkom pride samo
  naročniku z vklopljenim community_hints.
- **Odvisnosti:** M11.11, M11.16 (+M11.20 za številko; do takrat tease) · **Kompleksnost:** M
- **Commit:** `feat(engine): R6 percentil okolice z opt-in obvestili`

### M11.20 — Tendask+ paywall + trial 👤🤖 `[ ]`
`04` §4.9 (entitlement, 0007) + `08` §8.3 paywall: tease overlay, start-trial Edge Function,
in_app_purchase + verify-purchase + play-rtdn (👤 Play Console produkt ~9,99 €/leto +
~1,99 €/mes, RTDN topic). **PRED začetkom: potrditev paketa `in_app_purchase` (ni v
tech-stack §1) + cen; wireframe za paywall/tease overlay NE obstaja — skiciraj pred kodo.**
- **DoD:** trial flow e2e na napravi (start → 14 dni → expired → tease); nakup v internem
  testu (Play sandbox) odklene; RLS: entitlement bere samo lastnik; brez Plus = tease,
  s Plus = polni pogledi.
- **Odvisnosti:** M11.17, M11.18 · **Kompleksnost:** XL
- **Commit:** `feat(billing): Tendask+ naročnina s 14-dnevnim preizkusom`

### M11.21 — Dokumentacija + koncept sync `[ ]`
Povzetek v `koncept.md` §7.13/§8 (»implementirano, gl. docs/m11/«), `roadmap.md` dnevnik,
`tech-stack.md` §1 (firebase paketa iz 'kasneje' v aktivno; in_app_purchase), memory update.
- **DoD:** dokumenti skladni z implementiranim stanjem; brez sklicev na neobstoječe.
- **Odvisnosti:** vse prejšnje · **Kompleksnost:** S
- **Commit:** `docs: M11 zaključek — uskladitev koncepta, sklada in roadmapa`

## Mini-zemljevid odvisnosti

```
A: M11.1 → M11.2 → M11.3 → M11.4
B: M11.5 → M11.6 → M11.7              (vzporedno z A)
C: (A) → M11.8 → M11.9 → M11.10 → M11.11 → M11.12 (rabi B)
D: M11.13 (rabi M11.2) → M11.13b → M11.14 → M11.15
E: M11.16 (rabi M11.1) → M11.17 → M11.18 → M11.19 → M11.20 → M11.21
```
Priporočen kalendarski vrstni red: A → B → C → D → (premor/validacija s testerji) → E.
