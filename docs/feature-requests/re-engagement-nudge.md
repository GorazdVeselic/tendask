# FR: Re-engagement opomnik za neaktivne uporabnike

- **Status:** predlog (raziskava + arhitekturna odločitev), neimplementirano
- **Datum:** 2026-06-28
- **Področja:** lokalne notifikacije (M8), smart-engine/FCM (M11), retention
- **Povezave:** `docs/koncept.md` §"Vodenje proti motečnosti", `docs/m11/` (engine + FCM)

---

## 1. Problem

Vrtnar pogosto *vrtnari*, a pozabi *vnesti* — v soboto škropil, v nedeljo sadil,
nič zabeležil. Želimo nežen opomnik, ki ga povabi nazaj k dnevniku, **brez da
postanemo spam**.

Ključno: to nista en, ampak **dva segmenta**, ki potrebujeta različno sporočilo:

| Segment | Kdo | Cilj | Ton |
|---|---|---|---|
| **A — Never-activated** | namestil, odprl, a nikoli ni vnesel opravila ne prijave | aktivacija (prvi vnos) | "Začni svoj vrtni dnevnik" |
| **B — Lapsed** | bil aktiven, a ta teden tišina | retencija (vrni se k navadi) | "Kaj se je ta teden dogajalo na vrtu?" |

## 2. Arhitekturna odločitev

Dve poti; za MVP je prava **A (lokalna)**:

### A) Lokalni "dead-man's-switch" — PRIPOROČENO za MVP

Ob vsakem odpiranju aplikacije ali vnosu (task/note) prekličeš in znova zakoličiš
en lokalni opomnik za "čez N dni ob 17:00". Dokler je uporabnik aktiven, se
opomnik vedno potisne naprej in **nikoli ne sproži**; ko utihne N dni → sproži.

Zakaj prava izbira:
- **Brez backenda, brez FCM** (FCM je na `feat/m11-smart-engine`, ne na main).
- **Doseže segment A in goste** — anonimni uporabniki (`kLocalUserId = 'local'`)
  nimajo cloud profila ne FCM tokena; strežnik jih sploh ne more doseči.
- **Privacy-perfect, offline-first** — nič ne zapusti naprave; sproži se brez signala.
- **Infrastruktura že stoji** (M8): `flutter_local_notifications`, 3 receiverji,
  BOOT reschedule, reconcile vzorec, tihe ure/kapica.

Slabost: ne doseže uporabnika, ki app trajno več ne odpre (kar je hkrati
anti-spam lastnost — en sam vnaprej zakoličen opomnik, z decay-em).

### B) Strežniški FCM cron (R8) — kasneje, po M11

pg_cron + Edge Function, ki najde neaktivne in pošlje FCM. Signal aktivnosti:
`max(task.server_inserted_at)` (server-owned, clock-skew-immune; dodano v
migraciji 0011, komentar tam: "use for sync/active/churn").

**Omejitev B:** doseže **samo prijavljene z FCM tokenom** → po definiciji zgreši
segment A. Zato A ostane primarni; B je dodatek za win-back prijavljenih.

> Opozorilo: na main ni `last_active`/`last_login`; `profile.updated_at` se
> osvežuje le ob pisanju nastavitev (ni zanesljiv "zadnji obisk"). Lokalni
> pristop (A) tega ne potrebuje.

## 3. Anti-spam guardrails (jedro)

1. **Frekvenčna kapica: maks. 1× / 7 dni.** Trdo.
2. **Decay / give-up:** po 2 zaporednih ignoriranih podaljšaj interval (7 → 21 → ustavi).
   Mrtvih ne zbadaj v nedogled.
3. **Reset ob aktivnosti:** vsak vnos/odpiranje potisne naslednji opomnik za 7 dni; aktiven uporabnik ga nikoli ne vidi.
4. **Tihe ure** (`kQuietHoursStartHour=22`/`End=7`) veljajo; termin sob/ned pozno popoldne (~17:00 lokalno).
5. **Nikoli isti dan kot eksplicitni opomnik na opravilo.**
6. **Privzeto vklopljeno, a očiten in dostojanstven opt-out** (ločen toggle v zaslonu 22, ne pod opomniki za opravila).
7. **Globalni dnevni strop:** ko pride B, deli kvoto s suggestion push-i (M11.8 cooldown vzorec).
8. **Ton = pomoč, ne krivda:** nobeno sporočilo ne šteje časa ("že 9 dni!"); vedno naprej obrnjeno.

## 4. MVP predlog

Majhna nadgradnja M8 `NotificationService`:
- Nov kanal `journalNudge`, ločen toggle (privzeto on).
- Touch ob app-resume + ob write v `task`/`note` → reschedule.
- Copy ločen po `count(task)==0` (segment A) vs >0 (segment B).
- Decay po 2 neodzivih.
- Vse skozi `Clock` interface (testabilnost) + unit testi + debug-skrajšava N.

### Testne pasti (M8 nauki)
- Reschedule/preklic po fiksnem ID-ju (en sam, da se ne kopiči).
- Preživi reboot (BOOT receiver).
- Tihe ure prestavijo, ne izbrišejo.
- **Ne** deli kanala/ID-jev z opomniki za opravila (sicer preklic enega pobriše drugega).
- main↔M11 build na isti napravi nikoli brez `adb uninstall` vmes.

## 5. Zakaj NE FCM-only

Začetni osnutek (avtomatski) je predlagal R8 kot edino pot. To je narobe za ta
cilj: zahteva M11 + novo migracijo, predvsem pa **strukturno zgreši segment A**
(neaktivirane/goste — ravno tiste, ki jih hočemo aktivirati). Lokalni pristop ni
le enostavnejši, je **edina pot do segmenta A**.
