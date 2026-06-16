@echo off
REM ============================================================
REM  Tendask - deploy na povezan Android telefon (USB)
REM  Pogoj: na telefonu vklopi "Razvijalske moznosti" + "USB
REM  razhroscevanje", priklopi kabel in potrdi poziv na telefonu.
REM
REM  Uporaba (MODE + ENV):
REM    deploy.bat            -> RELEASE  + PRODUCTION  (Play preverba)
REM    deploy.bat hot        -> DEBUG    + STAGING     (privzeto za razvoj)
REM    deploy.bat hot prod   -> DEBUG    + PRODUCTION  (debug proti produkciji)
REM    deploy.bat staging    -> RELEASE  + STAGING     (GLASNO opozorilo!)
REM  (sopomenki za "hot": "dev", "debug")
REM
REM  Pravilo: razvoj cilja STAGING, Play-release cilja PRODUKCIJO.
REM  ENV doloca, katera dart_defines datoteka se uporabi.
REM ============================================================
setlocal
cd /d "%~dp0"

REM --- MODE (dev/release) + ENV (staging/production) ---
REM  "set VAR=val" oblika namenoma kvotirana, da v parih (...) ne ujame
REM  presledka pred ")" v vrednost (klasicna batch past).
set "MODE=release"
set "ENV=production"

if /i "%~1"=="hot"     ( set "MODE=dev" & set "ENV=staging" )
if /i "%~1"=="dev"     ( set "MODE=dev" & set "ENV=staging" )
if /i "%~1"=="debug"   ( set "MODE=dev" & set "ENV=staging" )
if /i "%~1"=="staging" ( set "MODE=release" & set "ENV=staging" )

REM Debug override: drugi argument lahko izrecno preklopi okolje.
if "%MODE%"=="dev" if /i "%~2"=="prod"       set "ENV=production"
if "%MODE%"=="dev" if /i "%~2"=="production" set "ENV=production"
if "%MODE%"=="dev" if /i "%~2"=="staging"    set "ENV=staging"

REM --- Izbira dart_defines datoteke glede na ENV ---
if "%ENV%"=="staging" (
  set "DEFINES_FILE=dart_defines.staging.json"
) else (
  set "DEFINES_FILE=dart_defines.json"
)

set DEFINES=
if exist "%~dp0%DEFINES_FILE%" (
  set DEFINES=--dart-define-from-file="%~dp0%DEFINES_FILE%"
) else (
  echo OPOZORILO: %DEFINES_FILE% ne obstaja - Supabase NE bo konfiguriran.
  echo Kopiraj predlogo -^> %DEFINES_FILE% in vnesi kljuce.
  echo.
)

echo ============================================================
echo === Tendask deploy  ^|  MODE: %MODE%  ^|  ENV: %ENV%
echo === defines: %DEFINES_FILE%
echo ============================================================
echo.

REM Varovalo: RELEASE proti STAGINGU se NE sme objaviti na Play.
if "%MODE%"=="release" if "%ENV%"=="staging" (
  echo ###########################################################
  echo #  POZOR: RELEASE build proti STAGINGU.                    #
  echo #  Ta APK NI za Play Store - cilja staging backend!        #
  echo #  Za Play uporabi:  deploy.bat   ^(release + production^)   #
  echo ###########################################################
  echo.
)

echo Povezane naprave:
call flutter devices
echo.

if "%MODE%"=="dev" (
  set RUNARGS=
  echo Gradim DEBUG build s hot reload in namescam na napravo...
  echo V tem terminalu: r = hot reload, R = hot restart, q = izhod.
) else (
  set RUNARGS=--release
  echo Gradim RELEASE build in namescam na napravo ^(to lahko traja minuto^)...
  echo ^(Ctrl+C odklopi konzolo; aplikacija ostane namescena in tece na telefonu.^)
)
echo.

REM flutter run = zgradi + namesti + zazene + strani dnevnik (za rocno preverbo).
REM Ce je priklopljenih vec naprav, te flutter vprasa, katero izbrati.
call flutter run %RUNARGS% %DEFINES%
set RC=%ERRORLEVEL%

if not "%RC%"=="0" (
  echo.
  echo NAPAKA pri zagonu ^(koda %RC%^).
  echo Preveri: USB razhroscevanje vklopljeno, naprava potrjena, kabel/vrata.
  echo Seznam naprav: flutter devices
)

endlocal & exit /b %RC%
