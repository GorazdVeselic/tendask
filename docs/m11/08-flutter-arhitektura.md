# Poglavje 8 — Flutter implementacija

> Feature-first (tech-stack §6): novo `features/suggestions/` in `features/community/`.
> UI bere SAMO iz Riverpod providerjev nad drift; nikoli direktno iz Supabase.

## 8.1 Arhitektura motorja na Flutter strani

Motor teče strežniško → Flutter stran je **prikaz + dve akciji**:

```
features/suggestions/
  data/suggestion_repository.dart      # drift branje + status pisanje
  application/suggestion_providers.dart
  presentation/suggestion_band.dart    # pas na Domov (01)
  presentation/widgets/suggestion_card.dart
```

```dart
// application/suggestion_providers.dart
@riverpod
Stream<List<SuggestionRow>> activeSuggestions(Ref ref) =>
    ref.watch(suggestionRepositoryProvider).watchActive();

// Band UI (presentation) — bere AsyncValue, brez tihega požiranja napak:
final suggestions = ref.watch(activeSuggestionsProvider);
return switch (suggestions) {
  AsyncData(:final value) when value.isEmpty => const SizedBox.shrink(), // prazen pas = ni pasu (legitimno)
  AsyncData(:final value) => SuggestionBand(suggestions: value),
  AsyncError() => const _BandErrorHint(),     // miren indikator, ne shrink (lokalni DB error = bug)
  _ => const SizedBox.shrink(),               // loading: pas se pojavi, ko je
};
```

- **Pas na Domov:** horizontalni `PageView`/stolpec max 3 kartic (`band_max_active`), sort po
  `score` desc. Kartica: ikona tipa, naslov (`t['suggestions.<key>.title']` z
  `message_params`), telo, gumba **Plan** / **Dismiss** (i18n `suggestions.actions.plan` /
  `.dismiss`) + **⋯** (action sheet, vzorec 14), footer z disclaimerjem
  (`suggestions.disclaimer`, droben).
- **⋯ action sheet** (pogodba v `03` §Akcije): »✓ Already done« (mini-sheet
  danes/včeraj/datum → done task + `markLogged`), »Don't suggest this again«
  (`dismiss(scope: forever)`), »I no longer have this plant/area« (`showConfirmDialog(...,
  destructive: true)` → soft-delete prek obstoječega plants/areas repo + `dismiss`).
  i18n: `suggestions.actions.already_done/.never/.remove_subject`.
- **Filter v streamu (drift, ne v widgetu):** `status = 'new' AND deleted = 0 AND
  valid_until >= startOfDay(clock.now())` **+ join na subjekt: `user_plant.deleted = 0`
  oz. `area.deleted = 0`** (odstranjena rastlina takoj umakne kartico, ne šele strežniški
  housekeeping). **POZOR: LEFT join z OR logiko** — `cat:` predlogi (R2/R6 brez konkretnega
  subjekta) nimajo ne `user_plant_id` ne `area_id`; INNER join bi jih požrl. Pogoj:
  `(user_plant_id IS NULL OR user_plant.deleted = 0) AND (area_id IS NULL OR area.deleted = 0)`.
  `Clock` injectan (testabilnost).
- **Načrtuj** (`b9e5b3f`, koncept §0.5): kartica opravila **ne ustvari sama**. Tiho ustvarjeno
  opravilo brez izbire termina in brez vidne potrditve je na napravi padlo na preverbi M11.14,
  zato gumb odpre **predizpolnjen** čarovnik Novo opravilo (tip, rastlina/območje, predlagani
  datum, odprt na koraku »Kdaj«). Predlog postane `planned` šele, ko čarovnik vrne id
  shranjenega opravila; **preklic pusti kartico na pasu**:
```dart
Future<void> _plan(BuildContext context, WidgetRef ref, Suggestion s) async {
  final repo = ref.read(suggestionRepositoryProvider);   // pred await: kartica lahko odpade
  final taskId = await context.pushNamed<String>('task-new', queryParameters: {
    'type': s.taskTypeId,
    'date': _suggestedDate(s).toIso8601String(),         // suggested_date, sicer jutri 09:00
    if (s.userPlantId != null) 'plant': s.userPlantId!,
    if (s.areaId != null) 'area': s.areaId!,
  });
  if (taskId == null) return;                            // preklic — predlog ostane
  await repo.markPlanned(s.id, plannedTaskId: taskId);
}
```
- **Opusti:** `suggestionRepository.dismiss(s.id)` → kartica izgine (stream), sync push odnese
  status; strežnik ob naslednjem teku izpelje `dismissed_until` (03 §Cevovod 2a).
- **Deep link highlight:** `HomeScreen` ob `?suggestion=<id>` paramu scrolla do pasu in
  kartico poudari (2 s animacija obrobe `colorScheme.primary`).
- **Zaslon »Pretekli predlogi«** (`presentation/suggestion_history_screen.dart`, route
  `/suggestions/history`): BRALNA časovnica iz `watchHistory()`, grupirana po datumih
  (`core/date_format.dart`), vrstica = ikona tipa + naslov predloga + status čip
  (`Planned ✓` → tap odpre nastalo opravilo prek `planned_task_id` / `Done` / `Dismissed` /
  `Muted` / `Missed` — i18n `suggestions.history_status.*`). Vstopa: ⋯ na glavi pasu +
  vrstica v Nastavitvah (deluje tudi ob praznem pasu). Brez akcij za nazaj v MVP (samo
  branje; kasnejši kandidat za preklic trajnega muta — `10` #11). To NI center obvestil
  (koncept §7.12 ostaja: dom predlogov = pas na Domov; ta zaslon je revizijska zgodovina —
  krepi razložljivost »zakaj sem to dobil«).

## 8.2 `SuggestionRepository` (vse metode, točni podpisi)

```dart
/// Reads suggestions from drift (the engine writes them via sync pull) and
/// records the user's Plan/Dismiss decisions (synced back via push).
class SuggestionRepository {
  SuggestionRepository(this._db, this._clock);
  final AppDatabase _db;
  final Clock _clock;

  /// Active band content: status 'new', not expired, newest score first. LOCAL.
  Stream<List<SuggestionRow>> watchActive();

  /// Marks a suggestion planned and links the created task. LOCAL write
  /// (status, planned_task_id, updated_at=now.toUtc(), sync_status=pending).
  Future<void> markPlanned(String id, {required String plannedTaskId});

  /// Dismisses a suggestion; the server derives dismissed_until on its next
  /// run (season → window end, forever → permanent mute). LOCAL, synced.
  Future<void> dismiss(String id, {DismissScope scope = DismissScope.season});

  /// Marks 'Already done': the caller has just created a DONE task (with the
  /// chosen date); links it and retires the suggestion. LOCAL, synced.
  Future<void> markLogged(String id, {required String doneTaskId});

  /// Badge helper for Settings/Home ("3 new suggestions"). LOCAL.
  Stream<int> watchActiveCount();

  /// Suggestion history (read-only audit): all non-'new' rows, newest first,
  /// for the 'Past suggestions' screen. LOCAL (retention = server-side 365 d).
  Stream<List<SuggestionRow>> watchHistory();
}
```
Vse metode so **lokalne** (drift); oblak izključno prek obstoječega sync servisa. Repo ne
sprejema/vrača drift `Companion` tipov na meji (CLAUDE.md) — `SuggestionRow` je drift row
class (read-only DTO; sprejemljivo kot pri ostalih repo-jih), pisanja sprejmejo gole parametre.

## 8.3 Okolica zavihek (V2 — koraki M11.17–19; gate → FR-20)

> ⚠️ **Scope popravek (2026-07-25).** Okolico gradimo **za temnim flagom** (kot
> `kSuggestionsEnabled`), v prod dark. **Paywall del spodaj (`entitlement` provider, `startTrial`,
> `in_app_purchase`, `verify-purchase`, `play-rtdn`) se NE gradi** — presežen s FR-20 (zunanja
> licenca, `tendask-plus-licensing.md`). V M11 je gate le **presentation `TeaseOverlay`** na
> **stub `hasPlus`** (placeholder, dev=true): mirno »Na voljo v Tendask +« + nevtralni »Vnesi
> kodo«, **brez cene/URL/CTA k nakupu** (anti-steering FR-20 §3.1). Pravo branje podpisanega
> tokena iz drift + prižig gate = **FR-20**.

```
features/community/
  data/community_repository.dart       # Supabase rezine + drift dnevni cache
  data/community_models.dart           # freezed: CommunityFeedItem, SeasonCurve, FrequencyStats
  application/community_providers.dart # fallback resolucija + entitlement gate
  presentation/community_landing_screen.dart   # 'Okolica' (⬡ 5. zavihek)
  presentation/community_task_screen.dart      # per-opravilo predloga
  presentation/widgets/...             # percentile_curve, frequency_bars, tease_overlay
```

**Struktura zaslonov** (`skupnost-agregacija.md` §12.1): landing s preklopom
`[ This week | Where you stand ]` + obseg = **samo oznaka** (odločitev A, 2026-07-25: brez izbirnika,
razreši ga fallback veriga; »vsi« ne obstaja); detajl
opravila = ena predloga (percentil + frekvenca + ta teden). Vsi teksti: i18n predloga +
lokalni podatek (drift: moja prva izvedba) + agregat (številke).

**`CommunityRepository` (podpisi):** `cohort` = primerjalna skupina (`kCommunityCohortSite` ali id
rastline, `skupnost-agregacija.md §7.4`); zlite `''` vrstice se ne berejo nikoli.
```dart
class CommunityRepository {
  /// The profile's buckets, finest → coarsest. A stream: moving the garden
  /// re-scopes every community read without a restart.  LOCAL.
  Stream<List<Bucket>> watchBuckets(String userId);

  /// Feed slice for the user's buckets; cloud fetch at most 1x/day, served from
  /// the drift community_cache afterwards (offline-friendly).  CLOUD+CACHE.
  Future<CommunityFeed?> feed({required List<Bucket> buckets});

  /// The detail screen's 'this week' line for ONE cohort, read out of the same
  /// daily activity_recent slice the feed cached — no extra request.
  Future<CommunityWeekly?> recentActivity({
    required Bucket bucket, required String taskTypeId, required String cohort});

  /// Season curve (CDF weeks 1..53) for a task type in ONE cohort at ONE
  /// resolution level. Returns null when below thresholds.  CLOUD+CACHE.
  Future<SeasonCurve?> seasonCurve({
    required Bucket bucket, required String taskTypeId, required String cohort});

  Future<FrequencyStats?> frequency({
    required Bucket bucket, required String taskTypeId, required String cohort});

  /// Season curves for MANY cohorts at once — the 'Where you stand' list would
  /// otherwise open the day with one request per cohort. ONE request per level;
  /// each pair is stored under the key seasonCurve() reads, so opening a detail
  /// afterwards is free (§12.4). CLOUD+CACHE.
  Future<Map<(String, String), SeasonCurve>> seasonCurves({
    required List<Bucket> buckets, required List<(String, String)> pairs});

  Future<int?> bucketPopulation({required Bucket bucket});

  /// My record for the type in this cohort this season: first date ('you'
  /// marker) + count ('you' bar), from ONE query. A stream, so logging a task
  /// with the screen open moves the marker. LOCAL; cohort membership mirrors
  /// agg_event (custom plant = site).
  Stream<MySeason> watchMySeason(String taskTypeId, {required String cohort});

  /// Every (task type, cohort) I did this season — the 'Where you stand' list.
  /// Same rule and season as watchMySeason; a task on two plants counts in both
  /// cohorts, exactly as agg_event records it. LOCAL.
  Stream<Map<(String, String), MySeason>> watchMySeasons();
}
```
`RemoteAggFetch` sprejme `Map<String, Object>`: `String` = `eq`, `List<String>` = `in` (edina
zmožnost, ki jo je rabilo masovno branje).

**Fallback hierarhija (en nivo, brez mešanja — implementirano v `community_providers.dart`):**
```dart
// communitySeasonCurve / communityFrequency: skupina je fiksna, širi se le geografija.
final buckets = [r7, r6, r5, climate];   // iz profila; SeasonCurve nosi svoj bucket
for (final b in buckets) {
  final curve = await repo.seasonCurve(
      bucket: b, taskTypeId: taskTypeId, cohort: cohort);
  if (curve != null && curve.pooledTotal >= kCommunityPrivacyMin) return curve;
}
return null;   // UI: 'not enough gardeners yet' empty state
// % se izpiše le, če pooledTotal >= kReliab (30); sicer opisni tercilni pas (timingBand).
// UI VEDNO označi obseg: 'v tvoji okolici' (r7/6/5) / 'v podobni klimi' (climate).
```
> **Skupine se NE zamenja** (uskladitev 2026-07-25, §7.4): rastlinsko vprašanje dobi rastlinski
> odgovor ali nič — zlita `''` vrstica bi pomešala obrez jablane in maline. Skupino izpelji iz
> subjekta opravila (`task_subject → user_plant.plant_id`; brez kataloške rastline →
> `kCommunityCohortSite`).
>
> **Brez `global` vedra** (uskladitev M11.17): nočni cron iz M11.16 materializira samo
> `r7/r6/r5/climate`, zato se degradacija ustavi pri klimatskem košu. Če bi globalni koš kdaj
> hoteli, je treba najprej razširiti cron.
`kPrivacy`/`kReliab` klient NE uveljavlja varnostno (to dela RLS) — pozna ju za pošten prikaz
(`core/config.dart`: `kCommunityPrivacyMin = 5`, `kCommunityReliabilityMin = 30`; vrednosti
zrcalita `app_config`).

**CDF izračun na napravi** (§12.3): `SeasonCurve` se zgradi iz ~53 vrstic `activity_season`
(seštej pretekla leta po tednih, kumulativa / pooled total). Čista funkcija + unit test.

**Gating v M11 (stub — pravi gate = FR-20):**
```dart
// M11: NE 'entitlement' provider, NE Play Billing. Le stub entitlement.
// hasPlus = placeholder (dev=true), pravo branje podpisanega tokena iz drift pride s FR-20.
const bool hasPlus = kDevPlusStub;   // TODO(FR-20): zamenjaj z licenseProvider (podpisan token)
// landing: 'Ta teden' prva vrstica vidna, ostalo TeaseOverlay (blur);
// detail: brez Plus celoten zaslon TeaseOverlay.
```
- **TeaseOverlay** = presentation widget: blur + mirno »Na voljo v Tendask +« + nevtralni
  gumb »Vnesi kodo« → (M11: no-op/placeholder; FR-20 poveže na vnos odkupne kode).
  **Brez cene, URL-ja ali CTA k nakupu** (anti-steering FR-20 §3.1).
- ⚠️ **NE gradi** (presežek FR-20): `entitlement` provider/tabela, `startTrial()`,
  `start-trial` Edge Function, `in_app_purchase`, `verify-purchase`, `play-rtdn` — vse to
  nadomešča FR-20 (zunanja licenca prek spletne strani + odkupna koda).
- R6 push za ne-naročnike: tease ubeseditev brez številke (»V tvoji okolici se je začelo
  gnojenje trate« — brez %); številka je premium (prižge FR-20).

## 8.4 Nove i18n vsebine (slang)

> **Obseg, ne podrobnost:** 61 ključev × (title+body) × 3 jeziki ≈ **400+ uporabniško vidnih
> nizov** — to je vsebinsko pisanje, ne koda. V M11.13 ga obravnavaj kot ločen pod-korak
> (najprej EN celoten, nato SL/DE prevod v bloku) — ne mešaj s widget kodo v istem sedenju.

- `suggestions.*` — naslov/telo za vsak `message_key` iz 01 (61 pravil; en/sl/de) +
  `suggestions.actions.plan/.dismiss/.already_done/.never/.remove_subject`,
  `suggestions.toast.planned/.logged`, `suggestions.history_status.*`,
  `suggestions.disclaimer`,
  `suggestions.history.anniversary`, `suggestions.cadence.overdue`,
  `suggestions.community.most_started`, `suggestions.dry_window` (pripona R1 —
  ne kartica; `suggestions.weather.window_open` je bil odstranjen z O4).
- `community.*` — landing/detajl/tease/empty state.
- Po dodajanju: `dart run slang` (ločen CLI!).

## 8.5 Kaj se NE spremeni — in kaj je vseeno NOVO v core

- Sync servis: samo registracija novih tabel (pull: suggestion, suggestion_log,
  plant_task_rule[katalog]; push: suggestion, profile nova polja) — brez novih arhitekturnih
  plasti.
- Plast A (lokalni opomniki) ostane nedotaknjena; dedup proti njej dela strežnik.
- Domov zasloni: pas je NOV widget nad obstoječim seznamom; nič se ne prestrukturira.

**Manjše NOVE core zmožnosti, ki jih psevdokoda v 06 predpostavlja (danes NE obstajajo):**
- `routerProvider` — router danes nastane prek `createAppRouter()` brez Riverpod providerja;
  za FCM deep link ga ovij v provider (ali uporabi globalni `GoRouter` instance — odloči ob
  M11.7, manjša od obeh sprememb).
- Javni pull trigger na sync koordinatorju (`pullNow()` ali raba obstoječega
  `syncServiceProvider.sync()`) — koordinator danes nima javnega API-ja za »osveži zdaj«.
- Auth: spec piše `authStateProvider.isSignedIn` — dejanski API je
  `authServiceProvider.hasSession` (gost = `kLocalUserId`, brez seje). Uporabi obstoječe ime.
