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
Cron-jobb på Railway — körs varje natt kl 02:00
