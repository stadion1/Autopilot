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
  05:00 UTC): synkar Skatteverkets nybilspris-API (innevarande +
  föregående år) mot `new_car_prices`
- `pages/api/admin/backfill-new-car-prices.ts` — engångsverktyg (ej
  schemalagt): synkar EN historisk årgång Skatteverket-data per anrop
- `pages/api/admin/recompute-depreciation-curves.ts` — engångsverktyg (ej
  schemalagt): räknar fram EN `referenceData.ts`-post i `depreciation_curves`
  per anrop, se "Pågående arbete" nedan
- `lib/skatteverket.ts` — delad Skatteverket-synklogik (`syncSkatteverketYear()`)
  mellan cronen och backfillen
- `lib/scoring/engine.ts` — poängmotorn: pris, mätarställning, ålder,
  utrustning m.m. → deal score + pros/cons + confidence. Har
  `isEssentiallyNewCar()` (mätarställning ≤500km, INTE årsmodell — en
  förhandsbokad bil kan visa nästa års modellår) och `getNewCarPrice()`
  som slår upp Skatteverkets listpris för nästan-nya bilar istället för en
  platt `basePrice`
- `lib/scoring/ownershipCost.ts` — beräknar ägandekostnad
  (värdeminskning, service, försäkring, skatt, drivmedel, finansiering).
  Värdeminskningen använder numera en empirisk kurva
  (`depreciation_curves`) när data finns, annars den gamla platta
  procentsatsen — se "Pågående arbete" nedan
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
`known_issues`, `analysis_feedback`, `new_car_prices`, `depreciation_curves`.

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
- **Två fynd vid manuell granskning av en nybils-analys** (Volvo XC60,
  blocket.se/mobility/item/24166983), fixade 2026-08-12: (1) "Kort
  annons — begränsad information" i `calculateConfidence()` slog till
  ovillkorligen på VARJE Blocket-analys — verifierat mot 4 olika annonser
  att blocket-api.se aldrig returnerar ett `description`-fält
  överhuvudtaget, oavsett annonsens faktiska längd. Kollen är nu scopad
  till `source_site === 'bytbil'`, den enda parsern som faktiskt skrapar
  riktig annonstext. (2) Priskortet visade alltid "Marknadsmedian" även
  för i praktiken nya bilar, där referenspriset egentligen är
  Skatteverkets nybilslistpris för den trimmen (`isEssentiallyNewCar()`)
  — en handlare som prissätter en fabriksbeställd bil till listpris är
  helt normalt, men etiketten fick det att se ut som en osannolik
  slump. `usedNewCarPrice`-flaggan fanns redan i `scoreVehicle()` men
  nådde bara en `console.log`; lade till `PriceRange.medianSource`
  (`'market' | 'new_car_list'`) så UI:t (priskort + pros/cons-texter)
  kan visa "Nybilspris (Skatteverket)" istället när det stämmer.

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

## Pågående arbete: empirisk värdeminskningskurva

Ersätter den gamla platta, manuellt gissade årliga värdeminsknings-
procenten per modell (`referenceData.ts`) — som applicerades exponentiellt
oavsett bilens ålder och alltså inte fångade den kända branta
år 1-nedgången — med en riktig, uppmätt kurva per modell/generation.

1. **Steg 1 (klart):** engångs-backfill av Skatteverkets historiska
   nybilspriser 2010–2026 in i `new_car_prices`
   (`pages/api/admin/backfill-new-car-prices.ts?year=YYYY`, ett år per
   anrop). Kört och verifierat — ~70 000 rader jämnt spridda över hela
   intervallet.
2. **Steg 2 (klart):** `depreciation_curves`-tabellen (migration körd i
   Supabase) + `pages/api/admin/recompute-depreciation-curves.ts?index=N`
   (räknar fram EN `referenceData.ts`-post per anrop: medianpris per
   åldersår i `market_listings`, delat med Skatteverkets nybilspris för
   SAMMA tillverkningsår — inte dagens nypris). Kräver minst 5 annonser
   per åldersgrupp för att räknas som en råpunkt. `calculateOwnershipCosts()`
   i `lib/scoring/ownershipCost.ts` använder kurvan när den finns
   (härleder årlig rate från två intilliggande lagrade punkter, klampad
   till -5%…40% som sista skyddsnät), annars faller den tillbaka på den
   gamla platta procentsatsen. **Beräkningen (57 index) kördes
   2026-08-12.**

   **Bugg upptäckt via en riktig analys (2026-08-12):** en Volvo XC60
   visade nästan ingen värdeminskning år 1, en spik på 89 000 kr år 2,
   sen nästan ingen igen år 4–5. Orsak: den ursprungliga versionen
   lagrade råa medianer per åldersår och lät `ownershipCost.ts` derivera
   varje års rate från bara TVÅ INTILLIGGANDE punkter — med 20–30
   annonser (olika trim/utrustning) per åldersgrupp studsar medianen
   tillräckligt mellan grannår att derivatan blir brusig, verifierat
   genom att räkna igenom XC60:ns faktiska siffror för hand och
   återskapa exakt samma 13k/89k/80k/37k/25k som i skärmdumpen. **Fixat:**
   glättning sker nu VID LAGRING istället för vid läsning — ålder 0→1
   (den kända branta nedgången) mäts direkt, ålder ≥1 får EN gemensam
   glättad rate från en viktad log-linjär regression över alla
   tillgängliga punkter, klampad 2%–35%/år. `ownershipCost.ts` behövde
   ingen ändring — den lagrade sekvensen ÄR redan den glättade kurvan.
   **Alla 57 index måste köras om** (inte bara de tidigare noll-punkts-
   modellerna) eftersom lagringsformatet/värdena ändrats i grunden för
   varenda modell.

   **Historik från FÖRE glättningsfixen ovan** (siffrorna gäller den
   gamla, nu ersatta råpunkts-metoden — täckningsprocenten kommer se
   annorlunda ut efter omkörningen, se ovan): granskning 2026-08-12 gav
   199/521 kurvpunkter (~38%). 11 av 57 modeller fick noll punkter — de
   flesta (Mini Cooper, Mazda CX-5, Nissan X-Trail, Hyundai IONIQ 5,
   Toyota Land Cruiser m.fl.) troligen bara `market_listings`-glesa
   (löser sig med mer nightly-data över tid, modellnamnen matchar
   korrekt mot Skatteverket — verifierat direkt). BMW 3-serie/5-serie och
   Mercedes-Benz C-klass/E-klass hade däremot en RIKTIG, separat
   matchningsbugg (fortfarande relevant/fixad, påverkas INTE av
   glättningsfixen): Skatteverket skriver aldrig ut seriebeteckningen
   bokstavligt (bara trimkoder som "320d xDrive", "C 200 4MATIC..."), så
   substräng-matchningen mot `new_car_prices.model_raw` kunde aldrig
   träffa. Fixat med ett `skatteverketModelPattern`-regex-fält på de fyra
   `ModelReference`-posterna (index 19, 20, 28, 29 — se
   `data/referenceData.ts`), bekräftat med omkörning (0 → 7/10/8/9
   punkter).

   **Nästa steg:** kör om alla 57 index med den nya glättningslogiken
   (samma PowerShell-loop, `0..56`), och stäm av att t.ex. XC60-analysen
   nu visar en jämn kurva istället för zigzag.
3. **Steg 3 (backlog, ej påbörjat):** finjustering för mätarställning —
   inom varje åldersgrupp, mät hur priset avviker med mätarställningens
   avvikelse från förväntat (`ref.avgMilPerYear × ålder`), ge en
   kr/mil-justering.
4. **Steg 4 (backlog, ej påbörjat):** gör om
   `recompute-depreciation-curves` till en schemalagd Vercel Cron (t.ex.
   månadsvis, som `score-listings.ts`) istället för manuell körning.
   Just nu förfinas kurvan INTE automatiskt — `market_listings` växer
   varje natt men kurvan är en snapshot från senaste manuella körning,
   och nya `referenceData.ts`-poster faller tyst tillbaka på den platta
   procentsatsen tills någon kör om loopen för det indexet. Komplikation:
   endpointen är medvetet begränsad till ett index per anrop (ingen
   `maxDuration` satt, defaulten kan vara så låg som 10s) — en cron-version
   behöver antingen en högre `maxDuration` (Vercel Pro) eller loopa ett
   fåtal index per körning och fortsätta nästa gång tills alla 57 är
   uppdaterade.

## Kända begränsningar / öppna trådar

- **Mätarställnings-bugg — RIKTIG rotorsak hittad och fixad (2026-08-12).**
  Jagade fel bov i flera omgångar innan den verkliga orsaken hittades.
  Facit: `scrapeAndParse()` i `scraper-service/parsers.ts` kör ALL
  parserdata (Blocket, Wayke, Bytbil) genom en `normalize()`-funktion
  direkt efter parsern returnerar — ett steg som ALDRIG loggas. Den hade
  `mileage_km: raw.mileage_km && raw.mileage_km >= 0 && ... ? raw.mileage_km : undefined`
  — en klassisk JS-fälla: `0 && vad_som_helst` kortsluter till `0`
  (falsy) INNAN gränskontrollen ens körs, så en korrekt tolkad "0 mil"
  kastades bort och blev `undefined`. `parseBlocket()` (i `blocket.ts`)
  hade ALDRIG fel — Railway-loggarnas `PARSED: {...,"mileage":0}` visade
  alltid rätt värde, bara ett steg tidigare i kedjan än där buggen satt.
  Detta förklarar även den allra första gåtan (`scores.mileage: 50` i den
  ursprungliga XC60-analysen): `normalize()` kastade bort mätarställningen
  före scoring, `saveCarData` lagrade NULL, och `getAnalysis()`s
  visningsfallback `row.mileage_km ?? 0` DOLDE att det lagrade värdet var
  NULL genom att visa "0" ändå — vilket fick hela utredningen att gå fel
  håll i flera timmar. Fixat: bytte alla tre numeriska kontroller i
  `normalize()` (`price_sek`, `mileage_km`, `year`) till `Number.isFinite()`
  istället för truthy-checks. Sökte igenom resten av scraper-service och
  huvudappen efter samma mönster — inga fler träffar.

  De tidigare fixarna i `blocket.ts` (`fetchAdWithRetry()`,
  "Ny bil till salu"→0-fallbacken, den utökade timeout-budgeten) löser
  ett verkligt men mindre problem (blocket-api.se är ibland trögt med att
  indexera en helt nyss inlagd annons — bekräftat separat via direkta
  curl-jämförelser) och lämnas kvar som extra skyddsnät, men det var INTE
  huvudorsaken till felen användaren såg.
- **blocket-api.se är inte fullt pålitlig.** Tre separata fall
  verifierade denna session: (1) speglar/cachar annonsdata och
  reflekterar INTE borttagning i realtid — därför bytte
  sold-verifieringen till att kolla riktiga blocket.se-sidan istället;
  (2) ad-detalj-endpointens `Miltal`-fält kan avvika från vad som
  faktiskt lagrades via sök-endpointen för samma annons (en Mercedes
  visade "256 387 mil" via ad-detalj men 23 900 mil i databasen — troligen
  ett fel/glapp i den tredjepartsdata, inte i vår kod); (3) hinner inte
  alltid indexera mätarställning för väldigt nyss inlagda annonser (se
  mätarställnings-buggen ovan). Lärdom: verifiera alltid mot databasens
  faktiska lagrade värden innan en hypotes om "orimlig data" antas
  stämma.
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
5. Granska resultatet av värdeminskningskurve-körningen tillsammans
   (hur många modeller fick riktiga kurvpunkter vs. föll tillbaka på
   flat-rate), och gör `recompute-depreciation-curves` till en
   schemalagd cron (se "Pågående arbete" ovan, steg 4) så den slutar
   vara ett manuellt steg.
