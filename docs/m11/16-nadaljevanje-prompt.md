# Nadaljevanje — M11 je DOKONČAN, ostaneta le merge v main (K13) in dimni test (K14)

Prompt za novo sejo (seja 5, 2026-07-26). Ta datoteka se **NE commita**.

---

Nadaljevanje — M11 je dokončan, ostaneta K13 (merge v main) in K14 (dimni test). Seja 5.

Branch `feat/m11-smart-engine`. Pogovor SL, koda EN. **Pred vsakim commitom VPRAŠAJ.**
Plan seje = `docs/m11/12-dokoncanje-m11.md` (K1–K12 ✅, ostaneta K13 in K14, oba označena 👤).

## PRVI KORAK V SEJI

1. Preberi: `docs/m11/12-dokoncanje-m11.md` (K13, K14), `docs/m11/09-koraki.md` §Zaključek faze E,
   `docs/deploy-runbook.md` §2 (ledger + migracija 0017), `CLAUDE.md`, memory `tendask-work-status`
   + `tendask-m11-reconcile-into-main` + `feedback-destructive-git-ops`.
2. Preveri, da se `main` ni premaknil od 2026-07-26 (`git fetch`, `git log main --not HEAD` mora biti
   prazen). Če se je premaknil, najprej `git merge main` v M11 in znova zeleno.
3. Potrdi zeleno: `flutter analyze` + cel `flutter test` (1150) + `deno test supabase/functions/` (116).
4. Šele nato K13 — in **ne pushaj brez izrecne potrditve**.

## STANJE OB PREDAJI

- HEAD = `f61c309`, **11 commitov lokalno, NIČ pushano** (`origin/feat/m11-smart-engine` = `fbf8738`).
- `main` = `origin/main` = `9cc9067` in je **v celoti vsebovan v M11** → merge je **fast-forward**
  (67 commitov, 186 datotek, ~40 000 vrstic). Merge commita ni, konflikt ni mogoč.
- `flutter analyze` čist · `flutter test` **1150** zelenih · `deno test` **116** zelenih.
- Drift `schemaVersion = 16`; v15→v16 je additivna (`createTable(communityCaches)`, lokalna tabela,
  se ne sinhronizira), pokrita z migracijskim testom.

### Vse je TEMNO (to je bistvo — main dobi kodo, ki nič ne dela)

- Klient: `kSuggestionsEnabled = false` → 5. zavihek izpuščen **hkrati** iz `main_shell` destinacij
  in iz router branch-a (indeksi se sicer razidejo — komentar na obeh mestih), `/suggestions/history`
  ne obstaja, FCM se ne inicializira, pas predlogov na Domov ne obstaja.
- Strežnik: `app_config.engine_enabled = 'false'` + straža v `engine_dispatch()` in `agg_refresh_all()`.
- Edge funkcija `smart-engine` **ni deployana**, nočni cron **ni omogočen**.
- `kDevPlusStub = true` → v dev je Okolica vidna kot za naročnika. V prod je nedosegljiva (zavihka ni),
  torej za merge ni tveganje; **je pa postavka na seznamu pred prižigom** — FR-20 ta šiv zamenja
  s podpisanim tokenom (`hasPlusProvider` je edino mesto).

## K13 — Merge M11 → main (dark) 👤

```
git checkout main
git merge feat/m11-smart-engine     # fast-forward
# potrdi: kSuggestionsEnabled=false, engine_enabled=false, edge fn ni deployana
flutter analyze && flutter test
git push origin main                # ← LOČENA odločitev, šele po izrecni potrditvi
```

- Do pusha je vse lokalno in se razveljavi z `git reset --hard origin/main`. Po pushu je pot nazaj
  revert, ne reset. Zato sta merge in push ločena.
- **K13 ni prižig.** Po njem aplikacija izgleda in dela točno tako kot danes.
- Pushaj tudi `feat/m11-smart-engine`, da veja na origin ne ostane 11 commitov zadaj.

## K14 — On-device dimni test na main buildu 👤

`adb uninstall app.tendask` → main build → potrdi:
1. **Nič M11/Okolica UI** — ni 5. zavihka, ni pasu predlogov na Domov, ni sekcije »V tvoji okolici«
   nad DANES, ni kartice na detajlu opravila, v nastavitvah ni vrstice motorja.
2. **M8 opomniki brez regresij** (lokalna obvestila, tihe ure, kapica).
3. **Migracija čez staro bazo OK** — namesti prod vc16, ustvari nekaj podatkov, nato main build čezenj:
   v15→v16 ne sme crashati in podatki morajo ostati.

## PO M11 (ne v tej seji)

Vrstni red iz rollout plana: **FR-20** (zunanja licenca, `docs/feature-requests/tendask-plus-licensing.md`)
→ **FR-19** (Lunin koledar) → **prižig** = 2 stikali + deploy edge fn + cron + migracija 0017 + masovna
1-letna `granted` licenca vsem obstoječim profilom (lansirno darilo).

⚠️ **Migracija `0017`** (`@site` primerjalna skupina v pogledu `agg_event`) **ni aplicirana nikjer.**
Sama po sebi neškodljiva (`create or replace view`, tabel in RLS se ne dotakne), a mora na PROD
**pred prižigom** nočnega agregata, sicer bi cron polnil `activity_*` brez prostorske skupine.

## ODPRTO (nič od tega ne blokira K13/K14)

- `community_cache` nima evikcije — ena `deleteWhere(fetchedAt < now − 30 dni)`.
- `harvest.sheet_title` »Koliko si pobral?« je zadnji spolno zaznamovan niz v aplikaciji (K9 je
  počistil pet takih v Okolici).
- Wireframe `community-flow_v3.html` ni usklajen s kodo na treh mestih (naslov kartice na Domov,
  odstotek v vrstici »Kje si ti«, rastlina zapečena v naslov feeda) — **odstopanja so zavestna in
  zapisana v `screen-map.md`**, ki je vir resnice; HTML se lahko uskladi kadarkoli.
- Parkirano: slovnica `{subject}` (rodilnik) v ~61 sporočilih × 3 jezike · TENDASK-6 RenderFlex ~9 px ·
  FR-8 vreme na centroid · insert-if-missing LWW race · globalno vedro · razrez `@site` po tipu območja ·
  izbirnik obsega (odložen, ne opuščen).
- `deno lint` (13) in `deno fmt --check` (4) javljata zadetke; CI poganja **samo** `deno test`.
  Zadetki so pred-obstoječi vzorci (`jsr:` inline importi v vseh testnih datotekah, `any` v `index.ts`)
  in razlike v koncih vrstic na Windowsu. Namenoma nedotaknjeno pred merge-om.

## OKOLJSKE PASTI

- `rtk` mangla `git log`/`status` → git **vedno** prek `rtk proxy git …`. Commit sporočilo v
  `tmp/commit_msg.txt` + `git commit -F`. Datoteke `docs/m11/*-nadaljevanje-prompt.md` se **NE commitajo**
  (`git restore --staged` jih pred commitom, če jih `git add docs` potegne noter).
- Okolje **nima `gh` CLI** — PR/push prek `git push` (izpiše URL). Pre-push hook sam požene analyze+test.
- Primarni shell PowerShell (Bash tudi). `deno` se poganja iz `supabase/functions/smart-engine/`.
- Riverpod 3 past: autoDispose provider, prebran prek `.future`, ga scheduler podre sredi `await` →
  `@Riverpod(keepAlive: true)` (tako sta rešena `communityBuckets` in `mySeasons`).
- Freezed 3.x = `abstract class X with _$X`. `Bucket` se zaleti s supabase `storage_client` → `hide Bucket`.
  `ErrorHint` je zaseden v Flutter foundation → naš je `LoadErrorHint`.
- slang = `dart run slang` (build_runner ga NE ujame); shema/anotacije → `dart run build_runner build
  --delete-conflicting-outputs`.
- On-device: `& .\deploy.bat hot` (staging). **Pred prod/main buildom `adb uninstall app.tendask`.**
  Zaslon prižgan: `adb shell svc power stayon true`. Screencap: `MSYS_NO_PATHCONV=1 adb … /sdcard/x.png`
  → `adb pull`. Staging **nima** community tabel → dev build vedno kaže »še premalo vrtnarjev«.
- Če `flutter test` obtiči → ubij viseče `flutter_tester`/`dart` procese.
- **PRODUKCIJA: nikoli nič ne briši**; migracije additive-only + idempotentne.
- UI: **nikoli beseda »motor«** → »Tendask« / »predlogi«.

## ODLOČENO (velja naprej)

- Obseg = samodejna oznaka, ne izbirnik (odločitev A); »vsi« ne obstaja.
- Primerjalna skupina: rastlinska ali `@site`; nikoli se ne zamenja, širi se le geografija;
  zlita `''` vrstica se nikoli ne bere.
- Okolica je v celoti Tendask + ; % samo nad `kCommunityReliabilityMin` (30), zaokrožen na 10,
  pod tem opisni tercilni pas. Odstotka ni na brezplačnih površinah (Domov band, seznam »Kje si ti«).
- M11.20 (paywall / `in_app_purchase` / trial) ODPADE — FR-20. V aplikaciji **NIKOLI** cena/URL/CTA k nakupu.
