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

    const mileageRaw = getParam('mätarställning', 'miltal', 'mileage')
    const yearRaw    = getParam('modellår', 'årsmodell', 'year')
    const fuelRaw    = getParam('drivmedel', 'bränsle', 'fuel')
    const gearRaw    = getParam('växellåda', 'transmission', 'gearbox')
    const hpRaw      = getParam('hästkrafter', 'effekt', 'horsepower')
    const colorRaw   = getParam('färg', 'color')

    const priceAmount = ad.price?.amount ?? ad.price?.value ?? ad.currentPrice

    // Miltal — konvertera mil till km om nödvändigt
    const parseMileage = (raw: string) => {
      const num = parseInt(raw.replace(/\s/g, '').replace(/\D/g, ''))
      if (isNaN(num)) return undefined
      return raw.toLowerCase().includes('mil') || num < 5000 ? num * 10 : num
    }

    const titleParsed = parseTitle(
      ad.subject ?? ad.heading ?? ad.title ?? ''
    )

    // Försök också plocka brand/model direkt från ad-objektet
    const brand = ad.brand ?? ad.make ?? titleParsed.brand
    const model = ad.model ?? titleParsed.model
    const variant = ad.variant ?? ad.trim ?? titleParsed.variant

    const data: Partial<CarListing> = {
      brand,
      model,
      variant,
      price_sek:    priceAmount ? parseInt(String(priceAmount).replace(/\D/g, '')) : undefined,
      mileage_km:   parseMileage(mileageRaw),
      year:         yearRaw ? parseInt(yearRaw.replace(/\D/g, '')) : undefined,
      fuel_type:    parseFuelType(fuelRaw || ad.fuelType),
      transmission: parseTransmission(gearRaw || ad.gearbox),
      horsepower:   hpRaw ? parseInt(hpRaw.replace(/\D/g, '')) || undefined : undefined,
      color:        colorRaw || ad.color || undefined,
      location:     ad.location?.name ?? ad.location,
      seller_type:  ad.store?.type === 'store' || ad.dealer ? 'dealer' : 'private',
      description:  ad.body ?? ad.description,
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
