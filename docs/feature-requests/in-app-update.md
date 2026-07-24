# FR-15: Obvestilo o nadgradnji v aplikaciji (in-app update)

- **Status:** predlog (feature request), čaka odločitev o obsegu
- **Datum:** 2026-06-26
- **Avtor:** Gorazd
- **Področja:** Android (Play), Flutter dependency, Supabase (opcijsko za gate), iOS (M10), GDPR/Data Safety (minimalno)
- **Povezave:** [`docs/tech-stack.md`](../tech-stack.md) (§1 sklad), [`docs/roadmap.md`](../roadmap.md), [`CLAUDE.md`](../../CLAUDE.md) (»Dependencies«, »Sync, čas in shema« → additive-only)

---

## 1. Povzetek (TL;DR)

Želiva, da app **zazna, da je na Play na voljo novejša verzija**, in uporabniku ponudi nadgradnjo — brez lastnega »version check« strežnika.

**Priporočen razrez (dva neodvisna mehanizma, ne eden):**

- **Mehki »na voljo je posodobitev« UX (Android) → Google Play In-App Updates** prek paketa `in_app_update` (flexible flow). Play sam ve za višji `versionCode`; app le pokliče `checkForUpdate()`. Nič lastne infrastrukture.
- **Trdi »moraš nadgraditi« gate (cross-platform) → lasten Supabase `min_supported_version`** branjen ob zagonu. Rabi se **redko** (vajina additive-only politika namenoma preprečuje prisilne nadgradnje), a je edina pot za iOS in za res prelomne primere.

**Predlog vrstnega reda:** najprej In-App Updates (Android, majhen poseg, takojšnja vrednost), Supabase gate šele ob dejanski potrebi / z iOS (M10).

---

## 2. Kontekst (zakaj je to relevantno zdaj)

- Distribucija je **Google Play** (zaprti test → produkcija). Play je edini kanal → Play-native mehanizem je smiseln.
- `versionCode` raste z vsakim releaseom (trenutno **vc12**, `1.0.0+12`). To je natanko signal, ki ga In-App Updates bere.
- **Offline-first:** app deluje brez signala. Update prompt **ne sme** biti blokirajoč ali alarmanten — mirna, opcijska akcija (skladno s »Network fail ni exceptional path«).
- **iOS (M10) je odložen** — Apple nima ekvivalenta In-App Updates; iOS pokrije le Supabase gate ali App Store mehanizem.

---

## 3. Opcija A — Google Play In-App Updates (priporočeno za Android)

**Paket:** [`in_app_update`](https://pub.dev/packages/in_app_update)

| Kazalnik | Vrednost |
|---|---|
| Verzija | 4.2.5 (objavljena ~9 mes. nazaj) |
| Publisher | jonasbark.de (verified) |
| Priljubljenost | ~1.29k likes, 160/160 pub points, ~189k tedensko |
| Platforme | **samo Android** |
| Licenca | MIT |
| API | `checkForUpdate()`, `startFlexibleUpdate()` + `completeFlexibleUpdate()`, `performImmediateUpdate()` |

**Verdikt:** zdrav, mainstream, tanek wrapper okrog uradnega Play In-App Update API-ja (že na moderni `com.google.android.play:app-update` knjižnici). »9 mesecev brez release-a« ni alarm — spodnji API je stabilen.

### Dva flowa
- **Flexible** (priporočeno): prenos v ozadju, uporabnik dela naprej, nato mirno »Znova zaženi za posodobitev«.
- **Immediate**: celozaslonski blokirni update (le za nujne/varnostne primere).

### Pasti (specifične za Tendask)
1. **Samo Play-nameščeni buildy** — ne dela na sideload/debug; **ni ga moč testirati lokalno**. Testira se prek Play tracka (med zaprtim testom dela za testerje, ko je gor višji `versionCode`).
2. **Samo Android** — iOS (M10) potrebuje ločeno pot.
3. **AGP 9 / KGP:** ekosistem je sredi prehoda; build že kaže ne-blokirna KGP opozorila (`flutter_timezone`, `share_plus`…). `in_app_update` bi se jim pridružil — **opozorilo, ne blokada**. Ob dodajanju potrdi, da build še zleti.
4. **Nova dependency izven `tech-stack.md §1`** → po pravilu projekta najprej potrdi + pin (`^4.2.5`) + posodobi §1.

---

## 4. Opcija B — Lasten Supabase min-version gate (cross-platform, za »force update«)

- Ena vrstica remote configa (npr. tabela `app_config` s `min_supported_version` / `latest_version`), branjena ob zagonu prek obstoječega Supabase klienta.
- Logika: `installedVersion < min_supported_version` → blokirni dialog »Posodobi« z `url_launcher` na Play/App Store listing.
- **Plusi:** popoln nadzor, **deluje tudi na iOS**, idealno za res prelomne primere (npr. če bi kdaj prekršil sync kompatibilnost — kar additive-only ravno preprečuje).
- **Pasti:** sam vzdržuješ vrednost; ni »auto download« kot In-App Updates; rabi `installedVersion` iz `package_info_plus` (že v skladu) in primerjavo verzij.
- **Shema:** `app_config` je javno-bralna (kot katalog), RLS read-only; additive migracija.

---

## 5. Opcija C — `upgrader` paket (odsvetovano)

Pokaže dialog na osnovi verzije iz trgovine, a pogosto temelji na **scrapanju store strani** (krhko, se lomi ob spremembah Play/App Store HTML). Ne priporočam.

---

## 6. Priporočilo

Vajina **additive-only migracijska politika** je namerno taka, da stari APK-ji **ne crashajo** ob pull-u → prisilne nadgradnje skoraj nikoli ne rabiš. Zato:

- **Za »na voljo je novejša verzija → nadgradi?«** → **Opcija A (In-App Updates, flexible)**: minimalen trud, native UX, samodejna zaznava.
- **Za redke »moraš nadgraditi« + iOS** → **Opcija B (Supabase gate)**, dodana kasneje, ko se pokaže potreba ali ob M10.

Opciji A in B se **ne izključujeta** — A je udobje na Androidu, B je varovalka povsod.

---

## 7. Predlagan obseg 1. iteracije (Opcija A)

1. Potrdi dependency `in_app_update: ^4.2.5`, posodobi `tech-stack.md §1`.
2. `core/` servis `UpdateService` (provider), ki ob app-startu/resume pokliče `checkForUpdate()`.
3. Ob `UpdateAvailability.updateAvailable` → mirno **flexible** povabilo (banner ali nenasilen dialog, prek `t.*` i18n, brez besede »motor« ipd.), ne blokirajoče.
4. `startFlexibleUpdate()` → ob `downloaded` pokaži »Znova zaženi za dokončanje« → `completeFlexibleUpdate()`.
5. Vsi nizi v slang (en/sl/de). Brez hardcode.
6. **DoD on-device:** preveri prek Play internega tracka (potrebuje gor objavljen višji `versionCode`); lokalno ni testabilno.

---

## 8. Zasebnost & GDPR

- **In-App Updates ne zbira osebnih podatkov** v vajinem smislu — vse teče prek Play storitve, ki je že obdelovalec (Play distribucija). Minimalen/ničen vpliv na Data Safety.
- **Supabase gate** bere javno `app_config` (brez PII) in `installedVersion` (lokalno) → prav tako brez vpliva na zasebnost.

---

## 9. Odprta vprašanja / odločitve

1. **Flexible ali tudi Immediate?** Predlog: samo flexible (mehko); immediate šele, če bo kdaj nujen varnostni release.
2. **Kdaj klicati `checkForUpdate()`?** Predlog: ob zagonu + ob resume, z razumnim throttle (npr. max 1×/dan), da ne nadleguje.
3. **Ali že zdaj dodava Supabase gate (B), ali šele z M10/iOS?** Predlog: odloži do potrebe.
4. **Umestitev v roadmap:** verjetno V2.5+ ali ločen FR-blok; ni go-live blocker (Google review zadeva je rešena ločeno z vidnejšim gostom).

---

*Naslednji korak ob potrditvi: dodaj `in_app_update` (+ §1) → `UpdateService` provider → flexible UX z i18n → on-device preverba prek Play internega tracka.*
