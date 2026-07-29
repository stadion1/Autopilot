# Bilanalys — Deployment Guide

## Översikt

```
GitHub
  ├── / (Next.js app)          → Vercel
  └── /scraper-service/        → Railway
```

Båda deployar automatiskt när du pushar till GitHub.

---

## Del 1 — Supabase (databas)

1. Gå till **supabase.com** → New project
2. Välj region: **eu-north-1** (Stockholm)
3. Spara databaselösenordet
4. Gå till **SQL Editor** → klistra in och kör `data/seed.sql`
5. Notera dina nycklar under **Settings → API**:
   - `Project URL` → `NEXT_PUBLIC_SUPABASE_URL`
   - `anon public` → `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `service_role` → `SUPABASE_SERVICE_ROLE_KEY`

---

## Del 2 — Railway (scraper)

1. Gå till **railway.app** → New Project → Deploy from GitHub
2. Välj ditt repo, välj mappen **scraper-service** som Root Directory
3. Railway detekterar Dockerfile automatiskt
4. Lägg till miljövariabler under **Variables**:

```
NODE_ENV=production
SCRAPER_SECRET=välj-en-lång-hemlig-sträng-här
```

5. Klicka **Deploy** — Railway bygger och startar servern
6. Under **Settings → Networking** — kopiera din publika URL:
   ```
   https://din-scraper.railway.app
   ```
7. Testa att den är uppe:
   ```
   curl https://din-scraper.railway.app/health
   # → {"status":"ok",...}
   ```

---

## Del 2b — Railway (nightly scraper, cron)

Bygger marknadsprisdata i `market_listings` — se NIGHTLY_SCRAPER.md. Kräver
att migrationen längst ner i `data/schema.sql` (source_url-unikhet +
`mark_stale_listings_sold()`) har körts i Supabase SQL Editor först.

1. I samma Railway-projekt som Del 2: **New Service** → **GitHub Repo** → samma
   repo, samma Root Directory (**scraper-service**) — Railway återanvänder
   samma Dockerfile/image, bara start-kommandot skiljer sig
2. **Viktigt:** `scraper-service/railway.json` sätter redan
   `startCommand: node dist/server.js` för webbtjänsten, och den filen
   styr ALLA tjänster som pekar på samma Root Directory — att bara ändra
   **Custom Start Command** i dashboarden för den nya tjänsten räcker
   alltså inte, filen vinner ändå. Använd istället den separata
   `scraper-service/railway.nightly.json` (redan i repot):
   under **Settings → Config-as-code** → fältet **Railway Config File**
   (obs: absolut sökväg från repo-roten, följer INTE Root Directory), sätt:
   ```
   /scraper-service/railway.nightly.json
   ```
3. Under **Settings → Cron Schedule** — aktivera och sätt:
   ```
   0 2 * * *
   ```
   (körs varje natt kl 02:00 UTC)
4. Lägg till miljövariabler under **Variables** (samma projekt som Del 2
   har redan `NODE_ENV`/`SCRAPER_SECRET` — den här tjänsten behöver
   dessutom):
   ```
   NEXT_PUBLIC_SUPABASE_URL=        (från Del 1)
   SUPABASE_SERVICE_ROLE_KEY=       (från Del 1)
   NIGHTLY_MAX_PAGES=20             (valfritt, default 20)
   ```
5. Kör en manuell deploy första gången och kontrollera loggarna — ska sluta
   med `[nightly] Klart på X.Xs`

---

## Del 3 — Vercel (frontend)

1. Gå till **vercel.com** → New Project → Import från GitHub
2. Välj ditt repo (root-mappen, inte scraper-service)
3. Framework: **Next.js** (auto-detekterat)
4. Lägg till miljövariabler under **Environment Variables**:

```
NEXT_PUBLIC_SUPABASE_URL=        (från Del 1)
NEXT_PUBLIC_SUPABASE_ANON_KEY=   (från Del 1)
SUPABASE_SERVICE_ROLE_KEY=       (från Del 1)
ANTHROPIC_API_KEY=               (från console.anthropic.com)
SCRAPER_SERVICE_URL=             (URL från Del 2, t.ex. https://din-scraper.railway.app)
SCRAPER_SECRET=                  (samma värde som i Railway)
```

5. Klicka **Deploy**
6. Din app är live på `https://din-app.vercel.app`

---

## Verifiera att allt hänger ihop

Öppna din Vercel-URL, klistra in en Blocket-annons och kontrollera:

- [ ] Loading-skärmen visas
- [ ] Analysen slutförs (30–40 sekunder första gången)
- [ ] Deal-score visas
- [ ] AI-sammanfattning visas på svenska
- [ ] Supabase → Table Editor → `analyses` → en ny rad har skapats

---

## Felsökning

**"SCRAPER_SERVICE_URL saknas"**
→ Miljövariabeln är inte satt i Vercel. Kontrollera Environment Variables.

**Scraper timeout (>25s)**
→ Railway-containern håller på att starta (cold start). Vänta 30s och försök igen.
→ Om det händer ofta: uppgradera till Railway Hobby-plan för att undvika cold starts.

**"Unauthorized" från scrapern**
→ SCRAPER_SECRET matchar inte mellan Vercel och Railway. Kontrollera att värdena är identiska.

**Blocket-parsing misslyckas**
→ Blocket kan ha uppdaterat sin HTML-struktur. Kontrollera Railway-loggar för felmeddelande.
→ Parsern har DOM-fallback — om `__NEXT_DATA__` inte fungerar försöker den med CSS-selektorer.

---

## Kostnader (ungefärligt)

| Tjänst    | Plan   | Kostnad      |
|-----------|--------|--------------|
| Vercel    | Hobby  | Gratis       |
| Railway   | Hobby  | ~50 kr/mån   |
| Supabase  | Free   | Gratis       |
| Anthropic | API    | ~0,05 kr/analys |

En analys kostar ungefär **5–10 öre** i AI-kostnader.
