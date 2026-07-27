# M11 — predaja seje (popravki po pregledu, P1–P7 narejeni)

> **Datum:** 2026-07-27 · veja `feat/m11-smart-engine` · **nič pushano**
> **Plan, ki ga izvajava:** `docs/m11/17-plan-popravkov.md` (paketi P1–P12, odločitve O1–O6)
> **Ta dokument je vstopna točka za naslednjo sejo.** Preberi ga celega, nato `17-plan-popravkov.md`
> §3 za pakete, ki še niso narejeni.

---

## 0 · Stanje v eni vrstici

P1–P7 iz plana so **narejeni in commitani**; ostajajo **P8–P12** in dva ostanka P7.
`flutter analyze` čist · **1220 Flutter** in **159 Deno** testov zelenih · motor 93,8 % vrstic.
Vse še vedno leži za `kSuggestionsEnabled = false` — nič od tega ne doseže uporabnika.

## 1 · Commiti te seje (najstarejši najprej)

| Hash | Paket | Kaj |
|---|---|---|
| `c34c62e` | **P1** | dismiss zapiše mute; klient prenese sentinel datum namesto `'infinity'` |
| `f04cacb` | **P2** | R6 zaključena okna, cadence 0, odporen razpored oken pravil |
| `bcf8544` | **P3** | FCM 400 ni mrtev token, timeouti, ponovna prijava žetona |
| `ddee511` | **P4** | poštena ubeseditev percentila, pasovi frekvence, tercil, imenovalec |
| `548854a` | **P5** | migracija `0018`: granti funkcij, `k_reliab()`, prag skupine |
| `2a21b6e` | **P6** | omejitev agregatnih poizvedb, izločitev nesezonskih tipov |
| `abd6713` | — | dokumenti prejšnjih sej (`13`–`17`) |
| `b164272` | **P7** | testi `index.ts` (razdeljen v `handler.ts`), straža 5d, migracija v13→v16, CI |
| `f6310bc` | P7+ | zaprte tri vrzeli pokritosti, ki jih je razkrilo merjenje |

## 2 · Odločitve, ki sem jih sprejel sam (in zakaj)

Te so **že v kodi**. Če se z eno ne strinjaš, jo je treba razveljaviti zavestno.

- **O1 (ubeseditev percentila) = nevtralno.** Naslov je jemal kumulativo in jo ubesedil kot rang
  (»Med prvimi ~90 %« za nekoga med zadnjimi 8 %). Zdaj sta **dve ločeni funkciji**: `seasonPercent`
  (kumulativa, odgovarja na vprašanje o **datumu**) in `seasonRankPercent` (mid-rank, odgovarja na
  vprašanje o **osebi**). Niz: *»Pred tabo je začelo ~X % vrtnarjev«*. Odstotek se uporabi samo,
  kadar je `0 < % < 100`; na robovih prevzame opisni pas (sicer bi zaokroževanje trdilo, da ni
  začel nihče oz. da so začeli vsi).
- **O2 (imenovalec) = največja posamezna sezona.** Brez migracije: oblika krivulje še naprej združuje
  vse pretekle sezone, imenovalec pa je najmočnejši letnik — pošten spodnji rob za število različnih
  ljudi. **Posledica: P4 ni več vezan na prvi tek crona.**
- **k-anonimnost `activity_season` = varianta C** (tvoja izbira): tedenske vrstice se objavijo šele,
  ko skupina preseže `k_reliab` (30). Vrstični prag iz plana bi **pokvaril krivuljo** — klient
  normalizira na prejete vrstice, zato skrite vrstice ne pustijo vrzeli, ampak premaknejo vse
  odstotke.
- **A7 iz pregleda, ki je iz plana izpadel** — zaprt v P7: motor zdaj bere `app_config.engine_enabled`
  (fail-closed) in debug izpis vrta je opt-in (`?debug=1`), ker `pg_net` vsak odgovor shrani v bazo.

## 3 · Odločitve, ki še blokirajo pakete

| # | Vprašanje | Blokira | Moje priporočilo |
|---|---|---|---|
| **O3** | Ločen `kCommunityEnabled` ali en flag + zapis v runbook? | **P9** | ločen flag — en flag danes prižge brezplačne predloge **in** plačljivo Okolico, `kDevPlusStub = true` pa jo podari vsem |
| **O4** | R1 kot samostojno pravilo, ali popravek specifikacije? | **P10** | popravi spec + odstrani mrtvi ključ `suggestions.weather.window_open`; R1 je v kodi ojačevalec, »jutri je suho okno« pa nosilna zgodba v `00-pregled-za-laika.md` — odloči se za eno |
| **O5** | drift tabela `plant_task_rule` na klientu: ven ali ostane? | **P11** | odvisno od roadmapa offline motorja — če ga ni v načrtu, ven (1127 vrstic seeda + sync pot brez bralca) |
| **O6** | `suggestions.community.most_started` — prevesti v opisno? | **P10** | da; je edini niz s socialnim dokazom in gre na **brezplačni** pas na Domov, daleč od pojasnila »nikoli ti ne pove, kaj naj narediš« |

## 4 · Kaj ostane — po vrstnem redu

### 4a · Ostanka P7 (predlagam, da gresta prva)

1. **`fcm_token_service.dart` = 0 % pokritosti, `fcm_handler.dart` ni v poročilu.** To je klientska
   polovica P3 (pot okrevanja žetona). Rabi mock `FirebaseMessaging`: dovoljenje zavrnjeno,
   `onTokenRefresh`, odjava med `await waitForProfile`, dvojni `start()` → ena naročnina.
2. **Prava Supabase poizvedba (`community_providers.dart:21–39`) = 0 %.** Tu živita `order` in
   `limit` iz P6; vsak test zamenja to zaprtje, ker je prav ono testna meja. Možnosti: (a) izloči
   oblikovanje poizvedbe v čisto funkcijo in testiraj njo, (b) integracijski test proti stagingu,
   (c) zapiši kot zavestno vrzel.

### 4b · Paketi iz plana

- **P8** — offline in svežina Okolice (ločitev »ni signala« od »premalo sosedov«, indikator svežine,
  pull-to-refresh). Ni odvisen od nobene odločitve.
- **P9** — flagi in cross-branch navigacija (čaka **O3**). Vsebuje test z **realnim**
  `StatefulShellRoute`; ta vzorec je v tej kodni bazi že enkrat sesul navigator.
- **P10** — jezik, besedila, dokumentacija (čaka **O4**, **O6**). Vključuje: spolno nevtralne nize,
  push telesa iz generatorja v i18n (danes so v **vikanju**, aplikacija je v tikanju),
  anti-steering varovalo čez `suggestions.community.*`, `screen-map.md`, odprti vprašanji #13/#14.
- **P11** — higiena (čaka **O5**): mrtva koda, podvojeni widgeti, `dispose()`, magične vrednosti,
  razhajanja Dart↔Deno v retry/timeout. **Dodaj na seznam:** šest testnih datotek motorja podvaja
  isti `kCfg` literal, `community_frequency_card` veja `freq_low_n` je po P5 verjetno nedosegljiva,
  in trije šibki testi iz plana (`climate_service_test` podvaja produkcijsko DOY formulo,
  `community_repository_test` trdi točno število omrežnih klicev, `plant_task_rules_seed_test` je
  strožji od motorja).
- **P12** — on-device dimni test (zadnji, po vsem ostalem).

### 4c · Znane nepokrite poti (izmerjeno, ne ocenjeno)

`cellWeather` (testi nastavijo `h3_r7 = null`, da se izognejo omrežju) · R6 skozi cel handler ·
`weather.ts` retry lestvica (71 % vrstic) · `dismissedUntil` veja `month_window`/`frost_offset` ·
`errorText`, `missing env` → 500, zunanji `catch` · `plantTaskRuleFromRemote` na klientu ·
migracija `0018` (v repu ni ogrodja za SQL teste).

## 5 · Kar moraš narediti ti (jaz ne morem)

1. **Sonde `tmp/probe_p5.sql`** (read-only, varne proti PROD):
   - **S1** pred `0018` → je problem z granti sploh resničen; **po** njej → potrditev, da so
     `engine_dispatch`/`agg_refresh_all` zaprti, `k_privacy`/`k_reliab` pa **še vedno izvršljiva**.
   - **S3** → dejanska oblika tabel proti `0006`/`0009` (`create table if not exists` je razliko
     lahko že za vedno skril).
   - **S4** → koliko odgovorov edge funkcije hrani `pg_net`.
2. **Aplikacija migracij:** `0017` (še ni nikjer) in `0018`. Obe morata na PROD **pred prižigom**
   nočnega crona. Po `0018` preveri, da branje agregatov z anon ključem še deluje.
3. **On-device** (P12) — samo naprava lahko dokaže, da cross-branch navigacija ne sesuje navigatorja.

## 6 · Delovni dogovor in pasti (prihrani si uro)

- **En paket = en commit**, pred vsakim commitom vprašaj. Po vsakem paketu: `flutter analyze` +
  **cel** `flutter test` + `deno test supabase/functions/`.
- **`deno check` mora teči iz mape `supabase/functions/smart-engine/`** — import map je v njenem
  `deno.json`. Iz korena javi tri lažne napake (`@supabase/supabase-js`, `h3-js`, `jose`).
- **`deno test supabase/functions/` (kot v CI) teče iz korena** in tam npm specifikatorji **niso**
  razrešljivi. Zato `handler.ts` nima npm uvozov — vse, kar jih rabi (supabase client, h3, FCM,
  okolje, ura), je injicirano prek `EngineDeps`. Test, ki bi uvozil `fcm.ts`, bi CI podrl; zato je
  klasifikacija napak v `_shared/fcm_errors.ts` (brez odvisnosti).
- **Testni dvojnik baze:** `supabase/functions/smart-engine/fake_db.ts` — veriženje poizvedb in
  zapisi, ki se dajo trditi (`db.writes`). Uporabljata ga `handler_test.ts` in `housekeep_test.ts`.
- **Pokritost:**
  `cd supabase/functions/smart-engine && deno test --coverage=/tmp/cov . && deno coverage /tmp/cov`
  · `flutter test --coverage` + `python tmp/cov_report.py` in `python tmp/cov_lines.py <pot>`
  (skripti sta v `tmp/`, gitignored — po potrebi ju napiši znova).
- **`git add -A docs` je past** — pobere neverzionirane dokumente prejšnjih sej. Dodajaj eksplicitno.
- **Bash orodje ohrani `cd` med klici.** Po `cd` v podmapo uporabi absolutne poti, sicer
  `flutter analyze` analizira napačno mapo (zgodilo se je).
- **Ne uporabljaj PowerShell here-string (`@'…'@`) v Bash orodju** — `@` znaka pristaneta v commit
  sporočilu. Za večvrstična sporočila `git commit -F - <<'MSG'`.
- **Na produkciji ne brišemo** — tudi v migracijah ne. `0018` zato nesezonskih vrstic ne briše,
  ampak jih pusti neobjavljive.

## 7 · Sklici

- `docs/m11/17-plan-popravkov.md` — plan (paketi, DoD, sonde). §2 tabela odločitev je zdaj delno
  zastarela: O1 in O2 sta razrešena, glej §2 tega dokumenta.
- `tmp/review-m11/` — izvorna poročila pregleda (PM, inženir, tester) + `POVZETEK.md`.
- `docs/deploy-runbook.md` — ledger; `0018` je vpisana kot še ne aplicirana, z opozorilom o
  `k_privacy()`.
- `docs/skupnost-agregacija.md` — §5.4 posodobljen s popravkom praga (varianta C).
- `CLAUDE.md` — izvršljiva pravila kode.

---

## Prompt za novo sejo (prilepi to)

> Nadaljujeva popravke M11 po `docs/m11/17-plan-popravkov.md`. Preberi najprej
> `docs/m11/18-nadaljevanje-prompt.md` — tam je stanje, sprejete odločitve in kaj ostane.
> P1–P7 so narejeni in commitani, testi zeleni (1220 Flutter, 159 Deno).
>
> Nadaljuj po tem vrstnem redu: **ostanka P7** (testi `fcm_token_service`/`fcm_handler`, in odločitev
> o pokritosti prave Supabase poizvedbe), nato **P8** (offline in svežina Okolice), nato **P9–P11**.
> Pri P9/P10/P11 rabim odgovore na **O3, O4, O5, O6** — predlagaj vsako z argumentom in počakaj
> odgovor, razen če je odgovor očiten iz kode.
>
> Delaj kot doslej: en paket = en commit, pred commitom vprašaj, po vsakem paketu cel `flutter test`
> + `deno test supabase/functions/`. Kjer nekaj lahko razrešiš sam in je pravilno, naredi in razloži;
> kjer gre za produktno odločitev, opiši problem, možnosti in priporočilo.
