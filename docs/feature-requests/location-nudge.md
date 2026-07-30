# FR-23: Poziv za lokacijo — push obvestilo + razlagalni list

- **Status:** predlog (raziskava + odločitve pred gradnjo), neimplementirano
- **Datum:** 2026-07-29
- **Cilj:** doseči 52 uporabnikov brez lokacije s push obvestilom, jim pokazati, kaj
  s tem izgubijo in česa ne shranjujemo — z evidenco, kdaj smemo spet
- **Področja:** lokacija (zaslon 16), FCM (M11), obvestila (M8), Domov, zasebnost
- **Povezave:** [FR-22](location-adoption.md) (✅ narejen: brez lokacije na Domov ni vremena, ampak
  kartica s povezavo), [FR-16](re-engagement-nudge.md)
  (lokalni nudge — deli isti prostor), `docs/m11/06-fcm.md`, `docs/koncept.md`
  §"Vodenje proti motečnosti"

---

## 1. Izmerjeno stanje (PROD, 29. 7. 2026)

Read-only sonda `tmp/probe_location_nudge.py` (samo agregati, nobene vrstice po uporabniku):

| Meritev | Vrednost |
|---|---|
| profilov skupaj | **95** |
| brez `h3_r5` | **52 (55 %)** |
| novih v 7 dneh: brez / s celico | **16 / 7** — delež se ne popravlja |
| med 52: ima rastlino / območje nad privzetim / ≥1 opravilo | 20 / 13 / 17 |
| med 52: ima zapisane `notification_settings` | **1** |

> ⚠️ **Najdba 29. 7. 2026: »95 profilov« ni »95 uporabnikov«.** Vrstica v `profile` ne nastane ob
> registraciji — ni triggerja na `auth.users`, profil se ustvari **lazy**, ob prvem zapisu iz aplikacije
> (nastavitev lokacije, sprememba jezika, zaslon 22, ali adopt privzetega vrta ob prijavi). Avtenticiran
> uporabnik, ki ne stori nič od tega, **nima vrstice** — in je zato v vseh številkah zgoraj nevidenen.
> Posledice za ta FR: (1) 52 je **spodnja meja**, ne število; (2) izbor prejemnikov `where h3_r5 is null`
> teh uporabnikov ne najde (§4.1); (3) `fcm_token` živi na `profile`, torej brez vrstice ni tokena in jih
> push ne more doseči. FR-22 to ne prizadene — klient bere lokalno in ob manjkajoči vrstici pokaže poziv.

Niso mrtvi profili — onboarding so prehodili, lokacijo preskočili (FR-22 §1). In: dovoljenje
za obvestila aplikacija zahteva **šele ob prvem opomniku na opravilo** (`entry_screen.dart:367`,
`reminder_step.dart:85`) ali v zaslonu 22, kjer je bil eden od 52. Predpostavi torej, da
**večina te populacije danes ne more prejeti nobenega obvestila.**

## 2. Veriga do prvega pusha

Push je cilj tega FR-ja. Da prispe, mora zdržati vseh šest členov:

| # | Člen | Stanje danes | Kdo ga odklene |
|---|---|---|---|
| 1 | FCM v izdaji (`firebase_core`, `firebase_messaging`, `google-services.json`) | samo na `feat/m11-smart-engine`; v `main` ga ni | merge M11 v main |
| 2 | `profile.fcm_token` na PROD | **stolpca ni** — migracije 0006+ niso aplicirane | `supabase db push` |
| 3 | Uporabnik namesti izdajo | Play auto-update, brez njegovega dejanja | — |
| 4 | Uporabnik app **odpre** | token se registrira ob zagonu (`main.dart:162`) | prvo odprtje |
| 5 | Dovoljenje `POST_NOTIFICATIONS` | večina ga nima (§1) | priming ob odprtju |
| 6 | Strežniška pot za pošiljanje | obstaja samo za predloge motorja, ki je temen | ta FR |

Iz členov 4–5 sledi edina strukturna omejitev, ki je ne moreva zaobiti:

> **Prvi stik mora biti v aplikaciji.** Token in dovoljenje nastaneta šele ob odprtju —
> torej uporabnika najprej ujameva in-app, push pa je **druga priložnost**: pride dneve
> pozneje, ko app že nekaj časa ni odprl.

To ni argument proti pushu, je njegov urnik. Kdor po posodobitvi app odpre in lokacije ne
nastavi, je natanko tisti, ki ga čez teden dni pošteno pokličeš nazaj.

## 3. Rešitev v dveh potezah

### 3.1 Poteza A — razlagalni list ob odprtju (in-app)

Modalni bottom sheet po vzorcu `notification_priming_sheet.dart`:

- **3–4 vrstice koristi** — samo tiste, ki so v tej izdaji res prižgane (§6).
- **Zasebnostna vrstica, vidna brez tapa:** shranimo samo grobo celico H3 (r5 ≈ 250 km²),
  koordinate ostanejo na napravi.
- **Tri poteze:** »Uporabi mojo lokacijo« (GPS) · »Vpiši kraj« (`/location`) · »Kasneje«.
- Ob »Kasneje« **v isti seji ne prosi še za obvestila** — dve prošnji zapored nista poziv.
  Priming za obvestila ostane vezan na svoj obstoječi sprožilec.

**Sprožilec:** ob odprtju Domov, ne v onboardingu in ne v prvi seji po posodobitvi.

### 3.2 Poteza B — push obvestilo (dneve pozneje)

Za vsakogar, ki je po A ostal brez celice **in** ima token: en push, ~5–10 dni pozneje.
Tap odpre list iz 3.1 (ne naravnost obrazca — obvestilo mora pojasniti, preden pošlje
tipkat).

**Kar je za to treba dograditi na obeh straneh:**

| Stran | Kaj | Zakaj ne gre z obstoječim |
|---|---|---|
| klient | ločena zastavica za FCM (npr. `kPushEnabled`) | danes je **ves** FCM pod `kSuggestionsEnabled` (`main.dart:95,162,206`) — prižig bi prižgal tudi pas predlogov in temen motor |
| klient | routing za `type: 'location_nudge'` | `suggestionIdOf()` sprejme samo `type == 'suggestion'` in vse drugo tiho spusti (`fcm_handler.dart:103`) |
| klient | lasten kanal (npr. `location_hint`) | manifest privzeto usmerja na kanal `suggestions` — lokacijski poziv pod oznako »Predlogi« je napačna etiketa; payload mora nositi `android_channel_id` |
| strežnik | izbor prejemnikov + pošiljanje | `engine_dispatch()` je vezan na `app_config.engine_enabled` (temen) in pošilja samo top predlog motorja |
| strežnik | evidenca poslanega (§4) | brez nje strežnik ne ve, kdaj sme spet |

**Kje naj push nastane:** ločen cron + majhna funkcija, **ne** razširitev motorja. Motor je
temen in ga ta FR ne sme prižgati; njegov cevovod (signali, pravila, `suggestion` vrstica)
za to sporočilo ni potreben. Ponovno uporabi le `_shared/fcm.ts` (pošiljanje + obravnava
`UNREGISTERED`).

## 4. Evidenca: komu, kdaj, kolikokrat

Danes je ni nikjer. Za push je **obvezna in strežniška** — kar ve samo naprava, strežniku
ob izbiri prejemnikov ne pomaga.

### 4.1 Strežnik (za push)

Vzorec je `engine_run` (`last_push_date`, `push_rejected_at`): stolpca, ne tabela dogodkov.
Additive-only, nullable:

```sql
alter table profile
  add column if not exists location_nudge_sent_at timestamptz,
  add column if not exists location_nudge_count   int not null default 0;
```

Izbor prejemnikov je nato ena poizvedba:

```sql
select user_id from profile
where h3_r5 is null
  and fcm_token is not null
  and location_nudge_count < 2
  and coalesce(location_nudge_sent_at, '-infinity') < now() - interval '21 days';
```

**Ta poizvedba ne vidi uporabnikov brez vrstice v `profile`** (§1). Ker pogoj `fcm_token is not null`
tako ali tako zahteva obstoječo vrstico, push jih ne more doseči — vrzel torej ni v poizvedbi, ampak v
tem, da vrstica nikoli ne nastane. Odločitev pred gradnjo (§10.6): ali profil ustvariti ob registraciji
(trigger na `auth.users` + backfill obstoječih), ali sprejeti, da ta populacija ostane dosegljiva samo
prek FR-22 na Domov.

Pravilo lastništva: **strežnik piše, klient bere.** Če bi oba pisala, se LWW sync spopade
sam s seboj. Ob `UNREGISTERED` odgovoru FCM velja isto kot v motorju: token ponulli, ne
poskušaj znova (`handler.ts:276`).

### 4.2 Naprava (za list)

`local_flag` prek `LocalPrefsRepository` — tabela obstaja in njen komentar to napoveduje:
*»later notification priming / **location prompt**«* (`sync_tables.dart:22`).

| Ključ | Pomen |
|---|---|
| `location_nudge_shown_count` | koliko prikazov lista je uporabnik videl |
| `location_nudge_last_shown` | ISO 8601 UTC — od tod presledek |
| `location_nudge_opt_out` | »ne sprašuj več«, trajno spoštovano (velja tudi za push) |

Kaj tak zapis **ni**: odporen na odjavo (`clearUserData()` pobriše `local_flag` v celoti,
`app_database.dart:76`) in ne velja med napravami. Za goste je edina evidenca, ki obstaja —
push jih ne doseže nikoli (token zahteva sejo, `fcm_token_service.dart:49`).

## 5. Anti-spam pravila

1. **Skupaj največ 2 poziva** (list + push štejeta v isto kvoto), presledek **≥ 21 dni**,
   nato tišina — trajno.
2. **Push nikoli prej kot 5 dni** po prikazu lista. Prej je isti poziv dvakrat.
3. **Tihe ure 22–07**; termin ~17:00 lokalno (`kJournalNudgeHour`).
4. **Nikoli isti dan kot opomnik na opravilo ali journal nudge.** Vzorec za izogib dnevom
   že obstaja (`JournalNudgeCoordinator._taskReminderDays`).
5. **Prednost pred journal nudge.** 35 od 52 brez lokacije ni vneslo nobenega opravila —
   to je isti človek, ki ga cilja FR-16. Brez tega pravila dobi dve obvestili v tednu.
   Predlog: dokler lokacije ni, gre prvi lokacijski poziv, journal nudge se prestavi.
6. **Trdi opt-out** v listu (na drugem prikazu) in v zaslonu 22; spoštovan tudi strežniško.
7. **Po `clearGardenLocation` se serija ne začne znova** — uporabnik je pravkar sam izbral
   stanje »brez lokacije«.
8. **Nič ob prvem zagonu po posodobitvi.** Poziv takoj po updatu bere kot »app me je ujela«.

## 6. Kaj smemo obljubiti

Koristi so odvisne od tega, kaj je v izdaji res prižgano:

| Korist | Pogojena z | Danes? |
|---|---|---|
| vreme za tvoj kraj (ne za Ljubljano) | nič — dela | **da** |
| pravi čas setve po tvoji klimi | `climate_profile`, ki nastane le ob `h3_r7 != null` (m11/07) | z M11 |
| opozorilo pred slano / v suši | pravili R7/R5 motorja | ob `kSuggestionsEnabled` |
| kaj delajo vrtnarji v tvoji okolici | kohorta po celici | ob `kCommunityEnabled` |

**Pravilo:** seznam koristi se gradi iz istih zastavic, ki krmilijo funkcije. Obljuba
funkcije, ki v izdaji spi, je enaka laž kot ljubljansko vreme brez oznake — in ravno to ta
FR popravlja.

Zasebnostni stavek (predlog, sl): »Shranimo samo grobo celico (≈ 250 km²) — točna lokacija
ostane na tvoji napravi in je nikoli ne pošljemo.« en/de ob implementaciji prek `dart run slang`.

## 7. Robni primeri

- **Gost** (`kLocalUserId`): samo list; push ga ne doseže nikoli.
- **Brez dovoljenja za obvestila:** samo list. Push tiho odpade, brez nadomestne poti.
- **Offline:** GPS dela, iskanje kraja ne (geocoding). Zaslon 16 to že obravnava — ne
  podvajaj obravnave napak.
- **Lokacija nastavljena, ko je push že v vrsti:** izbor teče ob pošiljanju, ne vnaprej;
  `h3_r5 is null` v poizvedbi to reši samo od sebe.
- **Uporabnik zavrne GPS:** list ostane odprt na »Vpiši kraj«, brez ponovnega sistemskega poziva.
- **Layout:** dolga nemščina + text-scale 1,3 → list mora ovijati; vnos v `test/layout/`.

## 8. Obseg

**V obsegu:** list + sprožilec + lokalna evidenca · migracija iz §4.1 · zastavica `kPushEnabled`
· routing za `location_nudge` · kanal `location_hint` · strežniška funkcija + cron · i18n ·
unit testi (izbor prejemnikov, kapica, sprožilec prek `Clock`) · layout matrika.

**Predpogoji (nista del tega FR-ja):** merge M11 v `main`, `supabase db push` migracij 0006+.

**Izven obsega:** pas na Domov (FR-22), obrat hierarhije gumbov na zaslonu 16, prižig motorja.

## 9. Merila

| Metrika | Izhodišče (29. 7.) | Cilj |
|---|---|---|
| **Primarna:** delež profilov z `h3_r5` | 45 % (43/95) | ≥ 60 % v 30 dneh |
| delež novih profilov z `h3_r5` (7-dnevna kohorta) | 30 % (7/23) | ≥ 60 % |
| doseg pusha: profili s `fcm_token` med brezcelnimi | 0 | izmeri 14 dni po izdaji |
| **Varovalo:** profili, ki lokacijo počistijo | ~0 | ostane ~0 |
| **Varovalo:** izklopi obvestil po uvedbi | izmeri ob izdaji | ne naraste |

Merjenje: ista sonda, pognana pred izdajo in 30 dni po njej. FR-14 (analitika) ni pogoj.

**Ločevanje od FR-22 ni pogoj** (odločeno 30. 7.): šteje rast deleža uporabnikov z lokacijo, ne
pripis učinka posameznemu popravku. Vrstni red izdaje je torej prost.

## 10. Odprta vprašanja (odločiti pred gradnjo)

1. **Ali `kPushEnabled` res ločiti od `kSuggestionsEnabled`?** Alternativa je počakati na
   prižig motorja in push obesiti nanj — ceneje, a lokacijski poziv postane talec M11.
2. **Ime kanala** (`location_hint` vs skupen »namigi« kanal za vse ne-opomniške nudge):
   Android imena kanala po nastanku ne da preimenovati (`notification_service.dart:17`) —
   enosmerna odločitev.
3. **Ali push potrebuje svoj opt-in ključ** v `notification_settings`, ali šteje kot
   produktno obvestilo pod obstoječim dovoljenjem OS? `weather_hints` ni pravo mesto
   (privzeto false in pomeni predloge motorja).
4. **Sprožilec lista:** ≥ 3 dni + ≥ 1 vnos, ali preprosto 3. odprtje Domov? Prvo je
   pomenljivejše, drugo se lažje testira.
5. **Ton drugega poziva:** enak kot prvi, ali krajši? Kar koli, kar šteje čas ali očita, je
   izven pravil (FR-16 §3.8).
6. **Ali profil ustvariti ob registraciji** (§1)? Danes nastane lazy, ob prvem zapisu. Možnosti:
   (a) trigger `on auth.users insert → insert into profile(user_id)` + enkraten backfill — additive,
   `default_garden_seeded` ima `not null default false`, zato reconcile deluje nespremenjeno;
   (b) `ensureProfile()` na klientu ob prijavi — v duhu offline-first, a doseže le tiste, ki app odprejo,
   in obstoječih ne popravi; (c) pustiti tako in sprejeti, da je ta populacija dosegljiva samo prek FR-22.
   Vpliva tudi na analitiko: vsi odstotki v `docs/analitika-geo.md` so »od tistih, ki imajo profil«.
