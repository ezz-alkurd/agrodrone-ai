@echo off
setlocal

cd /d "%~dp0\.."

echo AgroDrone AI Cloudflare Pages deploy
echo Project name: agrodrone-ai
echo Target URL: https://agrodrone-ai.pages.dev
echo.
echo Paste a Cloudflare API token with Cloudflare Pages edit access.
echo The token is used only for this command window.
echo.
set /p CLOUDFLARE_API_TOKEN=Cloudflare API token: 
set /p CLOUDFLARE_ACCOUNT_ID=Cloudflare Account ID (press Enter if not needed): 

if "%CLOUDFLARE_API_TOKEN%"=="" (
  echo No token entered. Deployment cancelled.
  exit /b 1
)

npx.cmd --yes wrangler@latest pages deploy ".\cloudflare_pages" --project-name agrodrone-ai --branch main --commit-dirty=true

endlocal
