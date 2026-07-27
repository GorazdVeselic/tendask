# Prelomi besed sredi besede — breme in pravilo

> **Status:** odprto · najdeno 2026-07-27 med M11 popravki (P9)
> **Pravilo:** `test/layout/layout_harness.dart` → `layoutBreaks`, izhodiščni seznam
> `kAcceptedWordBreaks`
> **Paket:** samostojen, takoj po M11 (dogovor 2026-07-27)

---

## 1 · Kaj se dogaja

Ko je škatla ožja od najdaljšega nezlomljivega kosa besedila, Flutter besedo prelomi **sredi
besede**: `Tedensk` / `o`, `Sloven` / `ščina`, `Startsei` / `te`. Nič se ne odreže, nič ne vrže
izjeme, `RenderFlex` ne javi overflowa — zato je bilo to za layout matriko **nevidno**.

Matrika je do zdaj lovila dva razreda: `overflow` izjeme in odrezan **vrstično omejen** tekst.
Prosto ovijajoč tekst je namenoma preskočila, ker se res nikoli ne odreže. To drži — samo pove
premalo: prosto ovijajoč tekst se **lahko prelomi sredi besede**, in to je enako razbito.

## 2 · Pravilo

`layoutBreaks` zdaj za vsak `RenderParagraph` izmeri najširši nezlomljiv kos in ga primerja s
škatlo. Meritev je lastna (`TextPainter` z istim slogom in `textScaler`), **ne** `getMinIntrinsicWidth`
— ta vezaja ne šteje za mesto preloma in bi `Aufgaben-Erinnerungen` lažno prijavil, čeprav se
lepo prelomi na vezaju. Ta razlika je odstranila 18 od 104 prvotnih zadetkov.

Vključeno pravilo je pokazalo **44 nizov na 11 zaslonih**. Da paket ne ostane rdeč, so ti zapisani
v `kAcceptedWordBreaks`: **nov** prelom pade takoj, teh 44 pa čaka na ta paket. Seznam vsebuje
samo besede, nikoli piksle — te premakne vsaka sprememba pisave ali paddinga.

## 3 · Breme

`**` = lomi se že pri **privzeti** velikosti pisave (×1.0), torej brez kakršnekoli nastavitve
uporabnika.

| Zaslon | Kos | Jeziki | Širine (dp) | Skala |
|---|---|---|---|---|
| `appearance` | `Dunkel` | de | 320 | ×1.0/1.3 |
| `appearance` | `Sistemsko` | sl | 320/360/411 | ×1.0/1.3 |
| `appearance` | `Svetlo` | sl | 320 | ×1.0/1.3 |
| `appearance` | `System` | de/en | 320/360 | ×1.0/1.3 |
| `appearance` | `Temno` | sl | 320 | ×1.0/1.3 |
| `areas` | `Bereiche` | de | 320 | ×1.3 |
| `areas` | `Območja` | sl | 320 | ×1.3 |
| `areas` | `Sredstva` | sl | 320 | ×1.3 |
| `areas` | `Supplies` | en | 320 | ×1.3 |
| `entry/review` | `ERINNERUNG` | de | 320/360/411 | ×1.3 |
| `entry/review` | `PONAVLJANJE` | sl | 320/360/411 | ×1.0/1.3 |
| `entry/review` | `WIEDERHOLUNG` | de | 320/360/411 | ×1.0/1.3 |
| `entry/review` | `Wöchentlich` | de | 320/360 | ×1.0/1.3 |
| `entry/review` | `Zelenjavni` | de | 320 | ×1.3 |
| `entry/when` | `Custom` | en | 320/360 | ×1.0/1.3 |
| `entry/when` | `Dnevno` | sl | 320/360 | ×1.0/1.3 |
| `entry/when` | `Eigene` | de | 320 | ×1.3 |
| `entry/when` | `Tedensko` | sl | 320/360/411 | ×1.0/1.3 |
| `entry/when` | `Tomorrow` | en | 320/360 | ×1.3 |
| `entry/when` | `Täglich` | de | 320/360 | ×1.3 |
| `entry/when` | `Weekly` | en | 320/360 | ×1.0/1.3 |
| `entry/when` | `Wöchentlich` | de | 320/360/411 | ×1.0/1.3 |
| `entry/when (custom recurrence)` | `Custom` | en | 320/360 | ×1.0/1.3 |
| `entry/when (custom recurrence)` | `Dnevno` | sl | 320/360 | ×1.0/1.3 |
| `entry/when (custom recurrence)` | `Eigene` | de | 320 | ×1.3 |
| `entry/when (custom recurrence)` | `Tedensko` | sl | 320/360/411 | ×1.0/1.3 |
| `entry/when (custom recurrence)` | `Tomorrow` | en | 320/360 | ×1.3 |
| `entry/when (custom recurrence)` | `Täglich` | de | 320/360 | ×1.3 |
| `entry/when (custom recurrence)` | `Weekly` | en | 320/360 | ×1.0/1.3 |
| `entry/when (custom recurrence)` | `Wöchentlich` | de | 320/360/411 | ×1.0/1.3 |
| `nav (five tabs)` | `Aufgaben` | de | 320/360 | ×1.3 |
| `nav (five tabs)` | `Opravila` | sl | 320 | ×1.3 |
| `nav (five tabs)` | `Startseite` | de | 320/360 | ×1.3 |
| `nav (five tabs)` | `Tagebuch` | de | 320/360 | ×1.3 |
| `nav (five tabs)` | `Umgebung` | de | 320/360/411 | ×1.0/1.3 |
| `note-form` | `Yesterday` | en | 320/360 | ×1.3 |
| `notifications` | `Erinnerungen` | de | 320 | ×1.3 |
| `notifications` | `dogodku` | sl | 320 | ×1.3 |
| `settings` | `Benachrichtigungen` | de | 320/360 | ×1.0/1.3 |
| `settings` | `Slovenščina` | de/en/sl | 320/360/411 | ×1.0/1.3 |
| `task-detail` | `Wiederholung` | de | 320/360/411 | ×1.3 |
| `tasks` | `Gießen` | de | 320/360 | ×1.0/1.3 |
| `tasks` | `Watering` | en | 320/360 | ×1.0/1.3 |
| `tasks` | `Zalivanje` | sl | 320 | ×1.3 |
| `tasks` | `Zelenjavni` | de/en/sl | 320/360 | ×1.0/1.3 |

### Prioriteta

1. **`entry/when` + `entry/review`** — čarovnik vnosa je najbolj obiskana pot v aplikaciji, lomi se
   pri ×1.0 na **360 dp** (privzeta Galaxy S23). Chipi ponavljanja (`Dnevno`/`Tedensko`/`Weekly`).
2. **`settings`, `appearance`, `tasks`** — prav tako ×1.0; `Slovenščina` se lomi v **vseh** jezikih
   na **vseh** širinah.
3. **`areas`, `notifications`, `note-form`, `task-detail`** — samo ×1.3.
4. **`nav (five tabs)`** — ni v produkciji (flag-dark), zato **ni** del tega bremena, ampak
   **pogoj za prižig** `kCommunityEnabled` (gl. `docs/deploy-runbook.md`).

## 4 · Vzorci popravkov

Vsi zadetki so ena od treh oblik, ne 44 ločenih problemov:

- **Tesna kontrola s fiksno razdelitvijo** (`SegmentedButton`, chipi ponavljanja, spodnja vrstica):
  širina reže = širina / število elementov. Rešitve: krajše oznake v vseh treh jezikih, drseč
  seznam namesto enakomerne razdelitve, ali oznaka samo na izbranem elementu.
- **Dvostolpčna vrstica** (`ListTile` z vrednostjo desno — `Slovenščina`, `Benachrichtigungen`):
  naslov dobi ostanek širine. Rešitev: vrednost pod naslovom (`subtitle`) namesto ob njem, ali
  `Flexible` z večjim deležem.
- **Dolgo ime v ozkem stolpcu** (`Zelenjavni vrt`, imena opravil v seznamu): uporabniško besedilo,
  ki ga ne moremo skrajšati. Rešitev je pri kontroli, ne pri nizu.

## 5 · Kako preveriš stanje

```
flutter test test/layout/
```

Za seznam preostalih: zakomentiraj vnos v `kAcceptedWordBreaks` in poženi znova — izpis pove
natančen kos, potrebno širino in dejansko škatlo.
