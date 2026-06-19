# Tendask — Content rating (IARC) + App content odgovori

> Pripravljeni odgovori za Play Console → App content. Vsi odgovori veljajo za **MVP** (skupnostna
> V2 funkcija ni prisotna, zato »deljenje lokacije med uporabniki« = Ne). Po vsaki spremembi obsega
> ponovno preglej.

---

## 1. Content rating — IARC vprašalnik

**E-poštni naslov** (za IARC potrdilo): `info@tendask.com`

**Kategorija aplikacije:** **Reference, News, or Educational** ni pravi; izberi
**»Utility, Productivity, Communication, or Other«** (Tendask = orodje/produktivnost, ni igra).

Odgovori na vprašanja (vsi **NE**, razen kjer označeno):

| Vprašanje | Odgovor |
|---|---|
| Nasilje (violence) | **No** |
| Strah / grozljivo | **No** |
| Spolnost / golota | **No** |
| Grdo izražanje (profanity) | **No** |
| Nadzorovane snovi (droge, alkohol, tobak) | **No** |
| Igre na srečo (pravi ali simulirani) | **No** |
| Ali aplikacija omogoča **interakcijo/komunikacijo med uporabniki** ali izmenjavo vsebine? | **No** |
| Ali aplikacija **deli uporabnikovo trenutno lokacijo z drugimi uporabniki**? | **No** |
| Ali aplikacija omogoča **nakup digitalnih dobrin**? | **No** |
| Ali vsebuje **oglase**? | **No** |
| Nezakonite/sporne aktivnosti | **No** |

➡️ Pričakovan rezultat: **Everyone / PEGI 3 / USK 0 / ESRB Everyone** (najnižja, splošna ocena).

> Opomba: vreme uporablja lokacijo na napravi, a je **ne deli z drugimi uporabniki** → zato »No« pri
> deljenju lokacije. To je skladno z Data Safety (precise location = shared z **Open-Meteo storitvijo**
> za funkcionalnost, NE med uporabniki).

---

## 2. Target audience & content

| Postavka | Odgovor |
|---|---|
| **Ciljne starostne skupine** | **18 in več** (po želji dodaj 16–17). **NE** izbiraj skupin pod 16. |
| Ali aplikacija **privlači otroke** (»appealing to children«)? | **No** |
| Designed for Families / Teacher Approved | **Ne** (ne prijavljaj) |

> Razlog: politika zasebnosti pravi, da app ni namenjen <16. Brez skupin pod 13 se izogneš strogim
> zahtevam Families Policy.

---

## 3. Ostale App content deklaracije

| Deklaracija | Odgovor |
|---|---|
| **Privacy policy URL** | `https://tendask.com/privacy` |
| **Ads** (oglasi) | **No, my app does not contain ads** |
| **Data safety** | Izpolni po [`../legal/play-data-safety.md`](../legal/play-data-safety.md) |
| **News app** | **No** |
| **COVID-19 contact tracing/status** | **No** |
| **Government app** | **No** |
| **Financial features** | **None** |
| **Data deletion** | Da — v aplikaciji (Nastavitve → izbris računa) + email `info@tendask.com` |

---

## 4. Permissions / posebne dovoljenja (če Play vpraša)

| Dovoljenje | Utemeljitev |
|---|---|
| **Lokacija** (`ACCESS_FINE/COARSE_LOCATION`) | Pridobitev lokalnega vremena za vrt. Koordinate se **ne shranjujejo** (le H3 območje); ni stalne lokacije v ozadju. |
| **Obvestila** (`POST_NOTIFICATIONS`) | Opomniki za načrtovana vrtna opravila. |
| **Točni alarmi** (`SCHEDULE_EXACT_ALARM`) | Časovno natančni opomniki opravil. |
| **Internet / network state** | Sinhronizacija (ob prijavi) in vremenski klic. |

> **App access** (če Play zahteva dostop za pregled): aplikacija deluje **brez prijave** (gostujoči
> način) — recenzentu ni treba poverilnic. Po želji navedi: »Vse funkcije razen sinhronizacije so
> dostopne brez računa (gumb 'Preizkusi brez računa').«
