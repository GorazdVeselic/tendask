# Prompt za novo sejo — Tendask (vrtnarska evidenčna aplikacija)
<!-- mapa projekta = C:\Users\Uporabnik\StudioProjects\tendask; ime aplikacije = Tendask -->

> Kopiraj spodnje besedilo v novo sejo Claude Code (v mapi `C:\Users\Uporabnik\StudioProjects\tendask`).

---

Delava na **mobilni aplikaciji Tendask** za osebno evidenco vrtnih opravil (vrt, trata,
živa meja, gredice). Evropski/večjezični (SLO) hobi-trg. **Pred-implementacijska faza —
NIČ hitenja z razvojem.** Govoriva slovensko.

**Najprej preberi:**
- `docs/koncept.md` — živ dokument (7.7–7.14 = arhitektura, 10 = naslednji koraki, konec = dnevnik odločitev).
- `docs/tech-stack.md` — POTRJEN tehnološki sklad (preberi pred kakršnimkoli kodiranjem).
- `docs/brand/brand.md` — POTRJENA vizualna identiteta.
- `docs/opravila-in-rastline.md` — katalog tipov opravil + rastlin (delno; glej spodaj).
- `docs/wireframes/index.html` — galerija ~27 zaslonov. memory `tendask-project-concept`.

**Kako pogledati wireframe + brand:** v mapi `docs/` zaženi `python3 -m http.server 8000`,
nato odpri http://localhost:8000/wireframes/ in http://localhost:8000/brand/final.html .

**ŽE ZAKLJUČENO:**
- Koncept, ~27 wireframov + flow (8 krogov), podatkovni model (§7.14), obvestila (2 plasti), monetizacija (smer).
- **Ime = „Tendask"**; domeni `.com`+`.app` kupljeni; **znamka preverjena (TMview, čisto)**.
- **Tech sklad POTRJEN** (`tech-stack.md`): Flutter + Riverpod + drift (offline) + ročni sync + Supabase +
  Sentry; FCM odložen; 0 € v razvoju/MVP. Vodilo: AI agent kodira → mainstream tehnologije.
- **Brand POTRJEN** (`brand/brand.md`): logo = list v H3-šesterokotniku (brez kljukice); zelena #2e7d32 +
  medena #E0A82E; Plus Jakarta Sans; SVG asseti v `docs/brand/assets/`.

**Ključne odločitve (na kratko):**
- OPRAVILO = ena entiteta (datum · status čaka/opravljeno · rastlina? · sredstva · vreme · opomnik).
- IA: 2 zavihka — 📅 Dnevnik + 📋 Opravila; FAB ＋ = Hiter vnos(02) → "Napredno ›" → Novo opravilo(07).
- Območja brez lokacije; lokacija+vreme+H3(res-7) = profil. Vreme = Open-Meteo. Jeziki SL/EN/DE.
- MVP solo prvo; H3 skupnost + percentili = V2. Brez AI (kurirana pravila).

**NAREDI NAPREJ (po vrsti, z mojim sprotnim pregledom):**
1. **Dokončaj katalog `opravila-in-rastline.md`** — preverba prevodov SL/EN/DE; razširitev rastlin
   ~35→100–200 (seed Wikidata/GBIF, NE ročno); ikone tipov opravil; matrika kategorija↔opravila.
2. *(opcijsko)* lastna registracija znamke (SIPO/EUTM, razred 9) — do launcha, ni nujno zdaj.
3. **Začetek implementacije** po `tech-stack.md §9`: Flutter skeleton → drift → seed → Supabase →
   sync → auth → jedro UI.

Vsako spremembo sproti zapiši v `docs/koncept.md` (+ dnevnik odločitev) in posodobi ustrezni
wireframe + galerijo `index.html`. Po spremembah preglej neskladja po zaslonih.
