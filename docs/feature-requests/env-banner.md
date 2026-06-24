# FR: Indikator okolja v aplikaciji (STAGING / OFFLINE)

- **Status:** predlog (feature request), čaka odločitev
- **Datum:** 2026-06-24
- **Avtor:** Gorazd
- **Področja:** app shell (`lib/app/app.dart`), dev tooling
- **Povezave:** [`docs/deploy-runbook.md`](../deploy-runbook.md), [`docs/staging-env.md`](../staging-env.md), [`lib/core/config.dart`](../../lib/core/config.dart) (`kEnvLabel`)

---

## 1. Povzetek (TL;DR)

Na isti napravi se izmenjujeta dva builda proti **dvema različnima backendoma**:

- **release AAB iz Play** → produkcijski Supabase (`*.supabase.co`),
- **lokalni build** (`deploy.bat hot` / `staging`) → staging Supabase (Docker WSL, `api-staging.tendask.app`).

Trenutno se okolje vidi **samo v logu ob zagonu** (`ENV: … — SUPABASE_URL=…`). Na napravi ni vizualnega znaka, kam je app povezan → tveganje, da testiraš/vnašaš podatke proti napačnemu backendu.

**Predlog:** majhen, nevsiljiv indikator okolja, viden **samo, kadar nisi na produkciji**. Produkcijski (Play) build ne pokaže ničesar — pravi testerji ga nikoli ne vidijo.

---

## 2. Signal že obstaja

`lib/core/config.dart` že izpelje okolje iz `SUPABASE_URL`:

```dart
String get kEnvLabel {
  if (kSupabaseUrl.isEmpty) return 'offline (no backend)';
  return kSupabaseUrl.contains('staging') ? 'staging' : 'production';
}
```

Ključ je **URL backenda, ne debug/release** — to je ravno pravilno:

| Build | `kEnvLabel` | Indikator |
|---|---|---|
| Play release AAB (prod) | `production` | **(brez)** |
| `deploy.bat hot` (debug, staging) | `staging` | STAGING |
| `deploy.bat staging` (release, staging) | `staging` | STAGING |
| `deploy.bat hot prod` (debug, prod) | `production` | **(brez)** |
| brez backenda (offline) | `offline (no backend)` | OFFLINE |

---

## 3. Predlagana rešitev (priporočena)

Kotni diagonalni **`Banner`** (Flutterjev vgrajeni widget) prek `builder` v `MaterialApp.router`, prikazan samo ko `kEnvLabel != 'production'`:

```dart
// MaterialApp.router( … , builder: …)
builder: (context, child) {
  if (kEnvLabel == 'production' || child == null) return child ?? const SizedBox();
  return Banner(
    message: kEnvLabel == 'staging' ? 'STAGING' : 'OFFLINE',
    location: BannerLocation.topEnd,
    color: kEnvLabel == 'staging' ? Colors.orange : Colors.grey,
    child: child,
  );
},
```

**Lastnosti:**
- viden na vsakem zaslonu (kotni trak), takojšen pregled »kam sem povezan«;
- **prod build = brez banderja** (tester nikoli ne vidi);
- ~6 vrstic, brez novih datotek, ponovno uporabi `kEnvLabel`; `debugShowCheckedModeBanner` je že `false`, zato ni dvojnih trakov.

**Opomba o standardih:** barva je dev-only chrome, ki nikoli ne pride do prod uporabnikov, zato je navadna `Colors.orange` (namenoma »ne-brand«) sprejemljiva izjema od pravila »barve prek teme«.

---

## 4. Alternative

- **B) Chip v AppBar na Domov** — manj vsiljiv, a viden le na Domov.
- **C) Oznaka okolja na splash zaslonu + v Nastavitvah** — vidiš ob zagonu / na zahtevo, ne stalno.

---

## 5. Obseg / ne-cilji

- **Cilj:** vizualno ločiti staging/offline od produkcije med razvojem.
- **Ne-cilj:** preklapljanje okolja v aplikaciji (okolje ostaja vezano na `--dart-define` ob buildu); kakršen koli prikaz na produkciji.

**Ocena:** trivialno (~6 vrstic v `app.dart`, brez sheme/testov/i18n — niz je dev-only, ne lokaliziran).
