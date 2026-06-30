/**
 * Blocket.se parser
 *
 * Blocket renders listing data two ways:
 * 1. __NEXT_DATA__ JSON blob in a <script> tag — most reliable, survives CSS class changes
 * 2. DOM elements — fallback if JSON structure changes
 *
 * We always try the JSON first. This is much more robust than CSS selectors
 * and far less likely to break on a Blocket deploy.
 *
 * We fetch one page per analysis. We do not crawl, paginate, or index.
 */

import { Page } from 'playwright'
import { CarListing, FuelType, ScraperResult, Transmission } from '../../types'
import { humanDelay } from '../scraper/stealth'

// ─── JSON extraction (primary method) ────────────────────────────────────────

interface BlocketNextData {
  props?: {
    pageProps?: {
      ad?: {
        subject?: string
        body?: string
        price?: { value?: number }
        parameters?: Array<{ label: string; value: string }>
        images?: Array<{ url: string }>
        location?: { name?: string }
        store?: { name?: string; type?: string }  // type: 'private' | 'store'
      }
    }
  }
}

function extractFromNextData(raw: string): Partial<CarListing> | null {
  try {
    const data: BlocketNextData = JSON.parse(raw)
    const ad = data?.props?.pageProps?.ad
    if (!ad) return null

    const params = ad.parameters ?? []
    const getParam = (label: string) =>
      params.find(p => p.label.toLowerCase().includes(label.toLowerCase()))?.value ?? ''

    const mileageRaw = getParam('mätarställning') || getParam('miltal')
    const yearRaw    = getParam('modellår') || getParam('årsmodell')
    const fuelRaw    = getParam('drivmedel') || getParam('bränsle')
    const gearRaw    = getParam('växellåda') || getParam('transmission')
    const colorRaw   = getParam('färg')
    const hpRaw      = getParam('hästkrafter') || getParam('effekt')

    return {
      price_sek:    ad.price?.value,
      description:  ad.body,
      images:       ad.images?.slice(0, 6).map(i => i.url),
      location:     ad.location?.name,
      seller_type:  ad.store?.type === 'store' ? 'dealer' : 'private',
      mileage_km:   parseMileage(mileageRaw),
      year:         parseYear(yearRaw) ?? parseYearFromTitle(ad.subject ?? ''),
      fuel_type:    parseFuelType(fuelRaw),
      transmission: parseTransmission(gearRaw),
      color:        colorRaw || undefined,
      horsepower:   hpRaw ? parseInt(hpRaw.replace(/\D/g, '')) || undefined : undefined,
      ...parseTitle(ad.subject ?? ''),
    }
  } catch {
    return null
  }
}

// ─── DOM fallback (used when __NEXT_DATA__ doesn't have the fields we need) ──

async function extractFromDOM(page: Page): Promise<Partial<CarListing>> {
  return page.evaluate(() => {
    const getText = (sel: string) =>
      document.querySelector(sel)?.textContent?.trim() ?? ''

    const title      = getText('h1[data-testid="ad-title"]') || getText('h1')
    const priceStr   = getText('[data-testid="price-tag"]') ||
                       getText('[class*="Price"]') ||
                       getText('[class*="price"]')
    const descEl     = document.querySelector('[data-testid="ad-description"]') ||
                       document.querySelector('[class*="Description"]')
    const desc       = descEl?.textContent?.trim() ?? ''

    // Collect all parameter rows — label → value pairs
    const paramRows: Record<string, string> = {}
    document.querySelectorAll('[class*="ParameterRow"], [class*="parameter"]').forEach(row => {
      const cells = row.querySelectorAll('dt, dd, span')
      if (cells.length >= 2) {
        const label = cells[0].textContent?.trim().toLowerCase() ?? ''
        const value = cells[1].textContent?.trim() ?? ''
        if (label && value) paramRows[label] = value
      }
    })

    const images = Array.from(
      document.querySelectorAll('img[data-testid*="image"], img[class*="AdImage"]')
    )
      .map((img: Element) => (img as HTMLImageElement).src)
      .filter(src => src && !src.includes('placeholder'))
      .slice(0, 6)

    return { title, priceStr, desc, paramRows, images }
  }).then(({ title, priceStr, desc, paramRows, images }) => {
    return {
      price_sek:   priceStr ? parseInt(priceStr.replace(/\D/g, '')) || undefined : undefined,
      description: desc || undefined,
      images:      images.length ? images : undefined,
      mileage_km:  parseMileage(paramRows['mätarställning'] || paramRows['miltal'] || ''),
      year:        parseYear(paramRows['modellår'] || paramRows['årsmodell'] || '') ?? parseYearFromTitle(title),
      fuel_type:   parseFuelType(paramRows['drivmedel'] || paramRows['bränsle'] || ''),
      transmission: parseTransmission(paramRows['växellåda'] || ''),
      color:       paramRows['färg'] || undefined,
      ...parseTitle(title),
    }
  })
}

// ─── Main parser ──────────────────────────────────────────────────────────────

export async function parseBlocket(page: Page, url: string): Promise<ScraperResult> {
  try {
    await page.goto(url, {
      waitUntil: 'domcontentloaded',
      timeout: 20000,
    })

    // Small human-like pause after page load
    await humanDelay(600, 1400)

    // Check for CAPTCHA or block page
    const title = await page.title()
    if (title.toLowerCase().includes('captcha') ||
        title.toLowerCase().includes('access denied') ||
        title.toLowerCase().includes('blocked')) {
      return { success: false, error: 'Bot detection triggered — try again later' }
    }

    // 1. Try __NEXT_DATA__ JSON first (most robust)
    const nextDataRaw = await page.evaluate(() => {
      const el = document.getElementById('__NEXT_DATA__')
      return el?.textContent ?? null
    })

    let data: Partial<CarListing> | null = null

    if (nextDataRaw) {
      data = extractFromNextData(nextDataRaw)
    }

    // 2. Fall back to DOM if JSON extraction failed or was incomplete
    if (!data || !data.price_sek || !data.brand) {
      const domData = await extractFromDOM(page)
      data = { ...domData, ...Object.fromEntries(
        Object.entries(data ?? {}).filter(([, v]) => v !== undefined)
      )}
    }

    // 3. Store raw HTML for potential re-parsing (avoids re-scraping)
    const rawHtml = await page.content()

    if (!data.price_sek && !data.brand) {
      return { success: false, error: 'Could not extract listing data — page structure may have changed' }
    }

    return {
      success: true,
      data: data as Partial<CarListing>,
      raw_html: rawHtml.slice(0, 500_000),   // cap at 500kb
    }
  } catch (err) {
    return {
      success: false,
      error: err instanceof Error ? err.message : 'Unknown scraper error',
    }
  }
}

// ─── Field parsers ────────────────────────────────────────────────────────────

/** "65 000 km" → 65000  |  "6 500 mil" → 65000 (convert mil→km) */
function parseMileage(raw: string): number | undefined {
  if (!raw) return undefined
  const num = parseInt(raw.replace(/\s/g, '').replace(/\D/g, ''))
  if (isNaN(num)) return undefined
  // Blocket sometimes shows mil, sometimes km — detect by magnitude
  // If number < 5000 it's almost certainly in mil
  return raw.toLowerCase().includes('mil') || num < 5000 ? num * 10 : num
}

function parseYear(raw: string): number | undefined {
  const match = raw.match(/\b(19|20)\d{2}\b/)
  return match ? parseInt(match[0]) : undefined
}

function parseYearFromTitle(title: string): number | undefined {
  const match = title.match(/\b(20\d{2}|19[5-9]\d)\b/)
  return match ? parseInt(match[0]) : undefined
}

function parseFuelType(raw: string): FuelType {
  const s = raw.toLowerCase()
  if (s.includes('el'))       return 'El'
  if (s.includes('laddhybrid') || s.includes('phev')) return 'Laddhybrid'
  if (s.includes('hybrid'))   return 'Hybrid'
  if (s.includes('diesel'))   return 'Diesel'
  if (s.includes('gas') || s.includes('naturgas')) return 'Gas'
  return 'Bensin'
}

function parseTransmission(raw: string): Transmission {
  const s = raw.toLowerCase()
  if (s.includes('automat') || s.includes('automatic')) return 'Automat'
  return 'Manuell'
}

/**
 * Extracts brand and model from a listing title.
 * Swedish listings typically follow: "Brand Model Variant Year"
 * e.g. "Volvo V60 T5 Inscription 2020"
 */
function parseTitle(title: string): { brand?: string; model?: string; variant?: string } {
  if (!title) return {}

  // Known Swedish market brands — ordered by listing frequency on Blocket
  const BRANDS = [
    'Volvo', 'Volkswagen', 'Toyota', 'BMW', 'Mercedes-Benz', 'Audi',
    'Ford', 'Skoda', 'Hyundai', 'Kia', 'Peugeot', 'Renault', 'Opel',
    'Nissan', 'Mazda', 'Honda', 'Seat', 'Citroën', 'Fiat', 'Tesla',
    'Subaru', 'Mitsubishi', 'Suzuki', 'Jeep', 'Land Rover', 'Porsche',
    'Lexus', 'Alfa Romeo', 'Mini', 'Saab', 'Dacia', 'MG',
  ]

  const cleanTitle = title.replace(/\s+/g, ' ').trim()

  for (const brand of BRANDS) {
    const idx = cleanTitle.toLowerCase().indexOf(brand.toLowerCase())
    if (idx !== -1) {
      const afterBrand = cleanTitle.slice(idx + brand.length).trim()
      // Next token after brand = model (e.g. "V60"), rest = variant
      const tokens = afterBrand.split(/\s+/)
      const model   = tokens[0] ?? undefined
      const variant = tokens.slice(1).join(' ').replace(/\b(19|20)\d{2}\b/, '').trim() || undefined
      return { brand, model, variant }
    }
  }

  // Fallback: first word = brand, second = model
  const tokens = cleanTitle.split(/\s+/)
  return {
    brand:   tokens[0],
    model:   tokens[1],
    variant: tokens.slice(2).join(' ') || undefined,
  }
}
