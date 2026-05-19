@echo off
title AgroDrone AI — Event Demo Launcher
color 0A
cd /d "%~dp0"

echo.
echo  ============================================================
echo   AgroDrone AI  ^|  Event Demo Launcher
echo   Graduation Project — Agricultural Drone AI System
echo  ============================================================
echo.

:: ── Check Python ───────────────────────────────────────────────
python --version >nul 2>&1
if errorlevel 1 (
    echo  [ERROR] Python not found. Please install Python 3.10+ and try again.
    pause & exit /b 1
)

:: ── Install dependencies if needed ────────────────────────────
echo  [1/4] Checking Python packages...
pip show ultralytics >nul 2>&1
if errorlevel 1 (
    echo  [1/4] Installing packages (first-time only, ~2 min)...
    pip install ultralytics opencv-python-headless numpy --quiet
    if errorlevel 1 (
        echo  [ERROR] Package install failed. Check your internet connection.
        pause & exit /b 1
    )
)
echo  [1/4] Packages OK

:: ── Check model files ─────────────────────────────────────────
set MODELS_DIR=%~dp0grad project fire base and flutter\grad prop\yolo\models
if not exist "%MODELS_DIR%\best.pt" (
    echo  [ERROR] Fire model not found: %MODELS_DIR%\best.pt
    pause & exit /b 1
)
if not exist "%MODELS_DIR%\plant_disease_best2.pt" (
    echo  [ERROR] Disease model not found: %MODELS_DIR%\plant_disease_best2.pt
    pause & exit /b 1
)
echo  [2/4] Both model files found

:: ── Check cloudflared ─────────────────────────────────────────
set CF_EXE=C:\Program Files (x86)\cloudflared\cloudflared.exe
if not exist "%CF_EXE%" (
    echo  [WARN] cloudflared not found at default path.
    echo         Downloading cloudflared...
    mkdir "%~dp0deploy\downloads" 2>nul
    curl -L -o "%~dp0deploy\downloads\cloudflared.exe" ^
      "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe"
    set CF_EXE=%~dp0deploy\downloads\cloudflared.exe
)
echo  [3/4] cloudflared ready

:: ── Start the API server ────────────────────────────────────────
echo  [4/4] Starting AI model API server on port 8767...
set AGRODRONE_API_HOST=127.0.0.1
set AGRODRONE_API_PORT=8767
start "AgroDrone API" /min python -B "%~dp0deploy\agrodrone_api.py"

:: Give the server a moment to load the models
echo.
echo  Waiting for models to load (this takes ~15 seconds on first run)...
timeout /t 15 /nobreak >nul

:: ── Open the Cloudflare tunnel ─────────────────────────────────
echo.
echo  ============================================================
echo   STARTING PUBLIC TUNNEL — copy the URL below!
echo  ============================================================
echo.
echo  The line that says:
echo     +---... | https://xxxx.trycloudflare.com
echo  is your EVENT URL. Share it or display it as a QR code.
echo.
echo  Attendees open that URL on their phone and can:
echo    - Tap "Open Camera" to take a photo
echo    - Select Fire or Disease model
echo    - Tap "Analyze Image" to see AI results
echo.
echo  Keep this window OPEN for the whole event.
echo  Press Ctrl+C to stop when the event ends.
echo  ============================================================
echo.

"%CF_EXE%" tunnel --url http://127.0.0.1:8767 --no-autoupdate

pause
