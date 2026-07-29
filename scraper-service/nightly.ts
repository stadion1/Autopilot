/**
 * scraper-service/nightly.ts
 *
 * Se ../NIGHTLY_SCRAPER.md för specifikationen.
 *
 * Körs en gång per natt (Railway Cron Job, se DEPLOY.md) — hämtar sidor från
 * blocket-api.se:s allmänna bilsök, behåller bara annonser som matchar en av
 * modellerna vi bevakar (TRACKED_MODELS, samma modeller som data/referenceData.ts
 * i huvudappen) och skriver dem till Supabase-tabellen market_listings.
 *
 * VIKTIGT — avsteg från den ursprungliga specen, upptäckt genom att faktiskt
 * testa API:t:
 *
 * 1. blocket-api.se/v1/search/car tar INGEN sök-/filterparameter (varken
 *    q, make, model eller sort) — bara `page`. Den ger tillbaka ett
 *    ofiltrerat, relevanssorterat flöde av ALLA bilannonser (~143 000 st,
 *    50 per sida, max 50 sidor tillgängliga = ~2 500 annonser/natt). Vi kan
 *    alltså inte fråga "för varje modell i listan" som specen beskriver —
 *    i stället hämtar vi sidor ur det allmänna flödet och filtrerar
 *    klientsidan mot TRACKED_MODELS. Över många nätter byggs täckningen upp.
 *
 * 2. Blockets namngivning av modell/serie är inkonsekvent mellan märken
 *    (Volvo ger rena namn som "V60"; BMW/Mercedes ger antingen en
 *    motorvariant i `model` som "325i"/"GLA220 d", eller en grövre
 *    gruppering i `series` som "3-Serie"/"GLA-Klass"). matchTrackedModel()
 *    försöker först exakt `model`-träff, sedan en normaliserad `series`-
 *    träff. Vissa modeller kan behöva justeras när riktig data börjar
 *    strömma in — kolla loggarna efter de första körningarna.
 *
 * 3. Ingen separat "market_medians"-tabell skapas — data/schema.sql:s
 *    get_market_median()-funktion aggregerar redan live från
 *    market_listings vid varje anrop, så inget separat
 *    uppdateringssteg behövs.
 *
 * 4. "Markera som sålda" görs med en 5-nätters karenstid (inte direkt vid
 *    första natten en annons saknas), eftersom vi bara samplar en
 *    roterande delmängd (~2 500 av ~143 000) av det totala utbudet varje
 *    natt — en annons som inte syns ikväll behöver inte vara såld.
 */

import { supabase } from './supabase'
import { parseFuelType, parseTransmission } from './blocket'

// ─── Modeller vi bevakar ──────────────────────────────────────────────────────
// Härlett från data/referenceData.ts i huvudappen. Hålls som en separat,
// hårdkodad lista här eftersom scraper-service byggs/deployas fristående
// och inte kan importera filer utanför sin egen mapp (se Dockerfile).

const TRACKED_MODELS: { brand: string; model: string }[] = [
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
  { brand: 'Kia', model: 'EV6' },
  { brand: 'Kia', model: 'Sportage' },
  { brand: 'Mazda', model: 'CX-5' },
  { brand: 'Mercedes-Benz', model: 'C-klass' },
  { brand: 'Mercedes-Benz', model: 'E-klass' },
  { brand: 'Mercedes-Benz', model: 'GLC' },
  { brand: 'Mini', model: 'Cooper' },
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

// ─── Config ───────────────────────────────────────────────────────────────────

const SEARCH_URL      = 'https://blocket-api.se/v1/search/car'
const MAX_PAGES       = parseInt(process.env.NIGHTLY_MAX_PAGES ?? '20', 10)
const PAGE_DELAY_MS   = 1000
const SOLD_GRACE_DAYS = 5

// ─── Blocket search doc shape (bara fälten vi använder) ──────────────────────

interface SearchDoc {
  id?: string
  ad_id?: number
  canonical_url?: string
  make?: string
  model?: string
  series?: string
  model_specification?: string
  year?: number
  mileage?: number              // i mil (SCANDINAVIAN_MILE), inte km
  mileage_unit?: string
  price?: { amount?: number }
  fuel?: string
  transmission?: string
  location?: string
  org_id?: string
  organisation_name?: string
  regno?: string
}

interface SearchResponse {
  docs?: SearchDoc[]
  metadata?: { paging?: { current: number; last: number } }
}

// ─── Matchning mot bevakade modeller ──────────────────────────────────────────

function normalizeToken(s: string): string {
  return s.toLowerCase().replace(/-?\s?(serie|klass)$/i, '').replace(/\s+/g, '').trim()
}

function matchTrackedModel(doc: SearchDoc): { brand: string; model: string } | null {
  if (!doc.make) return null
  const brandMatches = TRACKED_MODELS.filter(
    t => t.brand.toLowerCase() === doc.make!.toLowerCase()
  )
  if (brandMatches.length === 0) return null

  // Tier 1: exakt träff på `model` (funkar för Volvo, Toyota, BMW X-modeller m.fl.)
  if (doc.model) {
    const modelNorm = normalizeToken(doc.model)
    const hit = brandMatches.find(t => normalizeToken(t.model) === modelNorm)
    if (hit) return hit
  }

  // Tier 2: normaliserad träff på `series` (funkar för BMW 3/5-serie, Mercedes C/E-klass)
  if (doc.series) {
    const seriesNorm = normalizeToken(doc.series)
    const hit = brandMatches.find(t => normalizeToken(t.model) === seriesNorm)
    if (hit) return hit
  }

  return null
}

// ─── Rad-mappning ─────────────────────────────────────────────────────────────

function toMarketListingRow(doc: SearchDoc, tracked: { brand: string; model: string }) {
  const priceSek  = doc.price?.amount
  const mileageKm = typeof doc.mileage === 'number' ? doc.mileage * 10 : undefined

  if (!doc.canonical_url) return null
  if (!priceSek || priceSek < 5000 || priceSek > 10_000_000) return null
  if (!doc.year || doc.year < 1980 || doc.year > new Date().getFullYear() + 1) return null
  if (mileageKm === undefined || mileageKm < 0 || mileageKm > 1_000_000) return null

  return {
    source_url:   doc.canonical_url,
    source_site:  'blocket',
    brand:        tracked.brand,
    model:        tracked.model,
    variant:      doc.model_specification ?? undefined,
    year:         doc.year,
    price_sek:    priceSek,
    mileage_km:   mileageKm,
    fuel_type:    parseFuelType(doc.fuel),
    transmission: parseTransmission(doc.transmission),
    location:     doc.location ?? undefined,
    seller_type:  doc.org_id || doc.organisation_name ? 'dealer' : 'private',
    registration_number: doc.regno ?? undefined,
  }
}

// ─── Hämtning ─────────────────────────────────────────────────────────────────

async function fetchSearchPage(page: number): Promise<SearchDoc[]> {
  console.log(`  Hämtar sida ${page}...`)
  try {
    const res = await fetch(`${SEARCH_URL}?page=${page}`, {
      headers: { Accept: 'application/json', 'User-Agent': 'bilanalys-nightly/1.0' },
      signal: AbortSignal.timeout(15000),
    })
    if (!res.ok) {
      console.warn(`  Sida ${page}: HTTP ${res.status}, hoppar över`)
      return []
    }
    const json = (await res.json()) as SearchResponse
    return json.docs ?? []
  } catch (err: any) {
    console.warn(`  Sida ${page}: fel (${err?.message ?? err}), hoppar över`)
    return []
  }
}

function sleep(ms: number) {
  return new Promise(resolve => setTimeout(resolve, ms))
}

// ─── Main ─────────────────────────────────────────────────────────────────────

async function run() {
  const startedAt = Date.now()
  console.log(`\n[nightly] Startar — max ${MAX_PAGES} sidor från ${SEARCH_URL}`)

  let docsSeen  = 0
  let matched   = 0
  let upserted  = 0
  const rows: NonNullable<ReturnType<typeof toMarketListingRow>>[] = []

  for (let page = 1; page <= MAX_PAGES; page++) {
    const docs = await fetchSearchPage(page)
    docsSeen += docs.length
    if (docs.length === 0) break   // slut på resultat eller fel — inget mer att hämta

    for (const doc of docs) {
      const tracked = matchTrackedModel(doc)
      if (!tracked) continue
      const row = toMarketListingRow(doc, tracked)
      if (!row) continue
      matched++
      rows.push(row)
    }

    await sleep(PAGE_DELAY_MS)
  }

  console.log(`[nightly] ${docsSeen} annonser genomsökta, ${matched} matchade bevakade modeller`)

  // Blockets sökresultat kan skifta mellan våra sekventiella sid-anrop (en
  // annons kan bumpas/postas medan vi bläddrar och dyka upp på två sidor),
  // så samma source_url kan förekomma flera gånger i `rows`. Postgres ON
  // CONFLICT DO UPDATE klarar inte att träffa samma rad två gånger i samma
  // sats — dedupa klientsidan innan vi batchar.
  const dedupedRows = Array.from(
    new Map(rows.map(r => [r.source_url, r])).values()
  )
  if (dedupedRows.length < rows.length) {
    console.log(`[nightly] ${rows.length - dedupedRows.length} dubbletter borttagna innan upsert`)
  }

  // En rad i taget via RPC istället för en batch-upsert — upsert_market_listing()
  // matchar på VIN/registreringsnummer (oavsett source_url) för att undvika att
  // samma bil räknas dubbelt om den är korslistad på t.ex. Wayke också, vilket
  // en enkel ON CONFLICT(source_url)-batch inte kan uttrycka.
  for (const row of dedupedRows) {
    const { error } = await supabase.rpc('upsert_market_listing', {
      p_source_url:  row.source_url,
      p_source_site: row.source_site,
      p_brand:       row.brand,
      p_model:       row.model,
      p_variant:     row.variant ?? null,
      p_year:        row.year,
      p_price_sek:   row.price_sek,
      p_mileage_km:  row.mileage_km,
      p_fuel_type:   row.fuel_type,
      p_transmission: row.transmission,
      p_location:    row.location ?? null,
      p_seller_type: row.seller_type,
      p_vin:         null,   // sökändpointen ger bara registreringsnummer, inget VIN
      p_registration_number: row.registration_number ?? null,
    })

    if (error) {
      console.error(`[nightly] Fel vid upsert av ${row.source_url}:`, error.message)
      continue
    }
    upserted++
  }

  console.log(`[nightly] ${upserted} rader upsertade till market_listings`)

  // Markera annonser som sålda — kräver mark_stale_listings_sold() från
  // migrationen längst ner i data/schema.sql
  const { data: soldCount, error: soldError } = await supabase.rpc('mark_stale_listings_sold', {
    p_grace_days: SOLD_GRACE_DAYS,
  })

  if (soldError) {
    console.error('[nightly] Fel vid markering av sålda annonser:', soldError.message)
  } else {
    console.log(`[nightly] ${soldCount ?? 0} annonser markerade som sålda (${SOLD_GRACE_DAYS} dagars karens)`)
  }

  const ms = Date.now() - startedAt
  console.log(`[nightly] Klart på ${(ms / 1000).toFixed(1)}s\n`)
}

run()
  .then(() => process.exit(0))
  .catch(err => {
    console.error('[nightly] Fatalt fel:', err)
    process.exit(1)
  })
