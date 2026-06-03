# Prefokus: rastlina kot subjekt (ne območje)

> Datum: 2026-06-03 · Status: **POTRJENA SMER** (odločitve spodaj), izvedba v teku
> Povod: opravila so območje-centrična; rastlina — razlog, zaradi katerega opravila
> sploh delamo — je drugorazredna ali neobvezna. To znižuje vrednost aplikacije.
> Sorodno: nadgrajuje `ia-pregled.md` (vitka IA) in `koncept.md` §7.7/7.8/7.9/7.14.

---

## 1. Povod

Uporabnik dela opravila **zaradi rastlin**, ne zaradi opravil samih. Miselna shema je
vedno **problem → rastlina → akcija**:

- jagode napadajo mravlje → **tretiram**
- trava rjavi → **zalijem**
- spomladi → **obrežem lovorikovce** (opomnik mora reči "obreži lovorikovce", ne
  "opravilo na živi meji")

Trenutno je v aplikaciji **lokacija (greda, trata, živa meja) pomembnejša od rastline**,
ki jo obdelujemo. To je obrnjeno glede na bistvo.

## 2. Diagnoza — območje-centričnost na vseh plasteh

Implementacija je zvesto prevzela območje-centrično miselno shemo iz wireframov, ti pa
iz koncepta (§7.14 model: `area` obvezen, `user_plant` neobvezen).

| Plast | Kako se kaže | Dokaz |
|---|---|---|
| **Podatkovni model** | Območje **obvezno**, rastlina **neobvezna** | `task.area_id` NOT NULL, `task.user_plant_id` nullable (`lib/core/database/tables/user_tables.dart:78–80`) |
| **Repozitorij** | `create`/`updateTask` zahtevata `areaId`; poizvedbe so `watchByArea` / `watchLatestPerArea` | `lib/features/tasks/data/tasks_repository.dart:45–62, 67–116` |
| **Hiter vnos (02)** | "Kje" (območje) = prvorazredna vrstica čipov; rastlina pokopana pod **"Več (po potrebi)"** | `lib/features/tasks/presentation/quick_log_screen.dart:177–191`; shranjevanje zahteva `_areaId` (`:76`) |
| **Novo opravilo (07)** | Polje "Območje" **nad** "Rastlina"; rastlina označena "(za obrez, tretiranje…)" — izjema, ne pravilo | `docs/wireframes/07-reminder-edit.html:45–66` |
| **Navigacija** | Zavihek **"Območja"** obstaja; vstopa za **rastline ni** | `lib/app/router/main_shell.dart:40–44` |
| **Zgodovina** | Zgodovina **po območju** (05). Zaslona "zgodovina ene rastline" **ni**. | `area_detail_screen.dart` obstaja; `plant_detail` ne |
| **Domov / seznami** | Subjekt prikaza = območje; rastlina je pripis | `01-home.html:99–106` ("Obrezal živo mejo · 🪴 Živa meja · lovorikovec") |

## 3. Zakaj to ruši bistvo

Vrednost Tendaska (koncept §1, §6.5, §8) je **lastna zgodovina po subjektu** ("lani
tačas si…") in V2 **percentili**. Oboje je ključeno po **rastlina × tip opravila**
(kanonični ID, npr. `prune`×`apple`), **ne** po območju — območje v V2 sploh ne nastopa.

Najbolj dragocena vprašanja, ki jih trenutna IA onemogoča ali oteži:

- "Kdaj sem nazadnje obrezal **jablano**?" (jablana in maline sta v istem območju, a ju
  obrezuješ ob različnem času — koncept §7.8 to pozna, a model tega ne postavi v ospredje)
- "Kaj sem letos vse delal z **jagodami**?"
- "Pokaži zgodovino te **rastline**" — zaslona ni.

## 4. Ključni vpogled: dva tipa subjekta

Korenska napaka **ni** "rastlina ni obvezna". Napaka je **enačenje subjekta z območjem**.
Obstajata **dva tipa subjekta**:

1. **Homogeno območje = subjekt sam** → trata (in podobno). Rastline ni; območje *je*
   tisto, kar negujemo. Obstoječi model je tu **pravilen**.
2. **Rastlina = subjekt** → jablana, paradižnik, lovorikovec. Območje je le **kraj, kjer
   slučajno stoji** — postranska lastnost, ne hrbtenica.

Rešitev **ni** "rastlina povsod obvezna" (to bi razbilo trato). Rešitev je dvigniti
**SUBJEKT** v prvorazredni pojem:

> **Opravilo se veže na SUBJEKT = rastlina ALI območje-kot-celota.**
> Subjekt = `rastlina ?? območje`. Oba sta enakovredna; območje postane
> **skupina/lokacija**, ne hrbtenica.

### 4.1 Eno opravilo → več subjektov (multi-select, 2026-06-03)
Eno dejansko dejanje pogosto velja za **več subjektov hkrati** (z algami folirano gnojim
solato + paradižnik + trato; eno škropljenje = en dogodek). Zato je vez **many-to-many**:

> **Opravilo ↔ subjekti = M:N** prek povezovalne tabele `task_subject`.
> En zapis opravila, N subjektov. V Dnevniku **ena vrstica**; prikaže se v zgodovini
> **vsakega** subjekta; **sredstva in vreme veljajo skupno** (en odpis alg, en posnetek).

**Subjekt = instanca, ne vrsta.** `user_plant` je že instanca = vrsta (`plant_id`) ×
območje (`area_id`). Ista vrsta na več območjih (jablana–vrt, jablana–sadovnjak) = **dve
instanci**. Ob izbiri vrste izbirnik **ponudi območja, kjer to vrsto imaš, in jih
odkljukaš** → vsaka odkljukana instanca je svoj subjekt.

## 5. Potrjene odločitve (2026-06-03)

1. **Globina = subjekt (rastlina ALI območje)** — poseže do drift sheme. Zdaj je
   najceneje (pred M5/Supabase, brez migracijskega bremena).
2. **Navigacija: zavihek "Območja" → "Vrt"** — rastline grupirane po območjih, trata kot
   območje-subjekt; tap na rastlino → nov detajl rastline. Brez novega zavihka (skladno z
   vitko IA iz `ia-pregled.md`).
3. **Rezultati revizije:** ta dokument + uskladitev `koncept.md` · novi `_v2` wireframe ·
   sprememba sheme + repozitorijev.

## 6. Konkretne spremembe

### 6.1 Podatkovni model (drift + kasneje Supabase)
Subjekti se preselijo iz `task` v **povezovalno tabelo** (M:N):

- **`task`** — odstrani `area_id` in `user_plant_id`. Ostane: `task_type_id`, `date`,
  `status`, `note`, `weather`, `recurrence`, sync polja. Vreme/sredstva ostanejo na
  opravilu (en dogodek = en posnetek, en odpis).
- **`task_subject`** (NOVA) — `id`, `task_id` FK, `user_plant_id` nullable, `area_id`
  nullable, sync polja (`updated_at`, `deleted`, `sync_status`). Invarianta
  `CHECK(user_plant_id IS NOT NULL OR area_id IS NOT NULL)`. Ena vrstica = en subjekt.
  - subjekt = rastlina → `user_plant_id` (območje izpeljemo iz instance, `area_id` NULL);
  - subjekt = trata/območje → `area_id`, `user_plant_id` NULL.
- **`user_plant.area_id`** → **nullable** (rastlina ne rabi imenovanega območja, npr.
  lončnica na terasi).
- Repo: `create` sprejme **seznam subjektov**; poizvedbe `watchByArea`/`watchByPlant`/
  `watchLatestPerSubject` gredo prek joina na `task_subject`. Sync FK vrstni red:
  `area` → `user_plant` → `task` → `task_subject`/`task_reminder`/`note`/`task_supply`.

### 6.2 Nov zaslon: Detajl rastline (manjka — dostavi bistvo)
Zrcalo `05-area-detail`, a za **eno rastlino**: ikona + ime (+ osebni alias) +
zgodovinski namig ("lani tačas si jablano…") + **cela zgodovina opravil te rastline**.
To je "domača stran" subjekta.

### 6.3 IA / navigacija — zavihek "Vrt"
Rastline brskljive: zavihek **"Vrt"** = rastline grupirane po območjih + trata kot
območje-subjekt na vrhu. Tap na rastlino → detajl rastline; tap na trato → detajl območja.

### 6.4 Vnos (02 + 07) — subjekt naprej, multi-select
Vrstni red **Kaj → Za kaj (subjekti) → Kdaj**. Izbirnik subjekta je **multi-select** in:
- glede na `requires_subject` izbranega tipa najprej poudari pravo skupino ("obrez /
  tretiranje / pobiranje / sajenje" → rastline; "košnja / zalivanje trate" → trate);
- prikaže **uporabnikove subjekte** (rastline grupirane po območjih + trate); ob izbiri
  vrste z več instancami **ponudi območja, da odkljukaš** katere;
- omogoča **inline dodajanje** nove osebne rastline iz **celotnega kataloga** kar tu
  (iskanje → dodaj), brez ovinka prek urejanja območja (09);
- subjekt-rastlina **ven iz "Več (po potrebi)"** v glavno polje; območje se izpelje iz
  instance.

### 6.5 Domov + seznami
Vodi s **subjektom** (rastlina, če obstaja; sicer območje); območje = drobni drugotni čip.
Opomnik: "Obreži **lovorikovce**", ne "opravilo na živi meji".

### 6.6 Onboarding
"Katere **rastline** imaš?" (+ trata) namesto "Katera območja imaš?". Območja kot
neobvezno grupiranje.

### 6.7 Pametni motor (`pametni-motor.md`)
Cooldown/predlogi že načrtovani po `(območje+rastlina+tip)` — potrdimo, da je **rastlina+tip**
primarni ključ, območje le filter.

## 7. Kaj NAMENOMA NE spreminjamo
- **Trata ostane območje-kot-subjekt** (brez umetne "rastline trava").
- Pojem **območja ostane** (grupiranje + trata + lokacija).
- Vreme, sync, obvestila, katalog, dvojnost Dnevnik/Opravila — vse ostane.
- To je **prefokus IA + UX + manjši poseg v shemo**, ne predelava.

## 8. Posledice po datotekah (delovni seznam)

**Dokumentacija:**
- [ ] `koncept.md` §7.8/7.9 — opravilo se veže na **subjekt** (rastlina ALI območje);
      §7.14 — `task.area_id` nullable + CHECK, `user_plant.area_id` nullable; §6.3 zavihek "Vrt".
- [ ] dnevnik odločitev v `koncept.md` — vnos 2026-06-03.

**Wireframe (`_v2`):**
- [ ] `02-quick-log_v2` — subjekt naprej (multi-select), rastlina v glavnem polju.
- [ ] `07-reminder-edit_v2` — subjekti namesto območja, območje izpeljano.
- [ ] `10-plant-picker_v2` — multi-select subjektov: uporabnikove rastline po območjih +
      trate + inline dodaj iz kataloga + odkljukaj območja za vrsto z več instancami.
- [ ] `04-areas_v2` → **Vrt** (rastline po območjih + trata).
- [ ] **nov** `plant-detail_v2` — zgodovina ene rastline.
- [ ] **nov** `plant-edit_v2` — dodaj/uredi osebno rastlino: vrsta (katalog) + osebno ime +
      **izbira lokacij (multi-select območij)** + kategorija + odstrani. Vstop: Vrt "＋",
      detajl rastline ⋯, inline dodaj iz izbirnika (10_v2).
- [ ] `01-home_v2` — seznami vodijo s subjektom.
- [ ] `17-task-detail_v2` / `17b-task-detail-done_v2` — bralni detajl našteje **vse subjekte**
      (tap → detajl rastline / območja); vreme in sredstva skupna (en dogodek, en odpis).
- [ ] `index.html` — dodaj _v2 zaslone v galerijo.

**Koda (drift + repo, ker je globina = shema):**
- [ ] `user_tables.dart` — odstrani `Tasks.areaId`/`Tasks.userPlantId`; nova tabela
      `TaskSubjects` (task_id, user_plant_id?, area_id?, CHECK vsaj eden); `UserPlants.areaId` nullable.
- [ ] `tasks_repository.dart` — `create`/`updateTask` sprejmeta **seznam subjektov**;
      `watchByArea`/`watchByPlant`/`watchLatestPerSubject` prek joina; sredstva/vreme ostanejo na task.
- [ ] `quick_log_screen.dart` / `task_form_screen.dart` / `plant_picker_screen.dart` —
      multi-select subjekt naprej, inline katalog, validacija "vsaj en subjekt".
- [ ] build_runner po spremembi sheme; `flutter analyze` + obstoječi testi zeleni (M2 testi se prilagodijo).

## 9. Naslednji koraki
1. Uskladitev tega dokumenta (po tvojem pregledu).
2. `_v2` wireframe za prizadete zaslone.
3. Posodobitev `koncept.md` + dnevnik odločitev.
4. Shema + repo + UI (ločen commit, po pregledu).
