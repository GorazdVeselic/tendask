# Poglavje 6 — FCM implementacija (push, plast B)

> FCM je SAMO zvonec: vsa vsebina predlogov živi v `suggestion` tabeli (pull) in na pasu
> Domov. Push brez pasu ne obstaja; pas brez pusha deluje normalno.

## 6.1 Setup Firebase projekta (točni koraki)

1. **Firebase Console** (console.firebase.google.com) → *Add project* → ime `tendask`
   — **Google Analytics: OFF** (brez analitike v MVP, skladno s tech-stack §1).
2. *Add app → Android*: package name **`app.tendask`** (NE spreminjaj — Play identiteta).
   - SHA-1 ni potreben za FCM (potreben le za Google Sign-In prek Firebase, ki ga ne rabimo —
     Google login teče prek Supabase). Polje pusti prazno.
3. Prenesi **`google-services.json`** → `android/app/google-services.json`.
   - **Commit v repo je OK**: datoteka NI skrivnost (vsebuje javne identifikatorje;
     FCM pošiljanje varuje service account, ki je samo v Supabase secrets). To je izjema od
     ».env v gitignore« pravila — zabeleži v PR opisu.
4. **Gradle** (ročno, BREZ flutterfire_cli, da ne vleče `firebase_core` konfiguracijske magije
   po nepotrebnem — `firebase_messaging` `firebase_core` sicer potrebuje kot dep):
   - `android/settings.gradle.kts` → plugins: `id("com.google.gms.google-services") version "4.4.2" apply false`
   - `android/app/build.gradle.kts` → `id("com.google.gms.google-services")`
   - (Verzijo plugina ob izvedbi preveri proti aktualni; spreminjanje gradle = po dogovoru
     vprašaj — to JE ta dogovor, korak M11.5.)
5. **pubspec**: `firebase_core`, `firebase_messaging` (pinned major; pred dodajo preveri
   zadnji release — paketa sta v tech-stack §1 že predvidena za M11).
6. **AndroidManifest** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <meta-data
     android:name="com.google.firebase.messaging.default_notification_channel_id"
     android:value="suggestions" />
   <meta-data
     android:name="com.google.firebase.messaging.default_notification_icon"
     android:resource="@drawable/ic_notification" />   <!-- obstoječa ikona iz M8 -->
   ```
   `POST_NOTIFICATIONS` dovoljenje + priming (zaslon 21) že obstaja iz M8 — FCM ga podeduje.
7. **Notification channel `suggestions`**: ustvari ga `NotificationService` ob initu
   (`flutter_local_notifications` `AndroidNotificationChannel('suggestions', ...)`) — isti
   kanal uporabljata foreground prikaz (klient) in FCM background (manifest meta-data).
8. **Service account** za pošiljanje → `04-supabase-shema.md` §4.8.
9. iOS: NIČ v M11 (iOS = M10/kasneje; `firebase_messaging` iOS del ostane nekonfiguriran).

## 6.2 FCM token — pridobitev in shranjevanje

- **Kam:** `profile.fcm_token` + `fcm_token_updated_at` (drift → sync push → Supabase).
  MVP: ena vrstica = zadnja naprava zmaga (multi-device tabela `device` = V2.5, gl. 10).
- **Kdaj se pridobi:** ob zagonu PO prijavi (gost tokena ne rabi — motor zanj ne teče) in
  šele KO je `POST_NOTIFICATIONS` odobren (sicer `getToken()` na A13+ vrne token, ki ne
  prikaže nič — počakamo na priming flow iz M8).

```dart
// lib/core/notifications/fcm_token_service.dart
/// Keeps profile.fcm_token in sync with the device's FCM registration token.
@Riverpod(keepAlive: true)
class FcmTokenService extends _$FcmTokenService {
  StreamSubscription<String>? _refreshSub;

  @override
  Future<void> build() async {
    final auth = ref.watch(authServiceProvider);        // obstoječi provider
    if (!auth.hasSession) return;                       // guest: no engine, no token
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) return;
    final token = await messaging.getToken();
    if (token != null) await _store(token);
    _refreshSub?.cancel();
    _refreshSub = messaging.onTokenRefresh.listen(_store);
    ref.onDispose(() => _refreshSub?.cancel());
  }

  Future<void> _store(String token) =>
      ref.read(profileRepositoryProvider).updateFcmToken(token);
      // repo: write drift profile.fcmToken + fcmTokenUpdatedAt=now().toUtc(),
      // sync_status=pending → obstoječi push debounce ga odnese v oblak.
}
```
- **Ob odjavi:** `AuthService.signOut()` PRED `signOut` požene
  `profileRepository.updateFcmToken(null)` + flushPush (da strežnik tokena ne uporablja več),
  šele nato počisti lokalno bazo (obstoječi vrstni red `flushPush → signOut → clear`).
- **Strežnik:** ob FCM odgovoru UNREGISTERED token ponulli (04 §4.8).

## 6.3 Foreground / background / terminated

| Stanje | Mehanizem | Kaj naredimo |
|---|---|---|
| **Foreground** | `FirebaseMessaging.onMessage` | OS notifikacije NE prikaže sam → mi: če je uporabnik že na Domov, samo osveži pas (sync pull trigger); sicer pokaži lokalno notifikacijo prek obstoječega `NotificationService` (kanal `suggestions`) |
| **Background** | sistemska (notification message) | OS prikaže sam (kanal iz manifest meta-data); ob tapu → `onMessageOpenedApp` |
| **Terminated** | sistemska | ob tapu → `getInitialMessage()` v bootstrapu |

```dart
// lib/core/notifications/fcm_handler.dart — wired in main bootstrap (po Firebase.initializeApp)
Future<void> initFcmHandlers(Ref ref) async {
  final messaging = FirebaseMessaging.instance;

  FirebaseMessaging.onMessage.listen((msg) {
    if (msg.data['type'] != 'suggestion') return;
    // pullNow() je NOVA javna metoda na koordinatorju (08 §8.5) — pas se osveži iz drift streama
    unawaited(ref.read(syncCoordinatorProvider).pullNow());
    ref.read(notificationServiceProvider)
        .showForegroundSuggestion(msg);                       // tiha lokalna notifikacija
  });

  FirebaseMessaging.onMessageOpenedApp.listen((msg) => _routeFromMessage(ref, msg));

  final initial = await messaging.getInitialMessage();
  if (initial != null) _routeFromMessage(ref, initial);
}

void _routeFromMessage(Ref ref, RemoteMessage msg) {
  if (msg.data['type'] != 'suggestion') return;
  // Home is the suggestions' home (koncept §7.12); band highlights the id.
  ref.read(routerProvider).go('/?suggestion=${msg.data['suggestion_id']}');
}
```
> **Brez `onBackgroundMessage` handlerja v MVP** — pošiljamo *notification* messages (OS jih
> izriše sam); data-only + background isolate (`@pragma('vm:entry-point')`) ni potreben in
> je glavni vir crashev. Sync se zgodi ob naslednjem odprtju (obstoječi trigger).

## 6.4 Deep link ob tapu

- Cilj = **Domov** (pas predlogov je dom predlogov — koncept §7.12; brez ločenega centra).
- Route: obstoječi `'/'` (home branch) + query param `suggestion=<id>`; `HomeScreen` ob
  prisotnem paramu scrolla pas na vrh in predlog kratko poudari (highlight animacija 2 s).
- Če je predlog medtem `expired`/`dismissed` → pas pokaže ostale; brez error stanja
  (miss je pričakovan, ne exceptional).

## 6.5 Opt-in / opt-out (granularno)

- **Shramba:** obstoječi `profile.notification_settings` (jsonb, `NotificationSettings`
  model) — ključi ŽE obstajajo: `weather_hints` (pravila R1–R5/R7 push), `community_hints`
  (R6 push), `frequency_cap`, `quiet_hours`. Privzeto sta hint ključa **false** → push je
  opt-in (GDPR čisto), pas na Domov pa deluje vedno (in-app ni push).
- **UI:** zaslon 22 (`notifications` settings) — stikali »Vremenski/pametni namigi« in
  »Namigi okolice« iz neaktivnih (»kmalu«) v živi; ob prvem vklopu sproži FCM priming/token
  flow (6.2). `frequency_cap` stikalo dobi podnaslov »največ 1 namig na dan« (engine
  kapico izvaja vedno; stikalo OFF pomeni digest možnost kasneje — MVP: stikalo skrito,
  kapica vedno ON; gl. 10-odprta-vprasanja #6).
- **Strežnik je izvrševalec:** engine bere `notification_settings` in NE pošlje pusha, če je
  vrsta izklopljena (klient ne more »pozabiti« filtra). Pas dobi predloge ne glede na opt-in.
- **Tihe ure:** dispatch okno 07:00–12:00 lokalno je že izven privzetih tihih ur (22–07);
  `quiet_hours=true` z drugačnimi urami MVP ne podpira po meri (samo privzete) — engine
  preveri, da je lokalni čas pošiljanja izven [22,7), sicer push izpusti (pas ostane).
