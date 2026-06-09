# Tendask — Play grafični aseti

Generirano iz brand virov (`docs/brand/assets/`) prek `tmp/icongen/gen-store.js` (sharp).
Po spremembi brand SVG-jev regeneriraj: `cd tmp/icongen && node gen-store.js`.

## Pripravljeno ✅

| Datoteka | Velikost | Namen | Play zahteva |
|---|---|---|---|
| `icon-512.png` | 512×512 | App icon (store) | 512×512 PNG, 32-bit |
| `feature-graphic-1024x500.png` | 1024×500 | Feature graphic | 1024×500 PNG/JPEG |

## Še potrebno 👤 — Posnetki zaslona

Play zahteva **vsaj 2** telefonska posnetka (max 8). Priporočam **4–6**.

- **Format:** PNG ali JPEG, razmerje 9:16 (portret), min stranica ≥ 320 px, max ≤ 3840 px.
  Posnetek z naprave (npr. 1080×2400) je idealen — naloži ga kar takega.
- **Build:** uporabi **release** build (čist videz, brez debug pasu).
- **Jezik:** zajemi v slovenščini (primarni listing). Po želji še EN/DE set za prevode (neobvezno).

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
