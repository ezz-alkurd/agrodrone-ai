AgroDrone AI Cloudflare Pages deploy

Prepared site folder:
cloudflare_pages

Expected free URL:
https://agrodrone-ai.pages.dev

What is included:
- index.html copied from deploy/agrodrone_ai_complete.html
- assets folder
- API connection field inside the Live Demo section

Important:
The website can be hosted on Cloudflare Pages for free, but Cloudflare requires
your account authentication before the project can be created online.

To deploy:
1. Create a Cloudflare API token with Cloudflare Pages edit access.
2. Double-click cloudflare_pages/DEPLOY_TO_CLOUDFLARE.bat
3. Paste the token when asked.
4. Paste your Cloudflare Account ID if Wrangler asks for it or if you have more
   than one Cloudflare account. Otherwise press Enter.
5. Wait for Wrangler to print the pages.dev URL.

If the name agrodrone-ai is already taken, edit DEPLOY_TO_CLOUDFLARE.bat and
replace:
--project-name agrodrone-ai
with another name, for example:
--project-name agrodrone-ai-demo

The AI model API will work only while the local API server and Cloudflare tunnel
are running. The easiest phone-testing path is:
1. Double-click deploy/START_PUBLIC_DEMO.bat.
2. Copy the trycloudflare.com URL printed by cloudflared.
3. Open that URL directly on the phone.

If you use https://agrodrone-ai.pages.dev instead, paste the current
trycloudflare.com URL into the Live Demo API connection field and press Connect.
