/**
 * GET /api/cron/sync-new-car-prices
 *
 * Vercel Cron — syncar Skatteverkets nybilspriser-API (CC0, öppna data) in i
 * new_car_prices. Skatteverket publicerar cirka 3 uppdateringar per år, så
 * det här behöver inte köras dagligen (se vercel.json).
 *
 * Källa: https://skatteverket.entryscape.net/rowstore/dataset/
 * fad86bf9-67e3-4d68-829c-7b9a23bc5e42 — verifierad direkt via curl innan
 * den här filen skrevs (se konversationen), inte bara en sammanfattning.
 *
 * Scope: bara innevarande år och föregående år. Räcker för "ny bil"-
 * poängsättningen (se isEssentiallyNewCar i lib/scoring/engine.ts) — att
 * synka hela historiken 2008–idag (~78 000 rader) är inte nödvändigt för
 * det scopet och skulle göra varje körning mycket tyngre.
 */

import { NextApiRequest, NextApiResponse } from 'next'
import { upsertNewCarPrices } from '../../../lib/supabase/client'
import type { NewCarPriceRow } from '../../../lib/supabase/client'

const DATASET_URL = 'https://skatteverket.entryscape.net/rowstore/dataset/fad86bf9-67e3-4d68-829c-7b9a23bc5e42/json'
const PAGE_SIZE    = 100   // API:ets faktiska serverside-tak, oavsett begärt _limit
const CONCURRENCY  = 10

interface SkatteverketRow {
  kod: string
  marke: string
  modell: string
  tillverkningsar: string
  nybilspris: string
  bransletyp: string
}

async function fetchPage(year: number, offset: number): Promise<{ results: SkatteverketRow[]; resultCount: number }> {
  const res = await fetch(`${DATASET_URL}?tillverkningsar=${year}&_offset=${offset}&_limit=${PAGE_SIZE}`, {
    headers: { Accept: 'application/json' },
    signal: AbortSignal.timeout(15000),
  })
  if (!res.ok) throw new Error(`Skatteverket svarade med ${res.status}`)
  return res.json()
}

function toRow(r: SkatteverketRow): NewCarPriceRow | null {
  const price = parseInt(r.nybilspris, 10)
  const year  = parseInt(r.tillverkningsar, 10)
  if (!r.kod || !r.marke || !r.modell || !Number.isFinite(price) || !Number.isFinite(year)) return null
  return {
    source_code: r.kod,
    brand: r.marke,
    model_raw: r.modell,
    manufacturing_year: year,
    price_sek: price,
    fuel_type: r.bransletyp || null,
  }
}

async function syncYear(year: number): Promise<{ synced: number; failed: number }> {
  const first = await fetchPage(year, 0)
  const rows: NewCarPriceRow[] = first.results.map(toRow).filter((r): r is NewCarPriceRow => r !== null)

  const totalPages = Math.ceil(first.resultCount / PAGE_SIZE)
  const remainingOffsets = Array.from({ length: Math.max(0, totalPages - 1) }, (_, i) => (i + 1) * PAGE_SIZE)

  for (let i = 0; i < remainingOffsets.length; i += CONCURRENCY) {
    const chunk = remainingOffsets.slice(i, i + CONCURRENCY)
    const pages = await Promise.all(chunk.map(offset => fetchPage(year, offset)))
    for (const page of pages) {
      rows.push(...page.results.map(toRow).filter((r): r is NewCarPriceRow => r !== null))
    }
  }

  let synced = 0
  let failed = 0
  const BATCH = 500
  for (let i = 0; i < rows.length; i += BATCH) {
    const { error } = await upsertNewCarPrices(rows.slice(i, i + BATCH))
    if (error) {
      console.error(`[sync-new-car-prices] Batch-fel för ${year}:`, error)
      failed += rows.slice(i, i + BATCH).length
    } else {
      synced += rows.slice(i, i + BATCH).length
    }
  }

  return { synced, failed }
}

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
      results[year] = await syncYear(year)
    } catch (err: any) {
      console.error(`[sync-new-car-prices] Fel för ${year}:`, err?.message ?? err)
      results[year] = { error: err?.message ?? String(err) }
    }
  }

  return res.status(200).json({ years: results })
}
