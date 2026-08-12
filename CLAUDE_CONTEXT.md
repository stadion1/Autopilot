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
  visar jämförbara annonser med minst +8 poäng bättre deal score.
  **Fixat 2026-08-12**: `getBetterDeals()` matchade tidigare bara på
  år (±2) och pris (±30%), aldrig mätarställning — en begagnad bil kunde
  få "bättre alternativ" som i praktiken var nya lagerbilar (0 mil),
  poängsatta mot Skatteverkets nybilslistpris istället för
  marknadsmedian (helt olika värderingsgrund, inte jämförbara deal
  scores). Nu begränsat till samma kategori (`mileage_km <=
  NEW_CAR_MAX_MIL_KM`, samma tröskel som `isEssentiallyNewCar()` i
  `engine.ts` — flyttad till den delade `lib/scoring/constants.ts` för
  att undvika en cirkulär import mellan `engine.ts` och
  `lib/supabase/client.ts`).
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
- **`get_market_median()` gjord robust mot extremvärden (2026-08-12).**
  Undersökte FÖRST om det var ett verkligt problem innan något byggdes —
  hittade `market_listings`-grupper med upp till 5x spridning mellan
  lägsta/högsta pris inom samma märke/modell/år, men manuell koll av tre
  värsta fallen visade att den råa medianen redan var ganska robust
  (median matematiskt okänslig för svansextremer, till skillnad från ett
  medelvärde). Facit per fall: en trolig ex-taxi Mercedes E-klass
  (830 000 km, prissatt rimligt för sitt skick — inget fel), en äkta
  bred marknad för högmilade diesel-Passater (inget fel, bara verklig
  spridning), och en BMW M3 ("F80"-chassikod) felaktigt grupperad med
  vanliga 3-serie-bilar (ett RIKTIGT klassificeringsfel). Byggde en
  tvåstegs MAD-baserad (median absolute deviation) outlier-filtrering i
  `get_market_median()`: preliminär median → MAD → uteslut annonser mer
  än 3,5 "modifierade z-score"-enheter bort → räkna om medianen på det
  som blir kvar. Verifierat mot BMW-fallet: filtrerade bort både M3:an
  OCH en gränsfalls-annons (313hk M Sport, precis över tröskeln),
  `sample_size` 15→13, ny median 135 000 kr — matchade en manuell
  handuträkning exakt. Ingen klientkodsändring behövdes (samma RPC-
  signatur).
- **AI-sammanfattningen troligen trasig sen okänt lång tid, fixad
  (2026-08-12).** Användaren märkte att samma fraser återkom i nästan
  varje analys. Orsak: `analyzeWithAI()` i `lib/ai/analyzer.ts` använde
  modell-ID:t `claude-sonnet-4-6`, som inte matchar något giltigt
  Claude-modell-ID (aktuell familj: `claude-sonnet-5`/`opus-5`/`fable-5`,
  `claude-haiku-4-5-*`). `pages/api/process.ts`s `try/catch` runt anropet
  tystade felet HELT (ingen loggning alls) och föll tillbaka på
  `fallbackSummary()` — en fast mening-mall där bara siffrorna varierar;
  sista meningen ("Genomför alltid oberoende besiktning och begär
  servicehistorik") är alltid ordagrant identisk. Fixat: modell-ID:t
  ändrat till `claude-sonnet-5`, och lade till `console.error`-loggning
  i catch-blocket så ett framtida liknande fel syns i loggarna istället
  för att bara märkas via misstänkt repetitiv text.

  **Uppföljningsbugg samma dag:** med modellen faktiskt igång dök en NY
  felkälla upp — ett svar kunde klippas av mitt i JSON-strängen (700
  `max_tokens` var snålt tilltaget för 2–3 stycken svensk text inbakat i
  JSON), och `parseResponse()`s catch-block returnerade då tyst den råa,
  TRASIGA JSON-texten som om den vore ett giltigt sammandrag —
  `analyzeWithAI()` "lyckades" enligt anroparen, så `process.ts`s
  fallback-mekanism (som redan fixades ovan) triggades aldrig. Användaren
  fick se en avbruten JSON-blob rakt av i UI:t. Fixat: `max_tokens`
  höjd till 1024, och `parseResponse()` kastar nu istället för att
  returnera den trasiga texten, så den korrekt faller igenom till
  `process.ts`s befintliga (loggande) fallback. **Inte verifierat i
  produktion än** — testa en ny analys.

  **Förbättring samma dag:** användaren frågade om AI-sammanfattningen
  kunde kommentera specifika ägandekostnads-drivare (dyr att försäkra,
  ovanligt hög skatt, hög bränsleförbrukning, höga/låga servicekostnader)
  — den kunde inte, `analyzeWithAI()` fick bara en enda sammanslagen
  "Ägandekostnad: X/100"-siffra, aldrig den faktiska kr-uppdelningen som
  `OwnershipCostCard` redan visar. `process.ts` kör nu
  `calculateOwnershipCosts()` (utan kurva/mätarställnings-känslighet —
  de hämtas bara vid läsning i `pages/api/analysis/[id].ts`, den platta
  modellsnitts-raten räcker för AI:ns kvalitativa kommentar) och skickar
  år 1:s uppdelning (värdeminskning/service/försäkring/skatt/bränsle) in
  i prompten, med en instruktion att peka ut kategorier som sticker ut.
  Modellanteckningar och risker skickades redan sedan tidigare — inget
  gap där.

  **Tredje bugg i samma saga, hittad via loggarna:** trots modellfixen
  och max_tokens-höjningen fortsatte fallback-mallen dyka upp på vissa
  annonser. Loggen (nu synlig tack vare loggnings-fixet) visade den
  riktiga orsaken: `"Bad control character in string literal in JSON"`
  — modellen skrev helt naturliga stycken med RÅA radbyten inuti
  `summary`-JSON-strängen, vilket är ogiltigt enligt JSON-specen. Inte
  ett avkapat svar den här gången, ett giltigt men strikt-JSON-ogiltigt
  svar. Löst genom att helt överge JSON-formatet för svaret — bytt till
  ett enkelt `VERDICT: ...` / `SUMMARY: ...`-textformat där resten av
  texten efter "SUMMARY:" fångas rakt av (ingen escaping inblandad, fri
  text med radbyten är helt ofarligt i det formatet). Övervägde att
  sanera bort kontrolltecken före `JSON.parse()` istället, men bedömde
  det för riskabelt (kan sönderdela strukturell whitespace om modellen
  prettyprintat JSON:en). **Bekräftat i produktion** — en riktig,
  varierad AI-text kom tillbaka (efter att den specifika stale-cachade
  raden togs bort manuellt, se cache-anmärkningen nedan). Hela
  AI-sammanfattnings-sagan (fel modell-ID → tyst catch → avkapad JSON →
  råa radbyten i JSON) betraktas nu som löst.

  **Cache-fälla, samma mönster som mätarställnings-sagan tidigare
  idag:** att skicka in SAMMA Blocket-URL igen för att "testa fixen"
  returnerar bara den gamla cachade (trasiga) analysen om den är
  <24h gammal (`getCachedAnalysis()` matchar även `status='done'`-rader
  med trasigt AI-svar). Verifierades genom att jämföra `meta.analyzed_at`
  mot logg-tidsstämpeln för det ursprungliga felet — identiska.
  Snabbaste sättet att tvinga fram en omkörning: `delete from analyses
  where id = '<uuid>'` och skicka in URL:en på nytt.

  **Ytterligare fynd, samma dag:** användaren frågade hur prisestimatet
  räknas fram för en bil där `pricing.medianSource` visade sig vara
  felmärkt — se `get_market_median()`/prisestimat-posten nedan.
- **"Marknadsmedian" felmärkt när priset är en ren teoretisk gissning
  (2026-08-12).** Tredje och sista fallet av samma mislabeling-bugg som
  nybilspris-fixen tidigare idag (och som hittades genom att användaren
  frågade "hur räknas prisestimatet"): när VARKEN live- eller statisk
  marknadsmedian finns faller `calculatePricing()` tillbaka på en ren
  formel (`basePrice × (1-depreciation)^ålder` från `referenceData.ts`)
  — men `medianSource` särskiljde bara "nybilspris" från ett
  catch-all "market", så den teoretiska gissningen kallades
  "Marknadsmedian" i priskortet, pros/cons-texterna OCH AI-prompten,
  trots att `confidence.reasons` redan sa "Ingen marknadsmedian
  tillgänglig — teoretiskt estimat används" på samma sida. Fixat: nytt
  `'theoretical'`-läge i `PriceRange.medianSource`, trätt igenom
  priskortet ("Teoretisk uppskattning"), båda pros/cons-textrader i
  `engine.ts`, och AI-prompten (som nu explicit får veta att ingen
  riktig marknadsdata ligger bakom siffran).

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

   **Ytterligare bugg hittad och fixad (2026-08-12):** en 8 år gammal
   XC60 (registrerad 2018) visade nästan ingen värdeminskning år 1 men
   ett stort hopp år 2. Orsak: `depreciation_curves` för XC60 har bara
   punkter för ålder 0–9 (databegränsning, inte en bugg i sig). Bilens
   prognosfönster (ålder 8→12) låg delvis innanför kurvans täckning
   (år 1: ålder 8→9, täckt) och delvis utanför (år 2–5: ålder 9→10 osv,
   otäckt) — `depreciationRateForAge()` föll tyst tillbaka på den platta
   referensprocenten (12% för XC60) så fort ÅLDER+1 saknades i kurvan,
   vilket gav ett hack exakt vid kurvans kant (låg kurv-rate år 1, hög
   platt rate år 2–5). Fixat i `lib/scoring/ownershipCost.ts`: när en
   bils ålder är vid eller bortom kurvans äldsta mätpunkt, extrapoleras
   samma rate som kurvans två äldsta punkter mätte, istället för att
   byta till den orelaterade platta procentsatsen. Gäller alla modeller
   vars prognosfönster sträcker sig längre än kurvans datatäckning, inte
   bara XC60.
3. **Steg 3 (klart och verifierat, 2026-08-12):** finjustering för
   mätarställning. Ny tabell `mileage_sensitivity` — ett värde per
   (brand, model, year_from): kr per 1000 mil avvikelse från förväntad
   mätarställning (`ref.avgMilPerYear × ålder`), regressat ur samma
   `market_listings`-rader som redan hämtas för kurvan (prisavvikelse mot
   ÅLDERSGRUPPENS EGEN median, poolat över alla åldrar). Beräknas i samma
   `recompute-depreciation-curves.ts`-endpoint. `calculateOwnershipCosts()`
   sprider den bilspecifika totala justeringen jämnt över prognosåren
   (antar att mätarställnings-avvikelsen håller sig konstant framåt),
   klampat så ett enskilt år aldrig kan visa negativ värdeminskning.
   Migrationen körd, alla 57 index beräknade (0/1/2 fick tillfälliga
   proxy-nätverksfel första gången, gick igenom vid omkörning — inte en
   kodbugg). Granskad: alla värden negativa som förväntat (t.ex. XC60
   -10 825 kr/1000 mil, 271 annonser; Passat -4 738 kr/1000 mil,
   229 annonser), en modell (Audi A6, 94 annonser) träffade klamptaket
   (-15 000) exakt — den råa regressionen gav ett ännu mer extremt värde.

   **Två uppföljningar byggda samma dag, efter användarens invändning:**
   - **Kausalitetsfix:** den ursprungliga versionen antog att bilens
     NUVARANDE mätarställningsavvikelse ligger still framåt — vilket
     tyst antar att köparen kör exakt som föregående ägare. Fel: dagens
     avvikelse är redan inbakad i `car.price_sek` (marknaden har redan
     prissatt den), det som INTE är känt är hur avvikelsen växer/krymper
     framåt, vilket beror på DEN NYA ägarens egen körning. Löst:
     `calculateOwnershipCosts()` tar nu en valfri `expectedAnnualMil`
     (nytt inputfält "Din förväntade körsträcka" i UI:t, bredvid
     Kontant/Billån, förifyllt med modellens snitt via ny
     `getDefaultAnnualMil()`-export). Varje års justering räknas som
     `år × (användarens mil/år − modellens snitt)` — kör man i
     modellsnittet blir justeringen 0 (kurvans rate på det redan
     rabatterade priset bevarar redan den relativa positionen korrekt då).
   - **Prisjämförelsen förbättrad:** `scorePrice()`/`calculatePricing()`
     i `engine.ts` använde fortfarande den gissade
     `pricePer1000ExtraMil` från `referenceData.ts`. `scoreVehicle()`
     slår nu upp `mileage_sensitivity` via `getMileageSensitivity()` och
     använder den istället när data finns (samma tecken-konvention,
     ingen omvandling behövs), med fallback till den gissade konstanten
     annars.
4. **Steg 4 (byggt 2026-08-12, ej verifierat i produktion):** daglig
   Vercel Cron (`pages/api/cron/recompute-depreciation-curves.ts`,
   `0 4 * * *` i `vercel.json`). Kärnlogiken flyttad från admin-endpointen
   till en delad `lib/depreciationCurve.ts` (samma funktion,
   `recomputeDepreciationCurveForIndex()`, används av både admin-routen
   och cronen). Samma Hobby-begränsning som `score-listings.ts` (bara
   dagliga crons) — cyklar igenom alla 57 `MODEL_REFERENCES` ett antal i
   taget (`BATCH_SIZE=9`, ~7 dagar per full cykel), vilket dagsvarv som
   körs beräknas deterministiskt från dagens datum (dagar sedan epoch
   modulo antal varv) utan egen cursor-tabell. Index inom en dags batch
   körs med begränsad konkurrens (`CONCURRENCY=3`, båda miljövariabel-
   justerbara). **Inte uppmätt hur lång tid en daglig batch faktiskt
   tar** — kolla `durationMs` i cron-svaret efter första körningen.
   **Oklart om Vercel Hobby har ett tak på ANTAL crons** (utöver
   frekvenstaket vi redan stötte på för `score-listings`) — det här är
   nu den tredje cronen i `vercel.json`, inte verifierat att deployen
   går igenom.

## Kända begränsningar / öppna trådar

- **`deal_score`-backlog var permanent fastlåst, fixat (2026-08-12).**
  `pages/api/cron/score-listings.ts` körde en gång/dygn med
  `BATCH_SIZE=150`. `getListingsNeedingScore()` sorterar aldrig
  poängsatta rader (NULL `deal_score_updated_at`, dvs. nya rader från
  `scraper-service/nightly.ts`) FÖRST, före ALLA tidigare poängsatta
  rader oavsett ålder. Med ~5 126 aktiva rader, `SCORE_STALE_AFTER_HOURS
  =24` (gör praktiskt taget hela tabellen "kvalificerad" varje dygn) och
  ~400 nya rader/natt (redan mer än hela dagsbudgeten på 150) fick
  backloggen av redan poängsatta men inaktuella rader ALDRIG någon
  budget — inte "några dagar efter", permanent fastlåst. Effekten
  användaren såg: en färsk analys (kör alltid senaste kod) gav annan
  deal-score än samma annons lagrade värde i `market_listings`, och
  "bättre alternativ"-jämförelser kunde använda månader-gamla scores.
  **Första fixförsöket** (höj `BATCH_SIZE` + kör timvis istället för
  dagligen) blockerade HELA Vercel-deployen — projektet ligger på Hobby-
  planen, som bara tillåter dagliga crons; `vercel.json`s timschema fick
  bygget att failas helt (inget nytt gick live, oavsett tidigare pushar).
  **Andra fixen**, inom dagligt schema: `scoreVehicle()` i `engine.ts`
  gjorde tre databasuppslag (marknadsmedian, nybilspris, mätarställnings-
  känslighet) i SEKVENS trots att inget av dem beror på de andras
  resultat — körs nu parallellt med `Promise.all()`, ~3x snabbare per
  bil. `maxDuration: 60` tillagd (saknades helt).

  **Körd och uppmätt i produktion (2026-08-12):** första körningen med
  `BATCH_SIZE=2000` gav bara `{scored:1000, failed:0, total:1000}` —
  `getListingsNeedingScore()` använde bara `.limit()`, som
  Supabase/PostgREST tyst begränsar till 1000 rader/fråga oavsett
  begärt värde (samma buggmönster som redan setts två gånger tidigare
  denna session). **Tredje fixen:** lade till `.range()`-paginering i
  `getListingsNeedingScore()`. Mätning: 1000 rader tog 33,23s vid
  `CONCURRENCY=20` (~30 rader/sek) — 2000 hade landat på ~66s, över
  60s-taket. Satte `BATCH_SIZE=1400` (~46,5s uppskattat, ~13,5s
  marginal) baserat på den uppmätta hastigheten istället för att gissa.
  1400/dygn mot ~400 nya/natt ⇒ netto ~1000/dygn ⇒ ~5 100-raders
  backloggen tömd på ungefär en vecka. **Bekräftat i produktion:**
  `{scored:1400, failed:0, total:1400}` — hela batchen lyckades.
  Betraktas som löst.

  **Framtida trigger för Vercel Pro-uppgradering:** hela den här
  lösningen (1400/dygn inom en enda daglig 60s-körning, Hobby-planens
  tak) är en avvägning för DAGENS volym (~5 100 aktiva rader, ~400
  nya/natt). Vercel Hobby tillåter bara dagliga crons — går det inte
  längre att täcka dagsvolymen inom en 60s-körning (t.ex. om fler
  bilmodeller läggs till i `referenceData.ts`/`TRACKED_MODELS`, fler
  källor än Blocket/Wayke/Bytbil börjar skrapas i volym, eller
  marknadsdatan bara växer naturligt över tid), finns inget mer att
  vinna på snabbare kod eller större batch inom Hobbys begränsningar —
  då krävs Vercel Pro för att kunna köra cronen oftare än en gång/dygn
  (t.ex. varje timme, vilket redan är förberett/testat i denna session
  men blockerades av just Hobby-planens dagliga-crons-restriktion).
  Varningstecken att hålla utkik efter: `scored` börjar konsekvent
  understiga `total` (batchen hinner inte klart inom 60s) eller
  backloggen slutar krympa trots den dagliga körningen.
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
- **Bränsleförbrukning per modell — inte byggt, research påbörjad
  (2026-08-12).** `estimateAnnualFuelCost()` använder idag bara en platt
  schablon per drivmedelstyp (t.ex. 0,68 l/mil för ALL bensin oavsett
  modell), vilket begränsar både ägandekostnads-estimatet och AI-
  sammanfattningens förmåga att kommentera bränslekostnad specifikt.
  Undersökte blocket-api.se:s eget per-annons-förbrukningsfält (curl mot
  4 riktiga annons-ID:n): finns med riktiga värden på två ÄLDRE annonser
  (6,5 l/100km, 5,1 l/100km), saknas helt på två NYARE (inkl. en
  laddhybrid), och fältnyckeln själv är en instabil, lång beskrivande
  sträng ("Bränsleförbrukning(NEDC)NEDC var..."), inte en fast nyckel —
  kräver fuzzy substräng-matchning, ingen pålitlig primärkälla.
  Efterforskade alternativa öppna datakällor: Transportstyrelsens
  API-portal (`tsopendata.portal.azure-api.net`) hittades men gick inte
  att inspektera (WebFetch: "Socket is closed", två försök). EU:s
  miljöbyrå EEA har en öppen CO2-utsläppsdatabas för alla nyregistrerade
  bilar i EU (inkl. Sverige) sedan år 2000, per märke/modell/variant,
  med CO2-utsläpp (omräkningsbart till förbrukning) och elförbrukning
  för elbilar — mest lovande fyndet, men är en BULK-nedladdning
  (CSV/Excel, 2000–2024, hela EU, sannolikt miljontals rader), inte en
  fråga-per-anrop-API som Skatteverkets. Skulle kräva ett eget
  filtrerings-/bearbetningssteg (plocka ut Sverige-relevanta
  modeller/fält) — en klart större insats än Skatteverket-integrationen.
  Länkar: nedladdning `https://sdi.eea.europa.eu/data/d8ab6710-65b1-438c-bf48-f29fc12848ff`,
  interaktiv utforskare `http://co2cars.apps.eea.europa.eu/`.
  **Inte klart:** faktisk filstorlek/kolumnstruktur, om Sverige går att
  filtrera rent, och om det här är genuint bättre/pålitligare i praktiken
  än vad vi redan har. Sparat till en egen framtida session (för stort
  för att klämma in i en pågående) — se prioriterad lista nedan.

## Prioriterade nästa steg (föreslagna, ej bekräftade av användaren)

1. Ta ställning till orimligt-pris-varning per analys, som ett
   användarvänt komplement till den tysta ingestion-filtreringen.
2. Följ upp liggtids-påminnelsen när den triggas — avgör om datan
   räcker för att bygga "förväntad tid till sålt".
3. Vercel Pro-tröskeln (se ovan) — inget att göra nu, men bevaka
   `scored`/`total` i `score-listings`-loggarna över tid.
4. Bränsleförbrukning per modell (se ovan) — i en egen session: verifiera
   EEA-datasetets faktiska struktur/storlek och Sverige-filtrering
   (helst via direkt nedladdning/inspektion av riktiga rader, inte bara
   metadata), ta ett nytt försök på Transportstyrelsens API-portal via
   en annan metod än direkt WebFetch, och lägg fram en rekommendation
   (bygg pipeline / avstå) innan någon kod skrivs.
