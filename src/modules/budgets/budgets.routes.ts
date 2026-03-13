import {
  FastifyInstance,
  FastifyBaseLogger,
  RawReplyDefaultExpression,
  RawServerDefault,
  RawRequestDefaultExpression,
} from 'fastify'
import { ZodTypeProvider } from 'fastify-type-provider-zod'
import { BudgetsController } from './budgets.controller'
import { createBudgetsSchema } from './dtos/create-budgets.schema'
import { monthYearQuerySchema } from '@/shared/schemas/month-year-query.schema'

type FastifyZodInstance = FastifyInstance<
  RawServerDefault,
  RawRequestDefaultExpression<RawServerDefault>,
  RawReplyDefaultExpression<RawServerDefault>,
  FastifyBaseLogger,
  ZodTypeProvider
>

export async function budgetsRoutes(app: FastifyZodInstance) {
  const controller: BudgetsController = new BudgetsController()

  app.post('/', { schema: { body: createBudgetsSchema } }, (req, reply) =>
    controller.upsertBudget(req, reply),
  )
  app.get('/', { schema: { querystring: monthYearQuerySchema } }, (req, reply) =>
    controller.listBudgets(req, reply),
  )
  app.get('/:id', (req, reply) => controller.getBudgetById(req, reply))
  app.delete('/:id', (req, reply) => controller.deleteBudget(req, reply))
}
