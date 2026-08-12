/**
 * AI analysis layer — v1.2
 *
 * Ändringar från v1.1:
 * - Tar emot en ägandekostnads-uppdelning (bränsle/service/försäkring/skatt/
 *   värdeminskning, år 1) så sammanfattningen kan peka ut VILKEN kategori
 *   som faktiskt drar iväg (eller är ovanligt låg) istället för att bara
 *   se en enda sammanslagen "Ägandekostnad: X/100"-siffra.
 */

import Anthropic from '@anthropic-ai/sdk'
import { CarListing, ConfidenceResult, DealScores, PriceRange, Risk, Verdict } from '../../types'
import type { YearlyOwnershipCost } from '../scoring/ownershipCost'

const client = new Anthropic()

export interface AIAnalysisResult {
  summary: string
  verdict: Verdict
}

export async function analyzeWithAI(
  car: CarListing,
  scores: DealScores,
  confidence: ConfidenceResult,
  pricing: PriceRange,
  risks: Risk[],
  modelNotes?: string,
  ownershipYear1?: YearlyOwnershipCost,
): Promise<AIAnalysisResult> {
  const message = await client.messages.create({
    // 'claude-sonnet-4-6' (tidigare värde här) matchar inget giltigt
    // Claude-modell-ID — varje anrop till Anthropic-API:t misslyckades
    // troligen tyst, vilket fick process.ts:s catch-block att falla
    // tillbaka på den fasta fallbackSummary()-mallen istället för en
    // riktig AI-sammanfattning. Upptäckt genom att användaren märkte att
    // samma fraser (t.ex. den fasta sista meningen i fallback-mallen)
    // återkom nästan hela tiden.
    model:      'claude-sonnet-5',
    // Höjd från 700 — en verklig (inte tyst felande) AI-analys kunde
    // klippas av mitt i JSON-strängen om svaret råkade bli lite längre
    // än så, vilket gav trasig JSON som (se buggen nedan i parseResponse)
    // visades rakt av för användaren istället för att hanteras som ett fel.
    max_tokens: 1024,
    system:     SYSTEM_PROMPT,
    messages:   [{ role: 'user', content: buildPrompt(car, scores, confidence, pricing, risks, modelNotes, ownershipYear1) }],
  })

  const text = message.content
    .filter(b => b.type === 'text')
    .map(b => (b as any).text as string)
    .join('')

  return parseResponse(text, scores.deal)
}

// ─── System prompt ────────────────────────────────────────────────────────────

const SYSTEM_PROMPT = `
Du är en erfaren, pålitlig och ärlig bilrådgivare på den svenska marknaden.
Du hjälper konsumenter att fatta välgrundade köpbeslut.

ABSOLUTA REGLER:
1. Du förklarar BARA de siffror och fakta du fått i prompten. Du hittar inte på priser, statistik eller fakta.
2. Du skriver på svenska, i ett naturligt, professionellt men vänligt tonfall.
3. Du är ärlig om osäkerheter — om konfidensen är låg säger du det tydligt.
4. Du avslutar ALLTID med en konkret, handlingbar rekommendation.
5. Du nämner ALDRIG att du är en AI eller att detta är autogenererat.
6. Du skriver ALDRIG exakta siffror som ett exakt värde — alltid intervall eller "ungefär".
7. Max 3 korta stycken. Inga rubriker. Ingen punktlista. Ren löpande text.
8. Upprepa INTE risker som redan listas separat — de visas för användaren på annat ställe.
9. Svara EXAKT i formatet nedan — ingenting före "VERDICT:", ingenting efter sista stycket.

FORMAT (bokstavligt, inte JSON):
VERDICT: Bra affär|Okej affär|Tveksam affär
SUMMARY:
Första stycket...

Andra stycket...

Tredje stycket med rekommendationen...
`.trim()

// ─── Prompt builder ───────────────────────────────────────────────────────────

function buildPrompt(
  car: CarListing,
  scores: DealScores,
  confidence: ConfidenceResult,
  pricing: PriceRange,
  risks: Risk[],
  modelNotes?: string,
  ownershipYear1?: YearlyOwnershipCost,
): string {
  const age        = new Date().getFullYear() - car.year
  const mil        = Math.round(car.mileage_km / 10)
  const avgMilAge  = age * 1500
  // En förbeställd "nästa års modell" (Blockets "Ny bil till salu") kan visa
  // ett årsmodell EFTER innevarande år, vilket gör (currentYear - årsmodell)
  // noll eller negativt — "genomsnittlig mätarställning för årsmodellen"
  // blir då meningslös eller rentav negativ. Mätarställning nära noll är ett
  // entydigt "det här är i praktiken en ny bil"-tecken oavsett årsmodell.
  const isNewCar   = mil <= 50
  const milSignal  = isNewCar
    ? `I PRAKTIKEN NY/OANVÄND (${mil.toLocaleString('sv-SE')} mil) — ingen jämförelse mot genomsnittlig mätarställning är relevant`
    : mil < avgMilAge * 0.85
    ? `LÄGRE än genomsnittet för årsmodellen (${mil.toLocaleString('sv-SE')} mil vs typiska ${avgMilAge.toLocaleString('sv-SE')} mil)`
    : mil > avgMilAge * 1.20
    ? `HÖGRE än genomsnittet för årsmodellen (${mil.toLocaleString('sv-SE')} mil vs typiska ${avgMilAge.toLocaleString('sv-SE')} mil)`
    : `I LINJE med genomsnittet (${mil.toLocaleString('sv-SE')} mil)`

  // Ge alltid den faktiska procentsatsen, även när den är liten — annars
  // saknar modellen ett konkret tal att utgå från i "i linje"-fallet, och
  // kan (trots instruktionen att bara förklara givna siffror) hitta på en
  // egen uppskattning istället för att spegla den verkliga, obetydliga skillnaden.
  const deltaPctAbs = Math.abs(pricing.delta_pct * 100).toFixed(1)
  // "Marknadsmedian" är bara sant när medianSource faktiskt är 'market' —
  // annars (Skatteverkets nybilspris, eller den teoretiska basePrice ×
  // (1-depreciation)^ålder-formeln när ingen marknadsdata alls fanns) ska
  // modellen inte prata om en "marknadsmedian" som om jämförbara
  // annonser låg bakom siffran, annars säger den något som INTE stöds av
  // fakta i prompten (bryter mot ABSOLUTA REGEL 1).
  const priceRefLabel = pricing.medianSource === 'new_car_list' ? 'nybilspriset'
    : pricing.medianSource === 'theoretical' ? 'det teoretiskt uppskattade priset (INGEN riktig marknadsdata fanns — nämn det)'
    : 'marknadsmedianen'
  const priceSignal = pricing.delta_pct > 0.03
    ? `${deltaPctAbs}% UNDER ${priceRefLabel} — gynnsamt för köparen`
    : pricing.delta_pct < -0.03
    ? `${deltaPctAbs}% ÖVER ${priceRefLabel}`
    : `Ungefär i linje med ${priceRefLabel} (${deltaPctAbs}% ${pricing.delta_pct >= 0 ? 'under' : 'över'})`

  const highRisks = risks.filter(r => r.level === 'high')
  const medRisks  = risks.filter(r => r.level === 'medium')

  return `
FORDON (beräknat av regelmotor — dessa är fakta, inte uppskattningar):
- ${car.brand} ${car.model}${car.variant ? ' ' + car.variant : ''}, ${car.year}
- Pris: ${car.price_sek.toLocaleString('sv-SE')} kr
- Mätarställning: ${milSignal}
- Drivmedel: ${car.fuel_type} | Växellåda: ${car.transmission}
- Säljare: ${car.seller_type === 'dealer' ? 'Återförsäljare' : 'Privatperson'}
- Ort: ${car.location ?? 'Ej angiven'}

SCORES (0–100):
- Deal-score: ${scores.deal} | Pris: ${scores.price} | Tillförlitlighet: ${scores.reliability}
- Ägandekostnad: ${scores.ownership} | Mätarställning: ${scores.mileage} | Andrahandsvärde: ${scores.resale}

PRISANALYS:
- Annonserat: ${car.price_sek.toLocaleString('sv-SE')} kr
- Estimerat intervall: ${(pricing.low/1000).toFixed(0)} 000–${(pricing.high/1000).toFixed(0)} 000 kr (median ${(pricing.median/1000).toFixed(0)} 000 kr)
- Prisjämförelse: ${priceSignal}

${ownershipYear1 ? `ÄGANDEKOSTNAD ÅR 1 (uppskattat, beräknat av regelmotorn utifrån märke/drivmedel/ålder — inte en offert):
- Värdeminskning: ~${Math.round(ownershipYear1.depreciation).toLocaleString('sv-SE')} kr
- Service: ~${ownershipYear1.service.toLocaleString('sv-SE')} kr
- Försäkring: ~${ownershipYear1.insurance.toLocaleString('sv-SE')} kr
- Skatt: ~${ownershipYear1.tax.toLocaleString('sv-SE')} kr
- Bränsle: ~${ownershipYear1.fuel.toLocaleString('sv-SE')} kr
- Totalt: ~${Math.round(ownershipYear1.total).toLocaleString('sv-SE')} kr/år
Om någon av dessa kategorier sticker ut som ovanligt hög eller låg för bilens
märke/drivmedel/ålder (t.ex. hög försäkring pga premiummärke eller hög
effekt, hög skatt pga diesel, låg skatt/service pga elbil) — nämn det
konkret. Annars behöver du inte kommentera varje kategori för sig.
` : ''}KONFIDENS: ${confidence.score}/100 (${confidence.tier})
${confidence.reasons.length > 0 ? '- Begränsningar: ' + confidence.reasons.join('; ') : '- Inga väsentliga begränsningar'}

IDENTIFIERADE RISKER (${risks.length} st, visas separat för användaren — UPPREPA INTE dessa):
${risks.map(r => `- [${r.level.toUpperCase()}] ${r.title}`).join('\n')}
${highRisks.length > 0 ? `\nOBS: ${highRisks.length} HÖG risk identifierad — nämn detta i sammanfattningen.` : ''}
${medRisks.length > 0  ? `OBS: ${medRisks.length} MEDEL risk identifierad — nämn om relevant.` : ''}

${modelNotes ? `MODELL­SPECIFIK INFORMATION (från vår databas):\n${modelNotes}\n` : ''}
${car.description ? `ANNONSTEXT (utdrag):\n${car.description.slice(0, 400)}` : ''}
${isNewCar ? `\nOBS — DETTA ÄR EN NY BIL (${mil} mil): Säg INTE att mätarställningen är "som förväntat för årsmodellen" eller liknande — det är en ny bil, inte en begagnad. Nämn istället att en ny bil ofta har en brantare värdeminskning det första året jämfört med en redan begagnad bil av samma modell.\n` : ''}

Skriv nu en ärlig, balanserad analys på 2–3 korta stycken.
- Stycke 1: Priset och mätarställningen i kontext.
- Stycke 2: Det viktigaste att tänka på — inkludera eventuella utstickande
  ägandekostnads-kategorier (se ovan) om relevant, utan att upprepa
  riskerna ordagrant.
- Stycke 3: Konkret rekommendation med ett tydligt om/om inte.
`.trim()
}

// ─── Response parser ──────────────────────────────────────────────────────────

function parseResponse(text: string, dealScore: number): AIAnalysisResult {
  const VALID_VERDICTS: Verdict[] = ['Bra affär', 'Okej affär', 'Tveksam affär']

  const fallbackVerdict: Verdict =
    dealScore >= 72 ? 'Bra affär' :
    dealScore >= 55 ? 'Okej affär' : 'Tveksam affär'

  // Bytte från JSON-format till "VERDICT: ...\nSUMMARY: ..." efter att ha
  // sett riktiga svar krascha JSON.parse() — modellen skrev naturliga
  // stycken med RÅA radbyten inuti "summary"-strängen (helt normalt sätt
  // att skriva flerstycken-text), men råa kontrolltecken är ogiltiga
  // inuti en JSON-sträng enligt specen ("Bad control character in string
  // literal"). Att sanera bort/escapa kontrolltecken i efterhand är
  // riskabelt (kan lika gärna förstöra strukturell whitespace mellan
  // JSON-token om modellen prettyprintat), så enklare och robustare att
  // helt undvika att paketera fri text i strikt JSON. Om parsningen ändå
  // misslyckas ska det INTE tyst returnera den råa texten som om den vore
  // ett giltigt sammandrag (det gjorde en tidigare version, vilket lät
  // trasig text visas rakt av för användaren) — kastar istället, så
  // process.ts:s befintliga try/catch faller tillbaka på
  // fallbackSummary()-mallen och loggar felet.
  const verdictMatch = text.match(/VERDICT:\s*(.+)/i)
  const summaryMatch = text.match(/SUMMARY:\s*([\s\S]*)/i)

  const rawVerdict = verdictMatch?.[1]?.trim()
  const verdict: Verdict = VALID_VERDICTS.includes(rawVerdict as Verdict)
    ? (rawVerdict as Verdict)
    : fallbackVerdict

  const summary = summaryMatch?.[1]?.trim()
  if (!summary) {
    throw new Error('AI-svaret saknade ett SUMMARY-avsnitt')
  }

  return { verdict, summary }
}
