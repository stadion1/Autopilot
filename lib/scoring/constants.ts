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
