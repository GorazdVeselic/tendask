# Tendask + — rollout plan (FR-19 + FR-20 + M11)

- **Status:** delovni plan (dogovorjena smer 2026-07-23)
- **Namen:** eno vozlišče, ki poveže tri velike povezane naloge in določi **vrstni red**, **način dostave** in **disciplino branchev**. Podrobnosti so v pripadajočih dokumentih — ta plan jih ne podvaja, ampak sekvencira.
- **Povezave:**
  - [`feature-requests/tendask-plus-licensing.md`](feature-requests/tendask-plus-licensing.md) — **FR-20**, avtoritativen za licence/plačila/Play skladnost
  - [`feature-requests/biodynamic-calendar.md`](feature-requests/biodynamic-calendar.md) — **FR-19**, lunin koledar (prvi nosilec Plus)
  - [`m11/11-poravnava-v-main.md`](m11/11-poravnava-v-main.md) — **M11** poravnava v main
  - [`m11/09-koraki.md`](m11/09-koraki.md) — M11 tasklist (ostanek faze E)
  - [`deploy-runbook.md`](deploy-runbook.md) — deploy + migracijski ledger

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

- **Shemo-dotikajoče delo v `main` po enem naenkrat.** M11 in FR-20 oba premikata `profile` shemo + drift `schemaVersion` + sync push. Dva hkratna dviga `schemaVersion` = kolizija.
- **Vse ostalo (ne-shemsko) sme teči vzporedno** — kratkoživi branchi z `main`, hitro nazaj.
- Migracije **additive-only** (stari APK-ji ob pull-u ne crashajo); vsaka klient-dostopna tabela **eksplicitni grant v isti migraciji**.

---

## 3. Vrstni red (avtoritativen)

Vsak korak je **sam po sebi deployabilen v prod** (dark). Med koraki lahko kadarkoli izdaš bugfix ali drug dodatek.

| # | Korak | Stanje v main | Dokument |
|---|---|---|---|
| **1 ✅** | **Uskladi M11 z main** (main → M11; branch OSTANE, NE merge v main) — **IZVEDENO 2026-07-24** (`e0734ac`+`c27208e`) | na `feat/m11-smart-engine` | [`m11/11-poravnava-v-main.md`](m11/11-poravnava-v-main.md) |
| **2** | **Dokončaj M11** (ostanek faze E) | na branchu | [`m11/09-koraki.md`](m11/09-koraki.md) |
| **3** | **Merge M11 → main** (dark, `kSuggestionsEnabled=false`) — neboleč, ker M11 že vsebuje ves main | v main | — |
| **4** | **FR-20 licenčna infra** | v main (zid obstaja, nič ne zaklepa) | [FR-20 §12](feature-requests/tendask-plus-licensing.md) |
| **5** | **FR-19 lunin koledar** | v main (mena free; bogati del dark) | [FR-19](feature-requests/biodynamic-calendar.md) |
| **6** | **Prižig** | razkritje | §4 spodaj |

**Zakaj ta red:**
- **M11 prvi** — je staralna bomba (125/46 in raste); defuziraj takoj. (FR-19 ne front-loadava, ker po novem modelu ne izide free — glej FR-20 §10.4.)
- **Uskladi → dokončaj → mergaj nazaj (koraki 1→2→3 skupaj, hitro):** uskladitev (korak 1) je le **posnetek** — če main vmes premakneš, M11 spet zaide, zato dokončaj in mergaj nazaj, preden main odtava. Kontekst M11 je takrat tudi v glavi.
- **FR-20 pred FR-19**, ker FR-19 bogati del debitira zaklenjen → zid mora obstajati.
- Koraki 1–4 se dotikajo sheme → gredo **serijsko** (§2).

---

## 4. Prižig (korak 6 — edini »big bang«, in je majhen)

Vse hkrati, en dogodek:

1. `kSuggestionsEnabled = true` + gate M11 kot Plus.
2. FR-19 bogati del: flag on + gate kot Plus.
3. **Deploy `smart-engine` edge funkcije + omogoči cron** (server dark → live).
4. **Masovna 1-letna `granted` licenca vsem obstoječim profilom** (lansirno darilo, FR-20 §10.4).
5. Play Console: `App access` → »Da« + `review` koda (FR-20 §8); listing/posnetki po potrebi (SL/EN/DE).
6. Objavljena zgodba: »Tendask+ je tu, zgodnji uporabniki dobijo **1 leto v zahvalo**.«

M11 in FR-19 bogati del tako **debitirata zaklenjena** → nič grandfatheringa (FR-20 §10.2, §10.4).

---

## 5. Odprto (blokira gradnjo, ne poravnave)

- **FR-20 §11.2** — konkretne cene (letna + doživljenjska).
- **FR-20 §11.3** — Polar ali Paddle.
- **FR-20 §11.4** — dependency za podpis tokena (`tech-stack.md §1`).
- **FR-19 §11.2** — uskladi z novim modelom (»najprej vse free« je preseženo; bogati del ne izide free).

Koraka 1–2 (M11) se **lahko začneta takoj** — nista odvisna od zgornjih odločitev.

---

*Zapisano 2026-07-23. Vrstni red in »deployaj-sproti-razkrij-enkrat« dogovorjena v pogovoru.*
