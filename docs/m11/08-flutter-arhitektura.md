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
  housekeeping). `Clock` injectan (testabilnost).
- **Načrtuj:**
```dart
Future<void> planSuggestion(SuggestionRow s) async {
  final date = DateTime.tryParse(s.messageParams['suggested_date'] ?? '') ?? tomorrowAt9();
  final taskId = await tasksRepository.create(            // OBSTOJEČA metoda — task + subject
    taskTypeId: s.taskTypeId,
    date: date,
    subjects: [if (s.userPlantId != null) PlantSubject(s.userPlantId!)
               else if (s.areaId != null) AreaSubject(s.areaId!)],
    status: TaskStatus.waiting,
  );
  await suggestionRepository.markPlanned(s.id, plannedTaskId: taskId);
  // → top toast 'suggestions.toast.planned' + pas se osveži prek streama
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

## 8.3 Okolica zavihek (V2 — koraka M11.19/M11.20)

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
`[ This week | Where you stand ]` + obseg (auto: najfinejši nivo, ki prestane prag); detajl
opravila = ena predloga (percentil + frekvenca + ta teden). Vsi teksti: i18n predloga +
lokalni podatek (drift: moja prva izvedba) + agregat (številke).

**`CommunityRepository` (podpisi):**
```dart
class CommunityRepository {
  /// Feed slice for the user's buckets; cloud fetch at most 1x/day, served from
  /// the drift community_cache afterwards (offline-friendly).  CLOUD+CACHE.
  Future<List<CommunityFeedItem>> feed({required List<Bucket> buckets});

  /// Season curve (CDF weeks 1..53) for a task type (+optional plant) at ONE
  /// resolution level. Returns null when below thresholds.  CLOUD+CACHE.
  Future<SeasonCurve?> seasonCurve({
    required Bucket bucket, required String taskTypeId, String plantId = ''});

  Future<FrequencyStats?> frequency({
    required Bucket bucket, required String taskTypeId, String plantId = ''});

  Future<int?> bucketPopulation({required Bucket bucket});

  /// My first completion of the type this season — for the 'you' marker. LOCAL.
  Future<DateTime?> myFirstThisSeason(String taskTypeId, {String? plantId});
}
```

**Fallback hierarhija (en nivo, brez mešanja — psevdokoda v providerju):**
```dart
Future<(Bucket, SeasonCurve)?> resolveCurve(String taskTypeId, String plantId) async {
  final buckets = [r7, r6, r5, climateBucket, globalBucket];   // iz profila
  for (final withPlant in [plantId, '']) {                     // rastlino spusti zadnjo
    for (final b in buckets) {
      final curve = await repo.seasonCurve(
          bucket: b, taskTypeId: taskTypeId, plantId: withPlant);
      if (curve != null && curve.pooledTotal >= kPrivacy) return (b, curve);
    }
  }
  return null;   // UI: 'not enough gardeners yet' empty state
}
// % se izpiše le, če pooledTotal >= kReliab (30); sicer opisni tercilni pas.
// UI VEDNO označi obseg: 'in your area' (r7/6/5) / 'in a similar climate' / 'among all gardeners'.
```
`kPrivacy`/`kReliab` klient NE uveljavlja varnostno (to dela RLS) — pozna ju za pošten prikaz
(`core/config.dart`: `kCommunityPrivacyMin = 5`, `kCommunityReliabilityMin = 30`; vrednosti
zrcalita `app_config`).

**CDF izračun na napravi** (§12.3): `SeasonCurve` se zgradi iz ~53 vrstic `activity_season`
(seštej pretekla leta po tednih, kumulativa / pooled total). Čista funkcija + unit test.

**Paywall gating:**
```dart
@riverpod
Future<Entitlement> entitlement(Ref ref) async {
  // 1x/day cloud check (entitlement table), cached v drift local_prefs;
  // offline → zadnja znana vrednost (graceful).
}

// V presentation:
final ent = ref.watch(entitlementProvider).value;
final hasPlus = ent?.isActive ?? false;     // trial ali active, expires_at > now
// landing: 'This week' prva vrstica vidna, ostalo TeaseOverlay (blur + 'Try 14 days');
// detail: brez Plus celoten zaslon TeaseOverlay; gumb → startTrial() Edge Function.
```
- `startTrial()` = Supabase Edge Function `start-trial` (server preveri: še ni imel triala →
  `entitlement{status:'trial', trial_started_at:now, expires_at:+14d}`); brez kartice.
- Nakup: `in_app_purchase` (Play Billing) → Edge Function `verify-purchase` (server-side
  preverba prek Play Developer API) → `entitlement{status:'active'}`. RTDN webhook
  (`play-rtdn`) osvežuje podaljšanja/odpovedi. **Paket `in_app_purchase` ni v tech-stack §1 →
  pred korakom M11.20 vprašaj za potrditev** (zabeleženo tudi v 09).
- R6 push za ne-naročnike: tease ubeseditev brez številke (»V tvoji okolici se je začelo
  gnojenje trate« — brez %); številka je premium (skladno z monetizacijo §12.5).

## 8.4 Nove i18n vsebine (slang)

- `suggestions.*` — naslov/telo za vsak `message_key` iz 01 (61 pravil; en/sl/de) +
  `suggestions.actions.plan/.dismiss/.already_done/.never/.remove_subject`,
  `suggestions.toast.planned/.logged`, `suggestions.history_status.*`,
  `suggestions.disclaimer`,
  `suggestions.weather.window_open`, `suggestions.history.anniversary`,
  `suggestions.cadence.overdue`, `suggestions.community.most_started`.
- `community.*` — landing/detajl/tease/empty state.
- Po dodajanju: `dart run slang` (ločen CLI!).

## 8.5 Kaj se NE spremeni

- Sync servis: samo registracija novih tabel (pull: suggestion, suggestion_log,
  plant_task_rule[katalog]; push: suggestion, profile nova polja) — brez novih arhitekturnih
  plasti.
- Plast A (lokalni opomniki) ostane nedotaknjena; dedup proti njej dela strežnik.
- Domov zasloni: pas je NOV widget nad obstoječim seznamom; nič se ne prestrukturira.
