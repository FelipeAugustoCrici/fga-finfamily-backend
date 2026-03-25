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
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
})

app.addHook('onRequest', async (req, reply) => {
  if (req.method === 'POST' && req.url === '/finance/families') {
    return
  }

  if (req.method === 'POST' && req.url === '/telegram/webhook') {
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
