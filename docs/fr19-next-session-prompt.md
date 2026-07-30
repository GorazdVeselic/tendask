# FR-19 — prompt za naslednjo sejo (živ dokument)

> Ob koncu vsakega koraka sejo zaključi tako, da posodobiš ta dokument na NASLEDNJI korak
> (+ status v `plan-implementacije-fr19-fr20.md`). Uporabnik blok spodaj prilepi v novo sejo.

---

Gradiva FR-19 Lunin koledar po planu `docs/plan-implementacije-fr19-fr20.md` — **korak po koraku,
vsak korak v svoji seji**: en korak = en branch = en commit, vse temno (za flagom), merge v `main`.

**Naloga TE seje: samo korak T1.4 — Lunina ekliptična dolžina** (branch `feat/fr19-t1-4-moon-longitude`):

- V `lib/core/biodynamic/` dodaj Lunino ekliptično dolžino po Meeus pogl. 47: srednji elementi
  (`L'`, `D`, `M`, `M'`, `F`, `E` — formule v spec §14.2) + **~36 največjih periodičnih členov iz
  Meeus tabele 47.A**. Koeficienti so v arhiviranem prototipu
  (`N:\development\tendask\moon-prototipi-2026-07-30.zip`, P0.1) — vzemi jih od tam ali iz vira,
  ne prepisuj po spominu. Faktor `E` za člene z `M≠0` (potenca = |koef. M|); nutacija se izpusti.
- **Vratar taska:** test proti Meeus primeru 47.a — `λ(JD 2448724.5) ≈ 133.16°` z napako ≤ 0,003°.
  Če ta test ne pade skozi, se ne gre naprej.
- **Brez Riverpoda, brez Clocka, brez I/O** — čista logika; nič v aplikaciji tega še ne kliče.
  Obstoječe (`dayFor` stub, `time_base.dart`, `sun_longitude.dart`) — ne spreminjaj.

**Pred delom preberi:** plan T1 (`docs/plan-implementacije-fr19-fr20.md`) · spec §14.2
(`docs/feature-requests/biodynamic-calendar.md`) · obstoječe (`lib/core/biodynamic/`).

**Pravila:** naredi natanko ta korak in nič več (ne začenjaj T1.5). Pred merge: `flutter analyze`
čist + cel `flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu označi T1.4 ✅, posodobi
ta dokument na korak T1.5 (`feat/fr19-t1-5-zodiac`) in predlagaj commit.

**Stanje odločitev:** A1=C, A3=A ✅ · A4/A5/A6 (barve, ikone, privzeto stikalo) še odprte — blokirajo
šele T3, ne motorja.
