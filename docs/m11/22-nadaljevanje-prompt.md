# M11 — predaja seje (Paketa 1 in 2 zaključena, na vrsti P10)

> ⚠️ **ZASTARELO od 2026-07-28.** Paket 3 (§4 tega dokumenta) je narejen.
> Veljavna vstopna točka je **`23-nadaljevanje-prompt.md`**.

> **Datum:** 2026-07-28 · veja `feat/m11-smart-engine` · **nič pushano, produkcija nedotaknjena**
> **Vstopna točka za novo sejo.** `18-`, `20-` in `21-nadaljevanje-prompt.md` so zastareli.
> Beri tega, nato `19-najdbe-med-izvedbo.md` (pregled na vrhu) in `17-plan-popravkov.md` §3.

---

## 0 · Stanje v eni vrstici

Paket 1 (**N8** simulacija + **O7** odmik) in Paket 2 (**N14, N1, N9, N15** podatki) sta
commitana in preverjena · **1299 Flutter + 170 Deno zelenih**, analyze čist ·
migraciji `0020`/`0021` aplicirani **na stagingu**, prod nedotaknjen.

## 1 · Commiti te seje

| Hash | Kaj |
|---|---|
| `f3e4bd0` | sezonska simulacija čez 365 dni (N8) — meritev, ki je našla N25 |
| `c7b7033` | odmik ob ignoriranju predloga (**O7**, zapre N25) |
| `b837c5f` | cona + zamrznjen posnetek agregacije (N14, N1, N9, N15) |

## 2 · Kaj je bilo izmerjeno (in zakaj to spremeni zaupanje v motor)

Sezonska simulacija (`season_sim_test.ts`) požene **pravi handler čez 365 zaporednih dni na
eni shrambi**. Bistveno je, da stanje teče naprej: `suggestion_log.last_suggested_at`,
`dismissed_until`, žive `suggestion` vrstice in `engine_run.last_push_date` se pišejo na dan N
in berejo na dan N+1. Zato `SimDb` in ne `FakeDb` — zanka nad `FakeDb` bi izmerila, kolikokrat
se pravilo *lahko* sproži, in bila zelena.

| | pred O7 | po O7 |
|---|---|---|
| kartice na leto | 156 | **52** |
| pushi na leto | 129 | **38** |
| R3 pushi | 95 (74 %) | **8** |
| R5 pushi | 31 od 129 | **25 od 38** |
| najglasnejša straža | 61× | **4×** |

**Agronomska pravila so bila mirna že prej** (R5 1–4× na leto, R6 ×2, R2 ×1) — to je prvi
resnični podatek, da motor dela, kot je zamišljen. Hrup je prihajal izključno iz R3.
Po O7 se je razmerje pushov obrnilo: koristno pravilo ne tekmuje več s hrupnim za isti kanal.

Uporabnik, ki **ukrepa**, je dobil 39 kartic / 32 pushov že prej — motor je bil torej štirikrat
glasnejši do tistega, ki je že pokazal, da tega noče. To je bil argument za O7.

## 3 · Sprejeta odločitev O7 (da je ne bo kdo »popravil«)

Ignoriranje odslej nekaj stane: `[1, 1, 2, 4]`-kratnik lastnega cooldowna pravila po `n`
zaporednih ignoriranjih, po četrtem **tiho do konca sezone**. Vsako dejanje
(`planned`/`logged`/`dismissed`) niz prekine.

Tri stvari, ki jih je treba razumeti, preden se tega kdo dotakne:

- **Prvo ignoriranje je zastonj namenoma.** Kdor je bil teden dni odsoten, ne sme dobiti
  občutka, da se je funkcija pokvarila.
- **Vir ni nov stolpec.** Kartica, ki gre `new → expired` brez dotika, je **že** zapis
  ignoriranja. Niz se izpelje iz `suggestion` vrstic (`housekeep.ts` `ignoredStreaks`), ne iz
  števca — zato ni resetne logike, ki bi se lahko pokvarila: »ukrepal« je preprosto najnovejša
  vrstica tega ključa.
- **Niz je omejen na koledarsko sezono**, da se utišano pravilo naslednje leto samo od sebe
  spet oglasi.

Stranski učinek, ki je pravilen: ko R3 za košnjo utihne, se pojavi `R2:mow` (obletnica, svoj
guard key, cooldown 30 dni → 2× na leto). Blažja oblika istega opomina, ne luknja.

---

## 4 · Delovni nalog: Paket 3 — P10, besedilo, ki laže

Vse spodnje je **zapisano ali izmerjeno**, nič ni odprto za ugibanje. Vrstni red je
priporočen: N13 in O6 sta odločitvi o vsebini, ostalo je mehanika.

### N13 · Pet mest obljublja »kmalu (V2)«, medtem ko funkcija dela

Mesta: `onboarding_screen.dart` (`nearby_body`, `soon_badge`), `location_screen.dart`
(`location.why`), `notification_settings_screen.dart` (`type_weather_sub`, `type_community_sub`).
**Nobeno ni vezano na noben flag.** Pri obvestilih je `onChanged` pravilno vezan na
`kSuggestionsEnabled`, vezan ni **podnapis** — stikalo se da prestaviti, pod njim pa piše, da
funkcije še ni.

Popravek **ni prevod, ampak odločitev, kaj naj piše, ko je flag prižgan** — dva niza na mesto,
izbrana po flagu (`kSuggestionsEnabled` oz. `kCommunityEnabled`, ločena od O3). Uvod in zaslon
lokacije sta hujša od obvestil: ob prižigu bo vsak nov uporabnik v prvi minuti dvakrat prebral,
da je Okolica »kmalu«, in jo takoj zatem našel v petem zavihku.

### N17 · »Kje si ti« krivi okolico za uporabnikovo prazno zgodovino

`community_providers.dart` zlije dva vzroka v en prazen seznam:
`if (mine.isEmpty || buckets.isEmpty) return const []`, zaslon pa ima za oba **en sam** niz
`empty_standing` (»Za nobeno opravilo še ni dovolj vrtnarjev v okolici«). Ob 40 sosedih to ni
zavajajoče, ampak **izmerljivo napačno** — sosednji zavihek »Ta teden« ob istem času izriše
vrstice iz istih podatkov.

Past je širša, kot je videti: uporabnik s **tremi dokončanimi zalivanji** je vseeno dobil isti
niz, ker `water` ni sezonski tip in ga filter odvrže. Torej ne zadošča tretja veja
»najprej opravi kakšno opravilo« — laže tudi tistemu, ki **ima** zgodovino, le napačne vrste.
Rabiš tri stanja: premalo sosedov · nimam sezonske zgodovine · nimam zgodovine sploh.

### N20 · Dvojna pika — **obseg je bil v dnevniku precenjen, popravljeno**

Preverjeno v kodi 2026-07-28, da naslednja seja ne predela 153 nizov brez potrebe:

- **Resnično in videno:** `formatDm` (`date_format.dart`) vrne `1. 6.` s končno piko;
  `community_timing_card.dart` ga vloži v `community.detail.peak_weeks` (`$to.`) → **`1. 6..`**
  Prizadeti so nizi, ki jih polni **`formatDm`**.
- **Ni napaka:** ~51 teles predlogov, ki se končajo z `{window_end_date}.`, polni
  `suggestion_text.dart` prek **`formatDmy`** → `1. 6. 2026` (brez končne pike), torej
  `1. 6. 2026.` — ena pika, pravilno. Prvotni zapis N20 je to napačno pripisal.
- **Resnično in ločeno:** `fillTemplate` manjkajoč parameter nadomesti s praznim nizom, zato
  **5 teles** z izbirnim `{frost_date}` konča kot »… ko mine pozeba — **okoli .**«. Motor
  `frost_date` pošlje samo pri `frost_gate && lastFrostDate != null`, torej se to res zgodi.

Dva popravka, ne eden. Pravilo naj bo eno: **datum brez končne pike, ali predloge brez nje —
nikoli oboje.**

### N21 · `2–2×`, ko sta kvartila enaka

`community_frequency_card.dart` izriše `$from–$to×` brez veje za `from == to`. Ni redek rob:
ravno pri **ustaljenem** opravilu sta p25 in p75 enaka, torej se pokaže pri najbolj tipičnem
vzorcu. Ena veja → `2×`.

### O4 · R1 ostane ojačevalec (sprejeto)

Mrtvi ključ `suggestions.weather.window_open` **ven** iz i18n (`sl`/`en`/`de`) in iz generatorja;
kartica namesto tega dobi **pripono**, ko je `dry_window` postavljen — motor parameter že pošilja
(N4), zdaj dobi bralca. Popravi tudi `03-pravila-r1-r7.md §R1` in `00-pregled-za-laika.md`, ki
R1 opisujeta kot samostojno pravilo.

### O6 · Opisno, brez odstotka (sprejeto)

`suggestions.community.most_started` → »Večina vrtnarjev v tvoji okolici je to letos že začela.«
Anti-steering varovalo razširi na `suggestions.community.*`. Razlog: P4 je isto uokvirjanje
odstranil s plačljivih kartic, brezplačni pas ga ne sme vrniti skozi zadnja vrata — in v prvi
sezoni se delež itak še premika (N24).

### Še v P10

`docs/screen-map.md` uskladi z dejanskim stanjem.

**DoD paketa:** i18n testi zeleni v vseh treh jezikih · anti-steering varovalo pokriva
`suggestions.community.*` · vsak popravek ima test, ki bi napako ujel · `flutter analyze` +
cel `flutter test` + `deno test supabase/functions/`.

---

## 5 · Kar ostane za tem

- **Paket 4 · P11 higiena:** **O5** — `plant_task_rule` s klienta ven (seed + catalog-sync pot
  + drift tabela). **Pozor:** `tool/gen_rules_sql.dart` in novi `tool/gen_engine_fixture.dart`
  bereta `lib/data/seed/plant_task_rules_seed.dart`, in `supabase/seed/plant_task_rules.sql` +
  `supabase/functions/smart-engine/testdata/catalog_fixture.ts` sta iz njega generirana s
  parity testoma. O5 pomeni »ven iz aplikacije« (APK, drift, sync), **ne** »zbriši vir
  generatorja« — sicer ostaneta strežniška pravila brez izvora. Predlog: seed **preseli** iz
  `lib/` v build-time lokacijo, drift tabelo in sync pot pa odstrani. · **N2** —
  `communityWeekly` brez testa.
- **Paket 5 · dokončaj test na napravi:** offline stanja iz P8 · polna matrika sl/en/de ×
  1,0/1,3 po vseh M11 zaslonih (**N23**: matrika riše Domov z `weather: null`, zato realnih
  vremenskih nizov ne vidi — to je strukturna slepa pega, ne pozabi je) · »Pretekli predlogi« ·
  stikali obvestil · `band_max_active` (rabiš ≥4 hkratne predloge).
- **Pred prižigom Okolice:** spodnja vrstica pri petih zavihkih (R4) **in N23** ·
  `kDevPlusStub = false`.
- **Pred `db push` na prod:** sonda `supabase/probe/m11_shape.sql` + diff proti stagingu, in
  **nova** `supabase/probe/agg_context_invariants.sql` (teče v `rollback`, varna tudi na prod).
- **Odprto, ni dolg:** strežniški backfill cone. Po popravku N14 **ni več nujen** — prvi zagon
  popravljenega builda cono napolni sam. Ostaja možen (`h3_r7` → centroid → cona) kot ločena
  odločitev.

## 6 · Česa NE zapiraj

**N5, N6** (staging, zapisano v runbooku) · **N10** (zabeležena odložitev) · **N24** (po
zasnovi) · ostanek **N22** (odločitev o zasebnosti, ne popravek). Te so **sprejete**, ne dolg —
razlogi so pri vsaki zapisani. Če jih kdo »popravi«, je to regresija.

Enako velja za **O7**: lestvica `[1,1,2,4]` in sezonski obseg niza sta odločitev, ne naključje.

## 7 · Kako testirati na napravi

```bash
# 1) pragovi / velikost soseske
wsl -e bash -lc "cat .../supabase/seed/staging_test_data.sql | docker exec -i supabase-db psql -v ON_ERROR_STOP=1 -U postgres -d postgres"

# 2) po spremembi podatkov zadošča poteg v aplikaciji (N19 popravljen v 9fb8d69).
#    pm clear rabiš le za onboarding od začetka.
adb shell pm clear app.tendask && adb shell monkey -p app.tendask -c android.intent.category.LAUNCHER 1

# 3) prijava (koda iz Mailpita)
powershell -ExecutionPolicy Bypass -File tool\adb_run.ps1 -Steps tmp\scenarios\otp_request.txt
powershell -ExecutionPolicy Bypass -File tool\adb_run.ps1 -Steps tmp\scenarios\prag_obe_kohorti.txt -Vars OTP=123456,TAG=15_test

# 4) migracije na staging + preverba invariant
wsl -e bash -lc "tendask migrate"
wsl -e bash -lc "cat .../supabase/probe/agg_context_invariants.sql | docker exec -i supabase-db psql -v ON_ERROR_STOP=1 -U postgres -d postgres"
```

Runner: `-Steps <pot>`, `-Vars A=1,B=2` (**z vejico**), korak `shot <ime>` shrani
`tmp/shots/<ime>.png`. Scenariji v `tmp/scenarios/` (gitignore).

### Pasti, ki so stale časa

- **Vnos OTP se pripne** k stari kodi — pred vnosom pobriši polje.
- **Poteg za osvežitev z `y=700` odpre obvestilno vrstico** — začni pri `y=900`.
- **Ročni GPS takoj po dodelitvi dovoljenja tiho ne shrani** — drugi pritisk deluje.
- **Račun `gorazd@spletnakoda.si` je `provider=email`** (OTP dela); `exogenus@gmail.com` je
  Google — OTP prijava nanj bi tvegala drugo identiteto.
- **320 dp** = `adb shell wm density 540`, **360 dp** = `480`; nazaj `wm density reset`.
- **`deno fmt` razsuje generirani `catalog_fixture.ts`** (in prepiše EOL v datotekah, ki jih
  nisi spreminjal). CI ga ne poganja — ne poganjaj ga čez `testdata/`.

## 8 · Delovni dogovor

En paket = en commit · **pred commitom vprašaj** · po vsakem paketu cel `flutter test` +
`deno test supabase/functions/` + `flutter analyze` · vsako najdbo vpiši v
`19-najdbe-med-izvedbo.md` **takoj ob odkritju**, ne v povzetek · postavko odkljukaj šele, ko
obstaja **artefakt**, ki to dokazuje (test, ki pade brez popravka; sonda; posnetek z naprave).

## 9 · Sklici

`19-najdbe-med-izvedbo.md` (**beri prvi**) · `17-plan-popravkov.md` §3 (P10, P11) ·
`03-pravila-r1-r7.md` (§R3 nosi zdaj tudi opis O7) · `docs/deploy-runbook.md` ·
`docs/cookbook.md` · `docs/prelomi-besed.md` · `CLAUDE.md`
