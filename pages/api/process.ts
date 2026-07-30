/**
 * POST /api/process
 *
 * Gör det tunga jobbet för en redan skapad "pending"-analys: anropar
 * Railway-scrapern, kör scoring och AI, och sparar resultatet. Triggas av
 * klienten direkt efter /api/analyze utan att invänta svaret (fire-and-forget)
 * — klienten har redan navigerat vidare och pollar /api/analysis/[id] tills
 * statusen blir "done".
 *
 * Playwright körs INTE här — det sköts av Railway-tjänsten.
 * Det gör att denna route funkar på Vercel serverless.
 */

import { NextApiRequest, NextApiResponse } from 'next'
import { scoreVehicle, verdictFromScore } from '../../lib/scoring/engine'
import { analyzeWithAI } from '../../lib/ai/analyzer'
import {
  markProcessing,
  saveCarData,
  saveMarketListing,
  saveAnalysisResult,
  markError,
} from '../../lib/supabase/client'
import type { CarListing } from '../../types'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') return res.status(405).end()

  const { id, url } = req.body
  if (!id || typeof id !== 'string' || !url || typeof url !== 'string') {
    return res.status(400).json({ error: 'id och url krävs' })
  }

  await markProcessing(id)

  // 1. Anropa Railway-scrapern
  let car: Partial<CarListing>
  try {
    car = await callScraperService(url)
  } catch (err: any) {
    await markError(id, err.message)
    return res.status(422).json({ error: err.message })
  }

  await saveCarData(id, car)
  await saveMarketListing(car)   // best-effort — bidrar med verklig data till market_listings

  // 2. Scoring
  const completeCar = car as CarListing
  const { scores, confidence, pricing, pros, cons, risks, modelNotes } = await scoreVehicle(completeCar)

  // 3. AI-analys
  let aiSummary: string
  let verdict: 'Bra affär' | 'Okej affär' | 'Tveksam affär'
  try {
    const ai = await analyzeWithAI(completeCar, scores, confidence, pricing, risks, modelNotes)
    aiSummary = ai.summary
    verdict   = ai.verdict
  } catch {
    aiSummary = fallbackSummary(completeCar, scores, pricing)
    verdict   = verdictFromScore(scores.deal)
  }

  // 4. Spara
  try {
    await saveAnalysisResult(
      id, scores, confidence, pricing,
      pros, cons, risks, verdict, aiSummary,
      '1.2.0', ['market_medians_v1', 'known_issues_v1']
    )
  } catch {
    await markError(id, 'Misslyckades att spara')
    return res.status(500).json({ error: 'Misslyckades att spara analys' })
  }

  return res.status(200).json({ ok: true })
}

async function callScraperService(url: string): Promise<Partial<CarListing>> {
  const serviceUrl = process.env.SCRAPER_SERVICE_URL
  if (!serviceUrl) throw new Error('SCRAPER_SERVICE_URL saknas i miljövariabler')

  const res = await fetch(`${serviceUrl}/scrape`, {
    method:  'POST',
    headers: {
      'Content-Type':     'application/json',
      'x-scraper-secret': process.env.SCRAPER_SECRET ?? '',
    },
    body:   JSON.stringify({ url }),
    signal: AbortSignal.timeout(28000),
  })

  if (!res.ok) {
    const body = await res.json().catch(() => ({}))
    throw new Error(body.error ?? `Scraper svarade med ${res.status}`)
  }

  const result = await res.json()
  if (!result.success || !result.data) {
    throw new Error(result.error ?? 'Scrapern returnerade ingen data')
  }

  return result.data
}

function fallbackSummary(car: CarListing, scores: any, pricing: any): string {
  const mil   = Math.round(car.mileage_km / 10)
  const delta = (Math.abs(pricing.delta_pct) * 100).toFixed(0)
  const dir   = pricing.delta_pct > 0 ? 'under' : 'över'
  return `${car.brand} ${car.model} ${car.year} är prissatt ungefär ${delta}% ${dir} estimerat marknadsmedian på ${(pricing.median/1000).toFixed(0)} 000 kr. Med ${mil.toLocaleString('sv-SE')} mil och deal-score ${scores.deal}/100 bedöms detta vara ${verdictFromScore(scores.deal).toLowerCase()}. Genomför alltid oberoende besiktning och begär servicehistorik.`
}

export const config = {
  api: { bodyParser: { sizeLimit: '1mb' } },
}
