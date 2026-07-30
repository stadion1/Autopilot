'use client'

import { useState, useRef } from 'react'
import { useRouter } from 'next/navigation'
import styles from './page.module.css'

const SUPPORTED_SITES = [
  { key: 'blocket', name: 'Blocket' },
  { key: 'wayke',   name: 'Wayke' },
  { key: 'bytbil',  name: 'Bytbil' },
]

const EXAMPLE_URLS = [
  'blocket.se/annons/volvo-v60-t5-inscription',
  'wayke.se/objekt/bmw-320d-xdrive',
  'bytbil.com/vastra-gotalands-lan/personbil-corolla-hybrid-1122-19298930',
]

// Håller spinnern synlig minst så här länge innan vi navigerar vidare —
// annars hinner den inte synas alls vid ett snabbt (cachat) svar.
const MIN_ANALYZE_BTN_MS = 1000

export default function HomePage() {
  const [url, setUrl] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [placeholder] = useState(EXAMPLE_URLS[Math.floor(Math.random() * EXAMPLE_URLS.length)])
  const inputRef = useRef<HTMLInputElement>(null)
  const router = useRouter()

  async function handleAnalyze() {
    const trimmed = url.trim()
    if (!trimmed) {
      inputRef.current?.focus()
      return
    }

    setError('')
    setLoading(true)
    const startedAt = Date.now()

    try {
      const res = await fetch('/api/analyze', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ url: trimmed }),
      })

      const data = await res.json()

      if (!res.ok) {
        setError(data.error ?? 'Något gick fel. Försök igen.')
        setLoading(false)
        return
      }

      // Triggar det tunga jobbet (skrapning, scoring, AI) utan att invänta
      // svaret — vi navigerar direkt och låter analyssidans fyrastegs-vy
      // (som redan pollar /api/analysis/[id]) visa den riktiga väntetiden,
      // istället för att gömma den bakom bara en knapp-spinner.
      if (!data.cached) {
        fetch('/api/process', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ id: data.id, url: trimmed }),
        }).catch(() => {})
      }

      const elapsed = Date.now() - startedAt
      await new Promise(r => setTimeout(r, Math.max(0, MIN_ANALYZE_BTN_MS - elapsed)))
      router.push(`/analysis/${data.id}`)
    } catch {
      setError('Kunde inte nå servern. Kontrollera din anslutning.')
      setLoading(false)
    }
  }

  function handleKey(e: React.KeyboardEvent) {
    if (e.key === 'Enter') handleAnalyze()
  }

  return (
    <main className={styles.main}>
      {/* ── Grain texture overlay ── */}
      <div className={styles.grain} aria-hidden />

      {/* ── Subtle background marks ── */}
      <div className={styles.bgMark1} aria-hidden />
      <div className={styles.bgMark2} aria-hidden />

      {/* ── Hero ── */}
      <section className={styles.hero}>
        <div className={`${styles.eyebrow} anim-fade-up`}>
          <span className={styles.eyebrowDot} />
          AI-driven bilanalys för den svenska marknaden
        </div>

        <h1 className={`${styles.headline} anim-fade-up delay-1`}>
          Förstå om bilen är<br />
          <em className={styles.headlineEm}>ett smart köp</em>
        </h1>

        <p className={`${styles.subline} anim-fade-up delay-2`}>
          Klistra in en länk från Blocket, Wayke eller Bytbil.<br />
          Vi analyserar pris, risker och ger dig ett ärligt omdöme.
        </p>

        {/* ── Input ── */}
        <div className={`${styles.inputWrap} anim-fade-up delay-3`}>
          <div className={`${styles.inputBox} ${error ? styles.inputBoxError : ''}`}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" strokeWidth="1.5" className={styles.inputIcon}
              aria-hidden>
              <path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/>
              <path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/>
            </svg>
            <input
              ref={inputRef}
              type="url"
              value={url}
              onChange={e => { setUrl(e.target.value); setError('') }}
              onKeyDown={handleKey}
              placeholder={`t.ex. https://www.${placeholder}`}
              className={styles.input}
              disabled={loading}
              autoFocus
              aria-label="Klistra in bilannonsens URL"
            />
            <button
              onClick={handleAnalyze}
              disabled={loading}
              className={`${styles.analyzeBtn} ${loading ? styles.analyzeBtnLoading : ''}`}
              aria-label="Analysera annonsen"
            >
              {loading ? (
                <>
                  <span className={styles.spinner} aria-hidden />
                  Analyserar…
                </>
              ) : (
                <>
                  Analysera
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                    stroke="currentColor" strokeWidth="2" aria-hidden>
                    <path d="M5 12h14M12 5l7 7-7 7"/>
                  </svg>
                </>
              )}
            </button>
          </div>

          {error && (
            <p className={styles.errorMsg} role="alert">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                stroke="currentColor" strokeWidth="2" aria-hidden>
                <circle cx="12" cy="12" r="10"/>
                <line x1="12" y1="8" x2="12" y2="12"/>
                <line x1="12" y1="16" x2="12.01" y2="16"/>
              </svg>
              {error}
            </p>
          )}

          <div className={styles.trustBadges}>
            {['Gratis', 'Ingen inloggning', 'Inga dolda intressen'].map(t => (
              <span key={t} className={styles.trustBadge}>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none"
                  stroke="currentColor" strokeWidth="2.5" aria-hidden>
                  <polyline points="20 6 9 17 4 12"/>
                </svg>
                {t}
              </span>
            ))}
          </div>

          <div className={styles.supportedSites}>
            <span className={styles.supportedLabel}>Stöds:</span>
            {SUPPORTED_SITES.map(site => (
              <span key={site.key} className={styles.sitePill} data-site={site.key}>{site.name}</span>
            ))}
          </div>
        </div>
      </section>

      {/* ── Sample result ── */}
      <section className={`${styles.sampleWrap} anim-fade-up delay-4`}>
        <span className={styles.sampleLabel}>Exempel på ett resultat</span>
        <div className={`${styles.sampleCard} card`}>
          <div className={styles.sampleTop}>
            <div>
              <p className={styles.sampleCarName}>Volvo V90 T4 Momentum · 2019</p>
              <div className={styles.sampleScoreLine}>
                <span className={styles.sampleScoreNum}>72</span>
                <span className={styles.sampleScoreMax}>/100 deal score</span>
              </div>
            </div>
            <span className="tag tag-green">Bra affär</span>
          </div>
          <p className={styles.sampleSummary}>
            "Priset ligger klart under marknadsvärdet och mätarställningen är lägre
            än väntat för årsmodellen — en av de bättre affärerna vi sett i den här
            klassen just nu."
          </p>
        </div>
      </section>

      {/* ── Divider ── */}
      <div className={`${styles.divider} anim-fade-up delay-5`} aria-hidden />

      {/* ── Value props ── */}
      <section className={`${styles.valueProps} anim-fade-up delay-6`}>
        <ValueProp
          icon={<IconClock />}
          title="Direkt analys"
          desc="Resultat under 30 sekunder. Ingen registrering eller betalning krävs."
        />
        <ValueProp
          icon={<IconChart />}
          title="Prisreferens"
          desc="Jämförs mot aktuella marknadsdata för liknande bilar i Sverige."
        />
        <ValueProp
          icon={<IconShield />}
          title="Riskanalys"
          desc="Kända problem för modellen, varningsflaggor och ägarekostnader."
        />
        <ValueProp
          icon={<IconAI />}
          title="AI-sammanfattning"
          desc="En ärlig, tydlig bedömning formulerad som råd från en kunnig vän."
        />
      </section>

      {/* ── Trust line ── */}
      <p className={`${styles.trustLine} anim-fade-up delay-7`}>
        Transparent metodologi — varje poäng kan förklaras. Ingen reklam.
      </p>
    </main>
  )
}

function ValueProp({ icon, title, desc }: {
  icon: React.ReactNode; title: string; desc: string
}) {
  return (
    <div className={styles.vpCard}>
      <div className={styles.vpIcon}>{icon}</div>
      <h3 className={styles.vpTitle}>{title}</h3>
      <p className={styles.vpDesc}>{desc}</p>
    </div>
  )
}

/* ── Icons ── */
const IconClock = () => (
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
    stroke="currentColor" strokeWidth="1.5" aria-hidden>
    <circle cx="12" cy="12" r="10"/>
    <polyline points="12 6 12 12 16 14"/>
  </svg>
)
const IconChart = () => (
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
    stroke="currentColor" strokeWidth="1.5" aria-hidden>
    <line x1="18" y1="20" x2="18" y2="10"/>
    <line x1="12" y1="20" x2="12" y2="4"/>
    <line x1="6"  y1="20" x2="6"  y2="14"/>
    <line x1="2"  y1="20" x2="22" y2="20"/>
  </svg>
)
const IconShield = () => (
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
    stroke="currentColor" strokeWidth="1.5" aria-hidden>
    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
  </svg>
)
const IconAI = () => (
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
    stroke="currentColor" strokeWidth="1.5" aria-hidden>
    <path d="M12 2L2 7l10 5 10-5-10-5z"/>
    <path d="M2 17l10 5 10-5"/>
    <path d="M2 12l10 5 10-5"/>
  </svg>
)
