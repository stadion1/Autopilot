/**
 * GET /api/cron/score-listings
 *
 * Vercel Cron — (re)beräknar deal_score för aktiva rader i market_listings
 * med samma scoring-motor som en enskild bilanalys använder.
 *
 * Körs som ett separat jobb i den här appen istället för att byggas in i
 * scraper-service/nightly.ts, eftersom lib/scoring/engine.ts lever här och
 * scraper-service byggs/deployas fristående på Railway (kan inte importera
 * filer utanför sin egen mapp — se kommentaren i nightly.ts).
 *
 * Måste köras regelbundet, inte bara en gång vid insamling — get_market_median()
 * räknas ut live från market_listings, så en poäng som räknades ut när det
 * bara fanns någon enstaka bil av samma modell blir inaktuell när fler
 * annonser strömmar in. getListingsNeedingScore() prioriterar aldrig
 * poängsatta rader, sedan de med äldst deal_score_updated_at.
 *
 * Kör INTE AI-analysen (analyzeWithAI) här — den kostar per anrop och är till
 * för den enskilda bil en användare faktiskt tittar på, inte för att
 * poängsätta hela marknaden varje natt.
 *
 * SKALNING (2026-08-12): körde tidigare en gång/dygn med BATCH_SIZE=150.
 * Med ~5 126 aktiva rader och SCORE_STALE_AFTER_HOURS=24 (i client.ts) blir
 * praktiskt taget HELA tabellen kvalificerad för omscoring varje dygn ändå
 * (varje rad hinner bli >24h gammal mellan körningarna), plus ~400 nya
 * rader per natt från scraper-service/nightly.ts som alltid går FÖRE i kön
 * (nullsFirst-sortering på deal_score_updated_at). 150/dygn < 400 nya/natt
 * — backloggen av redan poängsatta men nu inaktuella rader fick alltså
 * ALDRIG någon budget kvar, den var permanent fastlåst, inte bara några
 * dagar efter. Höjt BATCH_SIZE och vercel.json:s schema körs nu varje
 * timme istället för en gång/dygn (se crons-arrayen) — 24 körningar × 400
 * ≈ 9 600/dygn, gott om marginal mot ~5 500 dagligen kvalificerade rader.
 * Frekvens hellre än en enda jättebatch, för att hålla varje körning kort
 * och inte chansa på ett långt maxDuration.
 */

import { NextApiRequest, NextApiResponse } from 'next'
import { getListingsNeedingScore, saveListingScore } from '../../../lib/supabase/client'
import { scoreVehicle } from '../../../lib/scoring/engine'
import type { CarListing, FuelType, Transmission, SupportedSite, SellerType } from '../../../types'

export const config = { maxDuration: 60 }

const BATCH_SIZE  = parseInt(process.env.SCORE_CRON_BATCH_SIZE ?? '400', 10)
const CONCURRENCY = 10

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (process.env.CRON_SECRET) {
    if (req.headers.authorization !== `Bearer ${process.env.CRON_SECRET}`) {
      return res.status(401).json({ error: 'Unauthorized' })
    }
  }

  const listings = await getListingsNeedingScore(BATCH_SIZE)
  let scored = 0
  let failed = 0

  for (let i = 0; i < listings.length; i += CONCURRENCY) {
    const chunk = listings.slice(i, i + CONCURRENCY)
    await Promise.all(chunk.map(async listing => {
      try {
        const car: CarListing = {
          brand:                listing.brand,
          model:                listing.model,
          variant:              listing.variant ?? undefined,
          year:                 listing.year,
          price_sek:            listing.price_sek,
          mileage_km:           listing.mileage_km,
          fuel_type:            listing.fuel_type as FuelType,
          transmission:         listing.transmission as Transmission,
          location:             listing.location ?? undefined,
          seller_type:          (listing.seller_type as SellerType) ?? undefined,
          registration_number:  listing.registration_number ?? undefined,
          vin:                  listing.vin ?? undefined,
          source_url:           listing.source_url,
          source_site:          listing.source_site as SupportedSite,
        }
        const { scores } = await scoreVehicle(car)
        await saveListingScore(listing.id, scores.deal)
        scored++
      } catch (err: any) {
        console.error(`[score-listings] Misslyckades för ${listing.id}:`, err?.message ?? err)
        failed++
      }
    }))
  }

  console.log(`[score-listings] ${scored} poängsatta, ${failed} misslyckade, av ${listings.length} hämtade`)
  return res.status(200).json({ scored, failed, total: listings.length })
}
