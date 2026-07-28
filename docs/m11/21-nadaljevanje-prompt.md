> **ZASTARELO — veljavna vstopna točka je `22-nadaljevanje-prompt.md`.** Paketa 1 in 2 iz §9
> sta izvedena (`f3e4bd0`, `c7b7033`, `b837c5f`); ostane P10 → P11 → naprava.

# M11 — predaja seje (triaža opravljena, test na napravi tekel, 12 novih najdb)

> **Datum:** 2026-07-28 · veja `feat/m11-smart-engine` · **nič pushano, produkcija nedotaknjena**
> **Vstopna točka za novo sejo.** Preberi tega celega, nato `19-najdbe-med-izvedbo.md`
> (N13–N24 so nove) in `17-plan-popravkov.md` §3.

---

## 0 · Stanje v eni vrstici

P1–P9 commitani · **triaža 14 vprašanj opravljena** · **test na napravi proti stagingu tekel** in
dal **12 novih najdb (N13–N24)**, od tega **5 že zaprtih** · **vse odločitve O1–O6 sprejete** →
P10 in P11 nista blokirana · **1293 Flutter + 159 Deno zelenih**, analyze čist.

## 1 · Commiti te seje

| Hash | Kaj |
|---|---|
| `8d7e96d` | triaža odprtih vprašanj + najdbe N13–N23 + kontrolni seznam ob prižigu v runbooku |
| `bdf3384` | **seed**: 70 sosedov, 35 `@site` + 35 `apple`, tie-break celice, `water` med tipi |
| `190fd7d` | **`tool/adb_run.ps1`**: `-Steps`, `-Vars NAME=VALUE`, korak `shot` |
| `2b1cd49` | predaja seje (ta dokument) |
| `9fb8d69` | **N19 + N22**: poteg doseže mrežo; pragova povesta resnico + straži v testih |
| `64e85d0` | pregled najdb po teži, zaprte vrstice s hashi |
| `b9c4eb4` | sprejete odločitve O4, O5, O6 |

## 2 · Naloga A — rezultat triaže

`10-odprta-vprasanja.md` ima zdaj triažno tabelo **in žig pri vsakem vprašanju**:

| Kup | # | Kaj to pomeni |
|---|---|---|
| **A · sprožilec je nastopil** | #5, #8, #12, #13 | živa vrstica v dnevniku najdb |
| **B · nastopi ob prižigu** | #1, #2, #6, #7, #9 | kontrolni seznam v `docs/deploy-runbook.md` |
| **C · ni aktualno** | #3, #4, #10, #11, #15 | ostane, s pogojem zapisanim pri vprašanju |

Popravka prejšnjih zapisov: **#9 ni bomba** (odjava in motor žeton počistita) — manjka pa metrika,
na kateri drevo visi (**N12**). **#13 je najhujši** — njegov pogoj se je uresničil dobesedno.

## 3 · Naloga B — kaj je odkljukano (z artefaktom) in kaj ne

**Odkljukano.** Posnetki so v `tmp/shots/` (gitignore — če jih rabiš, poženi test znova):

- Pet zavihkov z ⬡ · Okolica pristajalni, oba zavihka · detajl s krivuljo, kvartili, histogramom
- **Tri vstopne poti** v `community-task` (pas Okolice · sekcija Domov · kartica opravila)
- **Cross-branch**: Domov → detajl → nazaj → menjava zavihka — **brez sesutja**
- **P6**: nesezonski `water` s 35 sosedi v kohorti → histogram je, **kartice časovnice ni**
- **§5b pragovi**: kohorta 35 → številke · 29 → **nič** (gl. N22) · 4 → vrstice sploh ni ✓
- **Predlog prek sync pulla, ne pusha**
- **P1**: »Ne predlagaj več« → ponoven tek motorja → `emitted:0, candidates:[]`;
  `suggestion_log: guard=R3:water, dismissed_until=9999-12-31`

**Ni odkljukano — to je naslednje delo:**

- Offline stanja iz P8 (letalski način, »Podatki od {datum}«, vrnitev signala)
- Polna matrika sl/en/de × 1,0/1,3 po **vseh** M11 zaslonih (naredil sem samo de/320 dp → N23)
- »Pretekli predlogi«, stikali `weather_hints` / `community_hints`
- `band_max_active` (rabiš ≥4 hkratne predloge — motor jih mora izdelati)
- Ubeseditev percentila (P4) — vidna je, a **samo v cenzuriranem stanju** (gl. N24)

## 4 · Najdbe te seje — po teži

| # | Kaj | Kam |
|---|---|---|
| ~~N22~~ | »Opisni pas« med 5 in 30 **ne obstaja**; prag zapisan dvakrat | ✅ delno `9fb8d69` — ostanek je odločitev, gl. dnevnik |
| ~~N19~~ | Pull-to-refresh v Okolici je bil znotraj dneva **placebo** | ✅ `9fb8d69`, dokazano na napravi (39 → 70 z eno gesto) |
| **N18** | Seed ni prestopil praga za nobeno kohorto (`0017` razdelil, `0018` dvignil na 30) | ✅ `bdf3384` |
| **N14** | Tihi klimatski osvežilnik je za `kSuggestionsEnabled`; prod tega ključa nima → **nikoli ne teče**. Pravi vzrok za prazne `timezone` (N1) | P11 |
| **N17** | »Kje si ti« ob 40 sosedih trdi, da jih je premalo — zliti `mine.isEmpty` in `buckets.isEmpty` | P10 |
| **N23** | de/320 dp/×1,3: »Überwiegend klar« → `Ü…`; matrika tega **ne more** ujeti, ker Domov riše z `weather: null` | pogoj prižiga |
| **N13** | Pet mest obljublja Okolico kot »kmalu (V2)« / »Pozneje« / »(kasneje)«, medtem ko dela | P10 |
| **N15** | `agg_context` zamrzne celico, **ne pa cone** — sprememba cone tiho prepiše `local_day` cele zgodovine | P10/P11 |
| **N20** | Dvojna pika za vsakim datumom (`1. 6..`) — formatter + ~51 predlog; gre tudi v push | P10 |
| **N24** | `activity_season` ne bo nikoli imel preteklih let → »prva sezona« do 2027 | opažanje |
| **N21** | Frekvenca izpiše `2–2×`, ko sta kvartila enaka | P10 |
| **N16** | Seed je izbiral celico po izenačenju | ✅ `bdf3384` |

## 5 · Odločitve — vse sprejete 2026-07-28

| # | Sprejeto | Kaj naredi |
|---|---|---|
| **O4** | R1 ostane **ojačevalec** | mrtvi ključ `suggestions.weather.window_open` ven; kartica dobi **pripono**, ko motor postavi `dry_window` (že ga pošilja — N4). Popravi `03 §R1` + `00-pregled-za-laika.md`. |
| **O5** | `plant_task_rule` **s klienta ven** | seed + catalog-sync pot + drift tabela. Vrne se z bralcem in testom, če bo offline motor. |
| **O6** | **opisno** | »Večina vrtnarjev v tvoji okolici je to letos že začela.« Brez odstotka; anti-steering varovalo razširi na `suggestions.community.*`. |

**P10 in P11 s tem nista več blokirana.**

## 6 · Kako testirati na napravi (naučeno v tej seji)

```bash
# 1) pragovi / velikost soseske
wsl -e bash -lc "cat .../supabase/seed/staging_test_data.sql | docker exec -i supabase-db psql -v ON_ERROR_STOP=1 -U postgres -d postgres"
docker exec -i supabase-db psql -v ON_ERROR_STOP=1 -v keep=64 -U postgres -d postgres < tmp/staging_keep_neighbours.sql

# 2) po spremembi podatkov zadošča poteg v aplikaciji (N19 popravljen v 9fb8d69).
#    pm clear rabiš le, ko hočeš testirati onboarding od začetka.
adb shell pm clear app.tendask && adb shell monkey -p app.tendask -c android.intent.category.LAUNCHER 1

# 3) prijava (koda iz Mailpita)
powershell -ExecutionPolicy Bypass -File tool\adb_run.ps1 -Steps tmp\scenarios\otp_request.txt
powershell -ExecutionPolicy Bypass -File tool\adb_run.ps1 -Steps tmp\scenarios\prag_obe_kohorti.txt -Vars OTP=123456,TAG=15_test

# 4) ročni tek motorja
KEY=$(docker inspect supabase-edge-functions --format '{{range .Config.Env}}{{println .}}{{end}}' \
      | grep '^SUPABASE_SERVICE_ROLE_KEY=' | cut -d= -f2-)
curl -s -X POST https://api-staging.tendask.app/functions/v1/smart-engine \
     -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' \
     -d '{"user_ids":["107b37fb-43a2-4684-9aeb-06c7daa63eec"]}'
```

**Scenariji** v `tmp/scenarios/` (gitignore): `otp_request`, `login_code`, `prag_obe_kohorti`,
`prag_pod_privacy`, `okolica_pregled`. Ad-hoc raziskava ostane v `tmp/steps.txt`.
Runner: `-Steps <pot>`, `-Vars A=1,B=2` (**z vejico, ne dvakrat** — `-File` ne veže polj),
korak `shot <ime>` shrani `tmp/shots/<ime>.png`.

### Pasti, ki so me stale časa

- ~~Pull-to-refresh ne osveži~~ — popravljeno (`9fb8d69`). Pred tem popravkom je vsaka sprememba
  podatkov med testiranjem izgledala kot okvara funkcije; če kdaj spet tako izgleda, preveri to prvo.
- **Vnos OTP se pripne** k stari kodi — pred vnosom pobriši polje (scenariji to že delajo).
- **Poteg za osvežitev z `y=700` odpre obvestilno vrstico** — začni pri `y=900`.
- **Ročni GPS takoj po dodelitvi dovoljenja tiho ne shrani** — drugi pritisk deluje.
- **Račun `gorazd@spletnakoda.si` je `provider=email`** (OTP dela); `exogenus@gmail.com` je Google —
  OTP prijava nanj bi tvegala drugo identiteto.
- **320 dp** = `adb shell wm density 540`, **360 dp** = `480`; nazaj `wm density reset`.

## 7 · Kaj ostane

- **P10** — jezik in besedila: **N13**, **N17**, **N20**, N21 · **O4** (pripona za suho okno +
  mrtvi ključ ven) · **O6** (opisno) · **N9** (`agg_context` DB straža) · `screen-map.md`
- **P11** — higiena: **N14 + N1** (cona; brez tega je backfill brez pomena) · **O5**
  (`plant_task_rule` s klienta ven) · **N2** · **N15**
- **Dokončaj kontrolni seznam** iz §3 (offline, jezikovna matrika, preostali zasloni)
- **Pred prižigom Okolice:** spodnja vrstica pri petih zavihkih (R4) **in N23** · `kDevPlusStub=false`
- **Pred `db push` na prod:** sonda `supabase/probe/m11_shape.sql` + diff proti stagingu

## 9 · Delovni nalog: zapri, kar je odprto (naslednja seja)

Cilj: zapreti **vse** odprte najdbe in nedorečenosti, ne le najlažjih. Vrstni red ni poljuben —
najprej meritev, potem podatki, šele nato besedilo, ker popravek besedila na napačnih podatkih
samo lepše laže.

### Paket 1 · N8 — sezonska simulacija (najprej, ker je meritev)

Edina stvar, ki trditev »motor ne spama« spremeni iz obljube v podatek. 159 obstoječih testov
gleda vsako pravilo pri **enem** `runDate`.

**Naredi:** test, ki premakne `runDate` čez 365 dni nad fiksnim sintetičnim `UserBundle` in
posnetimi Open-Meteo odgovori, šteje emisije po pravilih in pade, če katero preseže pričakovano
zgornjo mejo na sezono. Izpis = golden »koledar predlogov za leto«.

**Past, ki odloči, ali test sploh kaj dokazuje:** cooldowni in straže (`suggestion_log`,
`engine_run.last_run_date`, `dismissed_until`) so **stanje med dnevi**. Zanka, ki stanje ob vsakem
dnevu ponastavi, izmeri nič — dokazala bo le, da se pravilo lahko sproži, ne kolikokrat se res.
Simulacija mora stanje nositi naprej skozi vseh 365 iteracij, tako kot ga nosi produkcija.

**Done:** golden file commitan · test pade, če se meja zviša · v `19-najdbe-med-izvedbo.md`
zapisano, **kaj je meritev pokazala** (tudi če je vse v mejah — to je rezultat, ne odsotnost
rezultata).

### Paket 2 · Podatki — edine najdbe, ki dajo napačen rezultat

| Najdba | Kaj |
|---|---|
| **N14 + N1** | `refreshClimateIfStale` je v `main.dart:162` za `kSuggestionsEnabled`, prod tega ključa nima → na produkciji **ne teče nikoli**. Vezava je napačna po vsebini: cona in klimatski koš hranita tudi Okolico (`agg_event.local_day`), ne le predlogov. Popravi pogoj **in** poskrbi, da se klic ponovi po prijavi (danes teče samo ob zagonu, ko je uporabnik še gost). Šele nato se pogovoriva o strežniškem backfillu — ta je mogoč (strežnik ima `h3_r7` → centroid → cona), a brez tega popravka bi se luknja jutri napolnila nazaj. |
| **N9** | `agg_context` write-once nima DB straže, agregati pa nanj že štejejo. Dodaj `before update` trigger, ki zavrne spremembo, ko je stara vrednost ne-null. Preveri, ali kak backfill rabi izjemo. |
| **N15** | `agg_context` zamrzne celico, ne pa cone → sprememba cone tiho prepiše `local_day` cele zgodovine. Odloči: cona **v** posnetek, ali zapisano zakaj ne. |

### Paket 3 · P10 — besedilo, ki laže

**N13** (pet mest obljublja »kmalu (V2)«, medtem ko funkcija dela — uvod in zaslon lokacije nista
vezana na noben flag) · **N17** (»Kje si ti« krivi okolico za uporabnikovo prazno zgodovino; manjka
tretja veja `mine.isEmpty`, in past je širša: laže tudi tistemu, ki ima zgodovino napačne vrste) ·
**N20** (dvojna pika za vsakim datumom, ~52 predlog, gre tudi v push) · **N21** (`2–2×`) ·
**O4** (pripona za suho okno + mrtvi ključ ven) · **O6** (opisno, brez odstotka).

### Paket 4 · P11 — higiena

**O5**: `plant_task_rule` s klienta ven (seed, catalog-sync pot, drift tabela) · **N2**
(`communityWeekly` brez testa).

### Paket 5 · Dokončaj test na napravi

Offline stanja iz P8 · polna matrika sl/en/de × 1,0/1,3 po vseh M11 zaslonih (**N23**: pri tem
upoštevaj, da matrika Domov riše z `weather: null`, torej realnih vremenskih nizov ne vidi) ·
»Pretekli predlogi« · stikali obvestil · `band_max_active` (rabiš ≥4 hkratne predloge).

### Česa NE zapiraj

N5, N6 (staging, zapisano v runbooku) · N10 (zabeležena odložitev) · N24 (po zasnovi) · ostanek
N22 (odločitev o zasebnosti, ne popravek). Te so **sprejete**, ne dolg — če jih kdo »popravi«,
je to regresija.

## 8 · Sklici

`19-najdbe-med-izvedbo.md` (**beri prvi**) · `17-plan-popravkov.md` · `docs/deploy-runbook.md`
(§»Odprta vprašanja, ki oživijo ob prižigu«) · `10-odprta-vprasanja.md` (triaža) ·
`docs/prelomi-besed.md` · `docs/staging-env.md` · `CLAUDE.md`
