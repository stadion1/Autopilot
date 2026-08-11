# Carzi — kontext för nästa session

Svensk bilannons-analystjänst. Klistra in en Blocket/Wayke/Bytbil-länk, få
en poängsatt analys: prisläge mot marknad, mätarställning, ägandekostnad
och en AI-sammanfattning. Byggd och underhållen iterativt tillsammans med
Claude Code — den här filen är ett färskt state-dump, inte en permanent
spec.

## Arkitektur

Två separata deployments som delar en Supabase/Postgres-databas:

**Huvudapp (Vercel, Next.js)** — `app/` (App Router, sidorna) +
`pages/api/` (Pages Router, API-routes; de lever kvar sida vid sida av
historiska skäl, ingen anledning att migrera).

- `app/page.tsx` — startsida, URL-input
- `app/analysis/[id]/page.tsx` — analysresultat: hero-poäng, prisanalys,
  mätarställning, ägandekostnad (stapeldiagram, Kontant/Billån-toggle),
  AI-sammanfattning, pros/cons, "bättre alternativ"-kort, bildlightbox
- `pages/api/analyze.ts` — skapar en pending-rad snabbt, triggar
  `/api/process` fire-and-forget (så navigeringen till analyssidan händer
  direkt och den riktiga ~15s väntan visas i det fyra-stegs
  laddningsflödet istället för att gömmas bakom knappen)
- `pages/api/process.ts` — själva jobbet: scrapa, poängsätt, spara
- `pages/api/cron/score-listings.ts` — daglig Vercel Cron (03:00 UTC):
  kör scoring-motorn på ALLA rader i `market_listings` (inte bara
  användaranalyserade), skriver `deal_score` — matar "bättre
  alternativ"-kortet
- `pages/api/cron/sync-new-car-prices.ts` — veckovis Vercel Cron (mån
  05:00 UTC): synkar Skatteverkets nybilspris-API mot `new_car_prices`
- `lib/scoring/engine.ts` — poängmotorn: pris, mätarställning, ålder,
  utrustning m.m. → deal score + pros/cons + confidence. Har
  `isEssentiallyNewCar()` (mätarställning ≤500km, INTE årsmodell — en
  förhandsbokad bil kan visa nästa års modellår) och `getNewCarPrice()`
  som slår upp Skatteverkets listpris för nästan-nya bilar istället för en
  platt `basePrice`
- `lib/scoring/ownershipCost.ts` — beräknar ägandekostnad
  (värdeminskning, service, försäkring, skatt, drivmedel, finansiering)
- `lib/ai/analyzer.ts` — AI-sammanfattningen (prompt inkluderar
  nybils-specialfall)
- `lib/supabase/client.ts` — all DB-åtkomst från huvudappen, bl.a.
  `saveMarketListing()` (skriver till `market_listings` från
  liveanalys-flödet) och `getMarketMedian()`
- `data/referenceData.ts` — statisk referensdata per modell (riktiga
  poster klustrar 2008–2022), `data/schema.sql` — databasschema

**scraper-service (Railway, fristående Express-server + separat cron)**
— kan INTE importera från huvudappens `lib/`/`data/` (Docker-bygget
kopierar bara `scraper-service/*.ts`), så delad logik/konstanter dupliceras
medvetet mellan de två kodbaserna. Håll dem i synk manuellt vid ändringar.

- `server.ts` — persistent webbtjänst. Routes: `POST /scrape` (en
  annons-URL → normaliserad bildata, används av huvudappens
  analysflöde), `GET /health`, `GET /supported`, plus
  engångs-admin-endpoints (se nedan)
- `nightly.ts` — separat cron-process (Railway Cron, `0 2 * * *`),
  skrapar Blockets sökresultat sidvis för spårade modeller, skriver till
  `market_listings`, kör sold-verifiering på gamla kandidater
- `blocket.ts` / `wayke.ts` / `bytbil.ts` — parsers per sajt.
  `blocket.ts` använder blocket-api.se (tredjeparts-wrapper) istället för
  Playwright — snabbt men har visat sig opålitligt för "är annonsen
  borta"-frågor (se Kända begränsningar)
- `soldVerification.ts` — delad `verifyBlocketAdGone()` (kollar riktiga
  blocket.se-sidans HTML efter "inte längre tillgänglig" /
  "sålts eller tagits bort" — INTE blocket-api.se, se nedan varför) och
  `daysListedSince()`

**Databastabeller** (Supabase/Postgres): `analyses`, `market_listings`
(+ `deal_score`, `deal_score_updated_at`), `model_references`,
`known_issues`, `analysis_feedback`, `new_car_prices`.

## Vad som är byggt (kronologiskt, senaste sessionerna)

- Ägandekostnad-kort med stapeldiagram + Kontant/Billån-toggle
- Tvåfas-analysflöde (snabb pending-rad + bakgrundsjobb) så laddningen
  känns responsiv istället för att gömmas bakom en hängande knapp
- Skatteverkets nybilsprisdata integrerad för nästan-nya bilar
  (≤500km) — trim-nivå-listpriser istället för en platt modellpris
- "Bättre alternativ"-kort: daglig scoring av HELA `market_listings`,
  visar jämförbara annonser med minst +8 poäng bättre deal score
- Ny logga (SVG, integrerad från användarens design, med runtime
  `getBBox()`-mätning för att fixa font-metrik-mismatch mellan
  designverktyg och riktig webbläsarrendering)
- Nybils-specialfall i både regelbaserad pros/cons och AI-prompten —
  säger "en ny bil är trevlig men första året tappar den mer i värde"
  istället för att nonsensiskt kommentera mätarställning på en 0-milare
- **Sold-verification-saga** (stor, flera steg): nightly-scrapern
  markerade för många annonser som sålda pga en "inte återsedd i
  samplet"-heuristik som inte höll mot ett ~143 000-annonsers,
  icke-stabilt sökresultat. Byggde riktig verifiering mot annonsens
  status, körde backfill, upptäckte att verifieringsmetoden själv var
  BAKVÄND (blocket-api.se returnerar 200 OK med full data även för
  bekräftat borttagna annonser), fixade till att kolla riktiga
  blocket.se-sidans HTML istället, och körde en rättningsomgång
  (`/reverify-active-listings`) som fann och åtgärdade 732 felaktigt
  återaktiverade annonser
- **Leasing/orimligt-pris-städning**: filtrerar bort ren leasing
  (`sales_form=5` / `Försäljningsform=Leasing`) vid insamling i båda
  kodbaserna. Höjde årsmodell-golvet 1980→2010 (referensdata täcker
  inte äldre generationer) och lade till en rimlighetsheuristik för
  extremt låga priser (avvisa pris <20 000kr om bilen samtidigt är
  <10 år OCH <150 000km — fångar leasingövertag som inte går att
  skilja från vanlig försäljning via något API-fält). Byggde
  `/cleanup-implausible-listings` för att städa redan inlagda rader
  mot samma regler, inklusive ett extra mätarställnings-tak
  (>1 000 000km, fångar uppenbara inmatningsfel i annonstexten)

### Engångs-admin-endpoints på scraper-service (Railway)

Kräver header `x-scraper-secret`. Inte schemalagda — körs manuellt vid
behov:
- `POST /backfill-sold-verification` — rättar gamla `sold_at`-felmärkningar
- `POST /reverify-active-listings` — motsatsen, rättar bakvänd
  sold-verifiering (redan körd, 732 rader rättade)
- `POST /cleanup-leasing-listings` — tar bort ren leasing som redan
  hamnat i `market_listings`
- `POST /cleanup-implausible-listings` — tar bort pre-2010/orimligt
  pris/orimlig mätarställning-rader (redan körd, 546 rader borttagna,
  0 kvar vid senaste körning)

## Kända begränsningar / öppna trådar

- **blocket-api.se är inte fullt pålitlig.** Två separata fall
  verifierade denna session: (1) speglar/cachar annonsdata och
  reflekterar INTE borttagning i realtid — därför bytte
  sold-verifieringen till att kolla riktiga blocket.se-sidan istället;
  (2) ad-detalj-endpointens `Miltal`-fält kan avvika från vad som
  faktiskt lagrades via sök-endpointen för samma annons (en Mercedes
  visade "256 387 mil" via ad-detalj men 23 900 mil i databasen — troligen
  ett fel/glapp i den tredjepartsdata, inte i vår kod). Lärdom: verifiera
  alltid mot databasens faktiska lagrade värden innan en hypotes om
  "orimlig data" antas stämma.
- **Ingen backfill/cleanup finns ännu för Wayke/Bytbil-källor** —
  årsmodell-golvet och prisheuristiken gäller `saveMarketListing()`
  generellt (alla källor), men `/cleanup-implausible-listings` har bara
  körts mot data som redan fanns; om Wayke/Bytbil har liknande gamla
  skräprader har de städats i samma körning (ingen `source_site`-filtrering
  i cleanup-queryn), men det är inte specifikt verifierat.
- **`get_market_median()` är inte robust mot outliers** — ingen trimmad
  percentil eller MAD-baserad beräkning. Föreslaget men inte byggt,
  användaren har inte bekräftat att de vill ha det.
- **Ingen orimligt-pris-varning på enskilda analyser** — om en
  användare klistrar in en annons med implausibelt pris (t.ex. en
  leasingövertag som klarar sig förbi `saveMarketListing()`s
  filter eftersom den ligger precis under gränserna) syns ingen
  varning i analysresultatet. Föreslaget men inte byggt.
- **Liggtider / "förväntad tid till sålt"** — avvaktar tills
  `market_listings` har ackumulerat tillräckligt med
  sold/removed-historik. En påminnelse är schemalagd (cloud routine,
  ~en vecka efter att den sattes upp) för att kolla om datan räcker nu.
- **Ingen Node.js lokalt tillgängligt** i den här miljön — alla
  scraper-service/TypeScript-ändringar denna session har verifierats
  via läsning + manuell brace-balansräkning, inte kompilering/körning.
  Bra att köra en riktig typecheck/build vid nästa tillfälle det går.

## Prioriterade nästa steg (föreslagna, ej bekräftade av användaren)

1. Kör en ny SQL-koll på min/max-priser per modell för att bekräfta att
   städningen höll (gjordes en gång, resultatet var rent — värt att
   återupprepa efter nästa nightly-körning för att se att inget nytt
   läcker in).
2. Ta ställning till `get_market_median()`-robusthet (trimmad
   percentil/MAD) — relevant nu när ingestion är strängare men
   fortfarande inte immun mot enstaka extremvärden.
3. Ta ställning till orimligt-pris-varning per analys, som ett
   användarvänt komplement till den tysta ingestion-filtreringen.
4. Följ upp liggtids-påminnelsen när den triggas — avgör om datan
   räcker för att bygga "förväntad tid till sålt".
