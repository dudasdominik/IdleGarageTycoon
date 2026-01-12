@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

rem ====== LOG ======
set "LOGFILE=%~dp0run-prod.log"
echo ================================ > "%LOGFILE%"
echo Run started: %DATE% %TIME% >> "%LOGFILE%"
echo Working dir: %CD% >> "%LOGFILE%"
echo ================================ >> "%LOGFILE%"

set "STEP="
title run-prod

if not exist ".env" (
  echo [ERROR] Nincs .env a rootban. Keszitsd el az .env.example alapjan.
  echo [ERROR] Nincs .env a rootban. >> "%LOGFILE%"
  pause
  exit /b 1
)

where docker >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Docker nincs a PATH-ban.
  echo [ERROR] Docker nincs a PATH-ban. >> "%LOGFILE%"
  pause
  exit /b 1
)

echo.
echo LOG: "%LOGFILE%"
echo.

rem ====== STEP 1 ======
set "STEP=Build images"
echo === %STEP% ===
echo === %STEP% === >> "%LOGFILE%"
docker compose build >> "%LOGFILE%" 2>&1
if errorlevel 1 goto FAIL

rem ====== STEP 2 ======
set "STEP=Start DB"
echo === %STEP% ===
echo === %STEP% === >> "%LOGFILE%"
docker compose up -d db >> "%LOGFILE%" 2>&1
if errorlevel 1 goto FAIL

rem ====== STEP 3 ======
set "STEP=Run EF migrations"
echo === %STEP% ===
echo === %STEP% === >> "%LOGFILE%"

rem Load .env so we can build the docker-network connection string
for /f "usebackq tokens=1,* delims==" %%A in (".env") do (
  echo %%A| findstr /b "#" >nul
  if errorlevel 1 (
    set "%%A=%%B"
  )
)

set "DB_CONN=Host=db;Port=5432;Database=%PG_DATABASE%;Username=%PG_USER%;Password=%PG_PASSWORD%"
echo Using DB_CONN=%DB_CONN% >> "%LOGFILE%"

docker compose run --rm -e ConnectionStrings__DefaultConnection="%DB_CONN%" migrate >> "%LOGFILE%" 2>&1
if errorlevel 1 goto FAIL

rem ====== STEP 4 ======
set "STEP=Start API + WEB"
echo === %STEP% ===
echo === %STEP% === >> "%LOGFILE%"
docker compose up -d api web >> "%LOGFILE%" 2>&1
if errorlevel 1 goto FAIL

rem ====== STEP 5 ======
set "STEP=Status"
echo === %STEP% ===
echo === %STEP% === >> "%LOGFILE%"
docker compose ps >> "%LOGFILE%" 2>&1
if errorlevel 1 goto FAIL

echo.
echo ✅ Kesz. Nezd meg: docker compose ps
echo ✅ Kesz. >> "%LOGFILE%"
echo Run finished: %DATE% %TIME% >> "%LOGFILE%"
pause
exit /b 0

:FAIL
echo.
echo ❌ Hiba a lepesnel: %STEP%
echo ❌ Hiba a lepesnel: %STEP% >> "%LOGFILE%"
echo --- Last 80 log lines ---
powershell -NoProfile -Command "Get-Content -Path '%LOGFILE%' -Tail 80" 2>nul
echo.
echo Teljes log: "%LOGFILE%"
pause
exit /b 1
