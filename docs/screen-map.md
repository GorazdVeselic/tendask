# Tendask — karta zaslonov (vir resnice za navigacijo)

> **Namen:** en dokument, ki drži **vse dejanske zaslone**, njihove **rute**, **kako se do njih pride**
> (CTA/trigger), **kaj na njih klikneš** in **kam to vodi**. Da pri načrtovanju novih feature-ov (npr.
> FR-19 Lunin koledar) ne ugibava, ampak vkey, kaj sodi kam.
>
> **Vir:** `lib/app/router/app_router.dart` + on-device screencap-i (ADB, 2026-07-23, prod build iz `main`,
> naprava SM-A536B / RZCT70XGC5P, dark tema, sl).
>
> **Vzdrževanje (pravilo):** ob vsaki spremembi rut (`app_router.dart`) ali strukture zaslona **posodobi ta
> dokument v istem commitu**. Screencap-i realnih zaslonov naj gredo v `tmp/` (ni v repo), povzetek strukture
> sem. Ko dodava nov zaslon, najprej dopiši vrstico sem (route + trigger + edges), šele nato koda.
>
> **Legenda:** `→` = navigacija (odpre); `⊳` = vsebovano/inline; **[shell]** = ima spodnjo navigacijo;
> **[full]** = celozaslonski nad shell-om (brez spodnje navigacije); `?x=` = query param; `:id` = path param.

---

## 1. Spodnja navigacija (StatefulShellRoute — 4 zavihki)

Shell (`main_shell.dart`) drži spodnjo vrstico: **Domov · Opravila · Dnevnik · Vrt**. Vsak je svoj branch;
menjava zavihka ohrani stanje (indexedStack).

### 1.1 Domov — `/home` (`home`) [shell]
Naslov »Dober dan 🌿« + datum · ⚙️ desno zgoraj.
- **Vsebina (od zgoraj):** vremenska kartica (📍 kraj + trenutno + 2-dnevna napoved + razširi) · rdeč pas
  »N zamujenih opravil« (razširljiv) · **DANES** (seznam ali »Danes ni načrtovanih opravil.«) · **NAZADNJE**
  (zadnja opravila) · **+ FAB** (spodaj sredina).
- **Akcije:**
  - ⚙️ → `/settings` (`settings`).
  - vremenska kartica → razširi (weather-detail sheet).
  - tap opravila (DANES/NAZADNJE) → **task-detail** (`/task/:id` ali shell `/tasks/:id`).
  - **+ FAB → `/task-new`** (vnos opravila, wizard — gl. §3.1).
- **[FR-19] doda:** »moon chip« pod vremensko kartico → `/moon-calendar` (ali `/tendask-plus`, če zaklenjeno).

### 1.2 Opravila — `/tasks` (`tasks`) [shell]
Seznam opravil. Tap opravila → **task-detail** `/tasks/:id` (`task-detail`, znotraj shell-a).

### 1.3 Dnevnik — `/journal` (`journal`) [shell]
Naslov »Dnevnik · vrtni dnevnik«. Segmented **[Časovnica | Mesec]**.
- **Mesec pogled:** ‹ mesec leto › nav · »N opravil ta mesec« · namig »💡 Tapni na dan …« · **mesečna
  mreža** (dnevi kot kartice; pike = opravila; danes = modra obroba; izbran = terakota obroba) · pod mrežo
  izbran dan: naslov datuma + seznam opravil + **»+ Dodaj opravilo na ta dan«**.
- **Akcije:** tap dan → izbere (pokaže opravila spodaj); tap opravila → task-detail; »+ Dodaj opravilo na ta
  dan« → `/task-new?date=…`.
- **[FR-19] doda (board C):** toggle »Lunin koledar« v tem koledarju → celice dobijo element-barvo + meno
  (kot namenski koledar), opravila ostanejo. Gl. §4.
- **NI »Teden« pogleda** (samo Časovnica + Mesec). Namenski lunin »Teden« živi v `/moon-calendar`.

### 1.4 Vrt — `/areas` (`areas`) [shell]
Naslov »Vrt · rastline in trate«. Segmented **[Območja | Sredstva | Recepti]**.
- **Območja:** sekcija »BREZ OBMOČJA« (rastline brez območja) + območja z naslovom (npr. »VRT«, »SADNO
  DREVJE«) in rastlinami · **»+ Rastlina«**.
- **Akcije:**
  - tap **rastline** → **plant-detail** `/plant/:id` (`plant-detail`) [full].
  - tap **območja** (naslovna kartica s 🌻/🍎) → **area-detail** `/areas/:id` (`area-detail`) [shell].
  - »+ Rastlina« → `/plant-add` (`plant-add`).
  - Sredstva / Recepti = zavihka (če `kSuppliesEnabled`).
- **[FR-19] doda (board D):** na **plant-detail** chip »🌙 Kdaj za …« → `/moon-finder?plant=:id`.

---

## 2. Celozaslonski zasloni (nad shell-om, brez spodnje navigacije) [full]

| Route (path) | name | Kako se pride (trigger) | Ključne akcije → kam |
|---|---|---|---|
| `/splash` | splash | zagon | → onboarding/home |
| `/onboarding` | onboarding | prvi zagon | koraki → `/home` |
| `/login` | login | odjava / prvi zagon | Google / e-pošta → `/login-email` |
| `/login-email` | login-email | login »e-pošta« | OTP → home |
| `/location` | location | onboarding / Nastavitve »Lokacija za vreme« | shrani H3 → nazaj |
| `/plant-picker` | plant-picker | (izbirnik rastlin) | izbere → nazaj z rezultatom |
| `/plant-add` | plant-add | Vrt »+ Rastlina« | shrani → nazaj |
| `/plant/:id` | **plant-detail** | Vrt → tap rastline | ✏️ → `/plant/:id/edit`; »📍 Dodeli območje«; tap opravila v zgodovini → task-view |
| `/plant/:id/edit` | plant-edit | plant-detail ✏️ | shrani/izbriši → nazaj |
| `/settings` | **settings** | Domov ⚙️ | gl. §2.1 |
| `/appearance` | appearance | Nastavitve »Tema in barve« | paleta+način → nazaj |
| `/notification-settings` | notification-settings | Nastavitve »Obvestila in opomniki« | tihe ure, kapica … |
| `/notification-preview` | notification-preview | (razvoj/preview) | — |
| `/area-new` | area-new | Vrt (dodaj območje) | shrani → nazaj |
| `/areas/:id/edit` | area-edit | area-detail uredi | shrani → nazaj |
| `/notes/new` | note-new | »Le zapis brez opravila« / dnevnik | shrani → nazaj |
| `/notes/:id/edit` | note-edit | tap opombe | shrani → nazaj |
| `/task-new` | **task-new** | Domov +FAB · Dnevnik »+ Dodaj …« (`?date=`) | wizard (gl. §3.1) |
| `/tasks/:id/edit` | task-edit | task-detail »✏️ Uredi« | wizard v edit-načinu |
| `/task/:id` | **task-view** | task-detail za klicalce **nad** shell-om (npr. plant-detail) | isti kot task-detail |

### 2.1 Nastavitve — `/settings` (dejansko, ADB 2026-07-23)
Naslov centriran »Nastavitve« · ← nazaj. Struktura (vsaka sekcija = VELIKA oznaka + kartica):
1. **Profil kartica:** 👤 e-pošta + »Prijavljen — podatki v oblaku«.
2. **LOKACIJA:** »📍 Lokacija za vreme« → `/location`.
3. **JEZIK:** segmented **[English · Deutsch · Slovenščina]** (inline, ne vrstica).
4. **VIDEZ:** »🎨 Tema in barve« → `/appearance`.
5. **OBVESTILA:** »🔔 Obvestila in opomniki« → `/notification-settings`.
6. **RAČUN & PODATKI:** »Izvozi podatke (GDPR)« · »Odjava« · »Izbriši račun in vse podatke« (terakota).
7. **O APLIKACIJI:** »🛡 Politika zasebnosti« ↗ (zunanja povezava).
8. Footer: »Tendask · 1.0.1+16«.
- **[FR-19] doda (board E):** poudarjena kartica **»✦ Tendask+«** takoj pod profilom (pred LOKACIJA) →
  `/tendask-plus`. Skrita prek `kTendaskPlusEnabled`, dokler ni monetizacije.

### 2.2 Detajl opravila — `/task/:id` (task-view) / `/tasks/:id` (task-detail), dejansko
← nazaj · ⋯ (action sheet). Struktura:
1. **Hero:** ikona tipa + naslov + subjekt (»🌱 rastlina«) + status-pill (»✓ Opravljeno · datum · ura«).
2. **RASTLINA ALI OBMOČJE (n):** kartica subjekta → tap → plant/area-detail.
3. **VREMENSKI POSNETEK:** kartica (stanje + °C + vlaga/veter/dež/ETo + dež 48 h + NAPOVED). **Zamrznjen** ob
   »opravljeno«.
4. **PRIDELEK** (če je harvest tip): količina.
5. **»✏️ Uredi«** → `/tasks/:id/edit`.
6. Akcijska vrstica: **Podvoji · Premakni · Na čaka · Izbriši**.
- **[FR-19] doda (board A):** sekcija **»Lunin koledar«** za VREMENSKIM POSNETKOM — element-dan iz `task.date`
  (**re-izpeljano, ne zamrznjeno**). Info, ni tap (MVP).

### 2.3 Detajl rastline — `/plant/:id` (plant-detail), dejansko
← nazaj · ✏️ (uredi). Struktura:
1. **Hero:** ikona (🍎…) + ime + znanstveno ime + chip **»📍 Dodeli območje«**.
2. **PRIDELEK:** »Skupaj … N kg«.
3. **ZGODOVINA OPRAVIL:** kartice opravil → tap → task-view.
- **[FR-19] doda (board D):** drugi chip v hero **»🌙 Kdaj za …«** → `/moon-finder?plant=:id` (predizpolnjen).

---

## 3. Wizard: vnos opravila — `/task-new` (dejansko, 4–5 korakov)

`EntryScreen` (`entry/`). Sprejme `?date=` (predizpolni datum — že obstaja!). ✕ zapre, ← korak nazaj.
Progres traku na vrhu; število korakov je odvisno od tipa (Sredstva korak pogojen z `kSuppliesEnabled`).

- **Korak 1 · Katero opravilo?** — »Ponovi zadnje« + mreža tipov (Zalivanje, Setev, Gnojenje …) + »Pokaži
  vse (26)« + »Le zapis brez opravila? → Opomba«. **Tap tipa samodejno naprej.**
- **Korak 2 · Za kaj?** — filter [Vse/Sadno drevje/Sobne/Trata] + seznam RASTLINE (+ za izbiro) + »Dodaj
  rastlino« + »ALI CELOTNO OBMOČJE« (chipi) + »Dodaj območje« → **Nadaljuj**.
- **Korak 3 · Kdaj** — segmented **[Danes | Jutri | Datum…]** + **Datum** (📅) + **Ura** (🕐) + »Privzeto:
  danes ob naslednji polni uri« + **Status** [Čaka | Opravljeno] + **Ponavljanje** [Brez/Dnevno/Tedensko/Po
  meri] → **Nadaljuj**.
- **Korak 4 · (Sredstva)** — pogojno (`kSuppliesEnabled`).
- **Zadnji korak · Pregled** — shrani.
- **[FR-19] doda (board B):** medla element-vrstica pod Datum/Ura na **koraku 3** (iz izbranega `date`). Info.

---

## 4. NOVI zasloni FR-19 (Lunin koledar) — načrt rut + vstopi + prehodi

Predlagane rute (top-level [full], brez kolizij):

| Route | name | Kako se pride (VSI vstopi) | Vsebuje / vodi |
|---|---|---|---|
| `/tendask-plus` | tendask-plus | (1) Nastavitve → »✦ Tendask+« kartica · (2) Domov moon chip (zaklenjen) rdeči CTA | brez licence: vnos kode + »Aktiviraj« + seznam ugodnosti (»Kmalu« za prihodnje) · z licenco: veljavnost + funkcije; **»Lunin koledar« → `/moon-settings`** |
| `/moon-settings` | moon-settings | `/tendask-plus` → »Lunin koledar« | stikalo · sistem [Po ozvezdjih / Po znamenjih] · podstikala · »Kaj je to« |
| `/moon-calendar` | moon-calendar | (1) Domov moon chip (odklenjen) · (2) *opc.* Dnevnik vstop | segmented [Mesec | Teden] · 🔎 → `/moon-finder` · **tap dan → dan-podrobno (sheet)** |
| `/moon-finder` | moon-finder | (1) `/moon-calendar` 🔎 (prazen) · (2) plant-detail »🌙 Kdaj za …« (`?plant=:id`, predizpolnjen) | izbor rastline (⊳ plant-picker) → seznam primernih dni → »＋« = `/task-new?date=…` |
| (sheet) | moon-day | `/moon-calendar` → tap dan | »Kaj se dogaja« + priporočila → »＋ opravilo« = `/task-new?date=…` |

**Polni navigacijski poti do iskalnika (za »vse vmesne korake«):**
- **A · iz koledarja:** Domov → *moon chip* → `/moon-calendar` → tap **🔎** → `/moon-finder` (prazen) → tap
  polje → **plant-picker** → izbereš rastlino → seznam dni → »＋« → `/task-new?date=…`.
- **B · iz rastline:** Vrt → tap rastline → `/plant/:id` → chip **»🌙 Kdaj za …«** → `/moon-finder?plant=:id`
  (predizpolnjen) → seznam dni → »＋« → `/task-new?date=…`.

**Vstop v ✦ Tendask+ (za »kako sploh prideš«):**
- Domov → **⚙️** → `/settings` → kartica **»✦ Tendask+«** → `/tendask-plus`.
- Domov → *moon chip (zaklenjen)* → rdeči CTA → `/tendask-plus`.

**Poimenovanje (fiksno):** povsod **»✦ Tendask+«** (ikona vedno spredaj). Prihodnje/nedokončane funkcije =
**»Kmalu«** (EN: »Soon«). Nikjer »Thun«/»Aussaattage«. Sistem = »Po ozvezdjih (biodinamični)« / »Po
znamenjih (astrološki)«.

---

## 5. Odprto (vpliva na karto)
- §8.9: en koledar (`/moon-calendar`) vs. tudi indikator v Dnevniku (§1.3 / board C). **Predlog:** primaren
  `/moon-calendar`; dnevniški toggle-overlay kasneje.
- `moon-day`: sheet znotraj `/moon-calendar` vs. lastna ruta. **Predlog:** sheet.
- pre-fill »＋ opravilo«: zaenkrat le `?date=` (obstaja). Tip/subjekt predizpolniti = odprto.
