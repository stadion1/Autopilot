/**
 * Blocket parser — använder blocket-api.se istället för Playwright.
 * Ingen browser behövs. Snabbt, enkelt, pålitligt.
 */

import { CarListing, FuelType, ScraperResult, Transmission } from './types'

// ─── Modeller vi bevakar ──────────────────────────────────────────────────────
// Härlett från data/referenceData.ts i huvudappen. Hålls som en separat,
// hårdkodad lista här eftersom scraper-service byggs/deployas fristående
// och inte kan importera filer utanför sin egen mapp (se Dockerfile).
// Enda källan för listan inom scraper-service — nightly.ts importerar den
// härifrån istället för att hålla en egen kopia (två kopior var precis det
// mönster som orsakade model_references-glappet i huvudappen, se
// CLAUDE_CONTEXT.md).
export const TRACKED_MODELS: { brand: string; model: string }[] = [
  { brand: 'Audi', model: 'A3' },
  { brand: 'Audi', model: 'A4' },
  { brand: 'Audi', model: 'A6' },
  { brand: 'Audi', model: 'Q3' },
  { brand: 'Audi', model: 'Q5' },
  { brand: 'BMW', model: '3-serie' },
  { brand: 'BMW', model: '5-serie' },
  { brand: 'BMW', model: 'X3' },
  { brand: 'BMW', model: 'X5' },
  { brand: 'Dacia', model: 'Duster' },
  { brand: 'Ford', model: 'Focus' },
  { brand: 'Ford', model: 'Kuga' },
  { brand: 'Hyundai', model: 'IONIQ 5' },
  { brand: 'Hyundai', model: 'Tucson' },
  { brand: 'Hyundai', model: 'i30' },
  { brand: 'Kia', model: 'Ceed' },
  { brand: 'Kia', model: 'EV6' },
  { brand: 'Kia', model: 'Niro' },
  { brand: 'Kia', model: 'Picanto' },
  { brand: 'Kia', model: 'Sportage' },
  { brand: 'Mazda', model: 'CX-5' },
  { brand: 'Mercedes-Benz', model: 'C-klass' },
  { brand: 'Mercedes-Benz', model: 'E-klass' },
  { brand: 'Mercedes-Benz', model: 'GLC' },
  { brand: 'Mini', model: 'Cooper' },
  { brand: 'Nissan', model: 'Leaf' },
  { brand: 'Nissan', model: 'Qashqai' },
  { brand: 'Nissan', model: 'X-Trail' },
  { brand: 'Peugeot', model: '3008' },
  { brand: 'Renault', model: 'Clio' },
  { brand: 'Renault', model: 'Kadjar' },
  { brand: 'Seat', model: 'Leon' },
  { brand: 'Skoda', model: 'Kodiaq' },
  { brand: 'Skoda', model: 'Octavia' },
  { brand: 'Skoda', model: 'Superb' },
  { brand: 'Subaru', model: 'Outback' },
  { brand: 'Tesla', model: 'Model 3' },
  { brand: 'Tesla', model: 'Model Y' },
  { brand: 'Toyota', model: 'C-HR' },
  { brand: 'Toyota', model: 'Corolla' },
  { brand: 'Toyota', model: 'Land Cruiser' },
  { brand: 'Toyota', model: 'RAV4' },
  { brand: 'Toyota', model: 'Yaris' },
  { brand: 'Volkswagen', model: 'Golf' },
  { brand: 'Volkswagen', model: 'ID.3' },
  { brand: 'Volkswagen', model: 'ID.4' },
  { brand: 'Volkswagen', model: 'Passat' },
  { brand: 'Volkswagen', model: 'T-Cross' },
  { brand: 'Volkswagen', model: 'Tiguan' },
  { brand: 'Volvo', model: 'S60' },
  { brand: 'Volvo', model: 'V60 Cross Country' },
  { brand: 'Volvo', model: 'V60' },
  { brand: 'Volvo', model: 'V90 Cross Country' },
  { brand: 'Volvo', model: 'V90' },
  { brand: 'Volvo', model: 'XC40' },
  { brand: 'Volvo', model: 'XC60' },
  { brand: 'Volvo', model: 'XC90' },
]

export function normalizeToken(s: string): string {
  return s.toLowerCase().replace(/-?\s?(serie|klass)$/i, '').replace(/\s+/g, '').trim()
}

// Matchar en eller flera kandidatsträngar (t.ex. annonsens egen "Modell"-fält
// OCH ett kortnamn härlett ur titeln) mot TRACKED_MODELS för ett givet märke.
// Kandidaterna provas i ordning — första träffen vinner. Behövs eftersom
// Blockets per-annons-API ger modellnamnet som en specifik motorvariant
// ("E450", "320i", "GLA220 d") snarare än modellfamiljen vi bevakar
// ("E-klass", "3-serie", "GLA"): utan detta missar market-median- och
// model_references-uppslagen data som faktiskt finns (verifierat: en
// Mercedes E450-annons fick "Misslyckades att spara" trots att
// market_listings hade 8 rader för Mercedes-Benz E-klass samma årsmodell —
// annonsen letade bara efter modellnamnet "E450", aldrig "E-klass").
// Samma tvåstegsidé som nightly.ts:s matchTrackedModel() redan löser för
// nattens sökresultat-baserade insamling (som har en separat `series`-fält
// för just detta) — ad-hämtningsflödet här körde aldrig igenom den logiken.
export function findTrackedModel(brand: string | undefined, candidates: (string | undefined)[]): string | null {
  if (!brand) return null
  const brandMatches = TRACKED_MODELS.filter(t => t.brand.toLowerCase() === brand.toLowerCase())
  if (brandMatches.length === 0) return null

  for (const candidate of candidates) {
    if (!candidate) continue
    const norm = normalizeToken(candidate)
    const hit = brandMatches.find(t => normalizeToken(t.model) === norm)
    if (hit) return hit.model
  }
  return null
}

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

function sleep(ms: number) {
  return new Promise(resolve => setTimeout(resolve, ms))
}

// blocket-api.se verkar ibland inte hunnit färdigindexera en väldigt nyss
// inlagd "Ny bil till salu"-annons vid första förfrågan — verifierat
// upprepade gånger på flera Volvo XC60/V60/XC90-annonser: mileage helt
// frånvarande (varken i toppnivåfältet eller specifications.Miltal) vid
// skrapning, men en manuell koll av exakt samma annons-ID några minuter
// senare visade "0 mil" korrekt på BÅDA ställena. Fördröjningen är INTE
// konstant — ett första försök med bara ~4s total omförsökstid (1,5s+2,5s)
// visade sig otillräckligt för vissa annonser trots att det räckte för
// andra. Utökat till upp till 20s total väntetid, inom Railway-tjänstens
// egen timeout-budget (se server.ts — höjd i samma ändring). Eftersom hela
// specifications-objektet verkar vara ofullständigt (inte bara
// Miltal-fältet för sig) räcker det inte att leta efter en annan signal i
// samma svar — hela svaret måste hämtas om.
async function fetchAdWithRetry(adId: string): Promise<any> {
  const RETRY_DELAYS_MS = [1500, 2000, 3000, 4000, 4500]

  for (let attempt = 0; ; attempt++) {
    const res = await fetch(`https://blocket-api.se/v1/ad/car?id=${adId}`, {
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'bilanalys/1.0',
      },
    })
    if (!res.ok) throw new Error(`blocket-api.se svarade med ${res.status}`)

    const ad = await res.json()
    const hasMileage = typeof ad.mileage === 'string' || typeof ad.specifications?.['Miltal'] === 'string'
    if (hasMileage || attempt >= RETRY_DELAYS_MS.length) return ad

    console.log(`  blocket-api.se saknar mileage för ${adId}, försöker igen om ${RETRY_DELAYS_MS[attempt]}ms (försök ${attempt + 1})`)
    await sleep(RETRY_DELAYS_MS[attempt])
  }
}

export async function parseBlocket(_: unknown, url: string): Promise<ScraperResult> {
  try {
    const adId = extractAdId(url)
    if (!adId) return { success: false, error: 'Kunde inte extrahera annons-ID från URL' }

    console.log(`  Anropar blocket-api.se för annons ${adId}`)

    let ad: any
    try {
      ad = await fetchAdWithRetry(adId)
    } catch (err: any) {
      return { success: false, error: err.message ?? `blocket-api.se svarade inte` }
    }
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

// fetchAdWithRetry ovan tar hand om det vanliga fallet (mileage saknas för
// att blocket-api.se inte hunnit indexera klart). Om det ändå är borta
// efter alla omförsök, och annonsen explicit är taggad "Ny bil till salu",
// är 0 ett tryggt sista-utväg-antagande — till skillnad från en begagnad
// bil, där en saknad mätarställning ALDRIG ska gissas.
const parsedMileage = parseMileageStr(ad.mileage ?? specs['Miltal'])
const mileageKm = parsedMileage ?? (specs['Försäljningsform'] === 'Ny bil till salu' ? 0 : undefined)

const rawBrand = specs['Märke'] ?? ad.title?.split(' ')[0]
const rawModel = specs['Modell'] ?? ad.title?.split(' ')[1]
// Titelns andra ord är ofta ett kortare seriennamn än specs['Modell']
// (t.ex. titel "Mercedes-Benz E" mot specs['Modell'] "E450") — samma roll
// som `series`-fältet spelar för nightly.ts:s sökresultat-baserade matchning.
const titleShortCandidate = ad.title?.split(' ')[1]
const trackedModel = findTrackedModel(rawBrand, [rawModel, titleShortCandidate])
if (trackedModel && trackedModel !== rawModel) {
  console.log(`  Normaliserar modellnamn: "${rawModel}" -> "${trackedModel}" (bevakad modell)`)
}

const data: Partial<CarListing> = {
  brand:        rawBrand,
  model:        trackedModel ?? rawModel,
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
