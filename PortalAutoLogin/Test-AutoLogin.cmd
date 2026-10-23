@echo off
rem ============================================================
rem   Self test: logout first, then let AutoLogin log back in.
rem   Use this to verify the program really works while OFFLINE.
rem   (Your network will drop for a few seconds on purpose.)
rem ============================================================
title Portal AutoLogin - self test
echo.
echo  ============================================================
echo   STEP 1/2 : logging out  (network will drop on purpose)
echo  ============================================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0AutoLogin.ps1" -Logout -NoBrowser
echo.
echo  ============================================================
echo   STEP 2/2 : auto login  (this is what happens at boot)
echo  ============================================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0AutoLogin.ps1"
echo.
echo  ExitCode = %ERRORLEVEL%   (0 = success)
echo  Log file = %~dp0AutoLogin.log
echo.
pause
