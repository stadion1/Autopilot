/**
 * POST /api/admin/backfill-new-car-prices?year=2015
 *
 * Engångsverktyg, triggas manuellt (inte schemalagt): fyller new_car_prices
 * med historiska Skatteverket-årgångar för värdeminskningskurve-projektet
 * (se CLAUDE_CONTEXT.md). Den veckovisa cronen (sync-new-car-prices.ts)
 * håller medvetet bara innevarande + föregående år färska — historisk data
 * ändras aldrig i efterhand så den behöver bara hämtas en gång.
 *
 * Ett år per anrop, inte en loop över flera år i samma request — ingen
 * maxDuration är satt för den här appens serverless-funktioner så
 * defaulten (kan vara så låg som 10s på vissa Vercel-planer) gäller, och
 * ett helt år kan vara tusentals rader över många paginerade Skatteverket-
 * anrop. Säkrare att köra ett år i taget och låta anroparen loopa.
 *
 * referenceData.ts:s golv är 2010 (se motiveringen i lib/supabase/client.ts
 * och scraper-service/nightly.ts), så det är en rimlig startpunkt — men
 * Skatteverkets dataset går ända till 2008 om vi senare vill ha mer historik.
 */

import { NextApiRequest, NextApiResponse } from 'next'
import { syncSkatteverketYear } from '../../../lib/skatteverket'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  if (process.env.CRON_SECRET) {
    if (req.headers.authorization !== `Bearer ${process.env.CRON_SECRET}`) {
      return res.status(401).json({ error: 'Unauthorized' })
    }
  }

  const year = parseInt(String(req.query.year), 10)
  const currentYear = new Date().getFullYear()
  if (!Number.isFinite(year) || year < 2008 || year > currentYear) {
    return res.status(400).json({ error: `year måste vara ett tal mellan 2008 och ${currentYear}` })
  }

  try {
    const result = await syncSkatteverketYear(year)
    console.log(`[backfill-new-car-prices] ${year}:`, result)
    return res.status(200).json({ year, ...result })
  } catch (err: any) {
    console.error(`[backfill-new-car-prices] Fel för ${year}:`, err?.message ?? err)
    return res.status(500).json({ error: err?.message ?? String(err) })
  }
}
