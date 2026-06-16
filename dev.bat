@echo off
REM ============================================================
REM  Tendask - razvojni zagon: DEBUG build s hot reload (privzeto STAGING).
REM  Dvoklik (ali "dev.bat" v terminalu) -> flutter run v debug proti
REM  staging backendu, kjer v tem terminalu delujejo:
REM    r = hot reload, R = hot restart, q = izhod, h = pomoc
REM  "dev.bat prod" -> debug proti PRODUKCIJI.
REM  Za PRAVO preverbo (release: offline, hitrost) uporabi deploy.bat.
REM ============================================================
call "%~dp0deploy.bat" hot %*
