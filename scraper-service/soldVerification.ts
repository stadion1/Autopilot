/**
 * scraper-service/soldVerification.ts
 *
 * Delad mellan nightly.ts (körs varje natt) och server.ts (exponerar ett
 * manuellt backfill-endpoint) — "är den här annonsen faktiskt borta"-logiken
 * ska bara finnas på ett ställe.
 */

// VIKTIGT: blocket-api.se (tredjeparts-API:et vi använder för att skrapa
// annonsdata) fortsätter returnera HTTP 200 med fullständig annonsdata för
// annonser som är sålda/borttagna på riktiga Blocket — det verkar cacha/
// spegla data och speglar INTE borttagning i realtid. Verifierat direkt:
// en bekräftat borttagen annons (blocket.se visade "inte längre tillgänglig")
// gav ändå 200 OK med fullständiga fält från blocket-api.se. Att förlita sig
// på det APIet för "är den här borta" är därför i grunden opålitligt.
//
// Riktiga blocket.se returnerar också 200 för en borttagen annons (SPA,
// ingen 404), men sidans HTML innehåller texten "inte längre tillgänglig" /
// "sålts eller tagits bort" — verifierat både på en bekräftat borttagen och
// en bekräftat aktiv annons (frånvarande på den aktiva, ingen falsk positiv).
const REAL_AD_URL = 'https://www.blocket.se/mobility/item'
const GONE_MARKERS = ['inte längre tillgänglig', 'sålts eller tagits bort']

// null = kunde inte avgöras (nätverksfel/timeout) — ska INTE tolkas som såld,
// bara försökas igen senare.
export async function verifyBlocketAdGone(adId: string): Promise<boolean | null> {
  try {
    const res = await fetch(`${REAL_AD_URL}/${adId}`, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
      signal: AbortSignal.timeout(10000),
    })
    if (res.status === 404 || res.status === 410) return true   // bekräftat borta
    if (!res.ok) return null                                     // annat fel — oklart

    const html = await res.text()
    const lower = html.toLowerCase()
    return GONE_MARKERS.some(marker => lower.includes(marker))
  } catch {
    return null   // timeout/nätverksfel — oklart, inte samma sak som borta
  }
}

export function daysListedSince(firstSeenAt: string): number {
  const days = (Date.now() - new Date(firstSeenAt).getTime()) / (1000 * 60 * 60 * 24)
  return Math.max(1, Math.round(days))
}
