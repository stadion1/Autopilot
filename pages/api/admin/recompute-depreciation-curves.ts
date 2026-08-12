/**
 * POST /api/admin/recompute-depreciation-curves?index=0
 *
 * Engångsverktyg (kan köras om senare när market_listings/new_car_prices
 * fått mer data): räknar fram depreciation_curves för EN post i
 * data/referenceData.ts's MODEL_REFERENCES per anrop. Ett index i taget,
 * samma försiktighetsprincip som backfill-new-car-prices.ts — ingen
 * maxDuration är satt för appens serverless-funktioner.
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
 */

import { NextApiRequest, NextApiResponse } from 'next'
import { supabase } from '../../../lib/supabase/client'
import { MODEL_REFERENCES } from '../../../data/referenceData'

const MIN_SAMPLES = 5
// Rimliga gränser för en ENSKILD årlig rate i den glättade kurvan — brett
// nog för allt från Land Cruiser (mycket lågt) till ett nyss-utgånget
// EV-erbjudande (mycket högt), men skyddar mot att en bil "ökar i värde"
// eller mot orimligt branta enstaka år som ändå kan smyga sig igenom
// regressionen om stödet är tunt.
const RATE_MIN = 0.02
const RATE_MAX = 0.35

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

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  if (process.env.CRON_SECRET) {
    if (req.headers.authorization !== `Bearer ${process.env.CRON_SECRET}`) {
      return res.status(401).json({ error: 'Unauthorized' })
    }
  }

  const index = parseInt(String(req.query.index), 10)
  if (!Number.isFinite(index) || index < 0 || index >= MODEL_REFERENCES.length) {
    return res.status(400).json({ error: `index måste vara 0–${MODEL_REFERENCES.length - 1}` })
  }

  const ref = MODEL_REFERENCES[index]
  const currentYear = new Date().getFullYear()
  const toYear = Math.min(ref.yearTo, currentYear)

  type RawPoint = { age: number; retainedPct: number; sampleSize: number }
  const raw: RawPoint[] = []
  let insufficientSamples = 0
  let noAnchorMatch = 0

  try {
    for (let vintageYear = ref.yearFrom; vintageYear <= toYear; vintageYear++) {
      const age = currentYear - vintageYear
      if (age < 0) continue

      const { data: listings, error: listingsErr } = await supabase
        .from('market_listings')
        .select('price_sek')
        .eq('brand', ref.brand)
        .eq('model', ref.model)
        .eq('year', vintageYear)
        .not('price_sek', 'is', null)

      if (listingsErr) return res.status(500).json({ error: listingsErr.message })
      if (!listings || listings.length < MIN_SAMPLES) { insufficientSamples++; continue }

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

        if (newPricesErr) return res.status(500).json({ error: newPricesErr.message })
        const pattern = new RegExp(ref.skatteverketModelPattern, 'i')
        newPricesRaw = (data ?? []).filter((p: { model_raw: string }) => pattern.test(p.model_raw))
      } else {
        const { data, error: newPricesErr } = await supabase
          .from('new_car_prices')
          .select('price_sek')
          .ilike('brand', ref.brand)
          .ilike('model_raw', `%${ref.model}%`)
          .eq('manufacturing_year', vintageYear)

        if (newPricesErr) return res.status(500).json({ error: newPricesErr.message })
        newPricesRaw = data
      }

      if (!newPricesRaw || newPricesRaw.length === 0) { noAnchorMatch++; continue }

      const observedMedian = median(listings.map((l: { price_sek: number }) => l.price_sek))
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

    if (raw.length === 0) {
      return res.status(200).json({
        index, brand: ref.brand, model: ref.model, yearFrom: ref.yearFrom, yearTo: ref.yearTo,
        rawPoints: 0, pointsStored: 0, insufficientSamples, noAnchorMatch,
      })
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
      if (error) return res.status(500).json({ error: error.message })
    }

    return res.status(200).json({
      index, brand: ref.brand, model: ref.model, yearFrom: ref.yearFrom, yearTo: ref.yearTo,
      rawPoints: raw.length, pointsStored: fitted.length,
      rateFirstYear: rateA, rateSteadyState: rateB,
      insufficientSamples, noAnchorMatch,
    })
  } catch (err: any) {
    return res.status(500).json({ error: err?.message ?? String(err) })
  }
}
