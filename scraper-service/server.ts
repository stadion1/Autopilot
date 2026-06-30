/**
 * scraper-service/server.ts
 *
 * Fristående Express-server som kör på Railway.
 * Exponerar Playwright-parsers som HTTP-endpoints.
 *
 * Varför separat från Vercel:
 * - Vercel serverless tillåter inte Chromium (för tungt, för lång körtid)
 * - Railway ger en persistent container med full OS-access
 * - Den här servern gör BARA scraping — inget annat
 *
 * Routes:
 *   POST /scrape     — scrapa en URL och returnera normaliserad bildata
 *   GET  /health     — healthcheck för Railway
 *   GET  /supported  — lista vilka domäner som stöds
 */

import express, { Request, Response } from 'express'
import { scrapeAndParse, validateListingUrl, detectSite } from './parsers'

const app  = express()
const PORT = process.env.PORT ?? 3001

// ── Middleware ────────────────────────────────────────────────────────────────

app.use(express.json({ limit: '1mb' }))

// Enkel auth — kräv en delad hemlighet i header
// Sätts som SCRAPER_SECRET i Railway-miljövariabler
// Samma värde sätts som SCRAPER_SECRET i Vercel
app.use((req: Request, res: Response, next) => {
  if (req.path === '/health') return next()  // healthcheck alltid öppen

  const secret = process.env.SCRAPER_SECRET
  if (!secret) return next()  // om ingen secret satt — öppen (dev-läge)

  const provided = req.headers['x-scraper-secret']
  if (provided !== secret) {
    return res.status(401).json({ error: 'Unauthorized' })
  }
  next()
})

// Request logging
app.use((req: Request, _res: Response, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`)
  next()
})

// ── Routes ────────────────────────────────────────────────────────────────────

/**
 * GET /health
 * Används av Railway för att avgöra om tjänsten är uppe.
 */
app.get('/health', (_req: Request, res: Response) => {
  res.json({
    status:    'ok',
    timestamp: new Date().toISOString(),
    service:   'bilanalys-scraper',
    version:   '1.0.0',
  })
})

/**
 * GET /supported
 * Returnerar lista på domäner som kan parsas.
 */
app.get('/supported', (_req: Request, res: Response) => {
  res.json({
    sites: ['blocket.se', 'wayke.se', 'bytbil.com'],
  })
})

/**
 * POST /scrape
 * Body: { url: string }
 * Returns: ScraperResult (success, data, error)
 *
 * Timeout: 25 sekunder — Railway timeout är 30s
 */
app.post('/scrape', async (req: Request, res: Response) => {
  const { url } = req.body

  if (!url || typeof url !== 'string') {
    return res.status(400).json({ success: false, error: 'URL krävs' })
  }

  // Validera att URL:en är en stödd site och ser ut som en annons
  const validation = validateListingUrl(url.trim())
  if (!validation.valid) {
    return res.status(400).json({ success: false, error: validation.error })
  }

  // Timeout-wrapper — skyddar mot hängande Playwright-instanser
  const timeoutMs = 25000
  const timeout   = new Promise<never>((_, reject) =>
    setTimeout(() => reject(new Error('Scraping tog för lång tid (25s)')), timeoutMs)
  )

  try {
    console.log(`  Scraping: ${url}`)
    const t0     = Date.now()
    const result = await Promise.race([
      scrapeAndParse(url.trim(), validation.site!),
      timeout,
    ])
    const ms = Date.now() - t0
    console.log(`  Klar: ${result.success ? 'OK' : 'FEL'} (${ms}ms)`)

    if (!result.success) {
      return res.status(422).json(result)
    }

    // Returnera inte raw_html till Vercel — för stor payload
    const { raw_html: _, ...safeResult } = result as any
    return res.json({ ...safeResult, duration_ms: ms })

  } catch (err: any) {
    console.error(`  Fel: ${err.message}`)
    return res.status(500).json({
      success: false,
      error:   err.message ?? 'Okänt scraping-fel',
    })
  }
})

// ── Start ─────────────────────────────────────────────────────────────────────

app.listen(PORT, () => {
  console.log(`\n  Bilanalys scraper-service`)
  console.log(`  Port:    ${PORT}`)
  console.log(`  Auth:    ${process.env.SCRAPER_SECRET ? 'aktiverad' : 'avstängd (dev)'}`)
  console.log(`  Miljö:   ${process.env.NODE_ENV ?? 'development'}\n`)
})
