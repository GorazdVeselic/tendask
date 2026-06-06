# Vreme — shranjevanje in optimizacija (FR-7)

> Status: **odločeno na papirju (2026-06-06), neimplementirano.** Vir resnice za to, *kako* se
> vreme shranjuje. Nadomešča prvotni model "en zamrznjen JSON posnetek na task" iz `koncept.md`
> §7.9/§7.10 (glej §7 spodaj — posledica za koncept).

## 1. Problem

Vreme je danes denormaliziran JSON blob na vsakem opravilu (`task.weather`) in vsaki opombi
(`note.weather`). En posnetek (`WeatherSnapshot`) nosi ~550–650 B (3 pasovi: pogoji ob izvedbi +
48 h nazaj + 3-dnevna napoved).

**Volumetrija** (predpostavka: 10.000 uporabnikov × ~30 opravil/mesec):

| Obdobje | Št. opravil | Samo `weather` kolona |
|---|---|---|
| mesec | 300.000 | ~180 MB |
| leto | 3,6 M | **~2,1 GB** |
| 3 leta | 10,8 M | **~6,3 GB** |

Problem ni velikost posameznega blob-a, ampak **podvajanje**: vreme je fizikalna funkcija
`f(lokacija, čas)`. Dva uporabnika v isti H3 celici ob istem dnevu imata identično vreme; trije
taski istega uporabnika v eni seansi nosijo tri identične kopije. H3 r7 (~5 km²) je hkrati grobji
ali primerljiv z Open-Meteo gridom (~1–11 km) — pod-celična natančnost, ki jo shranjujemo po
taskih, je fiktivna.

## 2. Vodilni vpogled

Vreme **ni osebni podatek** — je javna funkcija `(h3_celica, dan)`. Iz tega sledi:

1. **Deduplikacija**: dnevno vreme shrani enkrat na `(h3_r7, dan)`, task se sklicuje. Isti vzorec
   kot katalog (javno-bralno), ne per-user RLS.
2. **Rekonstrukcija**: historično vreme je deterministično. Open-Meteo `forecast` z `past_days`
   (do ~92 dni) vrne **izmerjene** vrednosti za pretekle dni → napoved se da naknadno nadgraditi
   v dejansko.

## 3. Model (odločeno)

Vreme okoli opravila = **ozko okno ±1 dan, centrirano na dan izvedbe**, in povsod **dejansko**
vreme (ne napoved — razen prehodno za prihodnost). Dva tipa podatka, dve mesti, **nikoli pomešana**:

### Tip A — trenutni pogoji ob kliku ✓ (dan 0)
Točkovni posnetek tiste ure ("ob 7:00 dež, 14°"). **Odvisen od ure** → zaseben tasku, frozen,
nikoli deljen. Živi kot **kompakten blob na tasku**. Polja (vse):

| Polje | Pomen |
|---|---|
| `temperature` | temp. zraka ob kliku |
| `humidity` | vlaga |
| `precipitation` | padavine zadnjo uro |
| `windSpeed` | veter |
| `weatherCode` | WMO koda (ikona) |
| `soilTemperature` | temp. tal (6 cm) |
| `et0` | evapotranspiracija |
| `capturedAt` | žig zajema |

### Tip B — dnevni povzetki (dan −1, dan 0, dan +1)
Agregati celega dne ("max 30°, min 14°, 5 mm dež") → **urno-neodvisni**, zato se smejo deliti po
celici. Živijo v skupni `weather_observation(h3_r7, dan)`. Polja (minimalno):

| Polje | Pomen |
|---|---|
| `weatherCode` | WMO koda (ikona) |
| `tempMax` | dnevni maksimum (vročinski/sušni stres) |
| `tempMin` | dnevni minimum (**slana** — agronomsko ključno) |
| `precipitationSum` | dnevni dež |

`et0` in `soilTemperature` za sosednja dneva **namenoma izpuščena** (za "kaj je bilo včeraj / bo
jutri" nepotrebna). Za dan −1/0/+1 hranimo `tempMax` **in** `tempMin` (ne ene temperature): min =
slana, max = vročina sta dve različni agronomski informaciji, strošek je ena `float` številka na
deljeni vrstici.

### Zakaj ni kolizije
Uporabnik A (7:00, dež) in B (18:00, sonce) v isti celici isti dan: njuna *trenutna pogoja* (tip A)
živita vsak na svojem tasku → nikoli ne tekmujeta za isto vrstico. Skupna tabela (tip B) drži samo
**dnevne agregate**, ki so po definiciji enaki ne glede na uro pogleda — A in B oba vidita isti
"6. jun: max 30°, min 14°, 5 mm, ⛈️". Oba pogleda sta resnična: "ob mojem kliku je bilo X" +
"tisti dan je bilo na splošno Y".

## 4. Napoved → dejansko (samozdravljenje)

Dan +1 ob izvedbi **še ne obstaja** (prihodnost). Zato:

1. Ob izvedbi se zapiše dan +1 kot **napoved** (`status = 'forecast'`, na voljo takoj iz Open-Meteo)
   — uporabnik takoj vidi smiselno vrednost, nikoli prazno.
2. Ko dan mine, postane dejansko vreme na voljo → vrstica se nadgradi v `status = 'actual'`.

**Kdo proži nadgradnjo — vezano na celico, ne na task.** En vrt = ena celica, ~30 opravil/mesec
večinoma v isti celici → dnevi se prekrivajo: dan +1 enega opravila je dan 0 ali −1 poznejšega in
se napolni **sam od sebe**. Mehanizmi po fazah:

- **Lazy self-healing (MVP):** ob vsakem branju/zajemu naprava oportunistično pogleda, katere
  vrstice za njeno celico so še `forecast`, a je dan že pretekel → **ena** poizvedba Open-Meteo
  (`forecast` s `past_days`) nadgradi napoved → dejansko. Brez crona, brez stroška za neaktivne.
- **Cron backstop (V2):** dnevni `pg_cron` / Supabase Edge Function (service role) pobere rep —
  vrstice `status='forecast' AND dan < current_date - interval '7 days'` (krajši prag, ne 60 —
  varnostni rob do 92-dnevne meje). Dela **na celici, ne na tasku** (zato ne rabi `deleted` filtra).
- **Graceful degrade:** solo uporabnik, ki app ne odpre, vidi dan +1 z oznako *"napoved"*, dokler
  se ne vrne. Sprejemljivo.

## 5. Zasebnost

- Skupna `weather_observation` je **javno-bralna** (kot katalog), ključ `(h3_r7, dan)`. Ni osebni
  podatek → ni per-user RLS, se ne briše ob izbrisu računa, ON DELETE CASCADE je ne zadeva.
- **Cron/server nima koordinat** (surove koordinate nikoli ne zapustijo naprave). Open-Meteo klic
  uporabi **centroid celice** (`h3.cellToLatLng(h3_r7)`) — deterministična funkcija javne mreže,
  ni uporabnikova lokacija; Open-Meteo tako ali tako kvantizira na svoj grid → rezultat identičen.

## 6. Skica sheme (ni final)

```
weather_observation
  h3_r7            text
  day              date
  weather_code     int
  temp_max         double
  temp_min         double
  precipitation_sum double
  status           text  -- 'forecast' | 'actual'
  updated_at       timestamptz
  PRIMARY KEY (h3_r7, day)          -- javno-bralno, NE per-user

task   (sprememba)
  ...
  weather_cell     text     -- h3_r7 ob izvedbi (snapshot — vrt se lahko premakne)
  weather          jsonb    -- SAMO tip A (trenutni pogoji ob kliku, kompakten)
  -- dan −1/0/+1 dnevni povzetki = (weather_cell, date±1) → weather_observation
```

Odprto pri implementaciji:
- **Sync vzorec za deljeno write-tabelo**: klient bere (kot katalog, pull) *in* piše (insert ob
  zajemu) — drugačen vzorec od per-user push/pull. Definirati ob implementaciji V2.
- Kompaktiranje tipa A bloba (kratki ključi, zaokroževanje na 1 decimalko) — Raven A iz debate.

## 7. Posledica za `koncept.md`

§7.9 in §7.10 trenutno opisujeta **en zamrznjen JSON posnetek** ("nikoli prepisan", 3 pasovi z
napovedjo 24–72 h naprej). Ta model ga nadomešča:

- "3 pasovi" → **okno ±1 dan**: dan −1 (dejansko), dan 0 (trenutni pogoji + dnevni povzetek),
  dan +1 (napoved → dejansko).
- "frozen, nikoli prepisan" velja le za **tip A** (trenutni pogoji ob kliku). Dnevni povzetki
  (tip B) se **smejo nadgraditi** (napoved → dejansko) — to ni prepis posnetka, ampak dopolnitev.
- Detajl opravila prikaže: trenutne pogoje (tip A iz taska) + okvir −1/0/+1 (tip B iz
  `weather_observation`). Pri starem tasku dan +1 pokaže, kaj se je **dejansko** zgodilo.

Posodobitev §7.9/§7.10 sledi ob implementaciji.

## 8. Faznost (da ne over-engineeriramo — vodilo #3)

Volumetrijska skrb (10k uporabnikov, ~2 GB/leto) je **V2 skala**. MVP je enouporabniški; tam je
Supabase strošek majhen. Zato:

- **MVP:** dovolj je hibrid lokalno — tip A blob na tasku (kompakten, z max+min za sosednja dneva)
  + lazy self-healing za dan +1. Skupna `weather_observation` sme začeti kot **lokalna drift
  tabela** (dedup znotraj uporabnikove naprave + lokalni prikaz). **Brez** shared cloud
  infrastrukture.
- **V2 (skala):** ekstrahiraj dnevne povzetke v **shared** cloud `weather_observation(h3_r7, day)`
  za cross-user deduplikacijo (Supabase prihranek) + cron backstop. To pride, ko gre server-side
  (community motor) itak v tek.

## 9. Dependency opozorilo (Open-Meteo)

Dve **ločeni** omejitvi, ki ju je lahko zamešati: tehnični throttling in licenca. (Aktualno
preverjeno 2026-06-06; politika se lahko spremeni.)

### 9.1 Tehnični throttling — **per IP naslov**
Free tier: **600 klicev/min · 5.000/h · 10.000/dan**, rezано **per IP**, ne per ključ/aplikacija.
Klici so uteženi: `weight = nLocations × (nDays/14) × (nVariables/10)` → en Tendask klic (1 lokacija,
~5 dni, ~10 spremenljivk) šteje kot **~1**.

**Posledica za arhitekturo — kje throttling boli, je odvisno od tega, od kod klic izhaja:**
- **Client-side (MVP, kot zdaj):** vsak uporabnik = svoj IP = svoja kvota. 10k uporabnikov z nekaj
  klici/dan je daleč pod limitom. Throttling **ni problem**. (To je glavna prednost, da vreme kličemo
  iz naprave, ne iz backenda.)
- **Server-side (V2 cron backstop):** vsi klici skozi **en** strežniški IP = ena skupna kvota →
  10k uporabnikov razbije 10.000/dan. Cron zato rabi plačljiv plan **ali self-host** (§9.3).
- **Past — CGNAT:** mobilni operater lahko skrije veliko naročnikov za en javni NAT IP → si delijo
  kvoto. Pri 10k razpršenih uporabnikih nizko tveganje (prag je visok, klicev malo), a ne ničelno
  za zelo goste skupine na istem operaterju.

### 9.2 Licenca — **ni odvisna od volumna ali IP razpršenosti**
Free tier je **samo nekomercialen**. Komercialna raba zahteva plačljivo naročnino **ne glede na
število klicev** ("regardless of call volume"). Torej: per-IP razpršenost (§9.1) reši *throttling*,
**ne** licence. Če bo Tendask komercialen (naročnine, oglasi, for-profit), potrebuje plačljiv
Open-Meteo plan, čeprav so klici client-side in razpršeni. Če bo res nekomercialen (brezplačen,
brez oglasov/naročnin), je free tier legitimen. Poslovna/pravna odločitev, ne tehnična.

### 9.3 Tretja možnost — self-host
Open-Meteo je **odprtokoden** → lahko teče na lastnem strežniku. Reši **oboje** hkrati: ni rate-limita
(lastna instanca) in ni komercialne licenčne omejitve. Cena = strežnik + vzdrževanje. Smiselno ravno
za V2 cron backstop, ki bi sicer trčil v throttling (§9.1) in licenco (§9.2) hkrati.

**Vir:** [pricing](https://open-meteo.com/en/pricing) · [terms](https://open-meteo.com/en/terms) ·
[discussion #853](https://github.com/open-meteo/open-meteo/discussions/853). Odločitev pred V2/launch.
