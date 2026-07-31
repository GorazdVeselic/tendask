# FR-19 — prompt za naslednjo sejo (živ dokument)

> Ob koncu vsakega koraka sejo zaključi tako, da posodobiš ta dokument na NASLEDNJI korak
> (+ status v `plan-implementacije-fr19-fr20.md`). Uporabnik blok spodaj prilepi v novo sejo.

---

Gradiva FR-19 Lunin koledar po planu `docs/plan-implementacije-fr19-fr20.md` — **korak po koraku,
vsak korak v svoji seji**: en korak = en branch = en commit, vse temno (za flagom), merge v `main`.

**Kaj je narejeno (motor `lib/core/biodynamic/`, vse v main):** T1.1–T1.9 ✅ — API + časovna osnova
(JD/T), λ Sonca in Lune (Meeus 25/47), zodiak (kalibrirane meje + IAU rezerva), mena (elongacija,
osvetljenost, mlaj/ščip z bisekcijo), T1.7 `dayFor` (element ob začetku dneva §12.6, bisekcija ure
prehoda), T1.8 deklinacija (`ascending`), **T1.9 neugodni dnevi**: `moon_distance.dart` (Meeus 47.A
cos stolpec, vratar 47.a) + vozel/perigej/mrk v `moon_calendar.dart`, **kalibrirano proti tiskanemu
Thun 2024** (jan/feb/dec fotografije, rešene iz transkriptov sej v `tmp/thun_photos/`): vozel
[−5 h, +4 h], perigej ±13 h, mrk = sizigija z |β| < 1,6°; apogej namenoma ni modeliran. Verifikacija
motorja: sweep Dart ↔ Python 2024–2027 = 0 neujemanj; proti tisku MAE 0,26 h, oznake 58/60;
day-level neugodni jan+feb+dec = vseh 14 modelabilnih tiskanih dni (planetarne oznake izven obsega,
spec §4.5). `BiodynamicDay` je s tem poln. Motor: 60 testov, cel suite 957.

**Naloga TE seje: korak T1.10 — referenčni fixture + mikro-meritev** (plan koraka 10+11 skupaj,
branch `feat/fr19-t1-10-fixtures`):

- **Fixture:** lastno izračunani datumi (element + ura prehoda, mena, ascending, unfavorable za
  ~2 meseca), ročno preverjeni ob nastanku, commitani kot testni fixture — naši izračuni, pravno
  čisti. Zasebna navzkrižna preverba proti `tmp/` prototipu (ne gre v repo, gl. P0.1).
- **Mikro-meritev:** `dayFor` za cel mesec (42 celic × 2 sistema) — potrdi < nekaj ms (»optimizacije
  morajo biti merljive«); če ne, memoizacija pride v T3 provider, ne v motor.
- **Brez Riverpoda, brez Clocka, brez I/O** — čista logika; nič v aplikaciji tega še ne kliče.

**Stranska najdba iz T1.9 — RAZREŠENA:** zamenjana člena (0,1,∓2,0) v `moon_longitude.dart`
(podedovano iz prototipa) popravljena po knjigi in re-verificirana proti tiskanemu Thun 2024
(50/50, MAE 0,26 h, 58/60 — nespremenjeno). Python prototip napako še nosi → Dart↔Python sweep za
ta dva člena ni več referenca (opomba v glavi datoteke); merodajna je primerjava s tiskom.

**Pred delom preberi:** plan T1 (`docs/plan-implementacije-fr19-fr20.md`) · obstoječe
(`lib/core/biodynamic/`, `test/core/biodynamic/`).

**Pravila:** naredi natanko ta korak in nič več (ne začenjaj T2). Pred merge: `flutter analyze`
čist + cel `flutter test` zelen. Pred commitom vprašaj. Ob koncu: v planu označi T1.10+11,
posodobi ta dokument na naslednji korak (T2.1 flag, `feat/fr19-t2-1-flag`) in predlagaj commit.

**Stanje odločitev:** A1=C (T1.9 vključen, potrjeno 2026-07-31), A3=A ✅ · A4/A5/A6 (barve, ikone,
privzeto stikalo) še odprte — blokirajo šele T3, ne motorja.
