import {
  FastifyInstance,
  FastifyBaseLogger,
  RawReplyDefaultExpression,
  RawServerDefault,
  RawRequestDefaultExpression,
} from 'fastify'
import { ZodTypeProvider } from 'fastify-type-provider-zod'
import { CreditCardsController } from './credit-cards.controller'
import { createCreditCardSchema } from './dtos/create-credit-card.schema'

type FastifyZodInstance = FastifyInstance<
  RawServerDefault,
  RawRequestDefaultExpression<RawServerDefault>,
  RawReplyDefaultExpression<RawServerDefault>,
  FastifyBaseLogger,
  ZodTypeProvider
>

export async function creditCardsRoutes(app: FastifyZodInstance) {
  const controller: CreditCardsController = new CreditCardsController()

  app.post('/', { schema: { body: createCreditCardSchema } }, (req, reply) =>
    controller.createCreditCard(req, reply),
  )
  app.get('/', (req, reply) => controller.getCreditCards(req, reply))
  app.get('/:id', (req, reply) => controller.getCreditCardById(req, reply))
  app.put('/:id', (req, reply) => controller.updateCreditCard(req, reply))
  app.delete('/:id', (req, reply) => controller.deleteCreditCard(req, reply))
}
