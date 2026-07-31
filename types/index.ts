export type SupportedSite = 'blocket' | 'wayke' | 'bytbil'
export type FuelType = 'Bensin' | 'Diesel' | 'El' | 'Hybrid' | 'Laddhybrid' | 'Gas'
export type Transmission = 'Manuell' | 'Automat'
export type SellerType = 'private' | 'dealer'
export type RiskLevel = 'high' | 'medium' | 'low'
export type Verdict = 'Bra affär' | 'Okej affär' | 'Tveksam affär'
export type ConfidenceTier = 'high' | 'medium' | 'low'
export type AnalysisStatus = 'pending' | 'processing' | 'done' | 'error'

export interface CarListing {
  brand: string
  model: string
  variant?: string
  year: number
  price_sek: number
  mileage_km: number
  fuel_type: FuelType
  transmission: Transmission
  horsepower?: number
  color?: string
  location?: string
  description?: string
  images?: string[]
  seller_type?: SellerType
  registration_number?: string
  registration_date?: string    // ISO-datum (YYYY-MM-DD) — ger exakt ålder, till skillnad från årsmodell
  vin?: string
  source_url: string
  source_site: SupportedSite
}

export interface SubScores {
  price: number
  reliability: number
  ownership: number
  mileage: number
  resale: number
}

export interface DealScores extends SubScores {
  deal: number
}

export interface PriceRange {
  low: number
  median: number
  high: number
  delta_pct: number        // negative = listing is cheaper than median (good)
  interpretation: string
}

export interface Risk {
  level: RiskLevel
  title: string
  description: string
  rule_id: string
}

export interface ConfidenceResult {
  score: number
  tier: ConfidenceTier
  reasons: string[]
}

export interface AnalysisResult {
  id: string
  car: CarListing
  scores: DealScores
  confidence: ConfidenceResult
  pricing: PriceRange
  pros: string[]
  cons: string[]
  risks: Risk[]
  verdict: Verdict
  ai_summary: string
  better_deals?: BetterDeal[]
  meta: {
    analyzed_at: string
    scoring_version: string
    data_sources: string[]
    cached: boolean
  }
}

export interface BetterDeal {
  brand: string
  model: string
  variant?: string
  year: number
  price_sek: number
  mileage_km: number
  location?: string
  deal_score: number
  source_url: string
  source_site: SupportedSite
}

export interface ScraperResult {
  success: boolean
  data?: Partial<CarListing>
  error?: string
  raw_html?: string        // stored for re-parsing without re-scraping
}
