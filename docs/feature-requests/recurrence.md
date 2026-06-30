# FR-5 — Ponavljanje opravil (MINIMALNI MVP)

> Status: **spec usklajen** (2026-06-30). Obseg = *materializiraj-naslednjo-instanco-ob-dokončanju*.
> Vir odločitev: pogovor 2026-06-30 (frekvence, sidro, konec) + razčlemba kode (FAZA 0)
> + pregled arhitekt/PM 2026-06-30 (odločitve D1–D6, glej §13).

## 1. Obseg

Uporabnik lahko na opravilu (status **čaka**) vklopi ponavljanje. Ko opravilo
označi kot **opravljeno**, se samodejno ustvari **ena** naslednja instanca z istim
tipom, subjekti, opombo in opomniki, premaknjena za interval naprej. Aktivno
opravilo je vedno **samo eno** (naslednje se rodi šele ob dokončanju trenutnega);
to invarianto eksplicitno varuje tudi blokada reverta (§5.4, D1).

### Ponujene frekvence (korak »Kdaj«)
- **Dnevno** = +1 dan
- **Tedensko** = +7 dni
- **Na N dni** = +N dni (poljuben interval, npr. 14)

Ker je sidro načrtovani datum in mesečnega ponavljanja ni, se vse tri reducirajo
na **»+N dni«** → en sam številčni model (`everyDays`), brez `freq` enuma in brez
koledarske mesečne aritmetike.

### Sidro naslednjega datuma
**Od načrtovanega datuma** opravljenega opravila (ne od trenutka dokončanja):
`naslednje = načrtovani_datum + everyDays`, **ohrani uro**. Zamuda pri dokončanju
NE premakne termina (»vsak ponedeljek« ostane ponedeljek).

### Konec serije
- Privzeto: **v nedogled** (nova instanca ob vsakem dokončanju).
- Neobvezno: **»ponovi določeno število krat«** (D4, popravljeno 2026-06-30) →
  uporabnik vnese **število ponovitev** (R ≥ 1 = kolikokrat se opravilo še ponovi
  po trenutnem). To je natanko `remaining`. Serija tako ustvari R dodatnih instanc
  (skupaj R+1). Zadnja instanca nima `recurrence` (D2), zato je vidno, da se ne bo
  ponovila. Ustavljanje med tekom: **⋯ → »Ustavi ponavljanje«** (ne brisanje).

## 2. NE-obseg (namerno izpuščeno za MVP)

| Izpuščeno | Zakaj |
|-----------|-------|
| Serijsko urejanje (»to / to in naprej / vse«) | Klasična koledarska močvara; pri modelu »ena naslednja naenkrat« ni potrebno. |
| Izjeme / preskoči-termin | Uporabnik preprosto preloži/izbriše posamezno instanco. |
| Mesečno / letno / RRULE (RFC 5545) | YAGNI; +N dni pokrije vrtne ritme. Add-only razširljivo kasneje. |
| Pred-materializacija več instanc vnaprej | Množi vrstice in sync; ena naprej zadošča. |
| Razrešitev konfliktov s pametnim motorjem (M11) | M11 ni na `main`. `series_id` (§3, D3) naredi bodočo spravo deterministično — glej §11. |
| Ponavljanje na opravilu z `done` ob vnosu (logiranje preteklosti) | Ponavljanje je dovoljeno samo na `waiting` (§7.9). |
| Revert-undo, ki pobriše rojeno instanco | D1: za MVP revert **prepovemo** (ne brišemo otroka); `series_id` to kasneje omogoči. |

## 3. Podatkovni model

Dva nosilca stanja na `task`:

1. **`task.recurrence`** (obstoječ nullable `TEXT` v drift / `JSONB` v Supabase) —
   JSON niz pravila; `null` = enkratno (ali zadnja v končni seriji).
2. **`task.series_id`** (NOVA nullable `TEXT` kolona, D3) — stabilen UUID, skupen
   vsem instancam ene serije. `null` = ni del serije. Generiran na napravi ob
   vklopu ponavljanja, **podedovan** v vsako rojeno instanco.

> **Migracija:** ena **additive** sprememba (nullable `series_id` v drift + Supabase).
> Nullable, brez backfilla, stari APK jo ignorira kot neznano polje (kot `recurrence`)
> → expand-only, varno za živo bazo. `recurrence` kolona že obstaja (brez sprememb).

### Oblika JSON (`recurrence`)
```json
{ "everyDays": 7, "remaining": 3 }
```
- `everyDays` (int ≥ 1) — interval v dneh.
- `remaining` (int ≥ 1, **neobvezno**) — koliko nadaljnjih instanc bo sledilo
  **po tej**. `null` = neomejeno. **Vrednost `0` se nikoli ne shrani** (D2): namesto
  zadnje instance z `remaining:0` dobi ta `recurrence = null`.

### Semantika štetja (D2 + D4, UI popravljen 2026-06-30)
- UI polje = **število ponovitev** R (R ≥ 1) = `remaining` neposredno (brez ±1).
  »R ponovitev« pomeni R dodatnih instanc po trenutni (skupaj R+1). Prazno/neveljavno
  polje (R < 1 ali prazen interval) **blokira »Naprej«** + pokaže napako pod poljem.
- Ob dokončanju instance z `recurrence = r`:
  - `r == null` → ni nove instance (enkratno ali že zadnja).
  - `r.remaining == null` → nova instanca z `recurrence = {everyDays, remaining: null}` (neskončno).
  - `r.remaining > 1` → nova instanca z `recurrence = {everyDays, remaining: remaining - 1}`.
  - `r.remaining == 1` → nova instanca z `recurrence = null` (to je zadnja; brez nadaljevanja).
- **Invarianta (D2):** `recurrence != null` ⇔ »po tej bo še vsaj ena« → značka serije
  (§7) nikoli ne laže.

### Typed model (brez `Map<String,dynamic>` po kodi)
Nov majhen nespremenljiv razred `Recurrence` (v `features/tasks/domain/recurrence.dart`):
```dart
class Recurrence {
  const Recurrence({required this.everyDays, this.remaining});
  final int everyDays;
  final int? remaining;

  /// Tolerant parse: invalid/empty/legacy → null (one-off). Never throws.
  static Recurrence? tryParse(String? raw);
  String encode();            // JSON string for repo
  Recurrence? next();         // child's recurrence; null = child is the last
}
```
- `tryParse` je **tolerantni parser** (neznana/manjkajoča polja → razumen default;
  `everyDays < 1`, `remaining < 1` (razen null) ali ne-JSON → `null`/normalizirano).
  Zrcali pravilo »tolerantni parser na obeh straneh sync«.
- `next()` vrne `recurrence` za **rojeno** instanco po pravilih zgoraj (`null` =
  rojena je zadnja). Klicalec spawn-a otroka takrat, ko `r != null`.
- UI in repo bereta `Recurrence`, **nikoli surovega JSON/Map**.

## 4. Generator naslednjega datuma (čista funkcija)

`features/tasks/domain/recurrence.dart`:
```dart
/// Next occurrence date, anchored on the *scheduled* date (not completion).
/// Civil-day arithmetic keeps wall-clock time → DST-safe. Pure: no Clock/now().
DateTime nextOccurrenceDate(DateTime scheduledLocal, int everyDays) =>
    DateTime(scheduledLocal.year, scheduledLocal.month,
             scheduledLocal.day + everyDays,
             scheduledLocal.hour, scheduledLocal.minute);
```
- **Lokalna** aritmetika polj (`day + everyDays`) → `DateTime` normalizira prelive
  meseca/leta; ohrani uro/minuto čez DST. Repo poskrbi za `.toUtc()` ob zapisu.
- Čista, brez `Clock` (sidro je `task.date`, ne `now()`) → trivialno testabilna.

## 5. Spremembe repozitorija (`tasks_repository.dart`)

### 5.1 `create(...)`
Že sprejema `String? recurrence`. **Dodaj** `String? seriesId` parameter (uporablja
ga le `_materializeNext` za dedovanje); UI ga ne poda. Če je `recurrence != null` in
`seriesId == null`, repo generira nov UUID (serija se rodi). Klicalec poda
`recurrence?.encode()`.

### 5.2 `updateTask(...)`
**Dodaj** `String? recurrence` parameter (in ga zapiši). **`series_id` NI parameter**
(UI ga ne pozna) — repo ga **derivira** iz `recurrence` + obstoječega stanja vrstice
(implementirano: bere trenutno vrstico, glej D5 pravila). Tako klicalcem ni treba
poznati serijske identitete.
*Opomba:* trenutno `updateTask` `recurrence` sploh ne piše → vrednost se ob editu
**ohrani, a ni urejljiva**; naloga je narediti polje **urejljivo** (ne »nehati izgubljati«).
Pravila (D5):
- vklop ponavljanja na opravilu brez serije → dodeli nov `series_id`;
- izklop ponavljanja (`recurrence → null`) → `series_id = null` (instanca zapusti serijo);
- sprememba `everyDays` → `remaining` ostane nedotaknjen;
- urejanje »konec po N« → prepiši `remaining = N - 1`.

### 5.3 `complete(id)`
Po obstoječi logiki (status→done, odpis zalog, vreme):
- preberi `task.recurrence` → `Recurrence.tryParse`;
- če `null` → nič (kot doslej);
- sicer izračunaj `nextOccurrenceDate(task.date.toLocal(), r.everyDays)`, pridobi
  subjekte + opomnike trenutne instance, in **znotraj iste transakcije** ustvari novo
  `waiting` instanco z `recurrence = r.next()?.encode()` (`null`, če je rojena zadnja)
  in **istim `series_id`** (podedovan).
- **Atomarnost:** rojstvo naslednje je del `complete()` transakcije; če spodleti,
  se odpis zalog + done **razveljavita** (eno opravilo ne sme pustiti pol-stanja).
- Vreme se zamrzne **samo** za dokončano instanco (`_captureWeather(id)`), ne za
  novo (nova je `waiting` → brez posnetka, po §7.10).

### 5.4 `revertToWaiting(id)` — blokada (D1)
Ker `complete()` na ponavljajočem opravilu **takoj rodi** naslednjo instanco, bi revert
ustvaril dve aktivni instanci iste serije (kršitev §1). Zato:
- če `task.status == done && task.recurrence != null` → **revert prepovej** (gumb
  onemogočen / blokiran z mirnim toastom; besedilo §8).
- sicer → kot doslej.
- *Sprejeto za MVP:* če je uporabnik vmes ročno pobrisal rojeno instanco, je revert
  vseeno blokiran (rahlo prestrogo). Pravi »undo« = pobriši novo instanco v seznamu.
  Natančnejši revert (prek `series_id`) je bodoča izboljšava.

### 5.5 Helper `_materializeNext(...)`
Privatna metoda — ekstrahiran skupni del rojstva instance (kopiranje subjektov/opomnikov,
prenos `series_id`), da `complete()` ostane berljiv. *Opomba:* `duplicate()` že dela
skoraj isto; če se vzorec ponovi ≥3×, poenoti — za zdaj le ta dva klicalca, zato
pazljiva ekstrakcija helperja (ne hierarhije).

## 6. Sync (ena additive migracija)

- `remote_mappers.dart`: `recurrence` se že (de)serializira (push `_jsonb`, pull `_text`).
  **Dodaj** `series_id` v `taskToRemote` (`'series_id': r.seriesId`) in `taskFromRemote`
  (`seriesId: Value(r['series_id'] as String?)`) — tolerantno, nullable.
- Nova instanca = navadna `task` vrstica (`sync_status = pending`) → gre prek obstoječega
  push/pull, brez posebne logike. LWW velja kot za vsako vrstico.
- **FK vrstni red** ostane (`task` → `task_reminder`/`subject`); rojstvo je v eni
  transakciji, zato je lokalno konsistentno pred sync.
- **Migracija** (additive): `alter table task add column series_id text;` (Supabase)
  + nova nullable kolona v drift `Tasks`. Brez `NOT NULL`, brez backfilla.
- Stari APK brez FR-5: bere `recurrence`/`series_id` kot neznani polji → tolerantni
  parser ju ignorira, opravilo deluje kot enkratno. **Additive-safe.**

## 7. UI/UX (podrobno v FAZI 2)

- Korak **»Kdaj«** (`when_step.dart`): pod statusom (in **samo ko status = čaka**)
  dodaj sekcijo »Ponavljanje« — preklop off/on, izbor Dnevno/Tedensko/Na N dni
  (+ številčno polje za N), neobvezno »ponovi skupaj N-krat«.
- **Kanonični prikaz ob editu (D6):** shranjen `everyDays` se mapira nazaj v kontrolnik
  deterministično — `1 → Dnevno`, `7 → Tedensko`, drugo → `Na N dni` (z N = everyDays).
  Tako urejanje ne preseneti.
- **Vizualna oznaka serije** v seznamih (Domov, Opravila, Dnevnik/koledar): majhna
  `Icons.repeat` ikona (size 15, `onSurfaceVariant`) tik ob reminder ikoni v trailing
  `Row` — pravilo prikaza `recurrence != null`. Ker velja `recurrence != null ⇔ bo
  naslednja` (D2), je značka vedno resnična. **Vidna tudi na opravljenih** v dnevniku
  (zgodovina »to je bilo ponavljajoče«). En skupen helper za trailing ikone, brez
  kopiranja po tile-ih.
- **Povratna informacija ob dokončanju ponavljajočega:** `showTopToast(context, …)`
  (obstoječ `core/widgets/top_toast.dart`, zgornji auto-toast) z besedilom
  `tasks_list.completed_recurring_toast` (»↻ Ponovljeno · naslednje $date«). Brez
  akcije (revert serije je blokiran, D1). Haptika (FR-17) nespremenjena.
- **Korak »Kdaj« kontrolnik:** 4-segmentni `SegmentedButton`
  `Brez/Dnevno/Tedensko/Po meri` (`showSelectedIcon: false`); pri »Po meri« se pokaže
  polje »Vsakih [N] dni«; neobvezni `CheckboxListTile` »Ponovi določeno število krat«
  → polje **števila ponovitev** [R] (R ≥ 1 = `remaining`; izklop → `remaining = null`).
  Pod kontrolniki **»Naslednje: <datum>«** (živ izračun). Validacija na meji:
  `everyDays ≥ 1`, `R ≥ 1` → prazno/neveljavno **blokira »Naprej«** + napaka pod poljem.
- Detajl opravila: `switch` zamenjaj z `Recurrence.tryParse`; vrstica »Ponavljanje«
  kaže človeški povzetek (Ne / Dnevno / Tedensko / Vsakih N dni [+ »· še N×«]).
- »Povrni na čaka« onemogočen na dokončani ponavljajoči instanci (§5.4) z razlago.
- Uporaba obstoječih komponent (`SegmentedButton`, `FieldLabel`, `SaveBar`,
  `showTopToast`), brez novih kopij.

## 8. i18n ključi (sl/en/de, namespace `entry`/`tasks_list`/`task_detail`)

Dejansko stanje (usklajeno z implementacijo 2026-06-30; sl prikazan). Opomba:
namespace je **`tasks_list`** (ne `tasks` — to je listni nav niz).

| Ključ | sl |
|------|-----|
| `entry.recurrence_label` | Ponavljanje |
| `entry.recurrence_off` | Brez |
| `entry.recurrence_daily` | Dnevno |
| `entry.recurrence_weekly` | Tedensko |
| `entry.recurrence_custom` | Po meri |
| `entry.recurrence_interval_label` | Vsakih |
| `entry.recurrence_days_unit` | dni |
| `entry.recurrence_repeat_count` | Ponovi določeno število krat |
| `entry.recurrence_times_unit` | krat |
| `entry.recurrence_repeat_count_hint` | Ponavlja se v nedogled; ustaviš ga pri opravilu (⋯ → Ustavi ponavljanje). |
| `entry.recurrence_invalid_number` | Vnesi število |
| `entry.recurrence_next_preview(date)` | Naslednje: $date |
| `tasks_list.recurring_badge_tooltip` | Ponavljajoče opravilo |
| `tasks_list.completed_recurring_toast(date)` | ↻ Ponovljeno · naslednje $date |
| `tasks_list.revert_blocked_recurring` | Tega ni mogoče povrniti — naslednje opravilo v seriji je že ustvarjeno. Po potrebi ga izbriši. |
| `task_detail.action_stop_recurrence` | Ustavi ponavljanje |
| `task_detail.recurrence_none` | Ne |
| `task_detail.recurrence_daily` | Dnevno |
| `task_detail.recurrence_weekly` | Tedensko |
| `task_detail.recurrence_every_days(n)` | Vsakih $n dni |
| `task_detail.recurrence_remaining(n)` | · še $n× |

*(Obstoječi `task_detail.recurrence_weekly/seasonal/once` se ob refaktorju switcha
počistijo, če postanejo mrtvi — preveri, da ne ostane nerabljen ključ.)*

Po dodajanju ključev: `dart run slang`.

## 9. Prizadete / nove datoteke

**Novo:**
- `lib/features/tasks/data/recurrence.dart` — model + parser + generator.
  (V `data/`, ne `domain/`: projekt po CLAUDE.md nima `domain/` plasti —
  struktura je `data/application/presentation`; model živi ob repozitoriju.)

**Spremenjeno:**
- `lib/core/database/app_database.dart` (oz. tabela) — nova nullable `series_id` v `Tasks`
  + `dart run build_runner build` (generirani `*.g.dart`).
- `supabase/migrations/NNNN_*.sql` — additive `alter table task add column series_id text;`
  (+ grant po konvenciji, če je potreben za novo kolono).
- `lib/core/sync/remote_mappers.dart` — `series_id` v `taskToRemote`/`taskFromRemote`.
- `lib/features/tasks/data/tasks_repository.dart` — `create`/`updateTask` `recurrence`+
  `seriesId`, `complete` materializacija, `_materializeNext` helper, `revertToWaiting` blokada.
- `lib/features/tasks/presentation/entry/steps/when_step.dart` — UI ponavljanja + kanonični prikaz.
- klicalci `updateTask`/`create` v entry stepperju (predaja `recurrence`).
- `home_screen.dart`, `tasks_screen.dart`, `task_entry_tile.dart` — ikona serije.
- `task_detail_screen.dart` — uskladi recurrence labelo; revert gate.
- `lib/i18n/translations.g.dart` (prek `dart run slang`) + `i18n/*.i18n.json`.

**Brez sprememb:** `reminder_coordinator.dart` (reaktivno pobere novo instanco sam).

## 10. Robni primeri

- **Preložitev ≠ smrt serije (D-popravek):** `postponeOneDay`/`reschedule` delata na
  **isti vrstici**, zato `recurrence` (in `series_id`) preživita; ob kasnejšem
  dokončanju se naslednja normalno rodi. Serija »umre« **le ob izbrisu** instance.
- **Izbris instance:** soft-delete obstoječe instance ne briše prejšnjih (opravljenih)
  niti ne »oživi« serije. Ni avtomatske kaskade; `series_id` pa naknadno omogoča
  identifikacijo cele serije (npr. bodoče »izbriši celo serijo«).
- **Časovni pas / DST:** lokalna aritmetika polj ohrani uro; shramba UTC.
- **Terminalna instanca (D2):** zadnja v končni seriji ima `recurrence = null`; vrednost
  `remaining = 0` se nikoli ne shrani. Značka serije zato nikoli ne laže.
- **Revert dokončanega ponavljajočega (D1):** prepovedan (§5.4) — ohranja »samo eno aktivno«.
- **Edit recurrence sredi serije (D5):** velja za **naslednje** rojstvo (bere se ob
  `complete()`); že obstoječe instance se ne dotaknejo. `everyDays` edit ne resetira
  `remaining`; »konec po N« edit prepiše `remaining = N-1`.
- **`duplicate()` (FR-6 »ponovi zadnje«, D6):** **strip** `recurrence` IN `series_id`
  ob duplikatu — »ponovi zadnje« je enkratna hitra kopija, ne nadaljevanje serije.
- **Offline multi-device fork (sprejeto, redko):** dve napravi dokončata *isto* instanco
  → dva otroka (različna UUID). LWW poravna original na en `done`, otroka pa sta ločeni
  vrstici. Pri single-user MVP zanemarljivo; `series_id` omogoča kasnejši dedup.
- **Opomniki:** kopirajo se specifikacije (offset/ura); coordinator jih re-anchora na
  nov datum samodejno. Pretekli fire-i se preskočijo (`fire.isAfter(now)`).

## 11. Bodoče opozorilo — pametni motor (M11, ko se merge-a)

Ko M11 pride na `main`: uporabnikovo ponavljanje (FR-5, eksplicitno) in predlogi motorja
(R3 cadence ipd.) lahko podvojita isto opravilo. `series_id` (D3) naredi spravo
**deterministično**: (a) motor prepozna aktivno serijo prek `series_id` in **utiša** R3
za isti (tip+subjekt) — brez krhke `last_done` hevristike; (b) FR-5 instanca ne sme
sprožati push obvestil motorja. **Zdaj neaktivno** (M11 ni na `main`); zabeleženo, da se
ne pozabi.

## 12. Definition of Done (preverljiv seznam)

- [ ] `Recurrence` model + `tryParse` (tolerantno) + `next()` + `encode()`.
- [ ] `nextOccurrenceDate` čista funkcija, DST-safe (civil-day aritmetika).
- [ ] Nova nullable `series_id` kolona (drift + Supabase additive migracija); `remote_mappers`
      (de)serializira `series_id` tolerantno.
- [ ] `updateTask` sprejme in zapiše `recurrence` + `series_id` (vklop/izklop pravila D5).
- [ ] `complete()` ob `recurrence != null` ustvari naslednjo instanco v isti transakciji
      (subjekti + opomniki podedovani; `series_id` podedovan; sidro = načrtovani datum).
- [ ] Serija se izteče po D2: instanca z `remaining == 1` rodi otroka z `recurrence = null`;
      `remaining == 0` se nikoli ne shrani; `recurrence != null ⇔ bo naslednja`.
- [ ] `revertToWaiting` prepovedan na dokončani instanci z `recurrence != null` (D1) + toast.
- [ ] `duplicate()` strip-a `recurrence` IN `series_id` (D6).
- [ ] Korak »Kdaj« kaže ponavljanje samo pri statusu *čaka*; off/on + frekvenca + interval
      + neobvezni N (»skupaj N-krat«); kanonični prikaz ob editu (1→Dnevno, 7→Tedensko).
- [ ] Ikona serije v seznamih (en skupen widget, brez kopij); obstoječa opravila
      (`recurrence == null`) nespremenjena.
- [ ] i18n sl/en/de + `dart run slang`.
- [ ] Unit testi: generator (dnevno/tedensko/N, prelom meseca/leta, DST), model parser
      (legacy/invalid → null), `next()` štetje + terminal=null.
- [ ] Repo testi: round-trip create/update z recurrence+series_id; `complete()` rodi
      naslednjo z istim `series_id`; štetje (N=2, N=3 → točno N instanc); terminalna
      instanca ima `recurrence == null`; `revertToWaiting` blokada; `duplicate` strip.
- [ ] Widget test: dokončanje ponavljajočega → naslednja instanca se pojavi.
- [ ] `flutter analyze` čist + cel `flutter test` zelen.
- [ ] `/code-review high` pregled diffa pred commitom.
- [ ] Ročna on-device verifikacija (seznam ostane za konec).

## 13. Dnevnik odločitev (pregled 2026-06-30)

| ID | Odločitev | Izbira | Razlog |
|----|-----------|--------|--------|
| D1 | Revert dokončanega ponavljajočega | **Prepreči + toast** | Brez `series_id` iskanja; varuje invarianto »samo eno aktivno«. Pravi undo = izbris nove instance. |
| D2 | Terminalno stanje serije | **Zadnja `recurrence = null`** | `recurrence != null ⇔ bo naslednja` → značka nikoli ne laže; `remaining:0` se ne shrani. |
| D3 | `series_id` kolona | **Dodaj zdaj (additive)** | Deterministična M11-sprava, bodoče funkcije serije, offline dedup; poceni zdaj, drago retroaktivno. |
| D4 | Pomen N | **Skupaj N-krat** (`remaining = N-1`) | Ujema mentalni model »naredim N-krat«; besedilo »skupaj«, ne »ponovitev«. |
| D5 | Edit sredi serije | **Ohrani `remaining`** | `everyDays` edit ne resetira štetja; »konec po N« edit prepiše `remaining = N-1`. |
| D6 | `duplicate()` na seriji | **Strip `recurrence` + `series_id`** | »Ponovi zadnje« je enkratna kopija, ne nova serija. |
