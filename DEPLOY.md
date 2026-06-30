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
