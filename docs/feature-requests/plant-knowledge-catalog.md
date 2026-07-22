# FR-21 — Rastlinsko znanje / obogaten katalog (»Vodič«)

- **Status:** ideja / osnutek (neimplementirano) · 2026-07-22
- **Datum:** 2026-07-22
- **Področja:** katalog (`plant`, seed), izbirnik rastlin (10), detajl `user_plant`, i18n, sync (pull kataloga), monetizacija (Tendask+)
- **Vir zahteve:** konkurenčna analiza **posadi.si** (zavihek »Znanje«) · sorodno **T5** (`docs/povratne-informacije.md` — manjka podvrsta/varieta, »ogromen vir podatkov«)
- **Povezave:** `docs/koncept.md` §7.14 (podatkovni model), `tech-stack.md` §2 (sync katalog = oblak vir resnice, pull), `CLAUDE.md` »Sync, čas in shema« (katalog id-ji add-only), FR-20 (`tendask-plus-licensing.md` — če premium), FR-19 (element-povezava rastline)

---

## 1. Ideja in vrednost

Ob kliku na rastlino Tendask pokaže **strukturiran opis** (kako jo gojiti, kje, koliko,
kdaj, zalivanje, kolobar, sosedje, škodljivci, nasveti) — ne le ime + kategorijo.

Danes je naš katalog (128 vrst) **tanek**: ime, kategorija, labels, povezava na tipe opravil.
Uporabnik dobi *kaj* seje, ne *kako*. Konkurent **posadi.si** ima to kot glavno prednost
(zavihek »Znanje«). Tester je isto opazil pri T5/pobiranju: »za to potrebuješ ogromno količino
podatkov o vsaki rastlini«.

Vrednost: **zadrževanje + zaupanje** (uporabnik se ne odseli v drugo aplikacijo po nasvet) in
**most k drugim funkcijam** (opomniki, lunin koledar, motor »kaj sejati«).

## 2. Konkurenčni benchmark — posadi.si »Znanje« (posneto 2026-07-22)

Struktura njihovega opisa rastline (na oko, primer Artičoka):
- Naslov + **latinsko ime** + fotografije (**Vir: Wikipedia**)
- Sekcije: **Pridelava · Lokacija · Količina · Čas sajenja** (+ verjetno Zalivanje, Kolobar, Nasveti)
- Barvna koda **element** (koren/list/cvet/plod) + **rimska št. družine** (kolobar) + ★ priljubljeno
- **Zelišča = PRO** (osnovna zelenjava free)

Kaj delajo dobro: enotna struktura, jedrnato, slovensko, praktično (»Dve do štiri rastline na
osebo«). Kaj je šibko: brez razlage sistema, banner oglasi na vsakem zaslonu. **Naša priložnost =
enaka kakovost vsebine, a brez oglasov, offline, čist prikaz.**

## 3. Obseg vsebine (predlog sekcij na rastlino)

Fiksen, enoten nabor kratkih sekcij (typed model, ne prosti tekst po kodi):

| Sekcija | Vsebina | Prioriteta |
|---|---|---|
| Latinsko ime | binomsko | osnovna |
| Opis / uvod | 1–2 stavka kaj je | osnovna |
| Pridelava | setev/vzgoja sadik, tla | osnovna |
| Lokacija | sonce/senca, zaščita | osnovna |
| Čas sajenja | okno (SI klima!) | osnovna |
| Razmik / globina | cm | osnovna |
| Zalivanje / nega | | razširjena |
| Kolobar / družina | botanična družina (deli z FR-10/motor) | razširjena |
| Dobri / slabi sosedje | companion (posadi.si ima) | razširjena |
| Škodljivci / bolezni | pogosti + ukrep | razširjena |
| Spravilo | kdaj/kako pobrati (veže na T11 yield) | razširjena |
| Nasveti | 2–3 kratki | razširjena |

**Opozorilo o obsegu:** 128 vrst × ~12 sekcij × 3 jezike (sl/en/de) = **velik korpus**. To NI koda,
je **uredniško delo** — glej §4 (kako, in kje je meja LLM-a).

## 4. Vir vsebine: AI/LLM + OBVEZNA kuracija (osrednje vprašanje)

**Da, LLM naredi ta obseg izvedljiv** — prvi osnutek 128 × 12 × 3 bi ročno terjal tedne/mesece;
z LLM je stvar dni. **Ampak LLM je pospešek za osnutek, NE avtoritativni vir.** Razlogi (kritično):

- **Agronomska halucinacija je resnična in draga.** LLM samozavestno napiše napačen čas sajenja,
  razmik, temperaturo, združljivost. Uporabnik po napačnem nasvetu **uniči pridelek in izgubi
  zaupanje** — to je **hujše kot nič vsebine**. Isto previdnost gojimo pri M11 motorju in FR-19
  (»tradicija/nasvet, ne agronomska trditev«).
- **LLM privzeto meša cone/sezone.** Default nasvet je pogosto US/UK vrtnarstvo → napačni datumi za
  slovensko klimo (cona ~6b–7). Vsak »čas sajenja« mora biti umerjen na SI.
- **Zato proces = LLM osnutek → kuracija → seed:**
  1. LLM generira strukturiran osnutek na rastlino (enak nabor sekcij, sl kot vir + en/de).
  2. **Navzkrižna preverba** vsakega »trdega« podatka (datum, razmik, družina, sosed) proti
     **≥1–2 zanesljivima viroma** (semenske hiše, kmetijski inštitut/svetovalna služba, uveljavljeni
     priročniki) — ali strokovni (agronomski) pregled. Vsaj SI-specifični podatki.
  3. Enoten ton + dolžina; navedba vira (kot posadi.si »Vir: …«).
- **Enkraten strošek, NE runtime.** Vsebina se materializira v katalog kot obstoječi seed
  (`catalog_seed`) — **brez LLM klicev v aplikaciji** (offline-first, brez stroška/nepredvidljivosti).

**Pravno:** LLM-generiran + kuriran tekst je **lastna vsebina** (ne kopija posadi.si). **NE
prepisujemo** posadi.si opisov. Slike: bodisi lastne bodisi **Wikimedia Commons z licenco + pripisom**
(kot posadi.si »Vir: Wikipedia«) — nikoli scrapano brez licence.

## 5. Arhitektura (sledi obstoječemu katalogu)

- **Shema = additive-only.** Nova nullable polja/tabela ob `plant` (npr. `plant_guide` z opisnimi
  sekcijami), nikoli `NOT NULL` brez defaulta — stari APK-ji ob pull-u ne smejo crash-ati
  (CLAUDE.md »migracije«). Katalog id-ji **add-only** (že veže `user_plant.plant_id`).
- **Oblak = vir resnice, naprave pull-ajo** (kot obstoječi katalog od M6). Vsebinski vir =
  `lib/data/seed/catalog_seed.dart` → `tool/gen_catalog_sql.dart` → `supabase/seed/…`. **Klient
  ne piše** (RLS read-only).
- **Offline-first:** bundlan seed = fallback za prvi zagon brez signala (vrt) — enako kot 128 vrst zdaj.
- **Typed model (freezed), ne `Map<String,dynamic>`** po kodi; branje prek `catalogLabel()`-vzorca
  (`core/catalog_labels.dart`), nikoli ročni `jsonDecode` v widgetu (CLAUDE.md UI vzorci).
- **i18n:** vse sekcije prek slang; **obseg prevodov je glavni strošek** (glej §7).
- **Umestitev UI:** detajl rastline v izbirniku (10) + detajl `user_plant`; sekcije zložljive
  (velika presentation datoteka → ekstrahiraj widgete).

## 6. Free vs premium (TVOJ razmislek — okvir + priporočilo)

Konkurent daje **osnovne opise zastonj**, zelišča kot PRO. Če naš osnovni opis skrijemo za plačilo,
smo **slabši od brezplačnega konkurenta**. Zato:

| Opcija | Free | Premium (Tendask+) | Ocena |
|---|---|---|---|
| **A — vse free** | cel vodič | (premium so orodja: lunin planer, motor, več vrtov) | najmočnejši kavelj, a nič novega monetiziranega |
| **B — osnovni free, poglobljeni premium** ⭐ | opis, pridelava, lokacija, čas sajenja, razmik | zalivanje, kolobar, sosedje, škodljivci, spravilo, nasveti, sezonski koledar per rastlina | **priporočeno** — tekmuje s free konkurentom + jasna premium vrednost |
| **C — osnovni nabor free, razširjeni sklop premium** | zelenjava | zelišča, redke vrste, sadno drevje | kot posadi.si; a deli katalog po vrstah je manj eleganten |

**Priporočilo: opcija B.** Osnovni opis mora ostati free (paritet s konkurentom, gradi navado);
premium = **poglobljeni »Tendask vodič«** (napredni agronomski sloj + sezonski per-rastlina koledar,
ki se lepo veže z FR-19 lunin + M11 motor). Ujema FR-20 logiko: monetiziraj **dodano vrednost**,
ne osnovnega kavlja. **Zdaj je itak vse free** (billing še ne obstaja) — meja je zapis namere.

## 7. i18n / obseg (realen strošek)

- 128 × ~12 sekcij × 3 jezike. Tudi z LLM je **kuracija in prevodna konsistenca** glavno delo.
- Predlog faznosti: **najprej osnovne sekcije (§3) za sl**, nato en/de, nato razširjene. Ne vse naenkrat.
- Ključi npr. `plant.guide.<slug>.cultivation/location/timing/…`; slang po spremembi → `dart run slang`.

## 8. Odprta vprašanja

1. **Free/premium meja** (§6) — opcija A/B/C. Priporočilo: B.
2. **Fazni obseg** — koliko sekcij v MVP (samo osnovne?) in koliko vrst (vseh 128 ali podmnožica najprej).
3. **Slike** — lastne vs Wikimedia (licenca/pripis) vs brez slik v MVP (tekst-only ceneje in offline-lažje).
4. **Kdo kurira** — kdo naredi navzkrižno preverbo/strokovni pregled (§4.2); brez tega ne gre v release.
5. **Vir/atribucija** — ali navajamo vire per rastlina (transparentnost + pravna higiena).
6. **Deljena polja z motorjem** — družina/kolobar (§3) naj bo **eno polje**, ki ga uporabita FR-10/M11 in vodič.

## 9. Kaj je NAMERNO zunaj obsega

- **Runtime LLM v aplikaciji** (offline-first, strošek, halucinacije) — vsebina je pred-materializirana seed.
- **Kopiranje posadi.si / tujih opisov** (pravno) — lastna kurirana vsebina.
- **Per-varieta agronomika** (T5) — ostaja V2+; ta FR je per-vrsta, ne per-sorta.
- **Nepreverjene agronomske trditve** — vsak trd podatek gre skozi §4.2 ali ne gre.
