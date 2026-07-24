# FR-17: Haptični odziv ob ključnih akcijah

- **Status:** ✅ implementirano 2026-06-28 (`feat/fr17-haptics`) — vse 3 akcijske točke
- **Datum:** 2026-06-28
- **Avtor:** Gorazd
- **Področja:** presentation (akcijske točke), `core/widgets/` (SaveBar, confirm_dialog)
- **Povezave:** [`CLAUDE.md`](../../CLAUDE.md) (»UI / presentation vzorci«, »Dependencies«), [`docs/koncept.md`](../koncept.md)

---

## 1. Povzetek (TL;DR)

App nima nobenega haptičnega odziva (`HapticFeedback` se ne pojavi nikjer v `lib/`). Predlog: kratek tactilni utrip ob **ključnih akcijah**, da uporabnik dobi potrditev, da se je tap registriral — še posebej koristno pri uporabi na vrtu (hitri tapi, včasih z rokavicami, sonce na zaslonu).

`HapticFeedback` je del `package:flutter/services.dart` (**vgrajen, brez nove dependency**). Na napravah z onemogočeno haptiko je samodejno no-op.

---

## 2. Kontekst (zakaj zdaj)

- Tendask je »beleži hitro« app, ki se uporablja zunaj — tactilna potrditev »vneseno je« je tu bolj vredna kot pri pisarniški aplikaciji.
- Trenutno je edina povratna informacija vizualna (premik opravila, snackbar). Ob soncu/rokavicah to ni vedno opazno.
- Poseg je majhen in ne vpliva na sync, shemo ali zasebnost.

---

## 3. Predlagane akcijske točke

| Akcija | Klic | Razlog |
|---|---|---|
| Opravilo označeno **✓ opravljeno** | `HapticFeedback.lightImpact()` | najpogostejša akcija; potrdi premik opravila |
| **Shrani** (`SaveBar` / bottom-sheet potrdi) | `HapticFeedback.mediumImpact()` | zaključek vnosa |
| **Potrditev izbrisa** (`showConfirmDialog(destructive: true)`) | `HapticFeedback.heavyImpact()` | destruktivno = močnejši signal |

Začni z **opravilom ✓** (največja vrednost); ostalo dodaj, če se obnese.

---

## 4. Obseg / ne-cilji

- **Cilj:** tactilna potrditev na ~3 ključnih akcijskih točkah.
- **Ne-cilj:** haptika na vsakem tapu (postane šum); zvočni odziv; vibracijski vzorci po meri (`Vibration` paket — nepotrebna dependency).

**Brez nove dependency, sheme, migracije ali i18n** (ni besedila). Testi: minimalni (widget test lahko le preveri, da akcija sploh teče; haptiko samo težko verificiramo brez naprave).

---

## 5. Odprta vprašanja / odločitve

1. **Stikalo v Nastavitvah?** Predlog: **brez** za MVP — stikalo bi zahtevalo `local_flags` zapis + branje na vsaki akcijski točki (obseg zraste). Večina aplikacij haptiko da brezpogojno; OS-onemogočena vibracija je tako ali tako no-op. Dodaj stikalo šele, če kdo pritoži.
2. **Katere točke v prvi iteraciji?** Predlog: samo opravilo ✓; SaveBar in destructive confirm v isti ali naslednji iteraciji.
3. **Jakost (`light`/`medium`/`heavy`/`selectionClick`):** zgornja tabela je izhodišče; fino uglasi na napravi.

---

## 6. Ocena

Trivialno: ~5–8 klicev na obstoječih akcijskih točkah, en import na datoteko. Brez infrastrukture.

---

## 7. Izvedba (2026-06-28)

Vse 3 točke v eni iteraciji. Razrešena odprta vprašanja iz §5:

1. **Stikalo v Nastavitvah:** brez (MVP) — kot predlagano.
2. **Obseg:** vse 3 razrede naenkrat (poseg je trivialen in chokepointi čisti).
3. **Jakost:** po tabeli (`light`/`medium`/`heavy`).

**Načelo (odstopanje od »tap registered« iz §1):** haptika se sproži, **ko se dejanje dejansko
zgodi**, ne ob vsakem tapu. Razlog konsistence: `complete` nima validacije (sproži ob tapu =
ob izvedbi), `delete` sproži šele po potrditvi (= ob izvedbi), zato mora tudi `save` sprožiti
ob **uspehu**, ne ob tapu — sicer bi `mediumImpact` lažno utripnil ob neuspeli validaciji
(prazno ime/vsebina) ali ob `PlantMoveResult.duplicate`. Posledica: medium NI v skupnem `SaveBar`
(ki ne ve za uspeh), ampak na uspešni save-poti vsakega obrazca.

**Kje:**
- `lib/core/haptics.dart` — `AppHaptics.taskCompleted()` / `saved()` / `destructiveConfirmed()`;
  edina točka preslikave jakosti (in bodočega stikala). `unawaited(...)` fire-and-forget.
- `lightImpact`: `task_swipe` (skupni swipe za seznam/domov/dnevnik), `tasks_screen` action-sheet,
  `task_detail` gumb + meni.
- `mediumImpact`: `entry_screen._save`, `area_form`, `plant_edit`, `note_form` — vsi na success-poti.
- `heavyImpact`: `showConfirmDialog` ob `destructive && potrjeno` — en chokepoint za vse izbrise/
  clear/odjavo (v `lib/` je en sam `AlertDialog`).

**Testi:** `test/core/haptics_test.dart` (jakostna preslikava prek mock platform kanala),
`test/core/widgets/confirm_dialog_test.dart` (branža confirm/cancel/non-destructive). Klicne točke
so straight-line wiring → ročna preverba na napravi (po CLAUDE.md brez testov za scaffolding).
