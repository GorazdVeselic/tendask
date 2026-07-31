# FR-19 — prompt za naslednjo sejo (živ dokument)

> Ob koncu vsakega koraka sejo zaključi tako, da posodobiš ta dokument na NASLEDNJI korak
> (+ status v `plan-implementacije-fr19-fr20.md`). Uporabnik blok spodaj prilepi v novo sejo.

---

Gradiva FR-19 Lunin koledar po planu `docs/plan-implementacije-fr19-fr20.md` — **korak po koraku,
vsak korak v svoji seji**: en korak = en branch = en commit, vse temno (za flagom), merge v `main`.

**Kaj je narejeno (motor `lib/core/biodynamic/`, vse v main):** T1.1–T1.8 ✅ — API + časovna osnova
(JD/T), λ Sonca in Lune (Meeus 25/47), zodiak (kalibrirane meje + IAU rezerva), mena (elongacija,
osvetljenost, mlaj/ščip z bisekcijo), **T1.7** `dayFor` (element ob začetku dneva §12.6, bisekcija
ure prehoda, JD→DateTime epoch aritmetika, mena na sredini dneva) in **T1.8** deklinacija (β Meeus
47.B, ε, δ; `ascending` = δ(konec) ≥ δ(začetek) — prototipova metoda). **Verifikacija (2026-07-31):**
Dart ↔ Python sweep 2024–2027 vseh plasti = 0 neujemanj; Dart **direktno proti tiskanemu Thun 2024**
(50 fotografiranih vstopov): MAE 0,26 h, oznake 58/60 — oba zgrešena = polnočni drobec §12.6;
presajanje jan/feb = 30/31, 29/29. Skripte: `tmp/engine_dump.dart`, `tmp/engine_check.py`,
`tmp/thun_vs_dart.py`. V `BiodynamicDay` je nezapolnjen samo še `unfavorable`.

**Naloga TE seje: samo korak T1.9 — neugodni dnevi** (branch `feat/fr19-t1-9-unfavorable`):

- **NAJPREJ varovalka iz decisions A1:** to je zadnji vsebinski korak motorja z izrecno možnostjo
  zavestnega izpusta — **vprašaj lastnika**, ali T1.9 gre v v1 ali se izpusti (potem preskoči na
  T1.10 fixtures). Plan ga označuje kot **največji dodatni izračun v celem tasku**.
- Če DA: neugodno = bližina **vozlov** (prehod Lune skozi ekliptiko — β skozi 0, že izračunljivo iz
  `moon_latitude.dart` z bisekcijo kot pri menah), **perigej** (minimum razdalje — ⚠️ razdaljni
  členi Meeus 47.A (cos stolpec) ŠE NISO portirani; nov file po vzorcu `moon_longitude.dart`,
  koeficienti iz prototipa/knjige, vratar 47.a za razdaljo; ob tretjem uporabniku srednjih
  elementov razmisli o ekstrakciji skupnega helperja — review opažanje T1.8) in **mrki** (sizigija
  blizu vozla). Napolni `BiodynamicDay.unfavorable` v `dayFor`.
- ⚠️ **Za ta sloj NI validiranega prototipa** (prototip pokriva λ, β, mene) — pragove (koliko ur
  okoli vozla/perigeja je »neugodno«) in referenco za validacijo (npr. fotografije tiskanega Thun
  2024 s temi oznakami, NAS) **določi z lastnikom, ne ugibaj**.
- Od obstoječih datotek smeš spremeniti samo `moon_calendar.dart`; `time_base.dart`,
  `sun_longitude.dart`, `moon_longitude.dart`, `moon_latitude.dart`, `declination.dart`,
  `zodiac.dart`, `moon_phase.dart`, `biodynamic_day.dart` ostanejo (`unfavorable` polje že
  obstaja).
- **Brez Riverpoda, brez Clocka, brez I/O** — čista logika; nič v aplikaciji tega še ne kliče.

**Pred delom preberi:** plan T1 + decisions A1 (`docs/plan-implementacije-fr19-fr20.md`) · spec
§4.5 (`docs/feature-requests/biodynamic-calendar.md`) · obstoječe (`lib/core/biodynamic/`).

**Pravila:** naredi natanko ta korak in nič več (ne začenjaj T1.10). Pred merge: `flutter analyze`
čist + cel `flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu označi T1.9 (✅ ali
zavestni izpust), posodobi ta dokument na korak T1.10 (`feat/fr19-t1-10-fixtures`, koraka 10+11
skupaj) in predlagaj commit.

**Stanje odločitev:** A1=C, A3=A ✅ · A4/A5/A6 (barve, ikone, privzeto stikalo) še odprte — blokirajo
šele T3, ne motorja.
