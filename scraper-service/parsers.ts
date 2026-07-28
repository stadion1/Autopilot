/**
 * Parser router
 *
 * Detects which site a URL belongs to, invokes the right parser,
 * and normalizes the result into a canonical CarListing.
 *
 * Also owns the "is this URL supported?" logic used by the API route
 * before spinning up a browser.
 */

import { CarListing, ScraperResult, SupportedSite } from './types'
import { createStealthBrowser, respectRateLimit } from './stealth'
import { parseBlocket } from './blocket'
import { parseWayke } from './wayke'
import { parseBytbil } from './bytbil'

const SUPPORTED_DOMAINS: Record<string, SupportedSite> = {
  'blocket.se':  'blocket',
  'wayke.se':    'wayke',
  'bytbil.com':  'bytbil',
}

export function detectSite(url: string): SupportedSite | null {
  try {
    const hostname = new URL(url).hostname.replace(/^www\./, '')
    return SUPPORTED_DOMAINS[hostname] ?? null
  } catch {
    return null
  }
}

export function validateListingUrl(url: string): { valid: boolean; error?: string; site?: SupportedSite } {
  const site = detectSite(url)
  if (!site) {
    return {
      valid: false,
      error: `Unsupported site. Supported: ${Object.keys(SUPPORTED_DOMAINS).join(', ')}`,
    }
  }

  // Basic sanity checks — ensure it looks like a listing, not a search page
  const urlObj = new URL(url)
  const path = urlObj.pathname

  if (site === 'blocket' && 
    !path.includes('/annons/') && 
    !path.includes('/bilar/') &&
    !path.includes('/mobility/item/') &&
    !path.includes('/item/')) {
  return { valid: false, error: 'This looks like a search page. Please paste a specific listing URL.' }
}
  if (site === 'wayke' && !path.includes('/bil/')) {
    return { valid: false, error: 'This looks like a search page. Please paste a specific listing URL.' }
  }

  return { valid: true, site }
}

/**
 * Main entry point: scrape and parse a listing URL.
 * Handles browser lifecycle — always cleans up.
 */
export async function scrapeAndParse(
  url: string,
  site: SupportedSite
): Promise<ScraperResult> {
  // Respect rate limits before acquiring a browser
  await respectRateLimit(url)

  const { browser, page } = await createStealthBrowser()

  try {
    let result: ScraperResult

    switch (site) {
      case 'blocket': result = await parseBlocket(page, url); break
      case 'wayke':   result = await parseWayke(page, url);   break
      case 'bytbil':  result = await parseBytbil(page, url);  break
      default:        result = { success: false, error: 'Unknown site' }
    }

    if (result.success && result.data) {
      result.data = normalize(result.data, url, site)
    }

    return result
  } finally {
    // Always close the browser — never leak Chromium processes
    await browser.close()
  }
}

/**
 * Normalize partial parsed data into a complete CarListing.
 * Applies defaults, cleans strings, validates ranges.
 */
function normalize(
  raw: Partial<CarListing>,
  url: string,
  site: SupportedSite
): Partial<CarListing> {
  return {
    ...raw,
    source_url:  url,
    source_site: site,
    brand:       capitalise(raw.brand),
    model:       raw.model?.trim(),
    variant:     raw.variant?.trim() || undefined,
    description: raw.description?.slice(0, 4000).trim() || undefined,
    price_sek:   raw.price_sek && raw.price_sek > 5000 && raw.price_sek < 10_000_000
                   ? raw.price_sek : undefined,
    mileage_km:  raw.mileage_km && raw.mileage_km >= 0 && raw.mileage_km < 1_000_000
                   ? raw.mileage_km : undefined,
    year:        raw.year && raw.year >= 1980 && raw.year <= new Date().getFullYear() + 1
                   ? raw.year : undefined,
  }
}

function capitalise(s?: string): string | undefined {
  if (!s) return undefined
  return s.charAt(0).toUpperCase() + s.slice(1)
}
