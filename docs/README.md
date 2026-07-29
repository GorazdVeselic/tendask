# Dokumentacija Tendask — karta

**Začni tu.** Vsak dokument ima eno nalogo; če iste stvari ne najdeš na enem mestu, je to napaka
v strukturi, ne razlog za nov dokument.

## Vsako sejo

| Vprašanje | Dokument |
|---|---|
| Kje smo, kaj je v produkciji, kaj teče | [`stanje.md`](stanje.md) |
| Kaj je odprto, kaj gradimo naslednje | [`backlog.md`](backlog.md) |
| Kaj je že zgrajeno in **zakaj tako** | [`narejeno.md`](narejeno.md) |
| Kako pišemo kodo | [`../CLAUDE.md`](../CLAUDE.md) |
| Kanonični ukazi (build, naprava, DB, git) | [`cookbook.md`](cookbook.md) |

## Po potrebi

**Zasnova in domena**
- [`koncept.md`](koncept.md) — funkcionalna specifikacija; §7.9 entiteta opravilo, §7.14 podatkovni
  model, §8 vizija skupnosti, na koncu dnevnik odločitev.
- [`tech-stack.md`](tech-stack.md) — potrjen sklad (§1), struktura map (§6), sync arhitektura (§2).
- [`brand/brand.md`](brand/brand.md) — vizualna identiteta.
- [`opravila-in-rastline.md`](opravila-in-rastline.md) — vsebinski vir za seed kataloga.

**Ko delaš na UI**
- [`ui-katalog.md`](ui-katalog.md) — en widget na vzorec, barve samo prek teme. **Preberi pred**
  dodajanjem zaslona, obrazca, sheeta ali dialoga.
- [`screen-map.md`](screen-map.md) — zasloni, rute, CTA, prehodi.
- [`wireframes/index.html`](wireframes/index.html) — galerija (`python -m http.server 8099` iz `docs/`).
- [`prelomi-besed.md`](prelomi-besed.md) — pravilo za prelome sredi besede v layout matriki.

**Operativa**
- [`deploy-runbook.md`](deploy-runbook.md) — izdaja, migracije, ⚠️ `linked` = PROD.
- [`staging-env.md`](staging-env.md) — staging okolje (WSL Docker, `deploy.bat hot`).
- [`how-to-add-plant.md`](how-to-add-plant.md) — postopek za katalog rastlin.
- [`go-live/`](go-live/) — Play Console: [stanje objave](go-live/play-console-status.md),
  [listing](go-live/store-listing.md), [testerji](go-live/testers.md).
- [`legal/`](legal/) — politika zasebnosti, Play Data Safety.

**Vhod uporabnikov**
- [`povratne-informacije.md`](povratne-informacije.md) — opažanja testerjev T1–T12 z odločitvami.
- [`bugreport.md`](bugreport.md) — odprti bugi BUG-001…004.

**Specifikacije odprtih zahtevkov**
- [`feature-requests/`](feature-requests/) — polni spec vsakega FR; **kazalo in stanje sta v**
  [`backlog.md`](backlog.md), ne tukaj.
- [`m11.md`](m11.md) — pametni motor: zakaj je ustavljen, kaj pušča na produkciji, kje je koda.
- [`pametni-motor.md`](pametni-motor.md), [`skupnost-agregacija.md`](skupnost-agregacija.md),
  [`vreme-shranjevanje.md`](vreme-shranjevanje.md) — konceptualna ozadja posameznih področij.

**Arhiv** — [`archive/`](archive/): zgodovinski zapisi, ki jih ne beremo pri delu
(zaključeni načrti). Nič od tod ni vir resnice; kaj je bilo izbrisano in kje ga dobiš, pove [`archive/README.md`](archive/README.md).

## Pravila vzdrževanja

- **Zaključeno gre iz `backlog.md` v `narejeno.md`** — z razlogom, ne s potekom dela. Nikoli obojih.
- **`stanje.md` se prepiše, ne dopolnjuje.** Ni dnevnik; zastarelo vrstico zamenjaj.
- **Ko dokument opravi svoje** (načrt je izveden, handoff je porabljen), gre v `archive/` ali ven —
  zastarel dokument je dražji od nobenega, ker ga nekdo prebere in mu verjame.
- **Ena tema, en dokument.** Preden dodaš datoteko, preveri, ali sodi v obstoječo.
