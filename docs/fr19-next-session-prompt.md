# FR-19 — prompt za naslednjo sejo (živ dokument)

> Ob koncu vsakega koraka sejo zaključi tako, da posodobiš ta dokument na NASLEDNJI korak
> (+ status v `plan-implementacije-fr19-fr20.md`). Uporabnik blok spodaj prilepi v novo sejo.

---

Gradiva FR-19 Lunin koledar po planu `docs/plan-implementacije-fr19-fr20.md` — **korak po koraku,
vsak korak v svoji seji**: en korak = en branch = en commit, vse temno (za flagom), merge v `main`.

**Naloga TE seje: samo korak T1.8 — deklinacija → dvigajoča/spuščajoča** (branch
`feat/fr19-t1-8-declination`):

- V `lib/core/biodynamic/` dodaj Lunino ekliptično širino β (Meeus 47, tabela 47.B — koeficienti iz
  prototipa P0.1, enak vzorec kot `moon_longitude.dart`), nagib ekliptike ε (Meeus 22, nizka
  natančnost zadošča) in pretvorbo (λ, β) → deklinacija δ (`sin δ = sin β cos ε + cos β sin ε sin λ`).
  **Vratar: Meeus primer 47.a za β** (vrednost vzemi iz prototipa/knjige, ne po spominu) — enako kot
  je bil vratar T1.4 za λ. ⚠️ Sweep verifikacija porta pokriva samo λ (Luna/Sonce) — β rabi svojo.
- `ascending` (dvigajoča/spuščajoča, sistem-neodvisno, spec §14.8) izračunaj po **metodi iz
  prototipa** (validirana 96–100 % proti Thun »čas presajanja« jan/feb 2024 — spec §4.5, §12.4);
  preveri v `tmp/`/NAS arhivu, kako prototip določi smer (predznak dδ/dt). Instant vzorčenja
  dokumentiraj v doc komentarju (predlog: začetek lokalnega dneva, skladno z dnevno oznako §12.6 —
  če prototip dela drugače, sledi prototipu).
- Napolni `BiodynamicDay.ascending` v `dayFor`; `unfavorable` ostane null do T1.9. Od obstoječih
  datotek smeš spremeniti samo `moon_calendar.dart`; `time_base.dart`, `sun_longitude.dart`,
  `moon_longitude.dart`, `zodiac.dart`, `moon_phase.dart`, `biodynamic_day.dart` ostanejo.
- **Brez Riverpoda, brez Clocka, brez I/O** — čista logika; nič v aplikaciji tega še ne kliče.
- Testi: vratar 47.a (β) · deklinacija ostaja v fizikalnem pasu (|δ| < ε + 5,15° + margin) ·
  ~27,3-dnevni ciklus (dva zaporedna maksimuma) · znan prehod dvigajoča→spuščajoča (referenco
  izračunaj iz prototipa, ne ugibaj).

**Pred delom preberi:** plan T1 (`docs/plan-implementacije-fr19-fr20.md`) · spec §4.5 + §12.4 +
§14.8 (`docs/feature-requests/biodynamic-calendar.md`) · obstoječe (`lib/core/biodynamic/`,
posebej `moon_calendar.dart` iz T1.7).

**Pravila:** naredi natanko ta korak in nič več (ne začenjaj T1.9). Pred merge: `flutter analyze`
čist + cel `flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu označi T1.8 ✅, posodobi
ta dokument na korak T1.9 (`feat/fr19-t1-9-unfavorable`; upoštevaj varovalko izpusta iz decisions
A1) in predlagaj commit.

**Stanje odločitev:** A1=C, A3=A ✅ · A4/A5/A6 (barve, ikone, privzeto stikalo) še odprte — blokirajo
šele T3, ne motorja.
