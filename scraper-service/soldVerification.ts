/**
 * scraper-service/soldVerification.ts
 *
 * Delad mellan nightly.ts (körs varje natt) och server.ts (exponerar ett
 * manuellt backfill-endpoint) — "är den här annonsen faktiskt borta"-logiken
 * ska bara finnas på ett ställe.
 */

const AD_URL = 'https://blocket-api.se/v1/ad/car'

// null = kunde inte avgöras (nätverksfel/timeout) — ska INTE tolkas som såld,
// bara försökas igen senare.
export async function verifyBlocketAdGone(adId: string): Promise<boolean | null> {
  try {
    const res = await fetch(`${AD_URL}?id=${adId}`, {
      headers: { Accept: 'application/json', 'User-Agent': 'bilanalys-nightly/1.0' },
      signal: AbortSignal.timeout(10000),
    })
    if (res.status === 404 || res.status === 410) return true   // bekräftat borta
    if (!res.ok) return null                                     // annat fel — oklart
    const ad = await res.json().catch(() => null)
    return !ad || !ad.title   // saknar grundläggande fält = i praktiken borta
  } catch {
    return null   // timeout/nätverksfel — oklart, inte samma sak som borta
  }
}

export function daysListedSince(firstSeenAt: string): number {
  const days = (Date.now() - new Date(firstSeenAt).getTime()) / (1000 * 60 * 60 * 24)
  return Math.max(1, Math.round(days))
}
