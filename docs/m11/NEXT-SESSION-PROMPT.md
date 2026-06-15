# Naslednja seja — M11.14: E2E preverba motorja na napravi + poliranje

Branch `feat/m11-smart-engine`. Pogovor SL, koda EN. **Pred vsakim commitom vprašaj.**
En korak roadmapa = en commit; korak odkljukaj v `docs/m11/09-koraki.md`.

## Kje sva (stanje 2026-06-15)

- **Faza A–C (M11.1–M11.12) ✅** — shema, klima, seed, FCM, cel motor (signali + R1–R7 +
  dispatch/pg_cron + FCM pošiljanje). Deployano na živ Supabase.
- **Faza D UI ✅ do zdaj:**
  - **M11.13 ✅** — pas pametnih predlogov na Domov (`0eb30ae`/`63d9e3e`/`7f1a3eb`).
  - **M11.13b ✅** — zaslon »Pretekli predlogi« (`c7f39af`) + wireframe (`9f26807`).
    `/suggestions/history`, časovnica po dnevu, status čipi (planned/logged/dismissed/
    muted/missed; `expired`→»Zamujeno«), tap planned+logged→opravilo, vstop iz glave pasu
    (le ko ni prazen) + Nastavitev. Skupni `core/widgets/day_header.dart` +
    `suggestionMessage`/`suggestionSubjectLabel` helperja.
  - **M11.15 ✅** — celovita test suite motorja v CI (`test(engine): …`). GitHub Actions ima
    dva joba: obstoječi `ci` (Flutter) + nov `engine` (`denoland/setup-deno@v2` →
    `deno test supabase/functions/`). 96 Deno testov + Flutter testi predlogov/klime na CI;
    README v `supabase/functions/`. Code+security review čisto (job ostal `ci`, ne `app`, da
    morebiten zahtevan status-check ne osiroti). Lokalno 96/96 zeleno.
- **Testi: Flutter 241/241 + Deno 96/96, `flutter analyze` čist.**
- **👤 ŠE NE:** on-device smoke M11.13b še NI narejen (opcijsko, gl. spodaj).
- **Vrstni red:** M11.14 (ta seja) je edini še odprt korak Faze D; rabi **fizično napravo**.
  Če naprave ni, je smiselno preskočiti na 👤 Play zaprti test ali Fazo E (M11.16+).

## Naloga te seje: M11.14 — E2E motorja na napravi + poliranje

**Vir resnice:** `docs/m11/09-koraki.md` korak M11.14; `docs/m11/00-pregled-za-laika.md` §0.1
(scenarij paradižnik → pikiranje); `docs/m11/03-pravila-r1-r7.md` (cevovod).

### Obseg
Cel krog na **fizični napravi** (SM A536B, USB) brez ročnih popravkov:
1. Vnos zgodovine (npr. paradižnik posajen) → **ročni engine invoke** za dev userja →
   suggestion vrstica pull-ana na napravo → FCM push (ali pull) → **tap** push →
   deep-link highlight kartice na pasu → **Načrtuj** → nastane opravilo → naslednji
   engine tek **NE podvoji** predloga (cooldown/guard).
2. **Poliranje:** uglasitev besedil predlogov (preveri realne nize na napravi),
   disclaimer copy, **Sentry za engine napake** (`console.error` → Sentry stub ali log drain).
3. **Posebej preveri (parkirano):** RenderFlex overflow čip-vrstice na zaslonu zgodovine ob
   **dolgem naslovu** predloga (Sentry TENDASK-6) — trailing `Row` (čip + chevron) v `ListTile`.

### DoD (iz 09-koraki)
- Scenarij §0.1 (paradižnik → pikiranje) izveden **v živo na napravi brez ročnih popravkov**.
- Dnevnik napredka v `docs/roadmap.md` dopolnjen.
- **Commit:** `feat(engine): e2e veriga paradižnika potrjena na napravi + poliranje sporočil`

### Recept za engine invoke (iz prejšnjih sej — preveri, da še velja)
- **`.env` DB geslo je bilo STALE** (pooler psycopg skripte mrtve) → delamo prek PostgREST /
  funkcijskega invoke-a.
- **Legacy `service_role` JWT** (NE maskirani `sb_secret_*`):
  `supabase projects api-keys --project-ref jlmkkeijmmnwkizutvkg -o env | grep '^SUPABASE_SERVICE_ROLE_KEY=' | cut -d= -f2- | tr -d '"\r\n'`
  → `apikey`+`Bearer` za PostgREST IN `functions/v1/smart-engine` (gateway `verify_jwt=true`).
- Vzorec skripte: `tmp/m119_e2e.py` (check|seed|invoke|cleanup, bere `SR_KEY` iz env).
- Dev user: **exogenus@gmail.com** (uid `c85fd203`).
- Drift dump z naprave: `cmd /c "adb exec-out run-as app.tendask cat app_flutter/tendask.db > tmp\device.db"`
  (PowerShell redirect pokvari binarno!).

### Opcijski lead-in: on-device smoke M11.13b
Pred M11.14 lahko narediš hiter vizualni smoke zaslona zgodovine + glave pasu + vstopa iz
Nastavitev. Polno stanje rabi terminalne predloge v lokalni bazi (sicer prazno stanje).
Deploy: 👤 `! deploy.bat hot`.

### Če naprave NI na voljo
M11.15 (CI test suite) je **že narejen** (ta seja). Edina preostala možnost brez naprave je
👤 Play zaprti test (vc4) ali start Faze E (M11.16 — Supabase migracija 0006 V2 agregati,
pure-server korak). M11.14 je nujno na napravi — ne sili E2E brez nje.

## Konvencije / arhitektura (kratko)
- Feature-first: `features/suggestions/{data,application,presentation}`. UI bere SAMO iz
  Riverpod providerjev nad drift; nikoli direktno Supabase. Repo ne vrača `Companion` na meji.
- Komponentni katalog: `EmptyState`, `SectionLabel`, `SheetHandle`, `DayHeader`,
  `showConfirmDialog`, `showTopToast` — uporabi obstoječe.
- Datumi prek `core/date_format.dart`; katalog labels prek `catalogLabel()`.
- i18n: vsi nizi prek `t.*`; po dodajanju ključev poženi **`dart run slang`** (ločen CLI!).

## Gotchas (naučeno)
- **UI: NIKOLI beseda »motor«** → »Tendask«/»predlogi« (gl. memory feedback-ui-no-engine-word).
- **Widget test + drift:** `repo.watch*().first` (STREAM) VISI pod `testWidgets` bindingom →
  beri z enkratnim `.get()` (Future) + filtriraj/sortiraj v Dartu. Za UI override providerje
  s `Stream.value([...])`, nikoli živ drift watch (viseč timer ob teardownu).
- **`flutter test` izpis** je medpomnjen prek `Select-Object` (vidiš šele ob koncu); uporabi
  `Start-Process … -RedirectStandardOutput tmp\out.txt` + `WaitForExit(ms)` s trdo omejitvijo,
  ALI `Tee-Object`. Izpis je **UTF-16** (razmaknjeni znaki) — beri prek PowerShell `Get-Content`.
- **Viseči testi:** ubij `flutter_tester`/`dart`/`dartaotruntime`
  (`Get-Process -Name flutter_tester,dart,dartaotruntime | Stop-Process -Force`) in zaženi znova.
- **Branch ↔ main na telefonu:** med menjavo `adb uninstall app.tendask` (drift downgrade pusti
  staro verzijo → duplicate-column crash). M11.13b ne dodaja sheme → ta korak sam ne tvega.
- **Commit message:** zapiši v `tmp/commit_msg.txt` + `git commit -F` (here-string se v tem
  harnessu pokvari). Po build_runner pred `git add` preveri riverpod hash churn v `.g.dart`
  (`git checkout --` nepovezane). M11.13b je uporabil ROČNE StreamProviderje → brez churna.
- **Wireframe localhost:** `python -m http.server 8099 --bind 127.0.0.1` iz `docs/wireframes/`
  (Bash background) → `http://127.0.0.1:8099/<ime>.html`.

## Parkirano (NE pozabi)
- FR-8 (vreme na centroid `h3_r7` namesto surovih koordinat — `docs/roadmap.md`).
- Insert-if-missing LWW race (`setLang`/`setNotificationSettings`/`saveGardenLocation`).
- Sentry TENDASK-6 (RenderFlex overflow 9px — preveri ob M11.14, gl. zgoraj).
- 👤 Play: upload vc4 (`1.0.0+4` zgrajen iz `main`) v Closed testing + ≥12 testerjev × 14 dni.

## Po M11.14
Faza D je s tem cela. Naprej: Faza E (V2 skupnost, M11.16–M11.21) ALI preklop na 👤 Play
zaprti test (≥12 testerjev × 14 dni). Priporočen vrstni red iz roadmapa: D → premor/validacija
s testerji → E.
