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
import { supabase } from './supabase'
import { extractAdId } from './blocket'
import { verifyBlocketAdGone, daysListedSince } from './soldVerification'

const app  = express()
const PORT = process.env.PORT ?? 3001

// ── Middleware ────────────────────────────────────────────────────────────────

app.use(express.json({ limit: '1mb' }))

app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*')
  res.header('Access-Control-Allow-Headers', 'Content-Type, x-scraper-secret')
  res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
  if (req.method === 'OPTIONS') return res.sendStatus(200)
  next()
})
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

/**
 * POST /backfill-sold-verification
 * Body (valfritt): { days?: number } — hur många dagar bakåt sold_at ska
 * omprövas, default 14.
 *
 * Engångsverktyg, triggas manuellt (inte schemalagt): rättar rader som
 * felaktigt markerades sålda av den gamla "inte återsedd i samplet"-
 * heuristiken innan verifieringen mot Blockets egen annons-endpoint fanns
 * (se nightly.ts). nightly.ts sköter verifiering av NYA kandidater varje
 * natt på egen hand — det här är bara för att städa upp befintliga
 * felmarkeringar i efterhand, kan köras om vid behov men behöver inte
 * schemaläggas.
 */
app.post('/backfill-sold-verification', async (req: Request, res: Response) => {
  const days = typeof req.body?.days === 'number' && req.body.days > 0 ? req.body.days : 14
  const cutoff = new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString()

  // Supabase/PostgREST caps results at 1000 rows per request by default —
  // without explicit pagination, any match beyond the first 1000 would
  // silently never get checked. Page through with .range() until a page
  // comes back short of PAGE_SIZE.
  const PAGE_SIZE = 1000
  const candidates: { id: string; source_url: string }[] = []
  for (let page = 0; ; page++) {
    const { data, error } = await supabase
      .from('market_listings')
      .select('id, source_url')
      .eq('source_site', 'blocket')
      .not('sold_at', 'is', null)
      .gte('sold_at', cutoff)
      .range(page * PAGE_SIZE, page * PAGE_SIZE + PAGE_SIZE - 1)

    if (error) {
      return res.status(500).json({ error: error.message })
    }
    candidates.push(...(data ?? []))
    if (!data || data.length < PAGE_SIZE) break
  }

  console.log(`[backfill] ${candidates.length} sold-markerade Blocket-rader (senaste ${days} dagarna) att kontrollera`)

  const stats = { checked: candidates.length, unmarked: 0, confirmedSold: 0, ambiguous: 0 }
  const CONCURRENCY = 8

  for (let i = 0; i < candidates.length; i += CONCURRENCY) {
    const chunk = candidates.slice(i, i + CONCURRENCY)
    await Promise.all(chunk.map(async (c: { id: string; source_url: string }) => {
      const adId = extractAdId(c.source_url)
      if (!adId) { stats.ambiguous++; return }

      const gone = await verifyBlocketAdGone(adId)
      if (gone === false) {
        // Fortfarande aktiv trots sold_at — felmarkerad av den gamla
        // heuristiken, backa den.
        await supabase.from('market_listings')
          .update({ sold_at: null, days_listed: null, scraped_at: new Date().toISOString() })
          .eq('id', c.id)
        stats.unmarked++
      } else if (gone === true) {
        stats.confirmedSold++   // korrekt markerad, rör inte
      } else {
        stats.ambiguous++       // nätverksfel — rör inte, går att köra om senare
      }
    }))
    await new Promise(resolve => setTimeout(resolve, 500))
  }

  console.log('[backfill] Klart:', stats)
  return res.json(stats)
})

/**
 * POST /reverify-active-listings
 *
 * Engångsverktyg, triggas manuellt: rättar det MOTSATTA problemet mot
 * /backfill-sold-verification. verifyBlocketAdGone() förlitade sig tidigare
 * på blocket-api.se, som visade sig fortsätta returnera fullständig data
 * (200 OK) för annonser som redan sålts/tagits bort på riktiga Blocket —
 * det cachar/speglar uppenbarligen data istället för att spegla borttagning
 * i realtid. Det gjorde att både nightly-verifieringen och båda
 * backfill-körningarna sannolikt har återaktiverat (sold_at satt till NULL)
 * annonser som i själva verket är sålda, mycket oftare än de rättade
 * riktiga falska positiva.
 *
 * Går igenom ALLA rader med source_site='blocket' AND sold_at IS NULL och
 * kontrollerar dem mot den korrigerade metoden (riktiga blocket.se-sidan,
 * inte blocket-api.se) — markerar bara sold_at på de som bekräftat är
 * borta. Rör inte rader som fortfarande är aktiva eller vars status är
 * oklar (nätverksfel).
 */
app.post('/reverify-active-listings', async (req: Request, res: Response) => {
  const PAGE_SIZE = 1000
  const candidates: { id: string; source_url: string; first_seen_at: string }[] = []
  for (let page = 0; ; page++) {
    const { data, error } = await supabase
      .from('market_listings')
      .select('id, source_url, first_seen_at')
      .eq('source_site', 'blocket')
      .is('sold_at', null)
      .range(page * PAGE_SIZE, page * PAGE_SIZE + PAGE_SIZE - 1)

    if (error) {
      return res.status(500).json({ error: error.message })
    }
    candidates.push(...(data ?? []))
    if (!data || data.length < PAGE_SIZE) break
  }

  console.log(`[reverify] ${candidates.length} aktiva Blocket-rader att kontrollera`)

  const stats = { checked: candidates.length, markedSold: 0, stillActive: 0, ambiguous: 0 }
  const CONCURRENCY = 8

  for (let i = 0; i < candidates.length; i += CONCURRENCY) {
    const chunk = candidates.slice(i, i + CONCURRENCY)
    await Promise.all(chunk.map(async (c: { id: string; source_url: string; first_seen_at: string }) => {
      const adId = extractAdId(c.source_url)
      if (!adId) { stats.ambiguous++; return }

      const gone = await verifyBlocketAdGone(adId)
      if (gone === true) {
        await supabase.from('market_listings')
          .update({ sold_at: new Date().toISOString(), days_listed: daysListedSince(c.first_seen_at) })
          .eq('id', c.id)
        stats.markedSold++
      } else if (gone === false) {
        stats.stillActive++   // faktiskt aktiv, rör inte
      } else {
        stats.ambiguous++     // nätverksfel — rör inte, går att köra om senare
      }
    }))
    await new Promise(resolve => setTimeout(resolve, 500))
  }

  console.log('[reverify] Klart:', stats)
  return res.json(stats)
})

/**
 * POST /cleanup-leasing-listings
 * Body (valfritt): { priceCeiling?: number } — kontrollera bara rader under
 * detta pris, default 50000 kr. Leasingannonsers "pris" är en månadskostnad
 * (verifierat: en bekräftad leasingannons visade 7 700 kr för en Skoda Peaq),
 * så en gräns rejält över det fångar in leasingprissatta rader utan att
 * kontrollera hela tabellen.
 *
 * Engångsverktyg: nightly.ts filtrerar numera bort sales_form=5
 * (leasing) vid insamling, men rader som redan hamnat i market_listings
 * innan den fixen finns kvar och drar ner medianpriser kraftigt. Kontrollerar
 * varje kandidat mot annonsens "Försäljningsform"-fält och TAR BORT raden
 * (inte bara markerar den) om den bekräftas vara leasing — en leasingrad har
 * ingen giltig användning i market_listings, till skillnad från en sold_at-
 * markering som åtminstone en gång var en riktig försäljning.
 */
app.post('/cleanup-leasing-listings', async (req: Request, res: Response) => {
  const priceCeiling = typeof req.body?.priceCeiling === 'number' && req.body.priceCeiling > 0
    ? req.body.priceCeiling : 50000

  const PAGE_SIZE = 1000
  const candidates: { id: string; source_url: string }[] = []
  for (let page = 0; ; page++) {
    const { data, error } = await supabase
      .from('market_listings')
      .select('id, source_url')
      .eq('source_site', 'blocket')
      .lt('price_sek', priceCeiling)
      .range(page * PAGE_SIZE, page * PAGE_SIZE + PAGE_SIZE - 1)

    if (error) {
      return res.status(500).json({ error: error.message })
    }
    candidates.push(...(data ?? []))
    if (!data || data.length < PAGE_SIZE) break
  }

  console.log(`[cleanup-leasing] ${candidates.length} Blocket-rader under ${priceCeiling} kr att kontrollera`)

  const stats = { checked: candidates.length, removed: 0, keptGenuine: 0, ambiguous: 0 }
  const CONCURRENCY = 8

  for (let i = 0; i < candidates.length; i += CONCURRENCY) {
    const chunk = candidates.slice(i, i + CONCURRENCY)
    await Promise.all(chunk.map(async (c: { id: string; source_url: string }) => {
      const adId = extractAdId(c.source_url)
      if (!adId) { stats.ambiguous++; return }

      try {
        const res2 = await fetch(`https://blocket-api.se/v1/ad/car?id=${adId}`, {
          headers: { Accept: 'application/json', 'User-Agent': 'bilanalys-nightly/1.0' },
          signal: AbortSignal.timeout(10000),
        })
        if (!res2.ok) { stats.ambiguous++; return }
        const ad = await res2.json().catch(() => null)
        const salesForm = ad?.specifications?.['Försäljningsform']

        if (salesForm === 'Leasing') {
          await supabase.from('market_listings').delete().eq('id', c.id)
          stats.removed++
        } else {
          stats.keptGenuine++   // äkta lågprissatt bil, rör inte
        }
      } catch {
        stats.ambiguous++
      }
    }))
    await new Promise(resolve => setTimeout(resolve, 500))
  }

  console.log('[cleanup-leasing] Klart:', stats)
  return res.json(stats)
})

/**
 * POST /cleanup-implausible-listings
 *
 * Engångsverktyg: nightly.ts och lib/supabase/client.ts (saveMarketListing)
 * avvisar numera nya rader med årsmodell < 2010 eller ett orimligt lågt pris
 * för en ung/lågmil bil (se kommentarerna i respektive fil) — men rader som
 * hamnade i market_listings INNAN de fixarna finns kvar och drar ner
 * medianpriser. Ingen extern verifiering behövs här (till skillnad från
 * leasing-cleanup ovan) — reglerna kollar bara data som redan finns lagrad
 * i raden, så vi kan filtrera och ta bort direkt.
 */
app.post('/cleanup-implausible-listings', async (req: Request, res: Response) => {
  const IMPLAUSIBLE_LOW_PRICE = 20000
  const MIN_AGE_YEARS_FOR_LOW_PRICE = 10
  const MIN_MILEAGE_KM_FOR_LOW_PRICE = 150000
  const MIN_YEAR = 2010
  const currentYear = new Date().getFullYear()

  const PAGE_SIZE = 1000
  const rows: { id: string; year: number | null; price_sek: number | null; mileage_km: number | null }[] = []
  for (let page = 0; ; page++) {
    const { data, error } = await supabase
      .from('market_listings')
      .select('id, year, price_sek, mileage_km')
      .range(page * PAGE_SIZE, page * PAGE_SIZE + PAGE_SIZE - 1)

    if (error) {
      return res.status(500).json({ error: error.message })
    }
    rows.push(...(data ?? []))
    if (!data || data.length < PAGE_SIZE) break
  }

  console.log(`[cleanup-implausible] ${rows.length} rader att kontrollera`)

  const isImplausible = (row: { year: number | null; price_sek: number | null; mileage_km: number | null }) => {
    if (row.year == null || row.price_sek == null || row.mileage_km == null) return false
    if (row.year < MIN_YEAR) return true
    // T.ex. en 2011 Mercedes C220 med "256 387 mil" (2 563 870 km) i data —
    // ett uppenbart inmatningsfel i annonsen som redan borde stoppats av
    // samma 1 000 000 km-tak som gäller vid ny insamling (nightly.ts,
    // saveMarketListing), men raden hamnade i databasen innan/utan den
    // kontrollen.
    if (row.mileage_km < 0 || row.mileage_km > 1_000_000) return true
    if (row.price_sek < IMPLAUSIBLE_LOW_PRICE) {
      const ageYears = currentYear - row.year
      if (ageYears < MIN_AGE_YEARS_FOR_LOW_PRICE && row.mileage_km < MIN_MILEAGE_KM_FOR_LOW_PRICE) return true
    }
    return false
  }

  const toRemove = rows.filter(isImplausible)
  const stats = { checked: rows.length, removed: 0, kept: rows.length - toRemove.length }
  const CONCURRENCY = 8

  for (let i = 0; i < toRemove.length; i += CONCURRENCY) {
    const chunk = toRemove.slice(i, i + CONCURRENCY)
    await Promise.all(chunk.map(async (row: { id: string }) => {
      const { error } = await supabase.from('market_listings').delete().eq('id', row.id)
      if (!error) stats.removed++
    }))
  }

  console.log('[cleanup-implausible] Klart:', stats)
  return res.json(stats)
})

// ── Start ─────────────────────────────────────────────────────────────────────

app.listen(PORT, () => {
  console.log(`\n  Bilanalys scraper-service`)
  console.log(`  Port:    ${PORT}`)
  console.log(`  Auth:    ${process.env.SCRAPER_SECRET ? 'aktiverad' : 'avstängd (dev)'}`)
  console.log(`  Miljö:   ${process.env.NODE_ENV ?? 'development'}\n`)
})
