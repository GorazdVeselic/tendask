# Dimni test na napravi (SM A536B)

Ponovljiv scenarij po večjem posegu v presentation plast. Koraki so zapisani v
**napisih**, ne v koordinatah, in tečejo v **enem** zagonu — brez posnetkov
zaslona in brez potrjevanja ukaza za vsak tap.

## Zagon (deploy)

```powershell
adb shell svc power stayon true   # sicer ugasnjen zaslon požre simulirane tape
.\deploy.bat                      # release + produkcija = nadgradnja na mestu
.\deploy.bat hot                  # debug + staging (isti podpis = nadgradnja brez uninstall)
```

> **USB pade sredi `deploy.bat` (»Lost connection to device«) — pogosto (2× v eni
> seji).** `flutter run` takrat izstopi, a nov build **ni nameščen** (preveri
> `adb shell dumpsys package app.tendask | grep lastUpdateTime`). Robustneje je
> zgraditi APK v datoteko (imun na USB, se zaključi), nato namestiti ločeno:
> ```
> flutter build apk --debug --dart-define-from-file=dart_defines.staging.json
> adb install -r build/app/outputs/flutter-apk/app-debug.apk
> ```
> Ne zanašaj se na `build/app/outputs/flutter-apk/app-debug.apk` po `flutter run`
> — tam ostane star APK; `flutter run` ga ne prepiše.

## Vodenje (adb_run)

Koraki v `tmp/steps.txt` → poženi **`& ./tool/adb_run.ps1`** (vedno **isti** ukaz,
allowlistan v `.claude/settings.local.json` → ne sprašuje). Datoteko lahko
prepišeš in skript poženeš večkrat zapored — ukazni niz se ne spremeni.

> **NIKOLI ne vodi prek `adb_ui.ps1 -Tap …` z različnimi argumenti** — vsak drug
> niz je nov ukaz in Claude Code vpraša za dovoljenje pri vsakem tapu. Prav tako
> ne prek `powershell -File …` (ugnezdenega procesa ne validira). Samo
> `& ./tool/adb_run.ps1` + `tmp/steps.txt`.

Podprti koraki: `taptext <napis>`, `tap x y`, `text …`, `key 67`, `swipe`,
`wait n`, `dump`, `echo`. `taptext` ujame tudi delni napis (emoji predpona) in
več-vrstične oznake; koordinate rabijo samo elementi brez napisa (FAB, ⋯,
puščice meseca, potrditveni gumbi dialogov — glej spodaj).

## Scenarij A — vnos opravila (entry flow) + seznam

Zadnjič odigran 2026-07-15, vse zeleno (po refaktorju entry korakov v čiste fn).

| # | Koraki | Kaj mora biti v izpisu |
|---|---|---|
| 1 | `tap 405 2152` (Opravila) | prazno stanje ali sekcije po dnevih |
| 2 | FAB `tap 540 1916` | **Korak 1 · Katero opravilo?** — mreža ploščic + »Pokaži vse (N)« |
| 3 | `taptext Zalivanje` (auto-advance) | **Korak 2 · Za kaj?** — RASTLINE + »ALI CELOTNO OBMOČJE« |
| 4 | izberi predmet: `taptext <ime rastline/območja>` | števec »1« + chip predmeta na dnu (`SelectedBar`) |
| 5 | `taptext Nadaljuj` | **Korak 3 · Kdaj** — Danes/Jutri/Datum…, Datum+Ura, Status, Ponavljanje |
| 6 | `taptext Tedensko` | »Naslednje: <datum +7>« (recurrence preview) |
| 7 | `taptext Nadaljuj` | **Korak 4 · Opomnik** — auto-seeded »Ob dogodku« + hint »Dodali smo privzeti opomnik« |
| 8 | `taptext Nadaljuj` (ali `Preskoči`) | **Pregled** — povzetek vseh polj (OPRAVILO/ZA KAJ/KDAJ/PONAVLJANJE/OPOMNIK) |
| 9 | `taptext Shrani opravilo` | seznam: sekcija **DANES**, vrstica z rastlino/območjem + značka »danes« |

### Opomnik — edit sheet + dovoljenja (`ReminderDraft`)

`Dodaj opomnik` na koraku 4 najprej sproži **priming** (»Vklopi obvestila«) → OS
poziv za obvestila → **exact-alarm gate** (»Dovoli točne opomnike«, Android 14+
ni privzeto). Da prideš do samega edit sheeta brez ročne poti skozi nastavitve:

```
adb shell cmd appops set app.tendask SCHEDULE_EXACT_ALARM allow
```

Edit sheet (`ReminderDraft`): preseti (`Ob dogodku`/`10 minut`/`1 uro`/`1 dan`/
`2 dni`/`Po meri…`), živ preview spodaj, gumb `Dodaj opomnik`. Že dodan preset
kaže »**že dodano**« in je onemogočen (`reminderOffsetTaken` dedup). `taptext
1 uro prej` → preview se posodobi → `taptext Dodaj opomnik` → nazaj na koraku 4 z
dvema opomnikoma.

## Scenarij B — ponovitev, dnevnik, koledar

| # | Koraki | Kaj mora biti v izpisu |
|---|---|---|
| 1 | odpri opravilo → `taptext Označi kot opravljeno` | naslednja ponovitev (+7 dni) pod **TA TEDEN** |
| 2 | `taptext Dnevnik` | skupina dneva »Danes« z opravljenim opravilom |
| 3 | `taptext Opombe` | »Ni opomb.« (prazno sporočilo po filtru) |
| 4 | `taptext Mesec` | mesec, »N opravil ta mesec«, izbran današnji dan + seznam dneva |
| 5 | `tap 980 487` (naslednji mesec) | tuj mesec: brez izbranega dneva in brez gumba za dodajanje |

## Scenarij C — izbris opravila (pospravljanje po testu)

| # | Koraki | Kaj mora biti v izpisu |
|---|---|---|
| 1 | odpri opravilo (`taptext <naslov>`) | detajl z gumbi na dnu: Označi/… /Uredi/Podvoji/**Izbriši** |
| 2 | `taptext Izbriši` | dialog »Izbriši opravilo? To dejanje je nepopravljivo.« |
| 3 | `tap 749 1298` (potrdi »Izbriši«) | nazaj na seznam, prazno stanje |

## Koordinate brez napisa

Portrait 1080×2400, SL.

| Element | tap |
|---|---|
| Spodnja nav: Domov / Opravila / Dnevnik / Vrt | 135 / 405 / 675 / 945, 2152 |
| FAB (hiter vnos) — sredinski | 540, 1916 |
| Nastavitve (zobnik, Domov AppBar desno) | 1010, 166 |
| Potrditveni gumb dialoga (desni) | 749, 1298 |
| Koledar: prejšnji / naslednji mesec | 100 / 980, 487 |
