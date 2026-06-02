# Tendask — Brand Guide (POTRJENO)

> **Status:** potrjena vizualna identiteta · 2026-06-01
> **Smer:** D (uravnotežena) — paleta + tipografija; logo iz smeri A (organski list v šesterokotniku, **brez kljukice**).
> **Predogled:** `docs/brand/final.html` · primerjava smeri: `docs/brand/directions.html`
> **Assets:** `docs/brand/assets/` (SVG = vir resnice; Flutter bere prek `flutter_svg`).

---

## 1. Logotip

**Koncept:** **list** (vrt) znotraj **šesterokotnika** (H3 celica → bodoča skupnost). Žila lista je subtilna
(ne kljukica — kljukica je tekmovala z listom in slabšala berljivost v drobnem).

| Datoteka | Uporaba |
|----------|---------|
| `assets/logomark.svg` | **primarni** — bel šesterokotnik + zelen list; za zelene/temne/foto podlage |
| `assets/logomark-mono.svg` | enobarvno zeleno; za **svetle** podlage |
| `assets/logomark-white.svg` | vse belo; za temne/fotografske podlage |
| `assets/app-icon.svg` | ikona aplikacije 1024×1024 (zelen gradient + mark) |
| `assets/app-icon-foreground.svg` | Android adaptivni **prednji** sloj (prosojno, 66% safe zone) |

**Wordmark:** „Tendask" v **Plus Jakarta Sans ExtraBold (800)**, letter-spacing −0.8px.
Lockup = mark + wordmark vodoravno, razmik = višina marka × 0.4.

### Pravila
- **Čisti prostor** okoli logotipa = ½ višine šesterokotnika.
- **Min. velikost:** mark 18 px (favicon/notif še bere). Pod 24 px raje inverz (bel list na zelenem).
- **NE:** ne razteguj, ne rotiraj, ne menjaj barv lista/šesterokotnika, ne dodajaj kljukice nazaj, ne postavljaj barvnega marka na pisano foto (uporabi `-white`).

---

## 2. Barvna paleta (design tokeni)

> Usklajeno z obstoječim `wireframes/styles.css`. Primarna zelena = nespremenjena.

| Token | Hex | Vloga |
|-------|-----|-------|
| `green-900` | `#205A28` | globoka zelena — žile, sence, pritisnjeno |
| `green` (primary) | `#2e7d32` | **primarna** — gumbi, poudarki, app bar |
| `green-400` | `#3a9a57` | svetla zelena — gradienti, hover |
| `honey` (accent) | `#E0A82E` | **redek** topel poudarek — "danes", praznovanja, opozorila (NE prevladuje) |
| `soft` | `#e8f3ea` | mehka zelena — ploščice ikon, oznake |
| `softer` | `#f2f8f3` | še mehkejša podlaga |
| `ink` | `#1d2823` | besedilo |
| `muted` | `#6b7770` | pridušeno besedilo |
| `bg` | `#eceef0` | ozadje zaslona |
| `surface` | `#ffffff` | kartice/površine |
| `line` | `#e4e8e5` | obrobe |

Pomožne (iz styles.css, ohranjene): `warn #b46b00`/`warn-soft #fff4e0`, `info #2266aa`/`info-soft #e6f0fa`.

**Flutter:** prenesi te tokene v `lib/app/theme.dart` (`ColorScheme` + lasten `ThemeExtension` za `honey`/`soft`).

---

## 3. Tipografija

- **Pisava:** **Plus Jakarta Sans** (Google Fonts; Latin Extended → č š ž / ä ö ü ß). En sklad za vse.
- **Teže:** 400 telo · 500/600 poudarki · 700 podnaslovi · 800 naslovi/wordmark.
- **Flutter:** paket `google_fonts` ali priloži statične `.ttf` (offline-varno, brez omrežja ob zagonu →
  **priporočam priložene ttf** zaradi offline narave aplikacije). Dodaj v `pubspec.yaml` `fonts:`.
- Lestvica (osnutek): naslov 28/800 · h2 22/700 · podnaslov 19/600 · telo 15/400 · drobno 13/500.

---

## 4. App-ikona — kako narediti PNG-je

SVG je vir; za trgovine rabiš PNG-je. Priporočen Flutter workflow:

```bash
# 1) iz app-icon.svg naredi 1024 PNG (enkrat — kjerkoli imaš orodje):
#    rsvg-convert -w 1024 -h 1024 docs/brand/assets/app-icon.svg -o icon-1024.png
#    (ali Inkscape / online SVG→PNG / Figma izvoz)
# 2) v Flutter projektu:
flutter pub add --dev flutter_launcher_icons
```
`pubspec.yaml`:
```yaml
flutter_launcher_icons:
  image_path: "assets/icon/icon-1024.png"        # iOS + privzeto
  android: true
  ios: true
  adaptive_icon_background: "#2e7d32"             # poln barvni sloj (ozadje)
  adaptive_icon_foreground: "assets/icon/foreground.png"  # iz app-icon-foreground.svg @1024
  remove_alpha_ios: true
```
```bash
dart run flutter_launcher_icons
```
Potrebna PNG-ja: `icon-1024.png` (iz `app-icon.svg`) + `foreground.png` (iz `app-icon-foreground.svg`).
V aplikaciji (splash, prazna stanja) uporabljaj **SVG direktno** prek `flutter_svg` — brez PNG-jev.

---

## 5. Splošni ton

- **Mirno, pregledno, naravno.** Veliko belega prostora, mehke sence (`0 8px 30px rgba(20,40,30,.12)`),
  zaobljeni robovi (16 px / 12 px). Ena prevladujoča zelena, medena le kot pika poudarka.
- Emoji 🌿/🌱 sta dovoljena v sporočilih/onboardingu, a ne v UI-kromu.

---

## 6. Inventar datotek

```
docs/brand/
  brand.md                    # ta dokument
  directions.html             # primerjava 4 smeri (arhiv odločitve)
  final.html                  # predogled potrjene znamke
  assets/
    logomark.svg              # primarni (barvni)
    logomark-mono.svg         # enobarvno zeleno (svetle podlage)
    logomark-white.svg        # belo (temne podlage)
    app-icon.svg              # 1024 ikona (gradient + mark)
    app-icon-foreground.svg   # Android adaptivni prednji sloj
```
