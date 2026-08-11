/**
 * GET /api/cron/sync-new-car-prices
 *
 * Vercel Cron — syncar Skatteverkets nybilspriser-API (CC0, öppna data) in i
 * new_car_prices. Skatteverket publicerar cirka 3 uppdateringar per år, så
 * det här behöver inte köras dagligen (se vercel.json).
 *
 * Scope: bara innevarande år och föregående år. Räcker för "ny bil"-
 * poängsättningen (se isEssentiallyNewCar i lib/scoring/engine.ts). Historisk
 * data (för värdeminskningskurvan) hämtas separat via engångsverktyget
 * pages/api/admin/backfill-new-car-prices.ts — den datan ändras aldrig i
 * efterhand så den behöver inte synkas om varje vecka.
 */

import { NextApiRequest, NextApiResponse } from 'next'
import { syncSkatteverketYear } from '../../../lib/skatteverket'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (process.env.CRON_SECRET) {
    if (req.headers.authorization !== `Bearer ${process.env.CRON_SECRET}`) {
      return res.status(401).json({ error: 'Unauthorized' })
    }
  }

  const currentYear = new Date().getFullYear()
  const years = [currentYear - 1, currentYear]

  const results: Record<number, { synced: number; failed: number } | { error: string }> = {}

  for (const year of years) {
    try {
      results[year] = await syncSkatteverketYear(year)
    } catch (err: any) {
      console.error(`[sync-new-car-prices] Fel för ${year}:`, err?.message ?? err)
      results[year] = { error: err?.message ?? String(err) }
    }
  }

  return res.status(200).json({ years: results })
}
