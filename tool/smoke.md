# Dimni test na napravi (SM A536B)

Ponovljiv scenarij po večjem posegu v presentation plast. Koraki so zapisani v
**napisih**, ne v koordinatah, in tečejo v **enem** zagonu — brez posnetkov
zaslona in brez potrjevanja ukaza za vsak tap.

```powershell
adb shell svc power stayon true   # sicer ugasnjen zaslon požre simulirane tape
.\deploy.bat                      # release + produkcija = nadgradnja na mestu
```

Nato: koraki v `tmp/steps.txt` → poženi **`./tool/adb_run.ps1`** (vedno isti ukaz).
Podprti koraki: `taptext <napis>`, `tap x y`, `text …`, `key 67`, `swipe`,
`wait n`, `dump`, `echo`. `taptext` ujame tudi delni napis (emoji predpona) in
več-vrstične oznake; koordinate rabijo samo elementi brez napisa (FAB, ⋯,
puščice meseca — glej spodaj).

> Ne zaganjaj skripta prek `powershell -File …`: ugnezdenega procesa Claude Code
> ne validira in vsakič vpraša za dovoljenje.

## Scenarij (zadnjič odigran 2026-07-14, vse zeleno)

| # | Koraki | Kaj mora biti v izpisu |
|---|---|---|
| 1 | `taptext Opravila` | prazno stanje ali sekcije po dnevih |
| 2 | FAB `tap 540 1916` → vrsta → predmet → `taptext Nadaljuj` | korak »Kdaj«: Danes/Jutri/Datum…, Datum + Ura, Status |
| 3 | `taptext Tedensko` | »Naslednje: <datum +7>« |
| 4 | `taptext Nadaljuj` ×2 → `taptext Shrani opravilo` | seznam: sekcija **DANES**, značka »danes« |
| 5 | odpri opravilo → `tap 540 1727` (Označi kot opravljeno) | naslednja ponovitev (+7 dni) pod **TA TEDEN** |
| 6 | `taptext Dnevnik` | skupina dneva »Danes« z opravljenim opravilom |
| 7 | `taptext Opombe` | »Ni opomb.« (prazno sporočilo po filtru) |
| 8 | `taptext Mesec` | mesec, »N opravil ta mesec«, izbran današnji dan + seznam dneva |
| 9 | `tap 980 487` (naslednji mesec) | tuj mesec: brez izbranega dneva in brez gumba za dodajanje |

## Koordinate brez napisa

Portrait 1080×2400, SL.

| Element | tap |
|---|---|
| Spodnja nav: Domov / Opravila / Dnevnik / Vrt | 135 / 405 / 675 / 945, 2152 |
| FAB (hiter vnos) — sredinski | 540, 1916 |
| Koledar: prejšnji / naslednji mesec | 100 / 980, 487 |
