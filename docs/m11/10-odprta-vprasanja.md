# Poglavje 10 — Odprta vprašanja (edina dovoljena)

> Vse spodaj NI blokada za implementacijo — vsaka točka ima delovni privzetek (že vgrajen v
> poglavja 1–9) in **odločitveno drevo**, kdaj/kako privzetek spremeniti. Vse nastavljivo brez
> deploya (`app_config`).

## 1. Kalibracija pragov motorja (po prvih realnih podatkih)

**Parametri:** cooldowni (R1:3d, R2:30d, R3:5d, R5:10d, R7:5d), dismiss trajanja, uteži ocen,
`emit_threshold=2.0`, obletnično okno ±7 d, `frost_safety_days=7`.
**Odločitveno drevo:** po 4–6 tednih internih testerjev poglej `suggestion` statuse:
- `dismissed / (planned+dismissed) > 60 %` za pravilo → pravilo prepogosto/prezgodaj →
  cooldown ×2 ALI prag +0.5.
- `expired > 70 %` (nihče ne reagira) → sporočilo/čas slaba → preveri uro pošiljanja in copy.
- `planned > 40 %` → pravilo dela; lahko znižaš prag in opazuješ, ali planned delež pade.
Vsi posegi: `app_config.engine`, brez deploya. Meritev = navaden SQL nad `suggestion`.

## 2. Vremenski pragovi (mm dežja, ure suhega, veter)

**Privzetki:** `app_config.weather_thresholds` (02 §G). Negotovo: koliko mm v 24 h res pomeni
»mokro za košnjo« (2.0 mm je konservativen) in ali je `dry_hours_min=24` prestrog za jesen.
**Odločitveno drevo:** dismissi R1 z opombo vremena ali pritožbe testerjev →
primerjaj prage z dejanskim sprejemanjem; popravljaj po enem parametru naenkrat (teden
opazovanja); cilj < 40 % dismiss na R1.

## 3. `drought7d` aproksimacija (R/lawn.water)

**Privzetek:** `recentRainMm72h < 2.0 AND forecastDryHours >= 24` (02 op. 1) — 72 h ni 7 dni.
**Odločitveno drevo:** če lawn.water spamlja po kratkem suhem obdobju → razširi weather_cache
payload s `past_days=7` (Open-Meteo forecast API to podpira do 92 dni; +tovor ~2×) in
implementiraj pravo 7-dnevno vsoto. Odločitev ob kalibraciji #2, ne prej (tovor ni zastonj).

## 4. `climate_bucket` meje pasov + redundanca višinske osi

**Privzetek:** 4 višinski × 6 temperaturnih pasov (07 §7.2).
**Odločitveno drevo:** ob ≥ ~200 registriranih z lokacijo poglej porazdelitev košev
(`select climate_bucket, count(*) from profile group by 1`):
- > 80 % uporabnikov v ≤ 2 koših → pasovi pregrobi za fallback vrednost → drobnejši t-pasovi.
- koši z 1–4 uporabniki sistematično (V2 fallback vedno preskoči climate nivo) → grobji pasovi.
- če se e-os in t-os popolnoma podvajata (vsak e-pas ⊂ en t-pas) → opusti e-os pri NOVIH
  zapisih (stari ostanejo veljavni stringi — bucket je samo ključ).

## 5. Open-Meteo arhiv: 10 let vs 30 let normali

**Privzetek:** 10 let ERA5 (07 §7.1) — manjši tovor, novejša klima (segrevanje!).
**Odločitveno drevo:** če se frost mediane na testnih lokacijah (Ljubljana, Kranjska Gora,
Koper, Dunaj, München) razlikujejo od uradnih agro-koledarjev za > 10 dni → podaljšaj na
20–30 let ali preklopi na p75/mediano kombinacijo. Preveri v M11.3 DoD (testne lokacije so
del unit testov s posnetimi odgovori).

## 6. Frekvenčna kapica: 1/dan vs digest

**Privzetek:** kapica vedno ON, max 1 push/dan (top score), stikalo `frequency_cap` v UI
skrito (06 §6.5). Digest (en povzetek z N predlogi) NI implementiran.
**Odločitveno drevo:** če testerji javljajo »premalo vidim« (pas spregledan) ALI je
`expired` delež visok kljub dobrim pravilom → implementiraj digest push ob 7:00 (naslov
»3 predlogi za tvoj vrt«) kot alternativo; stikalo 22 takrat oživi (single/digest).

## 7. Eligibility X/N/M + K_privacy/K_reliab (V2)

**Privzetki:** X=14 d, N=10 opravil, M=5 dni; K_privacy=5, K_reliab=30 (`app_config`).
**Odločitveno drevo (iz `skupnost-agregacija.md` §0.1/8):** prestroga upravičenost →
`bucket_population` prazen → najprej spusti N na 5; K-jev NE nižaj (K_privacy je
nepogajalski; K_reliab=30 je statistični minimum za ±9 % šum).

## 8. Normalizacija frekvence (`unit`)

**Privzetek:** `per_season` (04 §4.6) — naslov »~2–5× na sezono«.
**Odločitveno drevo:** za visoko-frekvenčna opravila (košnja) je »na sezono« neintuitivno →
ob M11.18 UI validaciji po potrebi dodaj `per_month` izračun (n_events / aktivni meseci
sezone) kot DODATEN stolpec (additive), UI izbere enoto po tipu opravila
(`default_cadence < 30 dni → per_month`).

## 9. Multi-device FCM token

**Privzetek:** `profile.fcm_token`, zadnja naprava zmaga (06 §6.2).
**Odločitveno drevo:** pritožba »na tablici ne dobim« ali telemetrija UNREGISTERED > 10 %/mes
→ tabela `device(id, user_id, fcm_token, platform, last_seen_at)` (additive migracija),
engine pošlje vsem živim tokenom; do takrat ne (YAGNI).

## 10. Skupnostna kalibracija pravil (post-V2 ritem)

**Privzetek:** pravila so statična do prvih dokončanih sezon z gostoto; kalibracijski cevovod
(01 §D točka 3) je ročen/kuratorski.
**Odločitveno drevo:** ko ima ≥ 1 koš `activity_season` z `pooled_total ≥ 30` za tip opravila →
enkrat na sezono primerjaj vrh krivulje z oknom pravila; odstopanje > 2 tedna → popravi okno
(`community-calibrated` source_ref). NIKOLI avtomatsko; NIKOLI pod `K_reliab`. Morebitna
LLM pomoč = samo osnutki za kuratorja (01 §D), nikoli direktno pisanje pravil.

## 11. Razveljavitev trajnega muta (»Ne predlagaj več tega«)

**Privzetek:** MVP brez UI za preklic (dismissed_until='infinity' ostane).
**Odločitveno drevo:** če support/testerji javijo »pomotoma sem utišal« več kot enkrat →
Settings → Obvestila dobi seznam trajnih mutov z gumbom za preklic (bere `suggestion_log`
mirror, preklic = nov klientni kanal — takrat dodaj `suggestion.status='unmuted'` vzorec
ali server endpoint; odločiti ob potrebi, ne prej).

## 12. Kako testirati motor brez realnih uporabnikov

**Plan (ni odprt — zapisan, da se ne izgubi):**
1. **Deterministični Deno testi** (M11.15): sintetičen `UserBundle` + posneti Open-Meteo
   JSON-i; `Clock` ekvivalent = injectan `today` (engine NIKOLI ne kliče `Date.now()`
   direktno v logiki pravil — parameter `runDate`).
2. **Sezonska simulacija:** test, ki `runDate` premika čez 365 dni z fiksno zgodovino in
   preverja, da se vsako pravilo sproži ≤ pričakovano-krat (regresija proti spamu) — izpis
   »koledar predlogov za leto« kot golden file.
3. **Sintetična populacija za V2 (M11.16):** SQL skripta `tmp/seed_synthetic_users.sql`
   (50 uporabnikov, 3 celice, 2 leti zgodovine) → agg funkcije + RLS pragovi preverljivi brez
   ljudi; NE commitati v produkcijski seed.
4. **Dev-only ročni invoke:** `supabase functions invoke smart-engine --body '{"user_ids":[...]}'`
   za tek »zdaj« na lastnem računu (namesto čakanja na 7:00).

## 13. `agg_context` write-once samo app-level (ne DB-vsiljeno)

**Privzetek:** `task.agg_context` je zamrznjen ob `done` na klientu (write-once, ohranjen ob
`↩ Na čaka`), a stolpec je navaden `jsonb` brez CHECK/trigger — invarianta živi samo v
`TasksRepository`. CLAUDE.md sicer želi DB-level invariante.
**Odločitveno drevo:** posnetek konzumira šele V2 agregacija (M11.16, `agg_event`). Ob M11.16,
preden agregati štejejo na ta polja, dodaj `before update` trigger, ki zavrne spremembo
`agg_context`, ko je stara vrednost ne-null (immutable po prvem zapisu) — takrat je tudi
jasno, ali kak migracijski backfill rabi izjemo. Prej ne (en sam pisalec = klient, app-level
guard zadošča za MVP, kjer se posnetek nikamor ne agregira).
