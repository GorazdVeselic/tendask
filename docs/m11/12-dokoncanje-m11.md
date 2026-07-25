# M11 — plan dokončanja (pot A: dokončaj v celoti → merge v main dark)

- **Status:** delovni plan (dogovorjeno 2026-07-25). Izhodišče: M11.1–M11.16 `[x]`, faza E odprta.
- **Odločitev:** **pot A** — dokončaj M11 v celoti (Okolica M11.17–19 + zaključek M11.21), nato merge M11 → main (dark). Razlog: zapri začeto, da se branch neha vleči.
- **Ključni scope popravek:** pod modelom FR-20 (zunanja licenca) **M11.20 (paywall / `in_app_purchase` / trial) ODPADE** — ni del M11. Okolico gradiva **za temnim flagom, brez Play Billing**; pravi Plus-gate (podpisan token) prižge **FR-20** ob prižigu zidu.
- **Tease:** `TeaseOverlay` gradiva kot **presentation widget** (blur + mirno »Na voljo v Tendask +« + nevtralni »Vnesi kodo«; **brez cene/URL/CTA k nakupu** — anti-steering §3.1 FR-20), gated na **stub entitlement** (`hasPlus` placeholder, v dev = true). Pravo branje tokena iz drift = FR-20.
- **Vse novo Okolica UI = flag-dark** (isti vzorec kot `kSuggestionsEnabled` / `kSuppliesEnabled`) — konsistentno z rollout planom (»deployaj sproti, razkrij enkrat«).
- **Povezave:** [`09-koraki.md`](09-koraki.md) (M11 tasklist + DoD), [`08-flutter-arhitektura.md`](08-flutter-arhitektura.md) (§8.3 Okolica), [`../skupnost-agregacija.md`](../skupnost-agregacija.md) (§7 ubeseditve, §12 zasloni), [`../feature-requests/tendask-plus-licensing.md`](../feature-requests/tendask-plus-licensing.md) (FR-20), [`../tendask-plus-rollout-plan.md`](../tendask-plus-rollout-plan.md), [`../screen-map.md`](../screen-map.md).

> En korak = en commit (delovni dogovor). Pred vsakim commitom vprašaj. Koraka 13–14 sta občutljiva (dotik `main` + naprava) — tam vprašaj pred pushom.

---

## Faza 0 — čiščenje protislovja

### Korak 1 — Doc: presezi paywall (M11.20 → FR-20)
- **Zajema:** v `09-koraki.md` označi M11.20 kot presežen → kazalec na FR-20; v `04-supabase-shema.md §4.9` (entitlement/0007) in `08-flutter-arhitektura.md §8.3` (paywall/tease/`in_app_purchase`) dodaj opozorilo »nadomešča FR-20, ne gradi po tem«. Zabeleži, da Okolica gradi dark, Plus-gate pride s FR-20.
- **Cilj:** nikjer več ne piše, da M11 gradi Play Billing; jasno, da 17–19 gredo dark.

## Faza 1 — zasnova (UI skladnost z realnimi zasloni)

### Korak 2 — Wireframe + realni zaslon: Okolica
- **Zajema:** preveri `docs/wireframes/community-flow_v3.html` proti dejanski 4-zavihkovni navigaciji (`screen-map.md` = vir resnice) — ali pokriva landing **in** detajl, kam sede 5. zavihek ⬡, ali se sklada z realnimi zasloni. Dopolni wireframe + `screen-map.md`, kjer manjka. **Brez kode.**
- **Cilj:** potrjena zasnova Okolice pred implementacijo (CLAUDE.md: wireframe pred zaslonom).

## Faza 2 — M11.17 Okolica: data + landing (XL → 4 koraki)

### Korak 3 — drift `community_cache` tabela
- **Zajema:** tabela iz `05 §5.6` (dnevni cache, drift-only, **brez Supabase migracije** — agregati že obstajajo iz M11.16), `schemaVersion` bump, mappers, migracijski test od stare sheme.
- **Cilj:** lokalna shramba za offline branje feeda.

### Korak 4 — `CommunityRepository` + modeli + providerji
- **Zajema:** `community_models.dart` (freezed: `CommunityFeedItem`, `SeasonCurve`, `FrequencyStats`), `feed()` + `bucketPopulation()` z dnevnim cache (cloud ≤1×/dan), providerji s fallback resolucijo košev (r7→r6→r5→climate→global). Unit testi.
- **Cilj:** podatkovna plast Okolice; UI bere iz providerjev, nikoli direktno iz Supabase.

### Korak 5 — 5. zavihek ⬡ + landing zaslon (flag-dark) + TeaseOverlay
- **Zajema:** navigacija 5. zavihek, `community_landing_screen` (feed »Ta teden« + preklop `[Ta teden | Kje si ti]`), obseg label (auto najfinejši nivo nad pragom), empty/cold-start (»še premalo vrtnarjev«), ovito v temni flag. **TeaseOverlay widget** (stub `hasPlus`): prva vrstica »Ta teden« vidna, ostalo blur + »Na voljo v Tendask +« + »Vnesi kodo« (brez cene/URL). Widget test.
- **Cilj:** viden (v dev) landing feed + tease videz; v prod dark.

### Korak 6 — i18n Okolica landing (en/sl/de)
- **Zajema:** `community.*` nizi za landing/empty/obseg/tease; `dart run slang`. **Anti-steering pregled** tease nizov (brez cene/naslova strani).
- **Cilj:** vsi nizi prek `t.*`, trije jeziki, skladni s politiko.

### Korak 7b — Primerjalne skupine (cohorts) 👈 dodano 2026-07-25
- **Zajema:** migracija `0017` (`@site` veja v `agg_event`), klient prehod z »rastlina neobvezna«
  na **skupino** (`kCommunityCohortSite` ali id rastline): feed bere cele rezine in prikaže vrstico na
  skupino (kapica na tip), `seasonCurve`/`frequency`/`myFirstThisSeason` zahtevajo `cohort`, veriga
  širi **samo** geografijo. Uskladitev `skupnost-agregacija.md §5.2/§7.1/§7.4`, `04 §4.5`, `08 §8.3`,
  screen-map, wireframe.
- **Zakaj:** prejšnja formulacija §7.4 je kot skrajni fallback dovolila zlivanje rastlin — obrez
  jablane in maline sta različna dogodka, zlita krivulja je večvrhna in percentil meri napačno
  vprašanje (ugotovljeno pri pregledu K5–K7).
- **Odvisnosti:** korak 7 · **Kompleksnost:** M · **Migracija:** additivna (`create or replace view`),
  varno zdaj, ker je nočni cron še server-dark in nič ni materializirano.

## Faza 3 — M11.18 Okolica: percentil + frekvenca (XL → 3 koraki)

### Korak 7 — CDF + frekvenca + fallback (čiste funkcije)
- **Zajema:** `SeasonCurve` CDF iz ~53 tednov na napravi, `FrequencyStats`, fallback hierarhija (en nivo, brez mešanja), `myFirstThisSeason()`. Unit testi (rezine: r7 prazen → r6; rastlina → spust; pod `kPrivacy` → null).
- **Cilj:** pravilen percentil z zanesljivo fallback verigo, testirano.

### Korak 8 — Detajl opravila (krivulja + »ti« + stolpci) + tease
- **Zajema:** `community_task_screen` (percentil krivulja + »ti« marker + frekvenca stolpci + »ta teden«), `kReliab` opisni način (brez % pod 30, zaokroži na 10, n viden), flag-dark. Brez Plus (stub) → celoten zaslon TeaseOverlay. Widget test.
- **Cilj:** per-opravilo pogled skladen s `skupnost-agregacija.md §7`.

### Korak 9 — i18n Okolica detajl (en/sl/de)
- **Zajema:** `community.*` detajl/obseg/opisni nizi; `dart run slang`.
- **Cilj:** detajl v treh jezikih.

## Faza 4 — M11.19 R6 v motorju

### Korak 10 — R6 (percentil okolice) + opt-in push
- **Zajema:** pravilo R6 v `smart-engine` (bere agregate, CDF, cooldown), tease ubeseditev brez številke za ne-naročnike, push le ob vklopljenih `community_hints` (opt-in že iz M11.6). Deno testi (CDF nad/pod `kReliab`; cooldown).
- **Cilj:** motor upošteva okolico; številka ostane za Plus (prižge FR-20).

## Faza 5 — zaključek in merge

### Korak 11 — M11.21: dokumentacija + koncept sync
- **Zajema:** `roadmap.md` (M11 → zaključen, opomba: 17–19 done dark, 20 → FR-20), `koncept.md §7.13/§8`, `tech-stack.md §1` (firebase iz »kasneje« v aktivno), memory (`tendask-work-status`).
- **Cilj:** dokumenti se ujemajo z implementiranim; M11 formalno zaprt.

### Korak 12 — Predpriprava merge: zeleno + poravnava
- **Zajema:** `flutter analyze` čist + cel `flutter test` zelen; preveri, ali se je `main` premaknil od uskladitve — če da, `git merge main` v M11; potrdi `schemaVersion` + ledger.
- **Cilj:** trdno zeleno izhodišče, M11 vsebuje ves aktualni main.

### Korak 13 — Merge M11 → main (dark) 👤
- **Zajema:** `git checkout main` → `git merge feat/m11-smart-engine`; potrdi `kSuggestionsEnabled=false` + community dark, edge fn **ni** deployan, cron **ni** omogočen; `analyze`+`test` zelen. Push šele po potrditvi.
- **Cilj:** M11 koda v main, temna; branch se neha vleči.

### Korak 14 — On-device dimni test na main buildu 👤
- **Zajema:** `adb uninstall app.tendask` → main build → potrdi: nič M11/Okolica UI, M8 opomniki brez regresij, migracija čez staro bazo OK.
- **Cilj:** dokazano varen dark merge na napravi.

---

## Odvisnosti

```
1 → 2 → (3 → 4 → 5 → 6) → (7 → 7b → 8 → 9) → 10 → 11 → 12 → 13 → 14
        └─ M11.17 ─────┘   └──── M11.18 ───┘   M11.19  M11.21  merge
```

## Opombe

- **M11.20 se NE gradi** (paywall/`in_app_purchase`/trial) — presežen s FR-20.
- **Tease = presentation widget na stub entitlementu**; pravi podpisani-token gate = FR-20.
- **Vse Okolica UI za temnim flagom** — v prod APK-ju nič ne dela do prižiga.
- **Občutljiva koraka 13–14** (main + naprava): backup + potrditev pred pushom; `adb uninstall` pred menjavo brancha na napravi (drift downgrade/podpis).

---

*Zapisano 2026-07-25 v pogovoru. Nadaljevanje rollout-plana: po tem M11 merge v main (dark) → FR-20 → FR-19 → prižig.*
