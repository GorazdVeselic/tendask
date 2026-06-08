# Prompt za novo sejo — Tendask (vrtnarska evidenčna aplikacija)
<!-- mapa projekta = C:\Users\Uporabnik\StudioProjects\tendask; ime aplikacije = Tendask -->

> Kopiraj spodnje besedilo v novo sejo Claude Code (v mapi `C:\Users\Uporabnik\StudioProjects\tendask`).

---

Delava na **mobilni aplikaciji Tendask** za osebno evidenco vrtnih opravil (vrt, trata,
živa meja, gredice). Evropski/večjezični (SLO) hobi-trg. Govoriva slovensko. **Aplikacija
je v razvoju — M0–M8 zaključeni, trenutno smo pri M9 (polish + release).**

**Najprej preberi:**
- `CLAUDE.md` — pravila pisanja kode (vir resnice za KAKO delamo).
- `docs/roadmap.md` — razvojni plan + **dnevnik napredka** (najnovejše zgoraj = točno stanje).
- `docs/koncept.md` — živ dokument (§7.x arhitektura/zasloni, §7.14 podatkovni model, konec = dnevnik odločitev).
- `docs/tech-stack.md` — POTRJEN tehnološki sklad.
- `docs/brand/brand.md` — POTRJENA vizualna identiteta.
- `docs/wireframes/index.html` — galerija zaslonov.

**Kako pogledati wireframe + brand:** v mapi `docs/` zaženi `python -m http.server 8000`,
nato odpri http://localhost:8000/wireframes/ in http://localhost:8000/brand/final.html .

**ŽE ZAKLJUČENO (M0–M8):**
- Skeleton + tema + router + i18n (sl/en/de, slang); drift offline baza + seed kataloga (128 vrst).
- Jedro opravil (vnos-čarovnik, pregled, urejanje, dnevnik, koledar); območja · rastline · opombe.
- Vreme (Open-Meteo, posnetek na opravilo); Supabase zaledje + RLS; ročni sync (push/pull, LWW).
- Auth (anonimno + linkanje) + lokacija/H3 na napravi; lokalna obvestila (opomniki + deep-link, zasloni 19–22).
- **Ime/domeni/znamka** potrjeni; tech sklad in brand potrjena.

**M9 — V TEKU (kaj je narejeno / kaj sledi):**
- [x] 9.1 Sentry (pure-Dart), 9.2 ikona+splash, 9.3 pregled neskladij UI/wireframi+i18n,
  9.6 razširitev kataloga rastlin (128 vrst), 9.8 UI polish + začasni izklop sredstev.
- [ ] **9.4 Android release** (keystore 👤, podpisan build, produkcijski `--dart-define`),
  **9.7 GDPR** (izvoz podatkov + izbris računa — placeholderja v Nastavitvah),
  **9.5 Play interni test** (👤, predpogoj 9.6).

**Ključne odločitve (na kratko):**
- OPRAVILO = ena entiteta (datum · status čaka/opravljeno · rastlina/območje · vreme · opomnik).
- Offline-first: UI bere/piše drift; Supabase v ozadju. Lokacija → samo H3 celice v profil (koordinate ostanejo na napravi).
- Jeziki SL/EN/DE. MVP solo; H3 skupnost + percentili = V2; brez AI (kurirana pravila, glej `pametni-motor.md`).
- **Sredstva (supplies) so začasno SKRITA** prek `kSuppliesEnabled=false` (`core/config.dart`) — pred-release odločitev; koda ostane.

**Pred-release TODO (iz beležk):** bundlan katalog seed za offline prvi zagon je narejen; on-device pull verifikacija ob naslednji priklopljeni napravi.

**Delovni dogovor:** en korak = en commit; **pred commitom vedno vprašaj**; po spremembi sproti
posodobi `docs/koncept.md` (+ dnevnik odločitev) + `roadmap.md` dnevnik + ustrezni wireframe/galerijo.
On-device preverba prek `! deploy.bat hot` (Samsung SM-A536B). Po spremembi sheme: `build_runner` +
Supabase `db push`; po i18n: `dart run slang`.
