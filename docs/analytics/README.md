# Analitika produkcije — od kod so uporabniki in kdo vnese lokacijo

Orodja živijo v [`tool/analytics/`](../../tool/analytics), rezultati tukaj:
`snapshots/<datum>.json` (surovi agregati) in `maps/<datum>.html` (zemljevid + graf).
Vse poizvedbe so **read-only agregati** — nobena vrstica posameznega uporabnika se ne prebere
in ne zapiše. Prim. [`feature-requests/analytics.md`](../feature-requests/analytics.md) za širši načrt.

## Zagon

Potrebuješ `.env` v korenu repa (geslo poolerja; gitignoran) in Python pakete `psycopg`, `h3`.

```bash
# 1) posnetek stanja na današnji dan
python tool/analytics/snapshot.py --label "vc17: FR-22 + FR-24"

# 2) zemljevid + graf iz zadnjega posnetka
python tool/analytics/render_map.py --release 2026-07-30 --release-label "vc17 · lokacija v onboardingu"

# 3) poročilo za datum: koliko uporabnikov skupaj + razdelitev po regijah
python tool/analytics/report.py                      # zadnji posnetek, primerjan s prejšnjim
python tool/analytics/report.py --snapshot 2026-08-02 --vs 2026-07-25
python tool/analytics/report.py --md                 # markdown tabela za v ta dokument

# 4) vnos lokacije skozi čas (kohorte ob registraciji)
python tool/analytics/adoption.py --release 2026-07-30
```

`snapshot.py --date YYYY-MM-DD` prepiše ime datoteke (npr. ob ponovnem zajemu za nazaj ni mogoč —
posnetek je vedno stanje *zdaj*). `render_map.py --snapshot YYYY-MM-DD` izriše starejši posnetek.

## Kaj posnetek vsebuje

| Polje | Pomen |
|---|---|
| `total`, `with_cell` | profilov skupaj / z nastavljeno lokacijo vrta |
| `regions` | razdelitev uporabnikov po statističnih regijah tistega dne (n + delež) |
| `points` | središča **H3 r5** celic (~8,5 km rob) + število uporabnikov v celici |
| `daily_new` | novi profili po dnevih (`server_inserted_at`) + koliko jih ima lokacijo |
| `daily_touched` | profili, pisani tisti dan (`updated_at`) — groba mera aktivnosti |

Zemljevid vsako celico dekodira v središče in jo vstavi v statistično regijo (Eurostat GISCO
NUTS-3 2021, `tool/analytics/assets/si_nuts3.geojson`). Središče v morju ali čez mejo gre v
najbližjo regijo in je na strani označeno kot približek.

## Kaj je merljivo in kaj ni

- **Baza nima časovnega žiga, kdaj je bila lokacija vnesena.** `profile` ima `created_at`,
  `updated_at`, `server_inserted_at` — noben od njih ne pove, kdaj je bil `h3_r5` nastavljen.
  Zato obstajata samo dve pošteni branji:
  1. **Kohorte ob registraciji** (`server_inserted_at`) — od profilov, ki so nastali v nekem
     obdobju, koliko jih ima danes lokacijo. Za spremembe onboardinga je to čisto: kohorta je
     videla eno samo različico.
  2. **Razlika med posnetkoma** — če `with_cell` zraste bolj, kot je novih registracij z lokacijo,
     so lokacijo dodali **obstoječi** uporabniki. To je edini način, da izmeriš učinek povabila na
     Domov (FR-22) — in deluje šele, ko obstajata **dva** posnetka. Zato: posnemi redno.
     `report.py` to razliko izpiše ločeno (»od tega obstoječi uporabniki«), prav tako premik
     po posameznih regijah.
- **Za nazaj se ne da.** Posnetek je stanje ob zajemu; brez posnetka tistega dne razdelitve po
  regijah za pretekli datum ni mogoče rekonstruirati. Kar imamo za nazaj, so samo registracije
  po dnevih. Kadenca posnetkov je torej edina zgodovina, ki jo bomo imeli — smiselno je vsaj ob
  vsaki izdaji in enkrat mesečno.
- **Baza ne ve, katero različico aplikacije ima uporabnik.** Ni tabele naprav in ni polja z
  `versionCode`. Kohorto lahko vežeš samo na *datum*, in datum objave na Play je zunanje dejstvo
  (Play Console), ne podatek iz baze. Zamik med objavo in dejansko posodobitvijo naprav pomeni,
  da so dnevi tik po izdaji mešanica starih in novih namestitev.
- **`created_at` piše naprava** (lahko ima zamaknjeno uro), `server_inserted_at` piše strežnik.
  Za kohorte uporabljaj `server_inserted_at` — tako delajo skripte tukaj.
- **Vzorec je majhen.** Pri stotinah profilov je razlika nekaj odstotnih točk lahko pet ljudi.
  `adoption.py` sam opozori, ko je kohorta po izdaji manjša od 30.

## Zasebnost

- Shranjujemo in objavljamo **samo celice, nikoli koordinate** — teh v bazi sploh ni (H3 se
  izračuna na napravi, `CLAUDE.md` § Zasebnost).
- r5 (~250 km²) je namerno grob; r7 bi bil pri tako majhni bazi uporabnikov na ravni ulice.
- V posnetku so števci na celico, ne uporabniki. Za karkoli javnega velja k-anonimnost
  (≥ 5 uporabnikov na celico) iz `feature-requests/analytics.md` — posnetki tukaj so interni.

## Ugotovitve doslej

### 2. avgust 2026 (`snapshots/2026-08-02.json`)

108 uporabnikov, 52 z lokacijo (48,1 %), 30 ločenih celic. Prvi posnetek — primerjave še ni.

| Regija | Uporabnikov | Delež |
|---|---|---|
| Podravska | 16 | 30,8 % |
| Osrednjeslovenska | 7 | 13,5 % |
| Savinjska | 7 | 13,5 % |
| Gorenjska | 6 | 11,5 % |
| Pomurska | 4 | 7,7 % |
| Obalno-kraška | 3 | 5,8 % |
| Posavska | 3 | 5,8 % |
| Goriška | 2 | 3,8 % |
| Jugovzhodna Slovenija | 2 | 3,8 % |
| Koroška | 2 | 3,8 % |
| Primorsko-notranjska | 0 | — |
| Zasavska | 0 | — |

Delež je med 52 profili z znano celico. Tri celice imajo središče v morju ali čez mejo in so
pripisane najbližji regiji.

Vnos lokacije po tedenskih kohortah registracije:

| Teden registracije | Novih | Z lokacijo | Delež |
|---|---|---|---|
| 14. 6. | 4 | 4 | 100 % |
| 21. 6. | 16 | 15 | 94 % |
| 28. 6. | 5 | 3 | 60 % |
| 19. 7. | 52 | 15 | 29 % |
| 26. 7. | 31 | 15 | 48 % |

Junijske kohorte so zaprti test (znanci, vodeni skozi namestitev), julijske javna objava —
razlika med 94 % in 29 % je razlika med tema dvema populacijama, ne posledica kode.

Za vc17 (FR-22 + FR-24, bump 30. 7.): kohorta pred 30. 7. ima 46,5 % (47/101), kohorta od
30. 7. naprej 71,4 % (5/7). **n = 7 — to je indic, ne rezultat.** Novi profili po dnevih: 30. 7.
1 od 3, 31. 7. nobenega novega, 1. 8. 4 od 4. Za trden odgovor je potreben nov posnetek čez nekaj
tednov in primerjava razlik.
