/**
 * Delade konstanter mellan scoringmotorn (server) och UI:t (klient).
 * Ligger i en egen fil utan andra imports så att klientkomponenter kan
 * importera den utan att dra in serverberoenden (t.ex. Supabase-klienten)
 * som resten av engine.ts använder.
 */

// Sätts som confidence-anledning när modellen helt saknas i referensdatabasen
// (varken märke eller modell hittades) — UI:t använder den exakta strängen
// för att avgöra om en tydlig "vi saknar data"-varning ska visas.
export const UNKNOWN_MODEL_REASON = 'Begränsad marknadsdata för denna modell'

// Mätarställning ensam, inte årsmodell — en förbeställd "nästa års modell"
// (t.ex. Blockets "Ny bil till salu"-annonser) kan visa ett modellår som
// ligger EFTER innevarande år, vilket ger en förvirrande eller rentav
// negativ ålder om man räknar (CURRENT_YEAR - årsmodell). Mätarställning
// nära noll är ett robust, entydigt "det här är i praktiken en ny bil"-
// tecken oavsett hur årsmodellen råkar vara satt. Delad mellan
// lib/scoring/engine.ts (avgör om Skatteverkets nybilspris ska användas
// istället för marknadsmedian) och lib/supabase/client.ts:s
// getBetterDeals() (undviker att jämföra deal_score mellan bilar som
// prissatts mot olika baser) — lagd här istället för att importeras
// direkt från engine.ts för att undvika en cirkulär import (engine.ts
// importerar redan från lib/supabase/client.ts).
export const NEW_CAR_MAX_MIL_KM = 500
