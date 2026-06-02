# Pametni motor predlogov — implementacijski načrt (roadmap)

> **Status:** ŽIV DOKUMENT · pred-implementacijska faza · OSNUTEK za pregled
> **Zadnja sprememba:** 2026-06-01
> **Povezano:** `koncept.md` §7.12 (taksonomija obvestil), **§7.13 (motor — koncept)**,
> §7.14 (podatkovni model), §8 (V2 percentili) · `opravila-in-rastline.md` (katalog + matrika).
> **Namen te datoteke:** razčleniti, *po katerih korakih* gremo v implementacijo pametnih
> predlogov (plast B), upoštevajoč **kateri podatki so na voljo iz katerega vira** in
> **agronomska pravila posameznih rastlin** (kdaj kaj potrebuje jablana, malina, paradižnik…).

---

## 0. Vodilna načela (recap, da se ne izgubimo)

1. **Ni AI, ni en "pameten algoritem".** Motor je **determinističen, rangiran cevovod
   pravil** nad skupnim slojem signalov. Razložljiv ("zakaj sem to dobil"), poceni, testabilen.
2. **"Združevanje" virov = rangiranje + straže, NE fuzija.** Vsak vir/pravilo proizvede
   *kandidatne predloge*; motor jih rangira po oceni, odstrani dvojnike, uveljavi straže
   (cooldown, vremenski proti-pogoji, upravičenost, spomin na Opusti), pošlje **top 1** ali digest.
3. **Opisno, ne predpisno, kjer je odgovornost.** Sezonska okna in skupnostni signali so
   *dejstva/okna* ("tipično okno", "X % v okolici"), ne ukazi → obide agronomsko odgovornost.
   Agronomska pravila izvirajo iz **kuriranih, navedenih virov**, nikoli iz halucinacij.
4. **Fazno po virih, ker so različno težki.** Vir B (lastna zgodovina) je lahek in brez
   odvisnosti → MVP. Vir A (sezonska okna) rabi agronomski sloj → faza 2. Vir C (skupnost)
   rabi gostoto → V2.

---

## 1. Razpoložljivi podatki — kaj imamo iz katerega vira

> To je **vhodni inventar** motorja. Vsak signal v §4 se napaja iz spodnjega.

### 1.A Uporabniški podatki (iz wireframov + model §7.14)
Vse že zbiramo skozi obstoječi flow (Hiter vnos 02 / Novo opravilo 07 / Opombe 18 / Območja 09 /
Zaloge 08 / Profil 12). Za motor so relevantni:

| Vir (tabela §7.14) | Polja, ki napajajo motor | Iz katerega zaslona |
|---|---|---|
| `task` | `task_type_id`, `area_id`, `user_plant_id?`, `date`, `status`, `recurrence`, `weather` (zamrznjen posnetek), `note` | 02, 07, 17/17b |
| `note` | `date`, `area_id?`, `user_plant_id?`, `text`, `weather` | 18, 03 |
| `area` | `type` (trata/meja/gredice/sadovnjak/rastlinjak/notranji…), **`protected`** (zaščiteno → izvzem iz vremenskih straž) → **upravičenost + izpostavljenost** | 04, 09 |
| `user_plant` | `plant_id` (kanonični) / `is_custom`, `personal_alias` → **katere rastline ima** | 09, 10 |
| `supply` / `recipe` | kaj ima doma + recepti → predlog lahko preveri zalogo | 08 |
| `profile` | `h3_r7/r6/r5`, `lang`, lokacija (za vreme) | 13, 16, 12 |
| `task_reminder` | plast A (uporabnikovi opomniki) — motor jih **upošteva pri dedup** | 19, 07 |
| `suggestion_log` | `rule_id`, `subject_key`, `last_suggested_at`, `dismissed_until` → **straže/cooldown** | (interno) |

**Ključno:** za MVP-pravila (faza 1) **ne rabimo nič novega zbirati** — vse to že nastaja
skozi normalno rabo. To je glavni razlog, da je vir B "zastonj".

### 1.B Vreme (Open-Meteo, klientsko; §7.7)
- **Napoved 24–72 h:** dež/padavine, temp, veter, vlaga → vremensko okno ("jutri suho").
- **Nazaj 24–48 h:** koliko dežja (ključno za škropljenje/foliarno).
- **Trenutno:** temp, vlaga, veter, stanje; opcijsko **temp. tal** in **ET₀**.
- **Klimatski normali:** **datum zadnje/prve pozebe** + povprečja → vir za **frost-anchor** (§3)
  in **klimatski koš** (Köppen / širinski pas). To je tisto, kar regionalizira koledar zastonj.

### 1.C Katalog opravil + rastlin (kurirano; `opravila-in-rastline.md`)
- `task_type`: `requires_subject`, **`weather_sensitive`**, `default_cadence` (ritem).
- `plant`: kategorija, kanonični ID + i18n.
- Matrika **kategorija ↔ tipi opravil** (katera opravila se sploh tičejo katere rastline).
- **MANJKA (gradiva v §3):** *kdaj* in *kako pogosto* posamezna rastlina potrebuje opravilo.

### 1.D Skupnost (V2; §8, `activity_agg`)
- Agregat **(H3 celica × teden v letu × tip opravila × klimatski koš × št. ločenih uporabnikov)**.
- Roll-up res-7→6→5 ob redki gostoti. Prag k-anonimnosti (ne prikaži koša z < N uporabniki).
- Da: "68 % v tvoji okolici je ta teden prvič pognojilo trato."

---

## 2. ⭐ Sloj agronomskih pravil rastlin (NOVO — srce vira A)

> Tvoja zahteva: *"upoštevaj pravila posameznih rastlin, poljščin, drevja in grmičevja —
> kdaj kaj potrebujejo."* To je nov **kuriran podatkovni sloj**, ki ga koncept doslej ni imel
> (imeli smo le grobo matriko kategorija↔opravilo + ritem na tipu opravila).

### 2.1 Problem granularnosti
Matrika pove *da* (jablano obrezuješ), ne *kdaj*. Toda **znotraj iste kategorije se časi
razlikujejo**: jablano obrezuješ pozimi v mirovanju, malino pa po obiranju. Zato rabimo
**dvonivojski** sloj (da kuracija ostane obvladljiva):

- **Nivo 1 — privzetek po kategoriji** (npr. "sadno drevje · obrez · pozno zimsko okno").
  Pokrije večino; malo vnosov.
- **Nivo 2 — izjema po vrsti** (override le tam, kjer se vrsta opazno razlikuje,
  npr. malina, breskev). Motor najprej išče pravilo vrste, sicer pade na kategorijo.

### 2.2 Predlog strukture (kurirana tabela `plant_task_rule`)
```
plant_task_rule = {
  scope:        'plant' | 'category',     // nivo 2 ali nivo 1
  ref_id:       plant_id | category_id,
  task_type_id,
  timing_anchor: enum {                    // KAKO je določen čas
      month_window     // okno tednov/mesecev, izraženo PO KLIMATSKEM KOŠU
    | frost_offset     // odmik od zadnje/prve pozebe (auto-regionalno!)
    | growth_stage     // relativno na PREJŠNJI korak/dogodek v verigi
    | cadence_only     // brez sezone, le ritem (npr. košnja: ko raste)
  },
  window:       { ... },                   // parametri glede na anchor (gl. spodaj)
  cadence:      npr. '1×/leto', '2×/leto', 'tedensko v sezoni',
  frost_gate:   bool,                       // ⊕ modifikator: ne pred mimo zadnje pozebe (ne glede na anchor)
  weather_guard: npr. 'suho + brez pozebe', 'tla > 8 °C',   // proti-pogoji (PRESKOČENI v protected območju)
  source_ref:   citat (svetovalna služba / etiketa / literatura),
  confidence:   'visoka' | 'srednja',
  message_key:  i18n predloga sporočila
}
```

**Parametri `window` po anchorju:**
- `month_window`: `{ start_week, end_week }` — **izražen po klimatskem košu**, ne po državi.
- `frost_offset`: `{ anchor: 'last_frost'|'first_frost', offset_min_d, offset_max_d }`.
  → datum pozebe pride iz Open-Meteo normalov → **isti zapis deluje v vsaki regiji**.
- `growth_stage`: `{ after_event: 'sow'|'prick_out'|'harden_off'|'harvest'|'bloom'|'dormant', offset_d }`
  → sidrano na **dejanski datum opravljenega prejšnjega koraka** (event-driven veriga).

**`frost_gate` (⊕ modifikator):** korak se sproži šele, ko je zadnja pozeba mimo — ne glede na
anchor. Motor vzame **kasnejšega** od (anchor-datum, datum-mimo-pozebe). Tako "sadike so pripravljene,
a počakaj pozebo" deluje samodejno (gl. presaditev v §2.3).

**Zaščiteni prostor (`area.protected`):** za opravila v zaščitenem območju motor **preskoči
`weather_guard`** (dež/pozeba sadik v hiši ne dosežejo). `frost_offset`/`frost_gate` **ostanejo** —
bistvo predsetve je priti pred pozebo, presaditev pa počakati nanjo.

### 2.3 Vzorčni vnosi (kažejo vse tri anchorje)

| Rastlina/kat. | Opravilo | Anchor | Okno / pravilo | Ritem | Straža |
|---|---|---|---|---|---|
| **Sadno drevje** (kat.) | obrez | `month_window` | pozno zimsko mirovanje (koš-odvisno) | 1×/leto | suho, brez hudega mraza |
| **Malina** (vrsta, override) | obrez | `growth_stage` | po obiranju (poletna) / pozimi (jesenska) | po tipu | — |
| **Sadno drevje** (kat.) | cepljenje | `month_window` ×2 | mirovanje (pozna zima–pomlad) + poletje (okuliranje) | sezonsko | suho, brez hudega mraza |
| **Paradižnik** | setev | `frost_offset` | 6–8 t **pred** zadnjo pozebo (notranja vzgoja) | sezonsko | temp. tal |
| **Paradižnik** | presaditev/sajenje | `frost_offset` | **po** zadnji pozebi | sezonsko | brez napovedane pozebe |
| **Trata** | spomladansko gnojenje | `cadence_only` + guard | ko trava raste | sezonsko | tla > ~8 °C, ne pred dežjem |
| **Lovorikovec** (živa meja) | obrez | `month_window` | pozna pomlad + poletje | ~2×/leto | izven pripeke/sonca |
| **Paradižnik** | predsetev (v hiši) | `frost_offset` | −6..8 t pred zadnjo pozebo | sezonsko | *(zaščiteno — guard preskočen)* |
| **Paradižnik** | pikiranje | `growth_stage` | po `sow` +2–3 t (prvi pravi listi) | po verigi | *(zaščiteno)* |
| **Paradižnik** | utrjevanje | `frost_offset` | −1..2 t pred zadnjo pozebo | enkratno | brez pozebe |
| **Paradižnik** | presaditev na prosto | `growth_stage` ⊕ `frost_gate` | po `harden_off`, a ne pred mimo pozebe | enkratno | brez pozebe/vetra |
| **Sadno drevje** | redčenje plodov | `growth_stage` | po cvetenju (junijsko trebljenje) | 1×/sezono | — |
| **Lončnice / občutljive** | prezimovanje | `frost_offset` (`first_frost`) | pred **prvo** pozebo → premik v zaščiteno | sezonsko (jesen) | preventiva pred mrazom |

> **Obseg:** kot pri katalogu rastlin (odločitev 2026-06-01, koncept §C) — **zdaj le vzorec za
> potrditev strukture**; poln nabor pravil se kurira v implementaciji (vir: nacionalne svetovalne
> službe, etikete, preverjena literatura). Ročno vnaprej NE širimo.

### 2.4 Odgovornost (kritično)
- Pravila so **opisna okna** ("tipično okno za tvojo okolico"), z **disclaimerjem**.
- Vsak vnos ima **`source_ref`** → revizijska sled, brez halucinacij (skladno s koncept §6.7, §7.13).
- Kjer ni zanesljivega vira, pravila **ne dodamo** (raje manj predlogov kot napačen).

---

## 3. Vir A brez "zajemanja regijskih koledarjev": frost-anchor

Namesto da zajemamo desetine avtorsko zaščitenih regijskih setvenih koledarjev:
1. Iz profilne lokacije izpeljemo **klimatski koš** + **datum zadnje/prve pozebe** (Open-Meteo normali).
2. Pravila tipa `frost_offset` se **avtomatsko regionalizirajo** (en zapis → vse regije).
3. Pravila tipa `month_window` so izražena **po klimatskem košu**, ne po državi.
4. Polobla obrne koledar (j. polobla +6 mes.) — že predvideno v §7.8.

→ "Zajamemo" eno majhno kurirano tabelo (§2), lokalni mraz/klima jo regionalizira. Kasneje
(vir C) jo skupnostni percentili **validirajo in finetunajo** z dejanskim vedenjem v okolici.

---

## 4. Signalni sloj (vmesnik med viri in pravili)

Pravila ne berejo surovih virov; berejo **normalizirane signale** (lažje testati, menjati vir):

| Signal | Iz vira | Primer |
|---|---|---|
| `weather.forecast` / `.recent` | 1.B | "naslednjih 48 h suho", "v 24 h padlo 12 mm" |
| `weather.soil_temp`, `.et0` | 1.B | "tla 9 °C" |
| `climate.frost_dates`, `.bucket` | 1.B | "zadnja pozeba ~15. apr", koš = Cfb |
| `history.last_done(subj, type)` | 1.A | "lani 18. maja gnojil trato" |
| `history.cadence(subj, type)` | 1.A + katalog | "košnja na ~7 dni → zamuja 4 dni" |
| `inventory.has(supply)` | 1.A | "ima ureo doma" |
| `eligibility.areas`, `.plants` | 1.A | "ima Trato in Sadovnjak z jablano" |
| `eligibility.protected` | 1.A | "ima Rastlinjak → vzgoja sadik mogoča; vremenske straže preskočene" |
| `chain.prev_step(subj, type)` | 1.A | "predsetev paradižnika opravljena 10. mar → pikiranje na vrsti" |
| `agronomy.window(plant,type)` | §2 + 3 | "okno obreza jablane: zdaj odprto" |
| `community.percentile(...)` | 1.D (V2) | "68 % v okolici že pognojilo" |
| `state.planned`, `.dismissed` | 1.A | "to že načrtovano" / "Opusti pred 3 dnevi" |

---

## 5. Anatomija pravila + tek motorja (konkretizacija §7.13)

**Pravilo** = `SPROŽILEC + KONTEKST + STRAŽE + sporočilo + akcija + ocena`.
**Dnevni paketni tek** (cron, ~6:00 po uporabnikovem času):

```
1. Naloži profil, območja, rastline, zgodovino, zaloge, suggestion_log.
2. Osveži signale (vreme za H3-celico, klimatski koš/pozebe).
3. Za vsako UPRAVIČENO pravilo × subjekt → oceni SPROŽILEC + KONTEKST → kandidat + ocena.
4. STRAŽE (filtri):
   - upravičenost (ima to območje/rastlino),
   - cooldown po (območje+rastlina+tip) — opravljeno v zadnjih N dneh? utišaj,
   - vremenski proti-pogoji (dež/mokro/napovedan dež → ne kosi),
   - dedup proti že načrtovanim opravilom in plast-A opomnikom,
   - spomin na Opusti (dismissed_until), "ne predlagaj tega" → ugasni pravilo.
5. Rangiraj po oceni; uveljavi frekvenčno kapico (max 1/dan ali digest).
6. Emit: push (FCM) + zapis na pas Domov (01); posodobi suggestion_log.
```

**Ocena (preprosta utež, ne ML):** vsota signalov (npr. vremensko okno odprto **+** osebna
obletnica **+** sezonsko okno odprto = višja ocena kot en sam signal). Uravnavamo ročno.

**Površina:** pas na **Domov (01)** z gumboma **Načrtuj** (ustvari načrtovano opravilo) /
**Opusti** (utiša). Povratna informacija hrani straže. Brez ločenega centra obvestil (§7.12).

---

## 6. Fazni načrt implementacije (koraki)

### Faza 1 — MVP motor: vir B + vreme *(z obstoječimi podatki, brez agronomskega sloja)*
**Kaj:** 3–4 deterministična pravila, ki tečejo **samo nad podatki, ki jih že zbiramo**:
- **R1 — Vremensko okno za škropljenje/foliarno:** `weather_sensitive` tip + napoved suho +
  nazaj brez dežja → "jutri primeren čas za tretiranje". Straže: ni dežja v 24–48 h, brez vetra.
- **R2 — "Lani tačas si…":** osebna obletnica iz `history.last_done` (± okno dni).
- **R3 — Zapadlo / na vrsti po ritmu:** `history.cadence` vs `default_cadence` (npr. košnja zamuja).
- **R4 (opc.) — Nizka zaloga ob predlogu:** če predlog rabi sredstvo in ga ni → opozorilo.

**Novi podatki:** samo `suggestion_log` (straže). Nič agronomske kuracije.
**Odvisnosti:** Open-Meteo klient, cron/edge funkcija, FCM, pas Domov (01).
**Testabilno:** unit testi pravil na sintetični zgodovini + vremenskih scenarijih (deterministično).
**Vrednost:** deluje že za 1 uporabnika, brez gostote, brez odgovornostnega tveganja.

### Faza 2 — Sezonska okna: vir A (agronomski sloj + frost-anchor)
**Kaj:**
- **R5 — sezonsko okno** iz `plant_task_rule` (§2) × klimatski koš/pozebe (§3): "okno obreza
  jablane se odpira" / "okno predsetve paradižnika čez ~2 tedna" / "okno cepljenja jablane" /
  **"prva pozeba se bliža → zaščiti/premakni lončnice"** (prezimovanje, `first_frost`).
- **R7 — veriga vzgoje sadik** (event-driven): opravljen korak (npr. predsetev, logiran z dejanskim
  datumom) sproži predlog naslednjega (pikiranje → utrjevanje → presaditev), z `frost_gate` na presaditvi.
  Teče v `protected` območju → vremenske straže preskočene (§2.2).
**Novi podatki:** kurirana tabela `plant_task_rule` (struktura zdaj, seed v tej fazi) +
izpeljava klimatskega koša/pozeb iz Open-Meteo normalov.
**Odvisnosti:** kuracija agronomskih oken z navedenimi viri (§2.4) + razširjen katalog rastlin.
**Testabilno:** za dane (koš, pozeba, rastlina) pričakovano okno; polobla-aware test;
veriga: opravljen korak K → pravilen datum/okno koraka K+1.
**Tveganje:** odgovornost → opisna okna + disclaimer + source_ref.

### Faza 3 — Skupnostni percentili: vir C *(V2, rabi gostoto)*
**Kaj:** **R6 — percentil okolice:** "X % v tvoji okolici je ta teden …" (§8).
**Novi podatki:** `activity_agg` (cron agregat) + roll-up res-7→6→5 + prag k-anonimnosti.
**Odvisnosti:** gostota uporabnikov (cold-start strategija §8); H3 celice iz profila.
**Testabilno:** agregacija/roll-up nad sintetično populacijo; GDPR prag.
**Vrednost:** najmočnejši diferenciator; hkrati validira/finetunea okna iz faze 2.

### Faza 4 — Poliranje *(opcijsko, sproti)*
Uravnavanje ocen/uteži, digest vs. enojni push, A/B pragov, (zelo kasneje) AI le za
preslikavo prostih imen → kanonično (post-V2), nikoli za agronomski nasvet.

---

## 7. Tehnična izvedba (skladno s §7.11)

- **Tek:** Supabase **cron (pg_cron)** ali **Edge Function**, dnevno po uporabnikovem času.
- **Vreme:** Open-Meteo — klientsko za UI; za strežniški tek motorja po H3-celici (brez koordinat).
- **Push:** Firebase **FCM** (strežniški). Plast A (opomniki) ostaja lokalna/deterministična.
- **Straže:** `suggestion_log` (cooldown, dismissed_until, last_suggested_at).
- **H3:** celico računa naprava (res-7), shrani r7/r6/r5; roll-up = navaden `GROUP BY` (brez `h3-pg`).
- **Strošek:** paketno/periodično → poceni (materializiran pogled za percentile).

---

## 8. Odprta vprašanja / odločitve, ki jih rabimo

1. **Parametri faze 1:** N dni cooldown po (območje+rastlina+tip); vremenski pragovi
   (koliko mm dežja = "mokro"; koliko ur suho za škropljenje); širina obletničnega okna (± dni).
2. **Privzeti ritmi:** dokončati `default_cadence` na tipih opravil (`opravila-in-rastline.md` §D).
3. **Agronomski viri (faza 2):** kateri kurirani viri so dovolj zanesljivi za `source_ref`
   (nacionalne svetovalne službe? etikete? literatura?) — pravna/odgovornostna presoja.
4. **Frekvenčna kapica:** max 1 ne-opomnik/dan vs. dnevni digest — privzetek + stikalo (22).
5. **Klimatski koš — natančnost:** Köppen + pozebe dovolj, ali rabimo še nadm. višino (mikroklima §8)?
6. **k-anonimnost (faza 3):** minimalni N ločenih uporabnikov na koš pred prikazom percentila.

---

## 9. Povezave
- `koncept.md` §7.12 (3 vrste obvestil), §7.13 (motor — koncept), §7.14 (model), §8 (V2 percentili).
- `opravila-in-rastline.md` — katalog tipov opravil + rastlin + matrika (vir za seed + sidro §2).
- Wireframe: `01-home.html` (pas predlogov), `19–22` (obvestila), `14-actions.html` (akcije).
