# Poglavje 0 — Razlaga za laika: kako vse skupaj deluje

> Brez tehničnih izrazov. Vse spodaj je pripoved; točne tehnične definicije so v poglavjih 1–8.

## 0.1 Od posajenega paradižnika do obvestila »čas za pikiranje«

Predstavljaj si Majo, ki ima na okenski polici lonček s semeni paradižnika.

**1. korak — Maja pove aplikaciji, kaj je naredila.** Desetega marca v Tendask vnese opravilo:
»Predsetev · paradižnik · opravljeno«. To je vse, kar mora narediti — isti vnos, kot ga dela že
zdaj za vsako drugo opravilo. Aplikacija si zapomni: *ta uporabnica ima paradižnik in ga je
10. marca posejala v hiši*. Zapis se shrani najprej v telefon (zato dela tudi sredi vrta brez
signala), ob prvi priložnosti pa se tiho prepiše še v oblak.

**2. korak — v oblaku obstaja »jutranji vrtnar«.** Vsako jutro okoli sedme ure se v oblaku za
vsakega uporabnika zbudi majhen avtomat — predstavljaj si ga kot izkušenega vrtnarja, ki ima
pred sabo tri stvari: (a) Majin vrtni dnevnik (kaj ima in kaj je kdaj naredila), (b) vremensko
napoved za njeno okolico in (c) knjigo kuriranih vrtnarskih pravil (»paradižnik se pikira
2–3 tedne po setvi, ko ima prve prave liste«).

**3. korak — avtomat lista po knjigi pravil.** Za Majin paradižnik najde pravilo: *po opravljeni
predsetvi sledi pikiranje, tipično 14–21 dni kasneje*. Pogleda v dnevnik: setev je bila
10. marca, danes je 26. marca — 16 dni, smo v oknu. Preveri še straže: Maja pikiranja še ni
vnesla, ni si ga že sama načrtovala, ni nedavno rekla »ne teži mi s tem«. Vse čisto → nastane
**predlog**: »Pred ~2 tednoma si sejala paradižnik — verjetno je čas za pikiranje.«

**4. korak — predlog pride do Maje po dveh poteh.** Na telefon prileti potisno obvestilo (kot
SMS od aplikacije), hkrati pa se predlog pojavi kot **pas na vrhu domačega zaslona** z dvema
gumboma: **Načrtuj** in **Opusti**. Obvestilo je samo zvonec; dom predloga je domači zaslon.

**5. korak — krog se sklene.** Če Maja pikiranje opravi in vnese, avtomat naslednji korak verige
(utrjevanje, presaditev) računa od *tega* datuma. Sistem se torej prilagaja njenemu dejanskemu
tempu, ne fiksnemu koledarju.

## 0.2 Kdo »odloča«, kaj bo predlagano?

Nihče ne ugiba in nič se ne »uči« na skrivaj. Odločajo **vnaprej napisana, pregledna pravila**,
ki jih je kuriral človek in imajo vsako svoj vir (npr. priročnik kraljevske hortikulturne
zveze RHS). Vsako pravilo je stavek oblike: »ČE imaš X in je čas/vreme Y in NE velja nobena
izjema, POTEM predlagaj Z.«

Da avtomat ve, da ima Maja paradižnik, mu ni treba nič posebnega — Maja je rastlino dodala v
svoj vrt že ob normalni rabi aplikacije (»Vrt → Gredica → paradižnik«), datum setve pa je njen
običajen vnos opravila. Motor torej **ne zbira nič novega**; samo bere, kar v aplikaciji že
nastaja.

Če pravil za neko rastlino ni (ali ni zanesljivega vira), avtomat raje molči. Manj predlogov je
boljše od napačnega.

## 0.3 Kako motor ve, kdaj je »čas«? Sezonska okna in pozeba kot sidro

Težava: »obrezuj jablano februarja« drži v Ljubljani, ne pa v Helsinkih. Namesto da bi vzdrževali
poseben koledar za vsako regijo, uporabimo dva trika:

- **Sezonsko okno** je obdobje v letu (npr. »tedni 6–11«), ko je opravilo tipično smiselno —
  ampak okno ni pribito na državo, temveč na **klimatski koš**: grobo oznako tipa »nižina,
  zmerno topla klima«, ki jo aplikacija izračuna iz dolgoletnih vremenskih povprečij za
  uporabnikovo okolico.
- **Pozeba kot sidro (frost-anchor):** za marsikaj je edino pomembno vprašanje »kdaj pri tebi
  tipično mine zadnja spomladanska pozeba«. Iz arhiva vremena za uporabnikovo okolico aplikacija
  izračuna: »pri tebi je zadnja pozeba tipično okoli 20. aprila«. Pravilo »sej paradižnik v hiši
  6–8 tednov PRED zadnjo pozebo« se potem **samo od sebe** pravilno premakne za vsak kraj na
  svetu — en zapis pravila, vse regije.

Pomembno: vse to so **opisna okna** (»tipičen čas v tvoji okolici«), ne ukazi. Aplikacija nikoli
ne trdi, da nekaj »moraš« — pove, da je zdaj obdobje, ko to delajo drugi in stroka.

## 0.4 Kako »68 % v okolici gnoji«? Kdo šteje in kako ostane zasebno?

Vsako opravljeno opravilo registriranega uporabnika nosi nevidno »poštno številko« — ne naslova!
To je šestkotna celica na zemljevidu (nekaj km široka), v katero spada njegov vrt, plus groba
klimatska oznaka. Telefon nikoli ne pošlje točnih koordinat; celico izračuna sam in pošlje samo njo.

Vsako noč v oblaku steče **štetje**: »v celici X je ta teden trato gnojilo 12 različnih ljudi«.
Šteje se **ljudi, ne opravil** (nekdo, ki gnoji petkrat, je še vedno en človek). Iz štetij
preteklih let se sestavi krivulja »do katerega tedna je tipično začelo X % ljudi« — in ko Maja
pogleda, ji aplikacija pove: »do zdaj je trato pognojilo ~68 % vrtnarjev v tvoji okolici.«

Zasebnost varujeta dve zavori:
- **Prag zasebnosti (5):** če je v celici manj kot 5 različnih ljudi, se številka sploh ne pokaže
  (pokaže se »še premalo vrtnarjev v okolici«). Nikoli ni mogoče razbrati posameznika.
- **Prag zanesljivosti (30):** odstotek se pokaže šele, ko šteje vsaj 30 ljudi; pod tem se pokaže
  le opisno (»zgodaj / običajno / pozno«), da majhen vzorec ne laže.

Če je v ožji okolici premalo ljudi, sistem pogleda širšo celico, nato podobno klimo, nazadnje vse
uporabnike — vedno pa pošteno pove, kateri obseg gleda (»v tvoji okolici« / »v podobni klimi« /
»med vsemi vrtnarji«).

## 0.5 Kaj se zgodi ob »Opusti« in ob »Načrtuj«?

**Načrtuj:** odpre **obrazec za novo opravilo, že izpolnjen** s tipom, rastlino in *predlaganim*
datumom — odprt na koraku »Kdaj«, da Maja potrdi/popravi datum in po želji doda opomnik, nato
shrani. (Spremenjeno 2026-06-15 iz prvotnega »en dotik«: uporabnik je opozoril, da takojšnja
tiha izdelava opravila brez izbire termina ni dober UX.) Šele **shranjeno** opravilo označi predlog
kot »načrtovan« → pas izgine, opravilo živi v zavihku Opravila. Če Maja obrazec prekliče, predlog
ostane na pasu.
Motor si zapomni: »to je zdaj načrtovano« → istega ne predlaga več.

**Opusti:** pas izgine in motor si zapiše »tega predloga tej osebi ne kaži N dni« (N je odvisen
od vrste predloga: vremenski namig ~teden, sezonsko okno do konca okna). Opusti je torej legitimen
odgovor, ki sistem uči umirjenosti — ne kazni.

Pod **⋯** so še trije odgovori za primere, ko predlog ne zadene:
- **»✓ Že opravljeno«** — »jablano sem obrezal prejšnji teden, samo vnesel nisem.« En dotik
  ustvari vnos v dnevnik (z izbranim datumom) in predlog izgine; bonus: dnevnik in statistika
  sta spet točna.
- **»Ne predlagaj več tega«** — »jablane nikoli ne redčim in ne nameravam.« Ta predlog za to
  rastlino utihne za vedno (druga opravila iste rastline ostanejo).
- **»Te rastline nimam več«** — jablana je požagana: aplikacija jo (po potrditvi) odstrani iz
  vrta in s tem samodejno ugasnejo VSI prihodnji predlogi zanjo.

Poleg tega velja **frekvenčna kapica**: največ eno potisno obvestilo na dan (najboljši predlog);
ostali predlogi tiho čakajo na pasu na Domov. Potisna obvestila so privzeto **izklopljena**,
dokler jih uporabnik ne vklopi (ločeno za vremenske in skupnostne namige) — pas na Domov pa deluje
za vse.
