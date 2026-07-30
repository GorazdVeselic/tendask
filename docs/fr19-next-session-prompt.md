# FR-19 — prompt za naslednjo sejo (živ dokument)

> Ob koncu vsakega koraka sejo zaključi tako, da posodobiš ta dokument na NASLEDNJI korak
> (+ status v `plan-implementacije-fr19-fr20.md`). Uporabnik blok spodaj prilepi v novo sejo.

---

Gradiva FR-19 Lunin koledar po planu `docs/plan-implementacije-fr19-fr20.md` — **korak po koraku,
vsak korak v svoji seji**: en korak = en branch = en commit, vse temno (za flagom), merge v `main`.

**Naloga TE seje: samo korak T1.3 — Sončeva ekliptična dolžina** (branch `feat/fr19-t1-3-sun`):

- V `lib/core/biodynamic/` dodaj Sončevo ekliptično dolžino po Meeus pogl. 25 (nizka natančnost,
  ~10 vrstic): `L0`, `M`, `C`, `λ☉ = (L0 + C) mod 360` — formule v spec §14.3. Vhod = `T`
  (julijanska stoletja) iz obstoječega `time_base.dart`.
- Unit test proti znani vrednosti (Meeus primer 25.a: JD 2448908.5 → λ☉ ≈ 199.90988°).
- **Brez Riverpoda, brez Clocka, brez I/O** — čista logika; nič v aplikaciji tega še ne kliče.
  Obstoječi API (`dayFor`, `BiodynamicDay`, `CalendarSystem`, `time_base.dart`) — ne spreminjaj ga.

**Pred delom preberi:** plan T1 (`docs/plan-implementacije-fr19-fr20.md`) · spec §14.3
(`docs/feature-requests/biodynamic-calendar.md`) · obstoječe (`lib/core/biodynamic/`).

**Pravila:** naredi natanko ta korak in nič več (ne začenjaj T1.4). Pred merge: `flutter analyze`
čist + cel `flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu označi T1.3 ✅, posodobi
ta dokument na korak T1.4 (`feat/fr19-t1-4-moon-longitude`) in predlagaj commit.

**Stanje odločitev:** A1=C, A3=A ✅ · A4/A5/A6 (barve, ikone, privzeto stikalo) še odprte — blokirajo
šele T3, ne motorja.
