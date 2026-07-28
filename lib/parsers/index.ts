import type { SupportedSite } from '../../types'

export type { SupportedSite }

const SUPPORTED_DOMAINS: Record<string, SupportedSite> = {
  'blocket.se':  'blocket',
  'wayke.se':    'wayke',
  'bytbil.com':  'bytbil',
}

export function detectSite(url: string): SupportedSite | null {
  try {
    const hostname = new URL(url).hostname.replace(/^www\./, '')
    return SUPPORTED_DOMAINS[hostname] ?? null
  } catch {
    return null
  }
}

export function validateListingUrl(url: string): {
  valid: boolean; error?: string; site?: SupportedSite
} {
  const site = detectSite(url)
  if (!site) {
    return {
      valid: false,
      error: `Sajten stöds inte. Stödda sajter: ${Object.keys(SUPPORTED_DOMAINS).join(', ')}`,
    }
  }

  const path = new URL(url).pathname
  if (site === 'blocket' && !path.includes('/annons/') && !path.includes('/bilar/')) {
    return { valid: false, error: 'Det ser ut som en söksida. Klistra in länken till en specifik annons.' }
  }
  if (site === 'wayke' && !path.includes('/bil/')) {
    return { valid: false, error: 'Det ser ut som en söksida. Klistra in länken till en specifik annons.' }
  }

  return { valid: true, site }
}
'test'
