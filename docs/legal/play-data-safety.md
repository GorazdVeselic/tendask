# Tendask — Play Console »Data Safety« mapiranje

> **Osnutek za pregled (2026-06-18, v1.2 — FR-8 + FR-12).** Pripravljeni odgovori za Play Console →
> App content → **Data safety** obrazec. Vsaka vrstica = en podatkovni tip v Googlovem obrazcu, z
> razlago, zakaj tak odgovor. **Vir resnice za dejstva = `privacy-policy.md` + koda** (Open-Meteo in
> OSM/Nominatim dobita le **približno središče celice ~1 km**, ne natančnih koordinat; surove
> koordinate se nikoli ne shranijo; v oblak gre le H3; Supabase EU; Sentry diagnostika; Google/Resend).
>
> **🔁 Sprememba glede na v1.0 (👤 popravi v konzoli):** **Precise location** ni več zbran/deljen
> (app zahteva le COARSE dovoljenje, surovih koordinat ne hrani); **Approximate location** postane
> _Shared_ (centroid celice → Open-Meteo).
>
> **🔁 Sprememba v1.2 (FR-12):** approximate location ostane _Shared_ (toggle se NE spremeni) — doda
> se le **drugi prejemnik OSM/Nominatim** (centroid celice → ime kraja). Obrazec nima polja za
> posameznega prejemnika, zato dejanski odgovori ostanejo enaki; posodobi le privacy policy (v1.2).
>
> Legenda stolpcev (kot v obrazcu): **Collected** = podatek zapusti napravo (na naš strežnik / se
> hrani) · **Shared** = preneseno tretji osebi · **Ephemeral** = obdelan le v pomnilniku za zahtevo,
> ne shranjen · **Required/Optional** = ali ga app nujno zbira ali le ob privolitvi/prijavi.

---

## 1. Splošno (uvodna vprašanja obrazca)

| Vprašanje | Odgovor | Opomba |
|---|---|---|
| Does your app collect or share any of the required user data types? | **Yes** | Email, lokacija, diagnostika, vsebina. |
| Is all of the user data encrypted in transit? | **Yes** | Vse prek HTTPS/TLS (Supabase, Open-Meteo, Sentry, Google). |
| Do you provide a way for users to request that their data be deleted? | **Yes** | V aplikaciji: Nastavitve → izbris računa (kaskadno počisti oblak) + lokalni clear. Dodatno e-pošta `info@tendask.com`. |

---

## 2. Podatkovni tipi

### Location

| Tip | Collected | Shared | Ephemeral | Required/Optional | Namen (purposes) | Pojasnilo |
|---|---|---|---|---|---|---|
| **Approximate location** | **Yes** | **Yes** | No | **Optional** | App functionality | V oblak (Supabase, EU) shranimo le celico **H3 (~1 km)**, ne koordinat (zato Collected, ne Ephemeral). Za vreme in ime kraja se **središče celice** (~1 km) pošlje Open-Meteo in OSM/Nominatim → zato **Shared**. Le ob prijavi/dovoljenju. |
| **Precise location** | **No** | **No** | — | — | — | App zahteva le **COARSE** dovoljenje in surovih koordinat nikoli ne hrani niti ne pošlje (vreme dobi le centroid celice). Natančne lokacije torej ne zbiramo. |

> ⚠️ **Po FR-8 je to poštena slika:** app nima več `ACCESS_FINE_LOCATION`, surovih GPS koordinat
> ne shrani (niti lokalno) in navzven pošlje le **približno središče celice** (~1 km). Zato je
> **precise location = ne zbrano**, **approximate location = Collected (H3 v Supabase) + Shared
> (centroid → Open-Meteo)**. Ujema se s politiko zasebnosti §2/§3/§5.

### Personal info

| Tip | Collected | Shared | Required/Optional | Namen | Pojasnilo |
|---|---|---|---|---|---|
| **Email address** | **Yes** | No | **Optional** | Account management, App functionality | Le ob prijavi s kodo (gost brez računa dela brez nje). Dostava kode prek Resend (obdelovalec), ne »sharing« za njihove namene. |
| **User IDs** | **Yes** | No | **Optional** | Account management, App functionality | Supabase `user_id` (in identifikator Google računa ob Google prijavi). Le ob prijavi. |

### App activity / App info and performance

| Tip | Collected | Shared | Required/Optional | Namen | Pojasnilo |
|---|---|---|---|---|---|
| **Crash logs** | **Yes** | **Yes** | Required | Analytics, App functionality (stabilnost) | Sentry ob sesutju/napaki (sled klicev, kontekst). |
| **Diagnostics** | **Yes** | **Yes** | Required | Analytics | Sentry: različica aplikacije, tip naprave/OS. |

### Other / app content

| Tip | Collected | Shared | Required/Optional | Namen | Pojasnilo |
|---|---|---|---|---|---|
| **Other user-generated content** (vrtni dnevnik: opravila, opombe, rastline, območja) | **Yes** | No | **Optional** | App functionality | Sinhronizira se v oblak (Supabase, EU) **le ob prijavi**; brez računa ostane na napravi. Izbor »Other« — Google nima namenske kategorije za vrtne zapise. |

---

## 3. Security practices (zadnja sekcija obrazca)

| Vprašanje | Odgovor |
|---|---|
| Data is encrypted in transit | **Yes** (HTTPS/TLS povsod) |
| Users can request that data be deleted | **Yes** (v aplikaciji + e-pošta) |
| Independent security review | **No** |
| Committed to Google Play Families Policy | **No** (ni namenjeno otrokom <16) |

---

## 4. Povzetek za hitro izpolnjevanje

- **Email, User IDs** → collected, NOT shared, optional, account management.
- **Approximate location** → collected (H3) + **shared (Open-Meteo + OSM/Nominatim centroid)**, optional, app functionality.
- **Precise location** → **NOT collected, NOT shared** (le COARSE dovoljenje; surovih koordinat ne hranimo).
- **Crash logs + Diagnostics** → collected + **shared (Sentry)**, required, analytics.
- **Vrtna vsebina** → collected (Other UGC), NOT shared, optional, app functionality.
- **Encryption in transit: Yes · Deletion available: Yes.**

> Tretje osebe, ki prejmejo podatke (za »shared«): **Open-Meteo** in **OSM/Nominatim** (approximate
> location — centroid celice), **Sentry** (crash/diagnostics). **Supabase** in **Resend** sta _obdelovalca_ v našem
> imenu (hramba/dostava), ne »sharing« v Googlovem pomenu — Supabase shranjuje, zato so tipi
> »collected«.
