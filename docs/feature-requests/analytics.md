# FR: Analitika & metrike (interna BI + javne statistike)

- **Status:** predlog (feature request), čaka odločitev o obsegu
- **Datum:** 2026-06-22
- **Avtor:** Gorazd
- **Področja:** Supabase shema, Firebase, tendask.app (web), GDPR
- **Povezave:** [`docs/koncept.md`](../koncept.md), [`docs/tech-stack.md`](../tech-stack.md), [`docs/roadmap.md`](../roadmap.md), [`CLAUDE.md`](../../CLAUDE.md) (»Sync, čas in shema«, »Zasebnost po zasnovi«)

---

## 1. Povzetek (TL;DR)

Želiva interne in (delno) javne statistike o uporabi Tendaska. Trenutna shema je **odlična za sync, šibka za analitiko**, iz dveh strukturnih razlogov:

1. **Gostje so nevidni.** App teče 100 % lokalno dokler se uporabnik ne prijavi (email/Google). Brez prijave = **nič podatkov v oblaku**. Vse Supabase metrike pokrivajo samo prijavljene.
2. **Shema je state-based (LWW upsert).** Vsak sync prepiše staro stanje → **ni zgodovine dogodkov**. Iz trenutnega posnetka ne moreš rekonstruirati funnela, retencije, časa-do-aktivacije.

**Priporočeni razrez (dva tira, ne eden):**

- **Vedenjska analitika (installi, app-open, DAU/retention, funnel, verzija/OS, tudi gostje) → Firebase Analytics / PostHog.** Brez dotika sync sheme, zastonj, pokrije goste.
- **Vsebinska analitika (rastline, taski, regije, zaključenost) → Supabase SQL + Metabase**, osvežitev ~1 h.
- **Majhen additive poseg `0006`** (`created_at`, `server_inserted_at`) odklene creation-time + kohorte za prijavljene — to je edina stvar, ki jo je vredno narediti **takoj**, ker brez nje zgodovine za nazaj ni mogoče dobiti.
- **Javne statistike na tendask.app** so izvedljive iz agregatov (z k-anonimnostjo) in so dober marketinški material (social proof).

---

## 2. Arhitekturni kontekst (zakaj je to netrivialno)

### 2.1 Gostje brez cloud računa
`lib/core/auth/auth_service.dart`: `kLocalUserId = 'local'`; anonimni cloud račun se **nikoli** ne ustvari. Šele prijava (`sendEmailOtp` / `signInWithGoogle`) ustvari `auth.users` vrstico, nato `claimLocalRows` pripne lokalne vrstice na pravi `uid`.

**Posledica:** install → uporaba → registracija funnel **NI** merljiv iz Supabase. Installe daje Play Console; uporabo gostov le naprava-side telemetrija (Firebase/PostHog/Sentry).

### 2.2 State-based, ne event-based
Sync je `upsert` po `updated_at` (LWW). Ko se task uredi, je staro stanje prepisano. `task.updated_at` se prepiše ob **vsaki** naslednji uredbi → »kdaj zaključen« in »completion latency« sta nezanesljiva. **Ni event-loga.**

### 2.3 Posledice za pravila projekta
- **Additive-only migracije** (stari APK-ji ne smejo crashati ob pull-u). Vsako novo polje = nullable ali z default.
- **Zasebnost po zasnovi.** Samo H3 celice (r7/r6/r5), nikoli koordinate. Javne statistike = **samo agregati** + k-anonimnost.
- **RLS:** klient ne sme videti tujih vrstic. Agregati prek `SECURITY DEFINER` funkcije / service-role / materializiranega view-a, nikoli prek odprtega RLS.

---

## 3. Inventar virov podatkov

| Vir | Kaj vsebuje | Status | Doseg |
|-----|-------------|--------|-------|
| **Supabase: user tabele** (`task`, `user_plant`, `area`, `note`, `supply`, …) | trenutno stanje vsebine, `updated_at`, `deleted`, `status`, `weather` jsonb, `recurrence` jsonb | ✅ obstaja | samo prijavljeni; brez creation-time |
| **Supabase: `profile`** | `h3_r5/r6/r7`, `lang`, `notification_settings`, `updated_at` | ✅ obstaja | regija + locale (privacy-safe) |
| **Supabase: `auth.users`** | `created_at` (= 1. prijava), `last_sign_in_at`, `email`, provider (`raw_app_meta_data`), `is_anonymous`=false | ✅ obstaja | samo prek service-role; `last_sign_in_at` slab DAU proxy |
| **Supabase: katalog** (`task_type`, `plant`) | referenčni slugi + labels | ✅ obstaja | za poimenovanje v reportih |
| **Play Console** | installi, uninstalli, ocene, ANR/crash, država, naprava | ✅ obstaja | vsi uporabniki (tudi gostje), a ločeno od app podatkov |
| **Firebase** (FCM že na M11 veji) | *Analytics še NI vključen* | ⚠️ delno | potencial: app-open, DAU, funnel, verzija/OS — tudi gostje |
| **Sentry** | crash/error (MVP: deferred) | ⚠️ deferred | stabilnost po verziji |
| **M11 veja** (`suggestion`, `suggestion_log`, `fcm_token`, `agg_context`) | engagement pametnih predlogov, FCM opt-in | 🔜 ni na `main` | doda predlog-engagement, ko se M11 merge-a |

---

## 4. Vloge in zanimive metrike

Za vsako metriko: **🟢 dosegljivo zdaj** · **🟡 rabi majhen poseg** · **🔴 rabi nov vir (event-log / Firebase)**.

### 4.1 Marketing (akvizicija, kanali, social proof)

| Metrika | Dosegljivost | Vir / kaj rabi |
|---------|-------------|----------------|
| Installi / dan, po državi, organsko vs. kampanja | 🟢 | Play Console (UTM prek Play install referrer) |
| Install → 1. odprtje → registracija (funnel) | 🔴 | Firebase Analytics (gostje!) |
| Conversion rate gost → prijavljen | 🔴 | Firebase event `sign_up` + app-open base |
| Delež prijav email vs Google | 🟡 | `auth.users` provider (service-role agregat) |
| Št. aktivnih vrtnarjev »v X regijah« (za oglase) | 🟢 | `count(distinct user_id)` + `count(distinct h3_r5)` |
| Najbolj sajene rastline ta mesec/sezona | 🟢 | agregat `user_plant` × `plant.labels` |
| Sezonski trend opravil (kdaj ljudje gnojijo/sadijo) | 🟡 | rabi `created_at` ali event-log za točen čas |
| Retencijska kriva (D1/D7/D30) za kampanjske kohorte | 🔴 | Firebase / event-log |
| ASO: katere ključne besede, ocene, ranking | 🟢 | Play Console |

### 4.2 BI analitik (globlja analiza, kohorte, segmentacija)

| Metrika | Dosegljivost | Vir / kaj rabi |
|---------|-------------|----------------|
| DAU / WAU / MAU | 🔴 | Firebase (gostje) ali `server_inserted_at` + event-log (prijavljeni) |
| Retention kohorte po datumu registracije | 🟡/🔴 | rabi `created_at` (prijavljeni) ali Firebase (vsi) |
| Čas do aktivacije (install → 1. task) | 🔴 | event-log / Firebase |
| Aktivacijski funnel: registracija → lokacija → 1. rastlina → 1. task → 1. ✓ | 🟡 | iz prisotnosti vrstic (brez časa) zdaj; s časom rabi `created_at` |
| Povprečno št. rastlin / območij / taskov na uporabnika | 🟢 | agregati |
| Completion rate (`done` / vsi taski) | 🟢 | `status` agregat (čas approx) |
| Completion latency (planiran `date` → zaključek) | 🔴 | rabi ločen `completed_at`, ne prepisljiv `updated_at` |
| Uporaba ponavljajočih opravil (`recurrence`) | 🟢 | `task.recurrence is not null` |
| Custom vs katalog rastline (pokritost kataloga) | 🟢 | `user_plant.is_custom` |
| Razmerje opomnikov na task, opt-in rate FCM | 🟡 | `task_reminder` count; FCM rabi M11 `fcm_token` |
| Engagement pametnih predlogov (poslan → tapnjen → izveden) | 🔴 (🔜 M11) | `suggestion_log` (M11 veja) |
| Vreme ob zaključku (npr. škropljenje ob dežju) | 🟢 | `task.weather` jsonb |
| Churn signal (X dni brez sync-a) | 🟡 | rabi `server_inserted_at` / last-sync žig |
| Segmentacija po app verziji / OS | 🔴 | rabi verzijo v cloudu ali Firebase |

### 4.3 Direktor / izvršni pregled (zdravje produkta, rast)

| Metrika | Dosegljivost | Vir / kaj rabi |
|---------|-------------|----------------|
| Skupno št. uporabnikov (prijavljenih) + rast/teden | 🟢 | `auth.users` count |
| Skupno št. namestitev (vsi, tudi gostje) | 🟢 | Play Console |
| Stickiness (DAU/MAU) | 🔴 | Firebase |
| North-star: # zaključenih opravil / teden | 🟢 (approx) | `task` agregat |
| Rast vsebine (rastline, vrtovi) skozi čas | 🟡 | rabi `created_at` za pravo časovnico |
| Geografska pokritost (regije / države) | 🟢 | `profile.h3_r5` + Play država |
| Stabilnost (crash-free users) | 🟡 | Play Console / Sentry |
| Strošek na uporabnika (Supabase/Firebase usage) | 🟢 | Supabase/Firebase billing dashboard |
| 30-dnevna retencija (zdravje) | 🔴 | Firebase / event-log |

### 4.4 Uporabnik (in-app, osebne statistike kot feature)

> Opomba: to ni interna analitika ampak **produktna funkcija** — osebni »garden stats« povečajo engagement in so retencijski vzvod. Vsi podatki so lokalno v drift, brez mreže.

| Metrika | Dosegljivost | Vir / kaj rabi |
|---------|-------------|----------------|
| »Letos si zaključil X opravil« | 🟢 | lokalni drift agregat |
| Streak / koledar aktivnosti (heatmap) | 🟡 | rabi `created_at`/`completed_at` lokalno za točen dan |
| Št. rastlin / območij, najbolj negovana rastlina | 🟢 | drift |
| Sezonski povzetek (»spomladi si največ sadil«) | 🟡 | rabi creation-time |
| Poraba zalog skozi čas | 🟢 | `task_supply` (ko `kSuppliesEnabled`) |
| »Year in review« kartica za deljenje | 🟡 | kompozicija zgornjih + creation-time |

### 4.5 Obiskovalec spletne strani (javne statistike, social proof)

> Cilj: privabiti nove uporabnike z »živo« skupnostjo. **Samo agregati, k-anonimnost (≥ N uporabnikov na celico), nikoli posamezniki.**

| Metrika | Dosegljivost | Opomba |
|---------|-------------|--------|
| »X vrtnarjev neguje svoje vrtove« | 🟢 | števec prijavljenih (+ optional Play installi) |
| »X opravil zabeleženih skupaj« | 🟢 | global count |
| »X rastlin raste v skupnosti« | 🟢 | `user_plant` count |
| Top 10 rastlin ta mesec | 🟢 | agregat z min. pragom |
| Zemljevid pokritosti (grobe H3 r5 celice / države) | 🟢 | **samo celice z ≥ N uporabniki**; r5 je grob (privacy-safe) |
| Sezonski »kaj ljudje delajo zdaj« (top opravila ta teden) | 🟡 | lepše s creation-time |
| Živ števec (animacija »+1 opravilo«) | 🟡 | cache-an agregat, osvežen ~1 h (ne realtime) |

---

## 5. Konsolidiran gap (kaj NIMAVA)

1. **`created_at`** na user-tabelah → brez nje ni creation-time, kohort, časovnice rasti. **Nepovraten za nazaj.**
2. **`server_inserted_at default now()`** → pravi server-side čas vnosa (sync/aktivnost), neodvisen od device `updated_at`.
3. **`completed_at`** (ali event) → completion latency; `updated_at` se prepiše.
4. **App verzija / platforma / OS** v cloudu → segmentacija (zdaj samo v `app_info.dart` na napravi).
5. **App-open / session / »last seen«** → DAU/retention. `auth.users.last_sign_in_at` je slab proxy.
6. **Event-log (append-only)** → funnel, vedenje, zgodovina. State-tabele tega ne morejo dati.
7. **Vidnost gostov** → brez naprava-side telemetrije (Firebase/PostHog) so nevidni.
8. **Notification/reminder engagement** → ali je opomnik sprožen/tapnjen (M11 doda za *predloge*, ne za opomnike).

---

## 6. Kaj je potrebno narediti (tiri)

### Tier 0 — Takoj, brez kode (🟢 nizek napor)
- Shranjene SQL poizvedbe v Supabase SQL Editor (chart view) za vse 🟢 metrike.
- Play Console + (kasneje) Firebase Analytics konzola za vedenjske osnove.
- **Rezultat:** osnovni vpogled danes, 0 infrastrukture.

### Tier 1 — Migracija `0006` (🟡 majhen, additive, naredi PRVO)
- `alter table <user_tables> add column created_at timestamptz;` (nullable, device-set ob insertu; drift mirror).
- `alter table <user_tables> add column server_inserted_at timestamptz default now();` (server-side).
- Po želji `task.completed_at timestamptz` (set ob prehodu `waiting→done`).
- Drift v?? mirror + repo `create(...)` nastavi `created_at`.
- **Rezultat:** creation-time, kohorte, churn signal za prijavljene. **Edini časovno občutljiv korak** (zgodovine za nazaj ni).

### Tier 2 — Firebase Analytics / PostHog (🔴 srednji napor, največji vzvod za vedenje)
- Vključi Firebase Analytics (Firebase že vpeljan na M11 veji) ali PostHog.
- Eventi: `app_open`, `sign_up`, `onboarding_complete`, `location_set`, `plant_added`, `task_created`, `task_completed`, `reminder_set`, `notification_opened`.
- Auto: verzija, OS, naprava, država, DAU/retention/funnel — **tudi gostje**.
- **Rezultat:** funnel, retention, segmentacija, DAU/MAU za vse uporabnike.

### Tier 3 — Dashboard (🟡)
- Metabase (ali Grafana) v WSL Dockerju (kjer že teče staging) na **read-only** Postgres role.
- Osvežitev ~1 h (Metabase cache ali `pg_cron` → materializiran view `analytics_daily`).
- **Rezultat:** vizualni interni dashboard, brez lastne kode.

### Tier 4 — Javne statistike na tendask.app (🟡)
- `SECURITY DEFINER` funkcija `public_stats()` ali nightly materializiran view → samo agregati + k-anonimnost (≥ N).
- Web bere prek anon ključa **samo to funkcijo/view** (RLS gate; nikoli surove tabele).
- Cache na CDN/edge ~1 h.
- **Rezultat:** social-proof grafi (števci, top rastline, zemljevid pokritosti).

---

## 7. Zasebnost & GDPR (obvezno upoštevati)

- **Javno = samo agregati.** Nikoli vrstica posameznika. k-anonimnost: regijo/celico prikaži le pri ≥ N uporabnikih (predlog N=5).
- **H3 ostane grob** za javno (r5), nikoli koordinate (jih tako ali tako ni).
- **Firebase/PostHog** = obdelovalec osebnih podatkov → posodobi Data Safety v Play + privacy-policy (`docs/legal/privacy-policy.html`); razmisli o opt-out / anonimizaciji IP.
- **Brez PII v reportih** (email, device id) razen v service-role internem pogledu.
- **Izvoz/izbris računa** mora pobrisati tudi morebitne event-log vrstice (`ON DELETE CASCADE`).

---

## 8. Odprta vprašanja / odločitve

1. **Firebase Analytics ali PostHog?** (Firebase = že vpeljan, zastonj, Google ekosistem; PostHog = open-source, self-host možen, manj »Google«.)
2. Ali gremo z **event-log tabelo v Supabase** poleg/namesto naprava-side analytics? (Podvajanje vs. en vir resnice.)
3. **Katere javne metrike** dejansko želiva pokazati na tendask.app (in kdaj — rabi kritično maso, da ne izgleda prazno)?
4. Vrstni red: predlog **Tier 1 (`0006`) takoj**, ostalo po M11 / go-live.
5. Prag k-anonimnosti N za javno.

---

*Naslednji korak ob potrditvi: definiraj obseg (katere vloge/metrike v 1. iteraciji) → migracija `0006` → izbor analytics orodja → Metabase setup.*
