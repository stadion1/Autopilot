/**
 * GET /api/cron/recompute-depreciation-curves
 *
 * Vercel Cron — kör steg 4 av värdeminskningskurve-projektet: ett dagligt
 * jobb som (om)beräknar depreciation_curves + mileage_sensitivity för en
 * delmängd av data/referenceData.ts's MODEL_REFERENCES varje dygn, så
 * kurvorna förfinas automatiskt när market_listings växer istället för att
 * vara en engångs-snapshot från senast någon körde admin-endpointen
 * manuellt.
 *
 * Vercel Hobby tillåter bara dagliga crons (samma begränsning som
 * score-listings.ts stötte på 2026-08-12 — ett timschema fick hela
 * deployen att avvisas), så istället för fler körningar per dygn cyklas
 * igenom alla 57 modeller över flera dagar: `Math.ceil(57 / BATCH_SIZE)`
 * dagar per full cykel. Vilket "varv" som körs idag beräknas
 * deterministiskt från dagens datum (dagar sedan epoch modulo antal varv)
 * — ingen egen cursor-tabell behövs, men om en dags körning misslyckas
 * körs INTE samma varv om nästa dag, det kommer först nästa cykel.
 * Acceptabelt här eftersom kurvorna ändras långsamt (marknadsdata, inte
 * news).
 *
 * Med BATCH_SIZE=9 tar en full cykel 7 dagar (57/9 avrundat uppåt).
 * Körs indexen inom en dags batch med begränsad konkurrens (INDEX_CONCURRENCY)
 * — de är oberoende av varandra (olika märke/modell), men varje index gör
 * redan flera sekventiella databasanrop internt (ett par år × 2 frågor),
 * så en alltför hög konkurrens riskerar att överbelasta Supabase snarare
 * än att vinna tid. Ej uppmätt i produktion hur lång tid en full daglig
 * batch faktiskt tar — kolla `durationMs` i svaret efter första körningen
 * och justera RECOMPUTE_CRON_BATCH_SIZE/RECOMPUTE_CRON_CONCURRENCY
 * (miljövariabler) om det ligger nära 60s-taket.
 */

import { NextApiRequest, NextApiResponse } from 'next'
import { MODEL_REFERENCES } from '../../../data/referenceData'
import { recomputeDepreciationCurveForIndex } from '../../../lib/depreciationCurve'

export const config = { maxDuration: 60 }

const BATCH_SIZE  = parseInt(process.env.RECOMPUTE_CRON_BATCH_SIZE ?? '9', 10)
const CONCURRENCY = parseInt(process.env.RECOMPUTE_CRON_CONCURRENCY ?? '3', 10)

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (process.env.CRON_SECRET) {
    if (req.headers.authorization !== `Bearer ${process.env.CRON_SECRET}`) {
      return res.status(401).json({ error: 'Unauthorized' })
    }
  }

  const total = MODEL_REFERENCES.length
  const numBatches = Math.ceil(total / BATCH_SIZE)
  const daysSinceEpoch = Math.floor(Date.now() / (24 * 3600_000))
  const batchNumber = daysSinceEpoch % numBatches

  const startIndex = batchNumber * BATCH_SIZE
  const endIndex = Math.min(startIndex + BATCH_SIZE, total)
  const indices = Array.from({ length: endIndex - startIndex }, (_, i) => startIndex + i)

  const t0 = Date.now()
  const results: Awaited<ReturnType<typeof recomputeDepreciationCurveForIndex>>[] = []

  for (let i = 0; i < indices.length; i += CONCURRENCY) {
    const chunk = indices.slice(i, i + CONCURRENCY)
    const chunkResults = await Promise.all(chunk.map(index => recomputeDepreciationCurveForIndex(index)))
    results.push(...chunkResults)
  }

  const durationMs = Date.now() - t0
  const succeeded = results.filter(r => !r.error).length
  const failed = results.filter(r => r.error).length

  console.log(`[recompute-depreciation-curves cron] varv ${batchNumber + 1}/${numBatches}, index ${startIndex}-${endIndex - 1}: ${succeeded} lyckades, ${failed} misslyckade, ${durationMs}ms`)

  return res.status(200).json({
    batchNumber, numBatches, startIndex, endIndex, durationMs, succeeded, failed, results,
  })
}
