/**
 * Blocket parser — använder blocket-api.se istället för Playwright.
 * Ingen browser behövs. Snabbt, enkelt, pålitligt.
 */

import { CarListing, FuelType, ScraperResult, Transmission } from './types'

export function extractAdId(url: string): string | null {
  const clean = url.split(/[?#]/)[0]
  const match = clean.match(/\/(\d{6,12})\/?$/)
  return match?.[1] ?? null
}

export function parseFuelType(raw?: string): FuelType {
  if (!raw) return 'Bensin'
  const s = raw.toLowerCase()
  // Hybrid/laddhybrid-kontrollerna måste komma FÖRE den generella 'el'-
  // kontrollen — Wayke taggar t.ex. alla hybrider/laddhybrider som
  // "Bensin+El", vilket annars felaktigt skulle klassas som ren elbil
  // eftersom "bensin+el" innehåller substrängen 'el'.
  if (s.includes('laddhybrid') || s.includes('plug'))  return 'Laddhybrid'
  if (s.includes('hybrid'))                            return 'Hybrid'
  if (s.includes('diesel'))                            return 'Diesel'
  if (s.includes('gas'))                               return 'Gas'
  if (s.includes('el') && !s.includes('+'))            return 'El'
  if (s.includes('el'))                                return 'Hybrid'  // t.ex. "Bensin+El" utan explicit hybrid/plug-in-ord
  return 'Bensin'
}

export function parseTransmission(raw?: string): Transmission {
  if (!raw) return 'Manuell'
  return raw.toLowerCase().includes('auto') ? 'Automat' : 'Manuell'
}

// blocket-api.se's /v1/ad/car svar innehåller ingen bilddata, så vi hämtar
// annonssidan direkt från blocket.se och plockar ut bilderna därifrån.
// Bilddatan ligger base64-kodad (och därefter URI-encodead) i attributet
// data-props på #mobility-item-page-root, under adData.ad.images[].uri.
async function fetchAdImages(adId: string): Promise<string[]> {
  try {
    const res = await fetch(`https://www.blocket.se/mobility/item/${adId}`, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
    })
    if (!res.ok) return []

    const html = await res.text()
    const tagMatch = html.match(/<div[^>]*id="mobility-item-page-root"[^>]*>/)
    const propsMatch = tagMatch?.[0].match(/data-props="([^"]*)"/)
    if (!propsMatch) return []

    const decoded = decodeURIComponent(Buffer.from(propsMatch[1], 'base64').toString('utf8'))
    const images = JSON.parse(decoded)?.adData?.ad?.images
    if (!Array.isArray(images)) return []

    return images.map((i: any) => i.uri).filter((u: any) => typeof u === 'string').slice(0, 6)
  } catch {
    return []
  }
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

    // Leasingannonser visar en månadskostnad i prisfältet, inte ett köppris
    // (verifierat: en "Försäljningsform":"Leasing"-annons hade pris 7 700 kr
    // för en Skoda Peaq). Vår hela analys — medianjämförelse, deal-score,
    // ägandekostnad — förutsätter ett köppris, så att köra den på en
    // leasingannons skulle ge missvisande siffror, inte bara osäkra.
    // Bättre att vägra tydligt än att låtsas analysera fel sak.
    if (specs['Försäljningsform'] === 'Leasing') {
      return {
        success: false,
        error: 'Den här annonsen är ett leasingerbjudande (månadskostnad), inte ett köp — vår analys jämför köppriser och skulle ge missvisande resultat för leasing.',
      }
    }

// blocket-api.se verkar ibland inte hunnit indexera Miltal/mileage för en
// nyss inlagd "Ny bil till salu"-annons — verifierat: två separata
// Volvo XC60-annonser gav mileage_km: undefined vid skrapning trots att en
// manuell koll av samma annons-ID:n strax efteråt visade "0 mil" korrekt i
// samma fält. Snarare än att låta hela analysen misslyckas (och senare
// tyst poängsättas fel om undefined-värdet flöt vidare) är 0 ett tryggt
// antagande just när Försäljningsform explicit säger "Ny bil till salu" —
// till skillnad från en begagnad bil, där en saknad mätarställning ALDRIG
// ska gissas.
const parsedMileage = parseMileageStr(ad.mileage ?? specs['Miltal'])
const mileageKm = parsedMileage ?? (specs['Försäljningsform'] === 'Ny bil till salu' ? 0 : undefined)

const data: Partial<CarListing> = {
  brand:        specs['Märke'] ?? ad.title?.split(' ')[0],
  model:        specs['Modell'] ?? ad.title?.split(' ')[1],
  variant:      ad.subtitle ?? undefined,
  year:         parseInt(ad.model_year ?? specs['Modellår']) || undefined,
  price_sek:    parsePrice(ad.price),
  mileage_km:   mileageKm,
  fuel_type:    parseFuelType(ad.fuel ?? specs['Drivmedel']),
  transmission: parseTransmission(ad.transmission ?? specs['Växellåda']),
  horsepower:   specs['Effekt'] ? parseInt(specs['Effekt'].replace(/\D/g, '')) || undefined : undefined,
  color:        specs['Färg'] ?? undefined,
  location:     specs['Bilens plats'] ?? undefined,
  seller_type:  ad.seller_type === 'dealer' ? 'dealer' : 'private',
  description:  ad.description ?? undefined,
  images:       ad.images?.slice(0, 6).map((i: any) => i.url ?? i.src ?? i).filter((i: any) => typeof i === 'string'),
  registration_number: specs['Registreringsnummer'] ?? undefined,
  registration_date: specs['Registreringsdatum'] ?? undefined,
  vin:          specs['Chassinummer'] ?? undefined,
  source_url:   url,
  source_site:  'blocket',
}

    if (!data.images || data.images.length === 0) {
      data.images = await fetchAdImages(adId)
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
