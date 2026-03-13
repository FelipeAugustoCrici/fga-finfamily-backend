import 'dotenv/config'
import type { VercelRequest, VercelResponse } from '@vercel/node'
import { app } from '@/app'

let isReady = false

async function ensureAppReady() {
  if (!isReady) {
    await app.ready()
    isReady = true
  }
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  await ensureAppReady()
  app.server.emit('request', req, res)
}
