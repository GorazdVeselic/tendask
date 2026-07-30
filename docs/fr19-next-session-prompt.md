# FR-19 — prompt za naslednjo sejo (živ dokument)

> Ob koncu vsakega koraka sejo zaključi tako, da posodobiš ta dokument na NASLEDNJI korak
> (+ status v `plan-implementacije-fr19-fr20.md`). Uporabnik blok spodaj prilepi v novo sejo.

---

Gradiva FR-19 Lunin koledar po planu `docs/plan-implementacije-fr19-fr20.md` — **korak po koraku,
vsak korak v svoji seji**: en korak = en branch = en commit, vse temno (za flagom), merge v `main`.

**Naloga TE seje: samo korak T1.6 — mena** (branch `feat/fr19-t1-6-phase`):

- V `lib/core/biodynamic/` dodaj meno po spec §14.6 (sistem-neodvisno): elongacija
  `e = (λLuna − λ☉) mod 360`, osvetljenost `illum = (1 − cos e)/2`, 8-stopenjska mena
  (`MoonPhase` iz `biodynamic_day.dart`) iz elongacije; mlaj/ščip = prehod `e` skozi 0/180,
  poišči z **vzorčenjem + bisekcijo** (prototip validiran na 1–3 min).
- Testi: **proti javnim menam 2026** (mlaji/ščipi, toleranca nekaj minut) + osvetljenost na
  robovih (mlaj ≈ 0, ščip ≈ 1).
- **Brez Riverpoda, brez Clocka, brez I/O** — čista logika; nič v aplikaciji tega še ne kliče.
  Obstoječe (`dayFor` stub, `time_base.dart`, `sun_longitude.dart`, `moon_longitude.dart`,
  `zodiac.dart`) — ne spreminjaj.

**Pred delom preberi:** plan T1 (`docs/plan-implementacije-fr19-fr20.md`) · spec §14.6
(`docs/feature-requests/biodynamic-calendar.md`) · obstoječe (`lib/core/biodynamic/`).

**Pravila:** naredi natanko ta korak in nič več (ne začenjaj T1.7). Pred merge: `flutter analyze`
čist + cel `flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu označi T1.6 ✅, posodobi
ta dokument na korak T1.7 (`feat/fr19-t1-7-transitions`) in predlagaj commit.

**Stanje odločitev:** A1=C, A3=A ✅ · A4/A5/A6 (barve, ikone, privzeto stikalo) še odprte — blokirajo
šele T3, ne motorja.
