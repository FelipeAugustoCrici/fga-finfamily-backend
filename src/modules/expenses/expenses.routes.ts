import {
  FastifyInstance,
  FastifyBaseLogger,
  RawReplyDefaultExpression,
  RawServerDefault,
  RawRequestDefaultExpression,
} from 'fastify'
import { ZodTypeProvider } from 'fastify-type-provider-zod'
import { ExpensesController } from './expenses.controller'
import { createExpenseSchema } from '@/modules/expenses/dtos/create-expense.schema'
import {
  listExpensesQuerySchema,
  patchExpenseStatusSchema,
  updateExpenseSchema,
} from '@/modules/expenses/dtos'
import { paramIdSchema } from '@/shared/schemas/param-id.schema'

type FastifyZodInstance = FastifyInstance<
  RawServerDefault,
  RawRequestDefaultExpression<RawServerDefault>,
  RawReplyDefaultExpression<RawServerDefault>,
  FastifyBaseLogger,
  ZodTypeProvider
>

export async function expensesRoutes(app: FastifyZodInstance) {
  const controller: ExpensesController = new ExpensesController()

  app.post('/', { schema: { body: createExpenseSchema } }, (req, reply) =>
    controller.createExpense(req, reply),
  )
  app.get('/', { schema: { querystring: listExpensesQuerySchema } }, (req, reply) =>
    controller.listExpenses(req, reply),
  )

  app.get('/:id', { schema: { params: paramIdSchema } }, (req, reply) =>
    controller.getExpenseById(req, reply),
  )

  app.put('/:id', { schema: { body: updateExpenseSchema, params: paramIdSchema } }, (req, reply) =>
    controller.updateExpense(req, reply),
  )

  app.patch(
    '/:id/status',
    { schema: { body: patchExpenseStatusSchema, params: paramIdSchema } },
    (req, reply) => controller.updateStatus(req, reply),
  )

  app.delete('/:id', { schema: { params: paramIdSchema } }, (req, reply) => {
    controller.deleteExpense(req, reply)
  })
}
