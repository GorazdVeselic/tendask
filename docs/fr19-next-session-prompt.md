# FR-19 — prompt za naslednjo sejo (živ dokument)

> Ob koncu vsakega koraka sejo zaključi tako, da posodobiš ta dokument na NASLEDNJI korak
> (+ status v `plan-implementacije-fr19-fr20.md`). Uporabnik blok spodaj prilepi v novo sejo.

---

Gradiva FR-19 Lunin koledar po planu `docs/plan-implementacije-fr19-fr20.md` — **korak po koraku,
vsak korak v svoji seji**: en korak = en branch = en commit, vse temno (za flagom), merge v `main`.

**Naloga TE seje: samo korak T1.2 — časovna osnova** (branch `feat/fr19-t1-2-timebase`):

- V `lib/core/biodynamic/` dodaj izračun julijanskega datuma (JD) iz UTC `DateTime` (standardni
  Fliegel/Meeus algoritem) in `T = (JD − 2451545.0) / 36525.0` (julijanska stoletja od J2000) —
  spec §14.1.
- Unit testi proti **znanim JD datumom** (npr. Meeusovi učni primeri, J2000 epoha) — tečejo na CI
  brez naprave.
- **Brez Riverpoda, brez Clocka, brez I/O** — čista logika; nič v aplikaciji tega še ne kliče.
  API iz T1.1 (`dayFor`, `BiodynamicDay`, `CalendarSystem`) že obstaja — ne spreminjaj ga.

**Pred delom preberi:** plan T1 (`docs/plan-implementacije-fr19-fr20.md`) · spec §14.1
(`docs/feature-requests/biodynamic-calendar.md`) · obstoječi API (`lib/core/biodynamic/`).

**Pravila:** naredi natanko ta korak in nič več (ne začenjaj T1.3). Pred merge: `flutter analyze`
čist + cel `flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu označi T1.2 ✅, posodobi
ta dokument na korak T1.3 (`feat/fr19-t1-3-sun`) in predlagaj commit.

**Stanje odločitev:** A1=C, A3=A ✅ · A4/A5/A6 (barve, ikone, privzeto stikalo) še odprte — blokirajo
šele T3, ne motorja.
