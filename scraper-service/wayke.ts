/**
 * Wayke.se parser
 *
 * Tidigare version antog en /v2/vehicles/{id}-endpoint på api.wayke.se och
 * en /bil/[slug]--[id]-URL. Verifierat mot verkliga annonser att bägge var
 * fel:
 * - api.wayke.se kräver en partner-API-nyckel (x-api-key) för ALLA endpoints,
 *   inklusive read-only /search/* — ingen anonym/gratis åtkomst finns.
 * - Riktiga annons-URL:er ser ut som https://www.wayke.se/objekt/{uuid},
 *   utan slug eller "--".
 *
 * Det som faktiskt fungerar: annonssidan är server-renderad (Next.js) och
 * innehåller ett komplett schema.org/Car JSON-LD-block med i princip allt
 * vi behöver (pris, miltal, VIN, reg.nr, bilder, motor, växellåda...). Ingen
 * Playwright/DOM-parsning behövs — samma mönster som blocket.ts landade i.
 *
 * Wayke verkar uteslutande vara en återförsäljar-marknadsplats (alla
 * observerade annonser har "Återförsäljare" + en organisation som säljare,
 * ingen privatperson-flagga i datan) — seller_type sätts därför till
 * 'dealer' rakt av.
 */

import { CarListing, ScraperResult } from './types'
import { parseFuelType, parseTransmission } from './blocket'

function extractWaykeId(url: string): string | null {
  const match = url.match(/\/objekt\/([a-f0-9-]{8,})/i)
  return match?.[1] ?? null
}

interface CarJsonLd {
  name?: string
  vehicleIdentificationNumber?: string
  identifier?: { value?: string }
  image?: string[]
  offers?: { price?: number; seller?: { name?: string } }
  brand?: { name?: string }
  model?: string
  vehicleConfiguration?: string
  vehicleModelDate?: string
  productionDate?: string
  mileageFromOdometer?: { value?: string; unitCode?: string }
  color?: string
  vehicleEngine?: { fuelType?: string; enginePower?: { value?: string } }
  vehicleTransmission?: string
}

function extractCarJsonLd(html: string): CarJsonLd | null {
  const re = /<script type="application\/ld\+json">([\s\S]*?)<\/script>/g
  let match: RegExpExecArray | null
  while ((match = re.exec(html))) {
    try {
      const parsed = JSON.parse(match[1])
      if (parsed?.['@type'] === 'Car') return parsed
    } catch {
      // inte giltig JSON eller inte det blocket vi letar efter — fortsätt
    }
  }
  return null
}

export async function parseWayke(_: unknown, url: string): Promise<ScraperResult> {
  try {
    const id = extractWaykeId(url)
    if (!id) return { success: false, error: 'Kunde inte extrahera annons-ID från URL' }

    const res = await fetch(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
    })
    if (!res.ok) {
      return { success: false, error: `Wayke svarade med ${res.status}` }
    }

    const html = await res.text()
    const car = extractCarJsonLd(html)
    if (!car) return { success: false, error: 'Kunde inte hitta fordonsdata (JSON-LD) i annonssidan' }

    const odometerRaw  = car.mileageFromOdometer?.value ? parseFloat(car.mileageFromOdometer.value) : undefined
    const odometerUnit = car.mileageFromOdometer?.unitCode
    const mileage_km   = odometerRaw === undefined ? undefined
                       : odometerUnit === 'SMI' ? odometerRaw * 10   // svensk mil, ifall det förekommer
                       : odometerRaw                                 // KMT = kilometer (vanliga fallet)

    const year = car.vehicleModelDate ? parseInt(car.vehicleModelDate)
               : car.productionDate   ? parseInt(car.productionDate)
               : undefined

    const data: Partial<CarListing> = {
      brand:        car.brand?.name,
      model:        car.model,
      variant:      car.vehicleConfiguration,
      year,
      price_sek:    car.offers?.price,
      mileage_km,
      fuel_type:    parseFuelType(car.vehicleEngine?.fuelType),
      transmission: parseTransmission(car.vehicleTransmission),
      color:        car.color,
      seller_type:  'dealer',
      registration_number: car.identifier?.value,
      vin:          car.vehicleIdentificationNumber,
      images:       car.image?.slice(0, 6),
      source_url:   url,
      source_site:  'wayke',
    }

    return { success: true, data }

  } catch (err: any) {
    return { success: false, error: err.message ?? 'Okänt fel i Wayke-parsern' }
  }
}
