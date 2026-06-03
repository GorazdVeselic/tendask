# IA pregled — kje se zasloni prekrivajo + predlog poenostavitve

> Datum: 2026-06-02 · Status: predlog za odločitev (NE implementacija)
> Povod: občutek, da je iz preproste ideje nastalo preveč prekrivajočih se zaslonov.
> Cilj: ločiti, kaj je dejansko odveč, od tega, kar nosi svojo vrednost — preden vložimo
> čas v backend (M5+). **Koda ni vir zmede** (feature-first, repo/provider/UI je čist);
> zmeda je v informacijski arhitekturi (IA), ki jo je implementacija zvesto prevzela iz wireframov.

## 1. Trenutna IA (kaj imamo)

**Navigacija:** 4 zavihki + plavajoči ＋ (Hiter vnos).
`Domov (01) · Dnevnik (03) · Območja (04) · Opravila (06)`

| Skupina | Zasloni | Vloga |
|---|---|---|
| Domov | 01 | vreme (placeholder do M4) + danes + zadnje |
| Vnos opravila | 02 Hiter vnos, 07 Novo opravilo | dva obrazca za **isto** entiteto |
| Pregled opravil | 06 Opravila (todo), 03 Dnevnik (log+opombe), 11 Mesečni koledar | trije pogledi na isto entiteto |
| Detajl | 17 / 17b | bralni pogled opravila (čaka / opravljeno) |
| Opombe | 18 | samostojna opomba → v Dnevnik |
| Območja & rastline | 04 seznam, 05 detajl, 09 obrazec, 10 picker | CRUD vrta |
| Zaloge / Profil | 08 Zaloge, 12 Nastavitve | podporno |
| Obvestila (M8) | 19–22 | opomniki |
| Start (M7/M9) | 00 splash, 13 prijava, 15a–d onboarding, 16 lokacija | uvod |

## 2. Diagnoza — kje se dejansko prekriva

**A) Tri okna na isto entiteto (opravilo): Domov + Opravila + Dnevnik.**
- Domov = "danes + zadnje" → **danes** je tudi v Opravilih, **zadnje** je tudi v Dnevniku.
- Domov je s tem **agregator** drugih dveh; brez vremena (M4) nima lastne vsebine.
- Opravila (prihodnost/todo) vs Dnevnik (preteklost/log) **je** smiselna delitev — to obdržimo.
- **Šibki člen = Domov.**

**B) Dva vnosna obrazca: Hiter vnos (02) + Novo opravilo (07).**
- Odkar 02 "Več / Napredno" vodi v 07, je 02 **podmnožica** 07 (ista polja, podvojena logika).
- "Hiter vnos = 2–3 dotiki" je dobra ideja; ločen poln obrazec je morda nepotreben kot **svoj zaslon**.

**C) Časovnica (03) + Mesečni koledar (11).**
- Dva pogleda istega → **ni odveč** (kot vsak koledar: seznam ⇄ mesec). Obdržimo.

**Kar NI odveč:** Območja (CRUD), rastline (picker), zaloge, opombe, nastavitve, obvestila — vsak svoj koncept.

## 3. Predlog vitke IA

### 3.1 Navigacija — vloga Domov (glavna odločitev)
Dve smiselni poti:

- **Opcija A — 3 zavihki (najbolj vitko):** `Dnevnik · Opravila · Vrt(Območja)` + ＋.
  Domov **ukinemo**; "danes" živi v Opravilih (zgoraj), vreme (M4) postane pas na vrhu Dnevnika/Opravil.
  Najmanj zaslonov, najbolj jasno. Tvegano le, če želiš en "pristajalni" dashboard.

- **Opcija B — 4 zavihki, a Domov dobi pravo vlogo:** Domov = **"Danes"** (vreme M4 + današnja opravila +
  opozorila zalog/pametni namig V2). Opravila = čista todo lista (brez "danes" dvojenja), Dnevnik = zgodovina.
  Domov ima smisel **šele po M4** (vreme); do takrat je prazen.

### 3.2 Vnos — en obrazec namesto dveh
En **progresivni** obrazec opravila: privzeto zložen (kaj + kdaj + kje = hiter vnos),
sekcije "Več" (rastlina, sredstva, opomnik, status, ponavljanje) razprte na zahtevo (collapse/expand).
- Odpravi podvojeno logiko 02/07; "hiter" ostane hiter (zložen), "napredno" je isti zaslon razprt.
- Povezano z backlog **FR-1** (razširi/skrij) — isti vzorec progresivnega razkritja.

### 3.3 Obdržimo brez sprememb
Detajl (17/17b), Opombe (18), Območja+rastline, Zaloge, Nastavitve, Dnevnik (časovnica+mesec), Obvestila (M8).

## 4. Priporočilo

1. **Vnos → en progresivni obrazec** (jasna zmaga, odpravi pravo podvajanje; smiselno pred M4).
2. **Domov → odloži odločitev do M4:** šele z vremenom se vidi, ali je "Danes" dashboard vreden
   svojega zavihka (Opcija B) ali ne (Opcija A). Do takrat Domov pusti kot je (ne gradi nanj).
3. Vse ostalo obdržimo — ni vir zmede.

> Neto: iz "4 zavihka + 2 vnosa" → cilj "3–4 zavihki + **1** vnos". Glavni vir občutka prenatrpanosti
> sta dva (Domov-kot-agregator in dvojni vnos); oba sta rešljiva brez rušenja preostalega.

## 5. Naslednji korak (po tvoji odločitvi)
- Če potrdiš **združitev vnosa**: posodobiva `koncept.md` §7.9 + wireframe 02/07 (en obrazec),
  nato ločen implementacijski korak (refaktor `quick_log` + `task_form` → en progresivni obrazec).
- Domov pustiva za odločitev ob M4.
- Ta dokument je vir resnice za to revizijo; ko se uskladiva, ga povzameva v `roadmap.md`.
