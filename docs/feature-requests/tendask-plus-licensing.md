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

**Odločitev proti Stripu: MoR.** Razlika ~3,5 % stane manj kot ura računovodje mesečno.

### 4.3 Polar proti Paddlu — priporočilo (odprto za potrditev, §11.3)

| | **Polar boljši** | **Paddle boljši** |
|---|---|---|
| Zrelost | — | od 2012, tisoče podjetij; **skoraj gotovo bo čez 5 let še tu** |
| Registracija | samopostrežna, takoj | preverjanje prodajalca pred go-live (traja, sprašujejo) |
| Izplačilo | — | **naravnost na banko**, brez vmesnega Stripe Express |
| Davki | pokrije DDV/OSS | globlji robni primeri, B2B reverse charge, računi po državah |
| Razvijalska izkušnja | moderni API, SDK-ji, **sandbox**, odprta koda | starejši občutek |
| Vgrajeno | License Keys, portal za kupca | zrelo upravljanje naročnin: dunning, ponovni poskusi, **opomniki pred obnovitvijo** |
| Cena | 5 % + 0,50 $, **cenejše stopnje + Startup Program** | 5 % + 0,50 $, brez cenejših stopenj |
| Tveganje | mlado podjetje (~2023) | — |

**Priporočilo: Polar.** Trije razlogi:

1. **Tveganje platforme je že ublaženo** — ker po §5.2 vse zrcališ v Supabase, je menjava ponudnika **prepis webhooka, ne selitev podatkov**. Odločitev ni za pet let in je reverzibilna.
2. **Prodajaš potrošnikom, ne podjetjem** → Paddlova največja prednost (B2B reverse charge, zahtevni računi) te ne zadeva.
3. **Sandbox, portal in Startup Program skrajšajo delo zdaj**, ko to delaš prvič in sam.

**Preskoči na Paddle, če:** Stripe Express onboarding za s.p. ne steče, **ali** Polar ne pošilja opomnika pred obnovitvijo (pri starejši publiki je to pomembno, §5.1).

⚠️ **Startup Program naj NE odloči izbire.** Razlika je ~0,30 € na letno prodajo (~30 € pri stotih) — to ni argument za ponudnika, s katerim boš živel leta.

### 4.4 Polar: predpogoji in okolja

**Stripe Express je obvezen predpogoj za go-live.** Polar izplačuje prek **Stripe Connect Express** — enkratni onboarding, kjer postaneš lastnik računa in pravni prejemnik sredstev. To **ni** Stripe kot tvoja blagajna (to sva zavrgla) — je izplačilna cev; MoR ostaja Polar in davčna slika iz §4.1 se ne spremeni. Za s.p. bo Stripe hotel davčno in matično številko, osebni dokument in IBAN. **Izplačila so ročna** — sprožiš jih sam.

**Sandbox se ujema z obstoječim staging okoljem:**

| | Polar | Supabase | Build |
|---|---|---|---|
| Test | `sandbox.polar.sh` / `sandbox-api.polar.sh/v1` | staging | `deploy.bat hot` |
| Živo | produkcija | prod | `deploy.bat release` |

Sandbox je popolnoma izoliran (ločen račun, organizacija in tokeni — produkcijski token tam ne dela), plačila s Stripovimi testnimi karticami. **ngrok ni potreben** — staging tunel `api-staging.tendask.app` je že javno dosegljiv, torej lahko Polar kliče webhook naravnost nanj.

Preveri pred tem: (a) ali staging stack sploh poganja `supabase/edge-runtime`, (b) da sta base URL in token **konfiguracija, ne konstanta** (isti vzorec kot obstoječi env-switch).

⚠️ **Letne obnovitve v sandboxu ne moreš počakati.** Za preizkus poti podaljšanja naredi **testni izdelek s kratkim obdobjem**, ali ročno sproži webhook s posnetim payloadom. Sicer bo »podaljšanje« edini del sistema, ki ga nikoli nisi videl delovati — in se zgodi šele čez leto dni, ko boš na napako pozabil.

**Startup Program** (`polar.sh/startup-program`): 12 mesecev na Scale pogojih (3,40 % + 0,30 $) brez 400 $/mesec, s shared Slack kanalom in P1 podporo. Prijava zahteva datum ustanovitve, zbran kapital, obseg plačil, velikost ekipe in 100 besed o izdelku. **Pogoji upravičenosti niso javno objavljeni** — z obsegom plačil 0 in brez investitorjev je sprejem negotov; prijava stane ~15 minut. ⚠️ **Ceno postavi na standardno tarifo (5 % + 0,50 $)** — ugodnejša je bonus prvega leta, ne osnova.

### 4.5 Vprašanja za računovodjo (ne ugibava)

1. Ali moraš pridobiti **ID za DDV** samo zaradi prejemanja storitev iz tujine (obrnjena davčna obveznost), tudi če nisi zavezanec doma? *Klasična past pri Stripe/Paddle/Google.*
2. Kako se knjiži MoR izplačilo — potrjeno kot prihodek = **neto**?
3. Kje je tvoj prag za normiranca in kdaj ga naročnine iztirijo?
4. Ali rabiš spremembo dejavnosti (SKD) za prodajo digitalnih storitev potrošnikom?

### 4.6 Pravno na spletni strani

- Pogoji uporabe + politika zasebnosti + politika vračil.
- **EU: 14-dnevna pravica do odstopa** za digitalno vsebino → ob nakupu izrecna privolitev v takojšnjo izvedbo (checkbox), sicer imaš 14 dni obvezno vračilo.
- Jasni pogoji odpovedi naročnine (samopostrežno prek MoR portala).

### 4.7 Umestitev na spletni strani (`../tendask_web`)

Stran je **statična in taka ostane** — Polar gosti blagajno, zato je gumb navadna povezava. Nič JS, nič obrazcev, nič PCI, nič DDV logike, **nič fiksnih stroškov** (Cloudflare Pages + Supabase free tier + Polar samo % na prodajo).

Trenutna struktura je en landing (`hero → #features → #shots → #okolica → #community`) z navigacijo na tri sidra.

| Kam | Kaj |
|---|---|
| **`/plus`** (+ `/sl/plus`, `/de/plus`) | **edino mesto s ceno in gumbom** — SEO tarča, naslov za e-pošto |
| **Nav, 4. postavka »Tendask +«** | vizualno ločena (medena `#E0A82E`); **glavna pot odkritja**, ker aplikacija ne sme voditi na nakup |
| **Landing: nova sekcija med `#okolica` in `#community`** | kratka vaba (kaj odklene + »od X €« + gumb na `/plus`); **NE v hero** — naloga hera je namestitev |
| **Footer** | »Tendask +« + **»Upravljanje naročnine / izgubljena koda«** → Polarjev portal (vsak klik = e-pošta, ki je ne prejmeš) |

**Vsebina `/plus`:** kaj odklene konkretno (ne »premium«) · **poštena tabela brezplačno/Plus** (pomiri strah »zdaj bodo vse zaklenili«) · **aktivacija v treh korakih** (kupiš → koda po e-pošti → prilepiš v aplikacijo; brez tega bo polovica pisala na `support@`) · dva gumba · 14-dnevno vračilo ob gumbu · FAQ (offline? menjava telefona? odpoved? izgubljena koda?).

⚠️ **Popravi hero značko `t.hero.free`** — ko bo Plus živ, je trditev »brezplačno« zavajajoča → »Brezplačen prenos« / »Osnovno brezplačno«, v vseh treh jezikih.

**Kje bo dejansko promet:** sekcija na landingu prinese malo. Ker aplikacija ne sme oglaševati navznoter, je pravi lijak **vsebina, ki jo ljudje iščejo** — v SI se aktivno išče, kdaj je dan za plod/koren. Brezplačna vsebinska stran o luninem koledarju s povezavo na `/plus` je verjetno vredna več kot vse ostalo skupaj (`src/content/` že obstaja).

---

## 5. Licenčni model

### 5.1 Ponudba = dva izdelka (odločeno 2026-07-22)

| Izdelek | Tip v Polarju | Obnovitev |
|---|---|---|
| **Tendask + letno** | naročnina (yearly) | samodejna, z jasnim »odpoveš kadarkoli, plačano leto ti ostane« |
| **Tendask + doživljenjsko** | enkratni nakup | ni je |

**Zavrnjeno in zakaj:**

- **Plačano testno obdobje (npr. 1 mesec za 2 €)** — ne zaradi denarja (neto ostane ~1,06 €), ampak ker **vsak izdelek nosi svoj ključ**: uporabnik bi kodo lepil dvakrat (test, nato letna). Poleg tega vrne vse breme mesečne (neuspela plačila, odpovedi, 12× transakcij). **Ovira ni cena, ampak trenje** — nakup zahteva izhod iz aplikacije, iskanje strani in prepis kode; za 2 € ta pot ni vredna.
  **Nadomestek (brezplačen):** 14-dnevno vračilo brez vprašanj (po EU pravu ga tako ali tako moraš ponuditi) + brezplačni sloj (mena Lune) + podarjene kode (`granted`).
- **Ločena »letna brez obnovitve«** — ni svoj izdelek. Naročnino kupiš in **takoj odpoveš → leto ti vseeno ostane**. To je enkratni nakup brez druge SKU.

**Pravilo ponudbe:** pri izdelku za ~10 € sta dve možnosti razumljivi v treh sekundah, tri so zgornja meja. Če bo kdaj potrebna tretja, naj bo **sezonska (6 mesecev)**, ne mesečna.

⚠️ **Če ostane samodejna obnovitev:** obvezen **opomnik po e-pošti 7 dni pred bremenitvijo** (preveri, ali ga pošilja Polar; sicer je to edini e-mail, ki ga moraš pošiljati sam). Publika je starejša — pozabljena bremenitev čez leto dni pomeni chargeback in enozvezdično oceno.

### 5.2 Delitev vlog

| Polar (MoR) | Tendask (Supabase) |
|---|---|
| pobere denar, DDV, račun | vodi, **kdo ima Plus in do kdaj** |
| **ustvari aktivacijsko kodo** (License Key benefit) | shrani kodo in jo veže na `auth.uid()` |
| **pošlje kodo kupcu po e-pošti** | izda **podpisan offline token** |
| ponuja kupcu portal (koda, odpoved, računi) | odloči, kaj dogodek pomeni |
| sporoča dogodke prek webhookov | — |

Polar je **blagajna in poštar**; licenco vodiš ti.

⚠️ **Popravek (2026-07-22): License Keys prihranijo manj, kot je izgledalo.** Lastno generiranje kod potrebuješ **tako ali tako** (§6.6: Play pregled, grandfathering, darila). Natančna razlika:

| Kos | Rabiš pri obeh ponudnikih | Prihrani Polar |
|---|---|---|
| Webhook sprejemnik, tabela `license`, `plus_until` | ✅ nujno | — |
| Generiranje kode (~20 vrstic), atomarna unovčitev | ✅ že rabiš za darila | — |
| **Pošiljanje kode kupcu po e-pošti** | ❌ | ✅ |
| **»Izgubil sem kodo« samopostrežno** | ❌ | ✅ |
| Omejitev naprav (`activate`), preklic ob vračilu | ❌ | ✅ |

Ostaneta torej **transakcijska e-pošta** (Resend ipd., brezplačna raven pokrije obseg) in **stran za ponovno pridobitev kode** — skupaj ~dan dela plus trajna skrb za dostavljivost v treh jezikih. Nezanemarljivo, a **ni odločilen argument** za izbiro ponudnika.

⚠️ **Organization access token nikoli ne sme v aplikacijo** — klici proti Polarju gredo izključno iz Edge Function; iz APK-ja bi ga kdorkoli izluščil.
⚠️ **Zrcali licence v svojo bazo** prek webhookov — Polar je mlado podjetje; ob menjavi ponudnika imaš podatke pri sebi.

### 5.3 Zakaj koda in ne e-pošta

Uporabnik ima v Tendask lahko **anonimen** ali **Google** račun z drugim naslovom, kot ga vpiše ob nakupu. Ujemanje po e-pošti bi od prvega dne generiralo podporne zahtevke. Koda deluje ne glede na to + omogoča darila in kupone.

**Pravilo: unovčitev zahteva prijavljen račun (Google/OTP), ne anonimnega.** Sicer uporabnik ob menjavi telefona izgubi plačano licenco in tega ne moreš rešiti.

### 5.4 Tok

**Ključna delitev:** *koda pove **kdo si**, webhook pove **do kdaj velja**.* Koda sama ne more vedeti, da je bilo plačano še eno leto — zato sta potrebna oba.

**Nakup (letno):**

1. Kupec na `tendask.com/plus` → Polarjeva blagajna (nakup nikoli ne teče čez tvoj strežnik).
2. Polar ustvari kodo in jo pošlje po e-pošti.
3. **Webhook → Edge Function:** »prodano, koda `X`, naročnina `sub_abc`, plačano do 20. 7. 2027.«
4. Edge Function zapiše vrstico v `license`. → **Koda obstaja v tvoji bazi, še preden jo kdo vnese.**
5. Kupec vnese kodo v aplikaciji → RPC preveri (obstaja? neunovčena? nepreklicana?) → veže na `auth.uid()`.
6. Strežnik izda podpisan token → pull sync → drift → Plus deluje offline.

**Podaljšanje (leto kasneje):** Polar sam bremeni kartico → webhook »`sub_abc` podaljšana do 2028« → Edge Function najde vrstico po `provider_ref` in prestavi `plus_until`. **Uporabnik ne naredi nič, kode ne dobi nove.**

**Doživljenjsko:** enako kot 1–6, `plus_until` daleč v prihodnost, podaljšanja ni.

**Odpoved:** ne narediš nič — `plus_until` poteče sam. **Vračilo/chargeback:** `plus_until = now()`, `revoked_at = now()`.

⚠️ **V Polarju NE nastavljaj poteka (TTL) na sami kodi.** Sicer imaš dve uri — Polarjevo in svojo — in ko se razideta, ima uporabnik veljavno naročnino in mrtvo kodo. **`plus_until` v tvoji bazi je edina resnica.**

**Poveži tudi kupca, ne le kode:** ob prvi unovčitvi shrani `profile.polar_customer_id`. Tako vsi kasnejši dogodki (obnovitev, ponovna naročnina po prekinitvi, sprememba paketa) najdejo uporabnika **brez nove kode**.

### 5.5 Offline ≠ nikoli online (razrešitev navideznega nasprotja)

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

### 5.6 Kaj se preverja kje

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

### 6.0 Kaj prevzame Polar in kaj ostane tvoje

Z uporabo Polarjevih License Keys se spodnje točke **skrčijo**: kode generira in dostavlja Polar (6.1 velja le še za lastne kode iz §6.7), omejitev naprav pokrije Polarjev `activate` z activation limit (6.4), preklic ob vračilu je Polarjev (6.3). **Nezmanjšano tvoje ostane 6.2 (podpisan token)** — Polar ne ve nič o vrtu brez signala.

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
| `subscription.created` / `renewed` | `plus_until = max(now, plus_until) + obdobje + kLicenseGraceDays` |
| `order.paid` (doživljenjsko) | `plus_until` daleč v prihodnost (token kljub temu omejen na 12 mes., §6.2) |
| `subscription.canceled` | pusti do `period_end` (plačal je) |
| `refund` / `chargeback` | `plus_until = now()`, `revoked_at = now()` |
| ročni preklic (zloraba) | `revoked_at = now()` |

> **Invarianta (obvezna): nakupni dogodki `plus_until` samo PODALJŠAJO — `max(now, obstoječi)`. Skrajšajo ga lahko izključno preklic, vračilo in chargeback.**
>
> Webhooki prihajajo **izven vrstnega reda**, zato brez tega pravila podvojen ali zamujen dogodek uporabniku odreže veljavnost. Hkrati to reši tri stvari zastonj: nadgradnjo iz letne v doživljenjsko, dvojni nakup, in nakup pred iztekom (kdor kupi 10 dni prej, ne izgubi teh 10 dni).

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

### 6.6 Lastne kode: darila, promocije, Play pregled, grandfathering

Polar pokriva **prodajo**. Za tri primere pa potrebuješ **lastne kode**, ki jih Polar ne more izdati:

1. **Testni račun/koda za Googlov pregled** — obvezno (§8), sicer pregled pade.
2. **Grandfathering** obstoječih uporabnikov koledarja (§10.4).
3. **Darila, promocije, novinarji, povračilo za prijavljen hrošč.**

Trije konkretni klicalci → po pravilu projekta (»≥3 klicalci«) to ni prezgodnja abstrakcija.

**Razlika v uri:** Polarjeve licence tečejo **od nakupa** (Polar meri TTL od nakupa, ne od aktivacije), lastne kode pa **od unovčitve**:

```
plus_until = redeemed_at + duration_days
```

To je edini pošten model za darilo, ki ga nekdo prejme decembra in unovči marca. Za naročnino bi bilo napačno — plačilo teče od nakupa, torej mora tudi upravičenost.

#### Podaritev licence — tri poti

**A. Lastna `granted` koda (priporočeno).** Vrstica v `license` (`kind='granted'`, `duration_days=365`), kodo izročiš kakorkoli (e-pošta, listek, ustno).
- **0 € stroška**, brez transakcije, provizije, DDV in računa
- prejemnik **ne rabi kartice** ne računa pri ponudniku
- deluje **identično pri Polarju in Paddlu**, ker ju sploh ne vključuje
- teče **od unovčitve** → darilo, dano decembra in unovčeno marca, ni okrnjeno

**B. 100 % kupon pri ponudniku.** Oba znata (Polar: enkrat / N mesecev / **za vedno**; Paddle: število obdobij, `null` = za vedno).
- ⚠️ **Past:** pri naročnini mora biti popust **»za vedno«**, sicer po prvem obdobju začne bremeniti kartico — ki jo je obdarjeni moral vnesti.
- Prednost: prejemnik dobi cel samopostrežni obred (ključ, e-pošta, portal). Slabost: mora skozi blagajno in pustiti podatke — za darilo starejšemu vrtnarju slabše od kode na listku.

**C. Ročno v bazi.** `plus_until` naravnost na profil znanega uporabnika. Najhitreje, a **ni prenosljivo** — deluje le, če oseba že ima račun in veš, kateri je. Za testerja da, za darilo ne.

#### `kind = 'review'` — koda za Googlov pregled

**Enkratna koda tu ne deluje:** recenzent jo porabi in ob **naslednji izdaji je mrtva** — vsak nov `versionCode` gre skozi pregled, torej bi moral vsakič izdati novo kodo in popraviti `App access`. Prej ali slej pozabiš in izdaja pade.

Zato posebna vrsta z drugačnim režimom:

| Lastnost | Vrednost | Zakaj |
|---|---|---|
| Večkratna unovčitev | **da**, s kapico (~20) | preživi več izdaj brez posega |
| Kaj podeli | **30 dni**, ne leto | ob uhajanju je škoda omejena |
| Preklic | takojšen (`revoked_at`) | zapreš v sekundi |
| Dnevnik | vsaka unovčitev (`uid`, čas) | zlorabo vidiš, ne ugibaš |
| Rotacija | ob večji izdaji / četrtletno | omeji življenjsko dobo |

Bistvo: ne šteješ, kolikokrat je bila uporabljena **za vedno**, ampak **koliko časa vsaka unovčitev velja**.

**Najmočnejši in najcenejši ukrep: kodo vklopi ob oddaji izdaje in prekliči po odobritvi.** Oddajaš nekajkrat letno → koda je živa nekaj dni na leto. Dve vrstici v deploy obredu zapreta skoraj celotno okno zlorabe.

Nevarnost je sicer manjša, kot se zdi: navodila iz `App access` **niso javna** (vidijo jih recenzenti in uporabniki tvojega Play Console računa) — ni v opisu, ne na posnetkih, ne v APK-ju. Cilj ni »zagotoviti, da jo uporabi samo recenzent« (to ni dosegljivo pri nobeni kodi), ampak da **tudi če uide, ni vredna dosti**.

⚠️ **Odprto:** ali sme `review` koda mimo zahteve po prijavljenem računu (§5.3). Recenzent bi se sicer moral prijaviti z Google/OTP, kar doda korak, na katerem pregled lahko zatakne; izjema pa doda poseben primer v kodo.

### 6.7 Poštena luknja (zavestno sprejeta)

Kdor unovči kodo, gre za vedno offline **in** premakne uro nazaj, obdrži Plus. Obramba (Play Integrity, zaznava root-a, obvezno online preverjanje) bi zlomila prav tisto, zaradi česar aplikacija obstaja.

---

## 7. Shema (skica)

```
profile
  + plus_until         timestamptz null   -- additive, nullable (stari APK-ji!)
  + plus_token         text null          -- podpisan JWT
  + plus_kind          text null          -- annual|lifetime|gift|granted — SAMO ZA PRIKAZ
  + polar_customer_id  text null          -- da kasnejši dogodki najdejo uporabnika brez nove kode

license
  id uuid pk, code text unique, kind text,            -- annual|lifetime|gift|granted
  plus_until timestamptz null,                        -- Polar: iz webhooka
  duration_days int null,                             -- lastne kode: plus_until = redeemed_at + to
  redeemed_by uuid null → auth.users, redeemed_at timestamptz null,
  revoked_at timestamptz null, provider text, provider_ref text,  -- provider_ref = Polar sub_/order id
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
- **`plus_kind` je izključno za prikaz.** Upravičenost se bere **samo** iz `plus_until`, nikoli iz tipa — sicer dobiš dve resnici. Namen: `plus_until = 2099` na zaslonu izgleda kot napaka, zato »Doživljenjska« proti »Letna, velja do 12. 3. 2027« (FR-19 §11.3 hoče prikaz veljavnosti).

---

## 8. Posledice v Play Console

⚠️ **Najbolj spregledana točka.**

1. **`App access` se mora spremeniti z »Ne« na »Da«.** Zdaj je pravilno nastavljeno (nič ni gate-ano); ob vklopu Plus je napačno in tvegaš zavrnitev. Uporabi **`review` kodo** (§6.6), ne osebnega računa — Tendask ima le Google/OTP prijavo, zato deljen testni račun ni izvedljiv. Navodila naj bodo dobesedna:

   > 1. Odpri aplikacijo, dokončaj uvod.
   > 2. Domov → ⚙️ → Tendask + → »Vnesi kodo«.
   > 3. Vnesi: `XXXX-XXXX-XXXX`.
   > 4. Odklenejo se: lunin koledar, planer, …

   *Drobnarija:* **pre-launch report je avtomatiziran in kode ne bo vnašal** — Plus zaslonov ne bo preizkusil. Ni težava, le od tam ne pričakuj pokritja.
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
   - **Prelomna točka: 7 mesecev.** Mesečna prehiti letno šele, če povprečen naročnik vztraja ≥7 mesecev (7,20 ÷ 1,05 = 6,9). Pri sezonski dejavnosti in slovenski zimi je to malo verjetno, a **ni izmerjeno** — je ocena, ne podatek. *(Po Startup tarifi 3,40 % + 0,30 $ bi bila prelomna točka ~6 mesecev; odločitve ne spremeni, ker glavni argument ni ta številka, ampak spodnji strukturni.)*
   - Odločilnejši, ker ne temelji na ugibanju: **pri letni ceni ~9,90 € mesečna tarifa ne more obstati.** Sorazmerna mesečna bi bila ~1,00–1,20 € (pod pragom fiksne provizije); pri 1,99 € pa je letna le 5 mesečnih → vsi vzamejo letno in mesečna je mrtva izbira, ki le zapleta podporo in knjiženje.
   - **Trenje ubija prednost mesečne.** Ker v aplikaciji ni povezave do nakupa, mora kupec sam najti stran, plačati in prekopirati kodo. Nizka vstopna cena tu ne kupi obsega — le manj denarja od istih ljudi.
   - **Sidro za ceno:** tiskane *Lunine bukve 2026 s setvenim koledarjem* stanejo **9,90 € + poštnina** — isti kupec, isti namen, vsakoletni nakup. Primerljive aplikacije: Planta/Vera enkratno ~10 $, vrtnarske aplikacije ~4–50 $/leto.
   - **Razmislek o razmerju:** doživljenjska se običajno postavi na 2,5–3× letne. Ne kanibalizira letne, ker načelni nasprotniki naročnin sicer ne kupijo ničesar.
   - **Vezano na obseg paketa (§10.2):** M11 ima ponavljajoč se strošek → če je v paketu, govori proti neomejeni doživljenjski (ali za njeno omejitev na lansirno ponudbo).
   - **Vmesna možnost, če bo potreba:** sezonska licenca 6 mesecev (ena transakcija, ujame sezonsko vedenje brez upravljanja odpovedi).
3. **Polar ali Paddle?** **Priporočilo = Polar** (§4.3), a ni potrjeno. Pred potrditvijo preveri dvoje: (a) ali Stripe Express onboarding za s.p. steče, (b) ali Polar pošilja **opomnik pred obnovitvijo** (§5.1) — če ne, ga moraš pošiljati sam ali izbrati Paddle.
4. **Nova dependency za preverjanje podpisa** — kateri paket, in posodobitev `tech-stack.md §1`.
5. **`kLicenseGraceDays`** — 7 ali 14?
6. **Število sedežev** — 3 ali več?
7. **Trial?** (npr. 14 dni Plus ob prvi prijavi) — poveča konverzijo, a doda stanje.
8. **Kdaj?** Ni launch-gating; aplikacija je v produkciji in free.

---

## 12. Predlagan vrstni red 1. iteracije

1. Odloči funkcije + ceno + ponudnika (§11.1–3).
2. Uskladi `tech-stack.md §1` z novo dependency za podpis.
3. **Polar:** dva izdelka (letno = naročnina, doživljenjsko = enkratno), oba z License Key benefit, **brez TTL na ključu**; webhook → Supabase Edge Function; RPC `redeem_license`; migracija (additive + granti).
4. **Spletna stran** (`../tendask_web/`, po §4.5): `/plus` v treh jezikih + nav postavka + sekcija na landingu + footer povezavi + popravek `t.hero.free` + pogoji in politika vračil.
5. Aplikacija: `plusProvider` (bere iz drifta, preverja podpis prek `Clock`) + zaslon Tendask+ — **UI po FR-19 §11.3–11.4**, ne izmišljuj novega.
6. i18n (en/sl/de) — **pregled vseh nizov glede anti-steering** pred oddajo (§3.1).
7. Play Console: `App access` na »Da« + `review` koda in dobesedna navodila (§8).
8. **DoD — vse v sandbox ↔ staging (§4.4), preden gre karkoli na prod:**
   - nakup letne → koda po e-pošti → webhook → vrstica v `license`
   - unovčitev v aplikaciji → **letalski način → Plus dela** (offline token)
   - **pot podaljšanja** prek kratkega testnega izdelka ali ročno sproženega webhooka — *edini del, ki se sicer prvič zgodi šele čez leto dni*
   - **vračilo/preklic** → `plus_until` se skrajša (edina pot, ki krajša)
   - doživljenjska → token **ni** 2099, ampak `now + 12 mesecev` (§6.2)
   - predelana drift vrstica → Plus ugasne
   - `review` koda: druga unovčitev uspe, po preklicu ne

**Vrstni red glede na FR-19:** Lunin koledar se gradi **najprej v celoti free** (FR-19 §11.2: »etapno — najprej vse free«). Ta FR se aktivira šele, ko je funkcija zrela in ima uporabnike; gating je zadnji korak, ne prvi.

---

*Odločeno 2026-07-22 v pogovoru. Naslednji korak ni tehničen: §11.2 (konkretne cene) in §11.3 (Polar ali Paddle) — brez njiju infrastrukture ni smiselno graditi.*
