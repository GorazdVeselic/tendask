# FR-18: Več lokacij / vrtov (kandidat za premium »Tendask+«)

- **Status:** ideja / želja (neraziskano do spec ravni, neimplementirano)
- **Datum:** 2026-06-29
- **Področja:** podatkovni model (`profile`/`area`), vreme & klima, pametni motor (M11), sync, monetizacija
- **Povezave:** `docs/koncept.md` §7.7 (ena lokacija = lastnost profila), §7.14 (podatkovni model), `docs/skupnost-agregacija.md` §12.5 (monetizacija Tendask+)

---

## 1. Želja

Uporabnik bi imel **več lokacij / vrtov** (npr. domači vrt + vikend + balkon staršev),
vsak s svojim vremenom in svojimi rastlinami/opravili. Ponudili bi ga lahko kot
**plačljiv dodatek (Tendask+)** — naraven »power-user« vzvod.

## 2. Zakaj je to večji poseg (povzetek analize 2026-06-29)

Trenutna arhitektura je zacementirana na **»1 uporabnik = 1 lokacija«**:
lokacija ni entiteta, je **lastnost profila** (`profile.h3_r7/r6/r5`, PK = `user_id`).
Koncept §7.7 to celo eksplicitno trdi (»vsa območja podedujejo to lokacijo«), zato
je predpogoj **sprememba potrjene odločitve v konceptu**, ne le koda.

Predpostavko bere skoraj vse, kar šteje: vreme/klima (`currentWeatherProvider`,
weather cache hrani **en sam** posnetek), pametni motor M11 (klima na centroid `h3_r7`),
place label, Domov, post-sign-in nav (binarno ima/nima lokacije), sync (profil = 1 vrstica).

**Srečni vzvod:** `area` (območja) je že `N`-na-uporabnika in vse entitete visijo nanj
(`user_plant`, `task` prek `task_subject`, `note`). Zato verjetno **ni treba dodajati
`garden_id` povsod** — dovolj bi bila nova tabela `garden(id, user_id, name, h3_r7/r6/r5, …)`
+ nullable `area.garden_id`; ostalo se navezuje **posredno prek območja**.

## 3. Groba ocena truda

| Sloj | Zahtevnost |
|---|---|
| Shema (drift + Supabase, additive-only) | 🟡 srednje |
| Repo + Riverpod (parametriziraj z »aktivnim vrtom«) | 🔴 veliko |
| Vreme / klima / M11 (cache & motor per-lokacijo) | 🟡 srednje |
| UI (selektor aktivnega vrta, čarovnik za vrt, nav) | 🔴 veliko |
| Sync (`garden` v FK vrstni red pred `area`) | 🟡 srednje |
| Plačilna infrastruktura (IAP — **še ne obstaja**) | 🔴 veliko, ločen mini-projekt |

Solo + AI agent: ~**2–3 tedne** za delujočo funkcionalnost (brez IAP) + ~**1 teden** IAP.

## 4. Tveganja

1. **Zasebnost & skupnost (v2):** več H3 celic na uporabnika = lažja deanonimizacija;
   skupnostna agregacija (`skupnost-agregacija.md`) bi tekla **per-vrtu** → razbije cold-start.
2. **Stari APK-ji:** `h3` mora **ostati** tudi v profilu (additive-only); nekaj časa dvojno vodenje lokacije.
3. **Konceptualni konflikt:** §7.7/§7.14 eksplicitno zanikata več lokacij — najprej posodobi koncept.

## 5. Predlog faziranja (če gremo naprej)

- **Faza 1 (MVP, dnevi):** zgolj **preklop lokacije za vreme** — uporabnik shrani 2–3 imenovane
  lokacije in izbere, katera napaja vremensko kartico; rastline/opravila ostanejo skupni.
- **Faza 2:** prava entiteta `garden` + `area.garden_id` + aktivni vrt skozi vso aplikacijo.
- **Faza 3:** IAP gating kot del `Tendask+`.

> Opomba: multi-location je verjetno **boljši prvi premium feature kot »Okolica«**, ker je
> uporaben takoj (ne potrebuje kritične mase uporabnikov kot skupnostna funkcija).
