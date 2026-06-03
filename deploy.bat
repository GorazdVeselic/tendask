@echo off
REM ============================================================
REM  Tendask - deploy na povezan Android telefon (USB)
REM  Pogoj: na telefonu vklopi "Razvijalske moznosti" + "USB
REM  razhroscevanje", priklopi kabel in potrdi poziv na telefonu.
REM  Uporaba: zazeni "deploy.bat" iz korena projekta.
REM ============================================================
setlocal
cd /d "%~dp0"

echo === Tendask deploy ===
echo.
echo Povezane naprave:
call flutter devices
echo.

echo Gradim release in namescam na napravo (to lahko traja minuto)...
echo (Ctrl+C odklopi konzolo; aplikacija ostane namescena in tece na telefonu.)
echo.

REM flutter run = zgradi + namesti + zazene + strani dnevnik (za rocno preverbo).
REM Ce je priklopljenih vec naprav, te flutter vprasa, katero izbrati.
call flutter run --release
set RC=%ERRORLEVEL%

if not "%RC%"=="0" (
  echo.
  echo NAPAKA pri zagonu ^(koda %RC%^).
  echo Preveri: USB razhroscevanje vklopljeno, naprava potrjena, kabel/vrata.
  echo Seznam naprav: flutter devices
)

endlocal & exit /b %RC%
