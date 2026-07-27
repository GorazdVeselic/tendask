# UI katalog — en widget na vzorec, barve samo prek teme

Izsek iz `CLAUDE.md` (2026-07-25), ker velja **samo pri delu na presentation plasti**.
Preberi ga, preden dodaš ali spremeniš zaslon, obrazec, sheet ali dialog.
Splošna presentation pravila (brez podvojenih widgetov, brez prop-drillinga, napake niso
`SizedBox.shrink()`, >~300 vrstic = razrez) ostajajo v `CLAUDE.md`.

## Komponentni katalog (en widget na vzorec — nikoli lokalna kopija)

Za vsak ponavljajoč se UI vzorec obstaja EN skupni widget. Lokalna `_SectionTitle`/`_Label`/`_EmptyHint` kopija = rdeč alarm.

- **Sekcijska oznaka** (skupina/sekcija v seznamu ali zaslonu) → `SectionLabel` (`core/widgets/section_label.dart`) — **VELIKE črke**, `labelSmall`, letterSpacing, `onSurfaceVariant`. En sam stil sekcij v aplikaciji.
- **Oznaka nad poljem v obrazcu** → `FieldLabel` (isti file) — sentence-case, `labelMedium`, `onSurfaceVariant`.
- **Prazen celozaslonski seznam** → `EmptyState` (`core/widgets/empty_state.dart`). **Dashboard/inline hint** (kratek kontekstni namig, npr. Domov »danes nič«) ni list-empty — sme biti lokalen in kompakten (ne `EmptyState`, ki je centriran in zračen).
- **Prazen seznam pod `RefreshIndicator`** → `PullableEmpty` (isti file) — `EmptyState` v scrollu, ki sprejme potisk navzdol. Gol `Center` ne scrolla, zato bi prav prazno stanje (tam uporabnik največkrat potegne) gesto požrlo.
- **Izbris v edit obrazcu** → `DestructiveButton` (`core/widgets/destructive_button.dart`) — rdeč (`colorScheme.error`), inline na **dnu vsebine**, samo v edit mode. **Nikoli** delete kot ikona v AppBar s privzeto barvo (izgleda onemogočen).
- **Izbris v `⋯` action sheetu** → zadnja `ListTile` vrstica, ločena z `Divider`, ikona+tekst v `colorScheme.error`.
- **Potrditev izbrisa** → `showConfirmDialog(..., destructive: true)` (`core/widgets/confirm_dialog.dart`) — rdeč `FilledButton`.
- **Shrani/potrdi gumb**: full-screen obrazec → `SaveBar`; bottom sheet → `FilledButton` (48h, full-width) — isti videz.
- **Bottom sheet** → vedno `SheetHandle` na vrhu.

## Barve in stil samo prek teme

- **Destruktivno/napaka = `colorScheme.error`**, nikoli hardcode rdeča; brand barve so v `theme/` (`AppColors.danger` ipd.).
- **Sekundarni/muted tekst = `colorScheme.onSurfaceVariant`** (= brand muted, nastavljen v temi).
- **Hint je medel globalno prek `inputDecorationTheme.hintStyle`** — ne nastavljaj `hintStyle` per-field; hint nikoli ne sme izgledati kot vnesen tekst.

---

Sorodno: `docs/screen-map.md` (zasloni, rute, prehodi), `docs/brand/brand.md` (vizualna identiteta), `docs/wireframes/*`.
