# FR-20: Tendask + (premium) — licenciranje, plačila in skladnost s Play

- **Status:** spec / dogovorjena smer (ni implementirano)
- **Datum:** 2026-07-22
- **Avtor:** Gorazd (+ agent)
- **Področja:** Google Play politika plačil, davki/s.p., Supabase (shema + Edge Function), drift, Flutter (nova dependency), Play Console (App access!), spletna stran `tendask.app`
- **Povezave:** [`docs/feature-requests/biodynamic-calendar.md`](biodynamic-calendar.md) (**FR-19 = prvi nosilec Plus**), [`docs/roadmap.md`](../roadmap.md) (Monetizacija, FR-18), [`docs/tech-stack.md`](../tech-stack.md) (§1 sklad), [`CLAUDE.md`](../../CLAUDE.md) (offline-first, additive-only, granti), spomin `tendask-monetization-planned`
- **Delitev dela z FR-19:** ta dokument je **avtoritativen za licenciranje, plačila in Play skladnost**; FR-19 je avtoritativen za **UI Tendask+ zaslona, vstopne točke in free/premium mejo Luninega koledarja** (§11.2–11.4). Ne podvajaj — povezuj.

---

## 1. Povzetek (TL;DR)

**Tendask +** = plačljiv paket funkcij, kupljen **na spletni strani** (ne prek Google Play Billing), unovčen v aplikaciji z **odkupno kodo**, veljaven **offline** prek podpisanega entitlement tokena.

Štiri odločitve, dogovorjene 2026-07-22:

1. **Pot: »consumption-only«** (Netflix model) — nakup zunaj aplikacije, v aplikaciji samo unovčenje/prijava. **0 % provizije Play.** Brez kakršnegakoli poziva k nakupu v aplikaciji.
2. **Plačila: merchant of record** (Polar ali Paddle), **ne Stripe** — ker je normirani s.p. obdavčen po **prihodkih**, ne po dobičku.
3. **Licenca: odkupna koda** (ne ujemanje po e-pošti), enkratna unovčitev, vezana na `auth.uid()`.
4. **Offline: podpisan token** s `plus_until`; aplikacija preverja podpis lokalno, strežnik je »urad, ki izda dokument«, ne vratar.

Če se pokaže, da brez gumba v aplikaciji ni konverzije → **pot B** (Googlov external payments program, ~10 % service fee, geo-pogojeno). Arhitektura licenc je v obeh primerih **enaka**, zato ni izgubljenega dela.

**Prvi nosilec = FR-19 (Lunin koledar).** Odločeno 2026-07-22 v FR-19 v2: mena Lune ostane **free** (kavelj, gradi navado), **element-dan + koledar/planer + akcije = Plus**. Zdaj je vse še free; premium meja se prižge šele s tem FR-jem.

---

## 2. Kaj Google dovoli (stanje 2026-07)

### 2.1 Osnovno pravilo

> »Google Play's billing system is required for developers offering in-app purchases of digital goods and services distributed on Google Play.«
> — [Payments policy](https://support.google.com/googleplay/android-developer/answer/10281818?hl=en)

### 2.2 Izjema, ki jo uporabljava — »consumption-only«

Politika **izrecno dovoli** aplikacijo, kjer uporabnik dostopa do vsebine, plačane drugje:

> »a user could log in when the app opens and access content paid for somewhere else«

Pogoj (železen):

> »Within an app, developers may not lead users to a payment method other than Google Play's billing system unless Section 3, 8, or 9 of Payments policy applies.«

In hkrati:

> »Outside of your app, you are free to communicate with your users about alternative purchase options.«

### 2.3 Nova pot od 30. 6. 2026 (ZDA / UK / EGP)

Google je odprl **external payments / external offers** program: dovoljen je gumb v aplikaciji, ki vodi na razvijalčevo spletno stran (ali lasten plačilni sistem v aplikaciji).

| Postavka | Vrednost |
|---|---|
| **Service fee** | od **10 %** na prvi $1M/leto — velja **ne glede na metodo** (Play Billing / alt billing / zunanja povezava) |
| **Billing fee** | **5 %** (ZDA/UK/EGP) — **samo** za transakcije prek Google Play Billing |
| Zunanje plačilo prek povezave iz aplikacije | service fee **da**, billing fee **ne** |
| Prijava v program | **obvezna** |
| Pokritost | ZDA, UK, EGP — **ne** vseh 40 držav, kjer je Tendask objavljen |

⚠️ **Nepotrjeno:** en sekundarni vir omenja **20 % service fee za transakcije, izvedene v 24 urah po link-outu**. V uradni dokumentaciji tega nisva potrdila — pred vklopom poti B preveri v Play Console.

### 2.4 Posledica za naju

- **Brez prijave v program:** v aplikaciji **ni** poziva k nakupu, cene, URL-ja, niti stavka »kupite na spletni strani«. Dovoljeno je nevtralno stanje + unovčenje.
- **S prijavo:** gumb je dovoljen, a stane ~10 % in zahteva **geografsko pogojevanje** (uporabnik izven ZDA/UK/EGP ostane pod starim anti-steering režimom).

**Viri:** [Payments policy](https://support.google.com/googleplay/android-developer/answer/10281818?hl=en) · [Lower service fees](https://support.google.com/googleplay/android-developer/answer/16954621?hl=en) · [Expanded billing choice (blog)](https://android-developers.googleblog.com/2026/06/play-expanded-billing.html) · [External payment links](https://developer.android.com/google/play/billing/externalpaymentlinks) · [External offers EEA](https://support.google.com/googleplay/android-developer/answer/16505463?hl=en)

---

## 3. Kako smeva oglaševati Tendask + (brez kršitve)

| Kanal | Smem povedati, da Plus obstaja? | Smem navesti ceno / povezavo do nakupa? |
|---|---|---|
| **V aplikaciji** | ✅ nevtralno stanje: »Tendask +: ni aktiven«, gumb »Vnesi kodo« | ❌ **ne** (ne cena, ne URL, ne CTA »kupi«) |
| **Play Store listing** (opis, posnetki) | ✅ da | ⚠️ opis ni »within an app« — a **ne** delaj iz njega prodajne strani; brez cene/URL-ja, da ne izzoveš pregleda |
| **Spletna stran `tendask.app`** | ✅ | ✅ brez omejitev |
| **E-pošta uporabniku** | ✅ | ✅ brez omejitev |
| **Družbena omrežja, blog, forumi** | ✅ | ✅ brez omejitev |
| **Push obvestilo iz aplikacije** | ⚠️ | ❌ obravnavaj kot »within an app« — brez CTA k nakupu |

**Praktična strategija promocije brez kršitve:**
1. Ob registraciji/prijavi uporabnik pusti e-pošto → tja gre komunikacija o Plus.
2. Spletna stran je edino prodajno mesto — SEO + vsebina (vrtnarski nasveti) je glavni lijak.
3. V aplikaciji uporabnik naleti na Plus **funkcijo**, ne na ponudbo: zaklenjena funkcija pokaže mirno »Na voljo v Tendask +« + gumb »Vnesi kodo«. Brez cene, brez povezave.

⚠️ **Rdeča črta:** noben niz v `i18n/*.i18n.json`, ki bi vabil k nakupu ali navajal ceno/naslov. To je edina stvar, ki lahko stane odstranitev aplikacije.

### 3.1 Presoja načrtovanega UI iz FR-19 (skladno ✅)

FR-19 §11.2–11.4 predvideva: čip na Domov viden **v obeh stanjih**, brez licence z rdečim »✦ Tendask+ ›« → **zaslon Tendask+** z **vnosom kode + »Aktiviraj« + opisom ugodnosti**, brez gumba »Kupi« in brez URL-ja.

To je **znotraj politike**: promocija lastne funkcije in vnos licence nista »leading users to a payment method«. Kritični sta dve podrobnosti, ki se ju je treba držati ob implementaciji:

- **Opis ugodnosti brez cene in brez naslova strani.** »Odklene lunin koledar in planer« ✅ · »2,99 €/mesec na tendask.app« ❌.
- **Brez namigov, kje dobiti kodo.** Niti »kodo dobite na naši spletni strani« — to je usmerjanje. Dovoljeno je le nevtralno »Vnesite licenčno kodo«.

---

## 4. Pobiranje plačil (normirani s.p.)

### 4.1 Ključni davčni argument

**Normiranec je obdavčen po prihodkih, ne po dobičku** → provizija plačilnega ponudnika **ne zniža** davčne osnove. To obrne običajno logiko:

- **Stripe** = ti si merchant of record → tvoj prihodek je **bruto** plačilo stranke; Stripova provizija je čist strošek in te hitreje potiska proti pragu normiranca. Poleg tega DDV po državi kupca (OSS), računi, chargebacki = tvoje delo.
- **Merchant of record (Polar / Paddle)** = prodajalec končnemu kupcu so **oni**; ti izdaš račun njim za **neto** izplačilo → provizija dejansko zniža davčno osnovo, DDV/OSS/računi/chargebacki pa niso tvoja skrb.

### 4.2 Primerjava (2026)

| Ponudnik | Provizija | Opomba |
|---|---|---|
| **Polar** | 5 % + ~0,50 $ (free tier); 3,8 % + 0,40 $ pri 20 $/mes | +1,5 % ne-US kartice; razvijalsko najprijetnejši API/webhooki |
| **Paddle** | 5 % + ~0,50 $ | najbolj uveljavljen; B2B reverse charge; skladni računi |
| **Lemon Squeezy** | 5 % + ~0,50 $ | +1,5 % mednarodne kartice, +0,5 % naročnine → v praksi najdražji |
| **Stripe** | ~1,5 % + 0,25 € (EGP kartice) | najcenejši na papirju, a MoR si ti |

**Odločitev: Polar ali Paddle.** Razlika ~3,5 % stane manj kot ura računovodje mesečno.

### 4.3 Vprašanja za računovodjo (ne ugibava)

1. Ali moraš pridobiti **ID za DDV** samo zaradi prejemanja storitev iz tujine (obrnjena davčna obveznost), tudi če nisi zavezanec doma? *Klasična past pri Stripe/Paddle/Google.*
2. Kako se knjiži MoR izplačilo — potrjeno kot prihodek = **neto**?
3. Kje je tvoj prag za normiranca in kdaj ga naročnine iztirijo?
4. Ali rabiš spremembo dejavnosti (SKD) za prodajo digitalnih storitev potrošnikom?

### 4.4 Pravno na spletni strani

- Pogoji uporabe + politika zasebnosti + politika vračil.
- **EU: 14-dnevna pravica do odstopa** za digitalno vsebino → ob nakupu izrecna privolitev v takojšnjo izvedbo (checkbox), sicer imaš 14 dni obvezno vračilo.
- Jasni pogoji odpovedi naročnine (samopostrežno prek MoR portala).

---

## 5. Licenčni model

### 5.1 Zakaj koda in ne e-pošta

Uporabnik ima v Tendask lahko **anonimen** ali **Google** račun z drugim naslovom, kot ga vpiše ob nakupu. Ujemanje po e-pošti bi od prvega dne generiralo podporne zahtevke. Koda deluje ne glede na to + omogoča darila in kupone.

**Pravilo: unovčitev zahteva prijavljen račun (Google/OTP), ne anonimnega.** Sicer uporabnik ob menjavi telefona izgubi plačano licenco in tega ne moreš rešiti.

### 5.2 Tok

```
nakup na tendask.app  →  webhook (Polar/Paddle)
   →  Supabase Edge Function (service role)  →  vrstica v `license` (koda + plus_until)
   →  e-pošta s kodo kupcu
   →  uporabnik vnese kodo v aplikaciji  →  RPC veže kodo na auth.uid()
   →  profile.plus_until + podpisan token
   →  obstoječi pull sync  →  drift  →  Plus deluje offline
```

### 5.3 Offline ≠ nikoli online (razrešitev navideznega nasprotja)

Strežnik **ni vratar, ki ga aplikacija kliče vsakič**. Strežnik je **urad, ki izda dokument**; vratar je aplikacija sama.

Analogija: letna vozovnica s hologramom. Šofer ne kliče centrale — pogleda hologram in datum. Ponarediti je ne moreš, ker nimaš stroja za holograme. Ko poteče, greš na okence.

| Kdaj | Rabi internet? | Kaj se zgodi |
|---|---|---|
| Nakup | **da** | plačilo je itak online |
| **Vnos kode** | **da, enkrat** | edini obvezni online trenutek |
| Izdaja tokena | — | podpisan token s `plus_until` |
| Na vrtu, tri tedne brez signala | **ne** | aplikacija lokalno preveri podpis + datum |
| Slučajno doma na wifi | mimogrede | običajni pull prinese **nov** token z novim datumom |

**Ključno:** ne gradiva nobenega ločenega »preverjanja licence«. Token pride zraven v istem pull-u, ki že zdaj vleče opravila in katalog. **Nič novega omrežnega dela.**

### 5.4 Kaj se preverja kje

**Lokalno, offline, ob vsakem zagonu:**
- je podpis pristen? → prepreči ročno predelavo drift baze
- je `sub == moj uid`? → prepreči kopiranje tujega tokena
- je `now < plus_until`? → prepreči večno veljavnost

**Na strežniku, brez sodelovanja aplikacije:**
- je bila koda že unovčena? (ob unovčitvi)
- koliko naprav? (ob unovčitvi/syncu)
- je bilo vračilo/preklic? (webhook) → strežnik preprosto **neha izdajati nove tokene**

---

## 6. Preprečevanje zlorab

**Načelo:** en trd zid (kriptografski podpis), vse ostalo mehke DB invariante. Ponarejanje mora biti dražje od naročnine, ne nemogoče.

### 6.1 Večkratna uporaba kode

Ena atomarna poizvedba, brez race pogoja:

```sql
update license
   set redeemed_by = auth.uid(), redeemed_at = now()
 where code = $1
   and redeemed_by is null
   and revoked_at is null
returning plus_until;
```

Nič vrnjeno → neobstoječa / porabljena / preklicana. `update ... where` zaklene vrstico → dva hkratna poskusa ne moreta oba uspeti.

### 6.2 Ponarejanje offline (edini pravi zid)

Podpisan token (ES256 / Ed25519): privatni ključ v Supabase secrets, **javni ključ bundlan v aplikaciji**.

```
{ sub: <uid>, plus_until: <ts>, iat: <ts> }
```

- Predelana vrstica v driftu nima veljavnega podpisa → Plus ugasne.
- Kopiran tuj token ima tuj `sub` → ne velja.
- ⚠️ Rabi **nov package** (`dart_jsonwebtoken` ali `cryptography`) — izven `tech-stack.md §1` → najprej potrdi.
- Za čas uporabi `Clock` (pravilo projekta), ne `DateTime.now()` — sicer ni testabilno.

**Veljavnost tokena ≠ trajanje licence** (velja, če bo v ponudbi doživljenjska):

```
token.plus_until = min(entitlement_until, now + 12 mesecev)
```

Doživljenjska licenca **ne sme** izdati tokena z `plus_until = 2099` — tak token je neizničljiv, ker se naprava ni dolžna nikoli več sinhronizirati, in ga ob vračilu ali zlorabi ne moreš preklicati. Z zgornjim pravilom se letne licence ne spremenijo (so itak krajše), doživljenjska pa omeji izpostavljenost na eno leto; kupec se mora enkrat letno slučajno povezati, kar se zgodi samo od sebe.

### 6.3 Potek, odpoved, vračilo, preklic

Vse prek webhookov v isto Edge Function, ki samo prepiše `plus_until`:

| Dogodek | Učinek |
|---|---|
| `subscription.created` / `renewed` | `plus_until = period_end + kLicenseGraceDays` |
| `subscription.canceled` | pusti do `period_end` (plačal je) |
| `refund` / `chargeback` | `plus_until = now()`, `revoked_at = now()` |
| ročni preklic (zloraba) | `revoked_at = now()` |

**Grace je na strežniku, ne v aplikaciji.** Strežnik prišteje 7–14 dni k `period_end`; aplikacija pozna eno samo pravilo (`now < plus_until`). Plačnik, ki je tri tedne na vrtu, ne izgubi ničesar.

Maksimalna izpostavljenost ob preklicu = **ena obračunska perioda + grace**. To je cena offline-first delovanja in jo sprejemava.

### 6.4 Deljenje računa

- `license_device (license_id, install_id, last_seen_at)`, **3 sedeži**
- `install_id` = naključni UUID ob prvi namestitvi — **nikoli IMEI/Android ID** (pravilo zasebnosti)
- Ob preseganju: **izvrzi najstarejšo napravo**, ne zavrni nove (uporabnik z novim telefonom ne sme klicati podpore)

### 6.5 Drobnarije

- **Oblika kode:** Crockford Base32, 16 znakov (brez I/L/O/U), normaliziraj velikost črk in vezaje pred primerjavo.
- **Rate limit:** ≤5 neuspelih poskusov/uro/`auth.uid()`, beleži v `license_redeem_attempt`.
- **Ne razlikuj razloga napake:** vedno »koda ni veljavna« (neobstoječa / porabljena / preklicana) — sicer uhajanje informacij.

### 6.6 Poštena luknja (zavestno sprejeta)

Kdor unovči kodo, gre za vedno offline **in** premakne uro nazaj, obdrži Plus. Obramba (Play Integrity, zaznava root-a, obvezno online preverjanje) bi zlomila prav tisto, zaradi česar aplikacija obstaja.

---

## 7. Shema (skica)

```
profile
  + plus_until  timestamptz null          -- additive, nullable (stari APK-ji!)
  + plus_token  text null                 -- podpisan JWT

license
  id uuid pk, code text unique, plus_until timestamptz,
  redeemed_by uuid null → auth.users, redeemed_at timestamptz null,
  revoked_at timestamptz null, provider text, provider_ref text,
  created_at, updated_at

license_device
  license_id → license, install_id text, last_seen_at

license_redeem_attempt
  user_id, attempted_at, success bool
```

**Pravila (iz `CLAUDE.md`):**
- Migracija **additive-only**, nova stolpca **nullable** → stari APK-ji ob pull-u ne crashajo.
- **Eksplicitni granti v isti migraciji.** `license*` tabele **nimajo** granta za `authenticated` — dostop samo prek `security definer` RPC.
- `plus_until` in `plus_token` sta **strežniško lastna**: `revoke update (plus_until, plus_token) on profile from authenticated` (column-level grant, ker RLS ne zna po stolpcih).
- **Sync push mora ta stolpca izpustiti** iz payloada — sicer si predelan klient prek LWW podari Plus.
- Drift shema zrcali Supabase (nova verzija sheme + migracija).

---

## 8. Posledice v Play Console

⚠️ **Najbolj spregledana točka.**

1. **`App access` se mora spremeniti.** Zdaj je »Ne, nič ni gate-ano« — to je pravilno za free aplikacijo. Ko dodaš Plus, **moraš Googlu dati testni račun z aktivno licenco** (ali kodo za unovčitev v navodilih), sicer pregled pade ali Plus funkcije nikoli niso pregledane.
2. **Data Safety** — če MoR hrani e-pošto kupca, preveri, ali se kaj spremeni (verjetno ne, ker plačilo teče zunaj aplikacije).
3. **Ni** potreben Merchant/payout setup v Play Console (ne uporabljava Play Billing).
4. Listing opis lahko omeni Plus, a **brez cene in URL-ja do nakupa**.

---

## 9. Kaj namenoma NE gradiva

- Play Integrity API, zaznavo root-a, obfuskacijo, preverjanje integritete APK-ja
- Strežniško validacijo ob vsakem zagonu
- Ujemanje licence po e-pošti
- Lasten plačilni sistem / Stripe kot merchant of record
- Google Play Billing (`in_app_purchase` / RevenueCat) — **razen** če se kdaj odločiva za pot B v celoti

---

## 10. Obseg paketa — kaj sme in kaj ne sme v Plus

> **Pravilo (odločeno 2026-07-22): Plus se gradi iz novega in neizdanega, nikoli iz izdanega.**
> Edina dovoljena izjema je **razširitev zmogljivosti** (več tega, kar uporabnik že ima) — tam nihče ničesar ne izgubi.

Zakaj tako strogo:

- **Ocene na Play.** Odvzem obstoječe funkcije je zanesljiv generator enozvezdičnih ocen. Te te stanejo več, kot znaša celoten prihodek Plus.
- **Listing je obljuba.** Julijska posodobitev listinga (SL/EN/DE) izrecno navaja **sredstva, recepte, pridelek in teme**. Zaklepanje česarkoli od tega zahteva popravek opisa **in** posnetkov zaslona v treh jezikih + nov pregled.
- **Ne zaklepaj zanke zadrževanja.** Kar uporabnika vrača v aplikacijo, mora ostati brezplačno — sicer brezplačni uporabnik odide, preden bi sploh premislil o plačilu.

### 10.1 Opomniki ostajajo trajno brezplačni (odločeno, ni odprto)

Preverjeno kot možnost in **zavrnjeno** 2026-07-22:

1. **So obljuba iz listinga** in so na posnetkih zaslona.
2. **So zanka zadrževanja** — opomnik je razlog za vrnitev; FR-16 (re-engagement nudge) stoji na istem sistemu.
3. **Brez njih Tendask ni več dnevnik opravil, ampak zapisnik.**

Monetizirati se sme le **nov sloj nad njimi** (glej 10.2), nikoli sam mehanizem obveščanja.

### 10.2 Kandidati za Plus

| Kandidat | Stanje | Strošek na uporabnika | Opomba |
|---|---|---|---|
| **M11 pametni motor / predlogi** | **zgrajen (faze A–D) na `feat/m11-smart-engine`, NIKOLI izdan** — v `main` ni `lib/features/suggestions/` | **realen** (edge funkcije, cron, FCM, vreme) | Najboljši kandidat: nihče ničesar ne izgubi, najvišja zaznana vrednost, razvoj večinoma plačan |
| **FR-19 lunin koledar** (element-dan, planer, akcije) | spec, gradi se **najprej free** | **nič** (čista funkcija datuma) | Prvi nosilec; mena Lune ostane free |
| **FR-18 več vrtov/lokacij** | ideja | nizek | Razširitev zmogljivosti — danes ima vsak 1 vrt in ga obdrži |
| **Vremensko pogojeni opomniki** | ne obstaja | nizek (vreme že imava) | »Ne opominjaj na zalivanje, če bo dež« — pošten način monetizacije opomnikov |
| **Opomnik po fazi Lune** | ne obstaja | nič | Naravna vez s FR-19 |
| **FR-14 analitika** | spec | nizek | Kasnejša širitev paketa |

**Posledica za cenovni model:** M11 ima **ponavljajoč se strošek**, lunin koledar pa nobenega. Funkcija, ki te stane vsak mesec, ne sme biti plačana enkrat za vedno → M11 v paketu je argument **za letno naročnino in proti neomejeni doživljenjski** (glej §11.2).

### 10.3 Trajno brezplačno (nikoli v Plus)

- **Opomniki** in vse osnovno obveščanje (§10.1)
- Opravila, dnevnik, območja, rastline, vreme — jedro aplikacije
- **Sredstva, recepti, pridelek, teme** — izdano in navedeno v Play listingu
- **Izvoz podatkov in izbris računa** — zakonska obveznost (GDPR)
- **Mena Lune** — free sloj FR-19 (kavelj, gradi navado)

### 10.4 Grandfathering ob vklopu plačilnega zidu

Lunin koledar gre v produkcijo **brezplačen** in se zaklene šele kasneje (§12). To je edini primer, kjer se izdana funkcija umika za zid — in zato zahteva izrecno varovalko:

**Vsi, ki so funkcijo uporabljali pred datumom vklopa, jo obdržijo trajno brezplačno.** Tehnično: ob vklopu enkratno označi obstoječe uporabnike (npr. `profile.plus_grandfathered bool`, dodeljeno strežniško po `updated_at`/uporabi pred mejnim datumom).

Iz tega naredi **objavljeno zgodbo** (»zgodnji uporabniki obdržijo vse«), ne tihega popravka. Val enozvezdičnih ocen stane več kot celoten prihodek Plus.

---

## 11. Odprta vprašanja / odločitve

1. ~~**Katere funkcije so Plus?**~~ **Odločeno (2026-07-22): prvi nosilec je FR-19** — element-dan + koledar/planer + akcije; mena Lune ostane free. **Opomniki so izrecno izključeni** (§10.1). Seznam kandidatov za širitev = §10.2, pri čemer je **M11 (zgrajen, a nikoli izdan) najmočnejši**. *Odprto ostaja, ali Plus starta z eno funkcijo ali počaka na dve — enofunkcijski paket je težje prodati; par »FR-19 kavelj + M11 vsebina« je najbolj obetaven.*
2. **Cena in model.** **Mesečna naročnina zavrnjena (2026-07-22)** — v igri ostaneta **letna + doživljenjska**; **konkretne številke namenoma še niso zapečene.** Podlaga za odločitev:
   - Fiksni del provizije MoR (~0,50 $) požre mesečno: pri 1,99 € ti ostane **1,05 €** (47 % izgube), pri letni 9,90 € pa **7,20 €**, pri doživljenjski 29,90 € **22,80 €** (računano z 22 % DDV in 5 % + 0,50 $ MoR).
   - **Prelomna točka: 7 mesecev.** Mesečna prehiti letno šele, če povprečen naročnik vztraja ≥7 mesecev (7,20 ÷ 1,05 = 6,9). Pri sezonski dejavnosti in slovenski zimi je to malo verjetno, a **ni izmerjeno** — je ocena, ne podatek.
   - Odločilnejši, ker ne temelji na ugibanju: **pri letni ceni ~9,90 € mesečna tarifa ne more obstati.** Sorazmerna mesečna bi bila ~1,00–1,20 € (pod pragom fiksne provizije); pri 1,99 € pa je letna le 5 mesečnih → vsi vzamejo letno in mesečna je mrtva izbira, ki le zapleta podporo in knjiženje.
   - **Trenje ubija prednost mesečne.** Ker v aplikaciji ni povezave do nakupa, mora kupec sam najti stran, plačati in prekopirati kodo. Nizka vstopna cena tu ne kupi obsega — le manj denarja od istih ljudi.
   - **Sidro za ceno:** tiskane *Lunine bukve 2026 s setvenim koledarjem* stanejo **9,90 € + poštnina** — isti kupec, isti namen, vsakoletni nakup. Primerljive aplikacije: Planta/Vera enkratno ~10 $, vrtnarske aplikacije ~4–50 $/leto.
   - **Razmislek o razmerju:** doživljenjska se običajno postavi na 2,5–3× letne. Ne kanibalizira letne, ker načelni nasprotniki naročnin sicer ne kupijo ničesar.
   - **Vezano na obseg paketa (§10.2):** M11 ima ponavljajoč se strošek → če je v paketu, govori proti neomejeni doživljenjski (ali za njeno omejitev na lansirno ponudbo).
   - **Vmesna možnost, če bo potreba:** sezonska licenca 6 mesecev (ena transakcija, ujame sezonsko vedenje brez upravljanja odpovedi).
3. **Polar ali Paddle?**
4. **Nova dependency za preverjanje podpisa** — kateri paket, in posodobitev `tech-stack.md §1`.
5. **`kLicenseGraceDays`** — 7 ali 14?
6. **Število sedežev** — 3 ali več?
7. **Trial?** (npr. 14 dni Plus ob prvi prijavi) — poveča konverzijo, a doda stanje.
8. **Kdaj?** Ni launch-gating; aplikacija je v produkciji in free.

---

## 12. Predlagan vrstni red 1. iteracije

1. Odloči funkcije + ceno + ponudnika (§11.1–3).
2. Uskladi `tech-stack.md §1` z novo dependency za podpis.
3. Supabase migracija (additive + granti) + Edge Function za webhook + RPC `redeem_license`.
4. Spletna stran: nakupna stran + pogoji + politika vračil (ločen repo `../tendask_web/`).
5. Aplikacija: `plusProvider` (bere iz drifta, preverja podpis prek `Clock`) + zaslon Tendask+ — **UI po FR-19 §11.3–11.4**, ne izmišljuj novega.
6. i18n (en/sl/de) — **pregled vseh nizov glede anti-steering** pred oddajo (§3.1).
7. Play Console: posodobi `App access` s testno kodo.
8. DoD on-device: unovčitev → letalski način → Plus dela; predelana drift vrstica → Plus ugasne.

**Vrstni red glede na FR-19:** Lunin koledar se gradi **najprej v celoti free** (FR-19 §11.2: »etapno — najprej vse free«). Ta FR se aktivira šele, ko je funkcija zrela in ima uporabnike; gating je zadnji korak, ne prvi.

---

*Odločeno 2026-07-22 v pogovoru. Naslednji korak ni tehničen: §11.2 (konkretne cene) in §11.3 (Polar ali Paddle) — brez njiju infrastrukture ni smiselno graditi.*
