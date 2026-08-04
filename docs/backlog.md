# Backlog — kaj je odprto

> **Samo negrajeno.** Ko je postavka zaključena, se preseli v [`narejeno.md`](narejeno.md) in se od tod
> **izbriše** — nikoli dve mesti za isto stvar. Trenutno stanje → [`stanje.md`](stanje.md).
>
> Legenda: 📝 spec napisan · 💡 ideja, ni spec ravni · 🔴 izmerjen problem · 🔨 v izdelavi

## Veliki mejniki

| # | Kaj | Stanje | Opomba |
|---|---|:---:|---|
| **M10** | iOS | 💡 | Rabi macOS + Xcode ali oblačni build (Codemagic / GitHub macOS runner) + Apple Developer 99 $/leto. Zraven pridejo iOS dovoljenja, ikone/splash, podpisovanje, TestFlight — in Apple prijava, odložena iz M7. |
| **M11** | Pametni motor + FCM + percentili | ⏸ | **Ustavljen 29. 7. 2026 kot preobsežen.** Zgrajen in ugasnjen na `feat/m11-smart-engine` (pushano, `c643320`). Zagon znova, v majhnih korakih. → [`m11.md`](m11.md) |

**Po M11 ni M12.**

## Lokacija vrta — tri strani istega problema

🔴 **Izmerjeno na produkciji 28. 7. 2026: 55 % uporabnikov (44/80) nima lokacije vrta.** Vsi so prešli
onboarding — preskok je preprosto najlažja poteza. Od Play izdaje 20. 7. je brez lokacije **75 %** novih
(junijska beta: 4 %). Ni bila le vrzel v statistiki: brez celice je `gardenLocation` tiho vrnil **Ljubljano**
→ napačno vreme in motor, ki računa na tuji lokaciji.

| FR | Kaj | Stanje | Doseže | Spec |
|---|---|:---:|---|---|
| **FR-23** | Poziv prek pusha + razlagalni list | 📝 | 52 od 95, ki Domov morda ne odprejo | [`location-nudge.md`](feature-requests/location-nudge.md) |

**FR-22** (brez lokacije ni vremena) in **FR-24** (onboarding) sta ✅ narejena in preverjena na napravi,
oba **še neizdana** → [`narejeno.md`](narejeno.md).

Merilo: 25 % → **≥60 %** novih v 30 dneh, merljivo z `tool/geo_user_map.py`, brez nove analitike.
FR-22 in FR-24 gresta lahko v isto izdajo (odločeno 30. 7.) — če delež zraste, je cilj dosežen;
kateri popravek je prispeval, ni pomembno.

## Tendask+ (monetizacija)

| FR | Kaj | Stanje | Ključna odločitev | Spec |
|---|---|:---:|---|---|
| **FR-20** | Licenciranje, plačila, skladnost s Play | 📝 | **»Consumption-only«**: nakup na spletni strani, v aplikaciji samo odkupna koda → **0 % provizije Play**. Rdeča črta: v aplikaciji **ne sme biti** poziva k nakupu, cene ali URL-ja (velja tudi za pushe in i18n). Plačila prek **merchant of record** (Polar), ne Stripe — normirani s.p. je obdavčen po prihodkih. Offline: podpisan token, javni ključ bundlan, pride z obstoječim pull syncom. **Opomniki ostajajo trajno free** (obljuba iz listinga). | [`tendask-plus-licensing.md`](feature-requests/tendask-plus-licensing.md) |
| **FR-19** | Lunin koledar (koren/list/cvet/plod) | 📝 | Iz feedbacka T10. **Lasten izračun** (siderični položaj Lune), **brez kopiranja Thuninega koledarja** — dejstva in tradicija so prosta, njen izdelek in znamka ne. Nič sheme, synca, mreže ali lokacije: element je čista funkcija datuma. **Mena free; ves preostali del = Tendask+** — gradi se **za flagom (dark)** in **debitira zaklenjen**; ob prižigu vsi obstoječi profili dobijo časovno omejeno **darilo Tendask+** (odločeno 2026-07-30, FR-20 §10.4 + rollout plan). | [`biodynamic-calendar.md`](feature-requests/biodynamic-calendar.md) · [odločitve](feature-requests/biodynamic-calendar-decisions.md) |
| **FR-18** | Več vrtov / lokacij | 💡 | Arhitektura je danes »1 uporabnik = 1 lokacija« (lastnost profila). Vzvod: `area` je že N-na-uporabnika → verjetno dovolj nova `garden` tabela + `area.garden_id`. Groba ocena 2–3 tedne. | [`multi-location.md`](feature-requests/multi-location.md) |
| **FR-21** | Rastlinsko znanje / »Vodič« | 💡 | Iz konkurenčne analize posadi.si + T5. LLM naredi obseg izvedljiv, a je **le pospešek za osnutek** — agronomska halucinacija uniči pridelek in zaupanje → osnutek → navzkrižna preverba → seed, **enkratno v katalog, ne runtime**. Osnovni opis free, poglobljeni = Plus. | [`plant-knowledge-catalog.md`](feature-requests/plant-knowledge-catalog.md) |

**Vrstni red dostave** (prenovljen 2026-07-30, brez M11): FR-19 motor → FR-19 UI dark → FR-20 minimalna
rezina → prižig z darilom → FR-20 trgovina — [`tendask-plus-rollout-plan.md`](tendask-plus-rollout-plan.md);
razrez na korake z branchi: [`plan-implementacije-fr19-fr20.md`](plan-implementacije-fr19-fr20.md).

## Ostalo

| FR | Kaj | Stanje | Opomba | Spec |
|---|---|:---:|---|---|
| **FR-7** | Vreme: deduplikacija + okno ±1 dan | 📝 | Vreme je danes JSON blob na vsakem tasku (~600 B × 3,6 M/leto pri 10 k uporabnikih ≈ 2,1 GB/leto, večinoma podvojeno). Model: vreme = `f(h3_r7, dan)`. **MVP = lokalni hibrid + kompaktiranje; skupna oblačna tabela = V2** (šele skala to opraviči). Opozorilo: Open-Meteo pri 10 k = komercialna raba. Če ta model kdaj nastane, z njim odpade tudi ovira za vreme pri opombah (FR-25): opomba bi vreme svojega dne **poizvedela**, namesto da zamrzne posnetek »zdaj« na poljubno datiran zapis. | [`vreme-shranjevanje.md`](vreme-shranjevanje.md) |
| **FR-10** | Motor: rastline z menjavo/prekinitvami | 📝 | Designerska opomba za M11: kolobarjenje in premiki. Če `user_plant` soft-deletaš in naslednje leto spet dodaš, je to nova vrstica → **izgubljen ritem/obletnica**. Premik med gredami je sprememba area FK, ne nov subjekt — ritem naj se ohrani. | [`m11.md`](m11.md) |
| **FR-14** | Analitika & metrike | 📝 | Shema je odlična za sync, šibka za analitiko (gostje nevidni, LWW upsert = brez zgodovine dogodkov). Dva ločena tira: vedenjska analitika **brez dotika sync sheme**, domenske statistike prek event loga. | [`analytics.md`](feature-requests/analytics.md) |
| **FR-26** | Preureditev zaslona Nastavitve | 💡 | Opažanje lastnika 3. 8. ob pogledu na napravo: profil je edina kartica brez sekcijske oznake → pod **RAČUN & PODATKI**, ob kartico ✦ Tendask+; Tendask+ dobi sekcijsko oznako in ime v kartici odpade; vrstica lokacije dobi pravo ikono bucike namesto emojija 📍. Samo presentation. **Smiselno šele po prižigu (T7)**, ko je kartica sploh vidna. | [`settings-restructure.md`](feature-requests/settings-restructure.md) |
| **FR-15** | Obvestilo o nadgradnji (in-app update) | 📝 | Play In-App Updates = **nova dependency izven `tech-stack.md §1`** → najprej potrdi. Lokalno netestabilno (rabi Play track). Lasten `min_supported_version` gate pride šele z M10/iOS. | [`in-app-update.md`](feature-requests/in-app-update.md) |
| **FR-27** | Domov/Opravila/Dnevnik pri velikem št. vnosov | 💡 | Ni izmerjen problem, proaktivno: Domov omeji DANES/NAZADNJE na okno -1 mesec/+7 dni (rdeč pas zamujenih ostane neomejen), Opravila+Dnevnik dobita search/filter, infinite scroll je nice-to-have dokler ni izmerjena počasnost. | [`list-scaling.md`](feature-requests/list-scaling.md) |

## Odprti bugi

BUG-001…005 → [`bugreport.md`](bugreport.md). Manjša opažanja brez naročenega popravka so v
[`stanje.md`](stanje.md).

**BUG-005** (2026-07-29, odprt): gostov profil ob prijavi brezpogojno prepiše oblačnega — možna tiha
izguba novejše lokacije/jezika/nastavitev. Smer popravka izbrana (zlivanje po stolpcih + test invariante
»ena vrstica profila«), ni implementirana. Odkrit ob zasnovi FR-22, ki ga ne blokira.

## Neobdelan tester-feedback

Opažanja T1–T12 z analizo in odločitvami: [`povratne-informacije.md`](povratne-informacije.md).
