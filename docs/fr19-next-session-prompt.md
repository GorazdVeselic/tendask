# FR-19 — prompt za naslednjo sejo (živ dokument)

> Ob koncu vsakega koraka sejo zaključi tako, da posodobiš ta dokument na NASLEDNJI korak
> (+ status v `plan-implementacije-fr19-fr20.md`). Uporabnik blok spodaj prilepi v novo sejo.

---

Gradiva FR-19 Lunin koledar po planu `docs/plan-implementacije-fr19-fr20.md` — **korak po koraku,
vsak korak v svoji seji**: en korak = en branch = en commit, vse temno (za flagom), merge v `main`.

**Naloga TE seje: samo korak T1.7 — prehod znotraj dneva** (branch `feat/fr19-t1-7-transitions`):

- V `lib/core/biodynamic/` implementiraj `dayFor` (spec §14.7–14.8): element ob **lokalni polnoči
  in koncu dneva**; če se razlikujeta → **bisekcija ure prehoda** na meji; napolni `BiodynamicDay`
  (sign/isConstellation, element, transitionAt?/secondaryElement?, phase, illumFraction; `ascending`
  in `unfavorable` ostaneta null do T1.8/T1.9). Pogodba časa iz T1.1: klicalec poda lokalni
  koledarski dan, meji = lokalna polnoč→polnoč, interno UTC; `transitionAt` = lokalni čas.
- **Testi čez DST prehod** (konec marca / konec oktobra — spec §14.5 opozorilo) in prehod tik čez
  polnoč (»polnočni drobec«, spec §12.6). Dnevna oznaka = element OB ZAČETKU dneva.
- **Brez Riverpoda, brez Clocka, brez I/O** — čista logika; nič v aplikaciji tega še ne kliče.
  Gradniki so vsi na mestu: `time_base.dart`, `sun_longitude.dart`, `moon_longitude.dart`,
  `zodiac.dart`, `moon_phase.dart` — ne spreminjaj jih.
- **JD→lokalni `DateTime` NE piši kot ročno koledarsko inverzijo** (razred hroščev iz najdbe T1.6) —
  uporabi epoch aritmetiko: `DateTime.fromMillisecondsSinceEpoch(((jd − 2440587.5) · 86400000)
  .round(), isUtc: true)` + round-trip test (`DateTime → julianDay → nazaj` = identiteta na ms).
- ⚠️ Past iz T1.6: prototipov IZPIS datuma (JD→datum) je imel 13-dnevni zamik (brez gregorijanske
  korekcije; v NAS arhivu popravljeno, original `…-original.zip`). Port motorja je sweep-verificiran
  Dart ↔ Python za 2024–2027 (max 3·10⁻¹¹°) — astronomije ni treba znova preverjati.

**Pred delom preberi:** plan T1 (`docs/plan-implementacije-fr19-fr20.md`) · spec §14.7–14.8 + §12.6
(`docs/feature-requests/biodynamic-calendar.md`) · obstoječe (`lib/core/biodynamic/`).

**Pravila:** naredi natanko ta korak in nič več (ne začenjaj T1.8). Pred merge: `flutter analyze`
čist + cel `flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu označi T1.7 ✅, posodobi
ta dokument na korak T1.8 (`feat/fr19-t1-8-declination`) in predlagaj commit.

**Stanje odločitev:** A1=C, A3=A ✅ · A4/A5/A6 (barve, ikone, privzeto stikalo) še odprte — blokirajo
šele T3, ne motorja.
