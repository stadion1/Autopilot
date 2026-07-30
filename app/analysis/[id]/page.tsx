'use client'

import { useEffect, useMemo, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import styles from './page.module.css'
import type { AnalysisResult } from '../../../types'
import {
  calculateOwnershipCosts, DEFAULT_FINANCING, OWNERSHIP_COST_CATEGORIES,
  type FinancingInput,
} from '../../../lib/scoring/ownershipCost'
import { UNKNOWN_MODEL_REASON } from '../../../lib/scoring/constants'

/* ── Loading state ── */
const LOAD_STEPS = [
  'Hämtar annonsdata',
  'Normaliserar fordonsinformation',
  'Jämför med marknadsdata',
  'AI-analys och riskbedömning',
]
const STEP_INTERVALS_MS = [1200, 2600, 4000]
const MIN_LOADING_MS = STEP_INTERVALS_MS[STEP_INTERVALS_MS.length - 1] + 900

function LoadingView() {
  const [step, setStep] = useState(0)

  useEffect(() => {
    const timers = STEP_INTERVALS_MS.map((ms, i) =>
      setTimeout(() => setStep(i + 1), ms)
    )
    return () => timers.forEach(clearTimeout)
  }, [])

  return (
    <div className={styles.loadingView}>
      <div className={styles.loadingSpinner} aria-label="Analyserar" />
      <h2 className={`${styles.loadingTitle} serif`}>Analyserar annonsen</h2>
      <p className={styles.loadingSubtitle}>Det tar vanligtvis 10–20 sekunder</p>
      <ul className={styles.stepList} role="list">
        {LOAD_STEPS.map((label, i) => (
          <li
            key={i}
            className={`${styles.stepItem}
              ${i === step ? styles.stepActive : ''}
              ${i < step ? styles.stepDone : ''}`}
          >
            <span className={styles.stepDot} aria-hidden>
              {i < step ? (
                <svg width="10" height="10" viewBox="0 0 24 24" fill="none"
                  stroke="currentColor" strokeWidth="3">
                  <polyline points="20 6 9 17 4 12"/>
                </svg>
              ) : null}
            </span>
            {label}
          </li>
        ))}
      </ul>
    </div>
  )
}

/* ── Main page ── */
export default function AnalysisPage() {
  const params = useParams<{ id: string }>()
  const id = params?.id
  const router = useRouter()
  const [data, setData] = useState<AnalysisResult | null>(null)
  const [status, setStatus] = useState<'loading' | 'done' | 'error'>('loading')
  const [errorMsg, setErrorMsg] = useState('')
  const [activeImg, setActiveImg] = useState(0)
  const [linkCopied, setLinkCopied] = useState(false)
  const [lightboxOpen, setLightboxOpen] = useState(false)

  useEffect(() => {
    if (!id) return
    let cancelled = false
    const startedAt = Date.now()

    // Håll kvar laddningsvyn minst tills stegen (LOAD_STEPS) hunnit spelas
    // upp, annars hoppar den direkt till resultatet när svaret är cachat.
    function afterMinDuration(fn: () => void) {
      const remaining = MIN_LOADING_MS - (Date.now() - startedAt)
      setTimeout(() => { if (!cancelled) fn() }, Math.max(0, remaining))
    }

    async function poll() {
      for (let attempt = 0; attempt < 30; attempt++) {
        if (cancelled) return
        try {
          const res = await fetch(`/api/analysis/${id}`)
          if (!res.ok) {
            if (res.status === 404) {
              await new Promise(r => setTimeout(r, 2000))
              continue
            }
            throw new Error('Server error')
          }
          const json = await res.json()
          if (json.status === 'done') {
            afterMinDuration(() => { setData(json); setStatus('done') })
            return
          }
          if (json.status === 'error') {
            afterMinDuration(() => { setErrorMsg(json.error ?? 'Analys misslyckades'); setStatus('error') })
            return
          }
          await new Promise(r => setTimeout(r, 1500))
        } catch (e) {
          afterMinDuration(() => { setErrorMsg('Kunde inte hämta analys'); setStatus('error') })
          return
        }
      }
      if (!cancelled) { setErrorMsg('Analysen tog för lång tid'); setStatus('error') }
    }

    poll()
    return () => { cancelled = true }
  }, [id])

  if (status === 'loading') return (
    <main className={styles.page}>
      <LoadingView />
    </main>
  )

  if (status === 'error') return (
    <main className={styles.page}>
      <div className={styles.errorView}>
        <div className={styles.errorIcon}>
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" strokeWidth="1.5">
            <circle cx="12" cy="12" r="10"/>
            <line x1="12" y1="8" x2="12" y2="12"/>
            <line x1="12" y1="16" x2="12.01" y2="16"/>
          </svg>
        </div>
        <h2 className="serif">Något gick fel</h2>
        <p>{errorMsg}</p>
        <button className="btn btn-primary" onClick={() => router.push('/')}>
          Försök igen
        </button>
      </div>
    </main>
  )

  if (!data) return null

  const { car, scores, confidence, pricing, pros, cons, risks, verdict, ai_summary, meta } = data
  const mileageMil = Math.round(car.mileage_km / 10)

  function handleShare() {
    navigator.clipboard.writeText(window.location.href).then(() => {
      setLinkCopied(true)
      setTimeout(() => setLinkCopied(false), 2000)
    })
  }

  return (
    <main className={styles.page}>
      <div className={styles.container}>

        {/* ── Back ── */}
        <button
          className={`${styles.backBtn} anim-fade-in`}
          onClick={() => router.push('/')}
          aria-label="Tillbaka till startsidan"
        >
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" strokeWidth="2" aria-hidden>
            <path d="M19 12H5M12 5l-7 7 7 7"/>
          </svg>
          Ny analys
        </button>

        {/* ── Okänd modell — vi saknar data för att ge ett tillförlitligt estimat ── */}
        {confidence.reasons.includes(UNKNOWN_MODEL_REASON) && (
          <UnknownModelBanner car={car} />
        )}

        {/* ── Car header ── */}
        <header className={`${styles.carHeader} card anim-fade-up`}>
          <div className={styles.carHeaderTop}>
          <div
            className={styles.carImageWrap}
            onClick={() => car.images?.length && setLightboxOpen(true)}
            style={car.images?.length ? { cursor: 'zoom-in' } : undefined}
          >
            {car.images?.[activeImg] ? (
              <img src={car.images[activeImg]} alt={`${car.brand} ${car.model}`}
                className={styles.carImage} />
            ) : (
              <div className={styles.carImagePlaceholder} aria-hidden>
                <svg width="36" height="36" viewBox="0 0 24 24" fill="none"
                  stroke="currentColor" strokeWidth="1">
                  <path d="M5 11l1.5-4.5h11L19 11"/>
                  <path d="M3 11h18v7H3z" rx="1"/>
                  <circle cx="7" cy="18" r="1.5"/>
                  <circle cx="17" cy="18" r="1.5"/>
                  <path d="M5 11h14"/>
                </svg>
              </div>
            )}
          </div>

          <div className={styles.carInfo}>
            <div className={styles.carSource}>
              <span className="tag tag-gray">
                <svg width="10" height="10" viewBox="0 0 24 24" fill="none"
                  stroke="currentColor" strokeWidth="2" aria-hidden>
                  <path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/>
                  <path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/>
                </svg>
                {car.source_site}
              </span>
              {car.location && (
                <span className="tag tag-gray">
                  <svg width="10" height="10" viewBox="0 0 24 24" fill="none"
                    stroke="currentColor" strokeWidth="2" aria-hidden>
                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/>
                    <circle cx="12" cy="10" r="3"/>
                  </svg>
                  {car.location}
                </span>
              )}
              {car.registration_number && (
                <span className="tag tag-gray">{car.registration_number}</span>
              )}
            </div>

            <h1 className={`${styles.carTitle} serif`}>
              {car.brand} {car.model}
              {car.variant && <span className={styles.carVariant}> {car.variant}</span>}
            </h1>

            <div className={styles.carSpecs}>
              {[
                { label: 'Årsmodell', value: car.year },
                { label: 'Mil',       value: mileageMil.toLocaleString('sv-SE') },
                { label: 'Drivmedel', value: car.fuel_type },
                { label: 'Växellåda', value: car.transmission },
                car.horsepower && { label: 'Effekt', value: `${car.horsepower} hk` },
              ].filter(Boolean).map((s: any) => (
                <div key={s.label} className={styles.specItem}>
                  <span className={styles.specLabel}>{s.label}</span>
                  <span className={styles.specValue}>{s.value}</span>
                </div>
              ))}
            </div>
          </div>

          <div className={styles.carPriceSide}>
            <span className={styles.priceLabel}>Begärt pris</span>
            <span className={styles.priceValue}>
              {car.price_sek.toLocaleString('sv-SE')} kr
            </span>
            <VerdictBadge verdict={verdict} />
          </div>
        </div>

        {car.images && car.images.length > 1 && (
          <div className={styles.thumbStrip} role="list" aria-label="Fler bilder">
            {car.images.slice(0, 6).map((src, i) => (
              <button
                key={i}
                type="button"
                className={`${styles.thumbBtn} ${i === activeImg ? styles.thumbActive : ''}`}
                onClick={() => setActiveImg(i)}
                aria-label={`Visa bild ${i + 1} av ${car.images!.length}`}
                aria-pressed={i === activeImg}
              >
                <img src={src} alt="" />
              </button>
            ))}
          </div>
        )}
        </header>

        {/* ── TL;DR: score + main driver + AI summary ── */}
        <div className={`${styles.heroCard} card anim-fade-up delay-1`}>
          <ScoreRing score={scores.deal} verdict={verdict} driverText={mainDriverText(scores)} />
        </div>
        <div className={`anim-fade-up delay-2`}>
          <AISummaryCard summary={ai_summary} verdict={verdict} />
        </div>

        {/* ── Detaljerad analys ── */}
        <div className={`${styles.detailDivider} anim-fade-up delay-3`}>
          <span className="section-label">Detaljerad analys</span>
        </div>

        <div className={`${styles.scoreRow} anim-fade-up delay-3`}>
          <SubScores scores={scores} />
          <ConfidenceCard confidence={confidence} />
        </div>

        {/* ── Price range ── */}
        <div className={`anim-fade-up delay-4`}>
          <PriceRangeCard car={car} pricing={pricing} />
        </div>

        {/* ── Ownership cost over time ── */}
        <div className={`anim-fade-up delay-5`}>
          <OwnershipCostCard car={car} />
        </div>

        {/* ── Pros / Cons — den som matchar omdömet visas först ── */}
        <div className={`${styles.prosConsRow} anim-fade-up delay-6`}>
          {verdict === 'Tveksam affär' ? (
            <>
              <ConsCard cons={cons} />
              <ProsCard pros={pros} />
            </>
          ) : (
            <>
              <ProsCard pros={pros} />
              <ConsCard cons={cons} />
            </>
          )}
        </div>

        {/* ── Risks ── */}
        {risks.length > 0 && (
          <div className={`anim-fade-up delay-7`}>
            <RisksCard risks={risks} />
          </div>
        )}

        {/* ── Actions ── */}
        <div className={`${styles.actions} anim-fade-up delay-8`}>
          <a href={car.source_url} target="_blank" rel="noopener noreferrer"
            className="btn btn-ghost">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" strokeWidth="2" aria-hidden>
              <path d="M18 13v6a2 2 0 01-2 2H5a2 2 0 01-2-2V8a2 2 0 012-2h6"/>
              <polyline points="15 3 21 3 21 9"/>
              <line x1="10" y1="14" x2="21" y2="3"/>
            </svg>
            Öppna annons
          </a>
          <button className="btn btn-ghost" onClick={handleShare}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" strokeWidth="2" aria-hidden>
              <path d="M4 12v7a2 2 0 002 2h12a2 2 0 002-2v-7"/>
              <polyline points="16 6 12 2 8 6"/>
              <line x1="12" y1="2" x2="12" y2="15"/>
            </svg>
            {linkCopied ? 'Länk kopierad!' : 'Dela analys'}
          </button>
          <button className="btn btn-ghost" onClick={() => router.push('/')}>
            Analysera annan bil
          </button>
        </div>

        {/* ── Disclaimer ── */}
        <Disclaimer meta={meta} confidence={confidence} />

      </div>

      {lightboxOpen && car.images && car.images.length > 0 && (
        <Lightbox
          images={car.images}
          index={activeImg}
          onIndexChange={setActiveImg}
          onClose={() => setLightboxOpen(false)}
        />
      )}
    </main>
  )
}

// Väger varje delbetygs "underskott" mot en godkänd nivå (70) med dess vikt
// i helhetsbetyget — de två som drar ner mest blir huvudorsaken. Samma
// vikter som WEIGHTS i lib/scoring/engine.ts.
function mainDriverText(scores: { price: number; reliability: number; ownership: number; mileage: number; resale: number }): string {
  const WEIGHTS: Record<string, number> = { price: 0.30, reliability: 0.25, ownership: 0.20, mileage: 0.15, resale: 0.10 }
  const LABELS:  Record<string, string> = { price: 'priset', reliability: 'tillförlitligheten', ownership: 'ägandekostnaden', mileage: 'mätarställningen', resale: 'andrahandsvärdet' }
  const BASELINE = 70

  const drivers = (Object.keys(WEIGHTS) as (keyof typeof WEIGHTS)[])
    .map(key => ({ key, deficit: Math.max(0, BASELINE - (scores as any)[key]) * WEIGHTS[key] }))
    .filter(d => d.deficit > 0)
    .sort((a, b) => b.deficit - a.deficit)
    .slice(0, 2)
    .map(d => LABELS[d.key])

  if (drivers.length === 0) return 'Alla delbetyg ligger på en bra nivå — ingen enskild faktor drar ner helheten.'
  const subject = drivers.length === 1 ? drivers[0] : `${drivers[0]} och ${drivers[1]}`
  return `${subject.charAt(0).toUpperCase()}${subject.slice(1)} drar ner betyget mest.`
}

function Lightbox({ images, index, onIndexChange, onClose }: {
  images: string[]; index: number; onIndexChange: (i: number) => void; onClose: () => void
}) {
  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (e.key === 'Escape')     onClose()
      if (e.key === 'ArrowRight') onIndexChange((index + 1) % images.length)
      if (e.key === 'ArrowLeft')  onIndexChange((index - 1 + images.length) % images.length)
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [index, images.length, onIndexChange, onClose])

  return (
    <div className={styles.lightbox} onClick={onClose} role="dialog" aria-modal="true" aria-label="Bildvisare">
      <button className={styles.lightboxClose} onClick={onClose} aria-label="Stäng bildvisare">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
          stroke="currentColor" strokeWidth="2" aria-hidden>
          <path d="M18 6L6 18M6 6l12 12"/>
        </svg>
      </button>

      {images.length > 1 && (
        <button
          className={`${styles.lightboxNav} ${styles.lightboxPrev}`}
          onClick={e => { e.stopPropagation(); onIndexChange((index - 1 + images.length) % images.length) }}
          aria-label="Föregående bild"
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" strokeWidth="2" aria-hidden><path d="M15 18l-6-6 6-6"/></svg>
        </button>
      )}

      <img
        src={images[index]}
        alt={`Bild ${index + 1} av ${images.length}`}
        className={styles.lightboxImg}
        onClick={e => e.stopPropagation()}
      />

      {images.length > 1 && (
        <button
          className={`${styles.lightboxNav} ${styles.lightboxNext}`}
          onClick={e => { e.stopPropagation(); onIndexChange((index + 1) % images.length) }}
          aria-label="Nästa bild"
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" strokeWidth="2" aria-hidden><path d="M9 18l6-6-6-6"/></svg>
        </button>
      )}

      {images.length > 1 && (
        <span className={styles.lightboxCounter}>{index + 1} / {images.length}</span>
      )}
    </div>
  )
}

/* ─── Sub-components ──────────────────────────────────────────────────────── */

function UnknownModelBanner({ car }: { car: any }) {
  const age = new Date().getFullYear() - car.year
  const isClassic = age >= 25

  return (
    <div className={`${styles.unknownModelBanner} anim-fade-in`} role="alert">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
        stroke="currentColor" strokeWidth="1.5" style={{ flexShrink: 0 }} aria-hidden>
        <path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
        <line x1="12" y1="9" x2="12" y2="13"/>
        <line x1="12" y1="17" x2="12.01" y2="17"/>
      </svg>
      <div>
        <strong>Vi saknar tillförlitlig data för {car.brand} {car.model}.</strong>{' '}
        {isClassic
          ? `Bilen är ${age} år och äldre/klassiska fordon följer inte samma pris- och värdeminsknings­mönster som andrahandsmarknaden vår analysmotor är byggd för — pris, ägandekostnad och riskbedömning nedan bör ses som mycket grova gissningar, inte ett estimat för den här specifika bilen.`
          : 'Modellen finns inte i vår referensdatabas, så pris, ägandekostnad och riskbedömning nedan bygger på generella schablonvärden — inte data för den här specifika bilen. AI-sammanfattningen väger in mer kontext från annonsen och kan vara mer träffsäker.'}
      </div>
    </div>
  )
}

function VerdictBadge({ verdict }: { verdict: string }) {
  const cls = verdict === 'Bra affär' ? 'tag-green'
            : verdict === 'Okej affär' ? 'tag-amber'
            : 'tag-red'
  return <span className={`tag ${cls} ${styles.verdictBadge}`}>{verdict}</span>
}

function ScoreRing({ score, verdict, driverText }: { score: number; verdict: string; driverText?: string }) {
  const r = 42
  const circ = 2 * Math.PI * r
  const offset = circ - (score / 100) * circ
  const color = verdict === 'Bra affär' ? 'var(--accent)'
              : verdict === 'Okej affär' ? 'var(--amber)'
              : 'var(--red)'

  return (
    <>
      <div className={styles.heroRingCol}>
        <span className="section-label">Deal score</span>
        <div className={styles.ringWrap}>
          <svg width="100" height="100" viewBox="0 0 100 100" role="img"
            aria-label={`Deal score: ${score} av 100`}>
            <circle cx="50" cy="50" r={r} fill="none"
              stroke="var(--surface-3)" strokeWidth="7"/>
            <circle cx="50" cy="50" r={r} fill="none"
              stroke={color} strokeWidth="7"
              strokeDasharray={circ}
              strokeDashoffset={offset}
              strokeLinecap="round"
              transform="rotate(-90 50 50)"
              style={{ transition: 'stroke-dashoffset 1.2s var(--ease-out)',
                       animation: 'ringDraw 1.2s var(--ease-out) both' }}
            />
          </svg>
          <div className={styles.ringCenter}>
            <span className={styles.ringScore} style={{ color }}>{score}</span>
            <span className={styles.ringMax}>/100</span>
          </div>
        </div>
      </div>
      <div className={styles.heroCardDivider} aria-hidden />
      <div className={styles.heroCardRight}>
        <VerdictBadge verdict={verdict} />
        {driverText && <p className={styles.ringDriverText}>{driverText}</p>}
      </div>
    </>
  )
}

function SubScores({ scores }: { scores: any }) {
  const items = [
    { label: 'Pris',           value: scores.price,        w: '30%' },
    { label: 'Tillförlitlighet', value: scores.reliability, w: '25%' },
    { label: 'Ägandekostnad',  value: scores.ownership,    w: '20%' },
    { label: 'Mätarställning', value: scores.mileage,      w: '15%' },
    { label: 'Andrahandsvärde', value: scores.resale,      w: '10%' },
  ]
  return (
    <div className={`${styles.subScoreCard} card`}>
      <span className="section-label">Delbetyg</span>
      <ul className={styles.subScoreList} role="list">
        {items.map(({ label, value, w }) => {
          const color = value >= 75 ? 'var(--accent)'
                      : value >= 55 ? 'var(--amber)'
                      : 'var(--red)'
          return (
            <li key={label} className={styles.subScoreItem}>
              <div className={styles.subScoreHeader}>
                <span className={styles.subScoreName}>
                  {label}
                  <span className={styles.subScoreWeight}>{w}</span>
                </span>
                <span className={styles.subScoreVal} style={{ color }}>{value}</span>
              </div>
              <div className={styles.barTrack} role="progressbar"
                aria-valuenow={value} aria-valuemin={0} aria-valuemax={100}>
                <div className={styles.barFill}
                  style={{ width: `${value}%`, background: color,
                           transformOrigin: 'left',
                           animation: 'barGrow 0.9s var(--ease-out) both' }} />
              </div>
            </li>
          )
        })}
      </ul>
    </div>
  )
}

function ConfidenceCard({ confidence }: { confidence: any }) {
  const color = confidence.tier === 'high'   ? 'var(--accent)'
              : confidence.tier === 'medium' ? 'var(--amber)'
              : 'var(--red)'
  const label = confidence.tier === 'high'   ? 'Hög konfidens'
              : confidence.tier === 'medium' ? 'Medel konfidens'
              : 'Låg konfidens'

  return (
    <div className={`${styles.confidenceCard} card`}>
      <span className="section-label">Konfidens</span>
      <div className={styles.confScore} style={{ color }}>
        {confidence.score}
        <span className={styles.confMax}>/100</span>
      </div>
      <span className={`tag ${confidence.tier === 'high' ? 'tag-green' : confidence.tier === 'medium' ? 'tag-amber' : 'tag-red'}`}
        style={{ marginBottom: '0.75rem' }}>
        {label}
      </span>
      {confidence.reasons.length > 0 && (
        <ul className={styles.confReasons} role="list">
          {confidence.reasons.map((r: string, i: number) => (
            <li key={i} className={styles.confReason}>
              <span className={styles.confBullet} aria-hidden>—</span>
              {r}
            </li>
          ))}
        </ul>
      )}
      {confidence.reasons.length === 0 && (
        <p className={styles.confGood}>
          Tillräckligt med data för en tillförlitlig bedömning.
        </p>
      )}
    </div>
  )
}

// Track-domänen breddas kring [low, high] (den smala "rimligt pris"-zonen)
// så att annonspriset får utrymme att röra sig proportionerligt — annars
// hamnar prickan nästan alltid i ena kanten eftersom low/high bara ligger
// ±7–16% ifrån varandra. Med padFactor=1.5 hamnar low/median/high alltid
// på exakt 37.5/50/62.5%, oavsett konfidensintervallets bredd.
const PRICE_TRACK_PAD_FACTOR = 1.5
const PRICE_TRACK_LOW_PCT    = 37.5
const PRICE_TRACK_MEDIAN_PCT = 50
const PRICE_TRACK_HIGH_PCT   = 62.5

function PriceRangeCard({ car, pricing }: { car: any; pricing: any }) {
  const { low, median, high, delta_pct, interpretation } = pricing
  const bandWidth  = Math.max(1, high - low)
  const domainLow  = low  - bandWidth * PRICE_TRACK_PAD_FACTOR
  const domainHigh = high + bandWidth * PRICE_TRACK_PAD_FACTOR
  const listingPct = Math.max(2, Math.min(98,
    ((car.price_sek - domainLow) / Math.max(1, domainHigh - domainLow)) * 100
  ))
  const isGood = delta_pct > 0.02

  return (
    <div className={`${styles.priceCard} card`}>
      <div className={styles.priceCardHeader}>
        <span className="section-label">Prisanalys</span>
        <span className={`tag ${isGood ? 'tag-green' : delta_pct < -0.02 ? 'tag-amber' : 'tag-gray'}`}>
          {interpretation}
        </span>
      </div>

      {/* Track */}
      <div className={styles.priceTrackWrap}>
        <div className={styles.priceTrack} aria-hidden>
          <div className={styles.priceZone}
            style={{ left: `${PRICE_TRACK_LOW_PCT}%`,
                     width: `${PRICE_TRACK_HIGH_PCT - PRICE_TRACK_LOW_PCT}%` }} />
          <div className={styles.priceFill}
            style={{ width: `${listingPct}%`,
                     background: isGood ? 'var(--accent-bg)' : 'var(--amber-bg)' }} />
          {/* Listing marker */}
          <div className={styles.priceMarker}
            style={{ left: `${listingPct}%`, background: 'var(--ink-1)' }}
            title={`Annonserat pris: ${car.price_sek.toLocaleString('sv-SE')} kr`} />
          {/* Median marker */}
          <div className={`${styles.priceMarker} ${styles.priceMarkerMedian}`}
            style={{ left: `${PRICE_TRACK_MEDIAN_PCT}%` }}
            title={`Marknadsmedian: ${median.toLocaleString('sv-SE')} kr`} />
        </div>
        <div className={styles.priceTrackLabels}>
          <span style={{ left: `${PRICE_TRACK_LOW_PCT}%` }}>Lägst</span>
          <span style={{ left: `${PRICE_TRACK_MEDIAN_PCT}%` }}>Median</span>
          <span style={{ left: `${PRICE_TRACK_HIGH_PCT}%` }}>Högst</span>
        </div>
      </div>

      {/* Numbers */}
      <div className={styles.priceGrid}>
        <PriceCell label="Annonserat" value={car.price_sek}
          highlight={isGood ? 'green' : 'amber'} />
        <PriceCell label="Estimerat intervall"
          value={`${(low/1000).toFixed(0)} 000 – ${(high/1000).toFixed(0)} 000`}
          suffix="kr" neutral />
        <PriceCell label="Marknadsmedian" value={median} dimmed />
      </div>
    </div>
  )
}

function PriceCell({ label, value, suffix = 'kr', highlight, neutral, dimmed }: any) {
  const color = highlight === 'green' ? 'var(--accent)'
              : highlight === 'amber' ? 'var(--amber)'
              : dimmed ? 'var(--ink-3)'
              : 'var(--ink-1)'
  return (
    <div className={styles.priceCell}>
      <span className={styles.priceCellLabel}>{label}</span>
      <span className={styles.priceCellValue} style={{ color }}>
        {typeof value === 'number' ? value.toLocaleString('sv-SE') : value}
        {' '}<span className={styles.priceCellSuffix}>{suffix}</span>
      </span>
    </div>
  )
}

function clampPct(n: number, min: number, max: number): number {
  if (Number.isNaN(n)) return min
  return Math.max(min, Math.min(max, n))
}

// Rundar upp till ett "snyggt" axelmax (1/2/5/10 × 10^n) så y-axelns
// etiketter blir jämna tal istället för t.ex. "83 400".
function niceAxisMax(value: number): number {
  if (value <= 0) return 1000
  const magnitude = Math.pow(10, Math.floor(Math.log10(value)))
  const residual = value / magnitude
  const niceResidual = residual <= 1 ? 1 : residual <= 2 ? 2 : residual <= 5 ? 5 : 10
  return niceResidual * magnitude
}

function formatAxisValue(n: number): string {
  return n === 0 ? '0' : `${Math.round(n / 1000).toLocaleString('sv-SE')}k`
}

function OwnershipCostCard({ car }: { car: any }) {
  const [financing, setFinancing] = useState<FinancingInput>(DEFAULT_FINANCING)
  const costs = useMemo(() => calculateOwnershipCosts(car, financing), [car, financing])
  const maxTotal = Math.max(...costs.map(c => c.total), 1)
  const axisMax = niceAxisMax(maxTotal)
  const axisTicks = [0, 0.25, 0.5, 0.75, 1].map(f => Math.round(axisMax * f))
  const totalFiveYears = costs.reduce((sum, c) => sum + c.total, 0)

  return (
    <div className={`${styles.ownershipCard} card`}>
      <div className={styles.ownershipHeader}>
        <span className="section-label">Ägandekostnad — kommande 5 åren</span>
        <span className={styles.ownershipTotal}>
          {Math.round(totalFiveYears).toLocaleString('sv-SE')} kr totalt
        </span>
      </div>

      <FinancingSelector financing={financing} onChange={setFinancing} />

      <div
        className={styles.ownershipChart}
        role="img"
        aria-label={`Stapeldiagram över uppskattad ägandekostnad per år de kommande 5 åren, uppdelat i värdeminskning, service, försäkring, skatt, bränsle${financing.type === 'loan' ? ' och finansiering' : ''}. Total uppskattad kostnad: ${Math.round(totalFiveYears).toLocaleString('sv-SE')} kronor.`}
      >
        <div className={styles.ownershipGridlines} aria-hidden>
          {axisTicks.map(t => (
            <div key={t} className={styles.gridline} style={{ bottom: `${(t / axisMax) * 100}%` }} />
          ))}
        </div>

        <div className={styles.ownershipAxisCol} aria-hidden>
          <div className={styles.ownershipAxisTicks}>
            {[...axisTicks].reverse().map(t => (
              <span key={t} className={styles.axisLabel}>{formatAxisValue(t)}</span>
            ))}
          </div>
          <div className={styles.ownershipAxisSpacer} />
        </div>

        {costs.map(row => (
          <div key={row.year} className={styles.ownershipBarCol}>
            <div className={styles.ownershipBarOuter}>
              <div className={styles.ownershipBarTrack} style={{ height: `${(row.total / axisMax) * 100}%` }}>
                {OWNERSHIP_COST_CATEGORIES.map(cat => {
                  const value = (row as any)[cat.key] as number
                  if (!value) return null
                  return (
                    <div
                      key={cat.key}
                      className={styles.ownershipSegment}
                      data-cat={cat.key}
                      style={{ height: `${(value / row.total) * 100}%` }}
                      title={`${cat.label}: ${Math.round(value).toLocaleString('sv-SE')} kr`}
                    />
                  )
                })}
              </div>
            </div>
            <span className={styles.ownershipBarTotal}>{Math.round(row.total / 1000).toLocaleString('sv-SE')}k</span>
            <span className={styles.ownershipBarLabel}>År {row.year}</span>
          </div>
        ))}
      </div>

      <div className={styles.ownershipLegend} role="list">
        {OWNERSHIP_COST_CATEGORIES
          .filter(cat => cat.key !== 'financing' || financing.type === 'loan')
          .map(cat => (
            <span key={cat.key} className={styles.legendItem} role="listitem">
              <span className={styles.legendDot} data-cat={cat.key} aria-hidden />
              {cat.label}
            </span>
          ))}
      </div>

      <p className={styles.ownershipDisclaimer}>
        Värdeminskning bygger på modellens historiska prisutveckling. Service, försäkring, skatt och
        bränsle är grova schablonvärden för genomsnittlig körning — inte en offert för just den här bilen.
      </p>
    </div>
  )
}

function FinancingSelector({ financing, onChange }: {
  financing: FinancingInput
  onChange: (f: FinancingInput) => void
}) {
  return (
    <div className={styles.financingRow}>
      <div className={styles.financingToggle} role="group" aria-label="Betalsätt">
        <button
          type="button"
          className={`${styles.financingToggleBtn} ${financing.type === 'cash' ? styles.financingToggleActive : ''}`}
          onClick={() => onChange({ ...financing, type: 'cash' })}
          aria-pressed={financing.type === 'cash'}
        >
          Kontant
        </button>
        <button
          type="button"
          className={`${styles.financingToggleBtn} ${financing.type === 'loan' ? styles.financingToggleActive : ''}`}
          onClick={() => onChange({ ...financing, type: 'loan' })}
          aria-pressed={financing.type === 'loan'}
        >
          Billån
        </button>
      </div>

      {financing.type === 'loan' && (
        <div className={styles.financingFields}>
          <label className={styles.financingField}>
            <span>Kontantinsats</span>
            <div className={styles.financingInputWrap}>
              <input
                type="number" min={0} max={100} step={5}
                value={financing.downPaymentPct}
                onChange={e => onChange({ ...financing, downPaymentPct: clampPct(Number(e.target.value), 0, 100) })}
              />
              <span>%</span>
            </div>
          </label>
          <label className={styles.financingField}>
            <span>Ränta</span>
            <div className={styles.financingInputWrap}>
              <input
                type="number" min={0} max={20} step={0.1}
                value={financing.interestRatePct}
                onChange={e => onChange({ ...financing, interestRatePct: clampPct(Number(e.target.value), 0, 20) })}
              />
              <span>%</span>
            </div>
          </label>
          <label className={styles.financingField}>
            <span>Löptid</span>
            <select
              value={financing.termYears}
              onChange={e => onChange({ ...financing, termYears: Number(e.target.value) })}
            >
              <option value={3}>3 år</option>
              <option value={5}>5 år</option>
              <option value={7}>7 år</option>
              <option value={10}>10 år</option>
            </select>
          </label>
        </div>
      )}
    </div>
  )
}

function ProsCard({ pros }: { pros: string[] }) {
  return (
    <div className={`${styles.pcCard} card`} data-type="pros">
      <div className={styles.pcHeader}>
        <span className={styles.pcDot} data-type="pros" aria-hidden />
        <span className="section-label" style={{ color: 'var(--accent)' }}>Fördelar</span>
      </div>
      <ul className={styles.pcList} role="list">
        {pros.map((p, i) => (
          <li key={i} className={styles.pcItem}>
            <span className={styles.pcBullet} data-type="pros" aria-hidden />
            {p}
          </li>
        ))}
      </ul>
    </div>
  )
}

function ConsCard({ cons }: { cons: string[] }) {
  return (
    <div className={`${styles.pcCard} card`} data-type="cons">
      <div className={styles.pcHeader}>
        <span className={styles.pcDot} data-type="cons" aria-hidden />
        <span className="section-label" style={{ color: 'var(--amber)' }}>Nackdelar</span>
      </div>
      <ul className={styles.pcList} role="list">
        {cons.map((c, i) => (
          <li key={i} className={styles.pcItem}>
            <span className={styles.pcBullet} data-type="cons" aria-hidden />
            {c}
          </li>
        ))}
      </ul>
    </div>
  )
}

function RisksCard({ risks }: { risks: any[] }) {
  const levelConfig = {
    high:   { label: 'Hög',  cls: 'tag-red',   dot: 'var(--red)' },
    medium: { label: 'Medel', cls: 'tag-amber', dot: 'var(--amber)' },
    low:    { label: 'Låg',  cls: 'tag-green',  dot: 'var(--accent-light)' },
  } as const

  return (
    <div className={`${styles.risksCard} card`}>
      <span className="section-label">Riskanalys</span>
      <ul className={styles.riskList} role="list">
        {risks.map((r, i) => {
          const cfg = levelConfig[r.level as keyof typeof levelConfig]
          return (
            <li key={i} className={styles.riskItem}>
              <span className={`tag ${cfg.cls}`} style={{ flexShrink: 0, marginTop: '1px' }}>
                {cfg.label}
              </span>
              <div className={styles.riskText}>
                <strong>{r.title}</strong>
                <span> {r.description}</span>
              </div>
            </li>
          )
        })}
      </ul>
    </div>
  )
}

function AISummaryCard({ summary, verdict }: { summary: string; verdict: string }) {
  return (
    <div className={styles.aiCard}>
      <div className={styles.aiCardInner}>
        <div className={styles.aiBadge}>
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" strokeWidth="2" aria-hidden>
            <path d="M12 2L2 7l10 5 10-5-10-5z"/>
            <path d="M2 17l10 5 10-5"/>
            <path d="M2 12l10 5 10-5"/>
          </svg>
          AI-sammanfattning
        </div>
        <blockquote className={styles.aiText}>{summary}</blockquote>
        <div className={styles.aiVerdict}>
          <span className={styles.aiVerdictLabel}>Vår bedömning:</span>
          <VerdictBadge verdict={verdict} />
        </div>
      </div>
    </div>
  )
}

function Disclaimer({ meta, confidence }: { meta: any; confidence: any }) {
  return (
    <footer className={styles.disclaimer}>
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
        stroke="currentColor" strokeWidth="1.5" style={{ flexShrink: 0, marginTop: '1px' }}
        aria-hidden>
        <circle cx="12" cy="12" r="10"/>
        <line x1="12" y1="8" x2="12" y2="12"/>
        <line x1="12" y1="16" x2="12.01" y2="16"/>
      </svg>
      <div>
        <strong>Obs:</strong> Prisestimat är baserade på tillgänglig marknadsdata
        (konfidens {confidence.score}/100) och skall inte tolkas som exakta värderingar.
        Genomför alltid en oberoende besiktning och granska servicehandlingar före köp.
        Analysmotor v{meta.scoring_version} · {new Date(meta.analyzed_at).toLocaleDateString('sv-SE')}.
      </div>
    </footer>
  )
}
