# Tendask + — rollout plan (FR-19 + FR-20)

- **Status:** delovni plan (dogovorjena smer 2026-07-23; **prenovljen 2026-07-30** — M11 izpadel iz zaporedja, ker je bil 2026-07-29 ustavljen kot preobsežen; dodan darilni model in razrez FR-20)
- **Namen:** eno vozlišče, ki poveže tri velike povezane naloge in določi **vrstni red**, **način dostave** in **disciplino branchev**. Podrobnosti so v pripadajočih dokumentih — ta plan jih ne podvaja, ampak sekvencira.
- **Povezave:**
  - [`feature-requests/tendask-plus-licensing.md`](feature-requests/tendask-plus-licensing.md) — **FR-20**, avtoritativen za licence/plačila/Play skladnost
  - [`feature-requests/biodynamic-calendar.md`](feature-requests/biodynamic-calendar.md) — **FR-19**, lunin koledar (prvi nosilec Plus)
  - [`m11.md`](m11.md) — **M11** (ustavljen 2026-07-29; iz zaporedja izpadel, vrne se kasneje v majhnih korakih)
  - [`deploy-runbook.md`](deploy-runbook.md) — deploy + migracijski ledger
  - [`plan-implementacije-fr19-fr20.md`](plan-implementacije-fr19-fr20.md) — **razrez na taske/korake z branchi** (izvedbeni nivo tega plana)

---

## 1. Vodilno načelo: deployaj sproti, razkrij enkrat

Trije taski so obsežni; skušnjava je zgraditi vse na branchih in narediti **en velik deploy na koncu**. To je **napaka** — poustvari točno divergenco, ki je zdaj boli pri M11 (main zamrzne, vse visi na branchu).

Namesto tega:

- **Deployaj ves čas.** Vsak kos gre v `main` in v produkcijo, **takoj ko je gotov** — a je za flagom, torej v APK-ju **nič ne dela** (dark).
- **Razkrij enkrat.** »Big bang« ni deploy, ampak **prižig flaga** (`kSuggestionsEnabled=true` + gate + deploy edge/cron) — drobna sprememba, ne merge.

**Precedens že teče:** `kSuppliesEnabled=false` — koda za sredstva se vozi v produkcijskih APK-jih (1.0.0+15) temna. Isti vzorec.

**Posledica za skrb »vmes ne bo možno delati drugih dodatkov«:** ravno nasprotno. Kar blokira druge dodatke, je dolgoživ branch. Flag-dark + sprotni deploy naredi bugfix ali drug FR **možen kadarkoli** — izdaja pač nese še temno kodo, ki ne dela nič. `main` nikoli ne zamrzne.

---

## 2. Edina trda disciplina: serializiraj shemo

Ni treba biti dosleden pri *vseh* branchih — le pri tistih, ki premikajo **shemo/sync**:

- **Shemo-dotikajoče delo v `main` po enem naenkrat.** FR-20 premika `profile` shemo + drift `schemaVersion` + sync push (M11 je to prav tako počel — ob ponovnem zagonu se serializira mimo FR-20). Dva hkratna dviga `schemaVersion` = kolizija.
- **Vse ostalo (ne-shemsko) sme teči vzporedno** — kratkoživi branchi z `main`, hitro nazaj.
- Migracije **additive-only** (stari APK-ji ob pull-u ne crashajo); vsaka klient-dostopna tabela **eksplicitni grant v isti migraciji**.

---

## 3. Vrstni red (avtoritativen, prenovljen 2026-07-30)

Vsak korak je **sam po sebi deployabilen v prod** (dark). Med koraki lahko kadarkoli izdaš bugfix ali drug dodatek.

| # | Korak | Stanje v main | Dokument |
|---|---|---|---|
| **1** | **FR-19 motor** (čista funkcija v `core/` + unit testi + nevtralne 3 meje po svetlih zvezdah) | dark (nič ga še ne kliče) | [FR-19 §14](feature-requests/biodynamic-calendar.md) |
| **2** | **FR-19 UI v celoti** (koledar, čip, oznake, iskalnik — po odločitvah A1–A6) | dark (za flagom) | [FR-19](feature-requests/biodynamic-calendar.md) · [odločitve](feature-requests/biodynamic-calendar-decisions.md) |
| **3** | **FR-20 minimalna rezina upravičenosti** (migracija `plus_until`/`plus_token`/`plus_kind` + granti + `plusProvider` + osnovni Tendask+ zaslon; brez `license*` tabel) | zid obstaja, nič ne zaklepa | [FR-20 §12](feature-requests/tendask-plus-licensing.md) |
| **4** | **Prižig z darilom** | razkritje | §4 spodaj |
| **5** | **FR-20 komercialni del** (Polar, kode, unovčitev, spletna stran, Play App access) | živo; **rok = pred potekom prvih daril** | [FR-20 §12](feature-requests/tendask-plus-licensing.md) |

**Zakaj ta red:**
- **Odvisnost FR-19 ↔ FR-20 je samo v točki prižiga, ne med gradnjo.** FR-19 je čisto klientski (nič sheme, nič synca) in se v celoti zgradi ter deploya temen brez FR-20; gate je do koraka 3 navaden `const` flag.
- **Motor prvi (korak 1)**, ker je edini kos z odprtim tehničnim vprašanjem (nevtralne meje) — tveganje se pobere na začetku.
- **Minimalna rezina FR-20 šele pred prižigom**, ker prižig z masovnim darilom rabi le upravičenost, ne trgovine.
- **Komercialni del po prižigu, a z rokom:** potek prvih daril je deadline — uporabnik, ki hoče plačati in ne more, je najslabši izid (FR-20 §10.4).
- Če se komercialni del zavleče, je izhod vedno odprt: **darilo se podaljša** — nobena pot se ne zapre.
- Shemo premika samo korak 3 → pravilo §2 je trivialno izpolnjeno. (M11, ki je premikal shemo vzporedno, je ustavljen; ob ponovnem zagonu se serializira mimo teh korakov.)

---

## 4. Prižig z darilom (korak 4 — edini »big bang«, in je majhen)

Vse hkrati, en dogodek:

1. FR-19 bogati del: flag on + gate kot Plus (prek `plusProvider`).
2. **Masovna časovno omejena `granted` licenca vsem obstoječim profilom** (lansirno darilo, FR-20 §10.4; dolžina = parameter, delovni predlog 6 mesecev, izbran glede na sezono).
3. Objavljena zgodba: »Tendask+ je tu, zgodnji uporabniki dobijo **X mesecev v zahvalo**.«
4. Play Console `App access` + `review` koda (FR-20 §8) — šele ko obstaja vnos kode, tj. lahko tudi s korakom 5; listing/posnetki po potrebi (SL/EN/DE).

FR-19 bogati del tako **debitira zaklenjen** → nič grandfatheringa (FR-20 §10.4); z darilom pa uporabniško deluje kot »podarjen Plus«, ne kot zid.

**Pred prižigom odločiti (FR-20 §11.9–11.10):** gost brez računa (lokalno darilo vs. vezava na prijavo) in dokončna dolžina darila.

*(M11 točki — `kSuggestionsEnabled` in deploy `smart-engine` + cron — sta izpadli z ustavitvijo M11; ob ponovnem zagonu M11 dobi svoj prižig.)*

---

## 5. Odprto

**Blokira šele korak 3 oz. 5 (ne korakov 1–2):**
- **FR-20 §11.2** — konkretne cene (letna + doživljenjska) — blokira komercialni del (korak 5).
- **FR-20 §11.3** — Polar ali Paddle — korak 5.
- **FR-20 §11.4** — dependency za podpis tokena (`tech-stack.md §1`) — korak 3.
- **FR-20 §11.9** — gost brez računa in darilo — pred prižigom (korak 4).
- **FR-20 §11.10** — dolžina darila — pred prižigom (korak 4).

**Blokira korak 1–2 (FR-19 gradnjo):**
- **FR-19 decisions A1–A6** (obseg slojev, en/dva koledarja, motor, barve, ikone, stikalo) — dorekniti pred UI.
- **Nevtralne vrednosti 3 kalibriranih mej** (svetle zvezde, FR-19 §14.5) — pred motorjem.

Korak 1 (motor) se **lahko začne takoj po** doreku mej — ni odvisen od ničesar drugega.

---

*Zapisano 2026-07-23, prenovljeno 2026-07-30 (M11 ustavljen; darilni model; razrez FR-20; vrstni red FR-19 → minimalna rezina → prižig → trgovina). »Deployaj-sproti-razkrij-enkrat« ostaja vodilo.*
