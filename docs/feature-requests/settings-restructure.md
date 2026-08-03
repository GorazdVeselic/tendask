# FR-26: Preureditev zaslona Nastavitve

- **Status:** ideja / želja (ni spec ravni, neimplementirano)
- **Datum:** 2026-08-03
- **Področja:** presentation (`settings_screen.dart`), komponentni katalog (`SectionLabel`), ikone
- **Povezave:** `docs/screen-map.md` §2.1 (struktura Nastavitev), `CLAUDE.md` §komponentni katalog,
  `docs/ui-katalog.md`
- **Izvor:** opažanje lastnika 3. 8. 2026 ob pogledu na napravo (staging build koraka T6.5, ko je
  kartica ✦ Tendask+ prvič stala v Nastavitvah).

---

## 1. Želja

Trije neodvisni popravki istega zaslona:

1. **Profil dobi sekcijo in stoji ob kartici ✦ Tendask+.** Danes je profilna kartica edina brez
   sekcijske oznake in visi na vrhu; predlog je, da pade pod **RAČUN & PODATKI** in se postavi
   **nad ali pod** kartico ✦ Tendask+ (par: kdo si + kaj imaš).
2. **✦ Tendask+ dobi sekcijsko oznako** kot vsaka druga sekcija (`SectionLabel`) — in ker ime nosi
   oznaka, ga **kartica sama ne ponavlja** več: ostanejo znak, pripis (»Napredne funkcije za
   načrtovanje vrta.«) in ›.
3. **Vrstica lokacije dobi pravo ikono lokacije** (obris bucike s krogcem, `kIconPlaceOutlined` /
   `kIconLocationOnOutlined`) namesto emojija 📍, ki se na Samsungu izriše kot rdeča risalna žebljica.

## 2. Zakaj

Zaslon je zrasel po plasteh in ima danes tri različne ravni: kartico brez oznake (profil), kartice z
oznako (lokacija, jezik, videz, obvestila, račun) in eno poudarjeno kartico brez oznake (Tendask+).
Enotna raven bere hitreje, sekcijska oznaka pa je edini vzorec, ki ga zaslon že uporablja povsod
drugod.

## 3. Odprta vprašanja (odloči lastnik, preden se karkoli piše)

- **Kam pristane par profil + Tendask+:** ostane na vrhu pod novo oznako, ali gre res dol v
  **RAČUN & PODATKI** (kjer so izvoz, odjava, izbris)? Prva varianta obdrži Tendask+ visoko
  (screen-map §2.1 ga postavlja »takoj pod profilom, pred LOKACIJA«), druga združi vse o računu.
  Vrstni red znotraj para (profil nad ali pod Tendask+) je del iste odločitve.
- **`SectionLabel` ne zna znaka.** Oznaka je danes čist velik tekst; »✦ TENDASK+« bi terjal ali
  ikono v oznaki (sprememba skupnega gradnika, ki ga uporablja cel app) ali oznako brez znaka, pri
  čemer znak ostane v kartici. Poimenovanje »✦ Tendask+, ikona vedno spredaj« je fiksirano v
  screen-map §4 — če oznaka znaka ne nosi, je treba to pravilo tam popraviti.
- **Emoji ali Material ikone v vrsticah?** Vrstice Nastavitev so danes dosledno emoji (📍 🎨 🔔).
  Zamenjava ene same v Material ikono naredi zaslon mešan; ali gredo **vse** vrstice na ikone (kot
  že kartica ✦ Tendask+, ki riše `kIconAutoAwesome`), ali dobi pravo ikono le lokacija? Po pravilu
  »sprememba vzorca gre kot en sveženj« (CLAUDE.md) je to eno vprašanje, ne tri.

## 4. Obseg

Majhen in **samo presentation**: brez sheme, brez sync-a, brez novih i18n ključev (ime izdelka se ne
prevaja; obstoječi ključi sekcij se lahko ponovno uporabijo). Zraven spadata **posodobitev
`screen-map.md` §2.1** in matrika postavitve (`settings` in `settings/plus-card` že obstajata — nova
razporeditev ju mora prestati pri 320 px × 1,3 in nemščini).

> Opomba o vrstnem redu: dokler `kTendaskPlusEnabled` ni prižgan, kartice ✦ Tendask+ ni videti, zato
> preureditev nima smisla pred prižigom (T7) — sicer se dvakrat presoja zaslon, ki ga uporabnik še ne
> vidi takega, kot bo.
