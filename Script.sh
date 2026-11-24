I'm building Playwright (TypeScript) UI automation for the Sanctioned Provider (SPS) web app.
This is a RECON step only. Do NOT scaffold the framework yet. Do NOT click Save, Delete,
or anything that changes data. Report back on each item:

1. Toolchain
   - node and npm versions; output of `npm config get registry`
   - Does `npm view @playwright/test version` work (public npm reachable, or proxy/JFrog needed)?
   - Is Microsoft Edge installed (version/path)? We'll use channel 'msedge', so do NOT run
     `npx playwright install`.
   - Installed SQL Server ODBC drivers (PowerShell: Get-OdbcDriver | ? Name -like '*SQL*').

2. Scratch setup in C:\Users\cs221954\repos\sps-recon:
   npm init -y; npm i -D @playwright/test typescript; npm i mssql msnodesqlv8

3. DB check: tiny node script, Windows (trusted) auth via msnodesqlv8, to
   crt_72.sql.caresource.corp\CRT_72, running:
   SELECT TOP 1 * FROM HPTSSPSDB.External.vw_MasterSanctionedList_Advanced
   Report success or the exact error.

4. App + login (IMPORTANT: never ask me for my password, never type or store credentials):
   - Launch Edge HEADED (channel 'msedge') and open http://daycrtprvweb11a:23020/
   - Stop at the login screen. Snapshot it to recon/login.md and tell me what kind it is:
     an HTML form (list the field labels/ids and the submit button), an SSO redirect
     (Okta/Entra/ADFS: give the URL it redirects to), or a browser-native Windows popup.
     Is there MFA?
   - Then call page.pause() and let ME log in manually in that browser window.
   - After I'm in, continue with item 5 in the same session.

5. Page structure, for Home, Search, Add, Audit, Reports (navigate via the left menu):
   - Save `await page.locator('body').ariaSnapshot()` to recon/<page>.md
   - List every form control: label, role, id/name, data-testid (if any)
   - Search: run ONE read-only search (Type NPI, value 1023511839). Capture the results
     table structure. Click the Value hyperlink, snapshot the popup, then CLOSE it
     WITHOUT clicking Delete.
   - Reports: list the report links. Don't download yet.
   - Is it Blazor (look for _framework/blazor.*.js / SignalR)? Are element IDs stable or generated?

6. Give me a summary plus the recon/*.md files.
