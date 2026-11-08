@echo off
chcp 65001 >nul
setlocal EnableExtensions DisableDelayedExpansion
title Qoder 调试端口启动

rem 双击 : 带 --remote-debugging-port 启动 Qoder（路径从 state.ini 现读，升级不失效）
rem check: 只解析路径，不启动

set "PORT=9222"
set "STATE=%LOCALAPPDATA%\Qoder CN\Qoder CN Launcher\state.ini"

if not exist "%STATE%" goto no_state

set "INSTALL_DIR="
set "APP_EXE="
for /f "usebackq tokens=1,* delims==" %%A in ("%STATE%") do (
  if /i "%%A"=="installDir" set "INSTALL_DIR=%%B"
  if /i "%%A"=="appExecutable" set "APP_EXE=%%B"
)

if not defined INSTALL_DIR goto no_state
if not defined APP_EXE set "APP_EXE=Qoder CN.exe"
set "EXE=%INSTALL_DIR%\%APP_EXE%"
if not exist "%EXE%" goto no_exe

echo   installDir : %INSTALL_DIR%
echo   app        : %APP_EXE%
echo   exe        : %EXE%
echo   port       : %PORT%
echo.

if /i "%~1"=="check" (
  echo   [check] 只做解析，不启动。
  exit /b 0
)

tasklist /fi "IMAGENAME eq Qoder CN.exe" /nh 2>nul | find /i "Qoder CN.exe" >nul
if not errorlevel 1 goto already_running

set "ELECTRON_RUN_AS_NODE="
echo   正在启动 ...
start "" "%EXE%" --remote-debugging-port=%PORT%

set /a tries=0
:wait
ping -n 2 127.0.0.1 >nul
set /a tries+=1
netstat -ano | findstr /c:":%PORT% " | findstr /i "LISTENING" >nul
if not errorlevel 1 goto ready
if %tries% lss 20 goto wait

echo   [x] 约 40 秒内 %PORT% 仍未监听：Qoder 起来了，但调试端口没生效。
echo       处理：完全退出 Qoder，再跑一次本脚本。
pause
exit /b 3

:ready
echo.
echo   [ok] 已带调试端口启动
echo        CDP: http://127.0.0.1:%PORT%/json/version
netstat -ano | findstr /c:":%PORT% " | findstr /i "LISTENING"
echo.
echo   提醒: 用完请完全退出 Qoder，端口随进程一起关闭。
ping -n 6 127.0.0.1 >nul
exit /b 0

:already_running
echo   [!] Qoder 已经在运行。
echo       它有单实例锁，新进程会直接退出，调试端口不会生效。
echo       请先完全退出 Qoder（含托盘图标），再运行本脚本。
pause
exit /b 2

:no_state
echo   [x] 找不到 state.ini 或其中没有 installDir：
echo       %STATE%
pause
exit /b 1

:no_exe
echo   [x] 解析出的可执行文件不存在：
echo       %EXE%
echo       可能是升级后 state.ini 没刷新，先正常打开一次 Qoder 再试。
pause
exit /b 4
