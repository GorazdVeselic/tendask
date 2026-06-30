# FR-5 — Ponavljanje opravil (MINIMALNI MVP)

> Status: **IMPLEMENTIRANO na `main`** (2026-06-30, commita `06bab04` feat + `feebfed` fix-ui).
> Ta dokument je **usklajen z dejansko kodo** (2026-06-30). Obseg =
> *materializiraj-naslednjo-instanco-ob-dokončanju*.
> Vir: pogovor 2026-06-30 (frekvence, sidro, konec) + pregled arhitekt/PM (odločitve D1–D6, §13).
> ⚠️ **Prod migracija še čaka:** Supabase `0013` (`series_id`) je apliciran na **staging**, na **prod** še NE —
> aplicirati pred naslednjim prod buildom (pravilo »vsak prod release → `supabase db push`«).

## 1. Obseg

Uporabnik lahko na opravilu (status **čaka**) vklopi ponavljanje. Ko opravilo
označi kot **opravljeno**, se samodejno ustvari **ena** naslednja instanca z istim
tipom, subjekti, opombo in opomniki, premaknjena za interval naprej. Aktivno
opravilo je vedno **samo eno** (naslednje se rodi šele ob dokončanju trenutnega);
to invarianto eksplicitno varuje tudi blokada reverta (§5.4, D1).

### Ponujene frekvence (korak »Kdaj«)
- **Dnevno** = +1 dan (`everyDays = 1`)
- **Tedensko** = +7 dni (`everyDays = 7`)
- **Po meri** = +N dni (poljuben interval prek polja »Vsakih [N] dni«)

Vse tri se reducirajo na **»+N dni«** → en sam številčni model (`everyDays`), brez
`freq` enuma in brez koledarske mesečne aritmetike.

### Sidro naslednjega datuma
**Od načrtovanega datuma** opravljenega opravila (ne od trenutka dokončanja):
`naslednje = načrtovani_datum + everyDays`, **ohrani uro**. Zamuda pri dokončanju
NE premakne termina (»vsak ponedeljek« ostane ponedeljek).

### Konec serije
- Privzeto: **v nedogled** (nova instanca ob vsakem dokončanju).
- Neobvezno: **»Ponovi določeno število krat«** → polje »[N] krat«, kjer je
  **N = `remaining` neposredno** (D4): število ponovitev **po trenutni** instanci.
  Vnos N=1 → trenutna + 1 = **skupaj 2**; N=3 → skupaj 4. Zadnja instanca nima
  `recurrence` (D2), zato je vidno, da se ne bo ponovila; detajl prikaže » · še N×«.

## 2. NE-obseg (namerno izpuščeno za MVP)

| Izpuščeno | Zakaj |
|-----------|-------|
| Serijsko urejanje (»to / to in naprej / vse«) | Klasična koledarska močvara; pri modelu »ena naslednja naenkrat« ni potrebno. |
| Izjeme / preskoči-termin | Uporabnik preprosto preloži/izbriše posamezno instanco. |
| Mesečno / letno / RRULE (RFC 5545) | YAGNI; +N dni pokrije vrtne ritme. Add-only razširljivo kasneje. |
| Pred-materializacija več instanc vnaprej | Množi vrstice in sync; ena naprej zadošča. |
| Razrešitev konfliktov s pametnim motorjem (M11) | M11 ni na `main`. `series_id` (§3, D3) naredi bodočo spravo deterministično — glej §11. |
| Ponavljanje na opravilu z `done` ob vnosu (logiranje preteklosti) | Ponavljanje je dovoljeno samo na `waiting` (§7.9). |
| Revert-undo, ki pobriše rojeno instanco | D1: revert je **prepovedan** (ne brišemo otroka); `series_id` to kasneje omogoči. |

## 3. Podatkovni model

Dva nosilca stanja na `task`:

1. **`task.recurrence`** (obstoječ nullable `TEXT` v drift / `JSONB` v Supabase) —
   JSON niz pravila; `null` = enkratno (ali zadnja v končni seriji).
2. **`task.series_id`** (nullable `TEXT` kolona, D3) — stabilen UUID, skupen vsem
   instancam ene serije. `null` = ni del serije. Generiran na napravi ob vklopu
   ponavljanja, **podedovan** v vsako rojeno instanco (tudi terminalno).

> **Migracija (additive):** nullable `series_id` (drift shema **v11** + Supabase **`0013`**).
> Nullable, brez backfilla, stari APK jo ignorira kot neznano polje (kot `recurrence`)
> → expand-only, varno za živo bazo. `recurrence` kolona je obstajala že prej.

### Oblika JSON (`recurrence`)
```json
{ "everyDays": 7, "remaining": 3 }
```
- `everyDays` (int ≥ 1) — interval v dneh.
- `remaining` (int ≥ 1, **neobvezno**, izpuščen ko neskončno) — koliko instanc bo
  sledilo **po tej**. `null`/izpuščen = neomejeno. **Vrednost `0` se nikoli ne shrani**
  (D2): namesto zadnje instance z `remaining:0` dobi ta `recurrence = null`.

### Semantika štetja (D2 + D4)
- `remaining` = število instanc **po trenutni**. UI polje »krat« se vanj preslika
  **neposredno** (brez `N-1`): vnos N → prva instanca dobi `recurrence = {everyDays, remaining: N}`.
- Ob dokončanju instance z `recurrence = r` (`Recurrence.next()` določi otrokovo pravilo):
  - `r == null` → ni nove instance (enkratno ali že zadnja).
  - `r.remaining == null` → nova instanca z `recurrence = {everyDays, remaining: null}` (neskončno; `next()` vrne `this`).
  - `r.remaining > 1` → nova instanca z `recurrence = {everyDays, remaining: remaining - 1}`.
  - `r.remaining == 1` → nova instanca z `recurrence = null` (to je zadnja; `next()` vrne `null`).
- **Invarianta (D2):** `recurrence != null` ⇔ »po tej bo še vsaj ena« → značka serije
  (§7) nikoli ne laže.

### Typed model (`lib/features/tasks/data/recurrence.dart`)
```dart
class Recurrence {
  const Recurrence({required this.everyDays, this.remaining})
    : assert(everyDays >= 1),
      assert(remaining == null || remaining >= 1);
  final int everyDays;
  final int? remaining;                 // instanc PO tej; null = neskončno; nikoli 0

  static Recurrence? tryParse(String? raw);  // tolerantno; nikoli ne vrže
  String encode();                            // JSON; izpusti remaining ko null
  Recurrence? next();                         // pravilo otroka; null = otrok je zadnji
}
```
- `tryParse` (tolerantni parser, zrcali sync filozofijo): `null`/prazno/ne-JSON/ne-Map →
  `null`; `everyDays < 1` ali manjka → `null` (enkratno); **`remaining < 1` (vključno 0)
  → normalizira na neskončno** (`null` remaining, ohrani `everyDays`).
- UI in repo bereta `Recurrence`, **nikoli surovega JSON/Map**.

## 4. Generator naslednjega datuma (čista funkcija)

`lib/features/tasks/data/recurrence.dart`:
```dart
DateTime nextOccurrenceDate(DateTime scheduledLocal, int everyDays) => DateTime(
  scheduledLocal.year, scheduledLocal.month, scheduledLocal.day + everyDays,
  scheduledLocal.hour, scheduledLocal.minute,
);
```
- **Lokalna** aritmetika polj (`day + everyDays`) → `DateTime` normalizira prelive
  meseca/leta; ohrani uro/minuto čez DST. Repo poskrbi za `.toUtc()` ob zapisu.
- Čista, brez `Clock` (sidro je `task.date`, ne `now()`) → trivialno testabilna.

## 5. Spremembe repozitorija (`tasks_repository.dart`)

### 5.1 `create(...)`
Sprejema `String? recurrence` **+ `String? seriesId`**. Če je `recurrence != null` in
`seriesId == null`, repo generira nov UUID (serija se rodi); materializator poda obstoječ
`seriesId`, da ga otroci podedujejo. Klicalec poda `recurrence?.encode()`.

### 5.2 `updateTask(...)`
Sprejme `String? recurrence` in ga zapiše (prej se ob editu ni pisal → bil je ohranjen,
a ne urejljiv). `series_id` se izpelje samodejno (D5):
- `recurrence != null` → `series_id = current.seriesId ?? nov UUID` (instanca dobi/obdrži serijo);
- `recurrence == null` → ostane brez (izklop ponavljanja prek `stopRecurrence`, §5.5);
- sprememba `everyDays`/`remaining` → zapiše novo pravilo, sicer štetje teče po `next()`.

### 5.3 `complete(id)`
Po obstoječi logiki (status→done, odpis zalog, vreme):
- `Recurrence.tryParse(task.recurrence)`; če `null` → nič (kot doslej);
  če `recurrence != null` a parse spodleti → **observability** `debugPrint` (sumljiva serija);
- sicer `await _materializeNext(task, rule)` **znotraj iste transakcije**.
- **Atomarnost:** rojstvo naslednje je del `complete()` transakcije; če spodleti, se
  odpis zalog + done **razveljavita**.
- Vreme se zamrzne **samo** za dokončano instanco (`_captureWeather(id)`), ne za novo.

### 5.4 `revertToWaiting(id)` — blokada (D1)
Ker `complete()` na ponavljajočem opravilu **takoj rodi** naslednjo instanco, bi revert
ustvaril dve aktivni instanci (kršitev §1). Zato: če `task.status == done` in
`Recurrence.tryParse(task.recurrence) != null` → **revert prepovej** (UI gate + toast
`tasks_list.revert_blocked_recurring`). Sicer → kot doslej. *Sprejeto za MVP:* tudi če je
otrok že ročno pobrisan, je revert blokiran (rahlo prestrogo); pravi »undo« = izbris nove
instance v seznamu.

### 5.5 `_materializeNext(...)` + `stopRecurrence(...)`
- `_materializeNext(parent, rule)` (privatna): rodi `waiting` instanco z
  `recurrence = rule.next()?.encode()` (`null`, če je zadnja) in **podedovanim
  `seriesId = parent.seriesId`**; kopira subjekte + opomnike; vrne lokalni datum naslednje.
- `stopRecurrence(id)`: počisti `recurrence = null` **in** `series_id = null` (instanca
  zapusti serijo, D5) — vezano na »⋯ → Ustavi ponavljanje«.
- `duplicate()` (FR-6 »ponovi zadnje«): **strip** `recurrence` IN `series_id` (D6) — kopija
  je enkratna, ne nadaljevanje serije.

## 6. Sync (additive migracija `0013`)

- `remote_mappers.dart`: `recurrence` (push `_jsonb`, pull `_text`) **+ `series_id`**
  (`taskToRemote` `'series_id': r.seriesId`; `taskFromRemote` `seriesId: Value(r['series_id'] as String?)`),
  tolerantno, nullable.
- Nova instanca = navadna `task` vrstica (`sync_status = pending`) → obstoječi push/pull, LWW.
- **FK vrstni red** ostane; rojstvo je v eni transakciji → lokalno konsistentno pred sync.
- **Migracija** (additive): Supabase `0013` `alter table task add column series_id text;`
  + drift shema **v11** (nullable kolona). Brez `NOT NULL`, brez backfilla.
- Stari APK brez FR-5: `recurrence`/`series_id` = neznani polji → tolerantni parser ju
  ignorira, opravilo deluje kot enkratno. **Additive-safe.**

## 7. UI/UX

- Korak **»Kdaj«** (`when_step.dart`): pod statusom (**samo ko status = čaka**) sekcija
  »Ponavljanje« — `SegmentedButton` Brez / Dnevno / Tedensko / Po meri (`showSelectedIcon: false`),
  pri »Po meri« polje »Vsakih [N] dni«; neobvezno »Ponovi določeno število krat« + polje »[N] krat«
  (= `remaining`, min 1); predogled »Naslednje: <datum>« + validacija blokira »Naprej« ob neveljavnem N.
- **Vizualna oznaka serije** v seznamih (Pregled, Opravila, detajl): `RecurringBadge`
  (`Icons.repeat`) ob opravilu z `recurrence != null`; skupen widget, brez kopij. Ker velja
  `recurrence != null ⇔ bo naslednja` (D2), je značka vedno resnična.
- Detajl/Pregled kažeta recurrence labelo prek `recurrence_label.dart` (» · še N×«).
- »Ustavi ponavljanje« v ⋯ (`stopRecurrence`); »Povrni na čaka« onemogočen na dokončani
  ponavljajoči instanci (§5.4), s toastom prek `showTopToast`.
- Toast ob dokončanju serije: `tasks_list.completed_recurring_toast` (»↻ Ponovljeno · naslednje <datum>«).

> **Nauki iz implementacije (UI):** (a) `ValueKey(recurrence)` na stateful pickerju ga je ob
> vsakem emitu uničil/poustvaril → izbris polja je skakal na »Dnevno«; odpravljeno brez key.
> (b) `SegmentedButton` privzeto kaže ✓ na izbranem → krade širino, besedilo prebije → povsod
> `showSelectedIcon: false`. (c) Enota `×` je izgledala kot gumb za brisanje → »krat«.

## 8. i18n ključi (sl/en/de) — dejansko stanje

**`entry.*`** (korak Kdaj): `recurrence_label` (»Ponavljanje«), `recurrence_off` (»Brez«),
`recurrence_daily`, `recurrence_weekly`, `recurrence_custom` (»Po meri«), `recurrence_interval_label`
(»Vsakih«), `recurrence_days_unit` (»dni«), `recurrence_repeat_count` (»Ponovi določeno število krat«),
`recurrence_times_unit` (»krat«), `recurrence_repeat_count_hint`, `recurrence_invalid_number`,
`recurrence_next_preview` (»Naslednje: {date}«).

**`task_detail.*`**: `label_recurrence`, `action_stop_recurrence` (»Ustavi ponavljanje«),
`recurrence_none`, `recurrence_daily`, `recurrence_weekly`, `recurrence_every_days` (»Vsakih {n} dni«),
`recurrence_remaining` (» · še {n}×«).

**`tasks_list.*`**: `recurring_badge_tooltip`, `completed_recurring_toast` (»↻ Ponovljeno · naslednje {date}«),
`revert_blocked_recurring`.

(Vsi v sl/en/de; generirano prek `dart run slang`.)

## 9. Datoteke (dejansko)

**Novo:**
- `lib/features/tasks/data/recurrence.dart` — `Recurrence` model + `tryParse`/`encode`/`next` + `nextOccurrenceDate`.
- `lib/features/tasks/presentation/recurrence_label.dart` — labela serije + `RecurringBadge`.
- testi: `test/features/tasks/recurrence_test.dart`, `recurrence_repository_test.dart`, `recurrence_when_step_test.dart`.

**Spremenjeno:**
- `lib/core/database/...` — nova nullable `series_id` v `Tasks` (drift **v11**, generirani `*.g.dart`).
- `supabase/migrations/0013_*.sql` — additive `series_id` (apliciran na staging; **prod čaka**).
- `lib/core/sync/remote_mappers.dart` — `series_id` v `taskToRemote`/`taskFromRemote`.
- `lib/features/tasks/data/tasks_repository.dart` — `create`/`updateTask` `recurrence`+`seriesId`,
  `complete`→`_materializeNext`, `stopRecurrence`, `duplicate` strip, `revertToWaiting` blokada.
- `lib/features/tasks/presentation/entry/steps/when_step.dart` — picker ponavljanja + predogled + validacija.
- `home_screen.dart`, `tasks_screen.dart`, `task_*_tile`, `task_detail_screen.dart` — značka + labela + revert gate.
- `lib/i18n/*` (prek `dart run slang`).

**Brez sprememb:** `reminder_coordinator.dart` (reaktivno pobere novo instanco sam).

## 10. Robni primeri

- **Preložitev ≠ smrt serije:** `postponeOneDay`/`reschedule` delata na **isti vrstici**,
  zato `recurrence` (in `series_id`) preživita; ob kasnejšem dokončanju se naslednja rodi.
  Serija »umre« **le ob izbrisu** instance.
- **Izbris instance:** soft-delete ne briše prejšnjih niti ne »oživi« serije; `series_id`
  naknadno omogoča identifikacijo cele serije (bodoče »izbriši celo serijo«).
- **Časovni pas / DST:** lokalna aritmetika polj ohrani uro; shramba UTC.
- **Terminalna instanca (D2):** zadnja v končni seriji ima `recurrence = null`; `remaining = 0`
  se nikoli ne shrani → značka nikoli ne laže.
- **Revert dokončanega ponavljajočega (D1):** prepovedan (§5.4).
- **Edit recurrence sredi serije (D5):** velja za **naslednje** rojstvo (bere se ob `complete()`);
  obstoječe instance se ne dotaknejo. Izklop = `stopRecurrence` (počisti `series_id`).
- **`duplicate()` (FR-6, D6):** strip `recurrence` IN `series_id`.
- **Offline multi-device fork (sprejeto, redko):** dve napravi dokončata *isto* instanco → dva
  otroka (različna UUID). LWW poravna original na en `done`; pri single-user MVP zanemarljivo;
  `series_id` omogoča kasnejši dedup.
- **Opomniki:** kopirajo se specifikacije (offset/ura); coordinator jih re-anchora na nov datum;
  pretekli fire-i se preskočijo (`fire.isAfter(now)`).

## 11. Bodoče opozorilo — pametni motor (M11, ko se merge-a)

Ko M11 pride na `main`: FR-5 (eksplicitno ponavljanje) in predlogi motorja (R3 cadence) lahko
podvojita isto opravilo. `series_id` (D3) naredi spravo **deterministično**: (a) motor prepozna
aktivno serijo prek `series_id` in **utiša** R3 za isti (tip+subjekt) — brez krhke `last_done`
hevristike; (b) FR-5 instanca ne sme sprožati push obvestil motorja. **Zdaj neaktivno** (M11 ni
na `main`); zabeleženo.

## 12. Definition of Done — stanje

- [x] `Recurrence` model + `tryParse` (tolerantno) + `next()` + `encode()`.
- [x] `nextOccurrenceDate` čista funkcija, DST-safe (civil-day aritmetika).
- [x] Nullable `series_id` (drift v11 + Supabase `0013` additive); `remote_mappers` tolerantno (de)serializira `series_id`. *(prod migracija še čaka)*
- [x] `updateTask` zapiše `recurrence` (+ izpeljan `series_id`).
- [x] `complete()` ob `recurrence != null` rodi naslednjo v isti transakciji (subjekti + opomniki + `series_id` podedovani; sidro = načrtovani datum).
- [x] Iztek serije po D2 (`remaining == 1` → otrok `recurrence = null`; `0` se ne shrani; `recurrence != null ⇔ bo naslednja`).
- [x] `revertToWaiting` prepovedan na dokončani ponavljajoči (D1) + toast.
- [x] `stopRecurrence` (⋯) + `duplicate()` strip `recurrence`+`series_id` (D6).
- [x] Korak »Kdaj« samo pri *čaka*; Brez/Dnevno/Tedensko/Po meri + interval + »krat« (=remaining) + predogled + validacija.
- [x] `RecurringBadge` v seznamih (skupen widget); obstoječa opravila nespremenjena.
- [x] i18n sl/en/de + `dart run slang`.
- [x] Unit testi: generator + model parser + `next()` (`recurrence_test.dart`).
- [x] Repo testi (`recurrence_repository_test.dart`) + widget test (`recurrence_when_step_test.dart`). Cel suite zelen (345).
- [x] `/code-review` (4-dimenzijski multi-agentni + adversarna verifikacija; vse najdbe popravljene).
- [ ] **Prod Supabase migracija `0013`** (`supabase db push` pred prod buildom).
- [ ] Ročna on-device verifikacija (preostane za konec).

## 13. Dnevnik odločitev (pregled 2026-06-30)

| ID | Odločitev | Izbira | Razlog |
|----|-----------|--------|--------|
| D1 | Revert dokončanega ponavljajočega | **Prepreči + toast** | Varuje invarianto »samo eno aktivno«; pravi undo = izbris nove instance. |
| D2 | Terminalno stanje serije | **Zadnja `recurrence = null`** | `recurrence != null ⇔ bo naslednja` → značka nikoli ne laže; `remaining:0` se ne shrani. |
| D3 | `series_id` kolona | **Dodana (additive)** | Deterministična M11-sprava, bodoče funkcije serije, offline dedup. |
| D4 | Pomen vnosa »krat« | **`remaining` neposredno** (N = ponovitve po trenutni; N=1 → skupaj 2) | Potrjeno z uporabnikom; ujema implementacijo. **(Popravek prejšnjega osnutka »skupaj N-krat«.)** |
| D5 | Edit sredi serije | **Velja za naslednje rojstvo**; izklop prek `stopRecurrence` (počisti `series_id`) | `everyDays`/`remaining` edit ne ruši štetja; `next()` teče naprej. |
| D6 | `duplicate()` na seriji | **Strip `recurrence` + `series_id`** | »Ponovi zadnje« je enkratna kopija, ne nova serija. |
