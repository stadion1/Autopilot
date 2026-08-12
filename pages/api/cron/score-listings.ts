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
 * dagar efter.
 *
 * Försökte först lösa det med ett timschema (24 körningar/dygn istället för
 * 1) — men Vercel Hobby tillåter bara dagliga crons, så deployen blockerades
 * helt (byggfel, ingen ny deployment gick igenom alls). Löst inom dagligt
 * schema istället genom att göra VARJE körning mycket snabbare: scoreVehicle()
 * i engine.ts gjorde tre databasuppslag (marknadsmedian, nybilspris,
 * mätarställnings-känslighet) i SEKVENS trots att de är oberoende av
 * varandra — kör dem nu parallellt med Promise.all, vilket tar bort ~2 av 3
 * databas-tur-och-retur per bil. Höjt BATCH_SIZE och CONCURRENCY i linje med
 * det, så en enda daglig körning hinner betydligt mer inom 60s-taket.
 * Tömmer inte hela backloggen på en dag, men gör stadigt och hållbart
 * framsteg (se räkneexemplet nedan) — kolla `scored`/`total` i loggarna
 * efter nästa körning och justera SCORE_CRON_BATCH_SIZE-miljövariabeln om
 * det visar sig ta för lång tid.
 */

import { NextApiRequest, NextApiResponse } from 'next'
import { getListingsNeedingScore, saveListingScore } from '../../../lib/supabase/client'
import { scoreVehicle } from '../../../lib/scoring/engine'
import type { CarListing, FuelType, Transmission, SupportedSite, SellerType } from '../../../types'

export const config = { maxDuration: 60 }

// Efter parallelliseringen ovan är per-bil-kostnaden ~1 databas-tur-och-
// retur istället för ~3 — vid CONCURRENCY=20 bör 2000 rader hinnas med
// gott om marginal inom 60s (grov uppskattning, inte uppmätt: 2000/20=100
// "vågor" × ~300-500ms ≈ 30-50s). 2000/dygn mot ~400 nya/natt ger ett
// netto på ~1600/dygn — tömmer ~5 100-raders backloggen på ungefär en
// vecka, håller sedan jämna steg med god marginal.
const BATCH_SIZE  = parseInt(process.env.SCORE_CRON_BATCH_SIZE ?? '2000', 10)
const CONCURRENCY = 20

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
