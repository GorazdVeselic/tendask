# Opravila in rastline — katalog (osnutek)

> **Status:** ŽIV DOKUMENT · osnutek kurirane baze za MVP
> **Povezano:** `koncept.md` §6.1/6.3 (podatkovno jedro), §7.7 (kanonični ID + i18n,
> nadzor kataloga), §7.8 (`zahtevaSubjekt`), §7.13 (vreme-občutljivost za pametne predloge),
> **§7.14 (preslikava v Supabase tabele — ta datoteka je vir za seed)**.
> **Opomba:** prevodi (DE) in znanstvena imena so osnutek — pred uporabo preveriti.

---

## 0. Načela (povzetek iz koncepta)

- Vse shranjeno kot **kanonični ID** (jezikovno nevtralen) + oznake **{sl, en, de}**.
  UI prikaže v jeziku uporabnika; podatki ostanejo nevtralni (nujno za V2 čezmejno primerjavo).
- **Tip opravila** ima zastavico **`zahtevaSubjekt`**: če `da`, ob vnosu ponudi izbiro rastline
  (obrez/tretiranje/pobiranje/sajenje…); pri trati subjekt = območje (`ne`).
- **`vreme`** = ali je tip vremensko občutljiv (vhod za pametna pravila §7.13).
- **Lasten vnos** (rastline ali izraza) = **zaseben**, ne gre v skupnost (§7.7). Osebni alias dovoljen.

---

## A) Tipi opravil — privzeti katalog

### A.1 Jedro (vsi vrtovi)

| ID | ikona | SL | EN | DE | kategorija | zahtevaSubjekt | tipičen ritem | vreme |
|----|:--:|----|----|----|------------|:--:|------|:--:|
| `mow` | 🌱 | Košnja | Mowing | Mähen | nega trate | ne (trata) | tedensko (sezona) | ✅ |
| `water` | 💧 | Zalivanje | Watering | Gießen | splošno | opcijsko | po potrebi | ✅ |
| `fertilize` | 🧪 | Gnojenje | Fertilizing | Düngen | nega | opcijsko¹ | sezonsko / večkrat | ✅ |
| `prune` | ✂️ | Obrez | Pruning | Schnitt | nega rastlin | **da** | 1–2×/leto | ◻️ delno |
| `plant` | 🪴 | Sajenje | Planting | Pflanzen | zasaditev | **da** | enkratno / sezonsko | ✅ |
| `sow` | 🌾 | Setev | Sowing | Aussaat | zasaditev | **da** | sezonsko | ✅ (temp. tal) |
| `treat` | 🐛 | Tretiranje / škropljenje | Treatment | Behandlung | varstvo | **da**¹ | po potrebi | ✅ (suho, brez vetra) |
| `harvest` | 🧺 | Pobiranje | Harvest | Ernte | pridelek | **da** | sezonsko | ❌ |
| `weed` | 🌿 | Pletje / okopavanje | Weeding | Jäten | nega | opcijsko | po potrebi | ◻️ delno |
| `mulch` | 🍂 | Zastiranje | Mulching | Mulchen | nega tal | opcijsko | sezonsko | ❌ |
| `graft` | 🔗 | Cepljenje | Grafting | Veredeln / Pfropfen | nega rastlin | **da** | sezonsko (mirovanje; okuliranje poleti) | ◻️ delno |

¹ Gnojenje/tretiranje: pri trati subjekt = območje; pri rastlini = `da`.

² Cepljenje: pretežno **sadno drevje**; tudi **vinska trta**, **vrtnice**, nekatero okrasno grmovje.
  Časovno dvoje oken (`month_window`, koš-odvisno): **prebujanje/mirovanje** (cepljenje v cep/kopulacija,
  pozna zima–pomlad) in **poletje** (okuliranje / cepljenje na popek). Možna kasnejša razdelitev na
  `graft` + `bud_graft` (okuliranje), za MVP en tip z dvema oknoma.

### A.2 Trata-specifična (lawn-care persona, §3)

| ID | ikona | SL | EN | DE | zahtevaSubjekt | tipičen ritem | vreme |
|----|:--:|----|----|----|:--:|------|:--:|
| `aerate` | 🕳️ | Prezračevanje (aeriranje) | Aeration | Aerifizieren | ne | 1–2×/leto | ✅ (vlažna tla) |
| `scarify` | 🪮 | Vertikutiranje (rezkanje ruše) | Scarifying | Vertikutieren | ne | 1×/leto (pomlad) | ✅ |
| `overseed` | 🌱 | Dosejevanje | Overseeding | Nachsaat | ne (trava) | pomlad / jesen | ✅ (temp. + vlaga) |
| `topdress` | 🏖️ | Peskanje (top-dressing) | Top-dressing | Topdressing | ne | 1×/leto | ❌ |
| `roll` | 🛞 | Valjanje | Rolling | Walzen | ne | pomlad | ✅ (vlažna tla) |
| `lime` | ⚪ | Apnjenje | Liming | Kalken | ne | po pH | ❌ |
| `lawn_weed_moss` | 🚫 | Tretiranje proti plevelu/mahu | Weed & moss control | Unkraut-/Moosbekämpfung | ne | sezonsko | ✅ |

### A.3 Vzgoja sadik (zaščiteni prostor — rastlinjak / "v hiši", §7.7 `protected`)

> **Veriga (MVP, event-driven):** vsak opravljen korak sproži predlog naslednjega; časi so
> sidrani na pozebo (frost-anchor) ali na prejšnji korak. Poteka v območju z `protected=true`,
> zato so koraki **izvzeti iz vremenskih straž** (dež/pozeba ne dosežejo sadik) — razen `harden_off`
> in `transplant`, ki sta **frost-gated** (čakata, da mine zadnja pozeba).

| ID | ikona | SL | EN | DE | zahtevaSubjekt | tipičen ritem / sidro | vreme |
|----|:--:|----|----|----|:--:|------|:--:|
| `start_seedlings` | 🪴 | Predsetev / vzgoja sadik | Starting seedlings (indoor sow) | Voranzucht | **da** | ~6–8 t **pred** zadnjo pozebo | zaščiteno (frost-anchor) |
| `prick_out` | 🌿 | Pikiranje | Pricking out / Potting on | Pikieren | **da** | ob prvih pravih listih (≈ setev +2–3 t) | zaščiteno |
| `harden_off` | 🌤️ | Utrjevanje (zakaljevanje) | Hardening off | Abhärten | **da** | ~1–2 t pred presaditvijo | ◻️ delno (brez pozebe) |
| `transplant` | 🌱 | Presaditev na prosto | Transplanting out | Auspflanzen | **da** | **po** zadnji pozebi (frost-gate) | ✅ (brez pozebe, brez vetra) |

> Sorodno: `sow` = **direktna** setev na prosto; `plant` = sajenje (kupljene sadike / trajnice).
> `transplant` = presaditev lastnih vzgojenih sadik na prosto (vrh verige).

### A.4 Dodatna nega / sezonska zaščita

| ID | ikona | SL | EN | DE | kategorija | zahtevaSubjekt | tipičen ritem / sidro | vreme |
|----|:--:|----|----|----|------------|:--:|------|:--:|
| `stake` | 🪵 | Privezovanje / opora | Staking / Tying | Aufbinden / Stützen | nega rastlin | **da** | po potrebi (med rastjo) | ❌ |
| `thin_fruit` | 🍏 | Redčenje plodov | Fruit thinning | Ausdünnen | nega rastlin (sadno) | **da** | po cvetenju (junijsko trebljenje) | ❌ |
| `repot` | 🪴 | Presaditev lončnic | Repotting | Umtopfen | lončnice | **da** | pomlad / po potrebi | ❌ |
| `overwinter` | ❄️ | Prezimovanje / zaščita pred zmrzaljo | Overwintering / Frost protection | Überwintern / Frostschutz | sezonska zaščita | **da** | **pred prvo pozebo** (jesen) | ✅ (`first_frost`) |

> **`overwinter`** je **zrcalo presaditve**: premik lončnic v zaščiten prostor / pokrivanje pred
> PRVO pozebo (`frost_offset` na `first_frost`) — odličen vhod za pametni predlog ("prva pozeba se
> bliža → zaščiti/premakni občutljive rastline"). `repot`/`overwinter` pogosto v `protected` območju.

> Ikone so osnutek (nekatere brez idealnega emojija) — finalno oblikovanje kasneje.

---

## B) Katere rastline (kategorije) se tičejo katerih opravil

| Kategorija | Tipični tipi opravil |
|------------|----------------------|
| **Trata** | košnja · zalivanje · gnojenje · aeriranje · vertikutiranje · dosejevanje · valjanje · peskanje · apnjenje · proti plevelu/mahu |
| **Sadno drevje** | obrez · **cepljenje** · **redčenje plodov** · tretiranje · gnojenje · pobiranje · zalivanje · zastiranje |
| **Jagodičevje** | obrez · tretiranje · gnojenje · pobiranje · zalivanje · zastiranje |
| **Zelenjava** | **vzgoja sadik** (predsetev · pikiranje · utrjevanje · presaditev) · setev · sajenje · **privezovanje/opora** · zalivanje · gnojenje · okopavanje · tretiranje · pobiranje · zastiranje |
| **Zelišča** | **vzgoja sadik** (predsetev · pikiranje · utrjevanje · presaditev) · sajenje · setev · zalivanje · pobiranje |
| **Okrasne / živa meja** | obrez · tretiranje · gnojenje · zalivanje · sajenje · *cepljenje (vrtnice)* · *prezimovanje* |
| **Lončnice / balkonske / sobne** | presaditev lončnic · zalivanje · gnojenje · **prezimovanje** · privezovanje/opora |

> **Tipi območij** (§7.7): zunanja — *trata · živa meja · gredice · sadovnjak · zasaditve* ·
> zaščitena (`protected=true`) — **rastlinjak · notranji prostor** (okenska polica…). Vzgoja sadik
> teče v zaščitenem območju; presaditev premakne subjekt na zunanje (gredica/sadovnjak).

---

## C) Rastline — kurirani katalog (VZOREC)

> ⚠️ **Odločitev (2026-06-01):** spodnjih ~35 je **le vzorec za potrditev strukture** (ID + i18n
> + kategorije). **Celoten katalog (širša taksonomija + 100–200+ vrst) se naredi v implementaciji
> v enem koraku** — seed iz **Wikidata/GBIF** (z atribucijo, §7.7), nato kuracija. Ročno zdaj NE
> širimo (podvojeno delo). Tudi **kategorije spodaj niso dokončne** — ob seedanju jih razširimo
> (npr. trajnice, okrasno grmovje, vzpenjavke, enoletnice/cvetlice, lončnice…).

### C.1 Sadno drevje
| id | SL | EN | DE | znanstveno | ikona |
|----|----|----|----|-----------|:--:|
| `apple` | jablana | apple | Apfel | *Malus domestica* | 🍎 |
| `pear` | hruška | pear | Birne | *Pyrus communis* | 🍐 |
| `plum` | sliva | plum | Pflaume/Zwetschge | *Prunus domestica* | 🫐 |
| `cherry` | češnja | cherry | Kirsche | *Prunus avium* | 🍒 |
| `peach` | breskev | peach | Pfirsich | *Prunus persica* | 🍑 |

### C.2 Jagodičevje
| id | SL | EN | DE | znanstveno | ikona |
|----|----|----|----|-----------|:--:|
| `raspberry` | malina | raspberry | Himbeere | *Rubus idaeus* | 🍇 |
| `strawberry` | jagoda | strawberry | Erdbeere | *Fragaria × ananassa* | 🍓 |
| `currant` | ribez | currant | Johannisbeere | *Ribes rubrum* | 🔴 |
| `blueberry` | borovnica | blueberry | Heidelbeere | *Vaccinium corymbosum* | 🫐 |

### C.3 Zelenjava
| id | SL | EN | DE | znanstveno | ikona |
|----|----|----|----|-----------|:--:|
| `tomato` | paradižnik | tomato | Tomate | *Solanum lycopersicum* | 🍅 |
| `lettuce` | solata | lettuce | Salat | *Lactuca sativa* | 🥬 |
| `potato` | krompir | potato | Kartoffel | *Solanum tuberosum* | 🥔 |
| `radish` | redkvica | radish | Radieschen | *Raphanus sativus* | 🌶️ |
| `cucumber` | kumara | cucumber | Gurke | *Cucumis sativus* | 🥒 |
| `pepper` | paprika | pepper | Paprika | *Capsicum annuum* | 🫑 |
| `bean` | fižol | bean | Bohne | *Phaseolus vulgaris* | 🫘 |
| `carrot` | korenje | carrot | Karotte/Möhre | *Daucus carota* | 🥕 |
| `cabbage` | zelje | cabbage | Kohl | *Brassica oleracea* | 🥬 |
| `zucchini` | bučke | zucchini | Zucchini | *Cucurbita pepo* | 🥒 |
| `onion` | čebula | onion | Zwiebel | *Allium cepa* | 🧅 |
| `garlic` | česen | garlic | Knoblauch | *Allium sativum* | 🧄 |

### C.4 Zelišča
| id | SL | EN | DE | znanstveno | ikona |
|----|----|----|----|-----------|:--:|
| `basil` | bazilika | basil | Basilikum | *Ocimum basilicum* | 🌿 |
| `parsley` | peteršilj | parsley | Petersilie | *Petroselinum crispum* | 🌿 |
| `rosemary` | rožmarin | rosemary | Rosmarin | *Salvia rosmarinus* | 🌿 |
| `thyme` | timijan | thyme | Thymian | *Thymus vulgaris* | 🌿 |
| `sage` | žajbelj | sage | Salbei | *Salvia officinalis* | 🌿 |
| `chives` | drobnjak | chives | Schnittlauch | *Allium schoenoprasum* | 🌿 |

### C.5 Okrasne / živa meja
| id | SL | EN | DE | znanstveno | ikona |
|----|----|----|----|-----------|:--:|
| `cherry_laurel` | lovorikovec (češnjev lovor) | cherry laurel | Kirschlorbeer | *Prunus laurocerasus* | 🌿 |
| `thuja` | tuja | thuja | Thuja/Lebensbaum | *Thuja occidentalis* | 🌲 |
| `hornbeam` | gaber | hornbeam | Hainbuche | *Carpinus betulus* | 🌳 |
| `beech` | bukev | beech | Buche | *Fagus sylvatica* | 🌳 |
| `box` | pušpan | box | Buchsbaum | *Buxus sempervirens* | 🌿 |
| `rose` | vrtnica | rose | Rose | *Rosa* | 🌹 |

### C.6 Trava (trata)
| id | SL | EN | DE | znanstveno | ikona |
|----|----|----|----|-----------|:--:|
| `lawn_grass` | travna ruša (mešanica) | lawn grass | Rasen | *Lolium perenne, Poa pratensis, Festuca* | 🌱 |

> Pri trati je subjekt = območje (trata), ne posamezna rastlina (§7.8).

---

## D) Odprto / TODO za ta katalog

**→ Razširitev kataloga = OPRAVLJENO v M9.6 (2026-06-07).** Katalog razširjen na **128 vrst čez 12
kategorij** (lawn, fruit_tree, berries, vegetable, herbs, perennial, shrub, climber, bulb, conifer, hedge,
houseplant). Vir resnice = `lib/data/seed/catalog_seed.dart`; ta tabela ostaja le zgodovinski vzorec.
- [x] **Taksonomija + obseg:** kategorije razširjene + 128 vrst. Metoda: kuracija SL/EN/DE (pogovorna imena)
      + **GBIF** preverba znanstvenih imen + **Wikidata** navzkrižna preverba SL imen (batch SPARQL).
- [x] **DE prevodi + znanstvena imena** preverjeni (GBIF match API; Wikidata DE oznake).
- [ ] Dodati **sloj sinonimov/aliasov po jezikih** (npr. „paradajz" → `tomato`), §7.7. *(plant_synonym tabela
      obstaja, a še prazna — naslednji korak po potrebi.)*
- [ ] Finalne **ikone** (nekatere vrste delijo generičen 🌿/🌸/🌲 emoji — dovolj za MVP).

**Lahko že prej (ni odvisno od obsega vrst):**
- [ ] Privezati **privzeta sredstva/recepte** na tipe (gnojenje/tretiranje) — povezava z Zalogami.
- [ ] Določiti **privzete rotacije/ritme** za pametna pravila (§7.13: cooldown N dni).
