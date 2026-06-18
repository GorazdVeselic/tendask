# On-device preverba GDPR (9.7) — izvoz + izbris računa

> **Status: čaka priklopljeno napravo** (USB, SM A536B / RZCT70XGC5P) + testni račun.
> `adb devices` trenutno prazen. Ta dokument = točni koraki, ko napravo priklopiš (nekaj korakov je
> interaktivnih — share sheet, potrditveni dialog — zato jih opraviš ti, jaz pomagam + preverim oblak).

## Priprava

1. Priklopi napravo (USB debugging). Preveri: `adb devices` → naprava »device«.
2. Namesti build: `! deploy.bat hot` (debug) ali release APK iz Play internega testa.
3. **Prijavi se** (email OTP ali Google) in ustvari nekaj podatkov (par opravil, območje, rastlino) —
   da je kaj za izvoziti/izbrisati, lokalno IN v oblaku (počakaj na push, ~sekunde).

## A) Izvoz podatkov (share sheet)

1. **Nastavitve → »Export data (GDPR)«** → odpre se sistemski **share sheet**.
2. Shrani JSON (npr. v Files ali pošlji sebi).
3. **Preveri vsebino JSON:**
   - ✅ vsebuje: `profile`, `area`, `user_plant`, `task` (+ `task_subject`/`reminder`/`note`/
     `supply`/`recipe`/`task_supply`).
   - ✅ **NE vsebuje** surovih koordinat (od FR-8 se sploh ne hranijo — tabela `device_location`
     odstranjena; le H3 celice v `profile`) niti internega `sync_status`.
4. Pri gostu (brez prijave): izvoz dela lokalno (ni oblačnega računa).

## B) Izbris računa (RPC počisti oblak)

1. Zapomni si **email / user_id** prijavljenega računa.
2. **(PRED)** preveri, da vrstice obstajajo v oblaku — `tmp/sync_verify.py` (pooler, geslo iz `.env`)
   ali Supabase Studio: `select count(*) from task where user_id = '<uid>'` > 0.
3. V app: **Nastavitve → »Delete account and all data«** → potrdi rdeči dialog.
4. App te **odjavi → onboarding**.
5. **(PO)** preveri oblak:
   - ✅ vrstice za `<uid>` v `task`/`area`/`user_plant`/`profile` **izbrisane** (cascade iz RPC
     `delete_account`).
   - ✅ uporabnik **odstranjen iz `auth.users`** (`select * from auth.users where id='<uid>'` → 0).
   - ✅ lokalna drift baza počiščena (sveža onboarding seja; katalog ostane).

## Pričakovano

- Izvoz: berljiv JSON, brez koordinat. ✅
- Izbris: oblak + lokalno počiščena, `auth.users` brez računa, nazaj na onboarding. ✅

> Ko bo naprava priklopljena, reci — greva skozi A in B, jaz med tem preverim oblačno stanje
> (pred/po) prek pooler skripte.
