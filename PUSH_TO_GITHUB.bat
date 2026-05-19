@echo off
title AgroDrone AI — Push to GitHub
color 0B
cd /d "%~dp0"

echo.
echo  ============================================================
echo   AgroDrone AI  ^|  Push to GitHub
echo   Run this ONCE to upload the project so Render can deploy it
echo  ============================================================
echo.

:: ── Check git ─────────────────────────────────────────────────
git --version >nul 2>&1
if errorlevel 1 (
    echo  [ERROR] Git is not installed. Download from https://git-scm.com
    pause & exit /b 1
)

:: ── Configure identity ────────────────────────────────────────
git config user.email "izzoalkurd@gmail.com"
git config user.name "ezzeldeen"

:: ── Get GitHub repo URL ───────────────────────────────────────
echo  Step 1: Create a NEW repo on GitHub (github.com/new)
echo          Name it: agrodrone-ai
echo          Set it to PUBLIC
echo          Do NOT tick "Add README"
echo.
set /p REPO_URL=  Paste your GitHub repo URL here (e.g. https://github.com/yourname/agrodrone-ai):

if "%REPO_URL%"=="" (
    echo  [ERROR] No URL entered. Run the script again.
    pause & exit /b 1
)

:: ── Remove stale lock if present ──────────────────────────────
if exist ".git\index.lock" del /f ".git\index.lock"

:: ── Stage everything ──────────────────────────────────────────
echo.
echo  [1/4] Staging files...
git add .gitignore requirements.txt render.yaml EVENT_LAUNCH.bat PUSH_TO_GITHUB.bat UPDATE_WEBSITE_URL.bat
git add deploy\agrodrone_api.py
git add cloudflare_pages\
git add "grad project fire base and flutter\grad prop\yolo\vision.py"
git add "grad project fire base and flutter\grad prop\yolo\models\detect.py"
git add "grad project fire base and flutter\grad prop\yolo\models\best.pt"
git add "grad project fire base and flutter\grad prop\yolo\models\plant_disease_best2.pt"
git add "grad project fire base and flutter\grad prop\yolo\best.pt"
git add agri_drone_ai_final\lib\
git add agri_drone_ai_final\pubspec.yaml
git add agri_drone_ai_final\android\
echo  [1/4] Staging done

:: ── Commit ────────────────────────────────────────────────────
echo  [2/4] Committing...
git commit -m "Initial commit — AgroDrone AI with new models + cloud deployment"
if errorlevel 1 (
    echo  [WARN] Nothing new to commit, continuing with push...
)
echo  [2/4] Commit done

:: ── Set remote and push ───────────────────────────────────────
echo  [3/4] Setting GitHub remote...
git remote remove origin 2>nul
git remote add origin %REPO_URL%
git branch -M main

echo  [4/4] Pushing to GitHub (this may ask for your GitHub login)...
git push -u origin main
if errorlevel 1 (
    echo.
    echo  [ERROR] Push failed. Common fixes:
    echo    - Make sure you created the repo on GitHub first
    echo    - If asked for password, use a GitHub Personal Access Token
    echo      (github.com ^> Settings ^> Developer settings ^> Personal access tokens)
    pause & exit /b 1
)

echo.
echo  ============================================================
echo   SUCCESS! Project is on GitHub at: %REPO_URL%
echo.
echo   NEXT STEP — Deploy to Render (takes 2 minutes):
echo    1. Go to  https://render.com  and sign in with GitHub
echo    2. Click  New +  then  Web Service
echo    3. Choose your  agrodrone-ai  repo
echo    4. Render reads render.yaml automatically — click Deploy
echo    5. Wait ~2 min — copy the URL it gives you
echo    6. Run  UPDATE_WEBSITE_URL.bat  and paste that URL
echo  ============================================================
echo.
pause
