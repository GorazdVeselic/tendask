# FR-22: Kontekstualni poziv za lokacijo na Domov

- **Status:** predlog, neimplementirano
- **Datum:** 2026-07-28
- **Cilj:** povečati delež uporabnikov z nastavljeno lokacijo vrta (`profile.h3_r5`)
- **Področja:** Domov (vremenska kartica), onboarding (zaslon 16), vreme, pametni motor
- **Povezave:** `docs/analitika-geo.md` (od kod številke), `docs/wireframes/` 16,
  `lib/features/home/presentation/widgets/home_weather_section.dart`,
  `lib/features/auth/presentation/location_screen.dart`

---

## 1. Problem

**55 % uporabnikov nima nastavljene lokacije vrta** (44 od 80 profilov, PROD, 28. 7. 2026).

Kar to *ni*: niso mrtvi profili in ni tehnična napaka. Vseh 44 ima
`default_garden_seeded = true` in vsaj eno območje — onboarding je pri vseh tekel do
konca, 13 jih je že opravilo kakšno opravilo. Nobeden nima nobene od treh H3
resolucij, torej ni delnega zapisa; lokacija preprosto nikoli ni bila nastavljena.

Časovnica pove, kaj se je zgodilo:

| Obdobje | Profilov | Brez lokacije |
|---|---|---|
| junij (zaprta beta) | 23 | **4 %** |
| od Play izdaje 20. 7. | 55 | **75 %** |
| zadnjih 7 dni (22.–28. 7.) | 8 | **100 %** |

Beta testerji so bili vodeni in motivirani. Pravi uporabniki preskočijo — in
preskok je najlažja poteza na zaslonu, ker je `location_screen.dart:276`:

```dart
FilledButton(onPressed: () => context.go('/home'), child: Text(t.location.kContinue))
```

Edini gumb na dnu je **primarni** in brezpogojno pelje naprej; nastavitev lokacije
zahteva tipkanje v kartico sredi zaslona. Kdor enkrat tapne, ni nikoli več pozvan —
do zaslona vodita samo onboarding in Nastavitve → Lokacija.

### Zakaj to ni le vrzel v statistiki

`gardenLocation` (`location_repository.dart:226`) ob manjkajoči celici vrne
`kDefaultLatitude/kDefaultLongitude` = **Ljubljana**. Posledice, po resnosti:

1. **Aplikacija tiho kaže napačno vreme.** Uporabnik v Murski Soboti dobi ljubljansko
   napoved, predstavljeno kot vreme svojega vrta — brez oznake kraja, brez opozorila.
   Na tej podlagi se odloča, ali bo zalival.
2. **Pametni motor računa na napačni lokaciji** — sezona, slana, dež so lokalni.
   Predlog »zalij« za 55 % uporabnikov izhaja iz tujega vremena.
3. **Okolica (skupnost) je zanje strukturno prazna** — kohorta se veže na H3 celico.
4. Šele nato: agregatna slika trga je pristranska (`docs/analitika-geo.md`).

Točka 1 pomeni, da je to **popravek poštenosti**, ne rastna taktika. Poziv, ki ga
predlagava, je posledica: če kartica pove resnico, je ponudba nastavitve naravna.

## 2. Cilj in merila

**Cilj:** uporabnik ve, ali vreme velja za njegov vrt, in ima ponudbo nastavitve
tam, kjer mu manjka — ne v onboardingu, kjer še ne ve, čemu služi.

| Metrika | Izhodišče (28. 7.) | Cilj |
|---|---|---|
| **Primarna:** delež novih profilov z `h3_r5` | 25 % (14 od 55, kohorta 20.–28. 7.) | ≥ 60 % v 30 dneh po izdaji |
| **Sekundarna:** delež obstoječih 44, ki lokacijo nastavi | — | ≥ 30 % v 30 dneh |
| **Varovalo:** delež profilov, ki lokacijo *počisti* (`clearGardenLocation`) | ~0 | ostane ~0 |
| **Varovalo:** aktivnost (profili z ≥1 opravilom v 7 dneh) | izmeri ob izdaji | ne pade |

Merjenje ne potrebuje novega instrumentiranja — FR-14 (analitika) ni pogoj.
Kohortna poizvedba po dnevu registracije je že v `tool/geo_user_map.py` oz.
`docs/analitika-geo.md`; pred izdajo zamrzni izhodišče, po 30 dneh ponovi.

**Cilj ni 100 %.** Kdor lokacije noče dati, je to legitimno; naloga je, da ve, kaj s
tem izgubi, in da ga stanje ne zavaja.

## 3. Rešitev

Vremenska kartica na Domov dobi **tretje stanje**: »vreme ni s tvoje lokacije«.

| Stanje | Danes | Predlog |
|---|---|---|
| lokacija nastavljena | vreme + ime kraja | nespremenjeno |
| **ni lokacije** | **vreme za Ljubljano, brez oznake** | vreme + miren pas: to ni tvoja lokacija + CTA »Nastavi kraj« |
| offline brez posnetka | tiha »ni na voljo« kartica | nespremenjeno |

Načela:
- **Ne modalno, ne push, ne blokira.** Kartica je del zaslona, ne prekine poti.
- **Miren ton, ne alarm.** Ni rdeče, ni klicaja — to ni napaka uporabnika.
- **Ena poteza do rešitve:** CTA pelje na obstoječi `/location` (push, z back).
- **Ne izginja in se ne vrača.** Dokler lokacije ni, je pas viden; ni odštevanja,
  ni »ne prikaži več« (glej §5 — kdor noče, pusti pas pri miru).

### Predlog besedila

| Ključ | sl | en | de |
|---|---|---|---|
| `home.weather.no_location.note` | Vreme za Ljubljano — tvojega kraja še ne poznamo. | Weather for Ljubljana — we don't know your place yet. | Wetter für Ljubljana — deinen Ort kennen wir noch nicht. |
| `home.weather.no_location.cta` | Nastavi kraj | Set your place | Ort festlegen |

Nemški prevod je predlog za pregled ob implementaciji (slang, `dart run slang`).
Besedilo namenoma imenuje **Ljubljano** — konkretno ime pove, da vreme ni od nikoder,
ampak od nekod drugod, in to je tisto, kar sproži popravek.

## 4. Obseg

**V obsegu:** tretje stanje vremenske kartice na Domov + i18n ključi + testi.

**Izven obsega** (ločene odločitve, ne pogoj za to):
- Obrat hierarhije gumbov na zaslonu 16. Najmanjši poseg z največjim učinkom na *nove*
  uporabnike; vreden svojega FR-ja, ker se dotakne onboardinga. → **Zdaj
  [FR-24](onboarding-location-cta.md)** (2026-07-29). Izvedba ni `TextButton`, kot je
  slutila ta alineja, ampak poudarjena GPS kartica + nepoudarjen gumb za preskok.
  **Ne izdaj v isti izdaji kot ta FR** — oba premikata isto metriko.
- Poziv ob prvi rastlini/zalivanju.
- Sprememba privzetka iz Ljubljane v »brez vremena« (glej §7).

## 5. Vedenje in robni primeri

- **Gost** (`kLocalUserId`): deluje enako — celica se piše lokalno, brez računa.
- **Offline:** vnos kraja potrebuje geocoding (mreža), GPS ne. Zaslon 16 to že
  obravnava; pas na Domov naj ob odsotnosti mreže ostane, CTA pa vodi na isti zaslon,
  ki napako pokaže sam. Ne dupliciraj obravnave napak.
- **Takoj po nastavitvi** pas izgine brez osvežitve — `gardenCell` je `Stream`,
  kartica ga gleda (`ref.watch`), prehod je reaktiven.
- **Po `clearGardenLocation`** se pas vrne. To je pravilno in ni nadlegovanje:
  uporabnik je pravkar sam izbral stanje »brez lokacije«.
- **Samo Domov.** Ne dodajaj istega pasu v Okolico, nastavitve ali seznam opravil —
  en poziv na eno mesto.
- **Layout:** dolga nemščina + text-scale 1.3 → pas mora ovijati, ne rezati.
  Dodaj vnos v `test/layout/` matriko.

## 6. Implementacijske opombe

- `HomeWeatherSection` naj gleda **`gardenCellProvider`** (`Stream<String?>`), ne
  `gardenLocationProvider` — slednji privzetka in resnične lokacije ne loči.
- Pas je del `CurrentWeatherCard` (nov opcijski `footer`/`onSetLocation`), ne nov
  widget nad njo — sicer imamo dve kartici, kjer je bila ena.
- CTA: `context.push('/location')`. Zaslon že zna »iz nastavitev« način
  (`fromSettings = context.canPop()`) — z `push` dobi back puščico in nima gumba
  »Nadaljuj«. **Nič novega v routerju.**
- Brez nove dependency, brez migracije, brez spremembe sheme.

## 7. Odprta vprašanja

1. **Ali Ljubljano sploh obdržati kot privzetek?** Alternativa: brez lokacije ni
   vremenske kartice, ampak samo povabilo. Bolj pošteno, a Domov izgubi vsebino pri
   prvem odprtju. Predlog: obdrži privzetek + pas (ta FR), ker ne odvzema ničesar.
2. **Ali isto povedati v Okolici**, ko se prižge? Tam brez celice ni kohorte, torej
   ni vsebine — a to je drug zaslon in druga odločitev.
3. **Ali obstoječih 44 doseči tudi drugače** (enkraten in-app poziv ob nadgradnji)?
   Zaenkrat ne — pas jih doseže ob prvem odprtju Domov, kar je dovolj.
