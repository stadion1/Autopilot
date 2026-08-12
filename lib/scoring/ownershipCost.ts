/**
 * ownershipCost.ts
 *
 * Uppskattar den totala ägandekostnaden per år över de kommande 5 åren,
 * uppdelat i värdeminskning, service, försäkring, skatt, bränsle och
 * (valfritt) finansieringskostnad.
 *
 * Värdeminskning bygger på samma verifierade depreciation-tabell
 * (data/referenceData.ts) som resten av analysmotorn använder. Service,
 * försäkring, skatt och bränsle är grova schablonvärden för den svenska
 * marknaden — INTE modellspecifika mätningar — eftersom exakt försäkrings-
 * premie kräver förarens profil och exakt fordonsskatt kräver registrerings-
 * bevisets CO2-/viktuppgifter, som inte är tillgängliga här. Det ska alltid
 * visas tydligt som en uppskattning i UI:t.
 */

import type { CarListing } from '../../types'
import { lookupModelReference } from '../../data/referenceData'

// Empirisk värdeminskningskurva (se data/schema.sql:s depreciation_curves-
// migration och pages/api/admin/recompute-depreciation-curves.ts). Ren
// datatyp, ingen import av lib/supabase/client här — den filen drar in
// Supabase-service-role-klienten, och den här modulen buntas till klienten
// via app/analysis/[id]/page.tsx ('use client'). Kurvan hämtas server-side
// i pages/api/analysis/[id].ts och skickas med i AnalysisResult-JSON:en.
export interface DepreciationCurvePoint {
  age_years: number
  retained_pct: number
  sample_size: number
}

const MIN_CURVE_SAMPLES = 5

// Härleder årlig värdeminsknings-rate från två intilliggande kurvpunkter
// (kvarvarande andel av nypriset vid ålder A respektive A+1). Faller
// tillbaka på den platta referensdata-procenten om punkterna saknas, har
// för få annonser bakom sig, eller ger ett resultat som är för orimligt
// för att lita på (marknadsdata är brusig — en enskild årsklass kan råka
// visa en negativ eller absurt hög rate av slumpvariation).
function depreciationRateForAge(
  curve: DepreciationCurvePoint[] | undefined,
  ageFrom: number,
  fallbackRate: number,
): number {
  if (!curve) return fallbackRate
  const p0 = curve.find(p => p.age_years === ageFrom)
  const p1 = curve.find(p => p.age_years === ageFrom + 1)
  if (!p0 || !p1) return fallbackRate
  if (p0.sample_size < MIN_CURVE_SAMPLES || p1.sample_size < MIN_CURVE_SAMPLES) return fallbackRate
  if (!(p0.retained_pct > 0)) return fallbackRate

  const rate = 1 - p1.retained_pct / p0.retained_pct
  if (!Number.isFinite(rate) || rate < -0.05 || rate > 0.40) return fallbackRate
  return rate
}

export type FinancingType = 'cash' | 'loan'

export interface FinancingInput {
  type: FinancingType
  downPaymentPct: number   // 0–100, används bara när type === 'loan'
  interestRatePct: number  // nominell årsränta, t.ex. 6.5
  termYears: number        // löptid i år
}

export const DEFAULT_FINANCING: FinancingInput = {
  type: 'cash',
  downPaymentPct: 20,
  interestRatePct: 6.5,
  termYears: 5,
}

export interface YearlyOwnershipCost {
  year: number
  depreciation: number
  service: number
  insurance: number
  tax: number
  fuel: number
  financing: number
  total: number
}

export interface OwnershipCostCategory {
  key: 'depreciation' | 'service' | 'insurance' | 'tax' | 'fuel' | 'financing'
  label: string
  isEstimate: boolean
}

export const OWNERSHIP_COST_CATEGORIES: OwnershipCostCategory[] = [
  { key: 'depreciation', label: 'Värdeminskning', isEstimate: true },
  { key: 'service',      label: 'Service',        isEstimate: true },
  { key: 'insurance',    label: 'Försäkring',      isEstimate: true },
  { key: 'tax',          label: 'Skatt',           isEstimate: true },
  { key: 'fuel',         label: 'Bränsle',         isEstimate: true },
  { key: 'financing',    label: 'Finansiering',    isEstimate: false },
]

const PREMIUM_BRANDS = ['BMW', 'Mercedes-Benz', 'Audi', 'Porsche', 'Land Rover', 'Jaguar']

// Schablonförbrukning per mil (1 mil = 10 km) — generella riktvärden för
// fordonstypen, inte specifika för den enskilda modellen.
const FUEL_CONSUMPTION_PER_MIL: Record<string, number> = {
  'Bensin':     0.68,  // liter/mil
  'Diesel':     0.58,  // liter/mil
  'Hybrid':     0.48,  // liter/mil
  'Laddhybrid': 0.35,  // liter/mil (bensinandel)
  'El':         1.9,   // kWh/mil
  'Gas':        0.75,  // kg/mil
}

// Ungefärliga drivmedelspriser (schablon, sommaren 2026) — resultatet
// påverkas inte dramatiskt även om literpriset rör sig ±10%.
const FUEL_PRICE_PER_UNIT: Record<string, number> = {
  'Bensin':     19.5,
  'Diesel':     19.0,
  'Hybrid':     19.5,
  'Laddhybrid': 19.5,
  'El':         2.5,
  'Gas':        21,
}

function estimateAnnualFuelCost(car: CarListing, avgMilPerYear: number): number {
  if (car.fuel_type === 'Laddhybrid') {
    // Schablon: ~40% av milen på el, resten på bensin
    const petrolCost = avgMilPerYear * 0.6 * FUEL_CONSUMPTION_PER_MIL['Laddhybrid'] * FUEL_PRICE_PER_UNIT['Laddhybrid']
    const elCost     = avgMilPerYear * 0.4 * FUEL_CONSUMPTION_PER_MIL['El'] * FUEL_PRICE_PER_UNIT['El']
    return Math.round(petrolCost + elCost)
  }
  const consumption = FUEL_CONSUMPTION_PER_MIL[car.fuel_type] ?? 0.6
  const price = FUEL_PRICE_PER_UNIT[car.fuel_type] ?? 19
  return Math.round(avgMilPerYear * consumption * price)
}

function estimateAnnualServiceCost(car: CarListing, ageAtYear: number): number {
  const isPremium = PREMIUM_BRANDS.includes(car.brand)
  let base = isPremium ? 12000 : 6000
  if (car.fuel_type === 'Diesel') base *= 1.15
  if (car.fuel_type === 'El')     base *= 0.6
  if (ageAtYear > 8)      base *= 1.25
  else if (ageAtYear > 5) base *= 1.1
  return Math.round(base / 100) * 100
}

function estimateAnnualInsuranceCost(car: CarListing): number {
  const isPremium = PREMIUM_BRANDS.includes(car.brand)
  let base = 9000 + (car.horsepower ?? 150) * 12
  if (isPremium)              base *= 1.3
  if (car.fuel_type === 'El') base *= 1.1  // dyrare batteri vid vagnskada
  return Math.round(base / 100) * 100
}

// Kraftigt förenklad uppskattning av fordonsskatt (schablon per drivmedel).
// Exakt fordonsskatt kräver registreringsbevisets CO2-/viktuppgifter, som
// inte är tillgängliga i annonsdata.
function estimateAnnualTax(car: CarListing): number {
  if (car.fuel_type === 'El')         return 360
  if (car.fuel_type === 'Laddhybrid') return 1200
  if (car.fuel_type === 'Hybrid')     return 2000
  if (car.fuel_type === 'Diesel')     return 5200
  return 2800 // Bensin/Gas
}

// Annuitetslån — returnerar räntekostnaden (inte hela betalningen, eftersom
// amorteringen bara omvandlar kontanter till tillgång och redan är
// inräknad i värdeminskningen) per år under löptiden.
function annualLoanInterest(principal: number, annualRatePct: number, termYears: number): number[] {
  const months = Math.max(1, Math.round(termYears * 12))
  const r = annualRatePct / 100 / 12
  const monthlyPayment = r === 0
    ? principal / months
    : (principal * r) / (1 - Math.pow(1 + r, -months))

  let balance = principal
  const interestByYear: number[] = []
  for (let y = 0; y < termYears; y++) {
    let yearInterest = 0
    for (let m = 0; m < 12; m++) {
      if (balance <= 0) break
      const interest = balance * r
      const principalPaid = Math.min(balance, monthlyPayment - interest)
      balance -= principalPaid
      yearInterest += interest
    }
    interestByYear.push(Math.round(yearInterest))
  }
  return interestByYear
}

export function calculateOwnershipCosts(
  car: CarListing,
  financing: FinancingInput = DEFAULT_FINANCING,
  years = 5,
  curve?: DepreciationCurvePoint[],
): YearlyOwnershipCost[] {
  const { ref } = lookupModelReference(car.brand, car.model, car.year)
  const ageNow = Math.max(0, new Date().getFullYear() - car.year)

  const fuelAnnual      = estimateAnnualFuelCost(car, ref.avgMilPerYear)
  const insuranceAnnual = estimateAnnualInsuranceCost(car)

  const loanInterestByYear = financing.type === 'loan'
    ? annualLoanInterest(
        car.price_sek * (1 - financing.downPaymentPct / 100),
        financing.interestRatePct,
        financing.termYears,
      )
    : []

  let value = car.price_sek
  const rows: YearlyOwnershipCost[] = []

  for (let y = 1; y <= years; y++) {
    const rate = depreciationRateForAge(curve, ageNow + y - 1, ref.depreciation)
    const nextValue = value * (1 - rate)
    const depreciation = Math.round(value - nextValue)
    value = nextValue

    const service   = estimateAnnualServiceCost(car, ageNow + y)
    const tax        = estimateAnnualTax(car)
    const financingCost = financing.type === 'loan' ? (loanInterestByYear[y - 1] ?? 0) : 0

    rows.push({
      year: y,
      depreciation,
      service,
      insurance: insuranceAnnual,
      tax,
      fuel: fuelAnnual,
      financing: financingCost,
      total: depreciation + service + insuranceAnnual + tax + fuelAnnual + financingCost,
    })
  }

  return rows
}
