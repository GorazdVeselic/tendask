# M11 — predaja seje (**paket 6 izveden**, ostane paket popravkov s naprave)

> **Datum:** 2026-07-29 · veja `feat/m11-smart-engine` · **nič pushano, produkcija nedotaknjena**
> **Vstopna točka za novo sejo.** `18-` do `25-nadaljevanje-prompt.md` so zastareli.
> Beri tega, nato `26-paket6-rezultati.md` (kaj je bilo videno na napravi) in
> `19-najdbe-med-izvedbo.md` (N32, N33 sta novi).

---

## 0 · Kje sva

Paket 6 (naprava) je **izveden**: 79 posnetkov v `tmp/shots/`, dnevnik rezultatov v
`docs/m11/26-paket6-rezultati.md`. `flutter test` **1333**, `deno test supabase/functions/` **176**,
`flutter analyze` čist. V paketu 6 ni bilo sprememb kode.

**Nekomitano v drevesu** (odloči takoj na začetku): `docs/m11/19-najdbe-med-izvedbo.md` (dodana N32,
N33 + pregledni vrstici) in nova `docs/m11/26-paket6-rezultati.md`. Netaknjeno tuje: neizsledena
`docs/feature-requests/location-nudge.md` iz vzporedne seje — **ni tvoje, ne dodajaj je v commit**.

Produkcija (preverjeno s sondo, read-only): ledger se konča pri **0016**, **nobenega** M11 objekta
ni, `engine_dispatch()` je zapisani no-op. Staging ima 0017–0022.

## 1 · Cilj te seje: paket popravkov s naprave

Štiri postavitvene napake, vse pri **320 dp** (`wm density 540`), vse potrjene s posnetkom. Tri od
štirih so bile nevidne testom, ker **matrika teh zaslonov sploh ne pokriva** — zato je trajni del
tega paketa razširitev matrike, ne samo popravek widgeta.

| # | Kaj | Datoteka | Dokaz |
|---|---|---|---|
| **N32** | prijavni zaslon se prelije čez dno (de 137 px, sl 47 px); naslov trči v gumb | `lib/features/auth/presentation/login_screen.dart:76–188` — `Column` z `Expanded` glavo in šestimi fiksnimi otroki, brez drsnika | `tmp/shots/25_de_320_auth.png`, `27_sl_320_x13_auth.png`, kontrola @360 dp `26_de_360_x13_auth.png` |
| **N32b** | korak s kodo: 91 px preliva ob odprti tipkovnici, gumb »Bestätigen und anmelden« do polovice odrezan in **tapa ne sprejme**; naslov v vrstici skrajšan v `Mit E-Mail anmeld…` | `lib/features/auth/presentation/email_login_screen.dart` | `tmp/shots/32_de_320_po_tapu.png` |
| **N33** | prednastavitveni list obvestil: 258 px preliva, **oba gumba z zaslona**, list ni drsljiv → po tej poti dovoljenja za obvestila ni mogoče dati (izhod je le poteza nazaj). V sl je od »Vklopi obvestila« vidnih ~27 px | `lib/features/notifications/presentation/notification_priming_sheet.dart` | `tmp/shots/97_de_320_priming_dno.png`, `98_sl_320_priming.png`, kontrola @450 dp `99_sl_450_priming.png` |
| **R4** | pet zavihkov lomi napise sredi besede (`Startsei/te`, `Aufgab/en`, `Tagebu/ch`, `Umgeb/ung`; sl `Opravila`) | `lib/app/router/main_shell.dart:40–90` (`NavigationBar` + `mainShellDestinations`) | `tmp/shots/35_de_320_domov_vrh.png` |
| **N23** | vremenska kartica na Domov: `25` in `°C` v dveh vrsticah, opis se skrči v `Ü…`, ko je daljši; FAB prekrije kartico pod pasom; zadnja vrstica odrezana pod navigacijo | `lib/features/weather/presentation/weather_card.dart` (`CurrentWeatherCard`) + spodnji padding Domov | `tmp/shots/35_de_320_domov_vrh.png` (ostra oblika `Ü…` je iz prejšnje seje, `13_de_320dp_x13_nav.png`) |

### Vrstni red, ki ga priporočam

1. **Najprej matrika, potem popravki.** Vsak popravek mora imeti test, ki **pade brez njega**.
   V `test/layout/layout_matrix_test.dart` manjkajo: `home` (Domov), `login`, `login-email`,
   uvod (`onboarding`) in prednastavitveni list. Domov je treba dodati z **resničnim vremenom**
   (najdaljši opis, npr. de »Überwiegend bewölkt«) — trenutni `weather: null` je natanko razlog,
   zakaj je N23 preživel (glej N23 v `19-…`).
2. **R4 rabi drugačno varovalo.** `NavigationBar` napise **odreže, ne prelije**, zato matrika
   `nav (five tabs)` ostane zelena tudi ob prelomu — `main_shell.dart:53` to celo pove. Preden
   popraviš, potrebuje `test/layout/layout_harness.dart` preverbo, ki odrez v `NavigationBar`
   dejansko ujame (npr. `getMinIntrinsicWidth` napisa proti dodeljeni širini; pomni pravilo iz
   `CLAUDE.md`: prosto-ovijajoč tekst ni signal, vrstično omejen pa je).
3. Šele nato widgeti. N32, N32b in N33 imajo **isti vzrok** (stolpec brez drsnika) — en vzorec,
   trije klicalci: `SingleChildScrollView` + `ConstrainedBox(minHeight: constraints.maxHeight)`.
   Pri listu (N33) gumba **ne smeta odplavati** z vsebino: drsi naj vsebina, gumba ostaneta pripeta.
4. R4 je **odločitev, ne mehanika**: krajši napisi v `nav.*` (i18n, potem `dart run slang`) ali
   omejitev `textScaler` na napisih ali `labelBehavior`. Predlagaj eno in povej, kaj izgubiš.
5. N23 enako: bodisi opis sme v dve vrstici, bodisi napoved odpade pod neko širino. Ne pozabi
   spodnjega paddinga Domov (FAB + navigacija).

### DoD paketa

- vsak popravek ima test, ki na verziji **pred** popravkom pade (matrika ali widget test);
- ponovna preverba **na napravi** pri `wm density 540` + `font_scale 1.3` v **de in sl**, posnetek
  v `tmp/shots/` z govorečim imenom; `tmp/overflow_scan.py` (iskalnik rumeno-črnega pasu) na vseh
  novih posnetkih vrne `ok`;
- `19-najdbe-med-izvedbo.md`: N32, N33 dobita ✅ in hash; R4 in N23 gresta iz »pogoj prižiga« v
  zaprto vrstico;
- `26-paket6-rezultati.md` §4 (tabela pogojev prižiga) se posodobi;
- `flutter test` + `deno test supabase/functions/` + `flutter analyze` zeleni.

## 2 · Kako reproducirati na napravi (naučeno v paketu 6)

```bash
adb shell svc power stayon true          # prvi korak vsake seje
adb shell wm density 540                 # 320 dp (360 dp = 480, nazaj: wm density reset)
adb shell settings put system font_scale 1.3
```

- **Jezik preklapljaj v aplikaciji** (Nastavitve → Jezik), **ne** s `cmd locale set-app-locales`:
  `main.dart:125` ob zagonu povozi napravin jezik s `profile.lang`, zato sistemski per-app locale
  po prijavi nima učinka. (Deluje le pri svežem `pm clear`, do prve prijave.)
- Scenariji: `tmp/steps.txt` + `& ./tool/adb_run.ps1` (PowerShell). Pasti, ki so stale časa:
  - `taptext` matcha **združen** semantični vozel — »Verlauf« v glavi pasu je del enega vozla in
    tap pristane sredi kartice; do zgodovine gre prek Nastavitev.
  - FAB pri 320 dp je na `tap 540 1820`, pri 450 dp na `tap 540 1916`; zobnik na Domov je
    `tap 990 170` (320 dp) oz. `tap 1012 168` (450 dp).
  - Vnos ure v `TimePicker`: preklopi na besedilni način, nato **`key 123` (na konec) + 4× `key 67`**
    in šele potem `text 07`. Brez `key 123` se znak pripne (»19« + »7« = »79«).
  - Tipkovnica prekrije gumb pri 320 dp; obvestilni oblaček tipkovnice požre tap. Za prijavo
    preklopi na `wm density 450`, prijavi se, nato nazaj na 540.
- Prednastavitveni list (N33) dobiš tako, da odvzameš dovoljenje in greš prek opravila:
  `adb shell pm revoke app.tendask android.permission.POST_NOTIFICATIONS` → opravilo → Uredi →
  korak opomnika → »Dodaj opomnik«. Po testu **vrni** `pm grant`.
- Kanali obvestil: `adb shell dumpsys notification --noredact | grep -o "mId='…', mName=[^,]*"`;
  posamezen kanal odpre
  `adb shell am start -a android.settings.CHANNEL_NOTIFICATION_SETTINGS --es android.provider.extra.APP_PACKAGE app.tendask --es android.provider.extra.CHANNEL_ID suggestions`.
  `task_reminders` nastane **šele, ko je obvestilo prikazano** (ne ob načrtovanju).
- `tmp/overflow_scan.py` šteje rumene piksle v vrstici (pas je črtast, zato **ne** išči zaporedja).
  Če ga rabiš trajno, ga premakni v `tool/` — `tmp/` je gitignore.

## 3 · Stanje staginga in testnih podatkov

- 70 sintetičnih sosedov v `871e13904ffffff`, kohorte `prune/fertilize/mow` × `@site|apple` = 35.
- Ročno posejani predlogi so **počiščeni** (`deleted = true`).
- Ostanejo (namenoma, ker držijo vrstico »Kje si ti«): `user_plant` **jablana**, obrez/jablana,
  obrez/paradižnik, dve pobiranji/jagoda pri `107b37fb-…`.
- Sonde: `m11_shape.sql` (prod prek `tmp/probe_m11_shape_prod.py`, read-only),
  `agg_context_invariants.sql` (6× PASS, teče v `rollback`), `push_rejection_rate.sql`
  (ničle so **pričakovane** pred prižigom).

## 4 · Česa NE popravljaj

Sprejeto in zapisano — ne odpiraj znova: **N3, N5, N6, N10, N11, N24, N31, ostanek N22** ·
odločitve paketov 3–5 in N12 (push nosi naslov in ne telesa · zajem generatorja je seznam ·
test markerjev bere surov katalog · `gendered_wording_test.dart` ima namenoma dva dela ·
nov `channelId` je bil zavrnjen z razlogom · `suggestion_log` je s klienta šel v celoti ·
žig zavrnjenega pusha je per-uporabnik · zavrnitev se ne poroča prek `reportError`).

Prav tako **ni** naloga te seje: slovenska sklanjatev `{subject}` (»pognoji **paprika**«) — parkirano
kot must-do v `roadmap.md` (TENDASK-6, rabi nominativ-oznako čez ~61 sporočil) · `kDevPlusStub = false`
(stikalo ob prižigu, ne popravek) · kanal `journal_nudge` v nemščini (nastane ob prvem povabilu) ·
FCM push tap iz ozadja.

## 5 · Delovni dogovor

En paket = en commit · **pred commitom vprašaj** · po paketu cel `flutter test` +
`deno test supabase/functions/` + `flutter analyze` · vsako najdbo vpiši v
`19-najdbe-med-izvedbo.md` **takoj ob odkritju** s kupom (A/B/C) · postavko odkljukaj šele ob
artefaktu · opažanja na napravi opisuj po **ADB screencapu**, ne po spominu · pred ad-hoc ukazom
poglej `docs/cookbook.md` · v Bash orodju je `git commit -F - <<'MSG'`, **ne** `-m @'...'@`.

Po spremembi i18n ključev `dart run slang`; po spremembi `suggestions.*.title` ali `push.fallback_*`
še `dart run tool/gen_push_i18n.dart`.

## 6 · Sklici

`26-paket6-rezultati.md` (**beri prvi**) · `19-najdbe-med-izvedbo.md` · `17-plan-popravkov.md` §P11/§P12 ·
`docs/prelomi-besed.md` · `docs/ui-katalog.md` · `docs/screen-map.md` · `docs/cookbook.md` ·
`docs/deploy-runbook.md` · `CLAUDE.md`
