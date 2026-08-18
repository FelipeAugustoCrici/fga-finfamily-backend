import {
  FastifyInstance,
  FastifyBaseLogger,
  RawReplyDefaultExpression,
  RawServerDefault,
  RawRequestDefaultExpression,
} from 'fastify'
import { ZodTypeProvider } from 'fastify-type-provider-zod'
import { IncomesController } from './incomes.controller'
import { createIncomeSchema, listIncomesQuerySchema, updateIncomeSchema } from './dtos'
import { paramIdSchema } from '@/shared/schemas/param-id.schema'

type FastifyZodInstance = FastifyInstance<
  RawServerDefault,
  RawRequestDefaultExpression<RawServerDefault>,
  RawReplyDefaultExpression<RawServerDefault>,
  FastifyBaseLogger,
  ZodTypeProvider
>

export async function incomesRoutes(app: FastifyZodInstance) {
  const controller: IncomesController = new IncomesController()

  app.post('/', { schema: { body: createIncomeSchema } }, (req, reply) =>
    controller.createIncome(req, reply),
  )
  app.get('/', { schema: { querystring: listIncomesQuerySchema } }, (req, reply) =>
    controller.getIncomes(req, reply),
  )

  app.get('/:id', { schema: { params: paramIdSchema } }, (req, reply) =>
    controller.getIncomeById(req, reply),
  )

  app.put('/:id', { schema: { body: updateIncomeSchema, params: paramIdSchema } }, (req, reply) =>
    controller.updateIncome(req, reply),
  )

  app.delete('/:id', { schema: { params: paramIdSchema } }, (req, reply) =>
    controller.deleteIncome(req, reply),
  )
}
