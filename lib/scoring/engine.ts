/**
 * Scoring engine v1.2
 *
 * Förändring från v1.1:
 * scorePrice() använder nu MARKET_MEDIANS (faktiska Blocket-priser per modell/år)
 * istället för teoretisk deprecieringsformel.
 * Felet i v1.1: basePrice * (1-rate)^age gav ~23% för låga estimat
 * på populära svenska modeller som håller värdet bättre än formeln antar.
 *
 * Verdict-trösklar justerade baserat på testresultat:
 *   Bra affär:     >= 68  (var 72)
 *   Okej affär:    >= 52  (var 55)
 *   Tveksam affär: <  52
 */

import { CarListing, ConfidenceResult, DealScores, PriceRange, Risk } from '../../types'
import { lookupModelReference } from '../../data/referenceData'
import { lookupMarketMedian } from '../../data/marketMedians'
import { getMarketMedian } from '../supabase/client'

export const SCORING_VERSION = '1.2.0'

const CURRENT_YEAR = new Date().getFullYear()

// Exakt ålder i år via registreringsdatum när det finns, annars den grova
// (CURRENT_YEAR - årsmodell). Årsmodellen ensam underskattar systematiskt
// åldern — en "2025 års modell" kan vara registrerad redan hösten 2024, så
// en bil som ser "1 år gammal" ut på årsmodell kan i verkligheten ha
// funnits i trafik i snart två år. Det gjorde att t.ex. en 2025-bil med
// 3 000 mil (helt normalt efter ~1,5 år) kunde flaggas som "hög
// mätarställning" trots att den inte kört mer än väntat för sin faktiska ålder.
function vehicleAgeYears(car: CarListing): number {
  if (car.registration_date) {
    const regDate = new Date(car.registration_date)
    if (!isNaN(regDate.getTime())) {
      const days = (Date.now() - regDate.getTime()) / (1000 * 60 * 60 * 24)
      return days / 365.25
    }
  }
  return CURRENT_YEAR - car.year
}

const WEIGHTS = {
  price:       0.30,
  reliability: 0.25,
  ownership:   0.20,
  mileage:     0.15,
  resale:      0.10,
}

// ─── Known issues ─────────────────────────────────────────────────────────────

interface KnownIssue {
  brand: string; model?: string; yearFrom?: number; yearTo?: number
  fuelType?: string; severity: 'high' | 'medium' | 'low'
  ruleId: string; title: string; description: string
}

const KNOWN_ISSUES: KnownIssue[] = [
  { brand:'Volvo',  model:'V60',    yearFrom:2020, yearTo:2021, severity:'low',
    ruleId:'volvo_v60_2020_brakes', title:'Återkallelse: bromsmjukvara (2020–2021)',
    description:'Kontrollera med Volvos återförsäljare att ABS-mjukvaruuppdatering är utförd.' },
  { brand:'Volvo',  model:'XC60',   yearFrom:2020, yearTo:2021, severity:'low',
    ruleId:'volvo_xc60_2020_brakes', title:'Återkallelse: bromsmjukvara (2020–2021)',
    description:'Samma ABS-återkallelse som V60 2020–2021. Kontrollera med Volvo-verkstad.' },
  { brand:'Volvo',  model:'XC60',   yearFrom:2018, yearTo:2020, severity:'low',
    ruleId:'volvo_xc60_sensus_freeze', title:'Sensus infotainment: uppfrysningar',
    description:'Mjukvaruuppdatering finns via auktoriserad Volvo-verkstad, ofta kostnadsfritt.' },
  { brand:'Volvo',  model:'XC90',   yearFrom:2015, yearTo:2019, fuelType:'Laddhybrid', severity:'medium',
    ruleId:'volvo_xc90_t8_oil_dilution', title:'T8 PHEV: oljespädning vid kortdistans­körning',
    description:'Kontrollera oljans kvalitet. Byt oftare om bilen körts mycket kort.' },
  { brand:'BMW',    model:'3-serie', yearFrom:2012, yearTo:2018, fuelType:'Bensin', severity:'high',
    ruleId:'bmw_n20_timing_chain', title:'N20/N26 motor: timing chain-slitage',
    description:'Risk för motorhaveri. Kontrollera servicehistorik. Lyssna efter skrammel vid kallstart.' },
  { brand:'BMW',    model:'3-serie', yearFrom:2006, yearTo:2013, fuelType:'Bensin', severity:'high',
    ruleId:'bmw_n52_valve_cover', title:'N52 motor: ventilkåpa och oljespill',
    description:'Plastventilkåpa spricker med åren. Kontrollera undersidan av motorn för oljespår.' },
  { brand:'BMW',    model:'5-serie', yearFrom:2016, yearTo:2020, severity:'medium',
    ruleId:'bmw_g30_infotainment_crash', title:'G30 iDrive 6: programvarukrascher',
    description:'Kontrollera att senaste programvara är installerad via BMW-verkstad.' },
  { brand:'Volkswagen', model:'Golf', yearFrom:2013, yearTo:2016, severity:'high',
    ruleId:'vw_dsg7_dq200_shudder', title:'DSG7 (DQ200): ryckningar vid låg hastighet',
    description:'Mjukvaru­uppdatering och mekatro­nikbyte finns via auktoriserad VW-verkstad.' },
  { brand:'Volkswagen', model:'Golf', yearFrom:2019, yearTo:2022, severity:'medium',
    ruleId:'vw_golf8_infotainment_bugs', title:'Golf 8: allvarliga mjukvarufel vid lansering',
    description:'Kontrollera att mjukvara post-2022 är installerad. Berör infotainment och förar­assistent.' },
  { brand:'Volkswagen', model:'Passat', yearFrom:2014, yearTo:2018, fuelType:'Diesel', severity:'medium',
    ruleId:'vw_ea288_egr_fouling', title:'EA288 2.0 TDI: EGR-ventil och sotning',
    description:'Ojämn tomgång och reducerad effekt. Förebygg med motorvärmare.' },
  { brand:'Volkswagen', model:'ID.3', yearFrom:2020, yearTo:2021, severity:'high',
    ruleId:'vw_id3_software_launch', title:'ID.3 (2020–2021): genomgripande mjukvarubugg­ar',
    description:'Kontrollera att mjukvara >3.0 är installerad. Provkör ALLA assistans­system.' },
  { brand:'Mercedes-Benz', model:'C-klass', yearFrom:2014, yearTo:2018, severity:'medium',
    ruleId:'mercedes_w205_rust', title:'W205 C-klass: rost bakre fjädring',
    description:'Kontrollera undersidan noggrant, särskilt vid saltzonhistorik.' },
  { brand:'Ford', model:'Kuga', yearFrom:2019, yearTo:2020, fuelType:'Laddhybrid', severity:'high',
    ruleId:'ford_kuga_phev_fire_risk', title:'Kuga PHEV: brandriskretur (2021)',
    description:'Kontrollera ALLTID att Fords återkallelseåtgärd är utförd.' },
  { brand:'Ford', model:'Focus', yearFrom:2011, yearTo:2016, severity:'high',
    ruleId:'ford_focus_powershift_slip', title:'PowerShift DCT: slirning och kraftbortfall',
    description:'Ökänd konstruktion. Undvik dessa årsmodeller med PowerShift-växellåda.' },
  { brand:'Subaru', model:'Outback', yearFrom:2010, yearTo:2018, severity:'medium',
    ruleId:'subaru_boxer_head_gasket', title:'Boxer­motor: head gasket vid högt miltal',
    description:'Kontrollera kylvätska. Kräver korrekt service­intervall.' },
  { brand:'Mini', model:'Cooper', yearFrom:2014, yearTo:2019, severity:'medium',
    ruleId:'mini_b38_timing_chain', title:'B38/B48 motor: timing chain-slitage',
    description:'Lyssna efter skrammel vid kallstart. Rekommendera motorinspektion.' },
  { brand:'Tesla', model:'Model 3', yearFrom:2018, yearTo:2020, severity:'medium',
    ruleId:'tesla_m3_panel_gaps', title:'Tidig Model 3: karossfogar och lackkvalitet',
    description:'Kontrollera karossens jämnhet. Förhandlings­argument vid köp.' },
  { brand:'Tesla', model:'Model Y', yearFrom:2021, yearTo:2022, severity:'low',
    ruleId:'tesla_my_heat_pump', title:'Model Y värmepump: problem i extrem kyla',
    description:'OTA-uppdateringar finns. Kontrollera att senaste mjukvara är installerad.' },
  { brand:'Hyundai', model:'IONIQ 5', yearFrom:2021, yearTo:2022, severity:'low',
    ruleId:'ioniq5_brake_recall', title:'IONIQ 5: bromskraft­återkallelse (2022)',
    description:'Kontrollera med Hyundai-verkstad att åtgärden är utförd med bilens VIN.' },

  // Audi
  { brand:'Audi', model:'A4', yearFrom:2008, yearTo:2011, fuelType:'Bensin', severity:'high',
    ruleId:'audi_a4_ea888_gen1_timing_chain', title:'2.0 TFSI (EA888 Gen1): kedjespännare i plast',
    description:'Tidiga 2.0 TFSI-motorer har en kedjespännare i plast som kan gå sönder och orsaka motorhaveri. Lyssna efter skrammel vid kallstart och kontrollera servicehistorik.' },
  { brand:'Audi', model:'Q5', yearFrom:2008, yearTo:2011, fuelType:'Bensin', severity:'high',
    ruleId:'audi_q5_ea888_gen1_timing_chain', title:'2.0 TFSI (EA888 Gen1): kedjespännare i plast',
    description:'Samma motorfamilj och problem som A4. Lyssna efter skrammel vid kallstart och kontrollera servicehistorik.' },

  // Hyundai / Kia — ABS-modul brandrisk
  { brand:'Hyundai', model:'i30', yearFrom:2007, yearTo:2012, severity:'high',
    ruleId:'hyundai_i30_abs_fire_recall', title:'Återkallelse: ABS-modul med brandrisk (2020)',
    description:'ABS-modulen kan läcka bromsvätska internt och orsaka kortslutning och motorrumsbrand. Kontrollera med Hyundai-verkstad att åtgärden är utförd.' },
  { brand:'Hyundai', model:'Tucson', yearFrom:2016, yearTo:2021, severity:'high',
    ruleId:'hyundai_tucson_abs_fire_recall', title:'Återkallelse: ABS-brandrisk (kampanj 2020)',
    description:'Kontrollera med Hyundai-verkstad att ABS-återkallelsen är åtgärdad. Risk för motorrumsbrand.' },
  { brand:'Kia', model:'Stinger', yearFrom:2018, yearTo:2019, severity:'high',
    ruleId:'kia_stinger_fire_recall', title:'Återkallelse: brandrisk (2020/2021)',
    description:'Kontrollera med Kia-verkstad att brandriskåterkallelsen är åtgärdad med bilens VIN.' },

  // Nissan
  { brand:'Nissan', model:'Qashqai', yearFrom:2014, yearTo:2017, fuelType:'Bensin', severity:'medium',
    ruleId:'nissan_qashqai_cvt_overheat', title:'CVT-växellåda (Jatco): överhettning och nödläge',
    description:'Kan ge ryckig acceleration, ovanligt ljud och att växellådan går in i nödläge (limp mode) vid tät trafik/backar. Begär att CVT-oljan bytts regelbundet, trots att den ofta marknadsförs som "livstidsfylld".' },

  // Honda — 1.5 turbo bränslespädning
  { brand:'Honda', model:'CR-V', yearFrom:2016, yearTo:2018, fuelType:'Bensin', severity:'medium',
    ruleId:'honda_crv_1_5t_oil_dilution', title:'1.5 turbo: bränslespädning av motorolja',
    description:'Korta körsträckor kan späda ut motoroljan med bensin, särskilt i kallt klimat. Kontrollera oljenivå/lukt och fråga om förlängd garantiåtgärd är utförd.' },
  { brand:'Honda', model:'Civic', yearFrom:2017, yearTo:2018, fuelType:'Bensin', severity:'medium',
    ruleId:'honda_civic_1_5t_oil_dilution', title:'1.5 turbo: bränslespädning av motorolja',
    description:'Samma problem som CR-V med 1.5 turbo-motorn. Kontrollera att förlängd garantiåtgärd är utförd.' },

  // Volvo — D5 kamrem (äldre generation, före kedjedrift)
  { brand:'Volvo', model:'V70', yearFrom:2001, yearTo:2007, fuelType:'Diesel', severity:'high',
    ruleId:'volvo_v70_d5_timing_belt', title:'D5: kamremsspännare känd svaghet',
    description:'Spännaren kan gå sönder så att kamremmen hoppar eller går av, vilket ger motorhaveri. Kräver dokumenterat byte av kamrem, spännare och pumpar enligt intervall (ca var 5:e år/9 000 mil).' },
  { brand:'Volvo', model:'XC70', yearFrom:2001, yearTo:2007, fuelType:'Diesel', severity:'high',
    ruleId:'volvo_xc70_d5_timing_belt', title:'D5: kamremsspännare känd svaghet',
    description:'Samma kamremsproblem som V70 D5. Kräver dokumenterat kamremsbyte inom intervall.' },

  // Peugeot / Citroën — DV6/BlueHDi DPF och EGR
  { brand:'Peugeot', model:'308', yearFrom:2008, yearTo:2018, fuelType:'Diesel', severity:'medium',
    ruleId:'peugeot_308_dv6_dpf_egr', title:'1.6 HDi/BlueHDi: partikelfilter och EGR-problem',
    description:'Vanligt med igensatt partikelfilter och kärvande EGR-ventil, särskilt vid mycket korta körsträckor. Begär servicehistorik som visar DPF-regenerering.' },
  { brand:'Citroën', model:'C4', yearFrom:2008, yearTo:2018, fuelType:'Diesel', severity:'medium',
    ruleId:'citroen_c4_dv6_dpf_egr', title:'1.6 HDi/BlueHDi: partikelfilter och EGR-problem',
    description:'Samma motorfamilj och problematik som Peugeot 308. Vanligt med igensatt partikelfilter vid korta körsträckor.' },

  // Renault — TCe "livstidskedja"
  { brand:'Renault', model:'Clio', yearFrom:2013, yearTo:2019, fuelType:'Bensin', severity:'medium',
    ruleId:'renault_clio_tce_timing_chain', title:'0.9/1.2 TCe: kedjan kan sträckas i förtid',
    description:'"Livstidskedjan" kan sträckas redan vid 8 000–10 000 mil trots att den marknadsförs som underhållsfri. Lyssna efter skrammel vid kallstart och kontrollera servicehistorik.' },
  { brand:'Renault', model:'Captur', yearFrom:2013, yearTo:2019, fuelType:'Bensin', severity:'medium',
    ruleId:'renault_captur_tce_timing_chain', title:'0.9/1.2 TCe: kedjan kan sträckas i förtid',
    description:'Samma motorfamilj och problem som Clio. Lyssna efter skrammel vid kallstart och kontrollera servicehistorik.' },

  // Opel — 1.6 CDTi kedjespännare
  { brand:'Opel', model:'Astra', yearFrom:2009, yearTo:2018, fuelType:'Diesel', severity:'medium',
    ruleId:'opel_astra_1_6cdti_chain_rattle', title:'1.6 CDTi: kedjespännare utan packning',
    description:'Vanligt med skrammel vid kallstart pga oljeläckage i kedjespännaren. Kontrollera om en uppdaterad packning/spännare har monterats.' },
  { brand:'Opel', model:'Insignia', yearFrom:2009, yearTo:2018, fuelType:'Diesel', severity:'medium',
    ruleId:'opel_insignia_1_6cdti_chain_rattle', title:'1.6 CDTi: kedjespännare utan packning',
    description:'Samma problem som Astra. Skrammel vid kallstart som försvinner vid tomgång är ett typiskt tecken.' },

  // Skoda — DSG7 (DQ200), samma växellåda som drabbat VW-koncernens Golf
  { brand:'Skoda', model:'Octavia', yearFrom:2009, yearTo:2015, severity:'medium',
    ruleId:'skoda_octavia_dq200_dsg', title:'DSG7 (DQ200): mekatronik och kopplingsslitage',
    description:'Samma växellådstyp som drabbat VW Golf. Vanligt med ryck vid låg fart och behov av mekatronikbyte.' },
  { brand:'Skoda', model:'Fabia', yearFrom:2009, yearTo:2015, severity:'medium',
    ruleId:'skoda_fabia_dq200_dsg', title:'DSG7 (DQ200): mekatronik och kopplingsslitage',
    description:'Samma växellådstyp och problem som Octavia. Kontrollera senaste mjukvaruversion hos Skoda-verkstad.' },
]

function getKnownIssues(car: CarListing): KnownIssue[] {
  return KNOWN_ISSUES.filter(i => {
    if (i.brand.toLowerCase() !== car.brand.toLowerCase())               return false
    if (i.model && i.model.toLowerCase() !== car.model.toLowerCase())   return false
    if (i.yearFrom && car.year < i.yearFrom)                            return false
    if (i.yearTo   && car.year > i.yearTo)                              return false
    if (i.fuelType && i.fuelType !== car.fuel_type)                     return false
    return true
  })
}

// ─── Score: Price ─────────────────────────────────────────────────────────────
// Priority: 1) live median from market_listings (real Blocket sales data,
// see scraper-service/nightly.ts), 2) static MARKET_MEDIANS table,
// 3) theoretical depreciation model. medianResult is resolved by the caller
// (scoreVehicle) since the live lookup is async.

function scorePrice(
  car: CarListing,
  avgMilPerYear: number,
  pricePer1000ExtraMil: number,
  basePrice: number,
  depreciation: number,
  medianResult: { median: number; sample_size?: number } | null,
): { score: number; usedMedian: number | null; delta: number } {
  const age = Math.max(0, vehicleAgeYears(car))

  const referencePrice = medianResult
    ? medianResult.median
    : basePrice * Math.pow(1 - depreciation, age)  // fallback

  // Mileage adjustment: every 1000 mil over expected reduces value
  const expectedMil    = age * avgMilPerYear
  const surplusMil     = Math.max(0, car.mileage_km / 10 - expectedMil)
  const milAdj         = (surplusMil / 1000) * Math.abs(pricePer1000ExtraMil)
  const adjustedRef    = Math.max(0, referencePrice - milAdj)

  const delta = (adjustedRef - car.price_sek) / Math.max(1, adjustedRef)
  // positive delta = listing is cheaper than reference = good for buyer

  return {
    score: deltaToScore(delta),
    usedMedian: medianResult ? medianResult.median : null,
    delta,
  }
}

function deltaToScore(d: number): number {
  if (d >  0.18) return 98
  if (d >  0.10) return 90
  if (d >  0.04) return 80
  if (d > -0.04) return 68
  if (d > -0.10) return 52
  if (d > -0.18) return 35
  return 18
}

// ─── Score: Mileage ───────────────────────────────────────────────────────────

function scoreMileage(car: CarListing, avgMilPerYear: number): number {
  const age   = Math.max(1, vehicleAgeYears(car))
  const ratio = (car.mileage_km / 10) / Math.max(1, age * avgMilPerYear)

  if (ratio < 0.50) return 96
  if (ratio < 0.70) return 88
  if (ratio < 0.90) return 80
  if (ratio < 1.10) return 70
  if (ratio < 1.30) return 58
  if (ratio < 1.60) return 42
  if (ratio < 2.00) return 28
  return 14
}

// ─── Score: Reliability ───────────────────────────────────────────────────────

function scoreReliability(car: CarListing, reliabilityBase: number): number {
  let score = reliabilityBase
  const age = vehicleAgeYears(car)
  const mil = car.mileage_km / 10

  if      (age > 10) score -= 18
  else if (age >  8) score -= 12
  else if (age >  5) score -= 6
  else if (age >  3) score -= 2

  if      (mil > 20000) score -= 18
  else if (mil > 14000) score -= 10
  else if (mil >  9000) score -= 5
  else if (mil >  6000) score -= 2

  getKnownIssues(car).forEach(i => {
    if (i.severity === 'high')   score -= 10
    if (i.severity === 'medium') score -= 5
    if (i.severity === 'low')    score -= 2
  })

  return clamp(score, 10, 100)
}

// ─── Score: Ownership cost ────────────────────────────────────────────────────

function scoreOwnership(car: CarListing): number {
  const fuelBase: Record<string, number> = {
    'El': 88, 'Laddhybrid': 82, 'Hybrid': 75,
    'Bensin': 55, 'Diesel': 58, 'Gas': 52,
  }
  let score = fuelBase[car.fuel_type] ?? 55
  const age = vehicleAgeYears(car)

  if      (age > 8) score -= 12
  else if (age > 5) score -= 6
  else if (age > 3) score -= 2

  if (['BMW', 'Mercedes-Benz', 'Audi', 'Porsche'].includes(car.brand)) score -= 10
  if (['El', 'Laddhybrid'].includes(car.fuel_type) && age > 5)         score -= 8

  return clamp(score, 10, 100)
}

// ─── Score: Resale ────────────────────────────────────────────────────────────

function scoreResale(car: CarListing, resaleBase: number): number {
  let score = resaleBase
  const age = vehicleAgeYears(car)

  const fuelAdj: Record<string, number> = {
    'El': 4, 'Laddhybrid': 6, 'Hybrid': 4,
    'Bensin': 0, 'Diesel': -8, 'Gas': -5,
  }
  score += fuelAdj[car.fuel_type] ?? 0

  if      (age > 8) score -= 12
  else if (age > 5) score -= 6

  if (car.transmission === 'Automat') score += 4

  const neutral = ['svart', 'vit', 'grå', 'silver', 'blå']
  if (car.color && !neutral.some(c => car.color!.toLowerCase().includes(c))) score -= 5

  return clamp(score, 10, 100)
}

// ─── Composite ────────────────────────────────────────────────────────────────

function composite(s: Omit<DealScores, 'deal'>): number {
  return Math.round(
    s.price       * WEIGHTS.price +
    s.reliability * WEIGHTS.reliability +
    s.ownership   * WEIGHTS.ownership +
    s.mileage     * WEIGHTS.mileage +
    s.resale      * WEIGHTS.resale,
  )
}

// ─── Confidence ───────────────────────────────────────────────────────────────

function calculateConfidence(
  car: CarListing,
  usedMedian: number | null,
  basePrice: number,
  depreciation: number,
  isDefaultRef: boolean,
): ConfidenceResult {
  let score = 70
  const reasons: string[] = []

  if (isDefaultRef) {
    score -= 25
    reasons.push('Begränsad marknadsdata för denna modell')
  }

  if (!usedMedian) {
    score -= 10
    reasons.push('Ingen marknadsmedian tillgänglig — teoretiskt estimat används')
  }

  const age = vehicleAgeYears(car)
  const ref = usedMedian ?? basePrice * Math.pow(1 - depreciation, age)
  if (Math.abs(car.price_sek - ref) / ref > 0.40) {
    score -= 20
    reasons.push('Priset avviker kraftigt från marknadsvärde — kontrollera manuellt')
  }

  if (age <= 2) score += 10
  if (age > 10) { score -= 10; reasons.push('Äldre fordon — mer variation i skick') }

  const mil = car.mileage_km / 10
  if (mil > 20000) { score -= 12; reasons.push('Hög mätarställning ökar osäkerheten') }

  if (!car.description || car.description.length < 50) {
    score -= 8
    reasons.push('Kort annons — begränsad information')
  }

  if (['El', 'Laddhybrid'].includes(car.fuel_type) && age > 3) {
    score -= 5
    reasons.push('Elbil/laddhybrid — batterihälsa (SoH) okänd utan mätning')
  }

  return {
    score:   clamp(score, 15, 95),
    tier:    score >= 70 ? 'high' : score >= 45 ? 'medium' : 'low',
    reasons,
  }
}

// ─── Price range ──────────────────────────────────────────────────────────────

function calculatePricing(
  car: CarListing,
  usedMedian: number | null,
  basePrice: number,
  depreciation: number,
  avgMilPerYear: number,
  pricePer1000ExtraMil: number,
  confidence: ConfidenceResult,
): PriceRange {
  const age      = Math.max(0, vehicleAgeYears(car))
  const midpoint = usedMedian ?? basePrice * Math.pow(1 - depreciation, age)

  // Mileage adjustment
  const surplusMil = Math.max(0, car.mileage_km / 10 - age * avgMilPerYear)
  const milAdj     = (surplusMil / 1000) * Math.abs(pricePer1000ExtraMil)
  const adjusted   = Math.max(10000, midpoint - milAdj)

  // Range width depends on confidence
  const halfWidth = confidence.tier === 'high'   ? 0.07
                  : confidence.tier === 'medium' ? 0.11
                  : 0.16

  const low    = roundTo(adjusted * (1 - halfWidth), 5000)
  const median = roundTo(adjusted, 5000)
  const high   = roundTo(adjusted * (1 + halfWidth), 5000)
  const delta  = (adjusted - car.price_sek) / Math.max(1, adjusted)

  const absPct = (Math.abs(delta) * 100).toFixed(1)
  const interpretation =
    delta >  0.03 ? `Priset är ungefär ${absPct}% under estimerat median — gynnsamt för köparen`
  : delta < -0.03 ? `Priset är ungefär ${absPct}% över estimerat median`
  : 'Priset är i linje med estimerat median'

  return { low, median, high, delta_pct: delta, interpretation }
}

// ─── Risks ────────────────────────────────────────────────────────────────────

function detectRisks(car: CarListing, modelNotes: string | undefined, avgMilPerYear: number): Risk[] {
  const risks: Risk[] = []
  const mil      = car.mileage_km / 10
  const ageYears = vehicleAgeYears(car)   // exakt (registreringsdatum om möjligt) för ratio-beräkning
  const age      = Math.round(ageYears)   // avrundat för visningstext
  const desc = (car.description ?? '').toLowerCase()

  // Known model-specific issues
  getKnownIssues(car).forEach(issue =>
    risks.push({ level: issue.severity, title: issue.title,
                 description: issue.description, rule_id: issue.ruleId })
  )

  // Model notes warning
  if (modelNotes) {
    const warn = ['kontrollera','problem','kräver','haveri','rost','återkallelse','deprecierar']
    if (warn.some(k => modelNotes.toLowerCase().includes(k))) {
      risks.push({ level: 'low', title: `Notering om ${car.brand} ${car.model}`,
                   description: modelNotes, rule_id: 'model_notes' })
    }
  }

  // No service history
  const serviceWords = ['service','servad','servicebok','kvitto','verkstad','besiktad']
  if (!serviceWords.some(w => desc.includes(w)) && car.seller_type === 'private') {
    risks.push({ level: 'medium', title: 'Servicehistorik saknas i annonsen',
                 description: 'Begär servicebok eller kvitton från auktoriserad verkstad.',
                 rule_id: 'no_service_history' })
  }

  // High mileage — relativt förväntad mätarställning för bilens ålder,
  // samma ratio som scoreMileage() använder. En flat gräns (t.ex. 15 000 mil)
  // skulle träffa nästan alla äldre bilar oavsett om de faktiskt kört mycket.
  const expectedMil = Math.max(1, ageYears) * avgMilPerYear
  const mileageRatio = mil / expectedMil
  if (mileageRatio >= 1.6) {
    risks.push({ level: 'medium',
                 title: 'Hög mätarställning',
                 description: `${mil.toLocaleString('sv-SE')} mil är klart över förväntat för en ${age} år gammal bil (~${Math.round(expectedMil).toLocaleString('sv-SE')} mil). Oberoende besiktning rekommenderas.`,
                 rule_id: 'high_mileage' })
  }

  // EV/PHEV battery — annonser nämner i praktiken aldrig batterihälsa själva,
  // så en obetingad kommentar blir bara brus. Batteriets ålder/cykler är
  // den faktiska riskfaktorn, så gränsen matchar samma 3-årströskel som
  // calculateConfidence() redan använder för samma anledning.
  if (['El', 'Laddhybrid'].includes(car.fuel_type) && ageYears > 3) {
    risks.push({ level: 'medium', title: 'Batterihälsa (SoH) okänd',
                 description: 'Be säljaren om SoH-utdrag eller använd OBD-adapter för att mäta.',
                 rule_id: 'ev_battery_soh_unknown' })
  }

  // Private seller
  if (car.seller_type === 'private') {
    risks.push({ level: 'low', title: 'Privatköp utan garanti',
                 description: 'Köplagen gäller. Överväg oberoende besiktning (ca 1 000–2 000 kr).',
                 rule_id: 'private_no_warranty' })
  }

  // Diesel urban
  if (car.fuel_type === 'Diesel' && car.year >= 2015) {
    risks.push({ level: 'low', title: 'Diesel och framtida stadsrestriktioner',
                 description: 'Dieselbilar kan påverkas av trängselskatter och miljözoner.',
                 rule_id: 'diesel_urban_risk' })
  }

  // Old car, high price
  if (age > 8 && car.price_sek > 150000) {
    risks.push({ level: 'medium',
                 title: 'Äldre bil till relativt högt pris',
                 description: `${age} år gammal bil till ${(car.price_sek/1000).toFixed(0)} 000 kr. Kontrollera att priset motiveras av skick.`,
                 rule_id: 'old_car_high_price' })
  }

  // Deduplicate and cap at 6
  const seen = new Set<string>()
  return risks
    .filter(r => { if (seen.has(r.rule_id)) return false; seen.add(r.rule_id); return true })
    .slice(0, 6)
}

// ─── Premium/exklusiv utrustningsnivå ─────────────────────────────────────────
// Marknadsmedianen (statisk eller live) tar bara hänsyn till märke/modell/år —
// inte utrustningsnivå. Matchar mot namngivna toppvarianter per märke, inte
// enskilda tillval, så det bara flaggas för bilar som faktiskt har en känd
// premiumvariant — annars skulle det kommentera på nästan varje bil.

const PREMIUM_TRIM_KEYWORDS: Record<string, string[]> = {
  'Volvo':         ['inscription', 'r-design', 'ultimate', 'polestar engineered'],
  'BMW':           ['m sport', 'm performance', 'individual'],
  'Mercedes-Benz': ['amg line', 'amg'],
  'Audi':          ['s line', 'competition', 'vorsprung'],
  'Volkswagen':    ['r-line', 'gti', 'r'],
  'Skoda':         ['sportline', 'rs', 'laurin & klement', 'l&k'],
  'Kia':           ['gt-line', 'gt'],
  'Hyundai':       ['n line', 'n-line'],
  'Toyota':        ['gr sport', 'executive'],
  'Seat':          ['fr', 'cupra'],
  'Mini':          ['john cooper works', 'jcw'],
  'Ford':          ['st-line', 'vignale'],
  'Peugeot':       ['gt-line', 'gt'],
}

function detectPremiumTrim(car: CarListing): string | null {
  const keywords = PREMIUM_TRIM_KEYWORDS[car.brand]
  if (!keywords || !car.variant) return null

  for (const keyword of keywords) {
    const escaped = keyword.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    const match = car.variant.match(new RegExp(`\\b${escaped}\\b`, 'i'))
    if (match) return match[0]
  }
  return null
}

// ─── Pros / Cons ──────────────────────────────────────────────────────────────

function generatePros(car: CarListing, scores: Omit<DealScores,'deal'>,
                      pricing: PriceRange, avgMilPerYear: number): string[] {
  const pros: string[] = []
  const mil = Math.round(car.mileage_km / 10)
  const age = Math.round(vehicleAgeYears(car))
  const premiumTrim = detectPremiumTrim(car)

  if (scores.mileage >= 80)
    pros.push(`Mätarställningen (${mil.toLocaleString('sv-SE')} mil) är under genomsnittet för en ${age} år gammal bil — typiskt ${(age * avgMilPerYear).toLocaleString('sv-SE')} mil.`)
  if (pricing.delta_pct > 0.04)
    pros.push(`Priset är ${(pricing.delta_pct * 100).toFixed(0)}% under estimerat marknadsmedian — bra förhandlings­utrymme.`)
  if (car.transmission === 'Automat')
    pros.push('Automatväxellåda ger generellt bättre andrahandsvärde och bredare köparmarknad.')
  if (['El','Laddhybrid','Hybrid'].includes(car.fuel_type))
    pros.push(`${car.fuel_type}-drivning ger lägre bränslekostnader och är välpositionerat för framtida miljöregler.`)
  if (scores.reliability >= 80)
    pros.push(`${car.brand} ${car.model} har ett starkt rykte för tillförlitlighet i sitt segment.`)
  if (car.seller_type === 'dealer')
    pros.push('Säljs av återförsäljare — innebär ofta garanti och möjlighet till finansiering.')
  if (scores.resale >= 74)
    pros.push('Modellen håller andrahandsvärdet väl, vilket minskar den totala ägandekostnaden.')
  if (premiumTrim && pricing.delta_pct >= -0.04)
    pros.push(`Utrustningsnivån "${premiumTrim}" är en efterfrågad toppvariant, vilket stärker andrahandsvärdet.`)

  return pros.slice(0, 4)
}

function generateCons(car: CarListing, scores: Omit<DealScores,'deal'>, pricing: PriceRange): string[] {
  const cons: string[] = []
  const age = Math.round(vehicleAgeYears(car))
  const premiumTrim = detectPremiumTrim(car)

  if (pricing.delta_pct < -0.04) {
    if (premiumTrim) {
      cons.push(`Priset är ${(Math.abs(pricing.delta_pct) * 100).toFixed(0)}% över estimerat marknadsmedian — men medianen tar inte hänsyn till utrustningsnivå, och den här bilen har utrustningspaketet "${premiumTrim}" som kan motivera en del av skillnaden.`)
    } else {
      cons.push(`Priset är ${(Math.abs(pricing.delta_pct) * 100).toFixed(0)}% över estimerat marknadsmedian — det finns utrymme att förhandla.`)
    }
  }
  if (scores.ownership < 58)
    cons.push(`${car.fuel_type}-drivning och/eller premiumvarumärke ger relativt hög uppskattad ägandekostnad.`)
  if (age > 7)
    cons.push(`${age} år gammal bil — räkna med ökad risk för oväntade underhålls­kostnader.`)
  if (scores.mileage < 55)
    cons.push('Mätarställningen är över genomsnittet för årsmodellen. Begär fullständig servicehistorik.')
  if (['BMW','Mercedes-Benz','Audi','Porsche'].includes(car.brand))
    cons.push(`${car.brand} har i genomsnitt högre service­kostnader än volymvarumärken.`)
  if (car.fuel_type === 'Diesel')
    cons.push('Diesel kan ge lägre andrahandsvärde i takt med ökad elektrifiering och miljözoner.')
  if (['El','Laddhybrid'].includes(car.fuel_type) && age > 4)
    cons.push('Äldre elbil/laddhybrid — batterikapaciteten kan ha minskat. Be om SoH-mätning.')

  return cons.slice(0, 4)
}

// ─── Verdict ──────────────────────────────────────────────────────────────────
// Trösklar justerade baserat på testresultat (v1.2)

export function verdictFromScore(score: number): 'Bra affär' | 'Okej affär' | 'Tveksam affär' {
  if (score >= 68) return 'Bra affär'
  if (score >= 52) return 'Okej affär'
  return 'Tveksam affär'
}

// ─── Main export ──────────────────────────────────────────────────────────────

export interface ScoringOutput {
  scores:       DealScores
  confidence:   ConfidenceResult
  pricing:      PriceRange
  pros:         string[]
  cons:         string[]
  risks:        Risk[]
  modelNotes:   string | undefined
  isDefaultRef: boolean
  usedMedian:   number | null  // useful for debugging/logging
}

export async function scoreVehicle(car: CarListing): Promise<ScoringOutput> {
  const { ref, isDefault } = lookupModelReference(car.brand, car.model, car.year)

  // Live data (verkliga Blocket-annonser i market_listings) föredras framför
  // den statiska MARKET_MEDIANS-tabellen när det finns tillräckligt underlag —
  // se getMarketMedian() i lib/supabase/client.ts för sample-size-tröskeln.
  const liveMedian = await getMarketMedian(car.brand, car.model, car.year)
  const medianResult = liveMedian ?? lookupMarketMedian(car.brand, car.model, car.year)

  const priceResult = scorePrice(
    car, ref.avgMilPerYear, ref.pricePer1000ExtraMil,
    ref.basePrice, ref.depreciation, medianResult,
  )

  const subScores = {
    price:       priceResult.score,
    reliability: scoreReliability(car, ref.reliabilityBase),
    ownership:   scoreOwnership(car),
    mileage:     scoreMileage(car, ref.avgMilPerYear),
    resale:      scoreResale(car, ref.resaleBase),
  }

  const scores:     DealScores       = { ...subScores, deal: composite(subScores) }
  const confidence: ConfidenceResult = calculateConfidence(
    car, priceResult.usedMedian, ref.basePrice, ref.depreciation, isDefault,
  )
  const pricing: PriceRange = calculatePricing(
    car, priceResult.usedMedian, ref.basePrice, ref.depreciation,
    ref.avgMilPerYear, ref.pricePer1000ExtraMil, confidence,
  )
  const risks = detectRisks(car, ref.notes, ref.avgMilPerYear)
  const pros  = generatePros(car, subScores, pricing, ref.avgMilPerYear)
  const cons  = generateCons(car, subScores, pricing)

  return {
    scores, confidence, pricing, pros, cons, risks,
    modelNotes:   ref.notes,
    isDefaultRef: isDefault,
    usedMedian:   priceResult.usedMedian,
  }
}

// ─── Utilities ────────────────────────────────────────────────────────────────

function clamp(n: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, Math.round(n)))
}

function roundTo(n: number, nearest: number): number {
  return Math.round(n / nearest) * nearest
}
