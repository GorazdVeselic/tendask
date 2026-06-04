@echo off
REM ============================================================
REM  Tendask - deploy na povezan Android telefon (USB)
REM  Pogoj: na telefonu vklopi "Razvijalske moznosti" + "USB
REM  razhroscevanje", priklopi kabel in potrdi poziv na telefonu.
REM
REM  Uporaba:
REM    deploy.bat          -> RELEASE build (prava preverba: offline, hitrost)
REM    deploy.bat hot      -> DEBUG build s hot reload (r / R v terminalu)
REM  (sopomenki za "hot": "dev", "debug")
REM ============================================================
setlocal
cd /d "%~dp0"

set MODE=release
if /i "%~1"=="hot"   set MODE=dev
if /i "%~1"=="dev"   set MODE=dev
if /i "%~1"=="debug" set MODE=dev

echo === Tendask deploy [%MODE%] ===
echo.
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
call flutter run %RUNARGS%
set RC=%ERRORLEVEL%

if not "%RC%"=="0" (
  echo.
  echo NAPAKA pri zagonu ^(koda %RC%^).
  echo Preveri: USB razhroscevanje vklopljeno, naprava potrjena, kabel/vrata.
  echo Seznam naprav: flutter devices
)

endlocal & exit /b %RC%
