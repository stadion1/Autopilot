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

## Utrustningsdata i AI-sammanfattningen (2026-08-14)

Startskott: användaren testade ett riktigt exempel (Mercedes-Benz E450,
mycket välutrustad) och påpekade att det är svårt att jämföra en
sparsamt utrustad bil mot en premiumvariant av samma modell — allt
hamnar i samma prisjämförelse-bucket idag.

**Billiga steget, byggt:** `blocket-api.se`s per-annons-svar innehåller
faktiskt en full utrustningslista (~50 poster för testbilen — "Panoramaglastak",
"Helklädda lädersäten" osv.) som `parseBlocket()` hämtade men aldrig
sparade. Nu fångad genom hela kedjan: `CarListing.equipment` (typad i
både `types/index.ts` och `scraper-service/types.ts`), ny
`analyses.equipment TEXT[]`-kolumn, `saveCarData()`/`getAnalysis()`
läser och skriver den, och AI-prompten i `lib/ai/analyzer.ts` (v1.3) får
nu listan i FORDON-sektionen med instruktionen att bara kommentera den
om den faktiskt förklarar prisbilden. **Löser INTE** att
deal-score/prisjämförelsen fortfarande behandlar alla trimnivåer av en
modell som en enda bucket — bara den kvalitativa AI-texten blir
smartare, inte siffrorna.

**Kräver manuell åtgärd innan det är live:** kör migrationen i
`data/schema.sql` (sök "Migration: analyses.equipment") i Supabase, och
verifiera att Railway deployat om `scraper-service` (samma steg som
median_source-fixen tidigare samma dag). **Inte testat i produktion än.**

**Den dyrare, inte byggda idén** (för framtida session): en riktig
utrustningsviktad prisjustering — vikta marknadsmedianen efter
utrustningsnivå istället för att bara nämna den i text. Mycket större
projekt: kräver att nightly-scrapern också hämtar full utrustningsdata
per annons (sökresultat-endpointen har den inte, bara detalj-endpointen),
plus en modell för hur mycket varje utrustningspaket typiskt påverkar
priset per märke/modell — liknar värdeminskningskurve-projektet i
storlek, fast för utrustning istället för ålder.

## Utökad modelltäckning — 51 → 105+ bilmodeller (2026-08-18)

Användaren ville bevaka fler bilmodeller — pekade på carup.se:s "Sveriges
100 populäraste bilar under 2024" som ett golv. Research innan kodning:
carup.se-listan bygger på NYregistreringar 2024, inte begagnatmarknaden,
så den korsades mot Kvdbils faktiska begagnatförsäljningsstatistik 2025
(sökning: "mest sålda begagnade bilar Sverige 2025"). Det avslöjade en
verklig lucka listan ensam hade missat: **Volvo V70** — utgången sedan
2016 — är enligt Kvdbil fortfarande Sveriges mest sålda BEGAGNADE bil
(52 865 sålda 2025), före både V60 och XC60. Lades till trots att den
inte finns på nyregistreringslistan.

**Ändrat:**
- `scraper-service/blocket.ts`s `TRACKED_MODELS` (delas av `nightly.ts`
  och `findTrackedModel()` — se kommentarerna där för varför det är en
  enda källa) utökad från 51 till 112 modeller.
- `data/referenceData.ts`s `MODEL_REFERENCES` utökad från 57 till 111
  poster (samma nya modeller plus några som redan fanns i referensdatan
  men inte bevakades av scrapern — de två listorna var redan innan
  denna session inte 1:1, det är avsiktligt: `lookupModelReference()`
  degraderar snyggt till märkessnitt/generell default för obevakade
  modeller, se funktionen längst ner i filen).
- Nya märken helt utan tidigare referensdata (fick annars den generiska
  300 000 kr-defaulten): Polestar, Cupra, Porsche, Lexus, MG, Lynk & Co,
  Opel, Citroën, Zeekr.
- Medvetet UTESLUTNA: skåpbilar/lätta lastbilar som dyker upp högt i
  både nyregistrerings- och begagnatstatistiken (Fiat Ducato, Mercedes
  Sprinter/Vito, Ford Transit, VW Caddy/Transporter) — utanför scope för
  en personbils­annons-analystjänst. "Volvo Others" (plats 100 på
  carup.se-listan, för ospecifikt för en enskild rad) uteslöts också.

**Viktig kvalitetsskillnad mot befintlig data:** `referenceData.ts`s
header hävdar källor som Mobility Sweden/Wayke/KVD-auktionsdata för de
ursprungliga posterna. De 54 nya posterna har INTE verifierats mot de
källorna — de är rimlighetsuppskattningar baserat på allmän kännedom om
svenska nybilspriser och typiska depreciationsmönster per segment
(samma tillvägagångssätt filen själv redan använder för Audi A4/A6/Q5,
se kommentaren i Audi-sektionen — "inga officiella nypriser hittades
... uppskattade genom jämförelse"). Bör betraktas som en startgissning,
inte forskad data — förbättras naturligt efterhand som
`market_listings` fylls på för dessa modeller (medianen dominerar redan
över `basePrice` när tillräckligt med riktiga annonser finns, se
`get_market_median()`).

**Inte gjort/verifierat den här sessionen:**
- Ingen `npm run build`/`tsc --noEmit` kördes — Node/npm saknas i den
  här miljön (samma begränsning som redan noterad i produktions-
  checklistan nedan, punkt 6d). Verifierat istället manuellt: brace/
  bracket/parentes-balans i båda filerna, samt att ingen `{brand,
  model}`-rad i `TRACKED_MODELS` förekommer två gånger.
- Inga `known_issues`-rader för de 54 nya modellerna — det pågående
  Deep Research-spåret (se prioriterade nästa steg, punkt 4) har hittills
  bara täckt Volvo/Toyota/VW/BMW/Mercedes-Benz av de URSPRUNGLIGA
  modellerna. De nya modellerna (och resten av de gamla) väntar fortfarande.
- Nightly-scrapern (`nightly.ts`) hämtar fortfarande bara ~20 sidor/natt
  ur ett ofiltrerat, roterande flöde (se `NIGHTLY_SCRAPER.md`) — med
  fler bevakade modeller tar det proportionerligt längre tid innan
  `market_listings` får meningsfull täckning för de nya, mindre vanliga
  modellerna (Zeekr, Lynk & Co, MG m.fl. är riktigt lågvolym i Sverige
  än så länge).

## Nightly-scraperns täckningstak upptäckt och MAX_PAGES höjt (2026-08-19)

Uppföljning på modellutökningen ovan — användaren jämförde nattens körning
mot tidigare (50–100 fler matchade annonser, bekräftade att den nya
`TRACKED_MODELS`-listan var aktiv) och frågade sen den rimliga
följdfrågan: hur vet vi att vi inte missar annonser, och hur många nya
annonser publiceras per dag på Blocket?

**Testade direkt mot blocket-api.se (2026-08-19) och hittade en gräns som
inte var tydligt dokumenterad förut:** `result_size.match_count` = 141 756
aktiva bilannonser totalt, men `metadata.paging.last` = 50 — ett HÅRT tak
i själva API:t. Vi kan aldrig nå fler än 50×50 = 2 500 annonser genom den
här endpointen, oavsett `NIGHTLY_MAX_PAGES`. Testade även igen om `sort`/
`sort_by` går att styra via query-param (i hopp om att kunna beställa
kronologisk ordning) — samma 422-fel som redan dokumenterat, sortering är
hårdkodad till `RELEVANCE` server-side.

`MAX_PAGES` stod på default 20 (env-var `NIGHTLY_MAX_PAGES` osatt i
Railway, såvitt känt) — dvs vi nådde inte ens fram till det egna
25-sidorstaket. **Höjt default till 50** i `scraper-service/nightly.ts`
(API:ts eget tak, ingen anledning att sätta lägre om inte prestanda blir
ett problem — 30 extra sidor × ~1s delay ≈ 30–50s extra körtid per natt,
ingen timeout-risk hittad i `railway.nightly.json`).

**Viktig nyansering av tidigare (för optimistisk) formulering:** sa
tidigare i konversationen att "täckningen byggs upp över flera nätter" —
det stämmer bara i den mån RELEVANCE-rankningen förskjuts natt till natt,
INTE som en rullande genomgång av hela beståndet (sidorna 1–50 är samma
relevans-fönster varje gång). Användaren kollade manuellt på blocket.se:s
riktiga sida och såg annonser på sida 20 publicerade för en timme sedan —
publiceringstakten är alltså flera tusen/dag, vilket gör
2 500-annonsersfönstret till ett litet statistiskt stickprov, inte en
fullständig fångst. **Beslut:** accepterat för nu — målet är ett
representativt stickprov för marknadsmedianen per modell/år, inte att
fånga varenda annons. Om fullständig täckning blir viktigt senare krävs
skrapning av blocket.se:s riktiga sida (med riktig datumsortering) istället
för blocket-api.se — större omarbetning, INTE påbörjad.

Dokumenterat i detalj i `NIGHTLY_SCRAPER.md` (punkt 1, utökad).

**Öppen tråd, inte byggd:** ett förslag som diskuterades men inte
implementerades — logga hur många av natt-kickens matchade annonser som
är helt nya (`source_url` aldrig sedd i `market_listings` förut) vs redan
kända, som ett billigt sätt att mäta faktisk fångstgrad för de bevakade
modellerna över tid (svarar inte på Blockets totala publiceringstakt, men
på den mer relevanta frågan om vi fångar upp fler nya annonser för det vi
bevakar). Naturlig uppföljning om täckningsfrågan kommer upp igen.

## Supabase model_references kopplad in i live scoring (2026-08-19)

Uppföljning på modellutökningen — användaren frågade vad det innebar att
`getLiveModelReference()` fanns skriven men aldrig anropades (se förra
sessionens svar). Bad om att den kopplas in på riktigt. Gjort.

**Ny funktion `resolveModelReference()`** i `lib/supabase/client.ts` — den
faktiska "DB primär, statisk `data/referenceData.ts` fallback"-ingången.
Ersätter `lookupModelReference()`-anropen i:
- `lib/scoring/engine.ts` (`scoreVehicle()`) — redan `async`, bara ett
  `await`-tillägg.
- `pages/api/analysis/[id].ts` — skickar nu även med `model_reference`
  (`avgMilPerYear`/`depreciation`) i JSON-svaret till klienten.

**Två saker som krävde eftertanke, inte bara en enkel swap:**

1. **Service-role-nyckeln får inte nå klienten.** `lib/scoring/
   ownershipCost.ts` buntas till klienten (`app/analysis/[id]/page.tsx` är
   `'use client'`) och importerar medvetet ALDRIG `lib/supabase/client.ts`
   (den filen håller `SUPABASE_SERVICE_ROLE_KEY`, ett fullprivilegierat
   nyckel). Löst genom att `getDefaultAnnualMil()`/
   `calculateOwnershipCosts()` nu tar en valfri förresolvad
   `{avgMilPerYear, depreciation}`-parameter istället för att slå upp
   själva — servern resolverar en gång och skickar med den via
   analys-JSON:en (`types/index.ts`s `AnalysisResult.model_reference`),
   klienten återanvänder den vid varje lokal omräkning (finansierings-
   toggle, mätarställnings-input) utan nya DB-anrop. Utan medskickad
   parameter faller funktionerna tillbaka på den gamla statiska
   uppslagningen — bakåtkompatibelt, `pages/api/process.ts`s befintliga
   anrop (`calculateOwnershipCosts(completeCar)`, ingen ref-parameter) är
   orört och funkar som förut.
2. **`pages/api/cron/score-listings.ts` scorar upp till 1400 rader/körning
   inom Vercel Hobbys 60s-tak** — en tidigare session lade ner
   ansträngning på att parallellisera `scoreVehicle()`s DB-uppslag för att
   få det att rymmas (se kommentarblocket i den filen). Ett DB-anrop PER
   RAD för referensuppslaget hade återinfört exakt det problemet. Löst med
   en in-process-cache (`Map`, nyckel `brand|model|year`, 10 min TTL) i
   `resolveModelReference()` — samma modell återkommer i hundratals rader
   per körning, så det blir i praktiken ett DB-anrop per DISTINKT modell
   (~111 st) snarare än per rad.

**Inte verifierat:** ingen `npm run build`/`tsc --noEmit` kördes (Node
saknas fortfarande i den här miljön — se punkt 11 i prioriterade nästa
steg). Verifierat istället manuellt: brace/parentes-balans i alla ändrade
filer, samt spårat varje anropsställe av de ändrade funktionssignaturerna
för att bekräfta att inget brutit bakåtkompatibiliteten (alla nya
parametrar är valfria och sist i listan). **Testa en riktig analys i
produktion näst session** för att bekräfta att `model_reference` faktiskt
kommer med i svaret och att ägandekostnads-kortet fortfarande fungerar.

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

- **`known_issues` utökad med Claude Deep Research för Volvo, verifierat
  (2026-08-13).** Startskott: användaren vill ha djupare bilkunskap i
  `known_issues` för bättre konsumentfeedback, körde Claude Deep Research
  (extern, i webbläsaren) på våra 8 bevakade Volvo-modeller med en
  promptmall utformad för att returnera SQL direkt mot schemat. Researchen
  kom tillbaka med 47 rader. Granskning innan import hittade: en
  substantiell dubblett (`xc60_sensus_freeze` mot redan seedade
  `volvo_xc60_sensus_freeze`, borttagen) och två svaga källor
  (`classaction.org`, ersatta). Eftersom 29 av raderna var
  `category='recall'` — säkerhetskritisk info som visas direkt för
  konsumenter — verifierades VARJE recall-familj manuellt mot svensk
  press (Vi Bilägare, SVT Nyheter, GP, Ny Teknik, Mest Motor, Börskollen)
  och internationella recall-register (NHTSA, tyska KBA) innan import,
  inte bara stickprov. Alla 10 recall-familjer bekräftades vara verkliga
  händelser (T8-batteribrand ~8 000 bilar i Sverige, dieselinsugsrör
  ~86 000, bränsleledning ~37 000, bromsbortfall B-läge även registrerad
  i EU via KBA — inte bara USA-NHTSA som researchens egen brasklapp
  antydde). Hittade och rättade ETT sakfel under verifieringen:
  `xc60_brake_pedal_loose_bolts` påstod återkallelsen skedde "nov
  2019/2020", men själva kampanjen (R10289) skickades ut först dec 2024
  (defekten uppstod 2019 på monteringslinjen, kampanjen kom mycket
  senare). 46 rader importerade (29 recall + 17 icke-recall: takluckans
  tätningslist, Aisin-växellåda, wet belt, EGR/DPF, 12V-batteri,
  infotainment, bakluckedämpare, AC-kompressor). Sparat som
  `data/volvo_known_issues_verified.sql` (fristående, körd direkt mot
  Supabase av användaren) OCH tillagt i `data/seed.sql` som ett separat
  `INSERT`-block (rör inte de 4 äldre Volvo-raderna, inga `rule_id`-
  krockar). **Mönster för nästa märke:** samma promptmall + samma
  tvåstegsprocess (research → manuell recall-verifiering mot
  press/NHTSA/KBA → import) — se prioriterad lista.
- **Samma mönster kört för Toyota, verifierat (2026-08-13).** 5 bevakade
  modeller (RAV4, Corolla, Yaris, C-HR, Land Cruiser). Researchen kom
  tillbaka med 31 rader (17 recall + 14 icke-recall), strukturellt rena
  (inga rule_id-krockar, inga ogiltiga severity/category-värden). 8 av
  17 recall-rader stickprovsverifierade mot NHTSA-originalkällor
  (inklusive de allvarligaste: Denso-bränslepump, RAV4 Prime
  DC/DC-brandrisk, Corolla styraxel-spricka, C-HR parkeringsbroms,
  Land Cruiser krockkudde-bältesgivare) — alla stämde exakt, ingen svag
  källa som Volvo-batchens classaction.org hittades. **Viktigast:**
  verifieringssökningen på svensk press avslöjade en RIKTIG återkallelse
  som researchen missat helt — Yaris Hybrid elektronisk parkeringsbroms
  (ECU-mjukvara, tillverkad juli 2020–april 2021), bekräftad av Vi
  Bilägare med ~4 000 svenska ägare berörda. Lades till manuellt som
  `yaris_epb_ecu_software` (32 rader totalt importerade). Lärdom: Deep
  Research missar ibland europa-specifika recalls som aldrig fick ett
  NHTSA-nummer (den amerikanska marknaden dominerar sökträffarna) —
  värt att alltid komplettera med en riktad sökning mot svensk press per
  märke, inte bara verifiera det researchen redan hittat. Sparat som
  `data/toyota_known_issues_verified.sql` + tillagt i `data/seed.sql`.

  **Uppföljningsbugg samma dag:** användaren körde `SELECT COUNT(*) FROM
  known_issues WHERE brand = 'Toyota'` och fick 33, inte förväntade 32.
  Orsak: missade en substantiell dubblett mot det ALLRA ÄLDSTA seedet
  (från långt innan Volvo/Toyota-passen) — `toyota_1kd_ftv_injector`
  (Land Cruiser 1KD-FTV, 2002–2015, injektorproblem, ingen källa) beskrev
  samma sak som nya `landcruiser_1kd_injektorer` (2010–2015, källa,
  mer detaljerad). Jag hade bara kollat `rule_id`-strängkollisioner mot
  BEFINTLIGA rader (ingen krock eftersom rule_id-namnen skiljer sig),
  inte innehållsöverlapp — samma typ av fel som Sensus-dubbletten i
  Volvo-passet, men den fångade jag då via manuell inspektion av just
  den sektionen; här missade jag att göra samma koll för Toyota-sektionen
  i det gamla seedet. Fixat: gav användaren en `DELETE FROM known_issues
  WHERE rule_id = 'toyota_1kd_ftv_injector'` att köra, och tog bort
  samma rad ur `data/seed.sql`. **Lärdom för nästa märke:** innan en ny
  batch skrivs, grepa `data/seed.sql` efter `('Märke','` i HELA filen
  (inte bara mot rule_id-listan) för att hitta ev. gamla seedade rader
  för det märket från originalseedet — inte bara verifiera mot förra
  Deep Research-batchens rader.
- **Samma mönster kört för Volkswagen, verifierat (2026-08-13).** 6
  bevakade modeller (Golf, Passat, Tiguan, T-Cross, ID.3, ID.4). Innan
  researchen kördes: kollade hela `seed.sql` (lärdomen från Toyota-
  missen) efter befintliga VW-rader — hittade 4 (DQ200-ryck Golf
  2013–2016, Golf 8-infotainment 2019–2022, EA288 EGR Passat 2014–2018,
  ID.3-lanseringsbuggar 2020–2021) och gav dem till researchen som
  "redan täckt, upprepa inte". Researchen kom tillbaka med 27 rader
  (15 recall + 12 icke-recall), strukturellt rena. Ett litet datafel:
  `fuel_type` kom i gemener ('bensin'/'el'/'laddhybrid') istället för
  databasens konvention ('Bensin'/'El'/'Laddhybrid') — inte funktionellt
  trasigt (`getLiveKnownIssues()` matchar med `ilike`, case-insensitive)
  men normaliserat vid import för konsekvens. 10 recall-rader
  stickprovsverifierade (samtliga high-severity: ID.4-batteribrand
  26V030 och ID.3-batteribrand — båda från januari/mars 2026, alltså
  bara veckor gamla när researchen kördes — Golf/Tiguan bakre
  spiralfjäder 42J5, Golf/Tiguan/T-Roc bromspedal-svetsfog, ID.4
  dörrhandtag 24V651, Passat GTE HV-säkring 93N4) — alla 10 stämde
  exakt mot NHTSA/KBA-originalkällor, ingen dubblett mot de 4 gamla
  raderna eller resten av seedet. Bästa träffsäkerheten av de tre
  passen hittills (10/10, inga fynd att rätta). Sparat som
  `data/vw_known_issues_verified.sql` + tillagt i `data/seed.sql`.
- **Samma mönster kört för BMW, verifierat (2026-08-14).** 4 bevakade
  modeller (3-serie, 5-serie, X3, X5). Kollade `seed.sql` för befintliga
  BMW-rader först — hittade 3 (N20 timing chain 3-serie 2012–2018, N52
  ventilkåpa/oljeläckage 3-serie 2006–2013, G30 iDrive 6-krascher
  5-serie 2016–2020), gav dem till researchen som "redan täckt".
  Researchen kom tillbaka med 31 rader (15 recall + 16 icke-recall),
  strukturellt rena, korrekt versaliserad `fuel_type` den här gången.
  **Nytt datafel, annorlunda än tidigare pass:** hela råtexten saknade
  svenska diakritiska tecken (å/ä/ö) genomgående ("sprod" för "spröd",
  "atgard" för "åtgärd", "kopratens" för "köparens") — ett
  genererings-/encodingfel, inte ett sakfel. Skrev om alla 31 radernas
  beskrivningar med korrekt svenska stavning innan import, samma
  sakinnehåll. 6 av de tyngsta claimen stickprovsverifierade
  (startrelä-brandrisk >1,1 miljoner globalt/196 355 i USA, Continental
  integrerat bromssystem 24V-104/79 670 i USA, B58-startmotorelektronik
  24V-576/>100 000 i USA, diesel-EGR-brandrisk 18V-755 expanderad till
  ~800 000 globalt, PHEV-batteribrand 20V-601/exakt 4 509 i USA och
  26 900 globalt, samt B58-oljepumpens bekräftat SAKNADE officiella
  recall — forskningen var här korrekt försiktig och hittade INTE på en
  recall som inte finns) — alla 6 stämde. Ett komplement lades till
  under verifieringen: 24V-576:s ursprungliga mjukvarufix visade sig
  otillräcklig och ersattes senare av en fysisk startmotorbytes-kampanj
  (25V-644) — nämnt i beskrivningen så köpar-VIN-kontrollen omfattar
  båda. Sparat som `data/bmw_known_issues_verified.sql` + tillagt i
  `data/seed.sql`. **Lärdom:** kolla alltid råtexten för saknade å/ä/ö
  innan import, inte bara sakinnehållet — uppenbarligen inte en garanti
  från Deep Research även när fakta stämmer.
- **Samma mönster kört för Mercedes-Benz, verifierat (2026-08-14).** 3
  bevakade modeller (C-klass, E-klass, GLC). Kollade `seed.sql` för
  befintliga Mercedes-rader först — hittade 2 (W205 C-klass rostangrepp
  bakre fjädring 2014–2018, W213 E-klass Magic Body Control-fel
  2016–2019), gav dem till researchen som "redan täckt" — och den här
  gången bad jag explicit om korrekta å/ä/ö i prompten (lärdom från
  BMW-passet). Fungerade: researchen kom tillbaka med 34 rader (9 recall
  + 25 icke-recall) med genomgående korrekt svensk stavning. Enda
  avvikelsen: en `rule_id` innehöll ett icke-ASCII-tecken
  (`glc_vatteninträngning_kaross`) — bytt till ASCII
  (`glc_vattenintrangning_torpedvagg`) för konsekvens med alla andra
  ~170 rule_id i databasen. 6 av 9 recall-rader stickprovsverifierade
  (kylvätskepumpens brandrisk 848 517 fordon — exakt matchande
  researchens siffra, bekräftat ej sålt i Nordamerika; MBUX-
  skärmåterkallelse 144 049, maj 2026; 48V-jordanslutning brandrisk
  ~12 200; GLC styrkopplingsbult 25V533/exakt 3 749; bränslepumps-
  återkallelse 143 551; GLC350e-kablageskavning 21V-197) — alla stämde.
  Bra disciplin: researchen letade INTE upp en påhittad högvolts-
  batteri-recall för laddhybriderna (bekräftade att den riktiga PHEV-
  batteriåterkallelsen bara gäller de rena elbilarna EQE/EQS, inte
  C/E/GLC:s laddhybridvarianter). Sparat som
  `data/mercedes_known_issues_verified.sql` + tillagt i `data/seed.sql`.
  **Sammanlagt 170 rader över 5 märken nu** (Volvo 46, Toyota 32, VW 27,
  BMW 31, Mercedes-Benz 34).
- **`model_references`-tabellen låg efter `referenceData.ts`, fixat i
  seed-filen (2026-08-13).** Användaren märkte att DB-tabellen bara hade
  46 rader trots att `data/referenceData.ts` har 57 modeller. Orsak:
  `getLiveModelRef()` i `lib/supabase/client.ts` frågar `model_references`
  FÖRST och faller bara tillbaka på `referenceData.ts` om DB-frågan missar
  — så de 11 saknade modellerna (Audi A3/A4/A6/Q3/Q5, Kia Ceed/Niro/
  Picanto, Nissan Leaf/Qashqai/X-Trail) körde tyst på fallback-vägen i
  varje analys istället för den avsedda "levande" DB-källan. Sannolikt
  uppstod glappet för att dessa modeller lagts till i TS-filen efter att
  `data/seed.sql` skrevs, utan att seed-filen uppdaterades i takt. Fixat:
  lade till alla 11 raderna i `data/seed.sql`s `model_references`-INSERT
  (värden kopierade 1:1 från `referenceData.ts`), verifierat att de 57
  raderna i filen nu exakt matchar TS-filens 57 modeller (ingen avvikelse
  åt något håll). Istället för att köra om hela `seed.sql` (som inleds
  med en destruktiv `TRUNCATE model_references, known_issues`) gav jag
  användaren en riktad `INSERT` med bara de 11 nya raderna, utan att röra
  `known_issues` eller de 46 befintliga raderna. **Kört mot
  produktions-DB och bekräftat 2026-08-13** — `model_references` har nu
  57 rader, matchar `referenceData.ts` exakt. Betraktas som löst.

## Lokal devmiljö återuppbyggd efter datormigrering (2026-08-22)

Användaren gjorde en migrering på sin dator — repot, `node_modules`,
Node.js och alla lokala `.env`-filer var borta. Klonade om från
`github.com/stadion1/Autopilot` och byggde upp devmiljön från grunden.

**Node.js saknades helt** (inte samma rättighetsproblem som tidigare
noterat i "Carzi-designsystem"-avsnittet nedan — den gången var
problemet att ingen körning alls var möjlig, den här gången var Node
bara inte installerat). `winget install` misslyckades två gånger med
en trasig källcache (`0x8a15000f`), och `winget source reset --force`
kräver adminrättigheter som saknas på jobbdatorn — bekräftar att
rättighetsbegränsningen från tidigare session fortfarande gäller för
winget specifikt. Användaren installerade Node.js manuellt istället
(v24.19.0/npm 11.17.0), vilket löste det. **Detta gör punkt 6d och 11 i
prioriterade nästa steg görbara nästa gång** — själva `npm run build`/
`tsc --noEmit`-körningen är dock ännu inte gjord, bara `npm install` +
`next dev` + en riktig analys i webbläsaren.

**Upptäckt: repot hade ALDRIG haft en `.gitignore`.** `node_modules` och
lock-filerna låg som ospårade filer i `git status` sen tidigare (synligt
redan i utgångsläget för den här sessionen). Skapade en root-`.gitignore`
(`node_modules/`, `.env`, `.env.local`, `.env.*.local`, `.next/`, `dist/`)
INNAN några `.env`-filer skapades, för att inte riskera att hemligheter
råkar committas.

**`.env.local` (huvudapp) och `scraper-service/.env` skapade** från
värden användaren hämtade ur Railway. Ett verkligt fynd under processen:
`SCRAPER_SECRET` skilde sig mellan de två inklistrade värdeuppsättningarna.
Orsak: användaren hade kopierat värden från TVÅ olika Railway-tjänster —
den ena från den faktiska `scraper-service` (kör `server.ts`, den enda
som validerar `x-scraper-secret`-headern), den andra från `nightly-scraper`
(kör `nightly.ts`, som ALDRIG läser `SCRAPER_SECRET` — den skrapar direkt
utan HTTP-anrop). Det senare värdet var alltså en röd sill. Satte det
verifierat rätta värdet (`server.ts`s) konsekvent på båda ställena.

**`tsx` laddar inte `.env` automatiskt** trots att det såg ut så vid
första anblick — kräver Node/tsx:s `--env-file`-flagga explicit.
`scraper-service`s `dev`-script kraschade direkt med "Missing
NEXT_PUBLIC_SUPABASE_URL..." tills `package.json`s `dev`-script
uppdaterades till `tsx watch --env-file=.env server.ts`.

**Playwright saknade nedladdade Chromium-binärer** — `npm install`
installerar bara `npx`-paketet, inte själva webbläsaren. Första
testanalysen gav 422 med "Executable doesn't exist..."; löst med
`npx playwright install chromium` i `scraper-service/`.

**Verifierat end-to-end i webbläsaren (2026-08-22):** en riktig
Blocket-annons (`blocket.se/mobility/item/25764733`, Tesla Model 3 Long
Range 2023) kördes genom hela kedjan lokalt — scraping, marknads-
jämförelse, deal score (57/100), ägandekostnadsberäkning,
AI-sammanfattning — allt fungerade. Enda konsolvarningen var en
befintlig, ofarlig React-hydreringsvarning på en SVG-cirkel i navbaren
(server/klient-mismatch på ett numeriskt attribut) — inte undersökt
vidare, verkar vara ett förbefintligt kosmetiskt problem, inte relaterat
till migreringen.

## Onödig Chromium-uppstart gjorde Blocket-scrapning ~12x långsammare (2026-08-22)

Uppföljning samma dag: användaren tyckte den nyss testade analysen kändes
seg — spinnern satt kvar länge på sista steget ("AI-analys och
riskbedömning") och "Tar lite längre tid än vanligt"-texten dök alltid
upp.

**Rotorsak:** `parseBlocket()` i `scraper-service/blocket.ts` tar en
`page`-parameter men ignorerar den helt (`_: unknown`) — parsern pratar
uteslutande med `blocket-api.se` via vanlig `fetch()`, precis som
kommentaren i `pages/api/process.ts` redan påstod ("Playwright körs
INTE här"). Trots det körde `scraper-service/parsers.ts`s
`scrapeAndParse()` OVILLKORLIGEN `createStealthBrowser()` (full headless
Chromium-launch + context + page) innan den routade till rätt
sajt-parser — även för Blocket, som aldrig rörde webbläsaren. En hel
webbläsarprocess startades och stängdes för ingenting, för varenda
Blocket-analys.

**Mätt effekt** (samma annons, `POST /scrape` direkt mot lokal
scraper-service, kringgår analys-cachen): 8 521 ms → 692 ms, ~12x
snabbare. Loggen från INNAN fixen visade `Klar: OK (8521ms)` för ett
enda JSON-API-anrop som borde ta under en sekund — bekräftar att nästan
hela tiden gick åt webbläsarlanseringen, inte själva datahämtningen.

**Fixat:** `scrapeAndParse()` har nu en tidig retur för
`site === 'blocket'` som anropar `parseBlocket()` direkt utan att röra
`createStealthBrowser()`/`respectRateLimit()` — Wayke/Bytbil (som
faktiskt använder Playwright för riktig sidladdning) är opåverkade,
samma browser-väg som innan.

**Även fixat, separat men relaterat fynd:** `LONGER_THAN_USUAL_MS` i
`app/analysis/[id]/page.tsx` stod på 8000ms — men samma vy lovar
"vanligtvis 10–20 sekunder", så meddelandet var garanterat att visas på
i princip VARJE analys (8s < den egna utlovade normaltiden). Höjd till
20000ms så den bara triggar när något faktiskt tar ovanligt lång tid.

**Kräver Railway-omdeploy innan produktionen märker skillnaden** —
scraper-service körs på Railway, inte lokalt; fixen är bara verifierad
i den lokala devmiljön denna session. **Inte omtestat i produktion än.**

**Öppen fråga, inte utredd:** hur mycket av de återstående ~692ms (och
resten av den totala analystiden — AI-anropet, DB-sparningarna) som
går att korta ytterligare är inte undersökt. Om användaren fortfarande
tycker det känns segt efter Railway-deployen är nästa naturliga plats
att mäta `analyzeWithAI()`s svarstid och de sekventiella
DB-sparningarna i `process.ts` (`saveCarData`/`saveMarketListing` körs
just nu efter varandra, inte parallellt — litet men enkelt vinstläge).

## Kända begränsningar / öppna trådar

- **Carzi-designsystem (mörka kort) — försökt och REVERTERAT (2026-08-14).**
  Användaren gav 7 tokens: `--carzi-midnight` (navbar/footer),
  `--carzi-deep` (kort/hover), `--carzi-white` (sidbakgrund, matchade
  redan `--white`), `--carzi-blue` (CTA), `--carzi-green`/`--carzi-amber`/
  `--carzi-red` (bra/okej/tveksam affär). Implementerat i `app/globals.css`
  (nya `:root`-tokens + en mörk variant av `--accent`/`--amber`/`--red`
  för text direkt på vit bakgrund, eftersom de fulla Carzi-färgerna hade
  för låg kontrast som ren text — se kommentarerna i filen om någon
  bygger vidare), `.nav`/`.card` fick lokalt omdefinierade
  `--ink-*`/`--surface-*`/`--border*`-tokens (CSS custom properties
  ärvs neråt, så alla ~100 befintliga regler som redan läste
  `var(--ink-2)` etc. blev automatiskt rätt utan att röras individuellt),
  CTA-knappar → blue, ny `<Footer>` i `layout.tsx`.

  **Två separata problem:**
  1. Ett byggfel: en CSS-kommentar som radade upp variabelnamn med `/`
     (`--ink-*/--surface-*`) skapade av misstag en `*/`-sekvens som
     stängde kommentarblocket i förtid — Vercel-bygget floppade med
     "Unknown word". Fixat (kommatecken istället för snedstreck), och
     sökte igenom alla fyra ändrade filer efter samma mönster (hittade
     inga fler).
  2. **Efter att bygget gick igenom och användaren faktiskt SÅG resultatet
     live:** alla nio kort blev samma mörka marinblå ton rakt igenom —
     tungt/monotont, och AI-sammanfattningskortet (som tidigare var det
     ENDA mörka elementet på en annars ljus sida, ett avsiktligt
     utstickande blickfång) försvann in i mängden eftersom allt annat
     nu såg likadant ut. Användaren bad om revert direkt efter att ha
     sett skärmdumpen — inget efterfrågades, kört direkt (`git revert`
     på båda committen, pushat).

  **Kunde INTE verifieras visuellt innan push** — Node.js/npm saknas i
  den här miljön (varken Git Bash eller PowerShell hittar `node`/`npm`,
  bekräftat denna session; en bakgrundsuppgift är flaggad för att
  utreda/fixa det), Python saknas också, och Browser-panelens `file://`-
  navigering renderar bara "static snapshots" som aldrig visade sig
  fungera för lokala HTML-mockuper (testat två vägar, båda gav tom sida).
  Enda sättet att faktiskt SE ändringen var att pusha till `main` och
  kolla den riktiga Vercel-deployen — en medveten avvägning
  (`git revert` är billigt, det här är en ren CSS-ändring utan
  data/migrationer, appen är i beta) men det är därför felet inte
  upptäcktes förrän efter push.

  **Lärdom inför en framtida omstart:**
  - Undvik `/`-tecken i CSS-kommentarer som radar upp `--variabel-namn`
    — skriv ut hela namnet eller separera med kommatecken/radbyte
    istället för snedstreck, annars riskeras samma `*/`-fälla.
  - Fråga om precis vilka kort som ska bli mörka INNAN implementation,
    inte bara anta "alla kort med `.card`-klassen" — användarens
    feedback tyder på att en mer selektiv approach (bara hero-kortet
    och/eller AI-sammanfattningen mörka, resten kvar ljusa) hade
    fungerat bättre än att göra alla nio korttyper identiskt mörka.
  - Om Node.js/Python fortfarande saknas nästa gång: fråga användaren
    om ett sätt att förhandsgranska INNAN kodning påbörjas (Vercel
    preview-branch, eller om de faktiskt har `npm run dev` lokalt)
    istället för att upptäcka detta mitt i arbetet.
  - Koden är helt reverterad — `app/globals.css`, `app/page.module.css`,
    `app/analysis/[id]/page.module.css` och `app/layout.tsx` är tillbaka
    till läget före denna session (ljust tema, samma som innan).
    Ingenting av Carzi-arbetet finns kvar i `main`.

- **"Misslyckades att spara" — två kombinerade buggar hittade och
  fixade (2026-08-14).** Användaren fick felet på en riktig annons
  (Mercedes-Benz E450, Blocket-ID 24714696). Utredning:
  1. `parseBlocket()` i `scraper-service/blocket.ts` satte `model` direkt
     från Blockets egna `specs['Modell']`-fält — för denna annons "E450",
     inte den bevakade modellfamiljen "E-klass". `nightly.ts` löste redan
     exakt det här problemet för nattens sökresultat-baserade insamling
     (Blockets modellnamngivning är inkonsekvent mellan märken — rena
     namn för Volvo, motorvarianter för BMW/Mercedes) via en
     `matchTrackedModel()`-tvåstegsmatchning (exakt `model`-fält, sen
     normaliserad `series`-fält), men den logiken portades aldrig till
     ad-hämtningsflödet som körs när en användare klistrar in en
     enskild URL. Verifierat konkret: `market_listings` hade 8 riktiga
     rader för Mercedes-Benz E-klass 2022 (skrivna med rätt modellnamn av
     nightly-scrapern), men den enskilda analysen letade efter "E450" och
     hittade noll träffar — `get_market_median()` missade data som
     faktiskt fanns. Bedömt påverka troligen fler märken med
     trimkods-namngivning (BMW, Audi, m.fl.), inte bara Mercedes.
  2. Missen i (1) drev prissättningen till `theoretical`-grenen (varken
     marknadsmedian eller nybilspris hittades) — men `analyses.median_source`s
     CHECK-constraint i databasen tillät bara `'market'`/`'new_car_list'`,
     aldrig uppdaterad när `'theoretical'` lades till i koden tidigare i
     sessionen (samma dag). Sparningen kraschade på constrainten.
     `process.ts`s catch-block kastade dessutom bort det riktiga
     felmeddelandet innan det skrev den generiska "Misslyckades att
     spara" — samma tysta-catch-mönster som AI-sammanfattningens bugg
     tidigare i sessionen, men aldrig fixat här.

  **Fixat:** flyttade `TRACKED_MODELS` + `normalizeToken()` till
  `blocket.ts` (enda källan nu — `nightly.ts` importerar dem istället för
  att hålla en egen kopia, samma lärdom som `model_references`-glappet).
  Ny `findTrackedModel()` i `blocket.ts` kör samma tvåstegsmatchning i
  `parseBlocket()`. Breddade DB-constrainten till att tillåta
  `'theoretical'`. Lade till felloggning i `process.ts`s save-catch.
  **Kräver manuell åtgärd innan det är helt live:** (a) migrationen i
  `data/schema.sql` (sök "Migration: analyses.median_source — add
  'theoretical'") måste köras i Supabase, (b) Railway måste deploya om
  `scraper-service` — koden är pushad till samma repo men det är inte
  verifierat att Railway auto-deployar från den branchen. **Inte
  omtestat i produktion än** — testa samma URL igen efter båda stegen.
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
- **Node.js nu tillgängligt lokalt igen (fixat 2026-08-22, se egen
  sektion ovan)** — men en riktig `npm run build`/`tsc --noEmit` är
  fortfarande inte körd. Alla TypeScript-ändringar i tidigare sessioner
  (modellutökningen, `model_references`-inkopplingen m.fl.) är fortfarande
  bara manuellt brace-räknade, inte kompilerade. Bra att göra vid nästa
  kodändring i de filerna.
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

## Idé: "Värdera min bil" — omvänt flöde (föreslaget av användaren 2026-08-13)

Istället för att klistra in en annons-URL: användaren matar in sin EGEN
bils märke/modell/årsmodell/mätarställning/drivmedel (inget att skrapa)
och får en värderingsuppskattning tillbaka. Öppnar en ny målgrupp —
säljare som vill prissätta INNAN de lägger upp en annons, inte bara
köpare som utvärderar en befintlig — och kan fungera som en stark
content-marketing-krok ("gratis värdering").

**Nyckelinsikt: största delen av infrastrukturen finns redan.**
`calculatePricing()` i `lib/scoring/engine.ts` räknar redan fram ett
prisestimat (marknadsmedian / värdeminskningskurva / Skatteverkets
nybilspris) helt oberoende av om det finns en annons — idag används det
bara för att jämföra mot en skrapad annons pris, men själva estimatet
kräver ingen annons. Samma sak gäller `known_issues`-uppslaget och
`calculateOwnershipCosts()`.

**Grovskiss, inte designad i detalj än:**
- Nytt enkelt formulär (inget URL-fält): märke/modell (dropdown från
  `model_references`), årsmodell, mätarställning, drivmedel, ev. växellåda.
- Ny lättviktig API-route som bygger en partiell `CarListing` direkt från
  formuläret (ingen skrapning) och återanvänder samma scoring-/
  pricing-funktioner som idag.
- Svar: prisintervall (low/median/high) + konfidens + relevanta
  `known_issues` för modellen/årsmodellen + ägandekostnadsuppskattning.
  AI-sammanfattningen behöver en annan promptvinkling ("här är vad din
  bil är värd och varför", inte "är det här ett bra köp").
- Schemafråga att lösa: `analyses`-tabellen är byggd kring
  `source_url`/`source_site`. Enklast är sannolikt en ny nullbar
  `entry_type`-kolumn ('listing' | 'self_valuation') snarare än en helt
  ny tabell, så AI-sammanfattnings-lagring/cachning kan återanvändas rakt av.
- Utan en riktig annons saknas skick/utrustningsnivå — estimatet blir
  nödvändigtvis ett "snittskick"-antagande om inte valfria fält
  (skick, utrustningsnivå) läggs till. Bör vara tydligt i disclaimer:
  "utgångspunkt för prissättning, inte en officiell värdering".

Inget scopat eller tidsuppskattat — spara till en egen framtida session
när det blir aktuellt att designa/bygga.

## Prioriterade nästa steg (föreslagna, ej bekräftade av användaren)

1. Ta ställning till orimligt-pris-varning per analys, som ett
   användarvänt komplement till den tysta ingestion-filtreringen.
2. Följ upp liggtids-påminnelsen när den triggas — avgör om datan
   räcker för att bygga "förväntad tid till sålt".
3. Vercel Pro-tröskeln (se ovan) — inget att göra nu, men bevaka
   `scored`/`total` i `score-listings`-loggarna över tid.
4. Kör samma Deep Research-mönster för resterande 31 modeller (Volvo,
   Toyota, Volkswagen, BMW och Mercedes-Benz klara, 170 rader totalt).
   Nästa naturliga batch: Audi (5 modeller, redan i `model_references`
   sen tidigare denna session men saknar known_issues helt) — flest
   bevakade modeller kvar bland de otäckta märkena. Samma process varje
   gång: (1) grepa `seed.sql` efter befintliga rader för märket FÖRST
   och ge dem till researchen som "redan täckt" (lärdom från Toyota-
   dubbletten), (2) kör promptmallen — inkludera nu ALLTID den explicita
   instruktionen om korrekta å/ä/ö (lades till efter BMW-passet, gav
   ett helt rent Mercedes-pass), (3) verifiera recall-raderna mot
   press/NHTSA/KBA/DVSA (stickprov av de allvarligaste räcker om
   strukturen är ren — Toyota 8/17, VW 10/10, BMW 6/6, Mercedes 6/9),
   (4) gör ALLTID en riktad svensk-press-sökning per märke utöver att
   verifiera researchens egna rader — Toyota-passet hittade en verklig
   recall (Yaris parkeringsbroms) som researchen missat helt, troligen
   för att den aldrig fick ett NHTSA-nummer och därför inte dök upp i
   de USA-tunga källorna, (5) kolla rule_id-listan efter icke-ASCII-
   tecken innan import (Mercedes-passet hade ett, `ä` i själva id:t).
5. Bränsleförbrukning per modell (se ovan) — i en egen session: verifiera
   EEA-datasetets faktiska struktur/storlek och Sverige-filtrering
   (helst via direkt nedladdning/inspektion av riktiga rader, inte bara
   metadata), ta ett nytt försök på Transportstyrelsens API-portal via
   en annan metod än direkt WebFetch, och lägg fram en rekommendation
   (bygg pipeline / avstå) innan någon kod skrivs.
6. **Produktionsklar-checklista innan bredare exponering** (begärd av
   användaren 2026-08-13, efter en fråga om hur långt appen är från att
   kunna testas av riktiga användare). Nuläge: kärnflödet är stabilt
   och stresstestat genom många riktiga analyser denna session, och en
   per-analys-disclaimer finns redan inbyggd
   (`app/analysis/[id]/page.tsx`s `Disclaimer`-komponent). Räcker för
   vänner/kollegor som testar informellt redan idag. För en bredare
   delad länk saknas:
   a. **Rate limiting på `/api/analyze`** (störst risk — en spridd
      länk kan hamras och dra upp Claude-API-kostnader eller
      överbelasta scraper-servicen). Förslag: en Supabase-tabell-baserad
      räknare (IP eller enkel token) istället för att lägga till
      Upstash Redis som ny infra — Vercel serverless functions är
      stateless mellan anrop så en in-memory-räknare fungerar inte.
   b. **Enkel integritets-/villkorssida** — vad som samlas in (klistrade
      URL:er, skrapad bildata inkl. VIN/regnr), varför, hur länge,
      vilka tredje parter (Anthropic för AI-sammanfattningen, Supabase
      för lagring), kontaktuppgifter. Ingen analytics/tracking hittad
      i koden (sökt igenom `app/`) så inget cookie-samtycke behövs för
      det specifikt, men sidan bör ändå finnas för riktiga användare.
   c. **Sentry (eller motsvarande) för felmonitorering** — inget sånt
      paket finns i `package.json` idag. Koppla in i de befintliga
      catch-blocken (`process.ts`, cron-routes) så fel syns proaktivt
      istället för att kräva manuell loggläsning i Vercel-panelen.
   d. **Kör en riktig `npm run build`/typecheck** på scraper-service och
      huvudappen — Node.js finns nu tillgängligt lokalt igen (fixat
      2026-08-22), så det här är inte längre blockerat, bara inte gjort
      än.
   e. (Lägre prioritet) Snabb mobilvy-/tvärwebbläsargenomgång — inte
      kontrollerad denna session.
7. "Värdera min bil"-idén (se egen sektion ovan) — inget att göra
   förrän användaren vill designa/bygga den på riktigt.
8. Kör migrationen för `analyses.equipment` i Supabase och verifiera att
   Railway deployat om `scraper-service` (se "Utrustningsdata i
   AI-sammanfattningen" ovan) — annars sparas utrustningslistan aldrig
   trots att koden är pushad.
9. Utrustningsviktad prisjustering (se egen sektion ovan) — större
   projekt, inte scopat. Naturlig uppföljning till det billiga steget
   som redan är byggt.
10. Carzi-designsystemet (se "Kända begränsningar" ovan) — reverterat,
    inte längre i `main`. Om det tas upp igen: fråga FÖRST exakt vilka
    kort som ska bli mörka (troligen inte alla nio — användarens
    feedback pekade på att det blev för monotont) innan någon CSS
    skrivs, och säkerställ en förhandsgranskningsväg (Vercel
    preview-branch eller lokal `npm run dev`) innan kodning påbörjas.
11. Verifiera den utökade `TRACKED_MODELS`/`MODEL_REFERENCES` (se
    "Utökad modelltäckning" ovan) mot en riktig `npm run build`/
    `tsc --noEmit` — Node.js finns nu tillgängligt lokalt igen (fixat
    2026-08-22), fortfarande bara manuellt brace-räknad, inte kompilerad.
    Kolla även Railway-loggarna
    efter några nätters `nightly.ts`-körning för att se om
    `matchTrackedModel()` faktiskt får träffar på de nya modellerna
    (samma modellnamn-matchningsosäkerhet som redan gäller BMW/Mercedes
    enligt `NIGHTLY_SCRAPER.md` — särskilt värt att kolla för Opel
    "Grandland" mot "Grandland X" i äldre annonser, och BMW "1-serie"
    mot Blockets möjliga "1-Serie"/motorkod-varianter).
12. Basespris/depreciation för de 54 nybilsmodellerna i punkt 11 är
    uppskattningar, inte forskad data (se disclaimern i samma sektion)
    — och de har ingen `known_issues`-täckning alls. Naturlig
    fortsättning på punkt 4:s Deep Research-spår när det är dags,
    men en egen, större batch givet antalet nya märken.
