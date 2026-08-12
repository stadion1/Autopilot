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
 * tillverkningsår (INTE dagens nypris — en 8 år gammal bil ska jämföras
 * mot vad den kostade ny då den begagnades, se CLAUDE_CONTEXT.md). Kräver
 * minst MIN_SAMPLES annonser för att spara en kurvpunkt.
 */

import { NextApiRequest, NextApiResponse } from 'next'
import { supabase } from '../../../lib/supabase/client'
import { MODEL_REFERENCES } from '../../../data/referenceData'

const MIN_SAMPLES = 5

function median(nums: number[]): number {
  const sorted = [...nums].sort((a, b) => a - b)
  const mid = Math.floor(sorted.length / 2)
  return sorted.length % 2 !== 0 ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2
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

  const points: {
    brand: string; model: string; year_from: number
    age_years: number; retained_pct: number; sample_size: number
  }[] = []
  let skipped = 0

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
      if (!listings || listings.length < MIN_SAMPLES) { skipped++; continue }

      const { data: newPrices, error: newPricesErr } = await supabase
        .from('new_car_prices')
        .select('price_sek')
        .ilike('brand', ref.brand)
        .ilike('model_raw', `%${ref.model}%`)
        .eq('manufacturing_year', vintageYear)

      if (newPricesErr) return res.status(500).json({ error: newPricesErr.message })
      if (!newPrices || newPrices.length === 0) { skipped++; continue }

      const observedMedian = median(listings.map((l: { price_sek: number }) => l.price_sek))
      const anchorMedian = median(newPrices.map((p: { price_sek: number }) => p.price_sek))
      if (!Number.isFinite(observedMedian) || !Number.isFinite(anchorMedian) || anchorMedian <= 0) {
        skipped++
        continue
      }

      const retainedPct = observedMedian / anchorMedian
      // Ett andrahandsvärde kan inte rimligen överstiga nypriset eller
      // ligga nära noll — det tyder på en felmatchning mellan
      // market_listings modellnamn och Skatteverkets fritext snarare än
      // en riktig mätpunkt. Bättre att hoppa över den årsklassen än att
      // spara en kurvpunkt som senare kan ge en orimlig rate.
      if (retainedPct <= 0 || retainedPct > 1.1) { skipped++; continue }

      points.push({
        brand: ref.brand, model: ref.model, year_from: ref.yearFrom,
        age_years: age, retained_pct: retainedPct, sample_size: listings.length,
      })
    }

    if (points.length > 0) {
      const { error } = await supabase
        .from('depreciation_curves')
        .upsert(
          points.map(p => ({ ...p, computed_at: new Date().toISOString() })),
          { onConflict: 'brand,model,year_from,age_years' },
        )
      if (error) return res.status(500).json({ error: error.message })
    }

    return res.status(200).json({
      index, brand: ref.brand, model: ref.model, yearFrom: ref.yearFrom, yearTo: ref.yearTo,
      pointsComputed: points.length, skipped,
    })
  } catch (err: any) {
    return res.status(500).json({ error: err?.message ?? String(err) })
  }
}
