# Paket 6 (naprava) — dnevnik rezultatov

> **Namen:** vsaka postavka naloga (`25-nadaljevanje-prompt.md §4`) dobi vrstico z **opazljivim
> dejstvom** in **posnetkom**, ki to dokazuje. Odstopanja gredo v `19-najdbe-med-izvedbo.md`,
> ne sem. Postavka brez posnetka **ni** odkljukana.
>
> Naprava: SM-A536B (Android 16), staging build z `SUGGESTIONS_ENABLED=true` in
> `COMMUNITY_ENABLED=true`, nameščen 2026-07-28 22:14. Posnetki v `tmp/shots/` (gitignore).
> Jezik se preklaplja **v aplikaciji** (Nastavitve → Jezik), ne s sistemskim locale: `profile.lang`
> ob zagonu povozi napravin jezik (`main.dart:125`), zato `cmd locale set-app-locales` po prijavi
> nima učinka.

## 1 · §4.1 — kar je bilo popravljeno in ga na napravi nihče ni videl

| Postavka | Kaj je na zaslonu | Posnetek | Stanje |
|---|---|---|---|
| **N17** prazna zgodovina | »Letos še ni zabeleženega nobenega opravila. Zabeleži sezonsko opravilo — obrez, gnojenje, setev — in tu bo pisalo, kje si v primerjavi z okolico.« (stanje doseženo z `update task set status='waiting'` na stagingu) | `70_sl_n17a_prazna_zgodovina.png` | ✅ |
| **N17** nesezonska zgodovina | sl: »Letošnja opravila (npr. zalivanje) niso sezonska, zato se čas začetka pri njih ne primerja.« · de: isti niz | `71_sl_n17b_nesezonska.png` · `40_de_320_wo_du_stehst.png` | ✅ |
| **N17** pretanka soseska | Po zabeleženem **obrezu na paradižniku** (kohorta `prune/tomato` ne obstaja): »Za nobeno opravilo še ni dovolj vrtnarjev v okolici za primerjavo.« — trditev o drugih pade **šele**, ko je zgodovina sezonska | `73_sl_n17c_pretanka_soseska.png` | ✅ |
| **O4** pripona suhega okna | sl: »… (običajni ritem ~4 dni). **Suho okno (~30 h) — primeren čas.**« · de: »… **Trockenes Zeitfenster (~30 h) — guter Zeitpunkt.**« | `75_sl_domov_pas_o4.png` · `50_de_320_pas_vrh.png` | ✅ |
| **P10.1** naslov | »Tendask — lepo, da si tu« (sl) · »Willkommen bei Tendask« (de) | `27_sl_320_x13_auth.png` · `21_de_320_onboarding.png` | ✅ |
| **P10.1** `standing.band` | vrstica »🍎 Obrez / jablana · v tvoji okolici / **pozno**« (prislov, ne »pozen«) | `74_sl_kje_si_ti_vrstica.png` | ✅ |
| **P10.1** žetev | list ob »Označi kot opravljeno«: **»Koliko pridelka?«** | `85_sl_zetev_list.png` | ✅ |
| **P10.1** pretekli predlogi | »Kaj ti je Tendask predlagal in kakšen je bil **tvoj odziv**.« | `76_sl_pretekli_predlogi.png` | ✅ |
| **N27** prednastavitveni list | tretja vrstica: de »Hinweise aus der Umgebung — was andere in deiner Nähe tun. **(optional)**« · sl »Namigi okolice — kaj počnejo drugi v tvoji bližini. **(neobvezno)**« — živa različica, brez »(V2« | `96_de_320_priming_list.png` · `98_sl_320_priming.png` | ✅ (ob tem odkrita **N33**) |
| **N30** ime kanala `suggestions` (de) | sistemske nastavitve → kategorija se imenuje **»Smarte Hinweise«** (pred preklopom jezika je bila »Pametni predlogi« — ime **sledi** jeziku, ker se kanal ustvari ob vsakem `init()`) | `56_de_kanal_suggestions.png` | ✅ |
| **N30** ime kanala `task_reminders` (de) | opomnik nastavljen na 07:50 je **dejansko prišel** (»💧 Gießen · Greda 1 · Heute«), s tem je nastal kanal **»Aufgaben-Erinnerungen«**; tap na obvestilo odpre pravo opravilo (deep link) | `94_de_obvestilo_opomnik.png`, `93_de_kanal_opomniki.png`, `95_de_tap_opomnika_deeplink.png` | ✅ |
| **N30** ime kanala `journal_nudge` (de) | — | — | ❌ **ni preverjeno**: kanal nastane šele, ko je prvo povabilo k dnevniku **prikazano** (naslednji tek je bil 5. 8.). Pokrito z `notification_channel_name_test.dart` |
| **N30** dopolnilo: ime `suggestions` **sledi** jeziku | po preklopu na sl in ponovnem zagonu je kanal »Pametni predlogi«, po preklopu nazaj na de in zagonu spet »Smarte Hinweise« — `createNotificationChannel` ob vsakem `init()` ime **posodobi**; zamrznejo le leno ustvarjeni kanali (`task_reminders`, `journal_nudge`) | `dumpsys notification` (dvakrat) | ℹ dopolnilo k zapisani omejitvi v `19-…` (N30) |

## 2 · §4.2 — ostalo iz testnega načrta

| Postavka | Kaj je na zaslonu | Posnetek | Stanje |
|---|---|---|---|
| Kapica pasu (`band_max_active`) | 5 aktivnih predlogov v bazi → **3 kartice**; po »Überspringen« se vrine četrti | `50/51/52_de_320_pas_*.png`, `53_de_320_po_ueberspringen.png` | ✅ |
| »Pretekli predlogi« | dve vrstici z oznakama »Opuščeno« in »Utišano«, glava in nožni pojasnili | `76_sl_pretekli_predlogi.png` · de `54_de_320_zgodovina_auspflanzen.png` | ✅ |
| Stikala obvestil | štiri vrste; podnapisa »prek strežnika · potrebuje internet« in »kaj se dogaja v okolici« (**N13 živi nizi**, brez »kmalu (V2)«); vrstica sistemskega dovoljenja | `77_sl_obvestila.png`, `78_sl_obvestila_dno.png` · de `66/67` | ✅ |
| Offline (P8) | letalski način: Domov, Okolica in detajl **obdržijo zadnje stanje**, brez rdečih napak — tudi po hladnem zagonu | `79`–`83` | ⚠ delno: veja »offline **in** brez predpomnilnika« ni dosegljiva pri prijavljenem uporabniku (dnevna rezina je bila pridobljena pred izklopom); pokrita s testi P8 |
| Matrika sl/en/de × 1,0/1,3 | narejeno: **de × 1,3 @ 320 dp** čez uvod, prijavo, korak s kodo, Domov, Okolico (pristajalni, »Kje si ti«, detajl, info list), pas predlogov, zgodovino, nastavitve, obvestila, opravila, detajl opravila, čarovnik (kdaj/opomnik/pregled), dnevnik, vrt, lokacijo, Videz, prednastavitveni list; prijavni zaslon tudi @ 360 dp in v sl | `21`–`98` | ⚠ **zavestno omejeno**: **en** ni bil pregnan na napravi — nemščina je najdaljši jezik in zgornja meja, `layout_matrix_test.dart` pa vse tri jezike pokriva na 23 zaslonih; na napravi so bili preverjeni prav tisti zasloni, ki jih matrika **ne** pokriva (uvod, prijava, koda, Domov, lokacija, info list, listi) |
| **N23** vremenska kartica | pri de / 320 dp / ×1,3: `25` in `°C` v **dveh vrsticah**, FAB prekrije kartico »HEUTE«, besedilo »Heute keine geplanten …« odrezano pod navigacijo | `35_de_320_domov_vrh.png` | ⚠ delno: **ostra oblika** (`Überwiegend klar` → `Ü…`) danes ni reproducirana, ker je bil opis vremena kratek (`Klar`) — v paketu 7 jo je reproducirala matrika, ki opis vsili (`weatherCode: 2`) |
| **R4** peti zavihek | `Startsei/te`, `Aufgab/en`, `Tagebu/ch`, `Umgeb/ung` — prelom sredi besede, potrjen pri 320 dp | `35_de_320_domov_vrh.png` | ✅ (zaprto v paketu 7) |
| **N26 ostanek** | `Auspflan/zen` na `suggestions/history`, de / 320 dp / ×1,3 | `54_de_320_zgodovina_auspflanzen.png` | ✅ (sprejeto v `docs/prelomi-besed.md`) |
| Iskalnik preliva | vsi posnetki preleta pregledani s `tmp/overflow_scan.py` (rumeno-črni pas): preliv **samo** na prijavnem zaslonu, koraku s kodo (**N32**) in prednastavitvenem listu (**N33**); vsi drugi zasloni pri de / 320 dp / ×1,3 so čisti | — | ✅ |
| Deep link iz obvestila | tap na opomnik iz vrstice odpre **pravo** opravilo (Gießen · Greda 1) | `95_de_tap_opomnika_deeplink.png` | ✅ (lokalni opomnik; **FCM push tap ni** preverjen v tej seji) |
| Zasloni brez pokritja matrike | lokacija (`89/90`, N13 živi niz »… und um dir zu zeigen, was Gärtner in einem ähnlichen Klima tun«), Videz (`91`), info list Okolice (`92`) — vsi celi pri de / 320 dp / ×1,3 | `89`–`92` | ✅ |

## 3 · Nove najdbe te seje

| # | Kje je zapisana |
|---|---|
| **N32** — prijavni zaslon in korak s kodo se pri 320 dp / ×1,3 prelijeta čez dno (de 137 px, sl 47 px, koda 91 px z odprto tipkovnico); matrika teh zaslonov ne pokriva | `19-najdbe-med-izvedbo.md`, tabela »Odprto« |
| **N33** — prednastavitveni list za obvestila se pri 320 dp / ×1,3 prelije za 258 px (de) in oba gumba padeta z zaslona; v sl je od »Vklopi obvestila« vidnih ~27 px. Pri privzeti gostoti je cel | `19-najdbe-med-izvedbo.md`, tabela »Odprto« |
| **N34** — gumb s fiksno višino (`SizedBox(height: 48)`) odreže dvovrstični nemški napis; odkrita **ni bila na napravi**, ampak ob razširitvi matrike v paketu 7, ko je `layoutBreaks` dobil preverbo navpičnega odreza | `19-najdbe-med-izvedbo.md`, tabela »Odprto« |

**Opaženo, a že zabeleženo drugje:** slovenska sklanjatev `{subject}` — »Med rastno dobo pognoji **paprika**« (`75_sl_domov_pas_o4.png`). Parkirano kot must-do v `roadmap.md` (TENDASK-6), ne nova najdba.

## 4 · §4.3 — pogoji prižiga

| Kaj | Stanje |
|---|---|
| **R4** spodnja vrstica pri petih zavihkih | ✅ **zaprt v paketu 7** (2026-07-29) — krajše nemške oznake (`Start`, `To-dos`, `Journal`, `Garten`, `Umfeld`) + `kNavLabelMaxTextScale = 1,2`, da slovenska »Opravila« ostane; `'nav (five tabs)'` izbrisan iz `kAcceptedWordBreaks` |
| **N23** vremenska kartica | ✅ **zaprt v paketu 7** (2026-07-29) — Domov je prišel v matriko z **resničnim** vremenom in padel v 9 od 18 primerov (19 px preliva pri 320 dp v vseh treh jezikih, že pri ×1,0); napoved gre pod mejno širino v svojo vrstico, oznaka vremena pa je izgubila `ellipsis`, ki je matriki dovolil, da je ne meri (od tod `Ü…`) |
| `kDevPlusStub = false` | ❌ **ostaja odprt po zasnovi** — `config.dart:310` je `true`, dokler ne obstaja licenca FR-20; zato je bila Okolica na napravi ves čas videna kot **plačana** različica, tease pa ne |
| **N26 ostanek** (`Auspflanzen`) | ✅ potrjen kot znan in sprejet prelom (`54_de_320_zgodovina_auspflanzen.png`) |
| sonda `m11_shape.sql` + diff proti stagingu | ✅ **brez zdrsa**: prod nima **nobenega** M11 objekta (0 vrstic COLUMN/INDEX/RLS za `suggestion`, `engine_run`, `app_config`, `activity_*`, `plant_task_rule`), ledger se konča pri **0016**, `engine_dispatch()` je zapisani no-op (`tmp/m11_shape_prod.txt` proti `tmp/m11_shape_staging.txt`) |
| sonda `agg_context_invariants.sql` | ✅ **6× PASS** na stagingu, v `rollback`: prvi žig dovoljen · prepis blokiran (`raise warning`) · ponovni push brez napake · izhod v sili deluje · N15 zamrznjena cona zmaga (`2026-06-16` iz posnetka proti `2026-06-15` iz profila) |
| sonda `push_rejection_rate.sql` | ✅ pognana, `rejected_30d = 0`, `users_with_a_run = 2` — **ničle so pričakovane** (pred prižigom ni pushov), ne okvara sonde |

## 5 · Testni podatki na stagingu

| Kaj | Stanje |
|---|---|
| 5 ročno posejanih vrstic v `public.suggestion` (`tmp/seed_suggestions.sql`) | ✅ **počiščeno** — `deleted = true` (mehki izbris, da jih pobere tudi naprava); `suggestion_log` ni dobil novih vrstic |
| opravila z naprave: obrez/paradižnik, obrez/jablana, dve pobiranji/jagoda + `user_plant` **jablana** | **ostane namenoma** — to je realna zgodovina, ki drži vrstico »Kje si ti« pri življenju za naslednjo sejo |
| statusi zalivanj (`tmp/n17_a_no_history.sql`, `tmp/n17_b_c.sql`) | ✅ vrnjeni na `done` |
| naprava | gostota `reset` (450 dp), `font_scale 1.0`, jezik aplikacije **sl**, `POST_NOTIFICATIONS` znova dodeljen, `SCHEDULE_EXACT_ALARM` dovoljen |

## 6 · Zeleno po paketu

`flutter test` **1333 zelenih** · `deno test supabase/functions/` **176 zelenih** · `flutter analyze` brez opozoril
(v paketu 6 ni bilo sprememb kode — samo dokumentacija in testni podatki).
