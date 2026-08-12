/**
 * Supabase client and typed DB helpers.
 *
 * All database access goes through this file.
 * Never import @supabase/supabase-js directly elsewhere.
 */

import { createClient } from '@supabase/supabase-js'
import {
  AnalysisResult,
  AnalysisStatus,
  BetterDeal,
  CarListing,
  ConfidenceResult,
  DealScores,
  PriceRange,
  Risk,
  Verdict,
} from '../../types'

// ─── Client ──────────────────────────────────────────────────────────────────

const supabaseUrl  = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseKey  = process.env.SUPABASE_SERVICE_ROLE_KEY!   // server-only key

if (!supabaseUrl || !supabaseKey) {
  throw new Error('Missing NEXT_PUBLIC_SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY')
}

export const supabase = createClient(supabaseUrl, supabaseKey)

// ─── Types matching the DB schema ────────────────────────────────────────────

interface AnalysisRow {
  id: string
  created_at: string
  source_url: string
  source_site: string
  status: AnalysisStatus
  error?: string

  // Car fields
  brand?: string
  model?: string
  variant?: string
  year?: number
  price_sek?: number
  mileage_km?: number
  fuel_type?: string
  transmission?: string
  horsepower?: number
  color?: string
  location?: string
  description?: string
  images?: string[]
  seller_type?: string
  registration_number?: string
  registration_date?: string
  vin?: string
  raw_html?: string

  // Scores
  deal_score?: number
  price_score?: number
  reliability_score?: number
  ownership_score?: number
  mileage_score?: number
  resale_score?: number

  // Confidence
  confidence_score?: number
  confidence_tier?: string
  confidence_reasons?: string[]

  // Pricing
  fair_price_low?: number
  fair_price_median?: number
  fair_price_high?: number
  price_delta_pct?: number

  // Analysis
  pros?: string[]
  cons?: string[]
  risks?: Risk[]
  verdict?: Verdict
  ai_summary?: string
  scoring_version?: string
  data_sources?: string[]
}

// ─── Cache lookup ─────────────────────────────────────────────────────────────

/**
 * Check if we've analyzed this URL recently.
 * Returns the analysis ID if a fresh (< 24h) completed analysis exists.
 */
export async function getCachedAnalysis(url: string): Promise<string | null> {
  const cutoff = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()

  const { data } = await supabase
    .from('analyses')
    .select('id')
    .eq('source_url', url)
    .eq('status', 'done')
    .gte('created_at', cutoff)
    .order('created_at', { ascending: false })
    .limit(1)
    .single()

  return data?.id ?? null
}

// ─── Create & update ─────────────────────────────────────────────────────────

export async function createPendingAnalysis(
  url: string,
  site: string
): Promise<string> {
  const { data, error } = await supabase
    .from('analyses')
    .insert({ source_url: url, source_site: site, status: 'pending' })
    .select('id')
    .single()

  if (error || !data) throw new Error(`Failed to create analysis: ${error?.message}`)
  return data.id
}

export async function markProcessing(id: string): Promise<void> {
  await supabase.from('analyses').update({ status: 'processing' }).eq('id', id)
}

export async function saveCarData(id: string, car: Partial<CarListing>, rawHtml?: string): Promise<void> {
  await supabase.from('analyses').update({
    brand:        car.brand,
    model:        car.model,
    variant:      car.variant,
    year:         car.year,
    price_sek:    car.price_sek,
    mileage_km:   car.mileage_km,
    fuel_type:    car.fuel_type,
    transmission: car.transmission,
    horsepower:   car.horsepower,
    color:        car.color,
    location:     car.location,
    description:  car.description,
    images:       car.images,
    seller_type:  car.seller_type,
    registration_number: car.registration_number,
    registration_date: car.registration_date,
    vin:          car.vin,
    raw_html:     rawHtml,
  }).eq('id', id)
}

export async function saveAnalysisResult(
  id: string,
  scores: DealScores,
  confidence: ConfidenceResult,
  pricing: PriceRange,
  pros: string[],
  cons: string[],
  risks: Risk[],
  verdict: Verdict,
  aiSummary: string,
  scoringVersion: string,
  dataSources: string[]
): Promise<void> {
  // A NaN slipping in here would otherwise fail silently: JSON.stringify(NaN)
  // is "null", so Supabase just stores SQL NULL with no error — the analysis
  // "succeeds" but the price card quietly shows 0 kr. Catch it here as a
  // last line of defense, not just at the point each value is computed.
  const numericFields = {
    deal_score: scores.deal, price_score: scores.price,
    reliability_score: scores.reliability, ownership_score: scores.ownership,
    mileage_score: scores.mileage, resale_score: scores.resale,
    confidence_score: confidence.score,
    fair_price_low: pricing.low, fair_price_median: pricing.median,
    fair_price_high: pricing.high, price_delta_pct: pricing.delta_pct,
  }
  const badFields = Object.entries(numericFields).filter(([, v]) => !Number.isFinite(v))
  if (badFields.length > 0) {
    console.error(`[saveAnalysisResult] Non-finite numeric field(s) for ${id}:`, badFields)
  }

  const { error } = await supabase.from('analyses').update({
    ...numericFields,
    confidence_tier:      confidence.tier,
    confidence_reasons:   confidence.reasons,
    pros,
    cons,
    risks,
    verdict,
    ai_summary:           aiSummary,
    scoring_version:      scoringVersion,
    data_sources:         dataSources,
    status:               'done',
  }).eq('id', id)

  if (error) throw new Error(`Failed to save analysis: ${error.message}`)
}

export async function markError(id: string, error: string): Promise<void> {
  await supabase.from('analyses').update({ status: 'error', error }).eq('id', id)
}

// ─── Fetch for results page ───────────────────────────────────────────────────

export async function getAnalysis(id: string): Promise<AnalysisResult | null> {
  const { data, error } = await supabase
    .from('analyses')
    .select('*')
    .eq('id', id)
    .single()

  if (error || !data) return null

  const row = data as AnalysisRow
  if (row.status !== 'done') return null

  return {
    id: row.id,
    car: {
      brand:        row.brand ?? '',
      model:        row.model ?? '',
      variant:      row.variant,
      year:         row.year ?? 0,
      price_sek:    row.price_sek ?? 0,
      mileage_km:   row.mileage_km ?? 0,
      fuel_type:    (row.fuel_type as any) ?? 'Bensin',
      transmission: (row.transmission as any) ?? 'Manuell',
      horsepower:   row.horsepower,
      color:        row.color,
      location:     row.location,
      description:  row.description,
      images:       row.images,
      seller_type:  (row.seller_type as any) ?? 'private',
      registration_number: row.registration_number,
      registration_date: row.registration_date,
      vin:          row.vin,
      source_url:   row.source_url,
      source_site:  (row.source_site as any),
    },
    scores: {
      deal:        row.deal_score ?? 0,
      price:       row.price_score ?? 0,
      reliability: row.reliability_score ?? 0,
      ownership:   row.ownership_score ?? 0,
      mileage:     row.mileage_score ?? 0,
      resale:      row.resale_score ?? 0,
    },
    confidence: {
      score:   row.confidence_score ?? 50,
      tier:    (row.confidence_tier as any) ?? 'medium',
      reasons: row.confidence_reasons ?? [],
    },
    pricing: {
      low:           row.fair_price_low ?? 0,
      median:        row.fair_price_median ?? 0,
      high:          row.fair_price_high ?? 0,
      delta_pct:     row.price_delta_pct ?? 0,
      interpretation: formatDeltaInterpretation(row.price_delta_pct ?? 0),
    },
    pros:      row.pros ?? [],
    cons:      row.cons ?? [],
    risks:     row.risks ?? [],
    verdict:   row.verdict ?? 'Okej affär',
    ai_summary: row.ai_summary ?? '',
    meta: {
      analyzed_at:     row.created_at,
      scoring_version: row.scoring_version ?? '1.0.0',
      data_sources:    row.data_sources ?? ['static_reference_v1'],
      cached:          false,
    },
  }
}

function formatDeltaInterpretation(delta: number): string {
  // delta är en andel (0.0283 = 2.83%) — måste multipliceras med 100 innan
  // toFixed(), annars blir t.ex. 2.8% till "0.0" (toFixed rundar decimal-
  // talet 0.0283 till en decimal, inte procentsatsen).
  const absPct = (Math.abs(delta) * 100).toFixed(1)
  if (delta > 0.03)  return `Priset är ungefär ${absPct}% under estimerat median`
  if (delta < -0.03) return `Priset är ungefär ${absPct}% över estimerat median`
  return `Priset är ungefär i linje med estimerat median (${absPct}% ${delta >= 0 ? 'under' : 'över'})`
}

// ─── Feedback ─────────────────────────────────────────────────────────────────

export async function saveFeedback(
  analysisId: string,
  data: {
    was_accurate?: boolean
    actual_sale_price?: number
    feedback_type?: string
    notes?: string
  }
): Promise<void> {
  await supabase.from('analysis_feedback').insert({
    analysis_id: analysisId,
    ...data,
  })
}

// ─── Market data queries ──────────────────────────────────────────────────────

// Under denna gräns är medianen för brusig för att lita på framför den
// statiska referensdatan — se data/marketMedians.ts som fallback.
const MIN_LIVE_MEDIAN_SAMPLE_SIZE = 5

export async function getMarketMedian(
  brand: string,
  model: string,
  year: number
): Promise<{ median: number; sample_size: number } | null> {
  try {
    // get_market_median() är en RETURNS TABLE-funktion — RPC ger tillbaka
    // en array av rader, inte objektet direkt.
    const { data, error } = await supabase.rpc('get_market_median', {
      p_brand: brand, p_model: model, p_year: year,
    })
    if (error) return null

    const row = data?.[0]
    if (!row || row.median == null || row.sample_size < MIN_LIVE_MEDIAN_SAMPLE_SIZE) return null

    return { median: Number(row.median), sample_size: Number(row.sample_size) }
  } catch {
    return null
  }
}

// ─── Market listing write-back ────────────────────────────────────────────────
// Varje lyckad analys via /api/analyze har redan skrapat en verklig annons
// (pris, miltal, år) — spara den även i market_listings så att den bidrar
// till framtida marknadsmedianer, precis som scraper-service/nightly.ts gör.
// Best-effort: fel här ska aldrig spräcka en analys.

// Mirrors the same checks in scraper-service/nightly.ts's toMarketListingRow()
// — can't share code across the two deployments (scraper-service builds
// independently, see its own comments), so kept in sync manually.
const IMPLAUSIBLE_LOW_PRICE_SEK = 20000
const MIN_AGE_YEARS_FOR_LOW_PRICE = 10
const MIN_MILEAGE_KM_FOR_LOW_PRICE = 150000

export async function saveMarketListing(car: Partial<CarListing>): Promise<void> {
  if (!car.source_url || !car.brand || !car.model || !car.year) return
  if (!car.price_sek || car.price_sek < 5000 || car.price_sek > 10_000_000) return
  // Verklig referensdata (data/referenceData.ts) klustrar 2008–2022 — en
  // äldre årsmodell är en annan bilgeneration än vad vår prismodell täcker.
  if (car.year < 2010 || car.year > new Date().getFullYear() + 1) return
  if (car.mileage_km == null || car.mileage_km < 0 || car.mileage_km > 1_000_000) return

  // Ett mycket lågt pris är bara rimligt för en genuint gammal/slitstark
  // bil. Verifierat: leasingövertag (t.ex. en nästan ny VW ID.3 för 5 400 kr)
  // ger inget separat Försäljningsform-värde att filtrera på som ren
  // leasing gör, men delar samma tecken — ung bil, lite mil, orimligt lågt
  // pris.
  if (car.price_sek < IMPLAUSIBLE_LOW_PRICE_SEK) {
    const ageYears = new Date().getFullYear() - car.year
    if (ageYears < MIN_AGE_YEARS_FOR_LOW_PRICE && car.mileage_km < MIN_MILEAGE_KM_FOR_LOW_PRICE) return
  }

  try {
    // Samma bil kan ligga ute på både Blocket och Wayke samtidigt — RPC:n
    // matchar på VIN när det finns (oavsett source_url) istället för att
    // bara dedupa på source_url, så den inte räknas dubbelt i marknadsmedianen.
    await supabase.rpc('upsert_market_listing', {
      p_source_url:  car.source_url,
      p_source_site: car.source_site,
      p_brand:       car.brand,
      p_model:       car.model,
      p_variant:     car.variant ?? null,
      p_year:        car.year,
      p_price_sek:   car.price_sek,
      p_mileage_km:  car.mileage_km,
      p_fuel_type:   car.fuel_type ?? null,
      p_transmission: car.transmission ?? null,
      p_location:    car.location ?? null,
      p_seller_type: car.seller_type ?? null,
      p_vin:         car.vin ?? null,
      p_registration_number: car.registration_number ?? null,
    })
  } catch {
    // best-effort — misslyckad skrivning ska inte påverka analysen
  }
}

// ─── Live model reference lookup ──────────────────────────────────────────────
// Queries the seeded model_references table in Supabase.
// Falls back to TypeScript static data if the query fails or returns nothing.
// This becomes the primary source once Phase 2 market data is live.

export interface LiveModelRef {
  base_price_sek:           number
  depreciation_rate:        number
  avg_mil_per_year:         number
  price_per_1000_extra_mil: number
  reliability_base:         number
  resale_base:              number
  notes:                    string | null
}

export async function getLiveModelReference(
  brand: string,
  model: string,
  year: number,
): Promise<LiveModelRef | null> {
  try {
    // Try exact match first (brand + model + year within range)
    const { data: exact } = await supabase
      .from('model_references')
      .select('base_price_sek, depreciation_rate, avg_mil_per_year, price_per_1000_extra_mil, reliability_base, resale_base, notes')
      .ilike('brand', brand)
      .ilike('model', model)
      .lte('year_from', year)
      .gte('year_to', year)
      .limit(1)
      .single()

    if (exact) return exact as LiveModelRef

    // Fallback: brand + model without year constraint
    const { data: brandModel } = await supabase
      .from('model_references')
      .select('base_price_sek, depreciation_rate, avg_mil_per_year, price_per_1000_extra_mil, reliability_base, resale_base, notes')
      .ilike('brand', brand)
      .ilike('model', model)
      .order('year_to', { ascending: false })
      .limit(1)
      .single()

    if (brandModel) return brandModel as LiveModelRef

    return null
  } catch {
    // Network error or table not seeded yet — scoring engine falls back to static data
    return null
  }
}

// ─── Live known issues lookup ─────────────────────────────────────────────────
// Returns model- and year-specific known issues from the database.
// Falls back gracefully to empty array on error.

export interface LiveKnownIssue {
  rule_id:     string
  severity:    'high' | 'medium' | 'low'
  title:       string
  description: string
}

export async function getLiveKnownIssues(
  brand: string,
  model: string,
  year: number,
  fuelType: string,
): Promise<LiveKnownIssue[]> {
  try {
    const { data, error } = await supabase
      .from('known_issues')
      .select('rule_id, severity, title, description')
      .ilike('brand', brand)
      .or(`model.ilike.${model},model.is.null`)
      .or(`year_from.lte.${year},year_from.is.null`)
      .or(`year_to.gte.${year},year_to.is.null`)
      .or(`fuel_type.ilike.${fuelType},fuel_type.is.null`)

    if (error || !data) return []
    return data as LiveKnownIssue[]
  } catch {
    return []
  }
}

// ─── Market listing scoring (pages/api/cron/score-listings.ts) ───────────────
// deal_score needs periodic re-scoring, not just a one-time value at insert
// time — get_market_median() is computed live from market_listings, so a
// score computed when only a couple of rows exist for a brand/model goes
// stale once more accumulate. deal_score_updated_at drives which rows are
// due: never-scored rows first, then the oldest scores.

const SCORE_STALE_AFTER_HOURS = 24

export interface ListingToScore {
  id: string
  brand: string
  model: string
  variant: string | null
  year: number
  price_sek: number
  mileage_km: number
  fuel_type: string
  transmission: string
  location: string | null
  seller_type: string | null
  source_url: string
  source_site: string
  registration_number: string | null
  vin: string | null
}

export async function getListingsNeedingScore(limit: number): Promise<ListingToScore[]> {
  const staleCutoff = new Date(Date.now() - SCORE_STALE_AFTER_HOURS * 3600_000).toISOString()

  const { data, error } = await supabase
    .from('market_listings')
    .select('id, brand, model, variant, year, price_sek, mileage_km, fuel_type, transmission, location, seller_type, source_url, source_site, registration_number, vin')
    .is('sold_at', null)
    .or(`deal_score_updated_at.is.null,deal_score_updated_at.lt.${staleCutoff}`)
    .order('deal_score_updated_at', { ascending: true, nullsFirst: true })
    .limit(limit)

  if (error || !data) return []
  return data as ListingToScore[]
}

export async function saveListingScore(id: string, dealScore: number): Promise<void> {
  await supabase.from('market_listings').update({
    deal_score: dealScore,
    deal_score_updated_at: new Date().toISOString(),
  }).eq('id', id)
}

// ─── Better-deal suggestions (analysis page) ──────────────────────────────────
// Only ever surfaces listings that score MEANINGFULLY higher than the one
// being viewed (BETTER_DEAL_SCORE_MARGIN) — a marginal +1-2 point difference
// isn't worth undermining trust in the rest of the analysis over. Restricted
// to a similar year range and price band so "better" means a genuinely
// comparable alternative, not just any higher-scoring car of the same model
// regardless of budget.

const BETTER_DEAL_SCORE_MARGIN = 8
const BETTER_DEAL_YEAR_WINDOW   = 2
const BETTER_DEAL_PRICE_BAND    = 0.3
const BETTER_DEAL_LIMIT         = 3

export async function getBetterDeals(car: CarListing, dealScore: number): Promise<BetterDeal[]> {
  try {
    const minPrice = Math.round(car.price_sek * (1 - BETTER_DEAL_PRICE_BAND))
    const maxPrice = Math.round(car.price_sek * (1 + BETTER_DEAL_PRICE_BAND))

    const { data, error } = await supabase
      .from('market_listings')
      .select('brand, model, variant, year, price_sek, mileage_km, location, deal_score, source_url, source_site')
      .ilike('brand', car.brand)
      .ilike('model', car.model)
      .is('sold_at', null)
      .not('deal_score', 'is', null)
      .gte('deal_score', dealScore + BETTER_DEAL_SCORE_MARGIN)
      .gte('year', car.year - BETTER_DEAL_YEAR_WINDOW)
      .lte('year', car.year + BETTER_DEAL_YEAR_WINDOW)
      .gte('price_sek', minPrice)
      .lte('price_sek', maxPrice)
      .neq('source_url', car.source_url)
      .order('deal_score', { ascending: false })
      .limit(BETTER_DEAL_LIMIT)

    if (error || !data) return []
    return data as BetterDeal[]
  } catch {
    return []
  }
}

// ─── New-car list prices (Skatteverket) ───────────────────────────────────────
// Trim-level "what did this cost new" data, used as the reference price for
// essentially-new cars instead of the flat per-model basePrice — see the
// migration comment in data/schema.sql for why. Synced by
// pages/api/cron/sync-new-car-prices.ts, queried here at scoring time.

export interface NewCarPriceRow {
  source_code: string
  brand: string
  model_raw: string
  manufacturing_year: number
  price_sek: number
  fuel_type: string | null
}

export async function upsertNewCarPrices(rows: NewCarPriceRow[]): Promise<{ error: string | null }> {
  if (rows.length === 0) return { error: null }
  const { error } = await supabase
    .from('new_car_prices')
    .upsert(
      rows.map(r => ({ ...r, synced_at: new Date().toISOString() })),
      { onConflict: 'source_code' },
    )
  return { error: error?.message ?? null }
}

// Picks the closest trim match by word-overlap between our scraped variant
// text and Skatteverket's free-text model string. With no variant to go on
// and more than one trim for the model, there's no reasonable way to pick
// one over another — better to return nothing and let the caller fall back
// to the existing basePrice estimate than silently guess a random trim's price.
function pickBestTrimMatch(
  candidates: { model_raw: string; price_sek: number }[],
  variant: string | undefined,
): number | null {
  if (candidates.length === 1) return candidates[0].price_sek
  if (!variant) return null

  const variantTokens = variant.toLowerCase().split(/\s+/).filter(Boolean)
  let bestScore = 0
  let bestPrice: number | null = null
  for (const c of candidates) {
    const modelTokens = c.model_raw.toLowerCase().split(/\s+/)
    const overlap = variantTokens.filter(t => modelTokens.includes(t)).length
    if (overlap > bestScore) { bestScore = overlap; bestPrice = c.price_sek }
  }
  return bestScore >= 1 ? bestPrice : null
}

export async function getNewCarPrice(
  brand: string,
  model: string,
  variant: string | undefined,
  year: number,
): Promise<number | null> {
  try {
    // Try the listing's own model year first, then adjacent years — a
    // dealer's "model year" label doesn't always line up with which
    // manufacturing-year bucket Skatteverket happened to file the trim
    // under (we've seen pre-order listings labelled a year that Skatteverket
    // hasn't published prices for yet).
    for (const y of [year, year - 1, year + 1]) {
      const { data, error } = await supabase
        .from('new_car_prices')
        .select('model_raw, price_sek')
        .ilike('brand', brand)
        .ilike('model_raw', `%${model}%`)
        .eq('manufacturing_year', y)

      if (error || !data || data.length === 0) continue

      const price = pickBestTrimMatch(data, variant)
      if (price) return price
    }
    return null
  } catch {
    return null
  }
}

// ─── Depreciation curve (empirical, see data/schema.sql) ──────────────────────
// Computed by pages/api/admin/recompute-depreciation-curves.ts from
// market_listings + new_car_prices. Queried here at request time (not
// bundled client-side — see the comment on DepreciationCurvePoint in
// lib/scoring/ownershipCost.ts for why that type is duplicated there
// instead of imported from this file).

export interface DepreciationCurveRow {
  age_years: number
  retained_pct: number
  sample_size: number
}

export async function getDepreciationCurve(
  brand: string,
  model: string,
  yearFrom: number,
): Promise<DepreciationCurveRow[]> {
  try {
    const { data, error } = await supabase
      .from('depreciation_curves')
      .select('age_years, retained_pct, sample_size')
      .eq('brand', brand)
      .eq('model', model)
      .eq('year_from', yearFrom)

    if (error || !data) return []
    return data as DepreciationCurveRow[]
  } catch {
    return []
  }
}
