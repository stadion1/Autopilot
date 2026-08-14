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
        <Footer />
      </body>
    </html>
  )
}

function Footer() {
  return (
    <footer className="footer">
      © {new Date().getFullYear()} Carzi — AI-driven bilanalys för den svenska marknaden.
    </footer>
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
            fill="#FAFAF8">carz<tspan id="carzi-logo-i">i</tspan></text>
          <circle id="carzi-logo-dot" cx="765" cy="42" r="11" fill="#2563EB" style={{ opacity: 0, transition: 'opacity 0.15s' }}/>
        </svg>
      </a>
      <span className="nav-badge">Beta</span>
      <script dangerouslySetInnerHTML={{ __html: `
        (function () {
          function positionDot() {
            var i = document.getElementById('carzi-logo-i');
            var dot = document.getElementById('carzi-logo-dot');
            if (!i || !dot) return;
            var box = i.getBBox();
            dot.setAttribute('cx', box.x + box.width / 2);
            dot.setAttribute('cy', box.y - 18);
            dot.style.opacity = '1';
          }
          if (document.fonts && document.fonts.ready) {
            document.fonts.ready.then(positionDot).catch(positionDot);
          }
          window.addEventListener('load', positionDot);
          positionDot();
        })();
      ` }} />
    </nav>
  )
}
