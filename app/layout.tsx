import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Carzi — Intelligent bilrådgivning',
  description: 'Klistra in en bilannons och förstå direkt om det är ett smart köp. AI-driven prisanalys, riskbedömning och ägarekostnader för den svenska begagnatmarknaden.',
  keywords: 'begagnad bil, bilanalys, bilrådgivning, blocket bilar, pris, andrahandsvärde',
  openGraph: {
    title: 'Carzi — Intelligent bilrådgivning',
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
      <a href="/" className="nav-logo" aria-label="Carzi — startsidan">
        <svg className="nav-logo-svg" viewBox="0 0 900 220" xmlns="http://www.w3.org/2000/svg" aria-hidden>
          <text
            x="50"
            y="155"
            fontFamily="Inter, Avenir, Helvetica, Arial, sans-serif"
            fontSize="150"
            fontWeight="700"
            letterSpacing="-4"
            fill="#111418">
            carzi
          </text>
          <circle cx="765" cy="42" r="11" fill="#0057FF"/>
        </svg>
      </a>
      <span className="nav-badge">Beta</span>
    </nav>
  )
}
