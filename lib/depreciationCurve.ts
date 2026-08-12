/**
 * lib/depreciationCurve.ts
 *
 * Kärnlogiken för att räkna fram depreciation_curves + mileage_sensitivity
 * för EN post i data/referenceData.ts's MODEL_REFERENCES. Delad mellan
 * pages/api/admin/recompute-depreciation-curves.ts (manuellt, ett index i
 * taget) och pages/api/cron/recompute-depreciation-curves.ts (dagligt,
 * några index i taget) — se respektive fil för anropskontext.
 *
 * Metod: för varje tillverkningsår i referensgenerationens yearFrom–yearTo
 * (avgränsat till innevarande år), jämför medianpriset i market_listings
 * för just det årsmodellet med Skatteverkets nybilspris-median för samma
 * tillverkningsår (INTE dagens nypris). Kräver minst MIN_SAMPLES annonser
 * för att en åldersgrupp ens räknas som en råpunkt.
 *
 * GLÄTTNING (viktigt): en första version lagrade råmedianerna rakt av och
 * lät lib/scoring/ownershipCost.ts derivera varje års rate från bara två
 * INTILLIGGANDE punkter. Det visade sig ge en studsig, orealistisk kurva —
 * en Volvo XC60-analys visade nästan ingen värdeminskning år 1, en spik på
 * 89 000 kr år 2, tillbaka till nästan noll år 4/5 osv. Orsak: 20–30
 * annonser per åldersgrupp är olika specifika bilar/utrustningsnivåer, så
 * mediannivån studsar från ren stickprovsvariation mellan grannår även om
 * varje enskild punkt för sig är rimlig.
 *
 * Fix: glätta INNAN lagring, inte vid läsning. Ålder 0→1 (den kända branta
 * "körde ut från handlaren"-nedgången) mäts direkt eftersom den
 * transitionen normalt har gott om stöd. Ålder ≥1 får EN gemensam,
 * viktad log-linjär regressionslutning över alla tillgängliga punkter —
 * fortfarande modellspecifik och mätt, men utan zigzag mellan enskilda
 * år. Den lagrade retained_pct-sekvensen är alltså en glättad/fittad kurva,
 * inte de råa medianerna — ownershipCost.ts:s befintliga two-point-
 * derivering behöver därför ingen ändring.
 *
 * MÄTARSTÄLLNINGS-KÄNSLIGHET (steg 3): utöver kurvan beräknas och lagras
 * (i mileage_sensitivity) hur mycket priset avviker per 1000 mil
 * avvikelse från förväntad mätarställning (ref.avgMilPerYear × ålder),
 * inom samma åldersgrupp — en enskild annons regressionsvärde per
 * referenspost, inte per ålder. Poolar annonser över ALLA åldersgrupper
 * (samma data som redan hämtas för kurvan ovan) eftersom mätarställnings-
 * effekten antas vara ungefär densamma oavsett bilens ålder. Klampad till
 * [-15000, 0] kr/1000 mil — aldrig positivt (mer mil ska aldrig öka
 * priset), och en nedre gräns för att skydda mot brusigt underlag.
 */

import { supabase } from './supabase/client'
import { MODEL_REFERENCES } from '../data/referenceData'

const MIN_SAMPLES = 5
// Rimliga gränser för en ENSKILD årlig rate i den glättade kurvan — brett
// nog för allt från Land Cruiser (mycket lågt) till ett nyss-utgånget
// EV-erbjudande (mycket högt), men skyddar mot att en bil "ökar i värde"
// eller mot orimligt branta enstaka år som ändå kan smyga sig igenom
// regressionen om stödet är tunt.
const RATE_MIN = 0.02
const RATE_MAX = 0.35
const MIN_MILEAGE_SAMPLES = 15

function median(nums: number[]): number {
  const sorted = [...nums].sort((a, b) => a - b)
  const mid = Math.floor(sorted.length / 2)
  return sorted.length % 2 !== 0 ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2
}

function clampRate(rate: number): number {
  return Math.min(RATE_MAX, Math.max(RATE_MIN, rate))
}

// Viktad minsta-kvadrat-lutning för ln(retained_pct) mot ålder — dvs. antar
// att retained_pct(ålder) ≈ a · e^(slope·ålder). Returnerar null om det
// inte finns tillräckligt med punkter för att fitta en linje.
function weightedLogLinearSlope(points: { age: number; retainedPct: number; weight: number }[]): number | null {
  if (points.length < 2) return null
  let sumW = 0, sumWX = 0, sumWY = 0, sumWXX = 0, sumWXY = 0
  for (const p of points) {
    const x = p.age, y = Math.log(p.retainedPct), w = p.weight
    sumW += w; sumWX += w * x; sumWY += w * y; sumWXX += w * x * x; sumWXY += w * x * y
  }
  const denom = sumW * sumWXX - sumWX * sumWX
  if (denom === 0) return null
  return (sumW * sumWXY - sumWX * sumWY) / denom
}

// Enkel (oviktad) minsta-kvadrat-lutning för y mot x — används för
// mätarställnings-känsligheten: y = prisavvikelse i kr mot samma
// åldersgrupps medianpris, x = mätarställningsavvikelse i mil mot
// förväntat (ref.avgMilPerYear × ålder). Varje punkt är en enskild
// annons, inte en median, så ingen extra viktning behövs utöver att
// varje annons redan räknas en gång.
function linearSlope(points: { x: number; y: number }[]): number | null {
  if (points.length < 2) return null
  const n = points.length
  let sumX = 0, sumY = 0, sumXX = 0, sumXY = 0
  for (const p of points) {
    sumX += p.x; sumY += p.y; sumXX += p.x * p.x; sumXY += p.x * p.y
  }
  const denom = n * sumXX - sumX * sumX
  if (denom === 0) return null
  return (n * sumXY - sumX * sumY) / denom
}

export interface RecomputeResult {
  index: number
  brand: string
  model: string
  yearFrom: number
  yearTo: number
  rawPoints: number
  pointsStored: number
  rateFirstYear: number | null
  rateSteadyState: number | null
  insufficientSamples: number
  noAnchorMatch: number
  mileagePoints: number
  mileageSensitivityKr: number | null
  error?: string
}

export async function recomputeDepreciationCurveForIndex(index: number): Promise<RecomputeResult> {
  const ref = MODEL_REFERENCES[index]
  const base = { index, brand: ref.brand, model: ref.model, yearFrom: ref.yearFrom, yearTo: ref.yearTo }
  const currentYear = new Date().getFullYear()
  const toYear = Math.min(ref.yearTo, currentYear)

  type RawPoint = { age: number; retainedPct: number; sampleSize: number }
  const raw: RawPoint[] = []
  let insufficientSamples = 0
  let noAnchorMatch = 0
  const mileagePoints: { x: number; y: number }[] = []

  try {
    for (let vintageYear = ref.yearFrom; vintageYear <= toYear; vintageYear++) {
      const age = currentYear - vintageYear
      if (age < 0) continue

      const { data: listings, error: listingsErr } = await supabase
        .from('market_listings')
        .select('price_sek, mileage_km')
        .eq('brand', ref.brand)
        .eq('model', ref.model)
        .eq('year', vintageYear)
        .not('price_sek', 'is', null)

      if (listingsErr) {
        return { ...base, rawPoints: 0, pointsStored: 0, rateFirstYear: null, rateSteadyState: null,
          insufficientSamples, noAnchorMatch, mileagePoints: mileagePoints.length, mileageSensitivityKr: null,
          error: listingsErr.message }
      }
      if (!listings || listings.length < MIN_SAMPLES) { insufficientSamples++; continue }

      const ageGroupMedianPrice = median(listings.map((l: { price_sek: number }) => l.price_sek))
      if (Number.isFinite(ageGroupMedianPrice) && ageGroupMedianPrice > 0) {
        const expectedMil = age * ref.avgMilPerYear
        for (const l of listings as { price_sek: number; mileage_km: number | null }[]) {
          if (l.mileage_km == null) continue
          const deviationMil = l.mileage_km / 10 - expectedMil
          mileagePoints.push({ x: deviationMil, y: l.price_sek - ageGroupMedianPrice })
        }
      }

      // Vissa modeller (BMW "3-serie", Mercedes "C-klass" m.fl.) är
      // seriebeteckningar som ALDRIG förekommer bokstavligt i Skatteverkets
      // data — de listar bara trimkoder ("320d xDrive", "C 200 4MATIC...").
      // För dem hämtas alla trimmar för märke+år och filtreras med regexet
      // i skatteverketModelPattern istället för en substräng-matchning.
      let newPricesRaw: { price_sek: number }[] | null
      if (ref.skatteverketModelPattern) {
        const { data, error: newPricesErr } = await supabase
          .from('new_car_prices')
          .select('price_sek, model_raw')
          .ilike('brand', ref.brand)
          .eq('manufacturing_year', vintageYear)

        if (newPricesErr) {
          return { ...base, rawPoints: 0, pointsStored: 0, rateFirstYear: null, rateSteadyState: null,
            insufficientSamples, noAnchorMatch, mileagePoints: mileagePoints.length, mileageSensitivityKr: null,
            error: newPricesErr.message }
        }
        const pattern = new RegExp(ref.skatteverketModelPattern, 'i')
        newPricesRaw = (data ?? []).filter((p: { model_raw: string }) => pattern.test(p.model_raw))
      } else {
        const { data, error: newPricesErr } = await supabase
          .from('new_car_prices')
          .select('price_sek')
          .ilike('brand', ref.brand)
          .ilike('model_raw', `%${ref.model}%`)
          .eq('manufacturing_year', vintageYear)

        if (newPricesErr) {
          return { ...base, rawPoints: 0, pointsStored: 0, rateFirstYear: null, rateSteadyState: null,
            insufficientSamples, noAnchorMatch, mileagePoints: mileagePoints.length, mileageSensitivityKr: null,
            error: newPricesErr.message }
        }
        newPricesRaw = data
      }

      if (!newPricesRaw || newPricesRaw.length === 0) { noAnchorMatch++; continue }

      const observedMedian = ageGroupMedianPrice
      const anchorMedian = median(newPricesRaw.map((p: { price_sek: number }) => p.price_sek))
      if (!Number.isFinite(observedMedian) || !Number.isFinite(anchorMedian) || anchorMedian <= 0) {
        noAnchorMatch++
        continue
      }

      const retainedPct = observedMedian / anchorMedian
      // Ett andrahandsvärde kan inte rimligen överstiga nypriset eller
      // ligga nära noll — det tyder på en felmatchning mellan
      // market_listings modellnamn och Skatteverkets fritext snarare än
      // en riktig mätpunkt.
      if (retainedPct <= 0 || retainedPct > 1.1) { noAnchorMatch++; continue }

      raw.push({ age, retainedPct, sampleSize: listings.length })
    }

    // Mätarställnings-känslighet: oberoende av om kurvan ovan kunde byggas
    // (den behöver ingen Skatteverket-ankare, bara jämförelse inom samma
    // åldersgrupp), så beräknas och lagras den även om `raw` blev tom.
    let mileageSensitivityKr: number | null = null
    if (mileagePoints.length >= MIN_MILEAGE_SAMPLES) {
      const slope = linearSlope(mileagePoints)
      if (slope !== null && Number.isFinite(slope)) {
        // Rimliga gränser: aldrig positivt (mer mil ska aldrig öka priset)
        // och aldrig mer extremt än -15 000 kr/1000 mil — ett tecken på
        // brusigt/otillräckligt underlag snarare än en äkta effekt.
        const krPer1000 = Math.min(0, Math.max(-15000, slope * 1000))
        mileageSensitivityKr = krPer1000
        const { error: sensErr } = await supabase
          .from('mileage_sensitivity')
          .upsert(
            {
              brand: ref.brand, model: ref.model, year_from: ref.yearFrom,
              kr_per_1000_mil_deviation: krPer1000, sample_size: mileagePoints.length,
              computed_at: new Date().toISOString(),
            },
            { onConflict: 'brand,model,year_from' },
          )
        if (sensErr) {
          return { ...base, rawPoints: raw.length, pointsStored: 0, rateFirstYear: null, rateSteadyState: null,
            insufficientSamples, noAnchorMatch, mileagePoints: mileagePoints.length, mileageSensitivityKr: null,
            error: sensErr.message }
        }
      }
    }

    if (raw.length === 0) {
      return { ...base, rawPoints: 0, pointsStored: 0, rateFirstYear: null, rateSteadyState: null,
        insufficientSamples, noAnchorMatch, mileagePoints: mileagePoints.length, mileageSensitivityKr }
    }

    raw.sort((a, b) => a.age - b.age)

    // Segment A: den kända branta ålder 0→1-nedgången, mätt direkt om
    // båda punkterna finns.
    const p0 = raw.find(p => p.age === 0)
    const p1 = raw.find(p => p.age === 1)
    const rateA = (p0 && p1) ? clampRate(1 - p1.retainedPct / p0.retainedPct) : null

    // Segment B: en gemensam glättad rate för ålder ≥1, viktad efter
    // stickprovsstorlek — det här är vad som ersätter den studsiga
    // punkt-till-punkt-derivatan.
    const ageGE1 = raw.filter(p => p.age >= 1)
    const slope = weightedLogLinearSlope(ageGE1.map(p => ({ age: p.age, retainedPct: p.retainedPct, weight: p.sampleSize })))
    const rateB = slope !== null ? clampRate(1 - Math.exp(slope)) : null

    // Bygg den glättade sekvensen som faktiskt lagras, förankrad i den
    // yngsta råpunkten och framåt så långt vi har en användbar rate.
    const anchor = raw[0]
    const fitted: RawPoint[] = [{ age: anchor.age, retainedPct: anchor.retainedPct, sampleSize: anchor.sampleSize }]

    for (let age = anchor.age + 1; age <= raw[raw.length - 1].age; age++) {
      const rate = (age === 1 && rateA !== null) ? rateA : rateB
      if (rate === null) break
      const prevPct = fitted[fitted.length - 1].retainedPct
      const sampleAtAge = raw.find(p => p.age === age)?.sampleSize ?? fitted[fitted.length - 1].sampleSize
      fitted.push({ age, retainedPct: prevPct * (1 - rate), sampleSize: sampleAtAge })
    }

    if (fitted.length > 0) {
      const { error } = await supabase
        .from('depreciation_curves')
        .upsert(
          fitted.map(p => ({
            brand: ref.brand, model: ref.model, year_from: ref.yearFrom,
            age_years: p.age, retained_pct: p.retainedPct, sample_size: p.sampleSize,
            computed_at: new Date().toISOString(),
          })),
          { onConflict: 'brand,model,year_from,age_years' },
        )
      if (error) {
        return { ...base, rawPoints: raw.length, pointsStored: 0, rateFirstYear: rateA, rateSteadyState: rateB,
          insufficientSamples, noAnchorMatch, mileagePoints: mileagePoints.length, mileageSensitivityKr,
          error: error.message }
      }
    }

    return {
      ...base, rawPoints: raw.length, pointsStored: fitted.length,
      rateFirstYear: rateA, rateSteadyState: rateB,
      insufficientSamples, noAnchorMatch,
      mileagePoints: mileagePoints.length, mileageSensitivityKr,
    }
  } catch (err: any) {
    return { ...base, rawPoints: 0, pointsStored: 0, rateFirstYear: null, rateSteadyState: null,
      insufficientSamples, noAnchorMatch, mileagePoints: mileagePoints.length, mileageSensitivityKr: null,
      error: err?.message ?? String(err) }
  }
}
