import fastify from 'fastify'
import cors from '@fastify/cors'
import { ZodError } from 'zod'
import { ZodTypeProvider, validatorCompiler, serializerCompiler } from 'fastify-type-provider-zod'
import { authMiddleware } from './shared/auth/auth.middleware'

import { financeRoutes } from '@/modules/finance'
import { telegramRoutes } from '@/modules/telegram/telegram.routes'

export const app = fastify({
  logger: true,
}).withTypeProvider<ZodTypeProvider>()

app.setValidatorCompiler(validatorCompiler)
app.setSerializerCompiler(serializerCompiler)

app.register(cors, {
  origin: (origin, cb) => {
    const allowed = (process.env.ALLOWED_ORIGINS || 'https://fga-finfamily.vercel.app')
      .split(',')
      .map((o) => o.trim())

    // Permite requisições sem origin (ex: mobile, Postman, server-to-server)
    if (!origin || allowed.includes('*') || allowed.includes(origin)) {
      cb(null, true)
    } else {
      cb(new Error(`CORS: origin ${origin} not allowed`), false)
    }
  },
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
})

app.addHook('onRequest', async (req, reply) => {
  console.log(`[APP] ${req.method} ${req.url}`)

  if (req.method === 'POST' && req.url === '/finance/families') {
    return
  }

  if (req.method === 'POST' && req.url.startsWith('/telegram/webhook')) {
    console.log('[APP] Webhook request — pulando auth')
    return
  }

  if (
    req.url.startsWith('/finance') ||
    req.url.startsWith('/me') ||
    req.url.startsWith('/persons/me') ||
    req.url.startsWith('/telegram')
  ) {
    await authMiddleware(req, reply)
  }
})

app.register(financeRoutes, { prefix: '/finance' })
app.register(telegramRoutes, { prefix: '/telegram' })

app.get('/', async (_, reply) => reply.send({ status: 'ok' }))
app.get('/health', async (_, reply) => reply.send({ status: 'ok' }))

app.get('/telegram/test', async (_, reply) => {
  console.log('[TEST] rota de teste chamada em:', new Date().toISOString())
  return reply.send({ ok: true, time: new Date().toISOString() })
})

app.setErrorHandler((error, _, reply) => {
  app.log.error(error)

  if (error instanceof ZodError) {
    return reply.status(400).send({
      message: 'Validation error',
      errors: error.issues,
    })
  }

  return reply.status(500).send({ message: 'Internal server error' })
})
