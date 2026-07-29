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
   bara `page` — inte `q`, `make`, `model` eller `sort` (testat, ger 422
   "Unexpected query parameters"). Den ger ett ofiltrerat, relevanssorterat
   flöde av alla ~143 000 bilannonser, 50/sida, max 50 sidor. Lösning:
   hämta sidor ur flödet och filtrera klientsidan mot en hårdkodad
   TRACKED_MODELS-lista (samma modeller som data/referenceData.ts).
   Täckningen byggs upp över flera nätter, inte allt på en gång.

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
