# Naslednja seja — M11.13b: zaslon »Pretekli predlogi«

Branch `feat/m11-smart-engine`. Pogovor SL, koda EN. **Pred vsakim commitom vprašaj.**
En korak roadmapa = en commit; korak odkljukaj v `docs/m11/09-koraki.md`.

## Kje sva (stanje 2026-06-15)

- **Faza A–C (M11.1–M11.12) ✅** — shema, klima, seed, FCM, cel motor (signali + R1–R7 +
  dispatch/pg_cron + FCM pošiljanje). Vse commitano + deployano na živ Supabase.
- **M11.13 ✅ — pas pametnih predlogov na Domov** (Faza D, prvi UI korak). Razbit na 3 commite:
  - `0eb30ae` — `SuggestionRepository` (`watchActive`, `markPlanned`/`dismiss(scope)`/`markLogged`)
    + providerji + `fillTemplate` čista substitucija. **`watchHistory`/`watchActiveCount` NAMERNO
    izpuščena** (mrtva koda do TE seje).
  - `63d9e3e` — i18n katalog predlogov (en/sl/de): 61 agronomskih ključev + 4 generični +
    akcije/sheet/confirm/**`suggestions.history_status.*`** (planned/logged/dismissed/muted/missed/
    expired). **history_status ključi že obstajajo — za ta korak verjetno NE rabiš novih nizov.**
  - `7f1a3eb` — `SuggestionBand` + `SuggestionCard` + akcije + deep-link highlight.
- **Testi: 234/234, `flutter analyze` čist.**

> POZOR na poimenovanje: prejšnja seja je interno govorila o »13a/13b/13c« kot pod-korakih
> M11.13. To NI isto kot **`M11.13b`** v roadmapu (= ta naloga, Pretekli predlogi). Uporabljaj
> samo uradne oznake.

## Naloga te seje: M11.13b — zaslon »Pretekli predlogi«

**Vir resnice:** `docs/m11/08-flutter-arhitektura.md` §8.1 (zadnji odstavek o
`suggestion_history_screen`) + §8.2 (podpisa `watchHistory`/`watchActiveCount`);
`docs/m11/09-koraki.md` korak M11.13b; `docs/m11/03-pravila-r1-r7.md` §Cevovod 2e (retencija).

### Obseg

1. **Repo:** v `lib/features/suggestions/data/suggestion_repository.dart` dodaj (zdaj sta na vrsti):
   - `Stream<List<Suggestion>> watchHistory()` — vse vrstice s `status != 'new'`, `deleted = 0`,
     najnovejše prej (`updated_at` desc). LOKALNO.
   - `Stream<int> watchActiveCount()` — število `status='new'` & ne-poteklih (badge za Nastavitve/
     vstop); lahko zrcali filter iz `watchActive`. Dodaj providerja v `application/suggestion_providers.dart`.
2. **Zaslon** `lib/features/suggestions/presentation/suggestion_history_screen.dart`, route
   `/suggestions/history` (dodaj v `lib/app/router/app_router.dart`, full-screen nad shell):
   - BRALNA časovnica iz `watchHistory()`, **grupirana po datumih** prek `core/date_format.dart`
     (`startOfDay`/`formatDmy`). Brez akcij za nazaj (samo branje) v MVP.
   - Vrstica = ikona tipa (`taskTypesMap` → `catalogLabel`) + naslov predloga
     (isti vzorec kot kartica: `fillTemplate(t['<messageKey>.title'], displayParams)` —
     glej `suggestion_card.dart` `_message`/`suggestionDisplayParams`, po potrebi ekstrahiraj skupni helper)
     + **status čip** prek `t.suggestions.history_status.*`.
   - **Tap na `planned` vrstico → odpre nastalo opravilo** prek `planned_task_id`
     (`context.pushNamed('task-detail', pathParameters: {'id': s.plannedTaskId!})`).
   - Prazna zgodovina → `EmptyState` (`core/widgets/empty_state.dart`).
3. **Vstopa do zaslona:**
   - **Vrstica v Nastavitvah** (`features/settings/presentation/settings_screen.dart`) — deluje tudi
     ob praznem pasu. To je MIN obvezni vstop.
   - Spec omenja tudi »⋯ na glavi pasu«, A **pas trenutno NIMA glave** (⋯ je na vsaki kartici).
     ODLOČITEV: bodisi dodaj diskreten »Zgodovina« gumb v glavo pasu, bodisi se zadovolji z vstopom
     iz Nastavitev (predlagam Nastavitve + po želji majhen link). Uskladi z uporabnikom.
4. **Wireframe NE obstaja.** Po CLAUDE.md pravilu (»wireframe pred zaslonom«): pred kodo
   skiciraj v `docs/wireframes/` ALI zavestno zapiši izjemo v `docs/koncept.md §7.12`
   (zgodovina = revizijska časovnica, NE center obvestil). Vprašaj uporabnika, kaj raje.

### Odprte odločitve (potrdi pred kodo)

- **Mapiranje status → čip:** vrstica ima `status` ∈ {planned, dismissed, logged, expired} +
  `dismiss_scope` ∈ {season, forever}. i18n čipi: planned/logged/dismissed/**muted**/**missed**/expired.
  Predlog mapiranja: `logged→Done`(`logged`), `planned→Planned`, `dismissed+season→Dismissed`,
  `dismissed+forever→Muted`, `expired→Missed`(ali `Expired`). **Potrdi semantiko »missed« vs »expired«.**
- **Retencija (03 §Cevovod 2e):** soft-delete terminalnih vrstic > 365 dni dela **STREŽNIK**
  (engine housekeeping, že v M11.12). Klient samo NE kaže `deleted=1` (filter v `watchHistory`).
  DoD »housekeeping test retencije« je verjetno Deno test motorja — **preveri, ali ni že pokrit**;
  če je app-side, doreči z uporabnikom.

### DoD (iz 09-koraki)

- Widget test: zgodovina prikaže vse terminalne statuse, `new` izključen; tap `planned` → detajl opravila.
- Retencija (gl. zgoraj — verjetno engine, ne nujno ta korak).
- `docs/koncept.md §7.12` dopolnjen (zgodovina ≠ center obvestil).
- `flutter analyze` čist; cel paket zelen.
- **Commit:** `feat(suggestions): zaslon preteklih predlogov z odzivi uporabnika`

## Konvencije / arhitektura (kratko)

- Feature-first: `features/suggestions/{data,application,presentation}`. UI bere SAMO iz Riverpod
  providerjev nad drift; nikoli direktno Supabase. Repo ne vrača `Companion` na meji.
- `SuggestionRow` (drift row class) je OK kot read-only DTO na meji; pisanja sprejmejo gole parametre.
- Komponentni katalog: `EmptyState`, `SectionLabel`, `SheetHandle`, `showConfirmDialog`,
  `showTopToast` — uporabi obstoječe, ne kopiraj.
- Datumi za prikaz prek `core/date_format.dart`; katalog labels prek `catalogLabel()`.
- i18n: vsi nizi prek `t.*`; po dodajanju ključev poženi **`dart run slang`** (ločen CLI!).

## Recepti / gotchas (naučeno to sejo)

- **Widget testi predlogov:** NE uporabljaj živega drift `watch` streama v widget testu — pusti
  viseč timer ob teardownu. Override `activeSuggestionsProvider` (in za zgodovino: nov
  `historyProvider`) s `Stream.value([...])`. Vzorec: `test/features/suggestions/suggestion_band_widget_test.dart`.
- **Toast v testih:** `showTopToast` ima `Future.delayed(2200)` → `pumpAndSettle` se med statičnim
  delayem vrne PREZGODAJ; rabiš eksplicitne stopenjske pumpe (`_settle` v band testu).
- **riverpod 3.x AsyncError** se v widget-testu ne sproži zanesljivo (ne `Stream.error` ne
  `StreamController`) → error-stanja ne testiraj prek streama (preveri vizualno).
- **Auth v testih:** brez Supabase config je `AuthService(null).userId == 'local'` → ni treba
  override-ati `authServiceProvider`.
- **Build:** po spremembi `@riverpod`/anotacij → `dart run build_runner build --delete-conflicting-outputs`.
  Po tem lahko nastane **riverpod hash churn v nepovezanih `.g.dart`** — pred `git add` jih `git checkout --` (atomiren commit).
- **Commit message:** zapiši v `tmp/commit_msg.txt` + `git commit -F` (here-string se v tem harnessu pokvari).
- **Branch ↔ main na telefonu:** med menjavo `adb uninstall app.tendask` (drift downgrade pusti staro verzijo → duplicate-column crash).

## Parkirano (NE pozabi, a ne ta korak)

FR-8 (vreme na centroid `h3_r7` namesto surovih koordinat — `docs/roadmap.md`); insert-if-missing
LWW race (`setLang`/`setNotificationSettings`/`saveGardenLocation`); Sentry TENDASK-6 (RenderFlex
overflow); 👤 Play upload vc4 (`1.0.0+4` zgrajen iz `main`) + zbiranje ≥12 testerjev za zaprti test.

## Po M11.13b

M11.14 (e2e motorja na napravi + poliranje) → M11.15 (CI test suite) → Faza E (V2 skupnost,
M11.16–M11.21) ALI prej preklop na 👤 Play zaprti test.
