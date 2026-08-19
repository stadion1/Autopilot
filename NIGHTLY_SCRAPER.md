# Nightly Scraper — specifikation

## Syfte
Scrapar Blocket varje natt för att bygga upp market_listings-tabellen
i Supabase med verkliga marknadspriser per modell och årsmodell.

## Flöde
1. Hämta sökresultat från blocket-api.se för varje modell i listan
2. Spara varje annons som en rad i market_listings
3. Deduplicera på source_url
4. Markera annonser som "sålda" när de försvinner
5. Kör SQL-aggregering för att uppdatera market_medians-tabellen

## API
Använder blocket-api.se/v1/search/car — samma API som parsern

## Schema
Se data/schema.sql — tabellen market_listings är redan skapad

## Deployment
Cron-jobb på Railway — körs varje natt kl 02:00. Se DEPLOY.md, Del 2b.

## Implementation — avsteg från specen ovan

Byggd i scraper-service/nightly.ts. Tre saker visade sig annorlunda än
antaget när API:t testades mot verkliga svar:

1. **Ingen per-modell-sökning finns.** blocket-api.se/v1/search/car accepterar
   bara `page` — inte `q`, `make`, `model` eller `sort` (testat igen
   2026-08-19, samma resultat: 422 "Unexpected query parameters"). Den ger
   ett ofiltrerat flöde av alla bilannonser, hårdkodat sorterat på
   `RELEVANCE` (bekräftat i svarets `metadata.params.sort`, går inte att
   ändra), 50/sida. Lösning: hämta sidor ur flödet och filtrera
   klientsidan mot en hårdkodad TRACKED_MODELS-lista (samma modeller som
   data/referenceData.ts).

   **Viktig gräns, verifierad direkt mot API:t 2026-08-19:** totalt
   antal aktiva bilannonser (`result_size.match_count`) var 141 756, men
   `metadata.paging.last` var 50 — ett HÅRT tak i själva API:t, oavsett
   hur många träffar sökningen har. Vi kan alltså aldrig nå fler än
   50 × 50 = 2 500 annonser (≈1,8% av beståndet) genom den här endpointen,
   hur `NIGHTLY_MAX_PAGES` än sätts. `MAX_PAGES` stod tidigare på 20 som
   default (env-var `NIGHTLY_MAX_PAGES`) — höjd till 50 (API:ts eget tak)
   2026-08-19 för att faktiskt nå så långt det går.

   Eftersom sorteringen är RELEVANCE och inte datum är "täckningen byggs
   upp över flera nätter" en överdrift — sidorna 1–50 är samma
   relevans-rankade fönster varje natt, det roterar bara i den mån
   RELEVANCE-rankningen själv förskjuts (boostade/nya annonser byter
   plats). Det är INTE en rullande genomgång av hela beståndet. Manuell
   koll på blocket.se:s riktiga sida (2026-08-19) visade sida 20 med
   annonser publicerade för en timme sedan — publiceringstakten är
   alltså i storleksordningen flera tusen/dag, vilket gör RELEVANCE-
   fönstret (2 500 annonser, blandat med äldre boostade annonser) till
   ett statistiskt stickprov, inte en fullständig fångst av nya
   annonser. Accepterat läge för nu — målet är ett representativt
   stickprov för marknadsmedianen per modell/år, inte att fånga allt.
   Om fullständig täckning blir viktigt senare krävs skrapning av
   blocket.se:s riktiga sida (troligen med riktig datumsortering) istället
   för den här wrapper-API:n — större omarbetning, inte gjord.

2. **Ingen market_medians-tabell skapas.** get_market_median() i
   data/schema.sql aggregerar redan live från market_listings vid varje
   anrop — inget separat uppdateringssteg behövs.

3. **"Sålda" markeras med 5 nätters karens**, inte direkt vid första
   natten en annons saknas i urvalet — se mark_stale_listings_sold() i
   data/schema.sql (migrationslängst ner i filen, måste köras manuellt
   i Supabase innan första nightly-körningen).

Modellmatchning (BMW/Mercedes namnger modell/serie inkonsekvent i Blockets
data) är best-effort — kolla Railway-loggarna efter de första körningarna
och justera TRACKED_MODELS eller matchTrackedModel() i nightly.ts om vissa
modeller aldrig får träffar.
