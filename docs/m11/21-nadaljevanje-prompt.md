# M11 — predaja seje (triaža opravljena, test na napravi tekel, 12 novih najdb)

> **Datum:** 2026-07-28 · veja `feat/m11-smart-engine` · **nič pushano, produkcija nedotaknjena**
> **Vstopna točka za novo sejo.** Preberi tega celega, nato `19-najdbe-med-izvedbo.md`
> (N13–N24 so nove) in `17-plan-popravkov.md` §3.

---

## 0 · Stanje v eni vrstici

P1–P9 commitani · **triaža 14 odprtih vprašanj opravljena** · **test na napravi proti stagingu
tekel** in dal **12 novih najdb (N13–N24)** · 1285 Flutter + 159 Deno zelenih · ostaja **P10, P11**
in dokončanje kontrolnega seznama (offline, jezikovna matrika, nekaj zaslonov).

## 1 · Commiti te seje

| Hash | Kaj |
|---|---|
| `8d7e96d` | triaža odprtih vprašanj + najdbe N13–N23 + kontrolni seznam ob prižigu v runbooku |
| `bdf3384` | **seed**: 70 sosedov, 35 `@site` + 35 `apple`, tie-break celice, `water` med tipi |
| `190fd7d` | **`tool/adb_run.ps1`**: `-Steps`, `-Vars NAME=VALUE`, korak `shot` |

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
| **N22** | »Opisni pas« med 5 in 30 **ne obstaja**; prag zapisan dvakrat (strežnik `app_config`, klient zapečen `30`), zato je veja `freq_low_n` mrtva | P10 |
| **N19** | Pull-to-refresh v Okolici je znotraj dneva **placebo** — `ref.invalidate()` bere isti dnevni cache | P10 |
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

## 5 · Odprte odločitve — zdaj s podatki

- **O4 (»suho okno«, blokira P10).** Zdaj je vidno: motor je poslal `dry_window: true, dry_hours: 48`,
  kartica pa je izpisala samo »Greda 1: zamuda približno 23 dni (običajni ritem ~7 dni)«. Torej
  parameter res **ne pride nikamor** (N4). Priporočilo ostaja **(c)**: R1 ostane ojačevalec, mrtvi
  ključ `suggestions.weather.window_open` ven, kartica dobi pripono, ko je `dry_window` postavljen.
- **O5** (`plant_task_rule` na klientu, blokira P11) — nespremenjeno; brez bralca ven.
- **O6** (`suggestions.community.most_started`) — nespremenjeno, priporočilo **(a) opisno**.

## 6 · Kako testirati na napravi (naučeno v tej seji)

```bash
# 1) pragovi / velikost soseske
wsl -e bash -lc "cat .../supabase/seed/staging_test_data.sql | docker exec -i supabase-db psql -v ON_ERROR_STOP=1 -U postgres -d postgres"
docker exec -i supabase-db psql -v ON_ERROR_STOP=1 -v keep=64 -U postgres -d postgres < tmp/staging_keep_neighbours.sql

# 2) OBVEZNO po vsaki spremembi podatkov — pull-to-refresh NE dela (N19)
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

- **Pull-to-refresh ne osveži** (N19) → `pm clear` + ponovna prijava; drugače vse izgleda pokvarjeno.
- **Vnos OTP se pripne** k stari kodi — pred vnosom pobriši polje (scenariji to že delajo).
- **Poteg za osvežitev z `y=700` odpre obvestilno vrstico** — začni pri `y=900`.
- **Ročni GPS takoj po dodelitvi dovoljenja tiho ne shrani** — drugi pritisk deluje.
- **Račun `gorazd@spletnakoda.si` je `provider=email`** (OTP dela); `exogenus@gmail.com` je Google —
  OTP prijava nanj bi tvegala drugo identiteto.
- **320 dp** = `adb shell wm density 540`, **360 dp** = `480`; nazaj `wm density reset`.

## 7 · Kaj ostane

- **P10** (O4, O6): jezik, N13, N17, N19, N20, N21, N22, mrtvi ključ, `screen-map.md`, #13/#14
- **P11** (O5): higiena; **N1 + N14** (cona), **N2** (`communityWeekly` test), **N15**
- **Dokončaj kontrolni seznam** iz §3 (offline, jezikovna matrika, preostali zasloni)
- **Pred prižigom Okolice:** spodnja vrstica pri petih zavihkih (R4) **in N23** · `kDevPlusStub=false`
- **Pred `db push` na prod:** sonda `supabase/probe/m11_shape.sql` + diff proti stagingu

## 8 · Sklici

`19-najdbe-med-izvedbo.md` (**beri prvi**) · `17-plan-popravkov.md` · `docs/deploy-runbook.md`
(§»Odprta vprašanja, ki oživijo ob prižigu«) · `10-odprta-vprasanja.md` (triaža) ·
`docs/prelomi-besed.md` · `docs/staging-env.md` · `CLAUDE.md`
