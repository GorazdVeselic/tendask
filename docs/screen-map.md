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

## 1. Spodnja navigacija (StatefulShellRoute — 4 zavihki; M11 doda 5.)

Shell (`main_shell.dart`) drži spodnjo vrstico: **Domov · Opravila · Dnevnik · Vrt**. Vsak je svoj branch;
menjava zavihka ohrani stanje (indexedStack).

> **[M11 Okolica] doda 5. zavihek** »Okolica« (⬡ = H3 celica) **za temnim flagom** (`kCommunityEnabled`):
> v prod APK-ju **skrit**, dokler ni prižgan. Ob prižigu je zavihek stalen za vse; brez Plus prikaže **tease**
> (gl. §1.5). Plus-gate = **FR-20** (podpisan token; v M11 le stub `hasPlus`).
>
> **Dva ločena flaga** (odločitev O3, `7d06944`): `kSuggestionsEnabled` prižge **brezplačne pametne
> predloge** (pas na Domov, `/suggestions/history`, sekcija PAMETNI PREDLOGI, stikali obvestil),
> `kCommunityEnabled` pa **plačljivo Okolico** (5. zavihek, `/community/task`, kartici na Domov in
> na detajlu opravila). Prižig enega ne prižge drugega.

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
- **[M11 predlogi] doda (flag-dark, `kSuggestionsEnabled`):** **pas »PREDLOGI ZATE«** takoj pod vremensko
  kartico, nad zamujenimi. Največ **3 kartice** (`kSuggestionBandMax`) + ena skupna izjava o odgovornosti
  pod pasom. Kartica: ikona tipa + naslov + telo (napolnjeno iz `message_params`; ob `dry_window` še
  pripona »Suho okno (~N h) — primeren čas.«) + **Opusti** / **Načrtuj** + ⋯.
  - **Načrtuj** → `/task-new` predizpolnjen (`?type=&date=&plant=|area=`); shranjen task predlog označi
    kot `planned`, preklic ga pusti na pasu.
  - **Opusti** → dismiss za sezono. ⋯ sheet: »Že opravljeno« (mini-sheet Danes / Včeraj / Izberi →
    ustvari `done` opravilo) · »Ne predlagaj več« (dismiss forever) · »Tega nimam več« (soft-delete
    subjekta, potrditveni dialog).
  - **Prazen seznam ne izriše ničesar** — ne naslova, ne razmika (Domov ne sme dobiti prazne luknje).
    Napaka lokalnega branja pokaže miren `LoadErrorHint`.
  - Tap potisnega obvestila odpre Domov z `?suggestion=<id>` — kartica je ~2 s obrobljena.
- **[M11 Okolica] doda (flag-dark, `kCommunityEnabled`):** sekcija **»V TVOJI OKOLICI ⬡«** nad **DANES** — ena vrstica feeda
  (naslov = opravilo, podnaslov = rastlina, oznaka intenzitete — **isti widget kot na landingu**) →
  `/community/task/:taskTypeId` (`?plant=`), pod njo meta vrstica (okno · obseg · populacija) in
  »Vse iz okolice ›« → `/community`. Skrito prek `kCommunityEnabled`.
  - **Izbira namiga** (odločeno 2026-07-25): prvi element feeda, katerega skupina je **kataloška rastlina
    v mojem vrtu**; če je ni, prvi element feeda. Prostorska (`@site`) skupina nikoli ne šteje kot »moja«
    (ustreza vsakemu vrtu), sme pa biti fallback.
  - **Brez dodatnih zahtev:** bere isto dnevno rezino, ki jo repozitorij že predpomni — sekcija ni
    dodaten omrežni klic. Če rezine ni (premalo vrtnarjev, offline brez cache, napaka branja), se
    **ne izriše nič** — ne naslova, ne razmika; Domov ne sme dobiti stalne prazne luknje.

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

### 1.5 Okolica — `/community` (`community`) [shell] · [M11, flag-dark]
5. zavihek (⬡), za `kCommunityEnabled`. Naslov »Okolica«. Segmented **[Ta teden | Kje si ti]** + **oznaka
obsega** (»v tvoji okolici« = r7/r6/r5 · »v podobni klimi« = climate) z oknom in populacijo vedra.
- **Obseg je oznaka, ne izbirnik** (odločitev A, 2026-07-25): razreši ga fallback veriga — najfinejši nivo nad
  `kCommunityPrivacyMin=5`, vedno **en** nivo (§7.4). Člen »vsi« ne obstaja (cron ne dela globalnega vedra),
  izbirnik je **odložen, ne opuščen** (podatkovna plast ga podpira).
- **Ta teden** (privzeto): kvalitativen feed zadnjih 7 dni (`pogosto`/`nekaj`/`redko`), populacija vedra;
  offline bere včerajšnji dnevni cache (drift `community_cache`). Pod pragom → »še premalo vrtnarjev«.
  **Vrstica = primerjalna skupina** (§7.4): naslov = opravilo, podnaslov = rastlina, kadar skupina ni
  prostorska (»Obrez« + »jablana«; »Košnja« brez podnaslova). Kapica: največ 2 vrstici na tip opravila.
- **Kje si ti:** skupine, ki si jih letos delal, vsaka postavljena ob krivuljo svoje skupine — oznaka
  **zgodaj/običajno/pozno** (percentil na napravi; prislov, ne pridevnik — oznaka nagovarja bralca in
  je od P10.1 spolno nevtralna), **nazadnje začeto na vrhu**. Vrstica: naslov = opravilo,
  podnaslov = rastlina **+ obseg te vrstice** (vsaka skupina se širi po svoje, §7.4, zato obsega ne more
  razglasiti zaslon). Skupine, za katere noben nivo nima dovolj vrtnarjev, **izpadejo** — zato podnožje pove
  zakaj. Tap → ista predloga. Tease enak kot »Ta teden«.
  - **Prazen seznam ima štiri različne razloge in štiri različna besedila** (najdba N17): naprava še ni
    dobila nobene rezine (offline) · **letos nimam nobenega opravila** · imam opravila, a nobeno ni
    **sezonsko** (zalivanje se po §7.5 ne primerja) · imam sezonsko zgodovino, a nobena skupina ne prestopi
    praga. Samo zadnji je trditev o **drugih** vrtnarjih — ostale so o moji zgodovini in je ne smejo
    pripisati soseski.
  - **Številke tu ni** (odločitev 2026-07-25, odstopanje od wireframa B2 »zgoden · 30 %«): odstotek brez
    velikosti vzorca in brez opombe o prvi sezoni je številka brez imenovalca (§7.7) — oboje je na detajlu,
    kamor vrstica pelje.
  - **Ena zahteva na nivo, ne na opravilo** (§12.4): rezina se prebere masovno in shrani **razrezana po
    skupinah, pod istimi ključi kot detajl** — odprtje detajla po seznamu je zato zastonj.
- **Akcije:** tap opravila → **community-task** `/community/task/:taskTypeId` (`?plant=`) [shell]; »ℹ️ Kako beremo
  te podatke« → explain sheet (pove tudi, **zakaj** je obseg tak).
- **Gating (M11 stub):** brez Plus → prva vrstica feeda vidna, ostalo `TeaseOverlay` (blur + »Na voljo v
  Tendask +« + nevtralni **»Vnesi kodo«** — **brez cene/URL/trial/CTA k nakupu**, anti-steering FR-20 §3.1).
  Pravi token-gate = FR-20; »Vnesi kodo« je v M11 placeholder.

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
| `/notification-settings` | notification-settings | Nastavitve »Obvestila in opomniki« | vrste (opomniki · povabilo k dnevniku · **pametni namigi (vreme)** · **namigi okolice** — zadnji dve strežniški, stikali inertni brez `kSuggestionsEnabled`, podnapis se s flagom zamenja) · privzeti zamik · tihe ure · predogled · sistemsko dovoljenje |
| `/notification-preview` | notification-preview | (razvoj/preview) | — |
| `/suggestions/history` | **suggestion-history** [M11, flag-dark `kSuggestionsEnabled`] | Nastavitve → PAMETNI PREDLOGI → »Pretekli predlogi« | samo za branje: predlogi, združeni po dnevu odziva (novejši zgoraj), s statusom (Načrtovano · Zabeleženo · Opuščeno · Utišano · Zamujeno); vrstica `planned`/`logged` → task-detail. Ni obvestilni center — obstaja zaradi pojasnljivosti. Prazno: »Še ni zgodovine …« |
| `/area-new` | area-new | Vrt (dodaj območje) | shrani → nazaj |
| `/areas/:id/edit` | area-edit | area-detail uredi | shrani → nazaj |
| `/notes/new` | note-new | »Le zapis brez opravila« / dnevnik | shrani → nazaj |
| `/notes/:id/edit` | note-edit | tap opombe | shrani → nazaj |
| `/task-new` | **task-new** | Domov +FAB · Dnevnik »+ Dodaj …« (`?date=`) | wizard (gl. §3.1) |
| `/tasks/:id/edit` | task-edit | task-detail »✏️ Uredi« | wizard v edit-načinu |
| `/task/:id` | **task-view** | task-detail za klicalce **nad** shell-om (npr. plant-detail) | isti kot task-detail |

> **Opomba k `community-task`:** ruta je **gnezdena pod `/community`** (ostane v zavihku, ima svoj back
> stack), zato ni [full]. `?plant=` **odsoten = prostorska skupina** (`@site`) — sentinel ne gre v URL.
> Os obeh grafov je **datumska** (`formatDm` ponedeljka tedna), ne imena mesecev kot v wireframu B3:
> imena mesecev bi pomenila 36 novih prevodov za manj natančnosti na tedenskem grafu.
| `/community/task/:taskTypeId` | **community-task** [M11, flag-dark] | Okolica feed · Domov kartica · detajl opravila CTA (`?plant=`) | percentil stolpci + »ti« marker + frekvenca stolpci + »ta teden« + ℹ️ explain sheet; brez Plus → `TeaseOverlay` čez vso vsebino |

### 2.1 Nastavitve — `/settings` (dejansko, ADB 2026-07-23)
Naslov centriran »Nastavitve« · ← nazaj. Struktura (vsaka sekcija = VELIKA oznaka + kartica):
1. **Profil kartica:** 👤 e-pošta + »Prijavljen — podatki v oblaku«.
2. **LOKACIJA:** »📍 Lokacija za vreme« → `/location`.
3. **JEZIK:** segmented **[English · Deutsch · Slovenščina]** (inline, ne vrstica).
4. **VIDEZ:** »🎨 Tema in barve« → `/appearance`.
5. **OBVESTILA:** »🔔 Obvestila in opomniki« → `/notification-settings`.
6. **PAMETNI PREDLOGI** [M11, flag-dark `kSuggestionsEnabled`]: »💡 Pretekli predlogi« →
   `/suggestions/history`. Sekcija se brez flaga ne izriše (tudi ruta ne obstaja).
7. **RAČUN & PODATKI:** »Izvozi podatke (GDPR)« · »Odjava« · »Izbriši račun in vse podatke« (terakota).
8. **O APLIKACIJI:** »🛡 Politika zasebnosti« ↗ (zunanja povezava).
9. Footer: »Tendask · 1.0.1+16«.
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
- **[M11 Okolica] doda (flag-dark):** sekcija **»V TVOJI OKOLICI«** + kartica **za kartico subjekta, pred
  VREMENSKIM POSNETKOM** → `/community/task/:taskTypeId` (`?plant=`, predloga tega opravila).
  Skrito prek `kCommunityEnabled`.
  - **Skupina** je izpeljana iz subjektov opravila (prva kataloška rastlina; območje, lastna rastlina ali
    brez subjekta → `@site`) — isto pravilo kot `agg_event` na strežniku.
  - **S Plus:** naslov je ugotovitev (»Bil si med zgodnejšimi 30 %« / opisni pas pod pragom / »Letos tega
    še nisi naredil«), podnaslov je CTA.
  - **Brez Plus:** samo nevtralen CTA »Kako je s tem opravilom v okolici ›« — **brez podatka in brez
    poizvedbe** (odločeno 2026-07-25: §12.5 »v Okolici ni nič trajno brezplačnega«; tease je na cilju,
    ne na tuji strani).

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
