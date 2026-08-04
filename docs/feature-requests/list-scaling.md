# FR-27: Domov/Opravila/Dnevnik pri velikem številu vnosov

- **Status:** ideja / želja (ni spec ravni, neimplementirano)
- **Datum:** 2026-08-03
- **Področja:** `tasks_repository.dart`, `notes_repository.dart`, presentation (`home`, `tasks`, `journal`)
- **Povezave:** `docs/screen-map.md` §1.1–1.3 (Domov/Opravila/Dnevnik)
- **Izvor:** pogovor z lastnikom 3. 8. 2026 o obnašanju pri nekaj sto+ vnosih — **ni izmerjen problem**,
  proaktivno vprašanje (danes vsi trije zasloni `watch()`-ajo celo tabelo brez `limit()`).

---

## 1. Želja

Tri neodvisne postavke:

1. **Domov: časovno okno na DANES/NAZADNJE poizvedbah** — `-1 mesec / +7 dni` namesto neomejenega
   `watch()`. Domov je snapshot, ne arhiv (`screen-map.md:26-28`). **Rdeč pas »N zamujenih opravil«
   ostane nevezan na to okno** — ločena, neomejena `COUNT` poizvedba, ker je zamujeno opravilo izpred
   2 mesecev še vedno zamujeno.
2. **Opravila + Dnevnik: search + filter.** Debounced `LIKE '%term%'` (brez FTS5 — ni potreben pri
   stotinah vrstic) + pogojno `.where()` veriženje za filtre (tip, območje, datum) — vzorec, ki ga
   `tasks_repository` že uporablja drugje.
3. **Nice-to-have: infinite scroll / paginacija** za sezname, ki nimajo naravne časovne omejitve
   (npr. Opravila brez filtra, Dnevnik »vsi vnosi«). Dodaja state (offset/limit, `hasMore`,
   `isLoadingMore`), `ScrollController` listener, in mora ostati usklajen z reaktivnimi drift
   streami (nov sinhroniziran zapis med scrollanjem ne sme podreti pozicije).

## 2. Zakaj

Vsi trije zasloni danes streamajo celo tabelo (`notes_repository.dart:16-20` ipd.) in razvrstijo v
Dartu. Pri nekaj sto vrsticah SQLite + `ListView.builder` virtualizacija to prenese brez težav, a
brez okenčenja/filtra poizvedba raste linearno z vsemi vnosi v zgodovini uporabnika, ne s tem, kar
uporabnik dejansko vidi.

## 3. Odprta vprašanja (odloči lastnik, preden se karkoli piše)

- **Meje okna na Domov:** je `-1 mesec / +7 dni` pravo razmerje, ali naj bo drugačno (npr. NAZADNJE
  = zadnjih N opravil ne glede na datum)?
- **Search obseg:** samo naslov opravila/opombe, ali tudi ime rastline/območja (join)?
- **Infinite scroll prioriteta:** ostane nice-to-have dokler ni izmerjena počasnost, ali gre v isti
  korak kot search/filter zaradi deljenega provider stanja?

## 4. Obseg

Postavka 1 (Domov okno) je samostojna in poceni. Postavki 2 in 3 sta neodvisni med sabo — search/filter
ne potrebuje paginacije in obratno. **Merilo za paginacijo:** izmerjena počasnost pri seznamu brez
filtra (ne progresivno predvidevanje) — v skladu z »optimizacije morajo biti merljive« (CLAUDE.md).
