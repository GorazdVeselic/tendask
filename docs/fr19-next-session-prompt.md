# FR-19 — prompt za naslednjo sejo (živ dokument)

> Ob koncu vsakega koraka sejo zaključi tako, da posodobiš ta dokument na NASLEDNJI korak
> (+ status v `plan-implementacije-fr19-fr20.md`). Uporabnik blok spodaj prilepi v novo sejo.

---

Gradiva FR-19 Lunin koledar po planu `docs/plan-implementacije-fr19-fr20.md` — **korak po koraku,
vsak korak v svoji seji**: en korak = en branch = en commit, vse temno (za flagom), merge v `main`.

**Naloga TE seje: samo korak T1.5 — zodiak** (branch `feat/fr19-t1-5-zodiac`):

- V `lib/core/biodynamic/` dodaj določitev znamenja/ozvezdja in elementa iz Lunine tropske dolžine:
  **tropski** = `floor(λ/30) mod 12`; **siderični** = 12 kalibriranih pragov (vrednosti = boundaries
  doc §1, epoha 2024.0 + precesija `0.013972°/leto × (leto − 2024)`; Kačenosec zajet v meji Sco→Sgr)
  + **rezervna tabela čistih IAU mej** (izhod v sili). Obe tabeli = konstante v enem filu,
  zamenljivi brez API spremembe. Mapping element→del rastline po spec §14.4 (zaporedje od 0°:
  plod, korenina, cvet, list × 3). V kodi komentar »traditional biodynamic constellation
  boundaries (calibrated)« — **brez imen** (boundaries §3).
- Testi: tropska znamenja proti znanim vrednostim; siderični pragovi (vstop v ozvezdje na meji);
  precesijski popravek za druga leta; element mapping za vseh 12.
- **Brez Riverpoda, brez Clocka, brez I/O** — čista logika; nič v aplikaciji tega še ne kliče.
  Obstoječe (`dayFor` stub, `time_base.dart`, `sun_longitude.dart`, `moon_longitude.dart`) —
  ne spreminjaj.

**Pred delom preberi:** plan T1 (`docs/plan-implementacije-fr19-fr20.md`) · spec §14.4–14.5
(`docs/feature-requests/biodynamic-calendar.md`) · **vrednosti mej §1 + pravni zagovor §3**
(`docs/feature-requests/biodynamic-calendar-boundaries.md`) · obstoječe (`lib/core/biodynamic/`).

**Pravila:** naredi natanko ta korak in nič več (ne začenjaj T1.6). Pred merge: `flutter analyze`
čist + cel `flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu označi T1.5 ✅, posodobi
ta dokument na korak T1.6 (`feat/fr19-t1-6-phase`) in predlagaj commit.

**Stanje odločitev:** A1=C, A3=A ✅ · A4/A5/A6 (barve, ikone, privzeto stikalo) še odprte — blokirajo
šele T3, ne motorja.
