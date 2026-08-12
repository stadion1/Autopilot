/**
 * POST /api/admin/recompute-depreciation-curves?index=0
 *
 * Engångsverktyg (kan köras om manuellt vid behov): räknar fram
 * depreciation_curves + mileage_sensitivity för EN post i
 * data/referenceData.ts's MODEL_REFERENCES per anrop. Ett index i taget,
 * samma försiktighetsprincip som backfill-new-car-prices.ts — ingen
 * maxDuration är satt för appens serverless-funktioner.
 *
 * Själva beräkningslogiken lever i lib/depreciationCurve.ts, delad med den
 * dagliga cronen (pages/api/cron/recompute-depreciation-curves.ts) som
 * kör några index åt gången automatiskt.
 */

import { NextApiRequest, NextApiResponse } from 'next'
import { MODEL_REFERENCES } from '../../../data/referenceData'
import { recomputeDepreciationCurveForIndex } from '../../../lib/depreciationCurve'

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

  const result = await recomputeDepreciationCurveForIndex(index)
  if (result.error) return res.status(500).json(result)
  return res.status(200).json(result)
}
