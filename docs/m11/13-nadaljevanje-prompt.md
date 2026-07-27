Nadaljevanje — dokončaj M11 (pot A) → merge v main (dark). Seja 2 (2026-07-25).

Branch feat/m11-smart-engine. Pogovor SL, koda EN. Pred vsakim commitom VPRAŠAJ.
En korak = en commit; glavni plan seje = docs/m11/12-dokoncanje-m11.md (14 korakov).

## PRVI KORAK V SEJI
Preberi docs/m11/12-dokoncanje-m11.md (glavni plan), docs/m11/09-koraki.md (DoD M11.17–21),
docs/m11/08-flutter-arhitektura.md §8.3 (Okolica), docs/skupnost-agregacija.md §7 (ubeseditve) + §12 (zasloni),
docs/screen-map.md §1.5 + §2 (community rute), memory tendask-work-status + tendask-m11-reconcile-into-main +
tendask-monetization-planned. Nato KRATEK PREGLED (kje sva, kaj je korak 5, odvisnosti) in ZAČNI S KORAKOM 5
(pred commitom vprašaj).

## KJE SVA (opravljeno v seji 1, vse commitano na origin/feat/m11-smart-engine)
- K1 ✅ (66bd601) doc: presezi M11.20 paywall → FR-20 (09/04/08/README + plan 12). Play Billing NIKJER več.
- K2 ✅ (9c7c5ab) doc: Okolica zasnova uskladi na FR-20 — screen-map.md (5. zavihek /community + /community/task/
  :taskTypeId, flag-dark), wireframe community-flow_v3.html (skupina C: brez cene/trial/URL → »Na voljo v Tendask +«
  + »Vnesi kodo«; C3 = vnos odkupne kode), skupnost-agregacija §12.5 opozorilo.
- K3 ✅ (8606f30) feat: drift community_cache tabela (local-only kot SyncCursors, v sync_tables.dart),
  schemaVersion 15→16, migracija createTable, dodana v clearUserData; migracijski test od v8 + schemaVersion=16.
- K4 ✅ (e3110ba) feat: community feature data plast — freezed modeli (Bucket/CommunityFeed/CommunityFeedItem/
  CommunityIntensity + SeasonCurve/FrequencyStats), CommunityRepository (feed + fallback r7→r6→r5→climate +
  bucketPopulation + dnevni cache), providerji (communityRepository/communityBuckets/communityFeed). 8 unit testov.

## NASLEDNJE: KORAK 5 (M11.17 — 5. zavihek + landing + TeaseOverlay, flag-dark)
Zajema (docs/m11/12 §Korak 5): navigacija 5. zavihek ⬡ (StatefulShellRoute, za kSuggestionsEnabled),
community_landing_screen (feed »Ta teden« iz communityFeedProvider + preklop [Ta teden | Kje si ti]),
obseg label (auto najfinejši nivo nad pragom — resolution→i18n label), empty/cold-start (»še premalo vrtnarjev«),
**TeaseOverlay** widget (stub hasPlus, dev=true): prva vrstica feeda vidna, ostalo blur + »Na voljo v Tendask +« +
nevtralni »Vnesi kodo« (BREZ cene/URL/CTA k nakupu — anti-steering FR-20 §3.1). Widget test.
- Cilj: viden (v dev) landing feed + tease videz; v prod dark.
- »Kje si ti« segment lahko za zdaj prazen/placeholder (osebni percentil pride v K7/K8) — ali samo preklopni skelet.
- Odvisnosti: K4 ✅. Za K5 dodaj **kDevPlusStub = true** v core/config.dart (stub hasPlus), NE gradi entitlement.
- Vzorci: obstoječi shell = lib/app/router (StatefulShellRoute, 4 branchi) + main_shell.dart; landing bere iz
  communityFeedProvider; obseg label prek CommunityResolution → t.community.scope.*.
- Nato K6 = i18n community.* landing (en/sl/de) + `dart run slang` + anti-steering pregled tease nizov.

## PLAN (14 korakov) — vrstni red
K1–K4 ✅ · **K5** (zavihek+landing+tease) → K6 (i18n landing) → K7 (CDF/SeasonCurve/FrequencyStats čiste funkcije +
fallback + myFirstThisSeason, unit) → K8 (detajl opravila community_task_screen + tease) → K9 (i18n detajl) →
K10 (R6 v smart-engine + opt-in push, Deno testi) → K11 (M11.21 docs+koncept sync) → K12 (predpriprava merge:
analyze+test zelen; če se main premakne, git merge main v M11) → K13 👤 merge M11→main (dark) → K14 👤 on-device dimni test.
Odvisnosti: 5→6→(7→8→9)→10→11→12→13→14. K13–14 občutljiva (main+naprava): potrdi pred pushom.

## STANJE KODE
- M11.1–M11.16 [x] + M11.17 delno (K3+K4 done). flutter analyze čist, test/features/community/ + test/core/database/ zeleni.
- M11 UGASNJEN: kSuggestionsEnabled=false ovija vse M11 vstopne točke. Server-dark (engine_enabled=false, edge fn ni
  deployan). Drift schemaVersion=16. Community agregatne tabele (activity_recent/season/frequency/bucket_population)
  obstajajo na PROD (M11.16, 0009), staging jih NIMA (feed graciozno pade v null).
- Community fallback: r7→r6→r5→climate (BREZ global — M11.16 cron ga ne materializira; degrade se ustavi pri climate).

## ODLOČENO (velja naprej)
- Pot A: dokončaj M11 v celoti → merge M11→main (dark).
- M11.20 (paywall/in_app_purchase/trial) ODPADE — FR-20 (zunanja licenca). NE gradi Play Billing/entitlement/trial.
- Okolica gradi za temnim flagom (kSuggestionsEnabled). Tease = presentation na STUB hasPlus (kDevPlusStub, dev=true);
  mirno »Na voljo v Tendask +« + »Vnesi kodo«, BREZ cene/URL/CTA. Pravi token-gate = FR-20.

## OKOLJSKE PASTI
- rtk MANGLERA git log/status → git VEDNO prek: rtk proxy git … (raw). Commit msg v tmp/commit_msg.txt + git commit -F.
- Okolje NIMA gh CLI — push/PR prek git push (git izpiše URL).
- Primarni shell PowerShell (Bash tudi). Freezed 3.x = **abstract class X with _$X** (ne `class`); `Bucket` se zaleti s
  supabase storage_client → import supabase_flutter **hide Bucket**. slang = `dart run slang`; shema → build_runner.
- On-device: & .\deploy.bat hot (SM A536B RZCT70XGC5P ima M11-staging build → pred prod/main adb uninstall app.tendask).
  Screencap: MSYS_NO_PATHCONV=1 adb shell screencap -p /sdcard/x.png → adb pull. Drži zaslon: adb shell svc power stayon true.
- Če flutter test obtiči → ubij viseče flutter_tester/dart.
- PRODUKCIJA: nikoli nič ne briši; migracije additive-only + idempotentne. UI: NIKOLI beseda »motor« → »Tendask«/»predlogi«.
- Backupi pred destruktivnimi git posegi; nikoli force push / merge v main brez dovoljenja.

## NEKOMMITANO (tuje — NE mešaj v M11 commite)
- CLAUDE.md (spremenjen) + docs/ui-katalog.md (nov) = uporabnikov ločen refaktor (izvlek UI kataloga iz CLAUDE.md).
  Pusti nedotaknjeno; ni del M11 korakov.

## PARKIRANO (ne blokira)
- Slovnica {subject} (rodilnik) copy-prenova ~61 sporočil × sl/en/de. TENDASK-6 RenderFlex ~9px. FR-8 vreme na centroid.
  Insert-if-missing LWW race. Global community bucket (če bi kdaj hoteli — rabi spremembo M11.16 crona).
