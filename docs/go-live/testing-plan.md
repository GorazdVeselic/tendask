# Tendask — Plan testiranja (interni → zaprti → produkcija)

> Google Play ima tri stopnje testiranja pred produkcijo. Za **osebne** račune (kar je naš) velja
> dodatna zahteva pred produkcijo: **zaprti test z ≥12 testerji, ki ostanejo prijavljeni 14 dni.**

## Pregled stopenj

| Stopnja | Kdaj | Testerji | Pregled Googla | Naša raba |
|---|---|---|---|---|
| **Internal testing** | takoj | do 100 (email) | ni / takoj | **9.5 — prva namestitev, smoke test** |
| **Closed testing** | pred produkcijo | ≥12 (zahteva) | da (krajši) | **odpre dostop do produkcije (osebni račun)** |
| **Open testing** | opcijsko | javno | da | preskočimo (ni nujno) |
| **Production** | javna objava | vsi | da (polni) | po 14-dnevnem zaprtem testu |

---

## 1. Interni test (zdaj, po odobritvi identitete)

1. Play Console → **Testing → Internal testing → Testers** → dodaj emaile (ali Google Group).
   Vključi vsaj `exogenus@gmail.com` + svoj testni Gmail.
2. **Copy link** (opt-in URL) → odpri na napravi → **Become a tester** → namesti iz Play.
3. Namen: potrditi, da se Play-distribuirani build namesti in dela (glej `README.md` Faza 6 —
   Google login, email OTP, GDPR izvoz/izbris).

---

## 2. Zaprti test (predpogoj za produkcijo — osebni račun)

**Zahteva:** vsaj **12 testerjev** mora biti **prijavljenih (opted-in) neprekinjeno 14 dni**, da se
odklene »Apply for production access«.

- [ ] 👤 Ustvari **Closed testing** track (ali uporabi obstoječi »Alpha«).
- [ ] 👤 Naredi **Google Group** (npr. `tendask-testers@googlegroups.com`) — lažje upravljanje kot
  ročni seznam emailov; dodaj jo kot testersko skupino.
- [ ] 👤 Zberi **≥12 ljudi** (priporočam 14–15 za rezervo, če kdo odpade): družina, prijatelji,
  vrtnarski znanci, FB vrtnarske skupine.
- [ ] 👤 Pošlji jim opt-in link + navodila (predloga spodaj). **Vsak se mora dejansko prijaviti**
  (postati tester) — šteje opt-in, ne le email na seznamu.
- [ ] 👤 **14-dnevna ura teče**, dokler je ≥12 prijavljenih. Spremljaj v Play Console.
- [ ] 👤 Po 14 dneh → **Apply for production access**.

> Nasvet: testerji ne rabijo aktivno uporabljati app-a vsak dan; ključno je, da **ostanejo
> prijavljeni** (ne odjavijo se iz testa) celih 14 dni. Razloži jim to.

---

## 3. Predloga sporočila testerjem (SL)

```
Pozdravljen-a!

Testiram svojo novo Android aplikacijo Tendask — preprost dnevnik za vrt
(opravila, vreme, opomniki). Bi mi pomagal-a kot tester?

Potrebujem le, da:
1) odpreš ta povezavo na Android telefonu: <OPT-IN LINK>
2) klikneš »Become a tester« in namestiš Tendask iz trgovine Play,
3) ostaneš prijavljen-a v test vsaj 14 dni (ni treba uporabljati vsak dan).

Hvala! Vesel-a bom vsakega vtisa ali napake, ki jo opaziš.
```

## Predloga (EN)

```
Hi!

I'm testing my new Android app Tendask — a simple garden journal
(tasks, weather, reminders). Would you help as a tester?

All I need is for you to:
1) open this link on an Android phone: <OPT-IN LINK>
2) tap "Become a tester" and install Tendask from the Play Store,
3) stay opted in for at least 14 days (no need to use it daily).

Thank you! Any impressions or bugs you spot are very welcome.
```

> Opomba: APK/AAB je isti kot za interni test; ko gradiš nov build za track, **dvigni
> `versionCode`** (`pubspec: 1.0.0+2`, …) — vsak Play upload mora imeti višjega.
