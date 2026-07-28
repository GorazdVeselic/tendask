# Geografska analitika — od H3 celic do zemljevida

> **Status:** delujoč recept · prvič izveden 2026-07-28
> **Orodje:** `tool/geo_user_map.py` + `tool/geo_user_map.tpl.html`
> **Izhod:** `tmp/geo/map_data.json` + `tmp/geo/map.html` (samostojen, brez omrežja)

Kako iz `profile.h3_r7/r6/r5` dobiva sliko, od kod so uporabniki, ne da bi kadar koli
imela njihove koordinate. Ta dokument je **kako**; interpretacija konkretne izvedbe je v
izhodu orodja.

```bash
pip install h3 psycopg          # razvojni orodji, NE aplikacijski dependency
python tool/geo_user_map.py
```

---

## 1. Zakaj to sploh gre

H3 indeks ni šifra — je deterministična koda celice. `h3.cell_to_latlng(cell)` vrne
**središče celice**, ne uporabnikove lokacije. Pri r5 je celica ~250 km² (rob ~8,5 km),
kar je dovolj za regijo in premalo za karkoli osebnega. To je natanko razlog, da je v
`profile` shranjen H3 in ne lat/lng: agregat ostane možen, sledenje pa ne.

**Zato vedno delaj na r5.** r7 (~5 km², rob ~1,2 km) je pri nekaj deset uporabnikih
praktično naslov — tudi za interno rabo ni razloga zanj.

## 2. Koraki

| # | Korak | Kje v kodi |
|---|---|---|
| 1 | **Preštej po celici** na PROD: `select h3_r5, count(*) … group by 1`. Nikoli vrstic po uporabniku. | `load_counts()` |
| 2 | **Dekodiraj** vsako celico v središče. | `h3.cell_to_latlng` |
| 3 | **Uvrsti točko v regijo** (ray casting, luknje upoštevane). | `in_polygon()` |
| 4 | **Zgreške pripni najbližji regiji** — glej §3. | `km_to_ring()` |
| 5 | **Projiciraj + poenostavi** (Douglas-Peucker) v SVG poti. | `make_projection()`, `simplify()` |
| 6 | **Vstavi podatke + pisavo v predlogo** → en samostojen HTML. | `render()` |

**Meje:** Eurostat GISCO, `NUTS_RG_01M_2021_4326_LEVL_3`. NUTS-3 za Slovenijo **so**
statistične regije — ni ročnega mapiranja občin, ni ugibanja. Celoten evropski file je
~28 MB, zato orodje enkrat prenese, filtrira `CNTR_CODE='SI'` in cacheira (~170 KB).

> **Slepa ulica, da je ne ponoviva:** geoBoundaries ADM1 za Slovenijo vrne **kohezijski
> regiji (2)**, ne statističnih, ADM2 pa 212 občin z okvarjenimi šumniki. Občine bi
> zahtevale ročno mapiranje 212 → 12. NUTS-3 to reši v enem koraku.

## 3. Dve pasti, ki sva ju že stopila

**Središče celice ni nujno v državi.** Dve obalni celici imata središče v morju oz. tik
čez mejo. Če jih spustiš, izgubiš uporabnike; če jih tiho pripneš, lažeš. Orodje jih
pripne **najbližji regiji** in to označi (`approx_km`) ter izpiše. Pri 0 km je pripis
varen — pri zamejskem uporabniku bi isto pravilo napačno pripisalo Sloveniji, zato mora
biti opomba vidna v prikazu.

**Razvrščanje »po najbližjem mestu« je približek, ki se moti.** Prvi poskus je celice
pripisal najbližjemu mestu iz ročnega seznama — hitro, a napačno ob mejah regij.
Point-in-polygon nad uradnimi mejami je enako poceni in ne ugiba.

**`const top` v brskalniku vrže SyntaxError** (`window.top` je že zaseden) in stran
ostane prazna, brez vidnega znaka. Zato: po vsaki spremembi predloge **poglej render**,
ne le kodo:

```bash
CH="/c/Program Files/Google/Chrome/Application/chrome.exe"
"$CH" --headless=new --disable-gpu --enable-logging=stderr --v=0 \
      --dump-dom "file:///C:/.../tmp/geo/map.html" 2>&1 >/dev/null | grep -i CONSOLE
"$CH" --headless=new --disable-gpu --hide-scrollbars --window-size=1180,1150 \
      --screenshot=tmp/geo/shot.png "file:///C:/.../tmp/geo/map.html"
```

## 4. Prikaz

- **Choropleth = sekvenčna lestvica ene barve** (brand zelena, `--s1…--s5`), razredi
  fiksni: 1 · 2 · 3–5 · 6–9 · 10+. Nič uporabnikov = nevtralna siva, ne najsvetlejša
  zelena — odsotnost ni majhna vrednost.
- **Pike (medena) so dejanske celice**, velikost = število. Brez njih choropleth laže o
  enakomernosti: Podravska je ena debela pika pri Mariboru, ne polna regija.
- **Barva besedila oznak se računa iz svetlosti polnila**, ne iz teme — ista oznaka sedi
  na temno zeleni v svetlem načinu in na svetlo zeleni v temnem.
- Pisava (Plus Jakarta Sans) je vgrajena kot data URI: stran dela brez omrežja, enako
  pravilo kot v aplikaciji.

## 5. Preden gre to na spletno stran (`../tendask_web`)

Trenutni izhod je **interni**. Za javno objavo velja troje, brez izjem:

1. **k-anonimnost: ne objavi enote z n < 5.** Manjše združi v »drugo«. Celica z enim
   uporabnikom v redko poseljeni regiji je identificirajoča, tudi če je celica velika.
2. **Nobenih pik r5 v javni različici** — samo agregat po regiji/državi. Pike so
   diagnostika za naju.
3. **Podatek je posnetek ob build-u, nikoli živa poizvedba iz brskalnika.** Statična
   stran nima in ne sme imeti dostopa do PROD; RLS tako ali tako ne dovoli branja tujih
   profilov. Pot: `geo_user_map.py` → ročno pregledan JSON → commit v `tendask_web`.

Ob objavi se splača povedati tudi *koliko* profilov lokacije nima — številka brez tega
konteksta izpade natančnejša, kot je.

## 6. Ko zraste čez Slovenijo

Recept drži do ene države. Kaj se spremeni, po vrsti verjetnosti:

| Kaj | Slovenija (zdaj) | Evropa | Svet |
|---|---|---|---|
| **Meje** | NUTS-3 (12) | NUTS-0/1 ali Natural Earth admin-0 | Natural Earth admin-0 110m (~250 KB) |
| **Uvrstitev** | point-in-polygon čez 12 | bbox predfilter + PiP | isto; brez predfiltra je O(celice × države) |
| **Projekcija** | equirect s cos(lat) | **equal-area** (EPSG:3035) | Robinson / Natural Earth II |
| **Zrnatost** | pike r5 | pike r5 postanejo šum | **H3 hex-bin** (`cell_to_parent(r3/r4)`) |
| **Lestvica** | fiksni razredi | fiksni razredi | kvantili ali log |

Trije poudarki:

- **Projekcija ni kozmetika.** Equirectangular čez Evropo napihne Skandinavijo; pri
  choroplethu ploščina *je* del sporočila, zato equal-area. Obe alternativi sta ~15
  vrstic matematike — nova knjižnica ni potrebna.
- **Hex-bin je naravna pot, ne rezervna.** Podatek *je* H3; pri svetovnem merilu je
  agregacija na r3/r4 in risanje šesterokotnikov (`h3.cell_to_boundary`) bolj pošteno od
  choropletha po državah, ki 300 uporabnikov v Berlinu razmaže čez vso Nemčijo.
- **Preklop naj bo podatkovni, ne ročni.** Ko delež uporabnikov izven SLO preseže prag
  (predlog: 15 %), zemljevid ni več slovenski. Do takrat ne gradiva svetovnega — YAGNI.

## 7. Kaj je še odprto

- **43 od 79 profilov nima celice** (stanje 2026-07-28). Dokler ne veva, ali so to
  uporabniki, ki so obstali pred onboardingom, je vsak odstotek na zemljevidu pogojen.
- Ali sploh hočeva to javno? »Kje so naši uporabniki« je lep signal skupnosti in hkrati
  podatek o uporabnikih — odločitev pred implementacijo v `tendask_web`, ne med njo.
