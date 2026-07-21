# Tendask — Play grafični aseti

Generirano iz brand virov (`docs/brand/assets/`) prek `tmp/icongen/gen-store.js` (sharp).
Po spremembi brand SVG-jev regeneriraj: `cd tmp/icongen && node gen-store.js`.

## Pripravljeno ✅

| Datoteka | Velikost | Namen | Play zahteva |
|---|---|---|---|
| `icon-512.png` | 512×512 | App icon (store) | 512×512 PNG, 32-bit |
| `feature-graphic-1024x500.png` | 1024×500 | Feature graphic (izvirnik, SL »Dnevnik za tvoj vrt«) | 1024×500 PNG/JPEG |

### Predstavitvena slika — po jezikih (2026-07-21)

Feature graphic je **per-listing** (ne per-build). Podnapis je usklajen z app taglinom (`<locale>.i18n.json` → `auth.tagline`).
Iz izvirnika ostanejo logotip + napis + medena podčrta **pikselsko nedotaknjeni**, zamenjan je **samo pas
podnapisa** (y 296–356) z interpolacijo gradienta; pisava = `Plus Jakarta Sans` w400/38 px, barva (240,245,240).

**Osnova + generator** (za prihodnje besedilne variante):
- `feature-graphic-base-1024x500.png` — **osnova brez podnapisa** (samo logotip + napis + podčrta). Nova varianta =
  ta osnova + centriran podnapis (cx=638, cy=328).
- `gen-feature-graphic.py` — regenerira osnovo iz izvirnika in izriše jezikovne različice. Nov jezik/besedilo =
  dodaj `render('<besedilo>', '…-xx-1024x500.png')`. Zaženi iz korena repo: `python docs/go-live/assets/gen-feature-graphic.py`.

| Datoteka | Listing | Podnapis (= app `auth.tagline`) |
|---|---|---|
| `feature-graphic-en-1024x500.png` | Privzeti (en-US) | Your garden journal |
| `feature-graphic-sl-1024x500.png` | Prevod sl-SI | Tvoj vrtni dnevnik |
| `feature-graphic-de-1024x500.png` | Prevod de-DE | Dein Gartentagebuch |

**Nalaganje 👤:** Objave v trgovini → Privzeta objava → Uredi → (za vsak jezik prek izbirnika/»Upravljanje prevodov«)
→ Grafični elementi → Predstavitvena slika → zamenjaj. Privzeti listing dobi EN; prevoda dobita svojo, sicer podedujeta EN.

## Posnetki zaslona — 3 jezikovni seti po 8, pripravljeni ✅ (2026-07-21)

Zajeti na napravi (SM A536B, **prod build vc15**) v **eni sveži gostujoči seji** z bogato posejanimi podatki
(3 območja · 30 rastlin · 5 sredstev · 5 receptov · opravila z zamudo/danes/jutri · dnevnik z opravili+opombo+pridelkom).
**Temna tema.** Isti podatki, trije jeziki: telefon preklopljen sl→en→de, tipkana imena (območja/sredstva/recepti/opomba)
ročno prevedena med prehodi (katalog rastlin + UI se prevedeta samodejno). Surovi 1080×2400 → obrez (vrh −90 statusna,
dno −150 navigacija) = **1080×2160** (`tmp/crop_{sl,en,de}.py`).

| # | Datoteka `NN-…png` | Zaslon |
|---|---|---|
| 1 | `01-home` | Domov — vreme + zamujeno + danes + pridelek |
| 2 | `02-tasks` | Opravila — zamuda / danes / jutri |
| 3 | `03-garden` | Vrt/Območja — območja + rastline |
| 4 | `04-supplies` | Vrt/Sredstva — 3 kategorije + zaloge |
| 5 | `05-recipes` | Vrt/Recepti — 5 receptov |
| 6 | `06-journal` | Dnevnik — opravila + opomba + pridelek |
| 7 | `07-quick-entry` | Hiter vnos — mreža tipov (26) |
| 8 | `08-task-detail` | Detajl — zamrznjen vremenski posnetek |

| Set | Mapa | Listing |
|---|---|---|
| 🇸🇮 SL | `screenshots/play-sl/` | prevod **sl-SI** |
| 🇬🇧 EN | `screenshots/play-en/` | **privzeti (en-US)** — nadomesti stari 6-set v `play/` |
| 🇩🇪 DE | `screenshots/play-de/` | prevod **de-DE** |

**Nalaganje 👤:** Objave v trgovini → Privzeta objava → Uredi → (privzeti = EN; za prevoda prek »Upravljanje prevodov«
izberi jezik) → Grafični elementi → Posnetki zaslona telefona → naloži 8 iz ustrezne mape (vrstni red = zaporedje datotek).
Gre v pregled. Brez per-jezičnih posnetkov prevod podeduje EN.

> **Postopek (ponovljiv):** `adb shell pm clear app.tendask` → gost + lokacija (GPS) → seed prek `tool/adb_run.ps1`.
> **Gotcha — brez umlautov/šumnikov:** `adb input text` ne tipka č/š/ž/ü/ö/ä/ß (vrže NullPointerException), zato so
> tipkana imena izbrana brez njih (Sadovnjak/Orchard/Obstgarten, Kompost, Nutzgarten…); imena iz kataloga se izrišejo
> pravilno. Preimenovanje je odporno na abecedno preurejanje z `taptext <staro-ime>` (najde postavko ne glede na scroll);
> gumbi so lokalizirani (Save/Shrani/Speichern, Edit/Uredi/Bearbeiten). Zajem: `adb -s <serial> exec-out screencap -p
> > tmp/<lang>-raw/NN.png` → `python tmp/crop_<lang>.py`.
>
> **Stari EN 6-set** je še v `screenshots/play/` (trenutno v živo na privzetem listingu); nov `play-en/` (8, z novimi
> funkcijami) ga nadomesti ob nalaganju.

### Zgodovinski EN 6-set (star, v `screenshots/play/`)

Play zahteva **vsaj 2** telefonska posnetka (max 8). Priporočam **4–6**.

- **Format:** PNG ali JPEG, razmerje 9:16 (portret), min stranica ≥ 320 px, max ≤ 3840 px.
  Posnetek z naprave (npr. 1080×2400) je idealen — naloži ga kar takega.
- **Build:** uporabi **release** build (čist videz, brez debug pasu).
- **Jezik:** default listing je **angleščina** → zajemi **EN** set (preklopi jezik aplikacije na
  English v Nastavitvah). Po želji še SL/DE set za prevoda (neobvezno; za SI trg je SL set lep dodatek).

### Katere zaslone zajeti (predlog)

1. **Domov** — vreme + današnja opravila (pokaže glavno vrednost na prvi pogled).
2. **Hiter vnos** — izbira tipa opravila (hitrost beleženja).
3. **Opravila** — seznam čakajočih z akcijami (swipe ✓ / +1 dan).
4. **Detajl opravila** — vremenski pasovi (zamrznjen posnetek).
5. **Vrt** — območja + rastline.
6. **Dnevnik** — kronološka časovnica.

### Kako zajeti (USB, naprava SM A536B)

Strojno: gumb za vklop + znižaj glasnost. Ali prek adb:
```
adb exec-out screencap -p > docs/go-live/assets/screenshots/01-home.png
```
(Ustvari mapo `screenshots/` prej; te datoteke so velike — po želji jih NE commitaj, le naloži v
Play. `tmp/` ostaja za scratch.)

> Opcijsko kasneje: »uokvirjeni« promo posnetki (telefon okvir + napis) — za boljšo konverzijo, a
> Play tega ne zahteva. Surovi posnetki povsem zadoščajo za interni test.
