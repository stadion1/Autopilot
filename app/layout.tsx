import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Bilanalys — Intelligent bilrådgivning',
  description: 'Klistra in en bilannons och förstå direkt om det är ett smart köp. AI-driven prisanalys, riskbedömning och ägarekostnader för den svenska begagnatmarknaden.',
  keywords: 'begagnad bil, bilanalys, bilrådgivning, blocket bilar, pris, andrahandsvärde',
  openGraph: {
    title: 'Bilanalys — Intelligent bilrådgivning',
    description: 'Förstå om bilen är ett smart köp.',
    type: 'website',
  },
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="sv">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
      </head>
      <body>
        <Nav />
        {children}
      </body>
    </html>
  )
}

function Nav() {
  return (
    <nav className="nav" role="navigation" aria-label="Huvudnavigation">
      <a href="/" className="nav-logo" aria-label="Bilanalys — startsidan">
        <div className="nav-logo-mark" aria-hidden>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" strokeWidth="1.5">
            <path d="M5 11l1.5-4.5h11L19 11"/>
            <rect x="3" y="11" width="18" height="7" rx="1"/>
            <circle cx="7"  cy="18" r="1.5"/>
            <circle cx="17" cy="18" r="1.5"/>
          </svg>
        </div>
        <span className="nav-logo-text">Bilanalys</span>
      </a>
      <span className="nav-badge">Beta</span>
    </nav>
  )
}
