@echo off
rem ============================================================
rem   Portal AutoLogin - run once manually
rem   The console output is in Chinese, produced by AutoLogin.ps1
rem ============================================================
echo.
echo  ===== Portal AutoLogin : manual run =====
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0AutoLogin.ps1"
echo.
echo  ExitCode = %ERRORLEVEL%
echo  Log file = %~dp0AutoLogin.log
echo.
pause
