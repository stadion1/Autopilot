/**
 * Bytbil.com parser
 *
 * Tidigare version antog ett window.__INITIAL_STATE__-objekt (Redux/Next.js-
 * mönster). Verifierat mot en riktig annons att det inte stämmer — Bytbil är
 * en traditionell server-renderad sajt (ASP.NET, inga JS-ramverk alls), så
 * ingen Playwright/JS-körning behövs — precis som Blocket och Wayke landade i.
 *
 * Fordonsdata ligger i två enkla HTML-block i sidans initiala källkod:
 * 1. En <dl><dt>/<dd>-lista med grundspecar (märke, modell, årsmodell,
 *    miltal, regnr, drivmedel, växellåda, färg).
 * 2. Ett "Uppgifter från Transportstyrelsen"-block (text-gray/uk-text-bold-
 *    par) med bl.a. exakt registreringsdatum ("I trafik") och motoreffekt —
 *    inget VIN/chassinummer exponeras dock, till skillnad från Blocket/Wayke.
 *
 * Bytbil verkar vara en ren handlar-marknadsplats (GitHub-orgens egen
 * beskrivning: "Alla bilar från alla Sveriges bilhandlare" — bilhandlare =
 * återförsäljare, inte privatpersoner; inga "Privatperson"-annonser
 * observerade) — seller_type sätts därför till 'dealer' rakt av, samma
 * resonemang som för wayke.ts.
 */

import { CarListing, ScraperResult } from './types'
import { parseFuelType, parseTransmission } from './blocket'

function extractBytbilId(url: string): string | null {
  const match = url.match(/-(\d{6,})\/?$/)
  return match?.[1] ?? null
}

function decodeHtmlEntities(s: string): string {
  return s
    .replace(/&#x([0-9a-fA-F]+);/g, (_, hex) => String.fromCharCode(parseInt(hex, 16)))
    .replace(/&#(\d+);/g,           (_, dec) => String.fromCharCode(parseInt(dec, 10)))
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g,  '&')
    .replace(/&lt;/g,   '<')
    .replace(/&gt;/g,   '>')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g,  "'")
    .replace(/<[^>]*>/g, '')   // ta bort ev. kvarvarande inline-taggar (t.ex. <sub> i CO2-värden)
    .trim()
}

function extractDlPairs(html: string): Record<string, string> {
  const pairs: Record<string, string> = {}
  const re = /<dt>([^<]*)<\/dt>\s*<dd>([\s\S]*?)<\/dd>/g
  let m: RegExpExecArray | null
  while ((m = re.exec(html))) {
    pairs[decodeHtmlEntities(m[1])] = decodeHtmlEntities(m[2])
  }
  return pairs
}

function extractLabelValuePairs(html: string): Record<string, string> {
  const pairs: Record<string, string> = {}
  const re = /<div class="text-gray">\s*([^<]*?)\s*<\/div>\s*<div class="uk-text-bold">([\s\S]*?)<\/div>/g
  let m: RegExpExecArray | null
  while ((m = re.exec(html))) {
    pairs[decodeHtmlEntities(m[1])] = decodeHtmlEntities(m[2])
  }
  return pairs
}

function extractImages(html: string): string[] {
  const seen = new Set<string>()
  const images: string[] = []
  for (const m of html.matchAll(/src="(https:\/\/pro\.bbcdn\.io\/[^"]+)"/g)) {
    const base = m[1].split('?')[0]
    if (seen.has(base)) continue
    seen.add(base)
    images.push(m[1])
  }
  return images.slice(0, 6)
}

function parseMil(raw?: string): number | undefined {
  if (!raw) return undefined
  const num = parseInt(raw.replace(/\D/g, ''))
  return isNaN(num) ? undefined : num * 10   // mil → km
}

function parsePriceKr(raw?: string): number | undefined {
  if (!raw) return undefined
  // Måste HTML-avkodas FÖRE siffer-strippningen — annars läcker "0":an i
  // en oavkodad &#xA0;-entitet igenom som en riktig siffra (429&#xA0;900
  // blir "4290900" istället för "429900", eftersom \D bara filtrerar
  // bort icke-siffror och "0" i "xA0" räknas som en siffra).
  const num = parseInt(decodeHtmlEntities(raw).replace(/\D/g, ''))
  return isNaN(num) ? undefined : num
}

function parseHorsepower(raw?: string): number | undefined {
  if (!raw) return undefined
  const match = raw.match(/(\d+)\s*hk/i)
  return match ? parseInt(match[1]) : undefined
}

export async function parseBytbil(_: unknown, url: string): Promise<ScraperResult> {
  try {
    const id = extractBytbilId(url)
    if (!id) return { success: false, error: 'Kunde inte extrahera annons-ID från URL' }

    const res = await fetch(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
    })
    if (!res.ok) {
      return { success: false, error: `Bytbil svarade med ${res.status}` }
    }

    const html = await res.text()

    const specs = extractDlPairs(html)          // Märke, Modell, Årsmodell, Miltal, Regnr, Drivmedel, Växellåda, Färg...
    const tsData = extractLabelValuePairs(html) // I trafik, Motoreffekt, Fordonsår...

    if (!specs['Märke'] && !specs['Modell']) {
      return { success: false, error: 'Kunde inte hitta fordonsdata i annonssidan' }
    }

    const titleMatch = html.match(/<h1 class="vehicle-detail-title">([^<]*)<\/h1>/)
    const title = titleMatch ? decodeHtmlEntities(titleMatch[1]) : ''
    const brand = specs['Märke']
    const model = specs['Modell']
    let variant: string | undefined
    if (title && brand && model) {
      const prefix = new RegExp(`^${brand}\\s+${model}\\s+`, 'i')
      variant = title.replace(prefix, '').trim() || undefined
    }

    const priceMatch = html.match(/<span class="car-price-details">\s*([^<]*?)\s*<\/span>/)
    const descMatch  = html.match(/vehicle-detail-equipment-detail[^>]*>([\s\S]*?)<\/div>/)

    // "I trafik" var YYYY-MM-DD i det verifierade exemplet — spara bara om
    // det faktiskt matchar det formatet, annars lämna det obestämt hellre
    // än att gissa på ett annat datumformat.
    let registrationDate: string | undefined
    if (tsData['I trafik'] && /^\d{4}-\d{2}-\d{2}$/.test(tsData['I trafik'])) {
      registrationDate = tsData['I trafik']
    }

    const data: Partial<CarListing> = {
      brand,
      model,
      variant,
      year:         specs['Årsmodell'] ? parseInt(specs['Årsmodell']) : undefined,
      price_sek:    parsePriceKr(priceMatch?.[1]),
      mileage_km:   parseMil(specs['Miltal']),
      fuel_type:    parseFuelType(specs['Drivmedel'] ?? tsData['Drivmedel']),
      transmission: parseTransmission(specs['Växellåda']),
      horsepower:   parseHorsepower(tsData['Motoreffekt']),
      color:        specs['Färg'],
      registration_number: specs['Regnr'],
      registration_date: registrationDate,
      seller_type:  'dealer',
      description:  descMatch ? decodeHtmlEntities(descMatch[1]) || undefined : undefined,
      images:       extractImages(html),
      source_url:   url,
      source_site:  'bytbil',
    }

    return { success: true, data }

  } catch (err: any) {
    return { success: false, error: err.message ?? 'Okänt fel i Bytbil-parsern' }
  }
}
