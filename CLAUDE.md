# Tendask — pravila za pisanje kode

Vir resnice za koncept/design: `docs/koncept.md` (§7.9 entiteta opravilo, §7.14 podatkovni model), `docs/tech-stack.md` (potrjen sklad + §6 struktura + §2 sync arhitektura + §10 konvencije), `docs/brand/brand.md` (vizualna identiteta), `docs/opravila-in-rastline.md` (vir za seed kataloga). Razvojni plan + delovni dogovor: `docs/roadmap.md` (M0–M11). Ta dokument pokriva **kako** piševa, ne **kaj** gradiva.

## Vodilna načela (po prioriteti)

1. **Offline-first — drift je vir resnice za UI.** Lokalna drift (SQLite) baza je vir resnice, ki ga bere in piše UI; Supabase je vir resnice v oblaku. **UI vedno piše v drift, nikoli direktno v Supabase** — sync poskrbi za oblak v ozadju. Aplikacija mora delovati brez signala (vrt!). Nikoli ne shrani skrivnosti (Supabase ključi, DSN) v repo — uporabi `--dart-define`. `.env`, keystore-ji, `key.properties`, `local.properties` → `.gitignore`.
2. **Zasebnost po zasnovi.** Iz GPS koordinat izračunaj H3 celico **na napravi** in shrani **samo celice** (`profile.h3_r7/r6/r5`) — **nikoli surovih koordinat**. RLS povsod (`user_id = auth.uid()`); anonimni uporabnik ima veljaven `auth.uid()`. GDPR: izvoz + izbris računa (`ON DELETE CASCADE`).
3. **Preproste delujoče rešitve, brez over-engineeringa.** Ne uvajaj abstrakcij, dokler nimaš ≥3 konkretnih klicalnikov. Brez "future-proof" tovarn, brez generikov za en tip, brez interface-a za en implement. Tri podobne vrstice so boljše od prezgodnje abstrakcije.
   - **Ko se vzorec ponovi ≥3×:** ekstrahiraj **helper/funkcijo pred class hierarhijo** (top-level funkcija ali statična metoda je ceneje brati in testirati kot nova bazna klasa).
   - **Composition pred inheritance.** Sestavi obnašanje iz manjših delov (mixin-i, ovojni objekti, funkcije višjega reda), ne podeduj.
   - **Abstrahiraj samo stabilen API.** Workflow v nastajanju (npr. sync push/pull ali UI obrazec, dokler ni potrjen) pusti duplicirano — abstrakcija nad gibljivo tarčo postane gnoj. Počakaj, da se oblika ustavi.
   - **Eksplicitna koda pred implicitno magijo.** Ne skrivaj business logike v extension-ih ali generic helperjih. Bralec mora videti, *kaj* se zgodi. Extension-i so OK za syntactic sugar nad tujimi tipi (npr. `BuildContext.theme`), ne za pravila aplikacije.
   - **Ko condition preseže ~3 pogoje:** ekstrahiraj **imenovan predikat** (`bool canComplete(...)`) **ali** modeliraj stanje z `enum`/`sealed class`. Vgnezdeni `if`-i z bool spremenljivkami so znak, da manjka tip.
4. **Pravilnost pred kratkostjo.** Ne odstrani validacije ali error handlinga na meji (uporabniški vnos, Open-Meteo odgovor, Supabase odgovor) zaradi LOC count. Notranji kodi zaupaj.
5. **Učinkovitost (sync, baterija, podatki).** Sync in obvestila tečejo v ozadju — vsak nepotreben `setState`, polling loop ali rebuild stane uporabnika. Default na lazy/streamed/debounced rešitve. Sync je inkrementalen (`updated_at > last_pulled_at`), ne full-table.

## Tendask stil (povzetek)

Hitri filter pred vsakim večjim kosom kode — če katero od teh ne drži, se ustavi in premisli:

- **Majhne eksplicitne funkcije.** Ena stvar, ime pove kaj, ≤ ~30 vrstic. Velike funkcije = skriti modeli.
- **Podatkovni tok je lahko sledljiv.** Vidiš, od kod vrednost pride in kam gre, brez skakanja po 6 datotekah. Globalni mutable state je rdeč alarm — state živi v Riverpod providerjih.
- **Branch logika je lokalna in berljiva.** Odločitev se zgodi tam, kjer jo bralec išče — ne v sub-sub-callbacku, ne v overridanem getterju.
- **Optimizacije morajo biti merljive.** Najprej naredi, da deluje, potem izmeri, šele potem optimiziraj — in dokumentiraj, **kaj** si izmeril.
- **Code > framework cleverness.** Raje 10 vrstic navadnega Darta kot ena vrstica exotic API trika. Naslednji bralec bere kodo, ne dokumentacije za lib.

> **Opomba o code-genu:** Tendask **namenoma** uporablja code-gen (Riverpod generator, freezed, drift, slang, json_serializable) — to ni "magija", ki bi se ji izogibali, ampak del potrjenega sklada. Pravilo "minimalna magija" velja za *ročno* napisano kodo (refleksija, dynamic dispatch, exotic operatorji), ne za generirane razrede.

## Struktura projekta (feature-first, po `tech-stack.md §6`)

```
lib/
  main.dart                 # samo bootstrap (ProviderScope, init)
  app/                      # MaterialApp, router (go_router), theme, lokalizacija
  core/                     # supabase client, drift db, sync service, dio, h3, Result/napake, config
  i18n/                     # slang (sl/en/de) — generirano
  features/
    home/                   # Domov (01), Hiter vnos (02)
    tasks/                  # opravila: data/ · application/ · presentation/
    journal/                # dnevnik/opombe (03, 18)
    areas/                  # območja (04, 05, 09)
    plants/                 # izbirnik rastlin (10)
    supplies/               # zaloge (08)
    notifications/          # opomniki (19–22)
    auth/                   # prijava/onboarding (13, 15, 16)
  data/
    seed/                   # seed iz opravila-in-rastline.md
```

Pravila:
- **Vsak feature = `data/` (repozitorij: drift + remote) → `application/` (Riverpod providerji) → `presentation/` (zasloni/gradniki).**
- **Repozitorij skrije, ali gre za drift ali remote.** Aplikacijska plast ne ve, od kod pridejo podatki. **UI bere iz Riverpod providerjev, nikoli direktno iz Supabase ali drift v gradniku.**
- **Repo ne sprejema/vrača drift tipov na meji.** Metode so tipirane (`create(...)`, `updateTask({...})`) — **nikoli `Companion`/`Value` v podpisu**; drift (`package:drift`) ostane v `data/`. Widget nikoli ne sestavi `Companion` (to je bil glavni zdrs M2 — `repo.update(id, TasksCompanion)` je pustil drift v `task_form`).
- **Eno odgovornost na datoteko.** Če datoteka preseže ~300 vrstic ali drži dve nepovezani stvari → razdeli.
- **`core/` ne kliče `features/`.** Features kličejo core. Modeli ne kličejo nič.
- **Brez krožnih importov.** Če ju imaš, je struktura napačna — popravi, ne zaobidi.
- **Privatno (`_`) je default.** Public samo, kar uporablja drug file.
- **Začasni outputi gredo v `tmp/`.** Vsak verifikacijski/debug output (analyze dump, log capture, scratch JSON, začasni SQL) gre v `tmp/` v korenu — nikoli razmetan po repu. Če `tmp/` ne obstaja, jo najprej ustvarim. `tmp/` je v `.gitignore`.
- **Generiranih datotek (`*.g.dart`, `*.freezed.dart`, `*.drift.dart`, slang output) NE urejaj ročno.** Po spremembi anotacij/sheme poženi `dart run build_runner build --delete-conflicting-outputs`.

## Konstante in konfiguracija

- **Vse magične vrednosti v `core/config.dart` ali ustreznem `theme/` filu.** Velja za: sync interval, weather cache TTL, privzeti zamik opomnika, tihe ure default, frekvenčno kapico, H3 resolucije (r7/r6/r5), kasneje agronomske pragove (frost-anchor) za pametni motor, barve, paddinge, animation duration.
- Imenovanje: `kSyncIntervalSeconds`, `kWeatherCacheTtl`, `kDefaultReminderOffset`, `kH3ResFine`. `k`-prefix loči konstante od spremenljivk.
- **Brand barve in tipografija živijo v `theme/`**, nikoli hardcode hex (`#2e7d32`, `#E0A82E`) v widgetih.
- **Uporabniške vrednosti = typed model (freezed), nikoli `Map<String, dynamic>` po kodi.** Eno mesto za branje/pisanje (repozitorij), nikoli direkten dostop iz widgeta.
- **i18n: slang (en/sl/de) od M0.** Vsi uporabniško vidni nizi prek `t.*` (npr. `t.tasks.title`), **nikoli hardcoded niz v widgetu**. **`base_locale: en`** (`slang.yaml`) = tehnični privzeti + fallback za nepodprte jezike (in default jezik Play listinga); app sicer sledi jeziku telefona prek `useDeviceLocale()`. **sl ostaja jezik ciljnega trga + vir wireframov** (vsebinsko izhodišče, ne tehnični base). Prevodi v `i18n/*.i18n.json`; po spremembi ključev poženi **`dart run slang`** (slang je ločen CLI, build_runner ga NE ujame).

## Dart/Flutter specifika

- **`const` kjerkoli mogoče** — Flutter zna preskočiti rebuild. `const Widget(...)`, `const EdgeInsets.all(8)`, `const TextStyle(...)`.
- **`final` po defaultu** za lokalne; `late final` samo, ko res rabiš.
- **Immutable modeli z freezed.** `final` polja, `copyWith()`, `==`/`hashCode` generirani. Za stanje uporabi `sealed`/`@freezed` union, kjer se splača.
- **State management: Riverpod (s code-gen) od M0.** `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator`. Konvencije: `@riverpod` anotacija, `ref.watch` v build, `ref.read` v callback. Provider scope = global root.
- **Async:** vedno handle-aj error vejo `Future`/`Stream`. Brez `await` brez `try` na meji (mreža/baza). Brez `ignore: unawaited_futures` — fire-and-forget = eksplicitno `unawaited(...)`.
- **Zero `print()` v production kodi.** Uporabi `debugPrint` (auto-strip v release), za strukturirano `package:logging` ali namenski wrapper. (V release crash/napake → Sentry.)
- **Ne `setState` v `build` ali brez `mounted` check po `await`.**
- **`dispose()` vsak controller/stream subscription/timer.**
- **`BuildContext` po `await` = footgun.** Po vsakem `await` v widget kodi: `if (!mounted) return;` PRED kakršno koli uporabo `context` (`Navigator`, `Theme.of`, `ScaffoldMessenger`, …). Lint `use_build_context_synchronously` mora biti error.
- **`!` (bang) operator z resnico.** Nikoli `foo!` brez komentarja v eni vrstici nad njim, ki pojasni **zakaj** je `null` tu nemogoč (invarianta, prejšnji check). Privzeto: `if (foo == null) return;` ali `switch (foo) { case null => ...; case final v => ... }`.
- **`analysis_options.yaml` je executable verzija teh pravil.** Baseline: `include: package:flutter_lints/flutter.yaml`. Treat-as-error: `avoid_print`, `unawaited_futures`, `use_build_context_synchronously`, `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`. Lint, ki se da avtomatizirati, NE sme živeti samo v CLAUDE.md.

## UI / presentation vzorci (naučeno iz pregleda M2)

- **Brez podvojenih widgetov.** Če isti widget (tile, save-bar, dialog, sheet-handle, empty-state) rabita ≥2 zaslona → `core/widgets/` (generičen) ali `features/<x>/presentation/widgets/` (feature-specifičen). **Verbatim copy-paste widgeta med zasloni je rdeč alarm**, tudi pri 2 klicalcih (drugače velja ≥3 pravilo — pri identičnih kopijah ne).
- **Ne prenašaj `theme`/`t` skozi konstruktorje.** `Theme.of(context)` in `context.t` sta poceni `InheritedWidget` lookup-a — beri ju lokalno v vsakem widgetu, ne kot parametre (prop-drilling = šum v vsakem podpisu).
- **Katalog labels samo prek `catalogLabel()`** (`core/catalog_labels.dart`) — nikoli ročni `jsonDecode` labels v widgetu (velja splošno: brez `Map<String,dynamic>` v presentation plasti).
- **Datumi za prikaz prek `core/date_format.dart`** (`startOfDay`/`formatDmy`/`formatHm`), ne podvojeni inline izračuni `DateTime(now.year, now.month, now.day)` po zaslonih.
- **Napake niso `SizedBox.shrink()`.** Tiho požiranje (`error: (_, _) => SizedBox.shrink()`) skrije bug — pokaži vsaj miren indikator (kasneje Sentry). Mreža = pričakovano stanje (graceful degrade); lokalni DB error = ne, to je bug.
- **Velika presentation datoteka (>~300 vrstic) je signal za ekstrakcijo widgetov**, ne za scroll.

### Komponentni katalog (en widget na vzorec — nikoli lokalna kopija)

Za vsak ponavljajoč se UI vzorec obstaja EN skupni widget. Lokalna `_SectionTitle`/`_Label`/`_EmptyHint` kopija = rdeč alarm; uporabi skupnega.

- **Sekcijska oznaka** (skupina/sekcija v seznamu ali zaslonu) → `SectionLabel` (`core/widgets/section_label.dart`) — **VELIKE črke**, `labelSmall`, letterSpacing, `onSurfaceVariant`. En sam stil sekcij v aplikaciji.
- **Oznaka nad poljem v obrazcu** → `FieldLabel` (isti file) — sentence-case, `labelMedium`, `onSurfaceVariant`.
- **Prazen celozaslonski seznam** → `EmptyState` (`core/widgets/empty_state.dart`). **Dashboard/inline hint** (kratek kontekstni namig, npr. Domov »danes nič«) ni list-empty — sme biti lokalen in kompakten (ne `EmptyState`, ki je centriran in zračen).
- **Izbris v edit obrazcu** → `DestructiveButton` (`core/widgets/destructive_button.dart`) — rdeč (`colorScheme.error`), inline na **dnu vsebine**, samo v edit mode. **Nikoli** delete kot ikona v AppBar s privzeto barvo (izgleda onemogočen).
- **Izbris v `⋯` action sheetu** → zadnja `ListTile` vrstica, ločena z `Divider`, ikona+tekst v `colorScheme.error`.
- **Potrditev izbrisa** → `showConfirmDialog(..., destructive: true)` (`core/widgets/confirm_dialog.dart`) — rdeč `FilledButton`.
- **Shrani/potrdi gumb**: full-screen obrazec → `SaveBar`; bottom sheet → `FilledButton` (48h, full-width) — isti videz.
- **Bottom sheet** → vedno `SheetHandle` na vrhu.

### Barve in stil samo prek teme

- **Destruktivno/napaka = `colorScheme.error`**, nikoli hardcode rdeča; brand barve so v `theme/` (`AppColors.danger` ipd.).
- **Sekundarni/muted tekst = `colorScheme.onSurfaceVariant`** (= brand muted, nastavljen v temi).
- **Hint je medel globalno prek `inputDecorationTheme.hintStyle`** — ne nastavljaj `hintStyle` per-field; hint nikoli ne sme izgledati kot vnesen tekst.

- **H3 celico računaj na napravi** (`h3_flutter`), shrani r7/r6/r5; **koordinate nikoli ne zapustijo naprave** in se nikoli ne shranijo.
- **RLS povsod:** uporabniške tabele `user_id = auth.uid()`; katalog (task_type, plant, …) javno-bralni. Anonimni uporabnik = veljaven `auth.uid()`, RLS deluje enako.
- **Skrivnosti prek `--dart-define`** (Supabase `url`+`anonKey`, Sentry DSN). Anon key + RLS = dovolj; brez service-role ključev v aplikaciji.
- **GDPR:** izvoz podatkov + izbris računa (`ON DELETE CASCADE`). Ob odjavi počisti lokalno drift bazo.
- **Lasten vnos (rastlina/izraz) je zaseben** — ne gre v skupnost (V2 percentili). Osebni alias dovoljen.

## Sync, čas in shema (drift ↔ Supabase)

Aplikacija živi offline; sync je inkrementalen in **enouporabniški (MVP)** — preprost, brez razreševanja konfliktov.

- **LWW po `updated_at`.** MVP nima konfliktov; privzeto pravilo = last-write-wins. Vsaka uporabniška vrstica ima `id` (UUID, **generiran na napravi** pred vstavljanjem — `uuid` paket), `updated_at` (timestamptz), `deleted` (bool, **soft delete** — da se izbris sinhronizira), in lokalno (samo drift) `sync_status ∈ {pending, synced}`.
- **Push:** vsak zapis/uredba/izbris → `sync_status = pending`; sync servis vzame `pending` → `upsert` v Supabase → `synced`. **Spoštuj FK vrstni red:** `area` → `user_plant` → `task` → `task_reminder`/`note`/`task_supply`.
- **Pull:** `select where user_id = auth.uid() and updated_at > last_pulled_at` → `upsert` v drift; `deleted = true` → odstrani lokalno.
- **Sprožilci:** ob vrnitvi povezave (`connectivity_plus`), zagonu, periodično.
- **Čas = UTC v shrambi in transferu; lokalna timezone SAMO za prikaz.** **Nikoli `DateTime.now()` direktno v sync/opomnik/ponavljanje logiki** — uporabi `Clock` interface (`abstract class Clock { DateTime now(); }`, default `SystemClock()`); servisi sprejmejo `Clock` v konstruktorju, testi inject-ajo `FakeClock`. Brez tega ne moreš testirati "opomnik čez 2 dni" brez `Future.delayed`.
- **Repo normalizira čas v UTC.** Klicalec poda lokalni `DateTime`; repo naredi `.toUtc()` pred zapisom (en `create`/`updateTask` v dveh widgetih ne sme dati različnih rezultatov). Za prikaz `.toLocal()` prek `core/date_format.dart`.
- **Domenska stanja = `enum` prek drift `textEnum`** (npr. `TaskStatus { waiting, done }`), shranjen kot `enum.name` (`'waiting'`/`'done'`) → zrcalno s Supabase, brez migracije. Query: `col.equalsValue(Enum.x)`. **Gotcha:** glavni `app_database.dart` mora **importati enum**, sicer generirani `*.g.dart` (part-of) javi "Type not found" (`flutter analyze` tega ne ujame, `flutter test` ga). Workflow v nastajanju (npr. `sync_status`, dokler M6 ni potrjen) pusti `String` — abstrahiraj šele stabilen API.
- **Shema drift in Supabase morata zrcaliti.** Ob spremembi tabele posodobi oba (drift tabela + Supabase migracija). **Migracije = additive-only:** add column/table = OK; rename = NIKOLI (add new + dual-write + drop čez 2 release); nov column = nullable ali z default (nikoli `NOT NULL` brez backfilla v isti migraciji). Razlog: stari APK-ji ob pull-u ne smejo crash-ati.
- **Katalog (`task_type`, `plant`, …): oblak je vir resnice, naprave ga pull-ajo (od M6).** Vsebinski vir je `lib/data/seed/catalog_seed.dart`; v oblak ga (re)materializira `tool/gen_catalog_sql.dart` → `supabase/seed/catalog.sql` (idempotenten `on conflict do update`), aplicirano prek service role/pooler (`supabase/seed/apply_catalog.py`) — **klient kataloga NE piše** (RLS read-only). **Katalog id-ji (`task_type.id`, `plant.id`) so add-only — NIKOLI preimenuj/izbriši** id, ki je v rabi: `user_plant.plant_id`/`task.task_type_id` kažeta nanje, preimenovanje jih osiroti (zlomljen FK). Ob širjenju (Wikidata/GBIF) vzemi stabilen ključ ali ohrani obstoječ slug. **Offline-first ✅ (M9.6):** bundlan seed (128 vrst) je fallback za prvi zagon brez signala (vrt); on-device potrjeno, da je katalog poln tudi offline.
- **Tolerantni parser na obeh straneh.** Neznana polja iz remote → ignoriraj (ne crash). Manjkajoča optional polja → default.
- **Multi-table write = transakcija.** Npr. opravilo + odpis zalog (`task_supply`) shrani atomarno (drift transaction; na Supabase strani RPC ali atomic upsert).
- **DB-level invariante v Supabase**, ne samo app-level: CHECK constraints (`status IN (...)`, `(plant_id IS NOT NULL OR is_custom)`), da app bug ne spusti slabe vrednosti.

## Network & offline behavior

Offline je **normalno stanje, ne edge case** (vrt brez signala). Vsak feature, ki se dotakne mreže (sync, Open-Meteo), mora to predvideti.

- **Network fail ni exceptional path.** Ni `throw` v UI, ni rdeč snackbar za vsak miss. Obravnavaj kot pričakovan return state (`Result`/`sealed` stanje). UI vedno bere iz drift → deluje tudi brez povezave.
- **Brez endless retry loopov.** Maks 3 poskusi z exponential backoff (1s → 3s → 9s), nato ustavi in pokaži stanje. `pending` vrstice počakajo na naslednji sprožilec.
- **UI degradira gracefully.** Zadnji znan state ostane viden (zadnji vremenski posnetek, zadnji sync). Indikator "ni sinhronizirano" je miren, ne alarmanten.
- **Vreme (Open-Meteo):** ob izvedbi opravila zajemi posnetek; če mreže ni, opravilo se vseeno shrani (posnetek doda ob naslednji priložnosti ali ostane prazen). **Zamrznjen dejanski posnetek na "opravljeno"** se ne prepisuje.
- **Connectivity status je explicit signal** prek enega `connectivity_plus` streama, ki ga features konzumirajo.
- **Nobenega runtime fetcha sredstev (fonti, ikone, asseti).** Vse, kar app potrebuje za prikaz, je **bundlano** v `assets/`. Naučeno: `google_fonts` privzeto **naloži font prek omrežja** (`fonts.gstatic.com`) → offline (vrt!) vrže Unhandled Exception. Plus Jakarta Sans je bundlan variable font (`assets/fonts/PlusJakartaSans-VariableFont_wght.ttf`, `pubspec fonts:`), uporabljen prek `fontFamily` v `app_theme`, ne prek `GoogleFonts.*`.

## Komentarji in dokumentacija

**Jezikovno pravilo (fiksno):**
- **Pogovor agent ↔ razvijalec: slovenščina.**
- **Vsa koda: angleščina.** To zajema: identifikatorje, route poti in imena (`/journal` ne `/dnevnik`; `name: 'journal'` ne `'dnevnik'`), i18n ključe (`nav.journal`), log/error nize, asset poti, imena datotek, komentarje, doc komentarje. Slovenščina živi samo v `docs/*`, pravilih (`CLAUDE.md`, `docs/roadmap.md`) in klepetu — **nikoli v kodi**.

**Komentarji:**
- **Default: brez komentarjev.** Dobro poimenovanje pove zgodbo.
- **Komentar samo za neočiten ZAKAJ:** skrita invarianta, workaround za bug v lib-u, presenetljivo obnašanje. Če bralec brez komentarja ne bo zmeden, ga ne piši.
- **Jedrnato — en stavek.** Brez opisa toka (`// calls X then Y`), brez reference na kličoče (`// used by Z`) — to spada v PR opis, ne kodo.
- `///` doc komentar za public API repozitorijev, servisov in modelov — eno vrstico.
- **Brez TODO brez datuma in podpisa.** `// TODO(gorazd, 2026-06-15): ...` ali nič.

## Git / commiti

- **En korak iz `docs/roadmap.md` = en commit.** Conventional Commits: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, `test:`. Naslov ≤72 znakov, brez pike. Slovenski opis.
- **Pred commitom VEDNO vprašaj** (delovni dogovor): "naj ta korak označim kot zaključen in ga commitam?"
- Body razloži *zakaj*, ne *kaj* (diff že pove kaj).
- En commit = ena logična sprememba. Brez "wip + cleanup" mega-commitov.
- **Nikoli `--no-verify` brez izrecnega dovoljenja.** Hook fail = popravi vzrok.
- **Nikoli force push na `main` brez izrecnega dovoljenja.**

## Dependencies

- Vsak nov package: preveri pub.dev score, zadnji release datum, issue tracker. Mrtve lib-e ne dodajaj. **Drži se potrjenega sklada v `tech-stack.md` §1** — dodajanje paketa izven seznama = najprej vprašaj.
- **Ne dodaj package-a za eno funkcijo, ki je 20 vrstic.**
- Pin major version (`^1.2.3`), commit `pubspec.lock`.

## Testi (pragmatično — glej `docs/roadmap.md`)

- **Pure logika** (drift poizvedbe, sync LWW/vrstni red, Open-Meteo parser, kasneje motor pravil): unit testi obvezni. Tečejo na CI brez naprave.
- **Servisi:** mock zunanje dep-e (dio HTTP, Supabase client), testiraj svoj ovoj.
- **UI:** widget testi za ključne/netrivialne zaslone (Hiter vnos shrani, akcija ✓ premakne opravilo). Brez golden testov, dokler dizajn ni stabilen. Brez e2e zaenkrat.
- **Brez testov za scaffolding/setter-je** — ne plačajo vzdrževanja.
- Ob mejniku: **ročna preverba na napravi** (Android, USB).

## Stvari, ki jih NE delam brez vprašanja

- Dodajati novo dependency (izven `tech-stack.md` §1).
- Spreminjati `pubspec.lock` ali `gradle` verzij.
- Brisati datoteke, ki jih nisem ustvaril v tej seji.
- Push, force-push, brisanje branche-ev, rebase published commitov.
- Spreminjati Android `applicationId` (`app.tendask`), package name, signing config.
- Uvajati nov state-management lib, novo arhitekturno plast, nov build sistem.
- Spreminjati potrjene odločitve iz `tech-stack.md` ali `koncept.md` — najprej predlagaj in vprašaj.

## Stvari, ki jih VEDNO delam

- Pred edit-om: preberem file.
- Pred implementacijo feature-a: pogledam pripadajočo sekcijo v `docs/koncept.md` / `docs/tech-stack.md` + ustrezni wireframe, ne ugibam.
- Pred spremembo sheme: preverim §7.14 koncepta in poskrbim, da drift + Supabase ostaneta zrcalna.
- Pred dodajanjem zaslona: preverim ustrezni `docs/wireframes/*`; če odstopam, najprej posodobim wireframe + koncept.
- **Nikoli ne ugibam dejstev** (email, imena, ID-ji, ključi) — če ne vem, vprašam.
- Po končani podnalogi: kratek "to je narejeno, naslednje je X" + vprašam za commit — brez epskih povzetkov.

---

*Pravila so živ dokument. Ko najdeva vzorec, ki se ponavlja, ali napako, ki bi se ji rad izognila, dopolniva tukaj.*
