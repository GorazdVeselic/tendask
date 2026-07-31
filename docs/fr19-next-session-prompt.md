# FR-19 — prompt za naslednjo sejo (živ dokument)

> Ob koncu vsakega koraka sejo zaključi tako, da posodobiš ta dokument na NASLEDNJI korak
> (+ status v `plan-implementacije-fr19-fr20.md`). Uporabnik blok spodaj prilepi v novo sejo.

---

Gradiva FR-19 Lunin koledar po planu `docs/plan-implementacije-fr19-fr20.md` — **korak po koraku,
vsak korak v svoji seji**: en korak = en branch = en commit, vse temno (za flagom), merge v `main`.

**Kaj je narejeno (motor `lib/core/biodynamic/`, vse v main):** T1.1–T1.11 ✅ — **T1 je zaključen.**
Motor: API + časovna osnova (JD/T), λ Sonca in Lune (Meeus 25/47), zodiak (kalibrirane meje + IAU
rezerva), mena (elongacija, osvetljenost, mlaj/ščip z bisekcijo), `dayFor` (element ob začetku dneva
§12.6, bisekcija ure prehoda), deklinacija (`ascending`), neugodni dnevi (vozel [−5 h, +4 h],
perigej ±13 h, mrk |β| < 1,6°; kalibrirano proti tiskanemu Thun 2024). T1.10 fixture: julij+avgust
2026 (62 dni × 2 sistema, vse plasti) v `biodynamic_fixture_test.dart`, sidran na javne sizigije in
mrka 12. 8./28. 8. 2026, zasebno navzkrižno preverjen (sweep 0 neujemanj, vozli 7/7). T1.11
meritev: mreža meseca (84 klicev `dayFor`) ~16 ms → **memoizacija na (mesec, sistem) gre v T3
provider**, motor ostane brez nje. Motor: 121 testov, cel suite 1021, CI zelen.
**⚠️ Časovna cona:** referenčni in fixture testi so CET/CEST — CI korak `Test` ima pripeto
`TZ: Europe/Ljubljana` (`ci.yml`), ne odstranjuj pripetja.

**Naloga TE seje: korak T2.1 — compile-time dark flag** (branch `feat/fr19-t2-1-flag`):

- `kMoonCalendarEnabled = false` v `core/config.dart` (vzorec `kSuppliesEnabled`). To je **edino
  stikalo do T6** — ob T6 ga na vstopnih točkah dopolni `plusProvider` gate, zraven pa pride še
  `kTendaskPlusEnabled` za Tendask+ kartico/zaslon (ime rezervirano v `screen-map.md` §2.1).
- Nič vidnega, nič sheme, nič odvisnosti — samo konstanta po obstoječem vzorcu.

**Pred delom preberi:** plan T2 (`docs/plan-implementacije-fr19-fr20.md`) · obstoječi vzorec
(`core/config.dart`, `kSuppliesEnabled`).

**Pravila:** naredi natanko ta korak in nič več (ne začenjaj T2.2). Pred merge: `flutter analyze`
čist + cel `flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu označi T2.1, posodobi ta
dokument na naslednji korak (T2.2 local_prefs, `feat/fr19-t2-2-prefs`) in predlagaj commit.

**Stanje odločitev:** A1=C ✅ · A3=A ✅ · A4/A5/A6 (barve, ikone, privzeto stikalo) še odprte —
A6 blokira T2.2 (privzeta vrednost `moonCalendarEnabled`), A4 blokira T2.4 (barve elementov);
T2.1 ne blokira nobena.
