/**
 * Blocket parser — använder blocket-api.se istället för Playwright.
 * Ingen browser behövs. Snabbt, enkelt, pålitligt.
 */

import { CarListing, FuelType, ScraperResult, Transmission } from './types'

function extractAdId(url: string): string | null {
  const match = url.match(/\/(\d{6,12})\/?$/)
  return match?.[1] ?? null
}

function parseFuelType(raw?: string): FuelType {
  if (!raw) return 'Bensin'
  const s = raw.toLowerCase()
  if (s.includes('el'))                               return 'El'
  if (s.includes('laddhybrid') || s.includes('plug')) return 'Laddhybrid'
  if (s.includes('hybrid'))                           return 'Hybrid'
  if (s.includes('diesel'))                           return 'Diesel'
  if (s.includes('gas'))                              return 'Gas'
  return 'Bensin'
}

function parseTransmission(raw?: string): Transmission {
  if (!raw) return 'Manuell'
  return raw.toLowerCase().includes('auto') ? 'Automat' : 'Manuell'
}

function parseTitle(title: string): { brand?: string; model?: string; variant?: string } {
  const BRANDS = [
    'Volvo','Volkswagen','Toyota','BMW','Mercedes-Benz','Audi','Ford','Skoda',
    'Hyundai','Kia','Peugeot','Renault','Opel','Nissan','Mazda','Honda',
    'Seat','Citroën','Fiat','Tesla','Subaru','Mitsubishi','Suzuki','Jeep',
    'Land Rover','Porsche','Lexus','Alfa Romeo','Mini','Saab','Dacia','MG',
  ]
  const clean = title.trim()
  for (const brand of BRANDS) {
    if (clean.toLowerCase().includes(brand.toLowerCase())) {
      const after = clean.slice(clean.toLowerCase().indexOf(brand.toLowerCase()) + brand.length).trim()
      const tokens = after.split(/\s+/)
      return {
        brand,
        model:   tokens[0] ?? undefined,
        variant: tokens.slice(1).join(' ').replace(/\b(19|20)\d{2}\b/, '').trim() || undefined,
      }
    }
  }
  const tokens = clean.split(/\s+/)
  return { brand: tokens[0], model: tokens[1], variant: tokens.slice(2).join(' ') || undefined }
}

export async function parseBlocket(_: unknown, url: string): Promise<ScraperResult> {
  try {
    const adId = extractAdId(url)
    if (!adId) return { success: false, error: 'Kunde inte extrahera annons-ID från URL' }

    console.log(`  Anropar blocket-api.se för annons ${adId}`)

    const res = await fetch(`https://blocket-api.se/v1/ad/car?id=${adId}`, {
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'bilanalys/1.0',
      },
    })

    if (!res.ok) {
      return { success: false, error: `blocket-api.se svarade med ${res.status}` }
    }

    const ad = await res.json()
    console.log('RAW_AD:', JSON.stringify(ad).slice(0, 1000))
    console.log('AD_KEYS:', JSON.stringify(Object.keys(ad)))

    // Extrahera parametrar
    const params: Record<string, string> = {}
    if (Array.isArray(ad.parameters)) {
      ad.parameters.forEach((p: any) => {
        if (p.label && p.value) params[p.label.toLowerCase()] = p.value
      })
    }

    const getParam = (...keys: string[]) =>
      keys.map(k => params[k]).find(v => v !== undefined) ?? ''

   // Parsa pris — "499 900 kr" → 499900
const parsePrice = (raw?: string) => {
  if (!raw) return undefined
  const num = parseInt(raw.replace(/\s/g, '').replace(/[^\d]/g, ''))
  return isNaN(num) ? undefined : num
}

// Parsa miltal — "4 365 mil" → 43650 km
const parseMileageStr = (raw?: string) => {
  if (!raw) return undefined
  const num = parseInt(raw.replace(/\s/g, '').replace(/[^\d]/g, ''))
  return isNaN(num) ? undefined : num * 10
}

const specs = ad.specifications ?? {}

const data: Partial<CarListing> = {
  brand:        specs['Märke'] ?? ad.title?.split(' ')[0],
  model:        specs['Modell'] ?? ad.title?.split(' ')[1],
  variant:      ad.subtitle ?? undefined,
  year:         ad.model_year ? parseInt(ad.model_year) : undefined,
  price_sek:    parsePrice(ad.price),
  mileage_km:   parseMileageStr(ad.mileage),
  fuel_type:    parseFuelType(ad.fuel ?? specs['Drivmedel']),
  transmission: parseTransmission(ad.transmission ?? specs['Växellåda']),
  horsepower:   specs['Effekt'] ? parseInt(specs['Effekt'].replace(/\D/g, '')) || undefined : undefined,
  color:        specs['Färg'] ?? undefined,
  location:     specs['Bilens plats'] ?? undefined,
  seller_type:  ad.seller_type === 'dealer' ? 'dealer' : 'private',
  description:  ad.description ?? undefined,
  images:       ad.images?.slice(0, 6).map((i: any) => i.url ?? i.src ?? i).filter((i: any) => typeof i === 'string'),
  source_url:   url,
  source_site:  'blocket',
}

    console.log('PARSED:', JSON.stringify({
      brand: data.brand, model: data.model, year: data.year,
      price: data.price_sek, mileage: data.mileage_km
    }))

    return { success: true, data }

  } catch (err: any) {
    return { success: false, error: err.message ?? 'Okänt fel i Blocket-parsern' }
  }
}
