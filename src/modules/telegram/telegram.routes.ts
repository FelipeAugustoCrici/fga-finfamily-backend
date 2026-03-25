import type {
  FastifyInstance,
  FastifyBaseLogger,
  RawReplyDefaultExpression,
  RawServerDefault,
  RawRequestDefaultExpression,
} from 'fastify'
import type { ZodTypeProvider } from 'fastify-type-provider-zod'
import { TelegramController } from './telegram.controller'

type FastifyZodInstance = FastifyInstance<
  RawServerDefault,
  RawRequestDefaultExpression<RawServerDefault>,
  RawReplyDefaultExpression<RawServerDefault>,
  FastifyBaseLogger,
  ZodTypeProvider
>

export async function telegramRoutes(app: FastifyZodInstance) {
  const controller = new TelegramController()

  app.post('/webhook', (req, reply) => controller.webhook(req, reply))
  app.post('/link/code', (req, reply) => controller.generateCode(req, reply))
  app.get('/link/status', (req, reply) => controller.getLinkStatus(req, reply))
  app.delete('/link', (req, reply) => controller.unlink(req, reply))
}
