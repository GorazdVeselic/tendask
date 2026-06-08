# Skupnostna agregacija opravil — statistični in podatkovni model (V2)

> **Status:** ŽIV DOKUMENT · pred-implementacijska faza · **odprta vprašanja razrešena 2026-06-08**
> **Zadnja sprememba:** 2026-06-08
> **Povezano:** `koncept.md` §8 (V2 vizija — povzetek), §7.14 (podatkovni model), §7.7 (lokacija/H3),
> `tech-stack.md` §5 (H3 na napravi) · `pametni-motor.md` (vir C = skupnost; frost-anchor).
> **Namen te datoteke:** natančno opredeliti, **kateri podatki** so potrebni in **kako točno**
> se agregirajo in prikazujejo skupnostni signali ("kaj počnejo drugi vrtnarji v okolici"),
> tako da **ne delamo statistično napačnih interpretacij**. Vir resnice za kasnejšo
> implementacijo; sheme/imena v angleščini, razlaga v slovenščini.

---

## 0. Bistvo (TL;DR)

1. Agregiramo **različne uporabnike (`COUNT(DISTINCT user_id)`), nikoli opravil**.
2. **Tri vprašanja → tri metrike:** *"kaj se dogaja zdaj"* (feed, drseče 7-dnevno okno),
   *"kdaj se to običajno dela / kje sem"* (časovni percentil iz preteklih celih sezon),
   *"kako pogosto"* (frekvenca — mediana + IQR med izvajalci).
3. Percentila **nikoli** ne računamo iz delnega tekočega tedna/sezone (cenzura) — krivuljo gradimo
   iz **dokončanih preteklih sezon**, tekoče leto je le marker.
4. Dva praga: `K_privacy=5` (zasebnostni minimum za prikaz) in `K_reliab=30` (minimum za prikaz
   **številke** v %; pod njim opisni pas). Oba server-nastavljiva.
5. Prikaz vedno iz **enega samega nivoja** (fina celica → grobejša → klimatski koš → globalno);
   nivojev nikoli ne mešamo, obseg vedno pošteno označimo.

---

## 0.1 Potrjene odločitve (2026-06-08)

| # | Vprašanje | Odločitev |
|---|---|---|
| 1 | Vedro dogodka | **Posnetek** `task.agg_context` (jsonb) ob `done` + cron `COALESCE(posnetek, join na profil)` |
| 2 | Pragova prikaza | `K_privacy=5`, `K_reliab=30` (oba server-nastavljiva); dvonivojski prikaz, % zaokrožen na 10, `n` viden |
| 3 | Vir klime | Open-Meteo normals (klic ob lokaciji); bogato-omejen **owner-only** `profile.climate_profile` jsonb; **javni** `climate_bucket` ostane grob |
| 4 | Sezonsko sidro | **Koledarsko leto (severna polobla)**; sezona = **izpeljava** iz absolutnih datumov (brez zapečenja → nadgradnja brez migracije) |
| 5 | Datum za binning | **`profile.timezone` (IANA)** → uvrsti v uporabnikov **lokalni dan**; tedenska granulacija |
| 6 | RLS gate `activity_season` | Denormaliziran **gate-stolpec** (`publishable`), ki ga piše cron |
| 7 | Frekvenčna metrika | **V2** (tri metrike skupaj) |
| 8 | Zrelost `X/N/M` | Konservativni server-nastavljivi privzetki (X=14 dni, N=10 opravil, M=5 dni); kalibriraj po podatkih |

### 0.2 Naknadne uskladitve iz wireframe verifikacije (2026-06-08)
Preverba `wireframes/community-concepts_v1.html` je razkrila tri vrzeli; zapolnjene additivno:
- **`bucket_population`** (§5.5) — štetje vrtnarjev v vedru za »~40 v okolici« + cold-start (pod
  `K_privacy` kaži »še premalo«, ne točne številke).
- **`activity_frequency.hist`** (§5.3) — shranjena porazdelitev za stolpčni prikaz (konsistenten s
  časovnim percentilom), ne le kvartili.
- **Obvestila/odstotki čez kratko okno** (§7.8) — ubeseditev iz CDF; neobvezna »participacija 7 dni«;
  feed ostane kvalitativen.

---

## 1. Namen, obseg, načela

**Cilj.** Uporabniku anonimno pokazati, kaj v njegovi okolici/klimi počnejo drugi vrtnarji, in
"kje je glede na množico" — **opisno, ne predpisno**. Ni agronomski nasvet; je dejstvo o ravnanju
skupnosti.

**Obseg.** V2, oblačno (Supabase Postgres). Bere **samo registrirane** uporabnike (gostje se ne
sinhronizirajo). Brez signala aplikacija skupnostnih pogledov ne kaže (graceful: zadnji posnetek
ali prazno).

**Načela (poleg globalnih iz CLAUDE.md):**
- **Resnicoljubnost pred bogatostjo** — raje "premalo podatkov" kot lažna natančnost.
- **Zasebnost po zasnovi** — koordinate ne zapustijo naprave; navzven nikoli pod res-7; vse
  k-anonimno; `is_custom` izključen; **javni agregat hrani le grob `climate_bucket`, ne `climate_profile`.**
- **Opisno, ne predpisno** — "X % je naredilo …", nikoli "ti naredi …".
- **Reprezentativnost priznana** — vzorec = *Tendask uporabniki, ki beležijo*; besedilo vedno
  "med vrtnarji na Tendask v tvoji okolici".

---

## 2. Tri vprašanja → tri metrike

| | **Feed** | **Časovni percentil** | **Frekvenca** |
|---|---|---|---|
| Vprašanje | Kaj se dogaja zdaj? | Kdaj se običajno dela? Sem zgodnji/pozni? | Kako pogosto? |
| Okno | drsečih zadnjih 7 dni | teden-v-letu, iz preteklih celih sezon | aktivna sezona |
| Dogodek | katerakoli izvedba v oknu | **prva** izvedba v sezoni / uporabnika | vse izvedbe / uporabnika |
| Metrika | `distinct_users` v oknu | CDF prvih izvedb | mediana + IQR izvedb na uporabnika |
| Rabi zgodovino? | NE | DA (≥1 cela sezona; leto 1 = poseben način §7.6) | DA (sezona) |
| Tipičen primer | "ta teden sadijo paradižnik" | "kdaj prvič pognojiti trato" | "kosijo ~2–4× mesečno" |

Metrik **nikoli ne mešamo** in jih v UI vizualno ločimo.

---

## 3. Natančne definicije

- **Izvedba (completion event):** vrstica `task` s `status='done'`, `deleted=false`, upravičenega
  uporabnika (§4.5). Ima: `user_id`, `task_type_id`, neobvezno kanonično rastlino `plant_id`
  (prek `task_subject → user_plant`, **le če `is_custom=false`**), in **lokalni dan izvedbe** (§ čas).
- **Sezona:** **koledarsko leto** (1. jan–31. dec), severna polobla (odločitev 4). Izračunana iz
  absolutnih datumov ob agregaciji, **ne shranjena**. *Omejitvi:* zimska čez-letna opravila in
  južna polobla (past §8.7), rešljivi kasneje brez migracije.
- **Prva izvedba v sezoni:** za `(u, T, neobvezno P, s)` = najzgodnejši lokalni dan izvedbe `T` v
  sezoni `s`. Vsak `(u, T, s)` prispeva **natanko en** dogodek → kumulativa seštevljiva (§5.4).
- **`distinct_users`:** `COUNT(DISTINCT user_id)`. **Ni seštevljiv** čez podobdobja (past §8.3).
- **Vedra:** štiri vzporedne pripadnosti dogodka — `h3_r7`, `h3_r6`, `h3_r5` in `climate_bucket`.
  Vir = `task.agg_context` posnetek, sicer `COALESCE` na profil (odločitev 1).
- **Nivo prikaza:** `{7, 6, 5, climate, global}`, od najbolj lokalnega/specifičnega k splošnemu.
  Prikaz uporabi **en sam** nivo (§7.4).
- **Drseče 7-dnevno okno:** `[danes − 7 dni, včeraj]` (vključi *včeraj*, ne *danes*).
- **ISO teden (`iso_week`):** binning enota za krivuljo (absorbira TZ + dnevni šum).

**Čas (odločitev 5):** shramba je UTC. Vsak dogodek uvrstimo v **uporabnikov lokalni dan** prek
`profile.timezone` (IANA). Tedenska granulacija pokrije ostanek; za relativni percentil je
morebiten enakomeren zamik tako ali tako nevtralen (past §8.6).

---

## 4. Podatki, ki jih potrebujemo

### 4.1 Javni klimatski koš — `profile.climate_bucket` (NOVO)
Grob koš **višinski pas × temperaturni pas**, izpeljan iz `climate_profile` (§4.6). String tipa
`e1_t3`. **To je edini klimatski podatek, ki gre v javni agregat.** Nullable, sinhroniziran.

### 4.2 Posnetek vedra na dogodku — `task.agg_context` (NOVO) — odločitev 1
Ob `done` zamrznemo v jsonb: `{h3_r7, h3_r6, h3_r5, climate_bucket}`. Cron bere
`COALESCE(task.agg_context, join na trenutni profil)` → pravilna čas-dogodka semantika, graciozen
fallback za stara/ne-posneta opravila. Selitev vrta ne preseli pretekle zgodovine. Isti vzorec kot
vremenski posnetek; r7+ celice + grob koš so neidentificirajoči.

### 4.3 Sezonskost opravila — `task_type.seasonal` (NOVO v katalogu)
Bool (default `true`). Časovni percentil le za **sezonska** opravila; za nesezonska prikažemo feed
+ frekvenco (§7.5).

### 4.4 Časovni pas — `profile.timezone` (NOVO) — odločitev 5
IANA string. Strežniško potreben za binning po lokalnem dnevu **in** za pametni motor (dnevni cron
ob 6:00 po lokalnem času) — torej ni špekulativno polje. Nastavi se na napravi ob lokaciji.

### 4.5 Upravičeni uporabniki — pogled `eligible_user` (izpeljano) — odločitev 8
Šteje le uporabnik z: `starost računa ≥ X dni` **IN** `skupno done-opravil ≥ N` **IN** `aktivnost
čez ≥ M različnih dni`. Privzetki **X=14, N=10, M=5**, server-nastavljivi; kalibriraj po podatkih.

### 4.6 Bogat klimatski profil — `profile.climate_profile` (NOVO, owner-only jsonb) — odločitev 3
Zajet ob nastavitvi lokacije z Open-Meteo normals klicem (poleg geokodiranja), graciozen offline
fallback (višinski pas takoj, ostalo dopolni ob povezavi). **Owner-only** (RLS `user_id=auth.uid()`),
**nikoli v javni agregat** → natančnejši podatki tu ne pomenijo javnega razkritja. Predlagan nabor:
- `elevation_m`
- `temp_monthly_normals[12]` (→ letno povprečje, GDD, zaznava sezone)
- `frost_last_spring`, `frost_first_autumn` (**frost-anchor za pametni motor**)
- `growing_season_days` ali `gdd_base5`
- `precip_annual_mm` (po želji), `koppen` (po želji)
- `captured_at`, `source` (za kasnejši re-fetch — normali so re-fetchabilni)

Iz tega **izpeljemo** grob javni `climate_bucket` (§4.1). Točen kazalnik + meje pasov + ali frost
računamo iz dnevnega arhiva → določimo ob implementaciji (in pretehtamo morebitno odvečnost višine,
ko temp. pas že vsebuje učinek višine).

### 4.7 Že obstoječe (brez sprememb)
`task` (status/date/deleted), `task_subject → user_plant (is_custom, plant_id)`,
`profile.h3_r7/r6/r5`. Vse že sync v oblak za registrirane.

---

## 5. Agregacijski cevovod (cron, Postgres)

`pg_cron` nočno, **inkrementalno** in **idempotentno** (preračun okna → upsert/replace). Štirje
produkti: `eligible_user` + tri agregatne tabele.

### 5.1 `eligible_user` (pogled ali nočna materializacija)
Set `user_id`, ki ustrezajo §4.5. Vse spodnje berejo **samo** te.

### 5.2 `activity_recent` — feed (drseče okno)
Za vsak nivo, vedro, `task_type_id`, (neobvezno) `plant_id`:
`distinct_users_7d = COUNT(DISTINCT user_id)` med upravičenimi z ≥1 izvedbo `T` v zadnjih 7 dneh.

> **POZOR (past §8.3):** `COUNT(DISTINCT)` **direktno nad surovim 7-dnevnim oknom**, NE vsota
> dnevnih distinct-števcev.

```
activity_recent(
  resolution text, bucket_key text, task_type_id text, plant_id text NULL,
  distinct_users_7d int, refreshed_at timestamptz
)
```
RLS: `using (distinct_users_7d >= K_privacy)`.

### 5.3 `activity_frequency` — frekvenca (odločitev 7)
Za vsak nivo, vedro, `task_type_id`, (neobvezno) `plant_id`, sezono `season_year`: med
**izvajalci** (uporabniki z ≥1 izvedbo `T` v sezoni), porazdelitev **števila izvedb na uporabnika**
v aktivni sezoni. Cron shrani **le povzetek** (mediana + kvartila + `n`), **brez `user_id`**.

> **POZOR (past §8.14):** uporabljaj **mediano + IQR, NE povprečja** (porazdelitev je desno-nagnjena
> zaradi power-uporabnikov). Štej **le med izvajalci** in **le v aktivni sezoni** (ničle izven
> sezone bi razvodenele). Normalizacija (na mesec aktivne sezone) je implementacijski detajl.

```
activity_frequency(
  resolution text, bucket_key text, task_type_id text, plant_id text NULL,
  season_year int, n_users int,
  per_user_p25 real, per_user_p50 real, per_user_p75 real, unit text,  -- npr. 'per_month'; kvartili za naslov "2–4×"
  hist jsonb  -- porazdelitev za prikaz: št. uporabnikov po pasovih, npr. {"1":4,"2":9,"3":12,"4":7,"5+":3}
)
```
RLS: `using (n_users >= K_privacy)`. `hist` omogoča stolpčni prikaz porazdelitve (vizualno konsistenten s
časovnim percentilom) — pasovi so dovolj grobi (k-anonimnost ohranjena prek `n_users` gate-a).

### 5.4 `activity_season` — časovni percentil (porazdelitev prvih izvedb)
Za vsak nivo, vedro, `task_type_id`, (neobvezno) `plant_id`, **leto** `year`, **ISO teden** `w`:
`first_user_count = #{upravičeni u : u-jeva PRVA izvedba T v sezoni year pade v teden w}`.

Lastnosti (zakaj pravilno in poceni):
- Vsak `(u, T, year)` prispeva v **natanko en** teden → tedenski števci **disjunktni po uporabnikih**
  znotraj leta.
- `season_total(year) = Σ_w first_user_count` = št. uporabnikov, ki so `T` v `year` opravili ≥1× →
  **seštevljivo, brez dvojnega štetja** (rešitev ne-additivnosti `DISTINCT` za ta primer).
- `cumulative(≤w) = Σ_{w'≤w} first_user_count`.

```
activity_season(
  resolution text, bucket_key text, task_type_id text, plant_id text NULL,
  year int, iso_week int,           -- 1..53
  first_user_count int,
  publishable bool,                 -- gate (odločitev 6): cron postavi true, ko pooled total ≥ K_privacy
  PRIMARY KEY (resolution, bucket_key, task_type_id, plant_id, year, iso_week)
)
```
RLS (odločitev 6): gate na **skupnem naboru**, ne tedenski celici (tedenski bar 1–2 osebi je OK,
anonimnostni set je cela sezona). Cron izračuna `pooled_total = Σ` čez uporabljena pretekla leta in
postavi **`publishable`** na vse vrstice vedra+tipa; RLS `using (publishable)`.

### 5.5 `bucket_population` — koliko vrtnarjev je v vedru (vrzel iz wireframe verifikacije)
Za prikaz »~40 vrtnarjev v tvoji okolici« in cold-start gating (»še premalo«) rabimo **populacijo
vedra** — različne upravičene uporabnike *ne glede na opravilo* (tri agregatne tabele so per-`task_type`).
```
bucket_population(resolution text, bucket_key text, distinct_users int, refreshed_at timestamptz)
```
- `distinct_users` = upravičeni uporabniki z **vsaj enim** dogodkom (oz. profilom) v vedru.
- **Prikaz:** ≥ `K_privacy` → pokaži približek (»~40«); < `K_privacy` → pokaži **»še premalo«**, NIKOLI
  točne majhne številke (npr. ne »3«).

### 5.6 Pretok in vrstni red
`eligible_user` → (`activity_recent` nad 7-dnevnim oknom) + (`activity_frequency` + `activity_season`
za **tekoče** leto, running; pretekla leta zamrznjena) + `bucket_population`. Ko se leto zaključi,
postane del "preteklih celih sezon".

---

## 6. Dva praga (ne mešaj ju) — odločitev 2

- **`K_privacy = 5`:** RLS nikoli ne izpostavi vrstice/skupine z manj različnimi uporabniki. Trd,
  nepogajalski strop. Server-nastavljiv.
- **`K_reliab = 30`:** **odstotek** prikažemo le, če je imenovalec ≥ 30 (šum ±9 % ≈ koraku
  zaokroževanja na 10 %). Pod tem: **opisno** ("zgodaj / običajno / pozno", tercili) ali skrijemo.
  Server-nastavljiv.

`K_privacy` ščiti ljudi; `K_reliab` ščiti **resnico**.

---

## 7. Princip prikaza

### 7.1 Feed — "kaj se ta teden dogaja"
Za uporabnikovo vedro (najfinejši nivo, ki prestane prag, §7.4), drseče okno: beri `activity_recent`,
razvrsti po `distinct_users_7d` padajoče, top N. Prikaz **kvalitativno** ("pogosto / nekaj / redko")
ali "med ~N vrtnarji". Deluje **takoj**, brez zgodovine.

### 7.2 Časovni percentil — "kdaj / kje sem jaz"
1. **Zgodovinska krivulja (CDF)** iz **dokončanih preteklih sezon** `Y`:
   `F(w) = [Σ_{y∈Y} cumulative_y(≤w)] / [Σ_{y∈Y} season_total_y]` (uporabniško-uteženo).
2. **Tvoj položaj:** tvoja prva izvedba `T` letos v tednu `w_u` → `P = F(w_u)`.
   *"Do tvojega datuma je zgodovinsko začelo ~P % → bil si med zgodnejšimi/poznejšimi."*
3. **Še nisi začel:** *"Do zdaj (teden W_now) zgodovinsko začne ~F(W_now) % — ti še nisi."*
4. **Tekoče leto = marker, NE odstotek** (cenzura + rast baze, past §8.1/§8.2). Vsi % iz zgodovinske
   krivulje; tekoče leto kvečjemu tvoj marker + surovo število.

Številko `P`/`F` le, če imenovalec ≥ `K_reliab`; sicer opisni 3-pasni način (tercili).

### 7.3 Frekvenca — "kako pogosto" (odločitev 7)
Beri `activity_frequency` za uporabnikovo vedro: naslov *"V tvoji okolici kosijo tipično **2–4×
mesečno**"* (IQR p25–p75) + **stolpčni prikaz porazdelitve** iz `hist` z oznako »ti« (vizualno
konsistenten s časovnim percentilom). Številčni razpon le ob `n ≥ K_reliab`; sicer opisno/skrito.

### 7.4 Fallback hierarhija (en nivo, brez mešanja)
Za poizvedbo `(T, neobvezno P)` z uporabnikovimi vedri vzemi **prvi** nivo, ki prestane potrebni
prag:
```
res-7 (P) → res-6 (P) → res-5 (P) → climate (P) → global (P)
   → šele če tudi global+rastlina ne zadošča: spusti rastlino in ponovi (res-7 … global, brez P)
```
- **Specifičnost (rastlina) ohranjamo**, geografijo širimo prej ("kdaj sadijo *paradižnik*" ≠ "karkoli").
- **Klimatski koš pred globalnim** (sezonska opravila klimatsko gnana).
- **Vedno en nivo**; nikoli ne združujemo. UI označi obseg: *"v tvoji okolici"* (7/6/5) /
  *"v podobni klimi"* (climate) / *"med vsemi vrtnarji"* (global).

### 7.5 Sezonska vs nesezonska opravila
`task_type.seasonal=false` → brez časovne krivulje (§7.2); le feed + frekvenca.

### 7.6 Zagon brez zgodovine (leto 1)
Ni dokončane pretekle sezone → krivulja (§7.2) ni na voljo. Takrat:
- Feed (§7.1) in frekvenca (§7.3, tekoča sezona) **delujeta**.
- Percentil v **omejenem, označenem načinu**: *"med tistimi, ki so letos **že** začeli, si v
  zgodnejši/poznejši X %"* — **cenzuriran** (pozni še niso všteti, delež se premika) → izrecno
  "doslej letos". Ob prvi dokončani sezoni samodejni preklop na §7.2.

### 7.7 Negotovost in zaokroževanje
- % zaokroži na 10; po želji prikaži `n` ("med ~40 vrtnarji"). Pri `n ∈ [K_privacy, K_reliab)` le
  opisni način.
- Brez algoritemskih "insightov"; pogled **uporabniško sprožen** (past §8.10).

### 7.8 Obvestila okolice in odstotki čez kratko okno (vrzel iz wireframe verifikacije)
Odstotek »X % ta teden« je **prepovedan** kot samostojna trditev (imenovalec čez 7-dnevno okno ni
definiran). Dovoljeni sta dve podatkovno podprti ubeseditvi:
- **CDF (privzeto za obvestila):** *"Večina v tvoji okolici je do zdaj že posadila paradižnik —
  primeren čas tudi pri tebi?"* / *"~68 % je do zdaj že začelo gnojiti trato."* (iz `activity_season`).
- **Participacija zadnjih 7 dni (neobvezno):** `participation = distinct_7d / season_total` =
  *"približno X od Y vrtnarjev, ki to delajo, je bilo aktivnih ta teden"* — mehka angažiranost, NE
  sezonska trditev; isti `K_privacy`/`K_reliab` gate-i. Feed sam ostane **kvalitativen**
  (pogosto/nekaj/redko), ne odstoten.

---

## 8. Statistične pasti, ki smo jih upoštevali

1. **Cenzura tekoče sezone.** Mid-sezone ne veš, kdo bo še začel. → % iz dokončanih preteklih sezon;
   tekoče leto le marker.
2. **Rast baze čez leta.** Absolutnih števcev med leti **ne primerjamo**. → primerjave v deležih (CDF).
3. **Ne-additivnost `COUNT(DISTINCT)`.** → feed računa distinct direktno nad oknom; krivulja
   uporablja **prve izvedbe** (vsak uporabnik enkrat → kumulativa dejansko seštevljiva).
4. **Delni koledarski teden.** → feed = drseče 7-dnevno okno; krivulja iz preteklih celih sezon.
5. **Majhen vzorec → lažna natančnost.** → ločen `K_reliab`; zaokroževanje; opisni pas pod pragom.
6. **Časovni pas / dan.** → binning po lokalnem dnevu (`profile.timezone`); tedenska granulacija +
   nevtralnost enakomernega zamika v relativnem percentilu.
7. **Sezonsko sidro / polobla.** → MVP koledarsko leto/sever; izpeljano (brez zapečenja); zimska
   čez-letna + jug = dokumentirani omejitvi.
8. **Prva vs vse izvedbe.** → krivulja iz **prvih** izvedb (sicer power-uporabnik popači).
9. **Mešanje nivojev / dvojno štetje.** → vedno en nivo; strog fallback; obseg označen.
10. **Selekcijska pristranskost / "data dredging".** → opisno ("med Tendask vrtnarji"); pogled
    uporabniško sprožen.
11. **Selitev uporabnika.** → posnetek vedra na dogodku (§4.2) + COALESCE.
12. **Anonimnostni set vs zanesljivost.** → dva praga (§6).
13. **Eksplozija dimenzij (rastlina).** → fallback tudi po spustu rastline (§7.4).
14. **Frekvenca: povprečje vs mediana.** Desno-nagnjena porazdelitev (power-uporabniki). → **mediana
    + IQR**, le med izvajalci, le v aktivni sezoni.

---

## 9. Strošek / free plan

- Tri agregatne tabele so **drobne** (tisoči–nizki desettisoči majhnih vrstic). Zanemarljiv del 500 MB.
- `pg_cron` teče **znotraj baze** (nočno, inkrementalno). Branje = majhne filtrirane rezine.
- Pravi dolgoročni porabnik 500 MB so **surove vrstice opravil** (sync tako ali tako).

---

## 10. Zasebnost — preverjeno

- Koordinate/višina **ne zapustijo naprave**; v oblak le H3 (r7+) in **grob** `climate_bucket`.
- `climate_profile` je **owner-only** (RLS), **nikoli v javni agregat**.
- Navzven **nikoli pod res-7**; vse k-anonimno (`K_privacy`). `is_custom` izključen.
- `activity_*` tabele so **javno-bralne** (prva taka kategorija poleg owner-only user-tabel in
  javno-bralnega kataloga). Piše jih **samo cron** (service-role / `SECURITY DEFINER`); klient nikoli.
  RLS izpostavi le k-anonimne vrstice. Agregati ne hranijo `user_id`, le števce/povzetke.
- GDPR: ob izbrisu računa (`ON DELETE CASCADE`) surove vrstice izginejo; naslednji cron jih izloči.

---

## 11. Preostali implementacijski detajli (dorečemo ob kodi)

Vsa konceptualna/shemska vprašanja so razrešena (§0.1). Ostane le:
- **Open-Meteo endpoint + kazalnik** za `climate_profile` (arhiv vs climate API; ali frost računamo
  iz dnevnega arhiva ali ga ponudnik da neposredno) + **meje pasov** `climate_bucket` (in odločitev
  o morebitni odvečnosti višinske osi).
- **Normalizacija frekvence** (na mesec aktivne sezone vs na sezono) + definicija "aktivne sezone".
- **Točna SQL oblika** crona (inkrementalni preračun okna, upsert, materializacija `eligible_user`).
- **Kalibracija** `X/N/M`, `K_privacy`, `K_reliab` po prvih realnih podatkih.

---

*Ko se začne implementacija, povzamemo v `koncept.md §8` in dodamo korake v `roadmap.md`
(zgodnji temelj + V2 pogledi).*
