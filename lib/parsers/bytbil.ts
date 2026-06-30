import { Page } from 'playwright'
import { ScraperResult } from '../../types'
import { humanDelay } from '../scraper/stealth'

export async function parseBytbil(page: Page, url: string): Promise<ScraperResult> {
  try {
    await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 20000 })
    await humanDelay(500, 1200)

    // Bytbil embeds vehicle data in a window.__INITIAL_STATE__ object
    const stateRaw = await page.evaluate(() => {
      const scripts = Array.from(document.querySelectorAll('script:not([src])'))
      for (const s of scripts) {
        const text = s.textContent ?? ''
        if (text.includes('__INITIAL_STATE__')) {
          const match = text.match(/window\.__INITIAL_STATE__\s*=\s*({.+?});?\s*$/)
          return match?.[1] ?? null
        }
      }
      return null
    })

    if (stateRaw) {
      try {
        const state = JSON.parse(stateRaw)
        const vehicle = state?.vehicle?.data ?? state?.ad?.vehicle
        if (vehicle) {
          return {
            success: true,
            data: {
              brand:        vehicle.make ?? vehicle.brand,
              model:        vehicle.model,
              variant:      vehicle.variant ?? vehicle.trim,
              year:         vehicle.modelYear ?? vehicle.year,
              price_sek:    vehicle.price?.value ?? vehicle.price,
              mileage_km:   vehicle.mileage,
              fuel_type:    vehicle.fuelType === 'Diesel' ? 'Diesel' : 'Bensin',
              transmission: vehicle.gearbox?.includes('Auto') ? 'Automat' : 'Manuell',
              color:        vehicle.colour,
              location:     vehicle.location?.city,
              seller_type:  vehicle.sellerType === 'company' ? 'dealer' : 'private',
              description:  vehicle.description,
              images:       vehicle.images?.slice(0, 6).map((i: any) => i.url) ?? [],
            },
          }
        }
      } catch { /* fall through to DOM */ }
    }

    // DOM fallback
    const data = await page.evaluate(() => {
      const title    = document.querySelector('h1')?.textContent?.trim() ?? ''
      const priceStr = document.querySelector('[class*="price"]')?.textContent?.trim() ?? ''
      return { title, priceStr }
    })

    return {
      success: true,
      data: {
        price_sek: data.priceStr ? parseInt(data.priceStr.replace(/\D/g, '')) : undefined,
      },
    }
  } catch (err) {
    return { success: false, error: err instanceof Error ? err.message : 'Unknown error' }
  }
}
