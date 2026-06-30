/**
 * Scraper stealth configuration.
 *
 * Goal: look like a real user, not a bot.
 * We do NOT try to circumvent any paywalls or authenticated content.
 * We only fetch publicly visible listing pages.
 *
 * Techniques used:
 * - Realistic user-agent rotation
 * - Random human-like delays between actions
 * - Viewport randomisation
 * - Disabling automation-detection headers
 * - Single request per listing (no crawling)
 */

import { Browser, BrowserContext, chromium, Page } from 'playwright'

const USER_AGENTS = [
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15',
]

const VIEWPORTS = [
  { width: 1440, height: 900 },
  { width: 1920, height: 1080 },
  { width: 1280, height: 800 },
  { width: 1366, height: 768 },
]

function randomFrom<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)]
}

/** Random delay between min and max ms — simulates human reading time */
export async function humanDelay(minMs = 800, maxMs = 2400): Promise<void> {
  const delay = Math.floor(Math.random() * (maxMs - minMs) + minMs)
  await new Promise(r => setTimeout(r, delay))
}

export interface StealthBrowserResult {
  browser: Browser
  context: BrowserContext
  page: Page
}

/**
 * Creates a new browser context configured to avoid bot detection.
 * Always call close() on the browser after use.
 */
export async function createStealthBrowser(): Promise<StealthBrowserResult> {
  const browser = await chromium.launch({
    headless: true,
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-accelerated-2d-canvas',
      '--disable-gpu',
      // Suppress webdriver flag that sites detect
      '--disable-blink-features=AutomationControlled',
    ],
  })

  const ua = randomFrom(USER_AGENTS)
  const viewport = randomFrom(VIEWPORTS)

  const context = await browser.newContext({
    userAgent: ua,
    viewport,
    // Accept Swedish locale — matches blocket.se expectations
    locale: 'sv-SE',
    timezoneId: 'Europe/Stockholm',
    // Realistic headers a real browser sends
    extraHTTPHeaders: {
      'Accept-Language': 'sv-SE,sv;q=0.9,en;q=0.8',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
      'Sec-Fetch-Site': 'none',
      'Sec-Fetch-Mode': 'navigate',
      'Sec-Fetch-User': '?1',
      'Sec-Fetch-Dest': 'document',
      'Upgrade-Insecure-Requests': '1',
      'Cache-Control': 'max-age=0',
    },
  })

  // Remove the `navigator.webdriver` property that Playwright sets by default
  await context.addInitScript(() => {
    Object.defineProperty(navigator, 'webdriver', { get: () => undefined })
    // Spoof plugins length to look like real browser
    Object.defineProperty(navigator, 'plugins', { get: () => [1, 2, 3, 4, 5] })
  })

  const page = await context.newPage()

  // Block heavy resources we don't need — faster + less fingerprinting surface
  await page.route('**/*.{png,jpg,jpeg,gif,webp,svg,ico,woff,woff2,ttf,mp4,mp3}', route => {
    // Exception: we DO want to capture image URLs, just not download the images
    route.abort()
  })
  await page.route('**/analytics**', route => route.abort())
  await page.route('**/tracking**', route => route.abort())
  await page.route('**/ads/**', route => route.abort())

  return { browser, context, page }
}

/**
 * Rate limiter — ensures we never hammer a domain.
 * Enforces a minimum gap between requests to the same host.
 */
const lastRequestTime: Record<string, number> = {}
const MIN_GAP_MS = 4000   // 4 seconds minimum between requests to same domain

export async function respectRateLimit(url: string): Promise<void> {
  const host = new URL(url).hostname
  const last = lastRequestTime[host] ?? 0
  const elapsed = Date.now() - last
  if (elapsed < MIN_GAP_MS) {
    await new Promise(r => setTimeout(r, MIN_GAP_MS - elapsed + Math.random() * 1000))
  }
  lastRequestTime[host] = Date.now()
}
