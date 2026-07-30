/**
 * POST /api/analyze
 *
 * Snabb endpoint: validerar URL:en, kollar cache, skapar en "pending"-post
 * i Supabase och returnerar analys-ID:t direkt — utan att vänta på skrapning,
 * scoring eller AI-analys. Det tunga arbetet görs av /api/process, som
 * klienten triggar (utan att invänta svaret) direkt efter det här anropet,
 * så att man navigerar till analyssidan nästan omedelbart och ser den
 * riktiga väntetiden i fyrastegs-vyn där, istället för bakom en tom knapp.
 */

import { NextApiRequest, NextApiResponse } from 'next'
import { validateListingUrl } from '../../lib/parsers'
import { getCachedAnalysis, createPendingAnalysis } from '../../lib/supabase/client'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') return res.status(405).end()

  const { url } = req.body

  if (!url || typeof url !== 'string') {
    return res.status(400).json({ error: 'URL krävs' })
  }

  // 1. Validera URL
  const validation = validateListingUrl(url.trim())
  if (!validation.valid) {
    return res.status(400).json({ error: validation.error })
  }

  // 2. Cache-kontroll
  const cachedId = await getCachedAnalysis(url)
  if (cachedId) return res.status(200).json({ id: cachedId, cached: true })

  // 3. Skapa DB-post
  let analysisId: string
  try {
    analysisId = await createPendingAnalysis(url, validation.site!)
  } catch {
    return res.status(500).json({ error: 'Databasfel' })
  }

  return res.status(200).json({ id: analysisId, cached: false })
}

export const config = {
  api: { bodyParser: { sizeLimit: '1mb' } },
}
