# Prompt za novo sejo (kopiraj v nov Claude Code chat)

> Memory + CLAUDE.md se naložita samodejno; ta prompt samo usmeri fokus.

---

Nadaljujeva Tendask. Stanje: M0–M9 ✅, Play Console setup večinoma narejen (app ustvarjen `app.tendask`, AAB na internem testu aktivno, listing EN + App content kompletni), **Google login na Play-buildu rešen** (Play App Signing SHA-1 registriran kot OAuth client). Podrobno stanje: `docs/go-live/play-console-status.md`.

**Fokus te seje: popravi dva buga, ki blokirata zaprti test.** Opisana sta v `docs/bugreport.md`:

1. **BUG-002** — po prijavi (in logout→login) app **vedno** vpraša za lokacijo, čeprav je že nastavljena. Vzrok: `login_screen.dart:48` (Google) + `email_login_screen.dart:86` (e-pošta) + `:35` (gost) brezpogojno `context.go('/location')`, brez preverbe stanja. Nianса: surove koordinate so v local-only `device_location` (ob logoutu zbrisane, se NE vrnejo iz oblaka); sinhronizira se le `profile.h3`. Popravek naj po prijavi preveri, ali je lokacija že nastavljena (npr. `profile.h3_r7 != null`) → če je, naravnost na `/home`; sicer `/location`. Razmisli, ali naj bo korak lokacije po logoutu preskočljiv/neobvezen.

2. **BUG-003** — gost ima »Odjava«, logout pa tiho izbriše nesinhronizirane podatke (možna izguba). Zahtevano: (a) gost (`AuthService.email == null`) nima gumba »Odjava« (skrit/onemogočen); (b) pred `clearUserData()` ob odjavi `flushPush()` ali potrditveni dialog, če flush ni mogoč (offline). Vzorec flush-pred-clear že obstaja za e-poštno prijavo.

**Postopek (po CLAUDE.md):**
- Najprej preberi prizadete datoteke + ustrezne dele `docs/koncept.md`/wireframov (auth/location flow), ne ugibaj.
- Po code-gen spremembah (drift/riverpod): `dart run build_runner build --delete-conflicting-outputs`; po i18n: `dart run slang`.
- `flutter analyze` čist + testi zeleni; dodaj test, kjer je smiselno (logout-flush, post-login routing).
- **Vprašaj za commit** po vsakem zaključenem koraku (ne commitaj brez dovoljenja). En bug = en commit.
- Ob koncu: zgradi nov **podpisan AAB** (`flutter build appbundle --release --dart-define-from-file=dart_defines.json`), **dvigni `versionCode`** v `pubspec.yaml` (`1.0.0+1` → `1.0.0+2`) pred buildom, da Play sprejme upload.

**Po popravkih:** naloži nov AAB na interni test, on-device preveri (SM A536B, `! deploy.bat hot` za debug ali install AAB), nato uporabnik prestavi build na **zaprti test** in razpošlje vabilo (`docs/go-live/tester-invite.md`) za ≥12 testerjev (14-dnevni gate).

**Ne pozabi:** ne dela popravka, dokler ni potrjen; po dogovoru vprašaj pred commitom; `tmp/` za scratch.

Začni z branjem `docs/bugreport.md` (BUG-002, BUG-003) + prizadetih datotek, predlagaj načrt popravka, počakaj na potrditev.
