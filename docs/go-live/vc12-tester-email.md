# vc12 — obvestilo testerjem o posodobitvi

- **Datum:** 2026-06-28
- **Namen:** obvestiti zaprte testerje, da so opomniki popravljeni + dodane teme (spremembe vc6–12), in jih povabiti k posodobitvi iz Play.

---

## 1. Changelog vc6 → vc12 (dejanski)

Glavno (uporabniško vidno):
- **Opomniki popravljeni** (`8004e81`, `a9521ed`) — ikona obvestila je na nekaterih
  napravah manjkala (config-split / density), zato se opomnik ni prikazal. To je
  napaka, ki so jo testerji občutili. Odpravljena.
- **Teme** (`3e2642a`) — 6 barvnih palet + zaslon **Videz** (svetli/temni način + paleta).

Manjše:
- Pametnejši vrstni red rastlin po tipu opravila/območja (`34504f2`, `e46a849`).
- Abecedno (locale-aware) sortiranje seznamov rastlin (`a660fb4`).
- Bolj viden vstop brez računa / offline (`8dfac76`).
- Popravek podvojenega privzetega vrta — posejan enkrat na račun, ne na napravo (`3384760`).
- Sentry release tag iz package info (`d83a872`, interno).

## 2. Email (SL, kot poslano)

**Zadeva:** Nova posodobitev Tendaska je na voljo

```
Pozdravljen/a,

v zadnji posodobitvi Tendaska sta dve glavni spremembi:

- Opomniki. Na nekaterih napravah se obvestilo ni prikazalo, čeprav je bil
  opomnik nastavljen. Napaka je odpravljena — opomniki spet delujejo zanesljivo.

- Teme. Pod Videz v nastavitvah lahko izbereš med 6 barvnimi paletami ter
  svetlim ali temnim načinom.

Manjše izboljšave: seznami rastlin so urejeni po abecedi, najbolj smiselne
rastline se ponudijo prve glede na izbrano opravilo, vstop brez računa (offline)
je bolj viden.

Posodobitve lahko preneseš iz trgovine Play:
https://play.google.com/store/apps/details?id=app.tendask

Če opaziš da kaj ne deluje, nam lahko sporočiš z odgovorom na ta mail.

Tendask
```

## 3. Prejemniki

- Vir: živ PROD projekt (`auth.users` + `profile.lang`), read-only izvoz.
- Skripti (v `tmp/`, **gitignored — vsebujejo PII, nikoli v repo**):
  - `tmp/export_tester_emails.py` — izvoz vseh prijavljenih (email, lang, datumi) → `tmp/tester_emails.csv`.
  - `tmp/make_recipients.py` — počisti seznam v `tmp/recipients_sl.csv`.
- **36 prijavljenih** skupaj; izločeni 4 (test + lastni računi: `test@example.com`,
  `exogenus@gmail.com`, `exogenus.iot@gmail.com`, `gorazd@spletnakoda.si`) →
  **32 pravih testerjev**.
- Opomba: `profile.lang` je nezanesljiv (večinoma `en` = device-locale default);
  testerji so dejansko SL → poslana samo SL verzija.

## 4. Pošiljanje — nauki

- Poslano iz **Tendask &lt;info@tendask.com&gt;** (Gmail "Pošlji kot", routan prek
  `smtp.resend.com`, port 465 SSL; domena potrjena v Resendu). Deluje.
- **BCC (Skp)** za vse prejemnike — zasebnost (ne vidijo naslovov drug drugega), GDPR.
- **Gotcha:** Gmail ne pusti pošiljati **sam sebi** — `info@tendask.com` →
  `exogenus@gmail.com` (isti Google račun) se zavrne ("Mail Delivery Subsystem").
  Zato je `exogenus@gmail.com` izločen iz seznama; v polje **Za** daj
  `gorazd@spletnakoda.si` ali `gorazd@hooraystudios.com`.
- Za nizko tveganje spama: en sam link, čist tekst, po želji v 2 manjših serijah.
