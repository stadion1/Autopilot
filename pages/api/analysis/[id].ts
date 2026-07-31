import { NextApiRequest, NextApiResponse } from 'next'
import { supabase, getAnalysis, getBetterDeals } from '../../../lib/supabase/client'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'GET') return res.status(405).end()

  const { id } = req.query
  if (!id || typeof id !== 'string') return res.status(400).json({ error: 'ID required' })

  // First get the status (fast)
  const { data: row } = await supabase
    .from('analyses')
    .select('id, status, error')
    .eq('id', id)
    .single()

  if (!row) return res.status(404).json({ error: 'Not found' })

  if (row.status === 'pending' || row.status === 'processing') {
    return res.status(200).json({ status: row.status })
  }

  if (row.status === 'error') {
    return res.status(200).json({ status: 'error', error: row.error })
  }

  // Done — return full analysis
  const analysis = await getAnalysis(id)
  if (!analysis) return res.status(404).json({ error: 'Analysis not found' })

  const betterDeals = await getBetterDeals(analysis.car, analysis.scores.deal)

  return res.status(200).json({ status: 'done', ...analysis, better_deals: betterDeals })
}
