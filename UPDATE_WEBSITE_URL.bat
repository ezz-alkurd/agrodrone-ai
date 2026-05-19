@echo off
title AgroDrone AI — Wire Render URL into Website
color 0E
cd /d "%~dp0"

echo.
echo  ============================================================
echo   AgroDrone AI  ^|  Update Website with Render URL
echo   Run this after Render gives you a deployment URL
echo  ============================================================
echo.
echo  After Render deploys, your URL looks like:
echo    https://agrodrone-api.onrender.com
echo.
set /p RENDER_URL=  Paste your Render URL here:

if "%RENDER_URL%"=="" (
    echo  [ERROR] No URL entered. Run the script again.
    pause & exit /b 1
)

:: Remove trailing slash if present
if "%RENDER_URL:~-1%"=="/" set RENDER_URL=%RENDER_URL:~0,-1%

echo.
echo  [1/3] Patching cloudflare_pages\index.html...

:: Use PowerShell to do the string replacement (handles special chars safely)
powershell -NoProfile -Command ^
  "(Get-Content 'cloudflare_pages\index.html' -Raw) -replace ^
   '// window\.AGRODRONE_API_BASE = .+\n    window\.AGRODRONE_API_BASE = .+', ^
   'window.AGRODRONE_API_BASE = ''%RENDER_URL%'';' ^
  | Set-Content 'cloudflare_pages\index.html'"

:: Simpler targeted replacement
powershell -NoProfile -Command ^
  "$content = Get-Content 'cloudflare_pages\index.html' -Raw;" ^
  "$content = $content -replace 'window\.AGRODRONE_API_BASE = '''';', 'window.AGRODRONE_API_BASE = ''%RENDER_URL%'';';" ^
  "Set-Content 'cloudflare_pages\index.html' $content"

echo  [1/3] index.html updated with: %RENDER_URL%

:: ── Commit the change ─────────────────────────────────────────
echo  [2/3] Committing URL update...
if exist ".git\index.lock" del /f ".git\index.lock"
git add cloudflare_pages\index.html
git commit -m "Wire Render URL %RENDER_URL% into website"
echo  [2/3] Committed

:: ── Push to GitHub so Cloudflare Pages auto-redeploys ─────────
echo  [3/3] Pushing to GitHub (Cloudflare Pages will auto-redeploy)...
git push origin main
if errorlevel 1 (
    echo  [WARN] Push failed — manually push or redeploy Cloudflare Pages.
)
echo  [3/3] Done

echo.
echo  ============================================================
echo   All done! Website now points to: %RENDER_URL%
echo.
echo   Test it:  %RENDER_URL%/api/health
echo.
echo   Share the Cloudflare Pages URL as your event QR code.
echo   Attendees phone in -> pick photo -> Analyze -> AI results!
echo  ============================================================
echo.
pause
