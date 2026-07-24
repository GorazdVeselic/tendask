# Prompt za novo sejo (kopiraj v nov Claude Code chat)

> Memory + CLAUDE.md se naložita samodejno; ta prompt samo usmeri fokus.
> Zadnja posodobitev: **2026-07-21** (po pripravi vc16 — beta pripona odstranjena, bump 1.0.1+16, on-device potrjen).

---

Nadaljujeva Tendask. **Aplikacija je javno na Google Play** (`1.0.0+15`, Splošna razpoložljivost,
40 držav). Produkcijski dostop odobren, migracije aplicirane, katalog 141 rastlin. Stanje:
`docs/go-live/play-console-status.md`.

**Kaj sva zaključila zadnjič (2026-07-21, commita `9f7d3e5` + `3f60764` na `main`):**
- **Prevoda listinga SL + DE oddana v pregled** + osvežen EN privzeti (dodane funkcije sredstva/recepti/
  pridelek/teme; iz opisov odstranjeni pomišljaji na uporabnikovo željo; ime aplikacije nedotaknjeno).
  Besedila v `store-listing.md`.
- **Identiteta (dev verification) + target-API do 31. 8. 2026 = potrjena zelena** v konzoli.
- **Jezikovne feature grafike + 3×8 posnetkov zaslona NALOŽENI na Play (👤 2026-07-21)** — po jezikih
  (privzeti=EN, prevoda sl/de svoje). Viri: `assets/feature-graphic-{en,sl,de}-1024x500.png` (+ `-base-`
  + generator `gen-feature-graphic.py`) in `assets/screenshots/play-{sl,en,de}/` (`NN-{si,en,de}-*.png`).

**Fokus te seje: 👤 naloži vc16 v produkcijo (koda + build sta gotova).**

### A) vc16 — ✅ ZGRAJEN + on-device potrjen, čaka samo upload
- **`kVersionChannel = ''`** (`core/config.dart:161`) — beta pripona odstranjena (izdaja 15 je v Nastavitvah
  še pisala »(beta)«). Odločeno: preprosta prazna vrednost, brez dodatne dart-define mašinerije.
- **Bump `1.0.0+15` → `1.0.1+16`** (`pubspec.yaml`) — prvi bump versionName.
- **`flutter test` = 823/823**; commit `75c6e31` na `main`.
- **On-device potrjeno (2026-07-21, SM A536B):** `versionCode=16`, `versionName=1.0.1`, app se zažene brez
  fatal izjem; `targetSdk=36`. AAB: `build/app/outputs/bundle/release/app-release.aab`.
- **PARKIRANO (ni v vc16):** vidnejši »Preskoči« na `location_screen.dart:274-284` — gumb »Nadaljuj« s praznim
  obrazcem že deluje kot preskok; prvi kandidat, **če** Play ponovi očitek »manjkajo podatki za prijavo«.

👤 **Ostane samo:** upload `app-release.aab` v produkcijski trak (nova izdaja). Pozor: versionCode 16 se
porabi že ob nalaganju.

### B) 👤 Preveri, da so listing-spremembe prešle Googlov pregled
Prevodi (SL+DE), feature grafike in posnetki so **naloženi** (2026-07-21) in šli v pregled. Preveri v
Play Console → Pregled objave, da je odobreno in v živo (če je še »v pregledu«, ni treba ukrepati).

**Postopek (po CLAUDE.md):**
- Preberi `play-console-status.md` (+ `store-listing.md` če se dotikaš besedil) preden karkoli predlagaš.
- **Ne ugibaj klik-poti v Play Console** — prenovljena je; vprašaj za posnetek, če nisi prepričan.
- Ob koncu posodobi dokumentacijo in **vprašaj za commit** (ne commitaj brez dovoljenja).

**Konteksta, ki ga ne izgubi:**
- **Play porabi `versionCode` že ob NALAGANJU svežnja**, v katerikoli trak — ne ob objavi. Naslednji
  build mora biti **`1.0.0+16`** (vc14 in vc15 sta porabljeni).
- **Sentry `invalid_icon` ni bug za uporabnike** — dogodki so z Googlovega pre-launch emulatorja
  (`android_x64`, `Users 0`); popravek `c0fc290` je na `main`. **Zdaj imamo prave uporabnike:** če se
  v Sentryju pojavi napaka z `Users > 0`, ima **prednost pred vsem zgoraj**.
- **On-device seeding gotcha** (če boš spet delal posnetke/testne podatke): `adb input text` **NE tipka
  šumnikov/umlautov** (č/š/ž/ü/ö/ä/ß → NullPointerException) — tipkana imena izbiraj brez diakritike;
  katalog rastlin + UI se prevajata sami. Preimenovanje odporno na re-sort z `taptext <staro-ime>`
  (a postavka mora biti izrisana → dolgi seznami rabijo scroll). Glej memory `feedback-ondevice-tap-map`.
- Telefon je bil po zadnji seji **očiščen** (app odstranjen); ob delu na napravi preklopi jezik nazaj
  na slovenščino in se prijavi v svoj račun.
