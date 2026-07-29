/**
 * scraper-service/supabase.ts
 *
 * Minimal Supabase-klient för nightly.ts. Separat från lib/supabase/client.ts
 * i Next.js-appen eftersom scraper-service byggs och deployas fristående
 * (Dockerfile kopierar bara filer inuti scraper-service/, se Dockerfile).
 */

import { createClient } from '@supabase/supabase-js'
import WebSocket from 'ws'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY

if (!supabaseUrl || !supabaseKey) {
  throw new Error('Missing NEXT_PUBLIC_SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY')
}

// supabase-js always constructs a Realtime client, which needs a WebSocket
// implementation — Node 20 has no native global WebSocket. We never use
// realtime (only .upsert()/.rpc()), but the constructor still requires this.
export const supabase = createClient(supabaseUrl, supabaseKey, {
  realtime: { transport: WebSocket as any },
})
