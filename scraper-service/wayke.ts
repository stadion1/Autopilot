/**
 * Wayke.se parser
 *
 * Wayke is more scraper-friendly than Blocket:
 * - They expose a public GraphQL / JSON API that the SPA uses
 * - Listing IDs are in the URL slug, so we can call the API directly
 * - This is vastly more reliable than HTML parsing
 *
 * URL pattern: https://www.wayke.se/bil/[slug]--[id]
 * e.g. https://www.wayke.se/bil/volvo-v60-t5-inscription--abc123def456
 *
 * We extract the ID and call their listing endpoint.
 * If the API changes, we fall back to DOM parsing.
 */

import { Page } from 'playwright'
import { CarListing, FuelType, ScraperResult, Transmission } from './types'
import { humanDelay } from '../scraper/stealth'

// ─── API method (preferred — no scraping needed) ─────────────────────────────

function extractWaykeId(url: string): string | null {
  // Match the ID at the end of the slug: --[alphanumeric]
  const match = url.match(/--([a-z0-9]+)\/?$/i)
  return match?.[1] ?? null
}

async function fetchFromWaykeAPI(listingId: string): Promise<Partial<CarListing> | null> {
  try {
    // Wayke's internal search API — returns full vehicle data
    const apiUrl = `https://api.wayke.se/v2/vehicles/${listingId}`
    const res = await fetch(apiUrl, {
      headers: {
        'Accept': 'application/json',
        'Origin': 'https://www.wayke.se',
        'Referer': 'https://www.wayke.se/',
      },
    })

    if (!res.ok) return null
    const json = await res.json()
    const v = json?.vehicle ?? json

    return {
      brand:        v.manufacturer ?? v.brand,
      model:        v.modelSeries ?? v.model,
      variant:      v.modelName ?? v.variant,
      year:         v.modelYear ?? v.year,
      price_sek:    v.price?.value ?? v.price,
      mileage_km:   v.mileage,
      fuel_type:    mapWaykeFuel(v.fuelType),
      transmission: mapWaykeGear(v.gearbox ?? v.transmission),
      horsepower:   v.horsepower ?? v.effect,
      color:        v.color ?? v.colourName,
      location:     v.location?.name ?? v.location,
      seller_type:  v.dealer ? 'dealer' : 'private',
      description:  v.description,
      images:       v.images?.slice(0, 6).map((i: any) => i.url ?? i) ?? [],
    }
  } catch {
    return null
  }
}

function mapWaykeFuel(raw?: string): FuelType {
  if (!raw) return 'Bensin'
  const s = raw.toLowerCase()
  if (s.includes('el'))                          return 'El'
  if (s.includes('laddhybrid') || s.includes('plug')) return 'Laddhybrid'
  if (s.includes('hybrid'))                      return 'Hybrid'
  if (s.includes('diesel'))                      return 'Diesel'
  if (s.includes('gas'))                         return 'Gas'
  return 'Bensin'
}

function mapWaykeGear(raw?: string): Transmission {
  if (!raw) return 'Manuell'
  return raw.toLowerCase().includes('automat') ? 'Automat' : 'Manuell'
}

// ─── DOM fallback ─────────────────────────────────────────────────────────────

async function extractFromWaykeDOM(page: Page): Promise<Partial<CarListing>> {
  // Wayke is a React SPA — wait for the vehicle data to render
  await page.waitForSelector('[class*="VehicleHeader"], h1', { timeout: 10000 }).catch(() => {})
  await humanDelay(400, 800)

  return page.evaluate(() => {
    const getText = (sel: string) => document.querySelector(sel)?.textContent?.trim() ?? ''

    const title = getText('h1') || getText('[class*="VehicleHeader"] h2')
    const priceStr = getText('[class*="Price"]') || getText('[data-e2e="price"]')

    const specs: Record<string, string> = {}
    document.querySelectorAll('[class*="SpecRow"], [class*="spec-row"], dl').forEach(row => {
      const dt = row.querySelector('dt')?.textContent?.trim().toLowerCase()
      const dd = row.querySelector('dd')?.textContent?.trim()
      if (dt && dd) specs[dt] = dd
    })

    const images = Array.from(document.querySelectorAll('img[class*="VehicleImage"], img[alt*="bild"]'))
      .map((img: Element) => (img as HTMLImageElement).src)
      .filter(src => src?.startsWith('http'))
      .slice(0, 6)

    return { title, priceStr, specs, images }
  }).then(({ title, priceStr, specs, images }) => ({
    price_sek:    priceStr ? parseInt(priceStr.replace(/\D/g, '')) : undefined,
    description:  specs['beskrivning'] || undefined,
    images:       images.length ? images : undefined,
    mileage_km:   specs['mätarställning'] ? parseInt(specs['mätarställning'].replace(/\D/g, '')) * 10 : undefined,
    year:         specs['modellår'] ? parseInt(specs['modellår']) : undefined,
    fuel_type:    mapWaykeFuel(specs['drivmedel']),
    transmission: mapWaykeGear(specs['växellåda']),
  }))
}

// ─── Main entry ───────────────────────────────────────────────────────────────

export async function parseWayke(page: Page, url: string): Promise<ScraperResult> {
  try {
    // Try API first — no browser needed
    const listingId = extractWaykeId(url)
    if (listingId) {
      const apiData = await fetchFromWaykeAPI(listingId)
      if (apiData && apiData.price_sek) {
        return { success: true, data: apiData }
      }
    }

    // Fall back to browser DOM parsing
    await page.goto(url, { waitUntil: 'networkidle', timeout: 20000 })

    const title = await page.title()
    if (title.toLowerCase().includes('404') || title.toLowerCase().includes('hittades inte')) {
      return { success: false, error: 'Listing not found or removed' }
    }

    const domData = await extractFromWaykeDOM(page)
    const rawHtml = await page.content()

    return {
      success: true,
      data: domData,
      raw_html: rawHtml.slice(0, 500_000),
    }
  } catch (err) {
    return {
      success: false,
      error: err instanceof Error ? err.message : 'Unknown error',
    }
  }
}
