# Prompt za novo sejo (kopiraj v nov Claude Code chat)

> Memory + CLAUDE.md se naložita samodejno; ta prompt samo usmeri fokus.
> Zadnja posodobitev: **2026-07-21** (po pripravi jezikovnih listingov + posnetkov).

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

**Fokus te seje: vc16 — nova izdaja s parkiranima popravkoma.**

### A) vc16 — nova izdaja s parkiranima popravkoma (razvojno delo)
Na `main` čakata dva popravka; vc16 naj ju zajame:
1. **`kVersionChannel = ' (beta)'` (`core/config.dart` ~vrstica 161)** — izdaja 15 v nastavitvah še piše
   »(beta)«. Ob popravku se **odloči, ali naj se pripona izpelje samodejno** (`kDebugMode` / `--dart-define`),
   da se ročni preklop ne more več pozabiti.
2. **Morda vidnejši »Preskoči« na zaslonu Lokacija** (`location_screen.dart` ~274-284) — gumb »Nadaljuj«
   dela pravilno tudi s praznim obrazcem, a ni videti kot preskok; kandidat, če Play ponovi očitek
   »manjkajo podatki za prijavo«.
Postopek: popravi → `flutter test` (cel suite, ne le analyze) → bump `pubspec` na **`1.0.0+16`** →
release build → on-device test → 👤 upload v produkcijo (ali najprej zaprti/interni trak).

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
